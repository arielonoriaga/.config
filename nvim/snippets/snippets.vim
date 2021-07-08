:iabbrev tt@ <Esc>ctniimport { shallowMount} from "@tests/";<cr>
            \import <C-o>p from "";<cr><cr>
            \describe("<C-o>P", () => {<cr>
                \const wrapper = shallowMount(<C-o>P);<cr><cr>
                \it('mount', () => {<cr>
                    \expect(<cr>
                        \wrapper.exists()
                    \).toBeTruthy();
                \});
            \});<Esc>,crptgg0j3WpBlv4exi@<Esc>lvu

:iabbrev tihs this
:iabbrev heigth height

:iabbrev vc@ <Esc>0vExiimport<C-o>p from "NEWCOMPONENTPATH";<Esc>
        \/components: {<Esc>,rsA<Esc>tkA<cr><C-o>P,<Esc>V2<C-]>:%s/NEWCOMPONENTPATH/<cr>
        \03Wli

:iabbrev tse <Esc>bvexiexpect(<cr>).toStrictEqual();<Esc>
