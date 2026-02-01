if ($args.Count -ne 2) {
    Write-Host ".\mklink.ps1 D:\programes\Vim E:\code\my_vim_config"
    exit
}

Push-Location # 保存当前目录
Set-Location $args[0]

# 定义一个函数来创建符号链接，并在目标路径已存在时删除它
function New-SymbolicLink {
    param (
        [String]$Name,
        [String]$Target
    )
    # 检查目标路径是否已存在
    if (Test-Path $Name) {
        # 删除已存在的文件或文件夹
        Remove-Item $Name -Recurse -Force
    }
    # 创建符号链接
    New-Item -ItemType SymbolicLink -Name $Name -Value $Target
}

# 调用函数来创建符号链接
New-SymbolicLink -Name "complete_list_all.vim" -Target (Join-Path -Path $args[1] -ChildPath "complete_list_all.vim")
New-SymbolicLink -Name "complete_list_python.vim" -Target (Join-Path -Path $args[1] -ChildPath "complete_list_python.vim")
New-SymbolicLink -Name "complete_list_sh.vim" -Target (Join-Path -Path $args[1] -ChildPath "complete_list_sh.vim")
New-SymbolicLink -Name "complete_list_zim.vim" -Target (Join-Path -Path $args[1] -ChildPath "complete_list_zim.vim")
New-SymbolicLink -Name "keybinding_help.vim" -Target (Join-Path -Path $args[1] -ChildPath "keybinding_help.vim")
New-SymbolicLink -Name "coc-settings.json" -Target (Join-Path -Path $args[1] -ChildPath "coc-settings.json")
New-SymbolicLink -Name "_vimrc" -Target (Join-Path -Path $args[1] -ChildPath "_vimrc")
New-SymbolicLink -Name "common.vim" -Target (Join-Path -Path $args[1] -ChildPath "common.vim")
New-SymbolicLink -Name "diff.vim" -Target (Join-Path -Path $args[1] -ChildPath "diff.vim")
New-SymbolicLink -Name "global_setting.vim" -Target (Join-Path -Path $args[1] -ChildPath "global_setting.vim")
New-SymbolicLink -Name "marks.vim" -Target (Join-Path -Path $args[1] -ChildPath "marks.vim")
New-SymbolicLink -Name "plugins.vim" -Target (Join-Path -Path $args[1] -ChildPath "plugins.vim")
New-SymbolicLink -Name "tabs.vim" -Target (Join-Path -Path $args[1] -ChildPath "tabs.vim")
New-SymbolicLink -Name "files.vim" -Target (Join-Path -Path $args[1] -ChildPath "files.vim")
New-SymbolicLink -Name "surround.vim" -Target (Join-Path -Path $args[1] -ChildPath "surround.vim")
New-SymbolicLink -Name "debug.vim" -Target (Join-Path -Path $args[1] -ChildPath "debug.vim")
New-SymbolicLink -Name "translate.vim" -Target (Join-Path -Path $args[1] -ChildPath "translate.vim")
New-SymbolicLink -Name "markup.vim" -Target (Join-Path -Path $args[1] -ChildPath "markup.vim")
New-SymbolicLink -Name "search.vim" -Target (Join-Path -Path $args[1] -ChildPath "search.vim")
New-SymbolicLink -Name "alignment.vim" -Target (Join-Path -Path $args[1] -ChildPath "alignment.vim")
New-SymbolicLink -Name "motion.vim" -Target (Join-Path -Path $args[1] -ChildPath "motion.vim")
New-SymbolicLink -Name "complete.vim" -Target (Join-Path -Path $args[1] -ChildPath "complete.vim")
New-SymbolicLink -Name "window.vim" -Target (Join-Path -Path $args[1] -ChildPath "window.vim")
New-SymbolicLink -Name "terminal.vim" -Target (Join-Path -Path $args[1] -ChildPath "terminal.vim")
New-SymbolicLink -Name "font.vim" -Target (Join-Path -Path $args[1] -ChildPath "font.vim")
New-SymbolicLink -Name "edit.vim" -Target (Join-Path -Path $args[1] -ChildPath "edit.vim")
New-SymbolicLink -Name "cmdline.vim" -Target (Join-Path -Path $args[1] -ChildPath "cmdline.vim")
New-SymbolicLink -Name "quickfix.vim" -Target (Join-Path -Path $args[1] -ChildPath "quickfix.vim")
New-SymbolicLink -Name "lint.vim" -Target (Join-Path -Path $args[1] -ChildPath "lint.vim")
New-SymbolicLink -Name "tags.vim" -Target (Join-Path -Path $args[1] -ChildPath "tags.vim")
New-SymbolicLink -Name "git.vim" -Target (Join-Path -Path $args[1] -ChildPath "git.vim")
New-SymbolicLink -Name "display.vim" -Target (Join-Path -Path $args[1] -ChildPath "display.vim")
New-SymbolicLink -Name "project.vim" -Target (Join-Path -Path $args[1] -ChildPath "project.vim")
New-SymbolicLink -Name "snippet.vim" -Target (Join-Path -Path $args[1] -ChildPath "snippet.vim")
New-SymbolicLink -Name "draw.vim" -Target (Join-Path -Path $args[1] -ChildPath "draw.vim")
New-SymbolicLink -Name "popup.vim" -Target (Join-Path -Path $args[1] -ChildPath "popup.vim")
New-SymbolicLink -Name "jump.vim" -Target (Join-Path -Path $args[1] -ChildPath "jump.vim")
New-SymbolicLink -Name "slide.vim" -Target (Join-Path -Path $args[1] -ChildPath "slide.vim")
New-SymbolicLink -Name "toolbar.vim" -Target (Join-Path -Path $args[1] -ChildPath "toolbar.vim")
New-SymbolicLink -Name "zim.vim" -Target (Join-Path -Path $args[1] -ChildPath "zim.vim")
New-SymbolicLink -Name "whichkey.vim" -Target (Join-Path -Path $args[1] -ChildPath "whichkey.vim")
New-SymbolicLink -Name "post.vim" -Target (Join-Path -Path $args[1] -ChildPath "post.vim")

Get-ChildItem -Attributes ReparsePoint
Pop-Location # 回到原来的目录
