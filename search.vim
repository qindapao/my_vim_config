
" =====================File: search.vim {======================= 搜索和替换 ============================================

" 设置grep默认显示行号
set grepprg=grep\ -n



" ----------------------------------------------------------------------------

" 替换函数
function! SearchReplaceWord(now_mode)
    if a:now_mode == 'n'
        let old_word = expand("<cword>")
    elseif a:now_mode == 'v'
        let old_word = CommonGetVisualLine()
    endif
    let new_word = input("Replace " . old_word . " with: ")
    execute '%s/' . old_word . '/' . new_word . '/gc | update'
endfunction

" ----------------------------------------------------------------------------

" range 标识的函数才能在可视选择范围内执行
function! SearchVisualReplaceWord() range
    let old_word = escape(getreg('"'), '/\&')
    " 设置默认值并且有机会可以修改默认pattern
    let old_word = input("old_patter: ", old_word)
    let new_word = input("Replace " . old_word . " with: ")
    execute "'<,'>s/" . old_word . "/" . new_word . "/gc | update"
endfunction

" ----------------------------------------------------------------------------

function! SearchFindAndReplaceInFiles()
    let winid = CommonShowPopup(g:regexPatterns)
    " 这里的redraw至关重要
    redraw
    let file_pattern = input('Enter the file pattern(Rooter 进入项目根; **/* 目录递归; * 当前目录; % 当前文件): ')
    execute 'args ' . file_pattern
    let search_pattern = input('Enter the search pattern(\c 忽略大小写; \<\> 全词匹配): ')
    let replace_pattern = input('Enter the replace pattern: ')
    execute 'argdo %s/' . search_pattern . '/' . replace_pattern . '/gc | update'
    call popup_close(winid)
endfunction

" ------------LeaderF 配置 {

let g:Lf_GtagsAutoGenerate = 0
let g:Lf_GtagsGutentags = 1

let g:Lf_CacheDirectory = expand('~')
let g:gutentags_cache_dir = expand(g:Lf_CacheDirectory.'/LeaderF/gtags')         " vim-gentags和leaderf共享的配置,只能这样配



" 索引方式
let g:Lf_UseVersionControlTool=1                                                 " 这个是默认选项, 可以不写, 按照版本控制工具来索引
let g:Lf_DefaultExternalTool='rg'                                                " 如果不是一个repo, 那么使用rg工具来索引
" 下面的两个cache都不要使用,否则结果可能不准确或者不实时显示
let g:Lf_UseCache = 0                                                            " 不要使用缓存,这样结果是最准确的
let g:Lf_UseMemoryCache = 0                                                      " 也不要使用内存的缓存,保证每次结果都是准确的

let g:Lf_ShortcutB = '<c-l>'                                                     " 打开buffer搜 索窗口
let g:Lf_ShortcutF = '<c-p>'                                                     " 打开leaderf窗口

" 为不同的项目配置不同的忽略配置
" autocmd BufNewFile,BufRead X:/yourdir* let g:Lf_WildIgnore={'file':['*.vcproj', '*.vcxproj'],'dir':[]}

" popup menu的显示效果非常差,就暂时不用它了
" let g:Lf_WindowPosition = 'popup'                                              " 配置leaderf的弹出窗口类型为popup
" 根目录配置
let g:Lf_WorkingDirectoryMode = 'AF'                                             " 配置leaderf的工作目录模式
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', '.project', '.root']              " 根目录标识
let g:Lf_MruFileExclude = ['*.tmp', '*.swp']
let g:Lf_MruMaxFiles = 2000

" let g:Lf_ShowRelativePath = 1


