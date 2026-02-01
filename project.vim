
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

" =====================File: project.vim }======================= 项目管理 =====

