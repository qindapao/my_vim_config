
" =====================File: window.vim {======================= 窗口操作 ============================================

" ----------------------------------------------------------------------------

" 关闭同组兄弟窗口，只保留当前窗口
function! CollapseLeafGroup() abort
    let cur_winid = win_getid()
    let layout = winlayout()

    " 先找到当前窗口所在的分组路径
    function! s:find_parent_group(node, target, parent) abort
        if type(a:node) == type([])
            if a:node[0] ==# 'row' || a:node[0] ==# 'col'
                for child in a:node[1]
                    let result = s:find_parent_group(child, a:target, a:node)
                    if !empty(result)
                        return result
                    endif
                endfor
            elseif a:node[0] ==# 'leaf' && a:node[1] == a:target
                return a:parent
            endif
        elseif type(a:node) == type(0) && a:node == a:target
            return a:parent
        endif
        return []
    endfunction

    let group = s:find_parent_group(layout, cur_winid, [])
    if empty(group)
        echohl WarningMsg | echo "未找到当前窗口的所属分组。" | echohl None
        return
    endif

    for sibling in group[1]
        if type(sibling) == type([]) && sibling[0] ==# 'leaf'
            let sid = sibling[1]
            if sid != cur_winid
                execute win_id2win(sid) . "close"
            endif
        elseif type(sibling) == type(0) && sibling != cur_winid
            execute win_id2win(sibling) . "close"
        endif
    endfor
endfunction

" ----------------------------------------------------------------------------

" 窗口操作
" 之所以绑定两个字母为了快速响应
" Z 代表最后结束的意思，所以是关闭窗口
nnoremap <silent> sz :close<CR>|                    " window: 关闭当前窗口
nnoremap <silent> <F2> :close<CR>|                  " window: 关闭当前窗口
nnoremap <silent> se :split<CR>|                    " window: 纵向分屏
nnoremap <silent> sw :vsplit<CR>|                   " window: 横向分屏
nnoremap <silent> sn :only<CR>|                     " window: 只保留当前窗口

command! CollapseFinalGroup call CollapseLeafGroup()
nnoremap <silent> sc :CollapseFinalGroup<cr>        " 关闭当前拆分层级的其它窗口

" ----------------------------------------------------------------------------


" =====================File: window.vim }======================= 窗口操作 ============================================

