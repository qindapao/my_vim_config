# vim_notes

[TOC]

## 快捷键整理

### 窗口和buffer管理

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

- 在NERD_tree插件的窗口中

按 `m` 然后等待一会儿，会出现文件操作的小窗口，可以对文件进行重命名或者删除添加复制等操作。

### vim自带终端操作

也是由于 `terminal_help` 插件的关系 ，所以拷贝字符到终端的操作方式发生变化。

- `ctrl shift - " 0` 5个键表示复制复制寄存器中的值到终端窗口

## 搜索

- 递归搜索当前目录以及所有子目录并quickfix打开

`: vim /string/ ** | copen`

如果是想指定文件类型，那么可以：
`: vim /string/ **/*.txt **/*.py | copen`
>查找当前目录以及子目录下的所有的txt和py后缀文件。

- 搜索的时候排除不需要关注的目录

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

- 忽略大小写

`\c`

`:vim /\cxx/ %`

>在当前文件中查找`xx`，并忽略大小写。

- vimgrep是可以搜索软链接目录的

## tags查找搜索

### gtags

** 完整的命令：**
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

就是查询了几次后，会在项目的目录下生成`.stats`后缀的文件。具体原因不明，目前的解决方案是，在项目的根目录下执行删除命令:

`find . -name "*.stats" | xargs rm -f`

删除前最好是用`find . -name "*.stats"`命令查询下需要删除的文件是否都是它们，不要误删除。

更完整的说明可以看这里：
https://github.com/skywind3000/gutentags_plus


## leaderf

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


## 替换

### 全局替换

- 加入参数列表

```txt
: args **/*.txt **/*.py
```

- 对参数列表中的文件进行替换操作

```txt
：argdo %s/hate/love/gc | update
```

>对参数列表中的文件依次把`hata`替换成`love`，并且更新文件，在每次替换前进行手动确认。


## 文件操作

### 打开历史文件

```txt
:browse oldfiles
<ESC>
选择数字
<CR>
```

## 未整理

- 当前操作某些文件会产生 `.stats` 后缀结尾的文件，目前不知道这些文件是怎么产生的。可以通过 `everything` 软件通过正则搜索带 `.stats` 后缀的文件来统一删除。

## 常用插件操作

### surround

- 如果想在添加的括号后面补一个空格，那么使用前半括号，比如 `ysiw(` ，添加括号后，括号后面会补一个空格。
- 如果不需要空格，使用后半括号，比如 `ysiw)` ，效果就是不会补空格。

### completor 补全插件

补全插件遇到文件名中有特殊字符，比如 `@ ! # *` 等，是无法正常补全的。

### coc 补全框架

目前遇到的问问题是，补全的第一个选项无法选择，都必须通过选择下一个再选择上一个来实现。设置了下面这行也没用。

```vim
let g:coc_snippet_next = '<tab>'
```

