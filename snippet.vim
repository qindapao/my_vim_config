
" =====================File: snippet.vim {======================= 代码片段 =====

" ----------------------------------------------------------------------------

let g:coc_snippet_next = '<tab>'

" " vim-snippets 插件配置 {
" Coc中安装这个就能触发代码片段,并且它读取的是UltiSnipsSnippetDirectories目录中的代码片段,另外UltiSnips目录也会默认读取
" :CocInstall coc-snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnips"]
" Utisnippest目录
" snippets.userSnippetsDirectory": "C:\\Users\\xx\\.vim\\plugged\\vim-snippets\\mysnips",
" vscode的textmate格式目录 sh.json 后缀
" snippets.textmateSnippetsRoots": ["C:\\Users\\xx\\.vim\\plugged\\vim-snippets\\textmate"]

inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CommonCheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

" ----------------------------------------------------------------------------

" =====================File: snippet.vim }======================= 代码片段 =====

