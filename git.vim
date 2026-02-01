
" =====================File: git.vim {======================= git 相关 =================================================

" ----------------------------------------------------------------------------

" 打开git远端上的分支
" function GitGetCurrentBranchRemoteUrl()

"     let remote_branch_info = system('git.exe rev-parse --abbrev-ref --symbolic-full-name @{upstream}')
"     let [remote_name, branch_name] = split(remote_branch_info, '/')

"     let init_addr = system('git.exe config --get remote.origin.url')
"     let middle_info = substitute(init_addr, 'xx.yy.com:2222', 'xx.yy.com', 'g')
"     let middle_info = split(middle_info, '@')[1]
"     let middle_info = split(middle_info, '.git')[0]

"     let get_adr = 'http://' . middle_info . '/file?ref=' . branch_name

"     silent execute '!chrome' get_adr
"     " 下面这种方式避免命令执行黑框弹出
"     call job_start(['chrome', get_adr])
" endfunction




" ----------------------------------------------------------------------------

" vim-gitgutter {
if executable('git')
    let g:gitgutter_git_executable = 'git'
elseif filereadable('D:/programes/git/Git/bin/git.exe')
    let g:gitgutter_git_executable = 'D:/programes/git/Git/bin/git.exe'
endif

let g:gitgutter_max_signs = 2000                        " git: 改动标志上限，如果设置为-1,标记的数量为无限
let g:gitgutter_enabled = 0                             " 默认不启用 gitgutter
" vim-gitgutter }

" ----------------------------------------------------------------------------

" git:tags 检出某个远程标签到本地
function! GitCheckoutTag()
    let tagline = expand("<cfile>")
    let tagname = matchstr(tagline, '[^/]*$')
    execute 'Git fetch origin tag ' . tagname
    execute 'Git checkout tags/' . tagname
endfunction

" ----------------------------------------------------------------------------

function! GitExtractCommitsFromVisualRange()
    " 获取选区的起止行号
    let start = getpos("'<")[1]
    let end = getpos("'>")[1]

    " 获取选中的行
    let lines = getline(start, end)

    " 初始化 commit 列表
    let commits = []

    " 正则匹配：前后有空格的 [abcdefg]，提取中间哈希
    for line in lines
        " • 2025-10-13 02:03:45 +0200 [f8e23da] {xx} FIXED: xx
        let match = matchlist(line, '\v\s\[\zs([0-9a-f]{7})\ze\]\s')
        if len(match) > 1
            call add(commits, match[1])
        endif
    endfor

    " 存入寄存器 a 和 b
    " b 是 新提交
    " a 是 旧提交
    if len(commits) >= 2
        let @b = commits[0]
        let @a = commits[-1]
        echo "Copied to registers: a = " . @a . ", b = " . @b
    else
        echo "Not enough properly bracketed commits found in selection."
    endif
endfunction

" ----------------------------------------------------------------------------

function! GitDiffQuickfixEntryWithA()
    " Step 1: 只保留 Quickfix 窗口
    only

    " Step 2: 模拟回车，打开光标所在的 Quickfix 项
    execute "normal! \<CR>"

    " Step 3: 执行 Gvdiffsplit 对比，使用寄存器 a 中的提交哈希
    execute "Gvdiffsplit " . getreg('a')
endfunction

" ----------------------------------------------------------------------------

function! GitDiffQuickfixNextEntryWithA()
    copen
    
    only

    execute "cnext"

    execute "Gvdiffsplit " . getreg('a')
endfunction


" ----------------------------------------------------------------------------

" :TODO: 待验证
function! GitDeleteRemoteTagAndRefresh()
    let l:tag = CommonGetLineContentLast()
    " 1 表示选择的是 Yes 2 表示选择的 No
    if confirm("删除远程标签 '" . l:tag . "' ?", "&Yes\n&No") != 1
        return
    endif
    execute 'Git push origin :' . l:tag
    execute 'Git fetch --prune --tags'
    execute 'terminal Git ls-remote --tags'
endfunction

" ----------------------------------------------------------------------------

