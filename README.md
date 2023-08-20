# my_vim_config
vim configuration file for my personal use


# vim最新的安装包下载


https://github.com/vim/vim-win32-installer/releases

# 特殊插件安装备忘

## vundle

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
## rbong/vim-flog

这个插件漂亮显示git graph，但是需要安装LuaJIT 2.1，可以参考[这里](https://github.com/rbong/vim-flog)的说明。

[编译参考](https://luajit.org/install.html):

1. 首先从[这里](https://luajit.org/download.html)下载源码。

    LuaJIT-2.1.0-beta3

2. 随便找一个英文目录，解压后，使用cygwin的环境进入到源码的顶级目录，然后`make`即可。
3. 等待编译完成，然后把生成的可执行文件放置到任何的能让`vim`读取到的`PATH`目录下。
   luajit.exe
   lua51.dll
4. 然后在可执行文件的目录下建立目录lua\jit\，并把源码的src\jit目录下的所有文件都拷贝到这个目录中来。
   lua\jit\*
5. 源码和可执行文件都已经备份。

## coc.nvim

>vim的智能提示和语法自动完成插件

[插件主页](https://github.com/neoclide/coc.nvim)
[插件指导](https://segmentfault.com/a/1190000040291763)

1. 插件要求安装nodejs，按照提示去官网下载安装即可。

>注意安装的时候不要勾选完整构建环境的安装，会出问题。暂时也不需要。

2. nodejs安装完成后先安装插件，安装插件后需要手动切换到release分支，否则使用的是没有编译的版本，插件安装完成后，安装插件市场

```
:CocInstall coc-marketplace
:CocList marketplace
```

可以在插件市场中搜索和`python`相关的插件。

```
:CocList marketplace python
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



