
" =====================File: files.vim {======================= 文件管理 ===============================================

" ----------------------------------------------------------------------------

function! FilesCloseHiddenBuffers()
    let open_buffers = []

    for i in range(tabpagenr('$'))
        call extend(open_buffers, tabpagebuflist(i + 1))
    endfor

    for num in range(1, bufnr("$") + 1)
        if buflisted(num) && index(open_buffers, num) == -1 && getbufvar(num, "&buftype") !=#'terminal'
            " 这里使用bdelete命令比较安全,如果后面想换成bw命令也是可以的
            exec "bdelete ".num
        endif
    endfor
endfunction

" ----------------------------------------------------------------------------

function FilesDisplayHTML()
    if &filetype == 'html'
        execute 'w'
        silent execute '!chrome' expand('%:p')
    endif
endfunction

" ----------------------------------------------------------------------------

" :TODO: 下面这个通过emacs打开后继承的环境变量有点问题,导致ggtags相关的路径错乱,可能是因为两个程序都定义了gtags相关的东西
function! FilesOpenInEmacs()
    let l:line_number = line(".")
    let l:file_path = expand("%:p")
    let l:command = "start emacsclientw +" . l:line_number . " " . l:file_path
    call system(l:command)
endfunction

" ----------------------------------------------------------------------------

" 切换到 html 模板的目录中运行 python -m http.server
" 或者指定目录运行也可以 python -m http.server --directory /path/to/html
" python -m http.server 8000 --bind 127.0.0.1
" 强制使用 ipv4
" http://127.0.0.1:8000/asciidoc_preview.html?file=demo.adoc
" 
function! FilesPreviewAsciiDoc()
    let l:filename = expand('%:t')
    let l:url = 'http://localhost:8000/asciidoc_preview.html?file=' . l:filename
    " 前提是浏览器的路径要在环境变量中
    call job_start(['chrome', l:url])
    " call job_start(['msedge', l:url])
endfunction

" ----------------------------------------------------------------------------

" ================================
"  Open the selected path（edit/split/vsplit/tab）
" ================================
function! FilesOpenSelectedPath(cmd)
    let path = CommonGetVisualSelection()
    let path = trim(path)

    if empty(path)
        echo "No path selected"
        return
    endif

    " If not an absolute path, based on the directory of the current buffer
    if !CommonIsAbsolutePath(path)
        let path = CommonGetCurrentPath() . '/' . path
    endif

    " Normalize paths using fnamemodify (cross-platform)
    let path = fnamemodify(path, ':p')

    if filereadable(path) || isdirectory(path)
        execute a:cmd . ' ' . fnameescape(path)
    else
        echo "Not a file or directory: " . path
    endif
endfunction

" ----------------------------------------------------------------------------

" NERDTree {
" NERDTree的修改文件的界面使用更小的界面显示
let NERDTreeMinimalMenu = 1
let NERDTreeShowHidden = 1
let NERDTreeAutoDeleteBuffer = 1

" 让NERDTree在右边打开
let NERDTreeWinPos="right"

" NERDTree }

" nerdtree-git-plugin 插件 {
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'*',
                \ 'Staged'    :'+',
                \ 'Untracked' :'o',
                \ 'Renamed'   :'^',
                \ 'Unmerged'  :'=',
                \ 'Deleted'   :'X',
                \ 'Dirty'     :'x',
                \ 'Ignored'   :'.',
                \ 'Clean'     :'v',
                \ 'Unknown'   :'?',
                \ }

" nerdtree-git-plugin 插件 }

" ----------------------------------------------------------------------------

au BufEnter * call FilesCloseHiddenBuffers()     " 自动删除隐藏的 buffer


" ----------------------------------------------------------------------------



nnoremap <silent> <leader>new :new<cr>|                                 " files: 创建一个新文件
nnoremap <silent> <leader>enew :enew<cr>|                               " files: 创建一个新文件并编辑
nnoremap <leader><F9> :call FilesDisplayHTML()<CR>|                     " files: 浏览器中打开当前编辑的html文件
nnoremap <leader>oe :call FilesOpenInEmacs()<CR>|                       " files: 使用emacs打开当前文件当前行
nnoremap <leader><leader>p :call FilesPreviewAsciiDoc()<CR>             " files: AsciiDoc 文件浏览器预览
xnoremap <leader>e :<C-u>call FilesOpenSelectedPath('edit')<CR>         " files: 打开选择的文件(当前 buffer)
xnoremap <leader>t :<C-u>call FilesOpenSelectedPath('tabedit')<CR>      " files: 打开选择的文件(tab 打开)
xnoremap <leader>s :<C-u>call FilesOpenSelectedPath('split')<CR>        " files: 打开选择的文件(纵向拆分)
xnoremap <leader>v :<C-u>call FilesOpenSelectedPath('vsplit')<CR>       " files: 打开选择的文件(横向拆分)
"
" nnoremap <silent> <leader>exp :silent !explorer %:p:h<CR><CR>|        " files: 外部文件浏览器中打开当前文件所在目录
" 用下面的方式避免黑框弹出
nnoremap <silent> <leader>exp :silent !start explorer %:p:h<CR><CR>|    " files: 外部文件浏览器中打开当前文件所在目录

" NERDTree

nnoremap <leader>rt :NERDTreeFocus<cr>:NERDTreeRefreshRoot<cr><c-w>p|   " files: 刷新目录树状态
nnoremap <leader>rf :NERDTreeFind<cr>:NERDTreeRefreshRoot<cr><c-w>p|    " files: 进入当前文件对应的目录树并且刷新目录树状态


" =====================File: files.vim {======================= 文件管理 ===============================================

