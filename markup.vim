
" =====================File: markup.vim {======================= 标记文档 ==============================================

" ----------------------------------------------------------------------------

" 以下函数的来源 https://github.com/youngyangyang04/PowerVim/blob/master/.vimrc
" usage :call GenMarkdownSectionNum    给markdown/zimwiki 文件生成目录编号
" 如果要在某些脚本代码中写注释,那么使用#----这种格式来过滤
function! MarkupGenSectionNum(file_type)
    if &ft != a:file_type
        echohl Error
        echo "filetype is not " . a:file_type
        echohl None
        return
    endif

    if a:file_type == 'markdown'
        let fit_patter = '^\(#\+\) \?\([0-9.]\+ \)\? *\(.*\)'
    elseif a:file_type == 'zim'
        let fit_patter = '^\(=\+\) \?\([0-9.]\+ \)\? *\(.*\)'
    else
        echohl Error
        echo "filetype is not surport."
        return
    endif

    let lvl = []
    let sect = []
    let out = ""
    for i in range(1, line('$'), 1)
        let line = getline(i)
        if a:file_type == 'markdown'
            let heading_lvl = strlen(substitute(line, '^\(#*\).*', '\1', ''))
            " 如果格式是#-那么直接跳过(短杠可能有无数个,并且后面可能还有别的字符)
            if line =~ '^#\+-\+.*'
                continue
            endif
        elseif a:file_type == 'zim'
            let heading_lvl = 7 - strlen(substitute(line, '^\(=*\).*', '\1', ''))
        endif

        if heading_lvl < 2
            if heading_lvl == 1
                " 顶级标签可能不只一个
                let lvl = []
                let sect = []
            endif
            continue
        endif
        " there should be only 1 H1, topmost, on a conventional web page
        " we should generate section numbers begin with the first heading level 2
        if len(lvl) == 0
            if heading_lvl != 2 " count from level 2
                " :TODO: 目前不知道为啥这些错误信息都会打印出来
                " echohl Error
                " echo "subsection must have parent section, ignore illegal heading line at line " . i
                " echohl None
                continue
            endif
            call add(sect, 1)
            call add(lvl, heading_lvl)
        else
            if lvl[-1] == heading_lvl
                let sect[-1] = sect[-1] + 1
            elseif lvl[-1] > heading_lvl " pop all lvl less than heading_lvl from tail
                while len(lvl) != 0 && lvl[-1] > heading_lvl
                    call remove(lvl, -1)
                    call remove(sect, -1)
                endwhile
                let sect[-1] = sect[-1] + 1
            elseif lvl[-1] < heading_lvl
                if heading_lvl - lvl[-1] != 1
                    " :TODO: 目前不知道为啥这些错误信息都会打印出来
                    " echohl Error
                    " echo "subsection must have parent section, ignore illegal heading line at line " . i
                    " echohl None
                    continue
                endif
                call add(sect, 1)
                call add(lvl, heading_lvl)
            endif
        endif

        let cur_sect = ""
        for j in sect
            let cur_sect = cur_sect . "." . j
        endfor
        let cur_sect = cur_sect[1:]
        let out = out . " " . cur_sect
        call setline(i, substitute(line, fit_patter, '\1 ' . cur_sect . ' \3', line))
    endfor
    " echo lvl sect out
    echo out
endfunc

" ----------------------------------------------------------------------------
" vimwiki 插件的配置 {
" 获取 Vim 安装目录的上一级目录
" 'qq_style.css'文件需要提前放到 workwiki_html 目录中
" 这行一定要设置，不然会把markdown的文件格式也当成vimwiki来处理，造成tagbar插件无法正常打开markdown的目录大纲
let g:vimwiki_ext2syntax = {'.wiki': 'default'}
let s:vim_parent = fnamemodify($VIM, ':h')
let g:vimwiki_list = [
      \ {'path': s:vim_parent . '/workwiki/', 'syntax': 'default', 'ext': '.wiki', 'css_name': 'qq_style.css', 'path_html': s:vim_parent . '/workwiki_html/'},
      \ {'path': s:vim_parent . '/personalwiki/', 'syntax': 'default', 'ext': '.wiki', 'css_name': 'qq_style.css'}
      \ ]
