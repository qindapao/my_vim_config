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

Get-ChildItem -Attributes ReparsePoint
Pop-Location # 回到原来的目录
