
" =====================File: display.vim {======================= 显示相关 =====

" ----------------------------------------------------------------------------

" lightline {
" 强制显示状态栏
set laststatus=2
let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'FugitiveHead'
    \ },
    \ }
" lightline }

" ----------------------------------------------------------------------------

" --------vim-indent-guides {-------------------------------------------------
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
autocmd filetype zim,markdown silent set conceallevel=2
autocmd FileType * if &ft != 'zim' && &ft != 'markdown' | set conceallevel=0 | endif
let g:indent_guides_auto_colors = 0
" 具體的顔色配置和主題綁定

" --------vim-indent-guides }-------------------------------------------------

" ----------------------------------------------------------------------------

" 主题和颜色设置 {
" 定义主题列表和颜色配置
let g:display_my_themes = [
    \ {'name': 'Lightning',         'fg': '#F0F0F0', 'bg': '#F5F5F5', 'config': {'global': {'airline_theme': 'catppuccin_frappe'}}},
    \ {'name': 'photon',            'fg': '#2E2E2E', 'bg': '#3C3C3C', 'config': {'global': {'airline_theme': 'catppuccin_frappe'}}},
    \ {'name': 'peachpuff',         'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'carbonized-light',  'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'carbonized-dark',   'fg': '#2E2E2E', 'bg': '#3C3C3C', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'everforest',        'fg': '#2E2E2E', 'bg': '#3C3C3C',
    \ 'config': { 
    \     'options': {'background': 'dark'},
    \     'global':  {
    \         'everforest_background': 'hard',
    \         'everforest_better_performance': 1,
    \         'airline_theme': 'everforest',
    \         },
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         ],
    \     },
    \ },
    \ {'name': 'everforest',        'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global': {
    \         'everforest_background': 'hard',
    \         'everforest_better_performance': 1,
    \         'airline_theme': 'everforest',
    \         },
    \    'post_command': [
    \        'set fillchars=vert:▒',
    \        'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \        ],
    \     },
    \ },
    \ {'name': 'sunbather',        'fg': '#2E2E2E', 'bg': '#3C3C3C',
    \ 'config': { 
    \     'options': {'background': 'dark'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#444444',
    \         ],
    \     },
    \ },
    \ {'name': 'sunbather',        'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \         'highlight Cursor guibg=#ff66cc guifg=NONE',
    \         ],
    \     },
    \ },
    \ {'name': 'schellar',  'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'highlight Cursor guibg=#ff66cc guifg=NONE',
    \         ],
    \     },
    \ },
    \ {'name': 'Laederon',  'fg': '#F0F0F0', 'bg': '#F5F5F5', 
    \ 'config': {
    \     'global': {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'highlight ColorColumn guibg=#eeeeee',
    \         'highlight Cursor guibg=#ff66cc guifg=NONE',
    \         ],
    \     },
    \ },
    \ {'name': 'jb',        'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {
    \         'airline_theme': 'catppuccin_frappe',
    \         'jb_style': 'light',
    \         'jb_enable_italic': 0,
    \         'jb_enable_unicode': 1,
    \         },
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=214 guifg=#FFA500',
    \         ],
    \     },
    \ },
    \ {'name': 'default',    'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \         ],
    \     },
    \ },
    \ {'name': 'lunaperche',      'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe'},
    \     'post_command': [
    \         ],
    \     },
    \ },
    \ {'name': 'off',      'fg': '#F0F0F0', 'bg': '#F5F5F5',
    \ 'config': { 
    \     'options': {'background': 'light'},
    \     'global':  {'airline_theme': 'catppuccin_frappe', 'colors_off_a_little': 1},
    \     'post_command': [
    \         'set fillchars=vert:▒',
    \         'highlight VertSplit ctermfg=green guifg=green',
    \         'highlight ColorColumn guibg=#eeeeee',
    \         'highlight CursorLine guibg=#f5f5f5',
    \         ],
    \     },
    \ },
    \ ]

" -------------------

" 定义辅助函数来设置主题和颜色
function! DisplaySetTheme(theme)
    if has_key(a:theme, 'config')
        " 设置全局变量
        if has_key(a:theme.config, 'global')
            for [key, val] in items(a:theme.config.global)
                execute 'let g:' . key . ' = ' . string(val)
            endfor
        endif

        " 设置 Vim 选项
        if has_key(a:theme.config, 'options')
            for [key, val] in items(a:theme.config.options)
                execute 'set ' . key . '=' . val
            endfor
        endif
    endif

    execute 'colorscheme ' . a:theme.name
    execute 'hi IndentGuidesOdd guibg=' . a:theme.fg . ' ctermbg=15'
    execute 'hi IndentGuidesEven guibg=' . a:theme.bg . ' ctermbg=15'

    " 执行后置命令
    if has_key(a:theme, 'config') && has_key(a:theme.config, 'post_command')
        for cmd in a:theme.config.post_command
            execute cmd
        endfor
    endif

    redraw
    echohl Question
    echo '* 正在应用主题：' . a:theme.name . ' ' . (g:display_my_color_name_index + 1) . '/' . len(g:display_my_themes)
    echohl None
