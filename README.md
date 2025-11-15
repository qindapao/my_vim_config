
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
+ [windows系统下调整光标的移动速度](#windows系统下调整光标的移动速度)

<!-- vim-markdown-toc -->

# vim最新的安装包下载

https://github.com/vim/vim-win32-installer/releases

当前我使用的版本是：`9.1`，包含补丁`1-16`。

最开始我安装的是`1-16`号补丁，当前现在安装的最新的是`1-44`号补丁。使用50号补丁以及以后都无法识别`shift`键了。

我在vim的项目中反馈了这个问题，并且提了一个issue，但是开发者说这是一个[修复](https://github.com/vim/vim/issues/18745)，以前的才是不正常的。

比如：`Ctrl+V`和`Ctrl+Shift+V`对于编辑器来说都是一个按键，按键码都是`22`。对于其他的组合情况也是这样。

验证方法是在vim的命令行中输入：`:echo getchar()`，然后按`Ctrl+V`；重复这个动作，然后按`Ctrl+SHift+V`，就可以测试是否是相同的按键。

但是呢，使用老版本的`gvim`补丁，比如当前使用的`16`号或者`44`号补丁，只能安装`python3.12`。如果安装最新版本的`python`，某些插件，比如：`LeaderF`就会不正常！

由于我映射了很多和`shift`相关的按键，所以我打算不使用`Gvim`的最新版本，当前使用`16`号补丁或者`44`号补丁。

但是重新看了作者的[说明](https://github.com/vim/vim/commit/68d9472c65ec75725a0b431048bebe036921331c)后，我发现或许我可以使用
最新版本的`Gvim`。我只是需要调用一个函数来切换默认的按键映射方式而已。

```vim
:call test_mswin_event('set_keycode_trans_strategy', {'strategy': 'experimental'})
```

或者：

```vim
:call test_mswin_event('set_keycode_trans_strategy', {'strategy': 'classic'})
```

如果是在初始化的阶段，或者是极小的`Gvim`的构建，也可以通过直接设置下面这个环境变量来达到同样的目的。

```vim
set VIM_KEYCODE_TRANS_STRATEGY=experimental
```

或者:

```vim
set VIM_KEYCODE_TRANS_STRATEGY=classic
```




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

2. 随便找一个英文目录，解压后，使用`msys2`的环境进入到源码的顶级目录，然后`make`即可。
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

随着开发的进行，可能还会映射一些文件，用于放置一些全局变量等等。 目前使用脚本自动化处理需要创建符号链接的文件：

注意两点:

1. 脚本的运行需要管理员权限，所以请以管理员启动`powershell`的终端
2. 系统一般默认不运行脚本执行，所以在执行脚本前需要先临时关闭这个门禁

```powershell
PS C:\WINDOWS\system32> cd E:\code\my_vim_config
PS E:\code\my_vim_config> Set-ExecutionPolicy Unrestricted -Scope Process

执行策略更改
执行策略可帮助你防止执行不信任的脚本。更改执行策略可能会产生安全风险，如 https:/go.microsoft.com/fwlink/?LinkID=135170
中的 about_Execution_Policies 帮助主题所述。是否要更改执行策略?
[Y] 是(Y)  [A] 全是(A)  [N] 否(N)  [L] 全否(L)  [S] 暂停(S)  [?] 帮助 (默认值为“N”): Y
PS E:\code\my_vim_config>
PS E:\code\my_vim_config> .\mklink.ps1 D:\programes\Vim E:\code\my_vim_config


    目录: D:\programes\Vim


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---l         2024/1/19     23:54              0 complete_list_all.vim
-a---l         2024/1/19     23:54              0 complete_list_python.vim
-a---l         2024/1/19     23:54              0 complete_list_sh.vim
-a---l         2024/1/19     23:54              0 complete_list_zim.vim
-a---l         2024/1/19     23:54              0 keybinding_help.vim
-a---l         2024/1/19     23:54              0 complete_list_all.vim
-a---l         2024/1/19     23:54              0 complete_list_python.vim
-a---l         2024/1/19     23:54              0 complete_list_sh.vim
-a---l         2024/1/19     23:54              0 complete_list_zim.vim
-a---l         2024/1/19     23:54              0 keybinding_help.vim
-a---l         2024/1/12     22:34              0 _vimrc


PS E:\code\my_vim_config>
```

为了安全起见，执行完脚本后应该恢复执行前的安全策略。可以在执行前使用这个获取当前的安全策略`Get-ExecutionPolicy`，然后使用`Set-ExecutionPolicy`设置回去。

脚本归档在项目目录下：`mklink.ps1`


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

另外一个很好看而且适合编程的[字体](https://github.com/subframe7536/maple-font)。
下载前可以看下[下载说明](https://github.com/subframe7536/maple-font/blob/variable/README_CN.md#%E5%91%BD%E5%90%8D%E8%AF%B4%E6%98%8E)。

# windows系统下调整光标的移动速度

按 Win + R 打开运行对话框，输入 control keyboard 并按回车。

如果发现无法直接打开运行对话框，可以找到`cmd`命令行，然后以管理员的身份运行。

在“键盘属性”窗口中，选择“速度”选项卡。

调整“重复延迟”和“重复速率”滑块以设置你想要的速度。

点击“应用”然后“确定”保存更改。



