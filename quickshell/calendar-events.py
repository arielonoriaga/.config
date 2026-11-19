#!/usr/bin/env python3
import json
import sys
import urllib.request
from datetime import date, datetime, time, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo

SOURCES = Path.home() / ".local/share/aurora/calendars"
CACHE = Path.home() / ".cache/aurora"
DAYS_BEFORE = 45
DAYS_AFTER = 75
MAX_SPAN_DAYS = 14
MAX_EXPANSIONS = 5000
FETCH_TIMEOUT_S = 15
WEEKDAYS = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]


def unfold(text):
    return text.replace("\r\n", "\n").replace("\n ", "").replace("\n\t", "").split("\n")


def parse_line(line):
    head, _, value = line.partition(":")
    name, *params = head.split(";")
    return name.upper(), dict(p.split("=", 1) for p in params if "=" in p), value


def unescape(value):
    return value.replace("\\n", " ").replace("\\N", " ").replace("\\,", ",").replace("\\;", ";").replace("\\\\", "\\")


def vevents(lines):
    event, depth = None, 0
    for line in lines:
        name, params, value = parse_line(line)
        if name == "BEGIN":
            if value == "VEVENT":
                event, depth = {"EXDATE": []}, 0
            elif event is not None:
                depth += 1
        elif name == "END":
            if value == "VEVENT" and event is not None:
                yield event
                event = None
            elif event is not None:
                depth -= 1
        elif event is not None and depth == 0:
            if name == "EXDATE":
                event["EXDATE"] += [(params, v) for v in value.split(",")]
            else:
                event.setdefault(name, (params, value))


def moment(params, value):
    value = value.strip()
    if params.get("VALUE") == "DATE" or len(value) == 8:
        return date(int(value[:4]), int(value[4:6]), int(value[6:8]))
    stamp = datetime.strptime(value[:15], "%Y%m%dT%H%M%S")
    if value.endswith("Z"):
        return stamp.replace(tzinfo=timezone.utc)
    if "TZID" in params:
        try:
            return stamp.replace(tzinfo=ZoneInfo(params["TZID"].strip('"')))
        except Exception:
            return stamp
    return stamp


def local(value):
    if isinstance(value, datetime):
        return value.astimezone().replace(tzinfo=None) if value.tzinfo else value
    return datetime.combine(value, time())


def duration(text):
    sign = -1 if text.startswith("-") else 1
    units = {"W": 0, "D": 0, "H": 0, "M": 0, "S": 0}
    number, in_time = "", False
    for ch in text.lstrip("+-P"):
        if ch == "T":
            in_time = True
        elif ch.isdigit():
            number += ch
        else:
            key = "M" if ch == "M" and in_time else ch
            if ch == "M" and not in_time:
                key = "D"
            units[key] = int(number or 0)
            number = ""
    return sign * timedelta(weeks=units["W"], days=units["D"], hours=units["H"], minutes=units["M"], seconds=units["S"])


def shift_months(start, months, day):
    total = start.month - 1 + months
    year, month = start.year + total // 12, total % 12 + 1
    try:
        return start.replace(year=year, month=month, day=day)
    except ValueError:
        return None


def nth_weekday(start, months, spec):
    first = shift_months(start, months, 1)
    weekday = WEEKDAYS.index(spec[-2:])
    ordinal = int(spec[:-2] or 1)
    days = []
    probe = first
    while probe.month == first.month:
        if probe.weekday() == weekday:
            days.append(probe)
        probe += timedelta(days=1)
    try:
        return days[ordinal - 1] if ordinal > 0 else days[ordinal]
    except IndexError:
        return None


def candidates(start, rule):
    freq, interval = rule.get("FREQ"), int(rule.get("INTERVAL", 1))
    byday = [d for d in rule.get("BYDAY", "").split(",") if d]
    bymonthday = [int(d) for d in rule.get("BYMONTHDAY", "").split(",") if d]
    for step in range(MAX_EXPANSIONS):
        if freq == "DAILY":
            yield [start + timedelta(days=step * interval)]
        elif freq == "WEEKLY":
            monday = start - timedelta(days=start.weekday()) + timedelta(weeks=step * interval)
            days = [WEEKDAYS.index(d[-2:]) for d in byday] or [start.weekday()]
            yield [monday + timedelta(days=d) for d in sorted(days)]
        elif freq == "MONTHLY":
            if byday:
                yield [nth_weekday(start, step * interval, d) for d in byday]
            else:
                yield [shift_months(start, step * interval, d) for d in (bymonthday or [start.day])]
        elif freq == "YEARLY":
            yield [shift_months(start, 12 * step * interval, start.day)]
        else:
            yield [start]
            return