endfunction

" -------------------

" 定义切换主题的函数
function! DisplayToggleMyOwnTheme()
    let g:display_my_color_name_index = (g:display_my_color_name_index + 1) % len(g:display_my_themes)
    call DisplayApplyTheme()
endfunction

" -------------------

" 定义应用主题的函数
function! DisplayApplyTheme()
    let theme = g:display_my_themes[g:display_my_color_name_index]
    call DisplaySetTheme(theme)
    " 保存当前主题状态到文件
    call writefile([g:display_my_color_name_index], expand('~/.vim_theme'))
endfunction

" -------------------

" 在 Vim 启动时读取主题状态并应用
if filereadable(expand('~/.vim_theme'))
    let g:display_my_color_name_index = readfile(expand('~/.vim_theme'))[0]
else
    let g:display_my_color_name_index = 0
endif

" -------------------

function! DisplayRemoveCommentItalic()
    let l:new_attrs = []

    " 获取 Comment 的 synID
    let l:id = synIDtrans(hlID('Comment'))

    " term/cterm/gui 样式
    for style_type in ['bold', 'underline', 'reverse', 'standout']
        if synIDattr(l:id, style_type, 'gui') == 1
            call add(l:new_attrs, 'gui=' . style_type)
        endif
        if synIDattr(l:id, style_type, 'cterm') == 1
            call add(l:new_attrs, 'cterm=' . style_type)
        endif
    endfor

    " 颜色
    let l:guifg = synIDattr(l:id, 'fg', 'gui')
    let l:ctermfg = synIDattr(l:id, 'fg', 'cterm')
    if l:guifg != ''
        call add(l:new_attrs, 'guifg=' . l:guifg)
    endif
    if l:ctermfg != ''
        call add(l:new_attrs, 'ctermfg=' . l:ctermfg)
    endif

    " 去掉 italic，不添加 gui=italic 或 cterm=italic

    " 如果没有其它样式，显式设置 gui=NONE 和 cterm=NONE
    if join(l:new_attrs, ' ') !~ 'gui='
        call add(l:new_attrs, 'gui=NONE')
    endif
    if join(l:new_attrs, ' ') !~ 'cterm='
        call add(l:new_attrs, 'cterm=NONE')
    endif

    " 构造并执行 highlight 命令
    let l:cmd = 'highlight Comment ' . join(l:new_attrs, ' ')
    execute l:cmd
endfunction

autocmd ColorScheme * call DisplayRemoveCommentItalic()
" 主题和颜色设置 }

" ----------------------------------------------------------------------------

" 设置打开和关闭语法高亮快捷键
" :TODO: 不知道从哪个配置开始NERDTree的显示不正常,需要先关闭语法高亮然后再打开语法高亮才能正常(默认会显示多余的^G字符,有空再定位吧,可能是哪个设置导致的)
" 定位方法是回退当前配置的git前面的提交,一直回退到不出问题的vimrc的版本
nnoremap <silent> <leader>sof :syntax off<cr>|          " display: 取消语法高亮(提高效率)
nnoremap <silent> <leader>son :syntax on<cr>|           " display: 取消语法高亮(增加可读性)

" ----------------------------------------------------------------------------

nnoremap <silent><F5> :call DisplayToggleMyOwnTheme()<CR>
autocmd VimEnter * call timer_start(50, { -> DisplayApplyTheme() })

" vim-highlighter 配置 {

" 这里最好不要直接用<CR>会覆盖掉一些重要的默认按键映射
nnoremap <C-CR>  <Cmd>Hi><CR>|                          " display: 当前高亮的下一个
nnoremap <C-S-CR>  <Cmd>Hi<<CR>|                        " display: 当前高亮的上一个
nnoremap <M-CR> <Cmd>Hi}<CR>|                           " display: 所有高亮的下一个
nnoremap <M-S-CR> <Cmd>Hi{<CR>|                         " display: 所有高亮的上一个

" vim-highlighter 配置 }

" =====================File: display.vim }======================= 显示相关 =====

