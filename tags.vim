
" =====================File: tags.vim {======================= 标签导航 ================================================

" ----------------------------------------------------------------------------

" tagbar 配置 {
" conf.ctags 配置 C:\Users\xx\ctags.d\conf.ctags
"
" --langdef=asciidocx
" --langmap=asciidocx:.ad.adoc.asciidoc
" --regex-asciidocx=/^=[ \t]+([^[:cntrl:]]+)/o \1/h/
" --regex-asciidocx=/^==[ \t]+([^[:cntrl:]]+)/. \1/h/
" --regex-asciidocx=/^===[ \t]+([^[:cntrl:]]+)/. . \1/h/
" --regex-asciidocx=/^====[ \t]+([^[:cntrl:]]+)/. . . \1/h/
" --regex-asciidocx=/^=====[ \t]+([^[:cntrl:]]+)/. . . . \1/h/
" --regex-asciidocx=/^======[ \t]+([^[:cntrl:]]+)/. . . . \1/h/
" --regex-asciidocx=/^=======[ \t]+([^[:cntrl:]]+)/. . . . \1/h/
" --regex-asciidocx=/\[\[([^]]+)\]\]/\1/a/
" --regex-asciidocx=/^\.([^ \t\.][^[:cntrl:]]+)/\1/t/
" --regex-asciidocx=/image::([^\[]+)/\1/i/
" --regex-asciidocx=/image:([^:][^\[]+)/\1/I/
" --regex-asciidocx=/include::([^\[]+)/\1/n/


" --langdef=txt
" --langmap=txt:.txt
" --regex-txt=/^(\={6}\s)(\S.+)(\s\={6})$/\2/h,heading/
" --regex-txt=/^(\={5}\s)(\S.+)(\s\={5})$/. 2/h,heading/
" --regex-txt=/^(\={4}\s)(\S.+)(\s\={4})$/.   \2/h,heading/
" --regex-txt=/^(\={3}\s)(\S.+)(\s\={3})$/.     \2/h,heading/
" --regex-txt=/^(\={2}\s)(\S.+)(\s\={2})$/.       \2/h,heading/

" --langdef=zim
" --langmap=zim:.txt
" --regex-zim=/^(\={6}\s)(\S.+)(\s\={6})$/\2/h,heading/
" --regex-zim=/^(\={5}\s)(\S.+)(\s\={5})$/. \2/h,heading/
" --regex-zim=/^(\={4}\s)(\S.+)(\s\={4})$/.   \2/h,heading/
" --regex-zim=/^(\={3}\s)(\S.+)(\s\={3})$/.     \2/h,heading/
" --regex-zim=/^(\={2}\s)(\S.+)(\s\={2})$/.       \2/h,heading/

" --langdef=vimwiki
" --langmap=vimwiki:.wiki
" --regex-vimwiki=/^=[ \t]+([^[:cntrl:]]+)[ \t]+=$/\1/h,header/
" --regex-vimwiki=/^==[ \t]+([^[:cntrl:]]+)[ \t]+==$/. \1/h,header/
" --regex-vimwiki=/^===[ \t]+([^[:cntrl:]]+)[ \t]+===$/.   \1/h,header/
" --regex-vimwiki=/^====[ \t]+([^[:cntrl:]]+)[ \t]+====$/.     \1/h,header/
" --regex-vimwiki=/^=====[ \t]+([^[:cntrl:]]+)[ \t]+=====$/.       \1/h,header/
" --regex-vimwiki=/^======[ \t]+([^[:cntrl:]]+)[ \t]+======$/.         \1/h,header/


let g:tagbar_type_zim = {
    \ 'ctagstype' : 'zim',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }
let g:tagbar_type_txt = {
    \ 'ctagstype' : 'txt',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }

let g:tagbar_type_vimwiki = {
    \ 'ctagstype' : 'vimwiki',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }
" vim 的文件类型依然是 asciidoc 但是呢使用自定义的 ctags 类型 asciidocx
" 这样就在既保持编辑器识别又能让tagbar按照自定义的方式处理标题
let g:tagbar_type_asciidoc = {
    \ 'ctagstype' : 'asciidocx',
    \ 'kinds' : [
        \ 'h:table of contents',
        \ 'a:anchors:1',
        \ 't:titles:1',
        \ 'n:includes:1',
        \ 'i:images:1',
        \ 'I:inline images:1'
    \ ],
    \ 'sort' : 0
\ }

" 0:不要按照tag名排序,而是按照tag出现的顺序排序
" 1:按照tag名排序
let g:tagbar_sort = 0

" 这是为了占用更少的空间
let g:tagbar_position = 'rightbelow'
let g:tagbar_autoshowtag = 0
" 必须要加这一行，不然大文件的时候默认使用tagbar会非常卡顿
" 这是airline显示tag用的
let g:airline#extensions#tagbar#enabled = 0
" tagbar 配置 }

