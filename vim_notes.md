# 搜索

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

# tags查找搜索

## gtags

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

就是查询了几次后，会在项目的目录下生成`.stats`后缀的文件。具体原因不明，目前的解决方案是，在项目的根目录下执行删除命令:

`find . -name "*.stats" | xargs rm -f`

删除前最好是用`find . -name "*.stats"`命令查询下需要删除的文件是否都是它们，不要误删除。

更完整的说明可以看这里：
https://github.com/skywind3000/gutentags_plus


# leaderf

模糊查找插件，使用前先安装[ripgrep](https://github.com/BurntSushi/ripgrep)

[使用说明](https://retzzz.github.io/dc9af5aa/)

- **特别说明**

如果需要在保持搜索框不自动关闭的情况下能动态打开文件，需要这样发命令:

```
:Leaderf rg -F --no-auto-preview --stayOpen -e mouse
```

上面这个命令的意思是：在保持搜索框不自动关闭的情况下，不要显示预览窗口(**如果有预览窗口就无法正常的打开文件！**)，然后正则搜索`mouse`字符串。


- 固定搜索某些目录

`Leaderf rg -e xxx aaa bbb`
在`aaa`和`bbb`目录中搜索xxx字符串。参考`rg`指令的语法。

- 排除掉某些目录

`Leaderf rg -e xxx -g=!src/`

排除掉`src`目录。


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

# 替换

## 全局替换

- 加入参数列表

```txt
: args **/*.txt **/*.py
```

- 对参数列表中的文件进行替换操作

```txt
：argdo %s/hate/love/gc | update
```

>对参数列表中的文件依次把`hata`替换成`love`，并且更新文件，在每次替换前进行手动确认。




# 文件操作

## 打开历史文件

```txt
:browse oldfiles
<ESC>
选择数字
<CR>
```



