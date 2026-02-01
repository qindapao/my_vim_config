
" =====================File: tabs.vim {======================= 标签页操作 =============================================

nnoremap <silent> tn :tabnew<CR>|   " tabs: 创建新标签页
nnoremap <silent> tc :tabclose<CR>| " tabs: 关闭当前标签页
nnoremap <silent> tC :q!<CR>|       " tabs: 强制关闭当前标签页
nnoremap <silent> to :tabonly<CR>|  " tabs: 只保留当前标签页
nnoremap <Tab> gt<cr>|              " tabs: 向前切换标签页
nnoremap <S-Tab> gT<cr>|            " tabs: 向后切换标签页
nnoremap <M-1> 1gt|                 " tabs: 切换到第1个标签页
nnoremap <M-2> 2gt|                 " tabs: 切换到第2个标签页
nnoremap <M-3> 3gt|                 " tabs: 切换到第3个标签页
nnoremap <M-4> 4gt|                 " tabs: 切换到第4个标签页
nnoremap <M-5> 5gt|                 " tabs: 切换到第5个标签页
nnoremap <M-6> 6gt|                 " tabs: 切换到第6个标签页
nnoremap <M-7> 7gt|                 " tabs: 切换到第7个标签页
nnoremap <M-8> 8gt|                 " tabs: 切换到第8个标签页
nnoremap <M-9> 9gt|                 " tabs: 切换到第9个标签页
nnoremap <M-0> :tablast<CR>|        " tabs: 切换到最后一个标签页

" =====================File: tabs.vim {======================= 标签页操作 =============================================