" markdown2ctags 插件配置 {
" Add support for markdown files in tagbar.
let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : '~/.vim/plugged/markdown2ctags/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes --sro=»',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '»',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }
" markdown2ctags 插件配置 }



" ----------------------------------------------------------------------------

" vim-gutentags {
" :TODO: 当前插件只支持ctags.exe和readtags.exe放到主目录C:\Users\xx\.vim，如果在子目录中就无法识别
" C:\Users\pc\.vim
"   ctags.exe
"   readtags.exe
"   ctags\
"       ctags.exe
"       readtags.exe
" 这两句非常重要是缺一不可的,并且配置文件的路径一定不能写错
let $GTAGSLABEL = 'native-pygments'                                              " 让非C语言使用这个生成符号表
" let g:gutentags_gtags_extra_args = ['--gtagslabel=native-pygments']

" 这里的路径注意下一定要是绝对路径
for conf in [ fnamemodify(expand('~/.vim/gtags/share/gtags/gtags.conf'), ':p'),
            \ fnamemodify($VIM . '/glob/share/gtags/gtags.conf', ':p') ]
    if filereadable(conf)
        let $GTAGSCONF = conf
        break
    endif
endfor

let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']      " gutentags 搜 索工程目录的标志，当前文件路径向上递归直到碰到这些文件/目录名
let g:gutentags_ctags_tagfile = '.tags'                                          " 所生成的数据文件的名称

let g:gutentags_modules = ['ctags', 'gtags_cscope']                              " 同时开启 ctags 和 gtags 支持

" 用leaderf设置的缓存目录,这里就不要设置了,屏蔽掉
" let g:gutentags_cache_dir = expand('~/.cache/tags')                              " 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录

" 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extra=+q，注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

let g:gutentags_plus_switch = 0                                                  " 是否自动将光标定位到自动修复列表位置 0:禁用 1:打开

" 下面这行是调试用的,当生成的tag出了问题,需要用这行来调试
let g:gutentags_define_advanced_commands = 1
" 上面的设置为1后运行下面这个打开追踪
" :GutentagsToggleTrace


" ctags 也要使用 universal ctags ，不能用老的 Exuberant-ctags 
" 查看当前使用的 python3 版本的方法
" 如果使用的是cygwin版本的python3，要注意下，这个版本的python3需要安装 pygments 模块
" 如果当前使用的python3版本不对，要调整下包含python3可执行文件的位置，放到Path变量的最前面
" 在命令中输入 :echo system('python3 --version')

" vim-gutentags }

" gutentags_plus 插件配置 {

" 打开新的窗口，并且光标在跳转栏
let g:gutentags_plus_nomap = 1
nnoremap <silent> <leader>gws :belowright split \| GscopeFind s <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 查找符号
nnoremap <silent> <leader>gwg :belowright split \| GscopeFind g <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 查找符号定义
nnoremap <silent> <leader>gwc :belowright split \| GscopeFind c <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 调用这个函数的函数
nnoremap <silent> <leader>gwt :belowright split \| GscopeFind t <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 查找字符串
nnoremap <silent> <leader>gwe :belowright split \| GscopeFind e <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 查找正则表达式
nnoremap <silent> <leader>gwf :belowright split \| GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>|   " tags: gutentags_plus 查找文件名
nnoremap <silent> <leader>gwi :belowright split \| GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>|   " tags: gutentags_plus 查找包含当前头文件的文件
nnoremap <silent> <leader>gwd :belowright split \| GscopeFind d <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 此函数调用的函数
nnoremap <silent> <leader>gwa :belowright split \| GscopeFind a <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 查找为此符号赋值的位置
nnoremap <silent> <leader>gwz :belowright split \| GscopeFind z <C-R><C-W><cr>:wincmd p<cr>|                " tags: gutentags_plus 在ctags的数据库中查找当前单词

nnoremap <silent> <leader>gns :GscopeFind s <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 查找符号(当前窗口)
nnoremap <silent> <leader>gng :GscopeFind g <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 查找符号定义(当前窗口)
nnoremap <silent> <leader>gnc :GscopeFind c <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 调用这个函数的函数(当前窗口)
nnoremap <silent> <leader>gnt :GscopeFind t <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 查找字符串(当前窗口)
nnoremap <silent> <leader>gne :GscopeFind e <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 查找正则表达式(当前窗口)
nnoremap <silent> <leader>gnf :GscopeFind f <C-R>=expand("<cfile>")<cr>:wincmd p<cr>|                       " tags: gutentags_plus 查找文件名(当前窗口)
nnoremap <silent> <leader>gni :GscopeFind i <C-R>=expand("<cfile>")<cr>:wincmd p<cr>|                       " tags: gutentags_plus 查找包含当前头文件的文件(当前窗口)
nnoremap <silent> <leader>gnd :GscopeFind d <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 此函数调用的函数(当前窗口)
nnoremap <silent> <leader>gna :GscopeFind a <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 查找为此符号赋值的位置(当前窗口)
nnoremap <silent> <leader>gnz :GscopeFind z <C-R><C-W><cr>:wincmd p<cr>|                                    " tags: gutentags_plus 在ctags的数据库中查找当前单词(当前窗口)