function! GitDeleteRemoteTag()
    let tagline = expand("<cfile>")
    let tagname = matchstr(tagline, '[^/]*$')
    execute 'Git push origin --delete tag ' . tagname
endfunction

" ----------------------------------------------------------------------------


" 切换它的打开和关闭
nnoremap <silent> <leader>ggo :GitGutterEnable<CR>      " git: 打开 gitgutter
nnoremap <silent> <leader>ggc :GitGutterDisable<CR>     " git: 关闭 gitgutter

" 状态的刷新时间由updatetime决定
nnoremap gnh :GitGutterNextHunk<CR>|                    " git: 下一个改动点
nnoremap gph :GitGutterPrevHunk<CR>|                    " git: 上一个改动点
command! Gqf GitGutterQuickFix | copen|                 " git: quickfix列表打开查看改动
command! Gcf GitGutterQuickFixCurrentFile | copen       " git: quickfix列表打开查看当前文件改动

" ----------------------------------------------------------------------------


" vim-fugitive 插件按键绑定 {
nnoremap <silent> <leader>gda :Git difftool -y<cr>|                                                                 " git: diff 显示所有差异
nnoremap <silent> <leader>gdc :execute 'Git! difftool ' . getreg('a') . ' ' . getreg('b') . ' --name-status'<CR>|   " git: diff 对比两个commit
nnoremap <silent> <leader>gdb :execute 'Git! difftool ' . getreg('a') . ' --name-status'<CR>|                       " git: diff 对比两个分支或者两个commit(以当前的作为基准)
nnoremap <silent> <leader>gdd :execute 'Gvdiffsplit ' . getreg('a')<CR>|                                            " git: diff 执行单文件对比(commit id 和 分支)
nnoremap <silent> <leader>gdv :call GitDiffQuickfixEntryWithA()<CR>
nnoremap <silent> <leader>gdn :call GitDiffQuickfixNextEntryWithA()<CR>
nnoremap <silent> <leader>gdf :execute 'Gvdiffsplit'<CR>|                                                           " git: diff 对比当前文件
nnoremap <silent> <leader>gbn :Git checkout -b |                                                                    " git: branch 基于当前分支创建一个新分支
nnoremap <silent> <leader>gbl :execute 'Git branch'<CR>| " git:branch 查看所有本地分支
nnoremap <silent> <leader>gbc :execute 'normal "xyiw' \| execute 'Git checkout ' . getreg('x') \| close<CR>|        " git:branch 切换分支
vnoremap <silent> <leader>gbc y:execute 'Git checkout ' . shellescape(@0) \| close<CR>|                             " git:branch 切换分支
nnoremap <silent> <leader>gbxl :execute 'normal "xyiw' \| execute 'Git branch -d ' . getreg('x') \| bwipeout \| execute 'Git branch'<CR>|   " git: branch 删除一个本地分支
vnoremap <silent> <leader>gbxl y:execute 'Git branch -d ' . shellescape(@0) \| bwipeout \| execute 'Git branch'<CR>|                        " git: branch 删除一个本地分支
nnoremap <silent> <leader>gbxfl :execute 'normal "xyiw' \| execute 'Git branch -D ' . getreg('x') \| bwipeout \| execute 'Git branch'<CR>|  " git: branch 删除一个本地分支
vnoremap <silent> <leader>gbxfl y:execute 'Git branch -D ' . shellescape(@0) \| bwipeout \| execute 'Git branch'<CR>|                       " git: branch 删除一个本地分支

nnoremap <silent> <leader>gbxr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -d ' . branchname<CR>|    " git: branch 删除一个远程分支
nnoremap <silent> <leader>gbxfr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git push origin -D ' . branchname<CR>|   " git: branch 删除一个远程分支

