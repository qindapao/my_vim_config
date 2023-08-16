# my_vim_config
vim configuration file for my personal use

# vundle

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

# 语法检查和格式化器

vim的个人插件目录的配置
```
C:\Users\pc\.vim
    bundle
    shellcheck.exe
    shfmt.exe
```

## bash
### shell-check
>bash的语法检查器

https://www.shellcheck.net/
https://github.com/koalaman/shellcheck


**windows**: shellcheck-v0.9.0.zip
set shellcheck.exe to PATH

### shfmt
>bash的自动化格式器

https://github.com/mvdan/sh => shfmt_v3.7.0_windows_amd64.exe




# 在windows下为vim的配置文件创建符号链接
```txt
C:\Windows\System32>D:

D:\>cd D:\programes\Vim

D:\programes\Vim>mklink _vimrc E:\code\my_vim_config\_vimrc
为 _vimrc <<===>> E:\code\my_vim_config\_vimrc 创建的符号链接

D:\programes\Vim>
```

# 交换esc和caps lock的键位

参考链接：[=>](https://cloud.tencent.com/developer/article/1748870)

1. win + R 输入 regedit 打开注册表
2. 进入目录 HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout
3. 建立一个二进制的映射
```txt
Scancode Map
00 00 00 00 00 00 00 00
03 00 00 00 3A 00 01 00
01 00 3A 00 00 00 00 00
```



