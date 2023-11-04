# vim_notes


<!-- vim-markdown-toc Marked -->

* [1 快捷键整理](#1-快捷键整理)
    - [1.1 窗口和buffer管理](#1.1-窗口和buffer管理)
    - [1.2 vim自带终端操作](#1.2-vim自带终端操作)
    - [1.3 链接](#1.3-链接)
* [2 搜索](#2-搜索)
* [3 tags查找搜索](#3-tags查找搜索)
    - [3.1 gtags](#3.1-gtags)
    - [3.2 CCTree](#3.2-cctree)
* [4 leaderf](#4-leaderf)
* [5 替换](#5-替换)
    - [5.1 ve配置](#5.1-ve配置)
    - [5.2 R命令和gR命令](#5.2-r命令和gr命令)
    - [5.3 全局替换](#5.3-全局替换)
        + [5.3.1 加入参数列表](#5.3.1-加入参数列表)
        + [5.3.2 对参数列表中的文件进行替换操作](#5.3.2-对参数列表中的文件进行替换操作)
    - [5.4 使用插件进行替换](#5.4-使用插件进行替换)
        + [5.4.1 ctrlsf](#5.4.1-ctrlsf)
* [6 编辑](#6-编辑)
    - [6.1 可视模式](#6.1-可视模式)
        + [6.1.1 虚拟编辑模式](#6.1.1-虚拟编辑模式)
        + [6.1.2 可视模式下的复制](#6.1.2-可视模式下的复制)
* [7 文件操作](#7-文件操作)
    - [7.1 打开历史文件](#7.1-打开历史文件)
* [8 未整理](#8-未整理)
* [9 常用插件操作](#9-常用插件操作)
    - [9.1 surround](#9.1-surround)
    - [9.2 completor 补全插件](#9.2-completor-补全插件)
    - [9.3 coc 补全框架](#9.3-coc-补全框架)
        + [9.3.1 coc框架下的c语言补全](#9.3.1-coc框架下的c语言补全)
        + [9.3.2 coc补全和代码片段管理工具的集成](#9.3.2-coc补全和代码片段管理工具的集成)
        + [9.3.3 支持java语言](#9.3.3-支持java语言)
    - [9.4 ale代码检查](#9.4-ale代码检查)
        + [9.4.1 java语言](#9.4.1-java语言)
* [10 git](#10-git)
    - [10.1 配置终端中使用的git工具](#10.1-配置终端中使用的git工具)
    - [10.2 使用浏览器打开当前文件的远程文件](#10.2-使用浏览器打开当前文件的远程文件)
* [11 vim的自定义函数](#11-vim的自定义函数)
* [12 vscode](#12-vscode)
    - [12.1 easymotion插件的一些说明](#12.1-easymotion插件的一些说明)
* [13 关于使用vim来画字符画](#13-关于使用vim来画字符画)
    - [13.1 虚拟编辑模式](#13.1-虚拟编辑模式)
    - [13.2 实用的命令行小工具](#13.2-实用的命令行小工具)
    - [13.3 R模式和gR模式](#13.3-r模式和gr模式)
* [14 git](#14-git)
    - [14.1 登录wsl后的别名设置](#14.1-登录wsl后的别名设置)
    - [14.2 fugitive](#14.2-fugitive)
        + [14.2.1 Gvdiffsplit](#14.2.1-gvdiffsplit)
        + [14.2.2 修改点的跳转](#14.2.2-修改点的跳转)
        + [14.2.3 如何实现预览所有的变更](#14.2.3-如何实现预览所有的变更)
* [15 调试](#15-调试)
    - [15.1 vimspector方案](#15.1-vimspector方案)
    - [15.2 安装vimspector插件](#15.2-安装vimspector插件)
    - [15.3 安装需要的调试适配器](#15.3-安装需要的调试适配器)
* [16 代码智能建议](#16-代码智能建议)

<!-- vim-markdown-toc -->

## 1 快捷键整理

### 1.1 窗口和buffer管理

由于有一个`terminal_help`插件把窗口切换快捷键映射了，不再是默认的`ctrl + w`，而且可以支持连续切换，目前是下面的值：

>下面这些操作都是在普通模式下

| 按键            | 功能           | 备注 |
|-----------------|----------------|------|
| alt + shift + H | 切换到左边窗口 |      |
| alt + shift + L | 切换到右边窗口 |      |
| alt + shift + J | 切换到下边窗口 |      |
| alt + shift + K | 切换到上边窗口 |      |
| ctrl + w + c    | 关闭当前窗口   |      |
| ctrl + w + v    | 左右拆分窗口   |      |
| ctrl + w + s    | 上下拆分窗口   |      |

1. 在NERD_tree插件的窗口中

按 `m` 然后等待一会儿，会出现文件操作的小窗口，可以对文件进行重命名或者删除添加复制等操作。

2. 如果在一些`quickfix`或者`locallist`之类的界面中，如果想分屏打开一个窗口，直接`ctrl + w + <CR>`即可。

### 1.2 vim自带终端操作

也是由于 `terminal_help` 插件的关系 ，所以拷贝字符到终端的操作方式发生变化。

3. `ctrl shift - " 0` 5个键表示复制复制寄存器中的值到终端窗口

### 1.3 链接

`gx`可以在浏览器中打开一个链接，如果链接不能直接被`vim`识别，那么可以先用可视模式选择这个链接，然后再按`gx`一样的。

## 2 搜索

1. 递归搜索当前目录以及所有子目录并quickfix打开

`: vim /string/ ** | copen`

如果是想指定文件类型，那么可以：
`: vim /string/ **/*.txt **/*.py | copen`
>查找当前目录以及子目录下的所有的txt和py后缀文件。

2. 搜索的时候排除不需要关注的目录

可以使用wildignore选项：
`:set wildignore+=objd/**,obj/**,*.tmp,test.c`
>排除掉objd目录以及它的子目录，排除掉obj目录以及它的子目录，排除掉当前目录下的*.tmp文件和test.c文件

还有个思路是关注需要搜索的文件：

```txt
:noautocmd vimgrep /{pattern}/gj `git ls-files`
```

映射一个快捷方式在配置文件中：

```txt
command -nargs=1 Sch noautocmd vimgrep /<args>/gj `git ls-files` | cw
```

这样，`:Sch xx`就可以搜索我们关注的文件了，不过在windows上这里可能会有点问题，因为git的可执行文件的路径问题。

3. 忽略大小写

`\c`

`:vim /\cxx/ %`

>在当前文件中查找`xx`，并忽略大小写。

4. vimgrep是可以搜索软链接目录的


5. 搜索后的单词被高亮，如果想去除高亮，可以用下面的命令。

```vim
:noh
```

## 3 tags查找搜索

### 3.1 gtags

**完整的命令：**
:GscopeFind {querytype} {name}

{name}中如果需要包含空格，那么需要使用反斜杠转义。无法忽略大小写，要实现比较麻烦，如果需要查询忽略大小写的正则表达式，建议还是使用vimgrep来实现。如果是简单的大小写匹配也可以使用下面这个例子演示的来实现。比**vimgrep**更**快速**。

```
:GscopeFind e [sS][bB]\ xx[0-9]
```
可以匹配这个字符串：`sB xx8`

```txt
{querytype} 取值有以下:
| 命令   | 快捷键     | 含义                          |
|--------|------------|-------------------------------|
| 0 or s | <leader>cs | 查找符号引用                  |
| 1 or g | <leader>cg | 查找定义                      |
| 2 or d | <leader>cd | 查找光标下的函数调用的函数    |
| 3 or c | <leader>cc | 查找调用光标下的函数的函数    |
| 4 or t | <leader>ct | 查找光标下的字符串            |
| 6 or e | <leader>ce | 查找光标下的egrep正则表达式   |
| 7 or f | <leader>cf | 查找光标下的文件名            |
| 8 or i | <leader>ci | 查找文件包括光标下的文件名    |
| 9 or a | <leader>ca | 查找分配当前符号的位置        |
| z      | <leader>cz | 在ctags的数据库中查找当前单词 |
```

如果使用过程中遇到了异常，使用下面的方法来解决：
比如抛出下面的异常:

```txt
ERROR: gutentags: gtags-cscope job failed, returned: 1
```

1. step1: add the line below to your .vimrc:
let g:gutentags_define_advanced_commands = 1

2. step2: restart vim and execute command:
:GutentagsToggleTrace

3. step3: open some files and generate gtags again with current project:
:GutentagsUpdate

4. step4: you may see a lot of gutentags logs, after that:
:messages
To see the gtags log.

**当前有一个问题:**

就是查询了几次后，会在项目的目录下生成`.stats`后缀的文件。查询得知这些文件是pylint生成的。尝试更新了`pylint`的版本后也没有解决问题。

`find . -name "*.stats" | xargs rm -f`

删除前最好是用`find . -name "*.stats"`命令查询下需要删除的文件是否都是它们，不要误删除。

更完整的说明可以看这里：
[补充](https://github.com/skywind3000/gutentags_plus)

**另外还有两个地方需要注意的：**

(1). 系统中的`gtags.exe`可执行文件在系统中最好只放一个，因为`vim`中的插件自己去找可执行文件，可能找到不是我们预期的那个。我当前是放置在`C:\Users\pc\.vim\gtags\bin\gtags.exe`，那么系统中就保持这一个就好，放置无法预期的错误。

(2). 如果系统中安装的`python3`不只有一个版本，比如既有`3.7`，也有`3.11`，那么要确保`guentags`插件使用的`python3`版本是安装了`pygments`模块的版本。不然会导致`native-pygments`找不到相应的模块报错。有一个简单的方法是在系统的环境变量中把安装了这个模块的`python3`的环境变量放在前面，这样插件寻找`python3`的可执行路径的时候就能先找到它。

### 3.2 CCTree

利用`vim`的`CCTree`插件，可以模拟`source insight`的代码树。插件需要安装[cscope](https://code.google.com/archive/p/cscope-win32/downloads)和[ccglue](https://sourceforge.net/projects/ccglue/files/latest/download)(解压出来有`ccglue.exe`和`ccglue_tracer.exe`两个可执行程序)工具。这里是`windows`版本的工具，选择`64`位的下载。

使用`CCTree`显示`C语言`的函数调用树，需要三步：

1. 先用`cscope`生成数据库。

2. 使用插件的命令添加`cscope`生成的数据库。

`CCTreeLoadDB xx.out`

3. 使用插件的命令打开生成的代码树。

跟踪`main`函数的调用：`CCTreeTraceForward main`

>具体的步骤见插件的帮助文档。

## 4 leaderf

模糊查找插件，使用前先安装[ripgrep](https://github.com/BurntSushi/ripgrep)

[使用说明](https://retzzz.github.io/dc9af5aa/)

* **特别说明**

如果需要在保持搜索框不自动关闭的情况下能动态打开文件，需要这样发命令:

```vim
:Leaderf rg -F --no-auto-preview --stayOpen -e mouse
```

上面这个命令的意思是：在保持搜索框不自动关闭的情况下，不要显示预览窗口(**如果有预览窗口就无法正常的打开文件！**)，然后正则搜索`mouse`字符串。

* 固定搜索某些目录

`Leaderf rg -e xxx aaa bbb`
在`aaa`和`bbb`目录中搜索xxx字符串。参考`rg`指令的语法。

* 排除掉某些目录

`Leaderf rg -e xxx -g=!src/`

排除掉`src`目录。

* 搜索当前文件中的行

`leaderfLine`


* 进入`leaderf`后的操作

| 快捷键                     | 说明                                         |
| -------------------------- | -------------------------------------------- |
| `<C-C>, <ESC>`             | 退出                                         |
| `<C-R>`                    | 在模糊查询和正则表达式模式间切换             |
| `<C-F>`                    | 在全路径搜索和名字搜索模式间切换             |
| `<Tab>`                    | 切换成normal模式                             |
| `<C-V>, <S-Insert>`        | 从剪切板里copy字符串进行查询                 |
| `<C-U>`                    | 清除已经打出的字符                           |
| `<C-J>, <C-K>`             | 在结果列表中移动                             |
| `<Up>, <Down>`             | 从历史记录里调出上一次/下一次的输入pattern   |
| `<2-LeftMouse> or <CR>`    | 打开在光标处的文件或者被选择的多个文件       |
| `<F5>`                     | 刷新缓存                                     |
| `<C-P>`                    | 预览选中结果                                 |
| `<C-Up>`                   | 在预览popup窗口里滚动向上                    |
| `<C-Down>`                 | 在预览popup窗口里滚动向下                    |
|                            |                                              |

按`<TAB>`键后可以进入`leaderf`的普通模式。`F1`可以查看这些普通命令的使用说明。再按`<TAB>`键就退出普通模式，又可以输入。

当前预览框最多显示的条目数量是**200**个，目前我自己改了下：

```python
def getInitialWinHeight(self):
    if self._reverse_order:
        return self._initial_win_height
    else:
        return 200
```

上面的`200`改成了`2000`.有空可以问下原作者这里是否可以调整。

* leaderf和gtags的配合

```vim
let g:Lf_CacheDirectory = expand('~')
" vim-gentags和leaderf共享的配置,只能这样配
let g:gutentags_cache_dir = expand(g:Lf_CacheDirectory.'/LeaderF/gtags')         
```

最重要的就是上面的配置，_vimrc中已经说明了，需要和`vim-gutentags`插件公用相关的`gtags`路径，所以只能这样配置。

* leaderf和rg配置搜索字符串时限定文件名过滤

```vim
leaderf rg -f *.py -e xx
```

上面的这句话的意思是在所有`.py`后缀结尾的文件中，正则搜索`xx`字符串。


## 5 替换

### 5.1 ve配置

如果设置`set ve=all`，那么`vim`相当于会变成一块横向无限的画布。在横向范围内，都可以进行替换操作，而不用管当面这行字符有多少。

### 5.2 R命令和gR命令

`R`命令是普通的替换命令，按照输入的字符来替换；
`gR`命令是虚拟替换命令，可以保持原来文本长度不变，在画字符画中有中文的情况下，就可以使用这种模式。


### 5.3 全局替换

#### 5.3.1 加入参数列表

```txt
: args **/*.txt **/*.py
```

#### 5.3.2 对参数列表中的文件进行替换操作

```txt
：argdo %s/hate/love/gc | update
```

>对参数列表中的文件依次把`hata`替换成`love`，并且更新文件，在每次替换前进行手动确认。

### 5.4 使用插件进行替换

#### 5.4.1 ctrlsf

`ctrlsf`这个插件也可以方便进行全局替换操作，打开替换窗口后，按`o`直接打开文件，如果想保持替换窗口不动打开文件，使用`O`。

**特别注意**：这个插件是把当前的`pwd`的目录作为项目的根目录的，所以如果想在项目中进行全局搜索，最好是先运行`Rooter`命令(这是一个插件提供的)后，再执行`ctrlsf keywords`的查找，这样才是全局结果。


## 6 编辑

### 6.1 可视模式

#### 6.1.1 虚拟编辑模式

设置`set ve=all`可以让编辑器进入可视虚拟编辑模式，可以在超出边界的位置编辑，适合用用于绘制图表。比如用`vim`可以绘制简单的文本图。  
默认情况下这个值为空，即`set ve=`

#### 6.1.2 可视模式下的复制

在`vim9`中，在可视模式下，可以使用`P`来粘贴内容，不会影响默认寄存器中的内容。


## 7 文件操作

### 7.1 打开历史文件

```txt
:browse oldfiles
<ESC>
选择数字
<CR>
```

## 8 未整理

当前操作某些文件会产生 `.stats` 后缀结尾的文件，目前不知道这些文件是怎么产生的。可以通过 `everything` 软件通过正则搜索带`.stats`后缀的文件来统一删除。



**待办的事项**:

:TODO: tabmode插件当前在`markdown`的收缩语法或者是`zimwiki`的收缩语法的时候，留空的宽度是不对的，是按照原有的字符数来留空的，这样语法收缩后会导致无法对齐。这个空了可以优化下，思路是增加一个选项，给定软件留空策略，一共三种：

1. 不留空
2. 以`markdown`语法收缩后作为基准。
3. 以`zimwiki`语法收缩后作为基准。

## 9 常用插件操作

### 9.1 surround

- 如果想在添加的括号后面补一个空格，那么使用前半括号，比如 `ysiw(` ，添加括号后，括号后面会补一个空格。
- 如果不需要空格，使用后半括号，比如 `ysiw)` ，效果就是不会补空格。

### 9.2 completor 补全插件

补全插件遇到文件名中有特殊字符，比如 `@ ! # *` 等，是无法正常补全的。

这个框架还有个优点是可以补全`markdown`文件或者是`zimwiki`文件中的中文。在配置文件中我是根据打开的文件的后缀类型来加载的：

```vim
if expand('%:e') ==# 'txt' || expand('%:e') ==# 'md'
    Plug 'maralla/completor.vim'                                               " 主要是用它的中文补全功能
else
    " 这里必须使用realese分支,不能用master分支,master分支需要自己编译
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
```

但是这里需要注意下，只有直接双击打开`markdown`文件或者是`zim`格式的`txt`文件才有效果。

### 9.3 coc 补全框架

`coc`自己的插件的安装位置：

- windows系统下是`%LOCALAPPDATA%\nvim-data\coc-extensions`
- vim8是`~/.vim/coc-extensions1`
- neovim是`~/.config/nvim/coc-extensions1`

在我的电脑上，这个路径是： **C:\Users\pc\AppData\Local\coc**


#### 9.3.1 coc框架下的c语言补全

1. 首先要做的事情是安装[clang](https://github.com/llvm/llvm-project)，对于`windows`系统来说，选择`LLVM-16.0.6-win64.exe`这样格式的安装包即可。记得安装最后的时候勾选添加到`PATH`。

2. 安装完成后，在命令执行窗口下输入以下的命令，如果能显示正常的信息，证明`clang`安装成功。

```cmd
C:\Users\pc>clang -v
clang version 16.0.6
Target: x86_64-pc-windows-msvc
Thread model: posix
InstalledDir: D:\programes\LLVM\bin

C:\Users\pc>
```

3. `clang`安装成功后，需要在`coc`的命令行运行以下指令，安装`coc`的`clang`补全插件：

```vim
:CocInstall coc-clangd
```

4. 安装完成后，打开一个C语言的源程序，会出现补全和代码提示。

#### 9.3.2 coc补全和代码片段管理工具的集成

如果安装了`ultisnips`补全，那么为了能在补全列表中看到片段插件的列表，需要在`coc`
中安装子插件`coc-ultisnips`:

```vim
:CocInstall coc-ultisnips
```

安装完成后就会出现`ultisnips`的补全列表了。一般情况下，除了安装`ultisnips`，我们
还会安装`vim-snippets`，这个插件中会有很多现成的可以直接使用的代码片段。

**如何自定义我们的代码片段？**

在编辑器中命令行输入`UltiSnipsEdit`，然后就会出现我们当前使用的文件对应的`snippets`
文件的路径，一般情况下是语言特定的文件。

目录看起来是这样的:

```txt
C:\Users\pc\.vim\plugged\vim-snippets\UltiSnips
```

这下面有很多片段文件，一般命名都是以具体的语言作为前缀，其中有一个文件比较特殊，
`all.snippets`，这个文件是对所有的文件类型都生效的一个全局文件。比如输入时间日期
等等就可以放在这里。


**如果我想定义多个`all.snippets`那么应该怎么操作呢？**

```vim
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysub"]
```

只需要在这个参数中加上我会自定义的目录即可。这个目录和模拟的片段目录平级即可。也
就是说是这样的目录结构：

```bash
UltiSnips
 ├──all.snippets
 ├──python.snippets
 └──...
mysub
 ├──all.snippets
 ├──python,snippets
 └──...

```

这个插件有[中文说明文档](https://github.com/Linfee/ultisnips-zh-doc/blob/master/doc/UltiSnips_zh.txt)。

#### 9.3.3 支持java语言

在编辑器中运行`:CocInstall coc-java`安装这个扩展。安装完成激活后随便打开一个`java`文件，就会自动下载 **JDT Language Server** 和相关的依赖文件。

下载的东西可能比较多，比较占用硬盘空间。



### 9.4 ale代码检查

#### 9.4.1 java语言

需要在系统中配置`javac`的默认编码方式，不然代码中的错误提示乱码。需要配置以下的参数：

```txt
JAVA_TOOL_OPTIONS -Dfile.encoding=UTF-8
```

如果是`windows`操作系统，直接加到用户环境变量或者系统环境变量中即可，这个参数影响所有的`java`二进制工具的默认编码格式。注意下这个环境变量修改后需要重新启动`OS`才能生效。

如果设置了上面这个还是出现乱码，可能是因为`javac`的版本和当前使用的`jdk`的版本不配套导致的，处理方式是正确指定`javac`可执行文件的路径。具体的配置方法在`_vimrc`中有说明。


## 10 git

### 10.1 配置终端中使用的git工具

```bash
root@DESKTOP-0MVRMOU:/etc# git.exe --version
git version 2.37.3.windows.1
root@DESKTOP-0MVRMOU:/etc# git --version
git version 2.34.1
root@DESKTOP-0MVRMOU:/etc#
```

由于默认的git可能是虚拟环境中的，并不是`windows`系统默认的`git.exe`可执行程序，这可能造成使用到了错误的程序，可以在终端的配置文件中增加别名来解决。

配置文件的一般位置是在`/etc/profile`，我们只需要在这个配置文件中加入下面这句话：

```bash
alias git="git.exe"
```

这样输入`git`的时候，实际调用的程序是`git.exe`，而不是虚拟终端中默认的版本不正确的`git`。

### 10.2 使用浏览器打开当前文件的远程文件

如果是用的是常规的`github`或者是类似的通用的`git`远程客户端，那么使用`vim-fugitive`插件的`:GBrowse`命令即可直接打开。

但是如果使用的是公司的系统，或者是`vim-rhubarb`(这个插件是搭配着`vim-fugitive`插件一起使用的)插件无法配置公司客户端，那么可以自己实现一个使用浏览器打开远程分支的功能，大概的思路如下：

在`_vimrc`中实现一个函数

```vim
 # 得到当前文件对应的远程分支的主机名和分支名
git.exe rev-parse --abbrev-ref --symbolic-full-name @{upstream}
 # 得到当前分支对应的远程分支的url，下面的主机名用上面得到的结果
git.exe config --get remote.主机名.url
 # 然后用这些地址拼接成一个浏览器地址，再使用下面的命令来打开
silent excute '!chrome' get_adr
```

## 11 vim的自定义函数

如果想要`vim`调用一个函数而不是输出回车就生效，最好的办法是使用`silent`命令。比如：
```vim
autocmd BufWritePost *.md silent call GenMarkdownSectionNum()
```
## 12 vscode

在`vscode`中也是可以使用`vim`的，安装`vscodevim`插件即可。这里是我的`vscode`的配置文件的备份：

```json
{
  "python.defaultInterpreterPath": "D:\\programes\\python3\\python.exe",
  "editor.renderWhitespace": "all",
  "editor.cursorBlinking": "solid",
  "editor.fontFamily": "sarasa mono sc",
  "security.workspace.trust.untrustedFiles": "open",
  "editor.minimap.enabled": false,
  "editor.tabCompletion": "on",
  "markdown.preview.fontSize": 12,
  "markdown.preview.lineHeight": 1.2,
  "[markdown]": {
      "editor.wordWrap": "on",
      "editor.quickSuggestions": {
        "comments": "on",
        "strings": "on",
        "other": "on"
      },
      "editor.tabCompletion": "on"
  },
  "terminal.integrated.profiles.windows": {
      "PowerShell -NoProfile": {
        "source": "PowerShell",
        "args": [
          "-NoProfile"
        ]
      },
      "Git-Bash": {
        "path": "D:\\programes\\git\\Git\\bin\\bash.exe",
        "args": ["--login"]
      }
    },
  "terminal.integrated.defaultProfile.windows": "Git-Bash",
  "markdown-preview-enhanced.enableExtendedTableSyntax": true,
  "markdown-preview-enhanced.enableHTML5Embed": true,
  "markdown-preview-enhanced.enableTypographer": true,
  "markdown-preview-enhanced.HTML5EmbedUseLinkSyntax": true,
  "workbench.colorTheme": "Default Light+",
  "diffEditor.ignoreTrimWhitespace": false,
  "[python]": {
    "editor.formatOnType": true
  },
  "editor.mouseWheelZoom": true,
  "excalidraw.image": {
    "exportScale": 1,
    "exportWithBackground": true,
    "exportWithDarkMode": false
  },
  "hediet.vscode-drawio.resizeImages": null,
  //vscodevim插件的配置
  "editor.lineNumbers":"relative",
  "vim.easymotion": true,
  "vim.incsearch": true,
  "vim.useSystemClipboard": true,
  "vim.useCtrlKeys": true,
  "vim.hlsearch": true,
  "vim.normalModeKeyBindings": [
    {
      "before": ["<C-h>"],
      "after": ["<C-w>", "h"]
    },
    {
      "before": ["<C-j>"],
      "after": ["<C-w>", "j"]
    },
    {
      "before": ["<C-k>"],
      "after": ["<C-w>", "k"]
    },
    {
      "before": ["<C-l>"],
      "after": ["<C-w>", "l"]
    },
    {
      "before": ["b", "c"],
      "commands": [
        ":close"
      ]
    }
  ]
}
```

上面的配置中，最后面就是关于`vscodevim`插件的配置。

### 12.1 easymotion插件的一些说明

```vim
" 向下跳转一个字符
<leader><leader>w
" 向下跳转一个字符
<leader><leader>b
" 上下搜索一个字符,敲击后会出现让输入查找字符的命令行提示,输入需要查找的字符
<leader><leader>s
" 上下搜索两个字符,敲击后会出现让输入查找字符的命令行提示,输入需要查找的2个字符
<leader><leader>2s
" 往下搜索一个字符,同上面一样，敲击后输入需要查找的字符
<leader><leader>f
" 往上搜索一个字符,同上面一样，敲击后输入需要查找的字符
<leader><leader>F
```

## 13 关于使用vim来画字符画

### 13.1 虚拟编辑模式


设置`:set ve=all`后vim在可视模式下就获取了横向的无限画布。然后可以使用自己的映射或者是类似与`DrawIt`或者是`TabMode`这样的软件来绘图。甚至可以直接调用外部程序，比如`diagon`。


### 13.2 实用的命令行小工具

在`vim`中使用`diagon`的方法也比较简单。只需要选择我们需要转换的文字，然后在命令行调用`diagon`对应的功能即可。举个例子，比如我们想生成一个文件树。我们先在vim中生成下面的文字：

```bash
Linux
    Suse
    androd
Windows
    windows98
    windowsxp

```

然后我们直接选择这些文字，在命令行输入以下的命令(命令前面加一个!表示这是一个外部命令)：

```vim
:!diagon Tree

```

文本就会自动切换成这样：

```bash

Linux
 ├──Suse
 └──androd
Windows
 ├──windows98
 └──windowsxp

```

还有个[视频](https://www.youtube.com/watch?v=WTnMft_wvZU)来说明这个用法。视频的后面还介绍了一个插件，不过我倒是觉得这个插件并没有多大作用。


如果想使用`diagon`的其它功能，也是类似。同样对应`Figlet`工具也可以类似的处理。




**一些第三方的画字符画的软件**:

(1). [ascii-draw](https://github.com/Nokse22/ascii-draw)
(2). [asciio](https://github.com/nkh/P5-App-Asciio)，它的`TUI`接口可以轻易在`vim`中调用。
(3). [另外一个ascii-draw](https://www.ascii-draw.com/)，它的[github链接](https://github.com/huytd/ascii-d)。

### 13.3 R模式和gR模式

这两种模式上面有讲到，用来给字符画写说明或者画线，就可以使用`gR`模式，可以保持文本中各字符在画布中的相对位置不发生变化。


## 14 git

### 14.1 登录wsl后的别名设置

由于我的git是在windows系统下使用，但是`wsl`的linux中也有一个git可执行程序。为了在运行`git`的时候是指向的`windows`系统下的可执行程序，在`wsl`的`.bashrc`文件中加上下面这句话。

```bash
alias git="git.exe"
```

这样运行`git`的时候就会自动指向windows下的`git.exe`，而不会使用wsl环境中的`/usr/bin/git`。


### 14.2 fugitive

#### 14.2.1 Gvdiffsplit

在这种对比模式下，如果想要撤销某个变更点的更改，可以在变更点上用下面命令：

* do 把另外一遍的变更点合并到当前文件
* dp 把当前的变更合并到另一个文件
* 使用:Gwrite命令将当前文件写入Git索引。
* 使用:Gread命令将Git索引中的内容读入当前文件。

后面这两个命令不怎么常用。

#### 14.2.2 修改点的跳转

主要是`gitgutter`插件的功能。

`]c` 跳转到下一个修改。

`[c` 跳转到上一个修改。

#### 14.2.3 如何实现预览所有的变更

如果想看有哪些文件改动，使用：`Git difftool --name-only`，或者`Git difftool --name-status`。具体见`fugitive`插件的帮助文档。

如果是想看所有的变更，使用：`Git difftool -y`，所有的变更都会以新的`TAB`页方式打开。

这两组命令后面也可以跟具体的参数，比如某个`commit id`或者是某个分支名，如果没有参数，默认当前分支最新比较。

## 15 调试

### 15.1 vimspector方案

### 15.2 安装vimspector插件

去插件的[官方主页](https://github.com/puremourning/vimspector)，然后用插件管理器安装。

### 15.3 安装需要的调试适配器

(1). 安装某种语言的调试适配器

这里以 **C** 语言举例：

```vim
:VimspectorInstall vscode-cpptools
```

具体支持的语言和需要发送的参数，看[这个链接](https://github.com/puremourning/vimspector#supported-languages)。

这个安装的时间可能会长一点，请耐心等待。

其它语言的可以去插件的主页查看。如果后续需要更新安装的这些适配器，使用下面的命令更新：

```vim
:VimspectorUpdate
```

(2). 配置适配器对应的快捷键

官方提供了两套快捷键方案：

```vim
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
```

我们使用第一种，把它配置到`vimcrc`中。


(3). 调试适配器的配置

这个配置在上面我们安装和打开对某个语言的支持的时候就已经设置好，存放在`your-path-to-vimspector/gadgets/linux/.gadgets.json`文件中，文件中的内容大致如下：

```json
{
  "adapters": {
    "vscode-cpptools": {
      "attach": {
        "pidProperty": "processId",
        "pidSelect": "ask"
      },
      "command": [
        "${gadgetDir}/vscode-cpptools/debugAdapters/OpenDebugAD7"
      ],
      "name": "cppdbg"
    }
  }
}
```

既然它已经配置好，那么我们不去管它。其它的详细可以查看[这里](https://www.cnblogs.com/kongj/p/12831690.html)。如果不进行远程调试，一般情况下不需要修改默认配置。

(4). 调试会话配置

项目调试会话文件位于以下两个位置：

* `<your-path-to-vimspector>/configurations/<os>/<filetype>/*.json`，比如在我的电脑上就是：`C:\Users\pc\.vim\plugged\vimspector\configurations\windows\C\vimspector.json`
* 项目根目录中的 `.vimspector.json`

项目根目录下的文件的优先级比插件根目录下的权限高。


(5). 调试会话配置的相关选项

```txt
vimspector.json 中只能包含一个对象，其中包含以下子对象：

adapters：调试适配器配置，如果不是进行远程调试，一般不需要设置
configurations：调试程序时的配置
configurations主要包含以下以下字段：

adapter:使用的调试配置器名称，该名称必须出现在adapters块或其他调试适配器配置中。

variables：用户定义的变量
configuration：配置名，如configuration1
remote-request,remote-cmdLine：远程调试使用
其中adapter和configuration是必须的。

configuration需要包含的字段和使用的 DAP 有关，我使用vscode-cpptools。configuration必须包含以下字段：

request：调试的类型，lauch或attach
type：cppdgb(GDB/LLDB)或cppvsdbg(Visutal Studio Windows debugger)
除了以上的选项，还可以设置程序路径、参数、环境变量、调试器路径等，更详细的信息可以查看 vscode-cpptools 文档launch-json-reference。

上面的选项构成了 vimspector 配置文件的主体框架，完整的选项参考vimspector.schema.json。
```

完整的选项参考可以看这个范例：[vimspector范例](https://puremourning.github.io/vimspector/schema/vimspector.schema.json)

关于`C`语言的配置，可以在[这里](https://ljqaq233.github.io/2023/04/21/VimSpector_Intro_and_Use/)找到一个范例。

```json
{
  "configurations": {
    "Launch": {
      "adapter": "vscode-cpptools",
      "configuration": {
        "request": "launch",
        "program": "E:\\code\\C\\helloworld.exe", // 要调试的可执行文件路径
      }
    }
  }
}

```
(6). 调试快捷键备忘

```txt
F5	<Plug>VimspectorContinue	When debugging, continue. Otherwise start debugging.
F3	<Plug>VimspectorStop	Stop debugging.
F4	<Plug>VimspectorRestart	Restart debugging with the same configuration.
F6	<Plug>VimspectorPause	Pause debuggee.
F9	<Plug>VimspectorToggleBreakpoint	Toggle line breakpoint on the current line.
<leader>F9	<Plug>VimspectorToggleConditionalBreakpoint	Toggle conditional line breakpoint or logpoint on the current line.
F8	<Plug>VimspectorAddFunctionBreakpoint	Add a function breakpoint for the expression under cursor
<leader>F8	<Plug>VimspectorRunToCursor	Run to Cursor
F10	<Plug>VimspectorStepOver	Step Over
F11	<Plug>VimspectorStepInto	Step Into
F12	<Plug>VimspectorStepOut	Step out of current function scope
```

这套快捷键有个问题是把我当前配置中的某些默认配置覆盖了。


## 16 代码智能建议

vim有`copilot.vim`插件。使用插件管理器安装完成后需要进行设置。

```vim
:Copilot setup
```
设置过程中会登录浏览器，然后弹出双向校验。双向校验完成后，会在`gvim`的命令栏弹出一个 **8位数** 的校验码，这个校验码需要回填回浏览器，然后本地的`Copilot`插件就被授权了。

但是即使配置了这个，也还不能直接使用`Copilot`功能，因为`github`上还需要被授权。也就是在`github`上需要订阅相关的服务。由于当前并没有大量的编码需求，暂时不订阅了。



