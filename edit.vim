
" =====================File: edit.vim {======================= 编辑增强 ========

" -------auto-pairs 配置 {
au filetype markdown,html let b:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '**':'**', '~~':'~~', '<':'>'}
" :TODO: 具体使用的时候在来调整,或者把公司中的配置同步过来
au filetype zim let b:AutoPairs = {'(':')', '[':']', '{':'}',"''":"''",'"':'"', '`':'`', '**':'**', '~~':'~~', '<':'>', '//':'//'}
" -------auto-pairs 配置 }

" -------vim-expand-region {
" + " 辅助:vim-expand-region 普通模式下扩大选区
" _ " 辅助:vim-expand-region 普通模式下缩小选区

let g:expand_region_text_objects = {
      \ 'iw'  :1,
      \ 'iW'  :1,
      \ 'i"'  :1,
      \ "i'"  :1,
      \ 'ib'  :1,
      \ 'iB'  :1,
      \ }

      " 下面的这些先备份，暂时不设置
      " \ 'i]'  :1,
      " \ 'ab'  :1,
      " \ 'aB'  :1,
      " \ 'a]'  :1,
      " \ 'ii'  :1,
      " \ 'ai'  :1,
      " \ 'ip'  :1,
      " \ 'il'  :1,




" nnoremap v<count>ii | " edit: 选择当前缩进，不包括上边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>ai | " edit: 选择当前缩进，包括上边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>iI | " edit: 选择当前缩进，包括上下边界，(微调使用o命令，可以在可视选框上下调整)
" nnoremap v<count>aI | " edit: 选择当前缩进，不包括上下边界，(微调使用o命令，可以在可视选框上下调整)

nnoremap <M-i> <Plug>(expand_region_expand)|        " edit: 普通模式下扩大选区
vnoremap <M-i> <Plug>(expand_region_expand)|        " edit: 可视模式下扩大选区

" 缩小选区
nnoremap <M-o> <Plug>(expand_region_shrink)|        " edit: 普通模式下缩小选区
vnoremap <M-o> <Plug>(expand_region_shrink)|        " edit: 可视模式下缩小选区
" -------vvim-expand-region }

" table-mode {
let g:table_mode_corner='|'
nnoremap <leader>tm :TableModeToggle<CR>|           " edit: 表格编辑模式
" table-mode }

nnoremap <leader><leader>o o<Esc>|                  " edit: 下面插入一行保持普通模式(不能设置为oo,会导致严重延迟)
nnoremap <leader>O O<Esc>|                          " edit: 上面插入一行保持普通模式(不能设置为OO,会导致严重延迟)
nnoremap <leader><leader><space> :%s/\s\+$//e<CR>|  " edit: 移除文件中所有行尾的空白(全文)
xnoremap <leader><leader><space> :s/\s\+$//e<CR> |  " edit: 移除选区中所有行尾空白(可视)
iab xtime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>|  " edit: 在插入模式下快速插入当前日期(需要按两个TAB键触发)
" 安静保存
nnoremap <silent> <C-s> :silent w<CR>|              " edit: 普通模式保存文件
inoremap <silent> <C-s> <Esc>:silent w<CR>a|        " edit: 插入模式保存文件
vnoremap <silent> <C-s> <Esc>:silent w<CR>gv|       " edit: 可视模式保存文件

" undotree 的配置 {
nnoremap <leader><F5> :UndotreeToggle<CR> |         " edit: 切换undotree的打开和关闭
" undotree 的配置 }

" ----------------------------------------------------------------------------

" 映射插入模式下和全局替换模式(R/gR)下的快速移动，不能映射 <C-h> 会发生删除
inoremap <C-S-J> <Down>
inoremap <C-S-H> <Left>
inoremap <C-S-L> <Right>
inoremap <C-S-K> <Up>

" =====================File: edit.vim }======================= 编辑增强 ========

