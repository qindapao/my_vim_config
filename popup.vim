
" =====================File: popup.vim {======================= 弹出窗口 =======

" ----------------------------------------------------------------------------


let g:popup_help_highlight_colors = ['red', 'DarkGreen', 'DarkCyan', 'DarkMagenta', 'green']


" 定义空格的高亮组

hi PopupHelpKeywordHighLightBlank ctermfg=red guifg=white guibg=black
if index(prop_type_list(), 'PopupHelpKeywordHighLightBlank') == -1
    call prop_type_add('PopupHelpKeywordHighLightBlank', {'highlight': 'PopupHelpKeywordHighLightBlank'})
endif


for i in range(len(g:popup_help_highlight_colors))
    let highlight_group = 'HelpPopupKeywordHighLight' . i
    execute 'hi ' . highlight_group . ' ctermfg=' . g:popup_help_highlight_colors[i] . ' guifg=' . g:popup_help_highlight_colors[i]
    if index(prop_type_list(), highlight_group) == -1
        call prop_type_add(highlight_group, {'highlight': highlight_group})
    endif
endfor

let g:popup_help_win_text_prop_id = 1
function! PopupMenuShowKeyBindings(search_mode, exec_mode, exec_cmd)
    " ! 开头的命令表示外部名 : 开头表示执行函数 其它表示执行vim内部表达式
    if a:exec_mode == 'auto'
        let user_command = a:exec_cmd
    elseif a:exec_mode == 'manu'
        let user_command = input('请输入一个命令:', '', 'command')
    endif

    " :TODO: 当前特殊情况太多了,函数需要重构
    if a:exec_mode != ''
        if user_command == 'get_vimrc_content'
            let data_list = readfile($MYVIMRC)
        elseif user_command == 'get_initel_content'
            let data_list = readfile('E:\code\emacs\emacs_config\init.el')
        elseif user_command == ':MarksSort'
            let data_list = eval(user_command[1:] . '()')
        else
            let user_command_str = ''
            try
                if user_command[0] == '!'
                    let user_command_str = system(user_command[1:])
                elseif user_command[0] == ':'
                    let user_command_str = eval(user_command[1:] . '()')
                else
                    redir => user_command_str
                    silent execute user_command
                    redir END
                endif
            catch
                let user_command_str = "null"
                echoerr "执行的命令无效: " . v:exception
            endtry

            let user_command_utf8 = iconv(user_command_str, &encoding, 'utf-8')
            let data_list = split(user_command_utf8, '\n')
        endif
    else
        let data_list = g:key_binding_list
    endif


    let opts = { 'line': 'cursor',
        \ 'col': 'cursor',
        \ 'padding': [0,1,0,1],
        \ 'wrap': v:true,
        \ 'border': [],
        \ 'close': 'button',
        \ 'highlight': 'Pmenu',
        \ 'resize': 1,
        \ 'zindex': 100,
        \ 'maxheight': 20,
        \ 'maxwidth': 80,
        \ 'title': 'tips',
        \ 'dragall': 1}
    let help_win = popup_create([''], opts)
    let help_win_nr = winbufnr(help_win)

    let input_str = ''
    while 1
        let c = getchar()
        if c == 27
            call popup_close(help_win)
            break
        elseif c == 9
            call PopupWinGetAllInfo(0)
            break
        elseif c == "\<BS>"
            let input_str = CommonRemoveLastChar(input_str)
        elseif c == 13
            let input_str = ''
        elseif c != 0
            let input_str .= nr2char(c)
        endif

        let keyword_match = []
        let text_property_list = []
        let first_line_text_property = []
        if(!empty(input_str))
            let match_line_cnt = 1
            let is_first_line = 1
            for item in ['{' . help_win . '} ' . input_str] + data_list
                let popup_str_in_bool = 0
                let fit_bool = (a:search_mode == 'and')? 1 : 0
                for sub_str in split(input_str, '\s\+')
                    if (a:search_mode == 'and' && item !~ '\c' . sub_str) || (a:search_mode == 'or' && item =~ '\c' . sub_str)
                        let fit_bool = 1 - fit_bool
                        break
                    endif
                endfor

                " :TODO: 这里可以优化性能,写一个总的正则,不用一个单词一个单词去匹配
                for sub_item in split(item, '\n')
                    if fit_bool
                        if !popup_str_in_bool
                            call extend(keyword_match, split(item, '\n'))
                        endif
                        if is_first_line
                            let start = 0
                            while 1
                                let match_str = matchstrpos(sub_item, '\s\+', start)
                                if match_str[0] == ''
                                    break
                                endif

                                let start = match_str[2]
                                call add(first_line_text_property, [1, match_str[1]+1, match_str[2] - match_str[1], 'PopupHelpKeywordHighLightBlank'])
                            endwhile
                            let is_first_line = 0
                        endif

                        " 循环高亮组
                        let highlight_cnt = 0
                        for input_str_regex in split(input_str, '\s\+')
                            let start = 0
                            while 1
                                let match_str = matchstrpos(sub_item, '\c' . input_str_regex, start)
                                if match_str[0] == ''
                                    break
                                endif

                                let start = match_str[2]
                                call add(text_property_list, [match_line_cnt, match_str[1]+1, match_str[2]-match_str[1], highlight_cnt % len(g:popup_help_highlight_colors)])
                            endwhile
                            let highlight_cnt += 1
                        endfor
                        let popup_str_in_bool = 1
                    endif
                    let match_line_cnt += 1
                endfor
                if !popup_str_in_bool
                    let match_line_cnt -= len(split(item, '\n'))
                endif
            endfor
        endif

        if (c != "\<Up>" && c != "\<Down>")
            call popup_settext(help_win, keyword_match)
            if !empty(text_property_list)
                for text_property in text_property_list
                    call prop_add(text_property[0], text_property[1], {'type': 'HelpPopupKeywordHighLight' . text_property[3], 'length': text_property[2], 'bufnr': help_win_nr, 'id': g:popup_help_win_text_prop_id})
                endfor
            endif

            if !empty(first_line_text_property)
                for text_property in first_line_text_property
                    call prop_add(text_property[0], text_property[1], {'type': text_property[3], 'length': text_property[2], 'bufnr': help_win_nr, 'id': g:popup_help_win_text_prop_id})
                endfor
            endif
        else
            let firstline = get(popup_getoptions(help_win), 'firstline', 1)
            if c == "\<Up>" && firstline > 1
                call popup_setoptions(help_win, #{ firstline: firstline - 1})
            elseif c == "\<Down>"
                call popup_setoptions(help_win, #{firstline: firstline + 1})
            endif
        endif

        redraw
    endwhile
endfunction

" ----------------------------------------------------------------------------


function! PopupWinGetAllInfo(paste_flag)
    let all_popup_win_list = popup_list()
    if all_popup_win_list != []
        let first_register = 1
        for winid in all_popup_win_list
            let bufnr = winbufnr(winid)
            let lines = getbufline(bufnr, 2, '$')
            if first_register
                let @a = join(lines, "\n") . "\n"
                let first_register = 0
            else
                let @A = join(lines, "\n") . "\n"
            endif
        endfor
        let @" = @a
        let @+ = @a

        if a:paste_flag
            normal! p
        endif
    endif
endfunction

" ----------------------------------------------------------------------------


source $VIM/keybinding_help.vim
" :TODO: 如果列表中只有一个元素，可能再增加一个弹窗显示详情
" :TODO: 可以支持类似fzf的模糊搜 索功能
" :TODO: 滚轮键只有在固定的时候可以使用，可以再处理下PgUp和PgDn
" 如果要搜 索所有的，输入.点号即可

" :TODO: 增加获取某个文件的行的后几行功能,用于查看_vimrc的注释信息和实际配置信息
nnoremap <silent> <leader><leader>psba :call PopupMenuShowKeyBindings('and', '', '')<cr>|                           " popup: 在自定义的列表中查找关键字,与的关系
nnoremap <silent> <leader><leader>psbo :call PopupMenuShowKeyBindings('or', '', '')<cr>|                            " popup: 在自定义的列表中查找关键字,或的关系
nnoremap <silent> <leader><leader>psbma :call PopupMenuShowKeyBindings('and', 'auto', 'map')<cr>|                   " popup: 在map命令中查找关键字,与的关系
nnoremap <silent> <leader><leader>psbmo :call PopupMenuShowKeyBindings('or', 'auto', 'map')<cr>|                    " popup: 在map命令中查找关键字,或的关系
nnoremap <silent> <leader><leader>psbea :call PopupMenuShowKeyBindings('and', 'auto', 'get_initel_content')<cr>|    " popup: 在emacs配置文件中查找关键字,与的关系

" 输入命令 marks 可以显示当前所有的标记
nnoremap <silent> <leader><leader>cm :call PopupMenuShowKeyBindings('and', 'manu', '')<cr>|                         " popup: 弹出窗口中显示所有的标记marks

nnoremap <leader>cpw :call popup_close(|                                                                            " popup: 关闭某一个弹出窗口(传入窗口ID)
nnoremap <leader>cpwa :call popup_clear()<cr>|                                                                      " popup: 关闭与清除所有的弹出窗口
nnoremap <silent> <leader>ypw :call PopupWinGetAllInfo(0)<cr>|                                                      " popup: 拷贝当前弹出窗口中的所有内容
nnoremap <silent> <leader>ypwp :call PopupWinGetAllInfo(1)<cr>|                                                     " popup: 粘贴当前弹出窗口中的所有内容


" ----------------------------------------------------------------------------

" =====================File: popup.vim }======================= 弹出窗口 =======