nnoremap <silent> <leader>gbr :execute 'Git fetch --all --prune' \| execute 'Git branch -r'<CR>|                    " git: branch 查看所有在远程分支
" 拉取一个远程分支并在本地跟踪它(复制远程分支名然后检出到本地然后建立两者的跟踪关系)
" git fetch origin <远程分支名>:<本地分支名>
" git branch --set-upstream-to=origin/<远程分支名> <本地分支名>
nnoremap <silent> <leader>gbfr :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git fetch origin ' . branchname . ':' . branchname \| execute 'Git branch --set-upstream-to=origin/' . branchname . ' ' . branchname<CR>
                                                                                                                    " git: branch 检出一个远程分支到本地
nnoremap <silent> <leader>gbur :let branchline=expand("<cfile>") \| let branchname=matchstr(branchline, '[^/]*$') \| execute 'Git fetch upstream ' . branchname . ':' . branchname \| execute 'Git branch --set-upstream-to=upstream/' . branchname . ' ' . branchname<CR>
                                                                                                                    " git: branch 检出一个远程分支(upstream)到本地

nnoremap <silent> <leader>gpl :execute 'Git pull'<CR>|                                                              " git: 拉取最新的变更
" 推送当前更改(当前本地分支)
nnoremap <silent> <leader>gps :let branchname=system('git rev-parse --abbrev-ref HEAD') \| execute 'Git push --set-upstream origin ' . trim(branchname)<CR>
                                                                                                                    " git: 推送当前本地分支到远端

" 查看当前文件的所有提交历史
nnoremap <silent> <leader>gog :0Gclog<cr> |                                                                         " git: 查看当前文件相关的所有提交历史记录

" 标签管理
nnoremap <leader>gta :execute 'Git tag -a <tag-name> ' . getreg('a') .  ' -m "标注信息"'|                           " git: tags 基于某个提交创建一个标签
nnoremap <silent> <leader>gtsl :execute 'normal "xyiw' \| execute 'Git show ' . getreg('x')<CR>|                    " git: tags 显示某个标签明细
nnoremap <silent> <leader>gtl :execute 'Git tag -l'<CR>|                                                            " git: tags 列出所有的本地标签

nnoremap <silent> <leader>gtxl :execute 'normal "xyiw' \| execute 'Git tag -d ' . getreg('x') \| bwipeout \| execute 'Git tag -l'<CR>
                                                                                                                    " git: tags 删除一个本地标签
vnoremap <silent> <leader>gtxl y:execute 'Git tag -d ' . shellescape(@0) \| bwipeout \| execute 'Git tag -l'<CR>|   " git: tags 删除一个本地标签

nnoremap <silent> <leader>gtp :execute 'normal "xyiw' \| execute 'Git push --set-upstream origin ' . getreg('x')<CR>
                                                                                                                    " git: tags 推送某个标签到远程服务器(x寄存器中存储了内容)
vnoremap <silent> <leader>gtp "xy:Git push --set-upstream origin <C-R>x<CR>|                                        " git: tags 推送某个标签到远程服务器(x寄存器中存储了内容)

nnoremap <silent> <leader>gtr :execute 'Git fetch --prune --tags' \| terminal Git ls-remote --tags<CR>|             " git: tags 列出所有的远程标签
nnoremap <silent> <leader>gtxr :call GitDeleteRemoteTagAndRefresh()<CR>|                                            " git: tags 删除某一个远程标签(待验证)
nnoremap <silent> <leader>gtxr :call GitDeleteRemoteTag()<CR>                                                       " git: tags 删除某一个远程标签
nnoremap <silent> <leader>gtc :call GitCheckoutTag()<CR>|                                                           " git: tags 检出某个远程标签到本地

xnoremap <leader>ec :<C-u>call GitExtractCommitsFromVisualRange()<CR>|                                              " git: Flog 界面截取选区内的起始 commit(最终对比的时候是左旧右新)
" nnoremap <silent> <leader>git :call GitGetCurrentBranchRemoteUrl()<CR>|                                           " git: 通过浏览器打开git上对应当前本地分支的远端分支

" diffchar 插件配置 {
nnoremap <Leader>gdcp <Plug>GetDiffCharPair<CR>
" diffchar 插件配置 }

" vim-fugitive 插件按键绑定 }

" ----------------------------------------------------------------------------

" =====================File: git.vim }======================= git 相关 =================================================

