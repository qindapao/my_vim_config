# vim_notes


<!-- vim-markdown-toc Marked -->

* [1 快捷键整理](#1-快捷键整理)
    - [1.1 窗口和buffer管理](#1.1-窗口和buffer管理)
    - [1.2 vim自带终端操作](#1.2-vim自带终端操作)
    - [1.3 链接](#1.3-链接)
* [2 搜索](#2-搜索)
* [3 tags查找搜索](#3-tags查找搜索)
    - [3.1 gtags](#3.1-gtags)
* [4 leaderf](#4-leaderf)
* [5 替换](#5-替换)
    - [5.1 全局替换](#5.1-全局替换)
* [6 文件操作](#6-文件操作)
    - [6.1 打开历史文件](#6.1-打开历史文件)
* [7 未整理](#7-未整理)
* [8 常用插件操作](#8-常用插件操作)
    - [8.1 surround](#8.1-surround)
    - [8.2 completor 补全插件](#8.2-completor-补全插件)
    - [8.3 coc 补全框架](#8.3-coc-补全框架)
        + [8.3.1 coc框架下的c语言补全](#8.3.1-coc框架下的c语言补全)
* [9 git](#9-git)
    - [9.1 配置终端中使用的git工具](#9.1-配置终端中使用的git工具)
    - [9.2 使用浏览器打开当前文件的远程文件](#9.2-使用浏览器打开当前文件的远程文件)
* [1 vim的自定义函数](#1-vim的自定义函数)
* [2 vscode](#2-vscode)
    - [2.1 easymotion插件的一些说明](#2.1-easymotion插件的一些说明)

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


## 4 leaderf

模糊查找插件，使用前先安装[ripgrep](https://github.com/BurntSushi/ripgrep)

[使用说明](https://retzzz.github.io/dc9af5aa/)

- **特别说明**

如果需要在保持搜索框不自动关闭的情况下能动态打开文件，需要这样发命令:

```vim
:Leaderf rg -F --no-auto-preview --stayOpen -e mouse
```

上面这个命令的意思是：在保持搜索框不自动关闭的情况下，不要显示预览窗口(**如果有预览窗口就无法正常的打开文件！**)，然后正则搜索`mouse`字符串。

- 固定搜索某些目录

`Leaderf rg -e xxx aaa bbb`
在`aaa`和`bbb`目录中搜索xxx字符串。参考`rg`指令的语法。

- 排除掉某些目录

`Leaderf rg -e xxx -g=!src/`

排除掉`src`目录。

- 搜索当前文件中的行

`leaderfLine`


- 进入`leaderf`后的操作

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


- leaderf和gtags的配合

```vim
let g:Lf_CacheDirectory = expand('~')
" vim-gentags和leaderf共享的配置,只能这样配
let g:gutentags_cache_dir = expand(g:Lf_CacheDirectory.'/LeaderF/gtags')         
```

最重要的就是上面的配置，_vimrc中已经说明了，需要和`vim-gutentags`插件公用相关的`gtags`路径，所以只能这样配置。

- leaderf和rg配置搜索字符串时限定文件名过滤

```vim
leaderf rg -f *.py -e xx
```

上面的这句话的意思是在所有`.py`后缀结尾的文件中，正则搜索`xx`字符串。


## 5 替换

### 5.1 全局替换

- 加入参数列表

```txt
: args **/*.txt **/*.py
```

- 对参数列表中的文件进行替换操作

```txt
：argdo %s/hate/love/gc | update
```

>对参数列表中的文件依次把`hata`替换成`love`，并且更新文件，在每次替换前进行手动确认。


## 6 文件操作

### 6.1 打开历史文件

```txt
:browse oldfiles
<ESC>
选择数字
<CR>
```

## 7 未整理

当前操作某些文件会产生 `.stats` 后缀结尾的文件，目前不知道这些文件是怎么产生的。可以通过 `everything` 软件通过正则搜索带`.stats`后缀的文件来统一删除。



**待办的事项**:

:TODO: tabmode插件当前在`markdown`的收缩语法或者是`zimwiki`的收缩语法的时候，留空的宽度是不对的，是按照原有的字符数来留空的，这样语法收缩后会导致无法对齐。这个空了可以优化下，思路是增加一个选项，给定软件留空策略，一共三种：

1. 不留空
2. 以`markdown`语法收缩后作为基准。
3. 以`zimwiki`语法收缩后作为基准。

## 8 常用插件操作

### 8.1 surround

- 如果想在添加的括号后面补一个空格，那么使用前半括号，比如 `ysiw(` ，添加括号后，括号后面会补一个空格。
- 如果不需要空格，使用后半括号，比如 `ysiw)` ，效果就是不会补空格。

### 8.2 completor 补全插件

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

### 8.3 coc 补全框架

目前遇到的问问题是，补全的第一个选项无法选择，都必须通过选择下一个再选择上一个来实现。设置了下面这行也没用。

```vim
let g:coc_snippet_next = '<tab>'
```

#### 8.3.1 coc框架下的c语言补全

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



## 9 git

### 9.1 配置终端中使用的git工具

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

### 9.2 使用浏览器打开当前文件的远程文件

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

## 1 vim的自定义函数

如果想要`vim`调用一个函数而不是输出回车就生效，最好的办法是使用`silent`命令。比如：
```vim
autocmd BufWritePost *.md silent call GenMarkdownSectionNum()
```
## 2 vscode

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
    },
  ]
}
```

上面的配置中，最后面就是关于`vscodevim`插件的配置。

### 2.1 easymotion插件的一些说明

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

