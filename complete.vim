
" =====================File: complete.vim {======================= 补全 ========

" coc补全插件的一些配置 {
" 这行配置已经没有意义,因为coc-settings.json中已经配置了"suggest.noselect": true
" :TODO: 这里我的预期效果是要直接设置TAB，但是设置TAB无效，具体原因未知，不过这不是很重要,目前可以使用ctrl + n/p替代
inoremap <silent><expr> <S-TAB> pumvisible() ? coc#pum#next(1) : "\<TAB>"| " 补全: 补全插入

" 定义coc插件和数据的目录
let g:coc_data_home = '~/.vim/coc'
" 这个参数可能并没有作用
" let g:python3_host_prog = "D:\\python\\python.exe"

" 跳到下一个诊断
nmap ]g <Plug>(coc-diagnostic-next)
" 跳到上一个诊断
nmap [g <Plug>(coc-diagnostic-prev)

" coc补全插件的一些配置 }

" -----------------------------------------------------------------------------

" 设置多个omni函数的范例
function! CompleteOmniPython(findstart, base)
    let l:res1 = python3complete#Complete(a:findstart, a:base)
    " 目前这个gtagsomnicomplete相当若,作用不是很大
    let l:res2 = gtagsomnicomplete#Complete(a:findstart, a:base)
    let l:res3 = CompleteOmniCustom(a:findstart, a:base)

    " 打印两个函数的返回结果
    " echom 'python3complete#Complete returns: ' . string(l:res1)
    " echom ' gtagsomnicomplete#Complete returns: ' . string(l:res2)
    " 3是列表 0是数字

    if ((type(l:res1) == 3 && empty(l:res1)) || type(l:res1) == 0) && (type(l:res2) == 3 && !empty(l:res2))
        return l:res2+l:res3
    elseif ((type(l:res2) == 3 && empty(l:res2)) || type(l:res2) == 0) && (type(l:res1) == 3 && !empty(l:res1))
        return l:res1+l:res3
    elseif ((type(l:res2) == 3 && empty(l:res2)) || type(l:res2) == 0) && ((type(l:res1) == 3 && empty(l:res1)) || type(l:res1) == 0)
        return l:res3
    else
        return l:res1 + l:res2 + l:res3
    endif
endfunction

" -----------------------------------------------------------------------------

function! CompleteOmniShell(findstart, base)
    " 目前这个gtagsomnicomplete相当若,作用不是很大
    let l:res2 = gtagsomnicomplete#Complete(a:findstart, a:base)
    let l:res3 = CompleteOmniCustom(a:findstart, a:base)

    if (type(l:res2) == 3 && empty(l:res2)) || type(l:res2) == 0
        return l:res3
    else
        return l:res2 + l:res3
    endif
endfunction

autocmd filetype python setlocal omnifunc=CompleteOmniPython
autocmd filetype sh setlocal omnifunc=CompleteOmniShell

" -----------设置--------------------------------------------------------------


set completeopt-=preview              " 关闭vim默认补全弹出预览窗口(主要是和自定义补全不冲突)


" -----------------------------------------------------------------------------

" 设置html的自动补全(使用vim内置的补全插件)ctrl-x-o触发
" 位于autoload目录下(这个目录下可能还有不少好东西)
autocmd filetype html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd filetype css setlocal omnifunc=csscomplete#CompleteCSS
autocmd filetype javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd filetype xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd filetype zim setlocal omnifunc=CompleteOmniCustom
autocmd filetype asciidoc setlocal omnifunc=CompleteOmniCustom
" gtagsomnicomplete {
" https://github.com/ragcatshxu/gtagsomnicomplete 原始的位置,我修改了下，当前使用的是我修改后的
autocmd filetype c,perl set omnifunc=gtagsomnicomplete#Complete
" gtagsomnicomplete }

" -----------------------------------------------------------------------------

" completor 插件配置 {
" pygments_parser.
" 关闭自动预览窗口(不知道是否会有什么负作用,但是可以解决强制打开预览窗口的问题)
" 就算是关闭这个选项也没用(涂鸦预览窗口还是会弹出)
let g:completor_auto_preview = 0
" set pythonthreedll=D:\python\python38.dll
let g:completor_auto_close_doc = 0
" let g:completor_clang_binary = 'D:\programs\LLVM\bin\clang.exe'
" 和javacomplete2配合起来使用,让javacomplete2的补全结果出现在我们的默认补全列表中
" .号或者::后面自动补全,或者输入任意的字符自动补全
" 这个不设置也能触发,但是可能优先级不够高
let g:completor_java_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
" let g:completor_zim_omni_trigger = '([\w-]+|@[\w-]*|[\w-]+:\s*[\w-]*)$'
let g:completor_zim_omni_trigger = '(\S+)$'
let g:completor_html_omni_trigger = '(\.|::)?\w*'
let g:completor_css_omni_trigger = '(\.|::)?\w*'
let g:completor_markdown_omni_trigger = '(\.|::)?\w*'
let g:completor_javascript_omni_trigger = '(\.|::)?\w*'
let g:completor_python_omni_trigger = '(\S+)$'
let g:completor_xml_omni_trigger = '(\.|::)?\w*'
" let g:completor_bash_omni_trigger = '(\.|::)?\w*'
" 还是单词优先好,需要补全函数手动触发即可
let g:completor_sh_omni_trigger = '(\S+)$'
" 一般情况下completor插件会自动检测java_completor插件的东西的位置,如果检测成功,那么功能自动就是正常的,否则需要手动指定他们
" let g:completor_python_binary = '/path/to/python/with/jedi/installed'
" 可以关闭preview,这样不和自定义的补全的弹出窗口重复
" :TODO: 这里可以根据文件类型不同打开不同的参数
" let g:completor_complete_options = 'menuone,noselect,preview'
let g:completor_complete_options = 'menuone,noselect'


" completor.vim 补全插件配置 }

" -----------------------------------------------------------------------------

" vim_completor {

" 如果使用的是虚拟环境这里要配置虚拟环境的地址,补全这里还有一个问题,如果文件名不规范,有@等特殊字符,无法补全
" let g:completor_python_binary = 'D:/code/tu_refactor_learn/TU_Refactory/.venv/Scripts/python.exe'
if executable('python3')
    let g:completor_python_binary = 'python3'
elseif executable('python')
    let g:completor_python_binary = 'python'
elseif filereadable('D:/python/python.exe')
    let g:completor_python_binary = 'D:/python/python.exe'
elseif filereadable('C:/Users/pc/AppData/Local/Programs/Python/Python314/python.exe')
    let g:completor_python_binary = 'C:/Users/pc/AppData/Local/Programs/Python/Python314/python.exe'
endif

nnoremap <silent> <leader><leader><leader>d :call completor#do('definition')<CR>| " 补全:completor 显示定义
nnoremap <silent> <leader><leader><leader>c :call completor#do('doc')<CR>| " 补全:completor 显示文档
nnoremap <silent> <leader><leader><leader>f :call completor#do('format')<CR>| " 补全:completor 格式化
nnoremap <silent> <leader><leader><leader>s :call completor#do('hover')<CR>| " 补全:completor ?
" vim_completor }

" -----------------------------------------------------------------------------

" 针对特种文件格式的自定义补全 {
" 暂时未验证是否和coc或者completor冲突
" 加载补全全局列表 g:complete_list
function! CompleteCustomList()
    source $VIM/complete_list_all.vim
    let g:word_to_complete = {}
    let g:complete_list = []
    if &filetype == 'zim' || &filetype == 'txt'
        source $VIM/complete_list_zim.vim
    elseif &filetype == 'python'
        source $VIM/complete_list_python.vim
    elseif &filetype == 'sh'
        source $VIM/complete_list_sh.vim
    endif

    if !empty(g:complete_list)
        let g:complete_list_all += g:complete_list
    endif

    let g:word_to_complete = extend(copy(g:word_to_complete_all), g:word_to_complete)

endfunction

" -----------------------------------------------------------------------------

" 这里多调用一次是因为如果重新加载vimrc,希望能生效
call CompleteCustomList()
autocmd filetype * call CompleteCustomList()

function! CompleteOmniCustom(findstart, base)
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        " 检查是否是一个字母,如果是字母开始补全(\a只能匹配ascii \S可以匹配中文字符)
        while start > 0 && line[start - 1] =~ '\S'
            let start -= 1
        endwhile
        return start
    else
        " find matches for a:base
        let res = []
        " h complete-functions
        " word: 补全的单词(无法多行,但是可以自己转换)
        " abbr: 补全菜单中显示的缩写
        " menu: 补全菜单中显示的额外信息(我加个*表示这项含有info预览信息 -表示没有)
        " info: 在预览窗口中显示的详细信息(如果有信息要至少包含一个换行符)
        " kind: 补全的类型
        " icase: 如果设置为1忽略大小写(需要后面的函数处理,否则无用)
        " dup: 如果设置为1标识允许添加重复项(只要word相同就能添加)(需要后面的代码处理否则没有作用)
        " :TODO: 这个变量移动到单独的字典文件中,然后每个语言一个文件,在vimrc中source进来(不是对应文件的字典清空,节省内存,要考虑字典文件的内存使用问题)
        " 还需要看下内存xnhc
        " 用 filter 先筛出匹配项
        let matched = filter(copy(g:complete_list_all),
                    \ 'has_key(v:val, "icase") && v:val.icase ? v:val.word =~ "\\c" . a:base : v:val.word =~ "\\C" . a:base')

        for item in matched
            " 匹配不区分大小写
            " 据说matchstr效率更高?
            " if matchstr(item['word'], pattern) != ''
            let item_copy = copy(item)

            if has_key(g:word_to_complete, item_copy['word'])
                let item_copy['word'] = g:word_to_complete[item_copy['word']]
            endif

            if item_copy['kind'] == 'ic' || item_copy['kind'] == 'if'
                let item_copy['word'] = eval(item_copy['word'])
            endif
            " add more information to the completion menu
            call add(res, item_copy)
        endfor
        return res
    endif
endfunction

" -----------------------------------------------------------------------------

" 设置默认的用户自定义补全函数
" c-x c-u(并不是 c-x c-o)
set completefunc=CompleteOmniCustom

" -----------------------------------------------------------------------------

" 在补全时显示弹出窗口
" :TODO: 补全的弹出窗口如果在别的文字上面显示会出现闪烁现象,需要定位下
function! CompleteShowPopup(item)
    " 如果已经存在弹出窗口，先关闭它,这里之所以要用双引号是因为这里要检查的是以双引号引起来的字符串的名字作为变量名的变量是否存在,所以这里单引号也是可以的
    if exists("s:winid")
        call popup_close(s:winid)
    endif

    if(!empty(v:completed_item) && !empty(a:item['info']))
        " :help popup_create()
        let popup_width_str = a:item['abbr'] . ' ' . a:item['kind'] . ' ' . a:item['menu']
        let word_len = strchars(a:item['word']) + strchars(substitute(a:item['word'], '[^\u4E00-\u9FCC]', '', 'g'))
        let list_len = strchars(popup_width_str) + strchars(substitute(popup_width_str, '[^\u4E00-\u9FCC]', '', 'g'))
        let width = list_len - word_len

        let opts = { 'line': 'cursor+1',
                    \'col': (width<0)?'cursor' . width:'cursor' . '+' . width,
                    \ 'padding': [0,1,0,1],
                    \ 'wrap': v:true,
                    \ 'border': [],
                    \ 'close': 'click',
                    \ 'highlight': 'Pmenu',
                    \ 'zindex': 100}
        let s:winid = popup_create(split(a:item['info'], '\n'), opts)
    endif
endfunction

" -----------------------------------------------------------------------------

" 当补全项改变时，显示弹出窗口
autocmd CompleteChanged * call CompleteShowPopup(v:completed_item)
" 当退出插入模式时，关闭弹出窗口
" :TODO: 这里甚至可以执行特定的回调，回调的位置可以想办法指定
autocmd InsertLeave * if exists("s:winid") | call popup_close(s:winid) | endif
" 当补全完成时，关闭弹出窗口
autocmd CompleteDone * if exists("s:winid") | call popup_close(s:winid) | endif
autocmd CompleteDone * .s/\%x00/\r/ge

" :TODO: 后面可以支持跨字母匹配,比如 wind  输入wd,匹配它
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------

" =====================File: complete.vim }======================= 补全 ========

