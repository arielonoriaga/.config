# game-deploy-setup — `--temp-env` mode

Date: 2026-07-02

## Problem

`game-deploy-setup` configures GitHub Actions deploy secrets for crash-game repos,
but it **wipes every existing secret first** (the `gh secret list … | gh secret delete`
block). That is correct for a full re-provision, wrong for spinning up a *temporary*
test environment alongside the existing ones.

We want to stand up a throwaway env in an existing repo without disturbing its
current secrets or workflows: duplicate a chosen deploy workflow, repoint its secret
references to a prefixed `TEST_*` set, and push only those new secrets — additively.

This mirrors what `wizards.yml` already is to `deploy.yml` in the game repos: the same
workflow with its AWS/CloudFront secret names prefixed, shared refs (`GH_AUTH_TOKEN`,
`vars.BASE_URL`) left alone.

## Scope

New additive mode on the existing script — no new file.

```
game-deploy-setup --temp-env [--branch testmigration] [--prefix TEST_] \
                  [--rbw-entry "GitHub Actions Secrets - Test Migration"]
```

Reuses existing plumbing: `detect_repo`, `switch_gh_account`/`restore_gh_account`,
`set_secret`, `rbw_field`, `guard_disabled_repo`.

## Flow (each outward step interactively confirmed)

1. `detect_repo` + `switch_gh_account` (EXIT-trap restore, as today).
2. **Interactive-select** a file from `.github/workflows/*.yml` (fzf, numbered fallback).
3. **Duplicate → `.github/workflows/<prefix-lower>.yml`** (`test.yml`), rewriting the source:
   - `name:` → append ` (TEST)`
   - `on.push.branches` → single `[<branch>]`
   - **collapse** the `case "${{ github.ref_name }}"` block to one env, derived from the
     rbw entry's `AWS_BUCKET_URI` segment (`s3://<prefix>-<env>-…` → `prod`). Keeps only
     the `MAIN_CLOUDFRONT_DISTRIBUTION_ID` ref; staging/dev arms removed.
   - prefix `secrets.X` → `secrets.<PREFIX>X` **only** for keys present in the rbw entry
     (`AWS_S3_BUCKET_PREFIX`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`,
     `MAIN_CLOUDFRONT_DISTRIBUTION_ID`). `GH_AUTH_TOKEN`, `vars.BASE_URL` untouched.
4. **Push `TEST_*` secrets additively** from the rbw entry via `set_secret` (no delete).
   `AWS_BUCKET_URI` is script-only metadata for step 3, not pushed.
5. **Git:** create/checkout `<branch>`, commit the new workflow, push `-u` — which triggers
   the temp deploy. Each of push-secrets / commit / push is confirmed first.

## Order

Push secrets **before** pushing the workflow branch, so the deploy that the push triggers
finds its `TEST_*` secrets already present.

## Assumption

The workflow rewrite targets the standard crash-game deploy shape (the `case`-based env
step). If that anchor is absent, warn and do the secret-prefix pass only rather than guess.

## Prefix / push rule

The set of secrets to prefix in the workflow **and** push to GitHub is derived from the
rbw entry's keys, minus `AWS_BUCKET_URI`. One rule, keeps it reusable and safe.