" 字符串检索相关配置 可以手动补充的词 (-i 忽略大小写. -e <PATTERN> 正则表达式搜 索. -F 搜 索字符串而不是正则表达式. -w 搜 索只匹配有边界的词.)
nnoremap <leader>frm <Plug>LeaderfRgPrompt --stayOpen|                  " search: Leaderf Leaderf rg -e,然后等待输入正则表达式
nnoremap <leader>frb <Plug>LeaderfRgCwordLiteralNoBoundary --stayOpen|  " search: Leaderf 查询光标或者可视模式下所在的词,非全词匹配
nnoremap <leader>frw <Plug>LeaderfRgCwordLiteralBoundary --stayOpen|    " search: Leaderf 查询光标或者可视模式下所在的词,全词匹配
nnoremap <leader>fren <Plug>LeaderfRgCwordRegexNoBoundary --stayOpen|   " search: Leaderf 查询光标或者可视模式下所在的正则表达式，非全词匹配
nnoremap <leader>frew <Plug>LeaderfRgCwordRegexBoundary --stayOpen|     " search: Leaderf 查询光标或者可视模式下所在的正则表达式，全词匹配
vnoremap <leader>frb <Plug>LeaderfRgVisualLiteralNoBoundary --stayOpen| " search: Leaderf 查询光标或者可视模式下所在的词,非全词匹配
vnoremap <leader>frw <Plug>LeaderfRgVisualLiteralBoundary --stayOpen|   " search: Leaderf 查询光标或者可视模式下所在的词,全词匹配
vnoremap <leader>fren <Plug>LeaderfRgVisualRegexNoBoundary --stayOpen|  " search: Leaderf 查询光标或者可视模式下所在的正则表达式，非全词匹配
vnoremap <leader>frew <Plug>LeaderfRgVisualRegexBoundary --stayOpen|    " search: Leaderf 查询光标或者可视模式下所在的正则表达式，全词匹配

nnoremap <leader>frr :LeaderfRgRecall<cr>|                              " search: Leaderf 搜索重新打开上一次的rg搜索

nnoremap ]n :Leaderf rg --next<CR>|                                     " search: Leaderf 跳转到字符串搜索列表的下一个结果
nnoremap ]p :Leaderf rg --previous<CR>|                                 " search: Leaderf 跳转到字符串搜索列表的上一个结果

nnoremap <leader>f1 :LeaderfSelf<cr>|                                   " search: Leaderf 搜索leaderf自己
nnoremap <leader>fm :LeaderfMru<cr>|                                    " search: Leaderf 搜索leaderf最近打开文件列表
nnoremap <leader>ff :LeaderfFunction<cr>|                               " search: Leaderf 搜索函数
nnoremap <leader>fb :LeaderfBuffer<cr>|                                 " search: Leaderf 搜索buffer
nnoremap <leader>ft :LeaderfBufTag<cr>|                                 " search: Leaderf 搜索标签文件
nnoremap <leader>fll :LeaderfLine<cr>|                                  " search: Leaderf 搜索当前文件的所有行
nnoremap <leader>fw :LeaderfWindow<cr>|                                 " search: Leaderf 搜索打开的窗口

" search visually selected text literally, don't quit LeaderF after accepting an entry
" 这里要注意下不能l键映射到最前面，不然会导致可视模式下自动往后多选择一个字符, --context 5 显示上下文5行, r替换
xnoremap gfl :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen --context 5 -e %s ", leaderf#Rg#visual())<CR>
                                                                        " search: Leaderf 不开启二次过滤的保留搜索列表(跳转后)
