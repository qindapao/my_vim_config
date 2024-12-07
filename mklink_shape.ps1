
if ($args.Count -ne 2) {
    Write-Host ".\mklink_shape.ps1 D:\programes\Vim\draw_shaps E:\code\my_vim_config\draw_shaps"
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
# :TODO: 这里很奇怪,下面这行注释删除后脚本执行部正常啊
# New-SymbolicLink -Name "led.vim" -Target (Join-Path -Path $args[1] -ChildPath "led.vim")
New-SymbolicLink -Name "basic.vim" -Target (Join-Path -Path $args[1] -ChildPath "basic.vim")
New-SymbolicLink -Name "led.vim" -Target (Join-Path -Path $args[1] -ChildPath "led.vim")
New-SymbolicLink -Name "figlet.vim" -Target (Join-Path -Path $args[1] -ChildPath "figlet.vim")

Get-ChildItem -Attributes ReparsePoint
Pop-Location # 回到原来的目录

