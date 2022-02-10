:iabbrev heigth height
:iabbrev lenght length
:iabbrev retrun return
:iabbrev tihs this
:iabbrev reponse response

:iabbrev vc@ <Esc>0vExiimport<C-o>p from 'NEWCOMPONENTPATH';<Esc>
  \/components: {<Esc>,rsA<Esc>tkA<cr><C-o>P,<Esc>V2<C-]>:%s/NEWCOMPONENTPATH/<cr>
  \03Wli

:iabbrev tse <Esc>bvexiexpect(<cr>).toStrictEqual();<Esc>

:iabbrev tt@ <Esc>ctniimport { shallowMount} from '@tests/';<cr>
  \import <C-o>p from '';<cr><cr>
  \describe('<C-o>P', () => {<cr>
    \const wrapper = shallowMount(<C-o>P);<cr><cr>
    \it('mount', () => {<cr>
      \expect(<cr>
        \wrapper.exists()
      \).toBeTruthy();
    \});
  \});<Esc>,crptgg0j3WpBlv4exi@<Esc>lvu

:iabbrev dd@ <Esc>ivar_dump();die;<Esc>2bli$

:iabbrev ic@ <Esc>cfniimport { injectable} from 'inversify';<cr><cr>
  \@injectable()<cr>
  \class <C-o>p {<cr><cr>
  \}<cr><cr>
  \export default <Esc>cfni <C-o>P;<Esc>dts3kdd2k

:iabbrev qr@ print_r(str_replace('`', '', vsprintf(str_replace("?", "'%s'", $query->toSql()), $query->getBindings())));die;<Esc>Exvblx

:iabbrev obj@ <Esc>cfniconst <C-o>p = {<cr><cr>};<cr><cr>export default <C-o>p;