vnoremap <leader>gws y:belowright split \| GscopeFind s <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找符号
vnoremap <leader>gwg y:belowright split \| GscopeFind g <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找符号定义
vnoremap <leader>gwc y:belowright split \| GscopeFind c <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 调用这个函数的函数
vnoremap <leader>gwt y:belowright split \| GscopeFind t <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找字符串
vnoremap <leader>gwe y:belowright split \| GscopeFind e <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找正则表达式
vnoremap <leader>gwf y:belowright split \| GscopeFind f <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找文件名
vnoremap <leader>gwi y:belowright split \| GscopeFind i <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找包含当前头文件的文件
vnoremap <leader>gwd y:belowright split \| GscopeFind d <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 此函数调用的函数
vnoremap <leader>gwa y:belowright split \| GscopeFind a <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 查找为此符号赋值的位置
vnoremap <leader>gwz y:belowright split \| GscopeFind z <c-r>"<cr>:wincmd p<cr>|                            " tags: gutentags_plus 在ctags的数据库中查找当前单词

vnoremap <leader>gns y:GscopeFind s <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找符号(当前窗口)
vnoremap <leader>gng y:GscopeFind g <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找符号定义(当前窗口)
vnoremap <leader>gnc y:GscopeFind c <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 调用这个函数的函数(当前窗口)
vnoremap <leader>gnt y:GscopeFind t <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找字符串(当前窗口)
vnoremap <leader>gne y:GscopeFind e <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找正则表达式(当前窗口)
vnoremap <leader>gnf y:GscopeFind f <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找文件名(当前窗口)
vnoremap <leader>gni y:GscopeFind i <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找包含当前头文件的文件(当前窗口)
vnoremap <leader>gnd y:GscopeFind d <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 此函数调用的函数(当前窗口)
vnoremap <leader>gna y:GscopeFind a <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 查找为此符号赋值的位置(当前窗口)
vnoremap <leader>gnz y:GscopeFind z <c-r>"<cr>:wincmd p<cr>|                                                " tags: gutentags_plus 在ctags的数据库中查找当前单词(当前窗口)
" gutentags_plus 插件配置 }

" ----------------------------------------------------------------------------


" leaderf不要自动生成标签,用gentags插件生成
" unique的意思是vim是否检查映射已经存在,如果存在会报错,当前暂时不需要这个功能
" nmap <unique> <leader>fgd <Plug>LeaderfGtagsDefinition
nnoremap <leader>fgd <Plug>LeaderfGtagsDefinition|      " tags: Leaderf 跳转到定义
nnoremap <C-LeftMouse> <Plug>LeaderfGtagsDefinition|    " tags: Leaderf 跳转到定义
nnoremap <leader>fgr <Plug>LeaderfGtagsReference|       " tags: Leaderf 跳转到引用
nnoremap <S-LeftMouse> <Plug>LeaderfGtagsReference|     " tags: Leaderf 跳转到引用
nnoremap <leader>fgs <Plug>LeaderfGtagsSymbol|          " tags: Leaderf 跳转到符号
nnoremap <A-LeftMouse> <Plug>LeaderfGtagsSymbol|        " tags: Leaderf 跳转到符号
nnoremap <leader>fgg <Plug>LeaderfGtagsGrep|            " tags: Leaderf 跳转到字符串(启动搜索功能)
nnoremap <C-A-LeftMouse> <Plug>LeaderfGtagsGrep|        " tags: Leaderf 跳转到字符串(启动搜索功能)

vnoremap <leader>fgd <Plug>LeaderfGtagsDefinition|      " tags: Leaderf 跳转到定义
vnoremap <leader>fgr <Plug>LeaderfGtagsReference|       " tags: Leaderf 跳转到引用
vnoremap <leader>fgs <Plug>LeaderfGtagsSymbol|          " tags: Leaderf 跳转到符号
vnoremap <leader>fgg <Plug>LeaderfGtagsGrep|            " tags: Leaderf 跳转到字符串(启动搜索功能)

nnoremap <leader>fgo :<C-U><C-R>=printf("Leaderf! gtags --recall %s", "")<CR><CR>|  " tags: Leaderf 重新打开最近的跳转命令
nnoremap <leader>fgn :<C-U><C-R>=printf("Leaderf gtags --next %s", "")<CR><CR>|     " tags: Leaderf 结果列表的下一个元素
nnoremap <leader>fgp :<C-U><C-R>=printf("Leaderf gtags --previous %s", "")<CR><CR>| " tags: Leaderf 结果列表的上一个元素


" ----------------------------------------------------------------------------

" =====================File: tags.vim }======================= 标签导航 ================================================

