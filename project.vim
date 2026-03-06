
" =====================File: project.vim {======================= 项目管理 =====

" ----------------------------------------------------------------------------

" vim-rooter 插件配置
" 需要打印目录
let g:rooter_silent_chdir = 0
" 手动设置root目录
let g:rooter_manual_only = 1
let g:rooter_patterns = ['.root', '.svn', '.git', '.hg', '.project']

" vim-rooter 插件配置 {
nnoremap <leader>foo :Rooter<CR>|       " project: 把当前的工作目录切换到项目的根目录
" vim-rooter 插件配置 }

" ----------------------------------------------------------------------------

" ------------vim-go插件不要启动补全------------------------------------------
" 默认使用 coc 提供的补全
let g:go_code_completion_enabled = 0
let g:go_def_mapping_enabled = 0

" === coc.nvim 基础增强 ===

" 跳转
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" 文档浮窗
nnoremap <silent> gk :call CocActionAsync('doHover')<CR>

" 重命名
nmap <silent> gnr <Plug>(coc-rename)

" 格式化
nmap <silent> gnf <Plug>(coc-format)

" Code Action
nmap <silent> ga <Plug>(coc-codeaction)

" ]g 快速跳到下一个诊断
" [g 快速跳到前一个诊断

" ----------------------------------------------------------------------------


" =====================File: project.vim }======================= 项目管理 =====

