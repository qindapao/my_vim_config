
# my_vim_config
vim configuration file for my personal use


<!-- vim-markdown-toc GFM -->

+ [vim最新的安装包下载](#vim最新的安装包下载)
+ [特殊插件安装备忘](#特殊插件安装备忘)
    * [1 vim-plug](#1-vim-plug)
    * [2 rbong/vim-flog](#2-rbongvim-flog)
    * [3 coc.nvim](#3-cocnvim)
    * [4 markdown2ctags](#4-markdown2ctags)
+ [语法检查和格式化器](#语法检查和格式化器)
    * [1 bash](#1-bash)
        - [1.1 shell-check](#11-shell-check)
        - [1.2 shfmt](#12-shfmt)
+ [在windows下为vim的配置文件创建符号链接](#在windows下为vim的配置文件创建符号链接)
+ [交换esc和caps lock的键位](#交换esc和caps-lock的键位)
+ [gtags](#gtags)
+ [ctags](#ctags)
+ [git可执行文件的位置](#git可执行文件的位置)
+ [文件备份](#文件备份)
+ [字体](#字体)

<!-- vim-markdown-toc -->

# vim最新的安装包下载

https://github.com/vim/vim-win32-installer/releases

# 特殊插件安装备忘

## 1 vim-plug

选择使用vim-plug来管理插件。

https://github.com/junegunn/vim-plug

下载plug.vim，然后放置到`autoload`目录下。

## 2 rbong/vim-flog

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

## 3 coc.nvim

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

3. 可以使用下面的命令显示当前安装的子插件

```
:CocList
extensitions
```

然后光标移动到需要操作的插件上，然后按`TAB`键，就可以卸载或者暂时禁用某个插件。

**其它补全插件**:

[tabnine-vim](https://github.com/codota/tabnine-vim)
[completor](https://github.com/maralla/completor.vim)

>completor这个插件比较特别，我发现它可以补全中文上下文，但是`coc.nvim`都不行。所以`completor`这个插件还是很有价值的，目前我在公司就是用的是这个插件。



## 4 markdown2ctags

原始的tagbar插件无法显示markdown格式的大纲，需要配合这个插件一起使用。
安装后需要设置可执行文件的位置:
```
\ 'ctagsbin' : 'C:/Users/pc/.vim/plugged/markdown2ctags/markdown2ctags.py',
```
其它的配置见`_vimrc`文件中的内容。


# 语法检查和格式化器

vim的个人插件目录的配置
```
C:\Users\pc\.vim
    bundle
    shellcheck.exe
    shfmt.exe
```

## 1 bash
### 1.1 shell-check
>bash的语法检查器

https://www.shellcheck.net/
https://github.com/koalaman/shellcheck


**windows**: shellcheck-v0.9.0.zip
set shellcheck.exe to PATH

### 1.2 shfmt
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

# gtags

http://adoxa.altervista.org/global/

下载后将可执行文件的路径放置到vim能访问到的PATH目录中：C:\Users\pc\.vim\gtags\bin

使用指导:
https://zhuanlan.zhihu.com/p/36279445
这个是对上面的一些补充:
https://learnku.com/articles/28249
gtags原生只支持6种语言：原生支持 6 种语言（C，C++，Java，PHP4，Yacc，汇编）
要支持其它语言，需要使用python。

```bash
pip install pygments
```

记得安装python模块的时候以管理员的身份运行。

vim的配置文件中需要加入类似下面的配置：
```txt
let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/path/to/share/gtags/gtags.conf'
```

已经按照链接中的方法配置。

如果想让gtags可以识别**库目录**，可以采用创建软链接的方法把库目录的软链接创建到项目的根目录位置。

```txt
mklink /d d:\pythonlib C:\Python311\Lib
```




# ctags

下载使用改进后的ctags:
项目的主页：
https://github.com/universal-ctags/ctags
可执行文件的下载地址：
https://github.com/universal-ctags/ctags-win32


如果我们需要为`ctags`指定配置文件，那么配置文件的路径是有要求的，可以参考这个链接： [ctags配置文件路径](https://docs.ctags.io/en/latest/option-file.html) 。

在`windows`的系统上配置文件的路径大概如下：

```bash
C:\Users\pc\ctags.d
```
其实就是变量：`%HOMEDRIVE%%HOMEPATH%/ctags.d/`


配置文件中的长名称和短名称都只能使用字母和数字，连 **下划线** 都不能使用。这里举一个范例：

**C:\Users\pc\ctags.d\conf.ctags**:

```bash
--langdef=txt
--langmap=txt:.txt
--regex-txt=/^(\={6}\s)(\S.+)(\s\={6})$/\2/h,heading/
--regex-txt=/^(\={5}\s)(\S.+)(\s\={5})$/. 2/h,heading/
--regex-txt=/^(\={4}\s)(\S.+)(\s\={4})$/.   \2/h,heading/
--regex-txt=/^(\={3}\s)(\S.+)(\s\={3})$/.     \2/h,heading/
--regex-txt=/^(\={2}\s)(\S.+)(\s\={2})$/.       \2/h,heading/

--langdef=zim
--langmap=zim:.txt
--regex-zim=/^(\={6}\s)(\S.+)(\s\={6})$/\2/h,heading/
--regex-zim=/^(\={5}\s)(\S.+)(\s\={5})$/. \2/h,heading/
--regex-zim=/^(\={4}\s)(\S.+)(\s\={4})$/.   \2/h,heading/
--regex-zim=/^(\={3}\s)(\S.+)(\s\={3})$/.     \2/h,heading/
--regex-zim=/^(\={2}\s)(\S.+)(\s\={2})$/.       \2/h,heading/

```
比如上面这个例子中，如果`heading`写成了`Heading_L1`就不行。上面为了显示出标签的层级，所以在不同层级的标签前面加上了`.`符号来区分。我尝试只加空格或者是只有`TAB`键都不行，具体原因未明，不过多了一个`.`符号也没有变得难看先这样吧。在使用`tagbar`的时候也要注意下，默认情况下tagbar是按照名字来排序标签的，可能和我们的预期不符，可以在`tagbar`的界面的位置按`s`键切换为按照标签出现的顺序排列。上面还有一个非常需要注意的地方是中间的正则表达式必须写成`(\S.+)`才能匹配中文，如果直接写成`.+`是匹配不了中文的。

目前还没有实现各级标签的折叠，不过这样也基本够用了，用空再折腾吧。

当有上面的配置的时候，vim的tagbar插件就可以按照下面配置：

```vim
let g:tagbar_type_zim = {
    \ 'ctagstype' : 'zim',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }
let g:tagbar_type_txt = {
    \ 'ctagstype' : 'txt',
    \ 'kinds' : [
        \ 'h:heading',
    \ ]
\ }
```
更加详细的说明可以参考这个[网页](https://gqqnbig.me/2023/09/20/vim%E9%85%8D%E7%BD%AE%E9%92%A2%E9%93%81%E9%9B%84%E5%BF%83%E6%96%87%E6%A1%A3%E5%A4%A7%E7%BA%B2/)，要注意下`Universal Ctags`和原来那个老的ctag是不一样的。

# git可执行文件的位置

如果电脑中安装了几个虚拟机，那么可能环境变量中会有重复的git.exe可执行程序，可能导致vim找到错误的exe程序，解决方法是把真正的系统的git.exe放置在环境变量的最前面的位置上。

# 文件备份

当前所有的文件都已经备份到了百度网盘。

```
vim
```
目录下。

其它资源

https://hanleylee.com/articles/usage-of-vim-editor-basic/


# 字体

一个很好看的适合`vim`使用的[字体](https://github.com/hanleylee/yahei-fira-icon-hybrid-font)。