" let g:vimwiki_valid_html_tags = 'b,i,s,u,sub,sup,kbd,br,hr,p,pre,ul,ol,li,table,tr,td,th,dl,dt,dd,blockquote,div,span'
" 需要支持svg的嵌入
" 需要手动先把图片和SVG放到导出目录下来
let g:vimwiki_valid_html_tags = 'b,i,s,u,sub,sup,kbd,br,p,pre,span,object,embed,iframe,svg'

let g:vimwiki_codeblock_highlight = 1
" 不要自动切换目录，因为这可能会导致 .md 和 .wiki 的文件配合 fugitive 工作的时候不正常
" 有自动命令会切换目录
" :verbose au BufWinEnter *.wiki
" :verbose au BufWinEnter *.md
let g:vimwiki_auto_chdir = 0

function! VimwikiLinkHandler(link)
    " 网页链接 -> 浏览器
    if a:link =~? '^https\?://'
        call system('cmd /c start "" ' . shellescape(a:link))
        return 1
    endif

    " file: 或 local: -> 系统默认程序
    if a:link =~? '^\%(file\|local\):'
        let l:path = substitute(a:link, '^\%(file\|local\):', '', '')

        " 相对路径 -> 基于当前 wiki 文件目录拼绝对路径
        if l:path !~? '^\%([A-Za-z]:\|[/\\]\)'
            let l:path = fnamemodify(expand('%:p:h') . '/' . l:path, ':p')
        endif

        call system('cmd /c start "" ' . shellescape(l:path))
        return 1
    endif

    " 其余交给 Vimwiki 默认逻辑（内部链接等）
    return 0
endfunction

" vimwiki 插件的配置 }


" ----------doq的配置 {---------------------------------------------------------
" 探测 doq 的路径
if executable('doq')
    " 如果 PATH 里已经有 doq，就直接用
    let g:pydocstring_doq_path = 'doq'
elseif filereadable('D:/python/Script/doq')
    let g:pydocstring_doq_path = 'D:/python/Script/doq'
elseif filereadable('C:/Users/pc/AppData/Local/Programs/Python/Python314/Scripts/doq.exe')
    let g:pydocstring_doq_path = 'C:/Users/pc/AppData/Local/Programs/Python/Python314/Scripts/doq.exe'
endif
" ----------doq的配置 }---------------------------------------------------------

" ----------vim-markdown {------------------------------------------------------
" 这个命令可能失效,需要在vim中手动执行这个命令,编辑markdown文件的时候
let g:vim_markdown_emphasis_multiline = 0
" 设置语法收缩
let g:vim_markdown_conceal = 1
" 设置代码块提示语法收缩
let g:vim_markdown_conceal_code_blocks = 1
let g:vim_markdown_strikethrough = 1
" 设置禁用折叠,这个一定要设置,不然会造成对比的时候语法错乱
let g:vim_markdown_folding_disabled = 1
" ----------vim-markdown }------------------------------------------------------

" ----------img-paste {---------------------------------------------------------
autocmd filetype zim,txt let g:mdip_imgdir = expand('%:t:r')
autocmd filetype zim,txt let g:PasteImageFunction = 'g:ZimwikiPasteImage'
autocmd filetype markdown,tex,zim,txt nmap <buffer><silent> <leader><leader>p :call mdip#MarkdownClipboardImage()<CR>| " markdown:zim 粘贴图片
autocmd FileType markdown silent! ALEDisableBuffer
" ----------img-paste }---------------------------------------------------------


" vim-markdown-toc 插件配置 {
let g:vmt_cycle_list_item_markers = 1
let g:vmt_auto_update_on_save = 1
" 自动更新

" vim-markdown-toc 插件配置 }

" ----------------------------------------------------------------------------

" markdown-preview 插件配置 {
" let g:mkdp_markdown_css = $VIM . '\github-markdown-light.css'
let g:mkdp_markdown_css = expand('~/.vim/markdown/github-markdown-light.css')
" markdown-preview 插件配置 }

" ----------------------------------------------------------------------------


noremap <leader>gsnm :silent call MarkupGenSectionNum('markdown')<cr>|    " markup: markdown生成数字目录序号
noremap <leader>gsnz :silent call MarkupGenSectionNum('zim')<cr>|         " markup: zim生成数字目录序号

" =====================File: markup.vim }======================= 标记文档 ==============================================