xnoremap gnfl :<C-U><C-R>=printf("Leaderf rg -F --stayOpen --context 5 -e %s ", leaderf#Rg#visual())<CR>
                                                                        " search: Leaderf 开启二次过滤的保留搜索列表(跳转后)
nnoremap <leader><C-P> :Leaderf file --stayOpen<CR>|                    " search: Leaderf 文件搜索但是保持搜索窗口不关闭
nnoremap <leader>flk :Leaderf line --stayOpen<CR>|                      " search: Leaderf 搜索文件行但是保持搜索窗口不关闭


" 关闭leaderf的预览窗口,不然会影响-stayOpen模式,预览窗口无法关闭,也无法编辑新的文件
" 当前好像这个功能又可以用了(太卡了，还是把它禁用)
let g:Lf_PreviewInPopup = 0


" ------------LeaderF 配置 }


" ----- ctrlsf 插件配置 ------------------------------------------------------

" ctrlsf 插件配置 {


" 有个小tips: 我们在搜 索结果页中我们可以使用zM折叠所有的搜 索结果(类似于vscode的效果)
" :TODO: 目前发现全词匹配-W不能和-I一起使用
" 获取光标下的单词(这里命令在第二个命令,所以不能用<cword>)

nnoremap <leader>cfto :CtrlSFToggle<cr>|                                    " search: ctrlsf:切换搜索窗口的打开和关闭
nnoremap <leader>cfip :Rooter<cr> :CtrlSF -I <C-r><C-w><cr>|                " search: ctrlsf:项目级 不敏感,非全词
nnoremap <leader>cfsp :Rooter<cr> :CtrlSF -S <C-r><C-w><cr>|                " search: ctrlsf:项目级 敏感,非全词
" 目前发现敏感和全词必须配套使用,否则全词功能失效?
nnoremap <leader>cfwp :Rooter<cr> :CtrlSF -S -W <C-r><C-w><cr>|             " search: ctrlsf:项目级 敏感,全词

nnoremap <leader>cfic :CtrlSF -I <C-r><C-w><cr>|                            " search: ctrlsf:当前目录递归 不敏感,非全词
nnoremap <leader>cfsc :CtrlSF -S <C-r><C-w><cr>|                            " search: ctrlsf:当前目录递归 敏感,非全词
nnoremap <leader>cfwc :CtrlSF -S -W <C-r><C-w><cr>|                         " search: ctrlsf:当前目录递归 敏感,全词

nnoremap <leader>cfid :CtrlSF -I <C-r><C-w> ./<cr>|                         " search: ctrlsf:仅限当前目录 不敏感,非全词
nnoremap <leader>cfsd :CtrlSF -S <C-r><C-w> ./<cr>|                         " search: ctrlsf:仅限当前目录 敏感,非全词
nnoremap <leader>cfwd :CtrlSF -S -W <C-r><C-w> ./<cr>|                      " search: ctrlsf:仅限当前目录 敏感,全词

nnoremap <leader>cfif :CtrlSF -I <C-r><C-w> %<cr>|                          " search: ctrlsf:当前文件 不敏感,非全词
nnoremap <leader>cfsf :CtrlSF -S <C-r><C-w> %<cr>|                          " search: ctrlsf:当前文件 敏感,非全词
nnoremap <leader>cfwf :CtrlSF -S -W <C-r><C-w> %<cr>|                       " search: ctrlsf:当前文件 敏感,全词

nnoremap <leader>cfmip :Rooter<cr> :CtrlSF -I |                             " search: ctrlsf:项目级 手动搜索,大小写不敏感
nnoremap <leader>cfmic :CtrlSF -I |                                         " search: ctrlsf:当前目录递归 手动搜索,大小写不敏感
nnoremap <leader>cfmid :CtrlSF -I  ./|                                      " search: ctrlsf:仅限当前目录 手动搜索,大小写不敏感
nnoremap <leader>cfmif :CtrlSF -I  %|                                       " search: ctrlsf:当前文件 手动搜索,大小写不敏感

nnoremap <leader>cfmsp :Rooter<cr> :CtrlSF -S |                             " search: ctrlsf:项目级 手动搜索,大小写敏感
nnoremap <leader>cfmsc :CtrlSF -S |                                         " search: ctrlsf:当前目录递归 手动搜索,大小写敏感
nnoremap <leader>cfmsd :CtrlSF -S  ./|                                      " search: ctrlsf:仅限当前目录 手动搜索,大小写敏感
nnoremap <leader>cfmsf :CtrlSF -S  %|                                       " search: ctrlsf:当前文件 手动搜索,大小写敏感

vnoremap <leader>cfip y:Rooter<cr> :CtrlSF -I <C-r>"<cr>|                   " search: ctrlsf:项目级 不敏感,非全词
vnoremap <leader>cfsp y:Rooter<cr> :CtrlSF -S <C-r>"<cr>|                   " search: ctrlsf:项目级 敏感,非全词
vnoremap <leader>cfwp y:Rooter<cr> :CtrlSF -S -W <C-r>"<cr>|                " search: ctrlsf:项目级 敏感,全词

vnoremap <leader>cfic y:CtrlSF -I <C-r>"<cr>|                               " search: ctrlsf:当前目录递归 不敏感,非全词
vnoremap <leader>cfsc y:CtrlSF -S <C-r>"<cr>|                               " search: ctrlsf:当前目录递归 敏感,非全词
vnoremap <leader>cfwc y:CtrlSF -S -W <C-r>"<cr>|                            " search: ctrlsf:当前目录递归 敏感,全词

vnoremap <leader>cfid y:CtrlSF -I <C-r>" ./<cr>|                            " search: ctrlsf:仅限当前目录 不敏感,非全词
vnoremap <leader>cfsd y:CtrlSF -S <C-r>" ./<cr>|                            " search: ctrlsf:仅限当前目录 敏感,非全词
vnoremap <leader>cfwd y:CtrlSF -S -W <C-r>" ./<cr>|                         " search: ctrlsf:仅限当前目录 敏感,全词

vnoremap <leader>cfif y:CtrlSF -I <C-r>" %<cr>|                             " search: ctrlsf:当前文件 不敏感,非全词
vnoremap <leader>cfsf y:CtrlSF -S <C-r>" %<cr>|                             " search: ctrlsf:当前文件 敏感,非全词
vnoremap <leader>cfwf y:CtrlSF -S -W <C-r>" %<cr>|                          " search: ctrlsf:当前文件 敏感,全词

" 设置vimgrep的全局排除规则
set wildignore=.git/**,tags,GPATH,GRTAGS,GTAGS
nnoremap <leader>vgip :Rooter<cr> :vimgrep /\c<C-r><C-w>/gj **/*<cr>|       " search: vimgrep:项目级 不敏感,非全词
nnoremap <leader>vgsp :Rooter<cr> :vimgrep /<C-r><C-w>/gj **/*<cr>|         " search: vimgrep:项目级 敏感,非全词
nnoremap <leader>vgwp :Rooter<cr> :vimgrep /\<<C-r><C-w>\>/gj **/*<cr>|     " search: vimgrep:项目级 敏感,全词
nnoremap <leader>vgiwp :Rooter<cr> :vimgrep /\c\<<C-r><C-w>\>/gj **/*<cr>|  "search: vimgrep:项目级 不敏感,全词

nnoremap <leader>vgic :vimgrep /\c<C-r><C-w>/gj **/*<cr>|                   " search: vimgrep:当前目录递归 不敏感,非全词
nnoremap <leader>vgsc :vimgrep /<C-r><C-w>/gj **/*<cr>|                     " search: vimgrep:当前目录递归 敏感,非全词
nnoremap <leader>vgwc :vimgrep /\<<C-r><C-w>\>/gj **/*<cr>|                 " search: vimgrep:当前目录递归 敏感,全词
nnoremap <leader>vgiwc :vimgrep /\c\<<C-r><C-w>\>/gj **/*<cr>|              " search: vimgrep:当前目录递归 不敏感,全词

nnoremap <leader>vgid :vimgrep /\c<C-r><C-w>/gj *<cr>|                      " search: vimgrep:仅限当前目录 不敏感,非全词
nnoremap <leader>vgsd :vimgrep /<C-r><C-w>/gj *<cr>|                        " search: vimgrep:仅限当前目录 敏感,非全词
nnoremap <leader>vgwd :vimgrep /\<<C-r><C-w>\>/gj *<cr>|                    " search: vimgrep:仅限当前目录 敏感,全词
nnoremap <leader>vgiwd :vimgrep /\c\<<C-r><C-w>\>/gj *<cr>|                 " search: vimgrep:仅限当前目录 不敏感,全词

nnoremap <leader>vgif :vimgrep /\c<C-r><C-w>/gj %<cr>|                      " search: vimgrep:当前文件 不敏感,非全词
nnoremap <leader>vgsf :vimgrep /<C-r><C-w>/gj %<cr>|                        " search: vimgrep:当前文件 敏感,非全词
nnoremap <leader>vgwf :vimgrep /\<<C-r><C-w>\>/gj %<cr>|                    " search: vimgrep:当前文件 敏感,全词
nnoremap <leader>vgiwf :vimgrep /\c\<<C-r><C-w>\>/gj %<cr>|                 " search: vimgrep:当前文件 不敏感,全词

nnoremap <leader>vgmp :Rooter<cr> :vimgrep //gj **/*|                       " search: vimgrep:项目级 手动搜索
nnoremap <leader>vgmc :vimgrep //gj **/*|                                   " search: vimgrep:当前目录递归 手动搜索
nnoremap <leader>vgmd :vimgrep //gj *|                                      " search: vimgrep:仅限当前目录 手动搜索
nnoremap <leader>vgmf :vimgrep //gj %|                                      " search: vimgrep:当前文件 手动搜索

vnoremap <leader>vgip y:Rooter<cr> :vimgrep /\c<C-r>"/gj **/*<cr>|          " search: vimgrep:项目级 不敏感,非全词
vnoremap <leader>vgsp y:Rooter<cr> :vimgrep /<C-r>"/gj **/*<cr>|            " search: vimgrep:项目级 敏感,非全词
vnoremap <leader>vgwp y:Rooter<cr> :vimgrep /\<<C-r>"\>/gj **/*<cr>|        " search: vimgrep:项目级 敏感,全词
vnoremap <leader>vgiwp y:Rooter<cr> :vimgrep /\c\<<C-r>"\>/gj **/*<cr>|     " search: vimgrep:项目级 不敏感,全词

vnoremap <leader>vgic y:vimgrep /\c<C-r>"/gj **/*<cr>|                      " search: vimgrep:当前目录递归 不敏感,非全词
vnoremap <leader>vgsc y:vimgrep /<C-r>"/gj **/*<cr>|                        " search: vimgrep:当前目录递归 敏感,非全词
vnoremap <leader>vgwc y:vimgrep /\<<C-r>"\>/gj **/*<cr>|                    " search: vimgrep:当前目录递归 敏感,全词
vnoremap <leader>vgiwc y:vimgrep /\c\<<C-r>"\>/gj **/*<cr>|                 " search: vimgrep:当前目录递归 不敏感,全词

vnoremap <leader>vgid y:vimgrep /\c<C-r>"/gj *<cr>|                         " search: vimgrep:仅限当前目录 不敏感,非全词
vnoremap <leader>vgsd y:vimgrep /<C-r>"/gj *<cr>|                           " search: vimgrep:仅限当前目录 敏感,非全词
vnoremap <leader>vgwd y:vimgrep /\<<C-r>"\>/gj *<cr>|                       " search: vimgrep:仅限当前目录 敏感,全词
vnoremap <leader>vgiwd y:vimgrep /\c\<<C-r>"\>/gj *<cr>|                    " search: vimgrep:仅限当前目录 不敏感,全词

vnoremap <leader>vgif y:vimgrep /\c<C-r>"/gj %<cr>|                         " search: vimgrep:当前文件 不敏感,非全词
vnoremap <leader>vgsf y:vimgrep /<C-r>"/gj %<cr>|                           " search: vimgrep:当前文件 敏感,非全词
vnoremap <leader>vgwf y:vimgrep /\<<C-r>"\>/gj %<cr>|                       " search: vimgrep:当前文件 敏感,全词
vnoremap <leader>vgiwf y:vimgrep /\c\<<C-r>"\>/gj %<cr>|                    " search: vimgrep:当前文件 不敏感,全词

let g:regexPatterns = [
\ '^：匹配行的开始。',
\ '$：匹配行的结束。',
\ '[]：匹配括号内的任何字符。',
\ '.：匹配任何单个字符（除了换行符）。',
\ '*：匹配前面的元素零次或多次。',
\ '+：匹配前面的元素一次或多次。',
\ '?：匹配前面的元素零次或一次。',
\ '\s：匹配任何空白字符，包括空格、制表符、换页符等。',
\ '\S：匹配任何非空白字符。',
\ '\d：匹配任何数字。',
\ '\D：匹配任何非数字字符。',
\ '\w：匹配任何字母、数字或下划线字符。',
\ '\W：匹配任何非字母、非数字和非下划线字符。',
\ '{n,m}：匹配前面的元素至少 n 次，但不超过 m 次。',
\ '{n,}：匹配前面的元素 n 次或更多次。',
\ '{,m}：匹配前面的元素不超过 m 次。',
\ '{n}：匹配前面的元素恰好 n 次。',
\ '|：表示或（or），匹配前面或后面的表达式。',
\ '( )：用于分组，匹配括号中的表达式。'
\ ]

" :TODO: 目前列表里面无法加注释只能放到外面来单独注释
" ^：匹配行的开始。                                    " 辅助:regexPatterns
" $：匹配行的结束。                                    " 辅助:regexPatterns
" []：匹配括号内的任何字符。                           " 辅助:regexPatterns
" .：匹配任何单个字符（除了换行符）。                  " 辅助:regexPatterns
" *：匹配前面的元素零次或多次。                        " 辅助:regexPatterns
" +：匹配前面的元素一次或多次。                        " 辅助:regexPatterns
" ?：匹配前面的元素零次或一次。                        " 辅助:regexPatterns
" \s：匹配任何空白字符，包括空格、制表符、换页符等。   " 辅助:regexPatterns
" \S：匹配任何非空白字符。                             " 辅助:regexPatterns
" \d：匹配任何数字。                                   " 辅助:regexPatterns
" \D：匹配任何非数字字符。                             " 辅助:regexPatterns
" \w：匹配任何字母、数字或下划线字符。                 " 辅助:regexPatterns
" \W：匹配任何非字母、非数字和非下划线字符。           " 辅助:regexPatterns
" {n,m}：匹配前面的元素至少 n 次，但不超过 m 次。      " 辅助:regexPatterns
" {n,}：匹配前面的元素 n 次或更多次。                  " 辅助:regexPatterns
" {,m}：匹配前面的元素不超过 m 次。                    " 辅助:regexPatterns
" {n}：匹配前面的元素恰好 n 次。                       " 辅助:regexPatterns
" |：表示或（or），匹配前面或后面的表达式。            " 辅助:regexPatterns
" ( )：用于分组，匹配括号中的表达式。                  " 辅助:regexPatterns




" 多文件替换相关的操作
" :args *.txt
" :argdo %s/foo/bar/gc | update

let g:ctrlsf_case_sensitive = 'yes'
let g:ctrlsf_follow_symlinks = 0
let g:ctrlsf_ignore_dir = ['docs/bak.md', '.gitignore']
let g:ctrlsf_backend = 'rg'
let g:ctrlsf_search_mode = 'async'
let g:ctrlsf_winsize = '30%'
" 默认按照字面意思搜 索
let g:ctrlsf_regex_pattern = 0
" :TODO: 直接在ctrlsf的搜索界面不要做替换,有一个风险是前面几行无法对齐,如果遇到
" 这种情况要么手动调整前面几行的对齐和下面的一致,或者是定位到真正的文本后再做替换
let g:ctrlsf_indent = 2
" normal 就是左边一列现实上下文的方式，可以用 M 切换
let g:ctrlsf_default_view_mode = 'compact'

" "openb" : 定义的是 打开当前匹配项，并在打开后跳转回 CtrlSF 面板前所在的窗口（也就是通过 suffix 来补充后续动作）。
" key     : "O"       : 你可以按大写 O 来触发这个操作。
" suffix  : "<C-w>p"  : 打开结果后，立刻切换回上一个窗口，保持 CtrlSF 面板活跃。
" \ 'openb': { 'key': 'f', 'suffix': '<C-w>p' },   " f = 打开并跳回
" 如果不想跳回，就不设置 suffix
" M 切换回紧凑模式的预览(切换回去比较卡，建议不要)
" :help ctrlsf-options
let g:ctrlsf_mapping = {
    \ "openb": { 'key': "b" },
    \ "popen": { 'key': "s" },
    \ "pquit": { 'key': "q" },
    \ "stop":  { 'key': "x" },
    \ "vsplit":  { 'key': "w" },
    \ "next": "n",
    \ "prev": "N",
    \ }
" 自动打开预览窗口
" 目前似乎这个功能无效，原因未知
let g:ctrlsf_auto_preview = 0
" 定义上下文的数量
let g:ctrlsf_context = '-B 5 -A 3'
" 根据项目文件，如 .svn .git 等等来确定项目根目录(因为我们当前有 Rooter 插件)
let g:ctrlsf_default_root = 'project'
let g:ctrlsf_extra_root_markers = ['.root', '.workspace', 'pyproject.toml']

" 结果不要默认折叠，需要的时候我们手动折叠即可
let g:ctrlsf_fold_result = 0
" 让每个窗口有独立面板
let g:ctrlsf_position = 'left_local'
let g:ctrlsf_compact_position = 'bottom_inside'
" 切换窗口的打开和关闭
nnoremap <leader>cfit :CtrlSFToggle<CR>
" ctrlsf 插件配置 }


" ----------------------------------------------------------------------------

" 打开某个目录下面的文件执行vimgrep忽略设置,这样每个项目可以独立
autocmd BufNewFile,BufRead */P5-App-Asciio* set wildignore=t/**,xt/**,*.tmp,test.c

" ----------------------------------------------------------------------------

noremap <leader>rw :call SearchReplaceWord('n')<CR>|            " search: 普通模式替换当前单词
vnoremap <leader>rw :call SearchReplaceWord('v')<CR>|           " search: 可视模式替换当前单词
" 替换函数快捷方式,和<leader>r和NERDTree刷新快捷键冲突
vnoremap <leader>rn :call SearchVisualReplaceWord()<CR>|        " search: 可视模式替换选择区域复制的单词为新单词
nnoremap <leader>vs :call SearchFindAndReplaceInFiles()<cr>|    " search: vim内置替换功能封装

" search highlight
set hlsearch| " 高亮: 设置搜索高亮
nnoremap <silent> <leader>noh :nohlsearch<CR>|                  " search: 取消搜索高亮
nnoremap <silent> # :nohlsearch<CR>|                            " search: 取消搜索高亮

" 设置星号不要自动跳转,只高亮
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
                                                                " search: 搜索并高亮当前单词
" :TODO: 这里使用了默认的寄存器，如果后续有干扰，需要保持默认寄存器干净，可能需要修改这里
xnoremap <silent> * y:let @/='\V'.escape(@", '/\')<CR>:let old_pos = getpos(".")<CR>:set hls<CR>:call setpos('.', old_pos)<CR>
                                                                " search: 可视模式搜索并高亮当前单词
" 由于环境变量的问题,下面这行暂时不使用
" command -nargs=1 Sch noautocmd vimgrep /<args>/gj `git ls-files` | cw            " 搜索git关注的文件 :Sch xx
nnoremap <leader>lv :lv /<c-r>=expand("<cword>")<cr>/%<cr>:lw<cr>
                                                                " search: 在location window(本地列表)列出搜索结果
nnoremap <leader>swa yiw/\c\<<C-R>"\>|                          " search: 当前文件当前光标下单词全词自动搜索
nnoremap <leader>swm /\c\<\><Left><Left>|                       " search: 当前文件全词手动搜索
nnoremap <leader>ra :%s/\%x00/\r/g<cr>|                         " search: 普通模式替换文本中的^@为换行
vnoremap <leader>ra :s/\%x00/\r/g<cr>|                          " search: 可视模式替换文本中的^@为换行

" =====================File: search.vim }======================= 搜索和替换 ============================================

