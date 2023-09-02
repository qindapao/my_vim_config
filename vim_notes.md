# 全局搜索

- 递归搜索当前目录以及所有子目录并quickfix打开

: vim /string/ ** | copen


# tags查找

## gtags

Command
:GscopeFind {querytype} {name}
Perform a cscope search and take care of database switching before searching.

{querytype} corresponds to the actual cscope line interface numbers as well as default nvi commands:

0 or s: Find this symbol
1 or g: Find this definition
2 or d: Find functions called by this function
3 or c: Find functions calling this function
4 or t: Find this text string
6 or e: Find this egrep pattern
7 or f: Find this file
8 or i: Find files #including this file
9 or a: Find places where this symbol is assigned a value

<leader>cs	Find symbol (reference) under cursor
<leader>cg	Find symbol definition under cursor
<leader>cd	Functions called by this function
<leader>cc	Functions calling this function
<leader>ct	Find text string under cursor
<leader>ce	Find egrep pattern under cursor
<leader>cf	Find file name under cursor
<leader>ci	Find files #including the file name under cursor
<leader>ca	Find places where current symbol is assigned
<leader>cz	Find current word in ctags database


Troubleshooting
ERROR: gutentags: gtags-cscope job failed, returned: 1
step1: add the line below to your .vimrc:

let g:gutentags_define_advanced_commands = 1
step2: restart vim and execute command:

:GutentagsToggleTrace
step3: open some files and generate gtags again with current project:

:GutentagsUpdate
step4: you may see a lot of gutentags logs, after that:

:messages
To see the gtags log.

https://github.com/skywind3000/gutentags_plus

# 文件操作

## 打开历史文件

```txt
:browse oldfiles
<ESC>
选择数字
<CR>
```