def occurrences(start, rule_text, window_end):
    rule = dict(p.split("=", 1) for p in rule_text.split(";") if "=" in p)
    count = int(rule["COUNT"]) if "COUNT" in rule else None
    until = moment({}, rule["UNTIL"]) if "UNTIL" in rule else None
    limit = local(until) + (timedelta(days=1) if isinstance(until, date) and not isinstance(until, datetime) else timedelta(seconds=1)) if until else None
    emitted = 0
    for batch in candidates(start, rule):
        for item in batch:
            if item is None or local(item) < local(start):
                continue
            if local(item) > window_end or (limit and local(item) >= limit) or (count is not None and emitted >= count):
                return
            emitted += 1
            yield item


def read_sources():
    if not SOURCES.exists():
        return None
    urls = [line.strip() for line in SOURCES.read_text().splitlines() if line.strip() and not line.startswith("#")]
    texts = []
    CACHE.mkdir(parents=True, exist_ok=True)
    for index, url in enumerate(urls):
        cached = CACHE / f"calendar-{index}.ics"
        try:
            with urllib.request.urlopen(url, timeout=FETCH_TIMEOUT_S) as response:
                text = response.read().decode("utf-8", "replace")
            cached.write_text(text)
            cached.chmod(0o600)
        except Exception:
            text = cached.read_text() if cached.exists() else ""
        texts.append(text)
    return texts


def entry(start, end, event):
    all_day = not isinstance(start, datetime)
    return {
        "time": "" if all_day else local(start).strftime("%H:%M"),
        "end": "" if all_day or end is None else local(end).strftime("%H:%M"),
        "title": unescape(event.get("SUMMARY", ({}, "(no title)"))[1]) or "(no title)",
        "location": unescape(event.get("LOCATION", ({}, ""))[1]),
    }


def collect(texts, window_start, window_end):
    events = [e for text in texts for e in vevents(unfold(text)) if "DTSTART" in e]
    overridden = {(e.get("UID", ({}, ""))[1], local(moment(*e["RECURRENCE-ID"]))) for e in events if "RECURRENCE-ID" in e}
    days = {}
    for event in events:
        if event.get("STATUS", ({}, ""))[1].upper() == "CANCELLED":
            continue
        start = moment(*event["DTSTART"])
        length = (moment(*event["DTEND"]) - start) if "DTEND" in event else duration(event["DURATION"][1]) if "DURATION" in event else timedelta(0)
        uid = event.get("UID", ({}, ""))[1]
        excluded = {local(moment(*ex)) for ex in event["EXDATE"]}
        if "RRULE" in event and "RECURRENCE-ID" not in event:
            starts = [s for s in occurrences(start, event["RRULE"][1], window_end)
                      if local(s) not in excluded and (uid, local(s)) not in overridden]
        else:
            starts = [start]
        for occurrence in starts:
            all_day = not isinstance(occurrence, datetime)
            span = max(1, min(MAX_SPAN_DAYS, length.days)) if all_day else 1
            for offset in range(span):
                day = local(occurrence).date() + timedelta(days=offset)
                if window_start <= day <= window_end.date():
                    days.setdefault(day.isoformat(), []).append(entry(occurrence, None if all_day else occurrence + length, event))
    for items in days.values():
        items.sort(key=lambda e: (e["time"] != "", e["time"]))
    return days


def main():
    texts = read_sources()
    if texts is None:
        print(json.dumps({"configured": False, "days": {}}))
        return
    today = date.today()
    window_end = datetime.combine(today + timedelta(days=DAYS_AFTER), time.max)
    print(json.dumps({"configured": True, "days": collect(texts, today - timedelta(days=DAYS_BEFORE), window_end)}))


if __name__ == "__main__":
    sys.exit(main())
