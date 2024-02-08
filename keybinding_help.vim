

let g:key_binding_list = [
\ "滚动操作[n] <c-s-e> 向上平滑单行滚动",
\ "滚动操作[n] <c-s-y> 向下平滑单行滚动",
\ "滚动操作[n] <c-u>   向上滚动半个屏幕",
\ "滚动操作[n] <c-d>   向下滚动半个屏幕",
\ "滚动操作[n] <c-b>   向上滚动整个屏幕",
\ "滚动操作[n] <c-s-f> 向下滚动整个屏幕",
\ "快速移动[n] <c-;>       [vim9-stargate]跳转到当前窗口的某个单词",
\ "快速移动[n] <leader>w   [vim9-stargate]跳转到某个字母指定的分屏",
\ "分屏和窗口操作[n] <leader>ss  上下分屏",
\ "分屏和窗口操作[n] <leader>vv  左右分屏",
\ "分屏和窗口操作[n] <leader>ow  除当前窗口外关闭其他的(only window)",
\ "分屏和窗口操作[n] <leader>cw  关闭当前窗口(close window)",
\ "TAB标签页操作[n] to           只保留当前标签页(tab only)",
\ "TAB标签页操作[n] tc           关闭当前标签页",
\ "TAB标签页操作[n] <Tab>        向前切换标签页",
\ "TAB标签页操作[n] <s-Tab>      向后切换标签页",
\ "TAB标签页操作[n] <alt-1~9>    按照数字切换标签页",
\ "TAB标签页操作[n] <s-Tab>      向后切换标签页",
\ "内置终端[n] <leader>dbt       删除当前的内置终端buffer(delete buffer terminal)",
\ "内置终端[n] <alt-=>           打开和关闭内置终端",
\ "内置终端[t] <alt-->           在默认终端操作界面上把默认寄存器的内容复制进去",
\ "内置终端[t] <Esc>             在默认终端中退出输入模式到普通模式下",
\ "内置终端[t] <ctrl+v>          在默认终端中复制系统剪切板中的内容",
\ "内置终端[t] <ctrl+u>          删除光标位置到行首所有字符",
\ "内置终端[t] <ctrl+w>          删除光标前的一个单词",
\ "内置终端[t] <ctrl+k>          删除光标当前位置到行尾",
\ "内置终端[t] <ctrl+左右方向键> 向前或者向后移动一个单词",
\ "文本对齐[c] :Tabularize /,     [Tabularize]以逗号对齐(也可以是别的符号,符号或者字符可以是多个,这是默认对齐行为)",
\ "文本对齐[c] :Tabularize /,/r0  [Tabularize]以逗号右对齐(r[right]可以换成l[left] c[center],字母后面的空格表示对齐后补全多少空格)",
\ "文本对齐[c] :h Tabularize      [Tabularize]帮助手册查看",
\ "Git[c]      :Gvdiffsplit       [vim-fugitive]左右对比当前文本和最新提交的改变(后面可以跟参数也可以不跟,跟参数表示和特定git对象比较,比如commit id或者分支名或者其它)",
\ "Git[n]      <leader>gitda      [vim-fugitive]和最新提交对比所有变更(git diff all)",
\ "Git[c]      :h fugitive        [vim-fugitive]帮助手册查看",
\ 'git[t]      git fetch upstream             获取上游分支所有变更',
\ 'git[t]      git merge upstream/mian        合并上游分支的变更到本地分支',
\ "标记[n]  [signature]\n\
  \:h signature 帮助手册查看\n\
  \mx           Toggle mark 'x' and display it in the leftmost column\n\
  \dmx          Remove mark 'x' where x is a-zA-Z\n\
  \m,           Place the next available mark\n\
  \m.           If no mark on line, place the next available mark. Otherwise,\n\
  \             remove (first) existing mark.\n\
  \m-           Delete all marks from the current line\n\
  \m<Space>     Delete all marks from the current buffer\n\
  \]`           Jump to next mark\n\
  \[`           Jump to prev mark\n\
  \]'           Jump to start of next line containing a mark\n\
  \['           Jump to start of prev line containing a mark\n\
  \`]           Jump by alphabetical order to next mark\n\
  \`[           Jump by alphabetical order to prev mark\n\
  \']           Jump by alphabetical order to start of next line having a mark\n\
  \'[           Jump by alphabetical order to start of prev line having a mark\n\
  \m/           Open location list and display marks from current buffer\n\
  \m[0-9]       Toggle the corresponding marker !@#$%^&*()\n\
  \m<S-[0-9]>   Remove all markers of the same type\n\
  \]-           Jump to next line having a marker of the same type\n\
  \[-           Jump to prev line having a marker of the same type\n\
  \]=           Jump to next line having a marker of any type\n\
  \[=           Jump to prev line having a marker of any type\n\
  \m?           Open location list and display markers from current buffer\n\
  \m<BS>        Remove all markers\n",
\ "日志定位[c] :messages clear           清除vim所有的messages日志",
\ '查找  ctrlsf 按键映射           直接 ctrl + shift + c，然后搜索ctrlsf即可',
\ "文件比较 \n\
\在Vim中，你可以使用以下方法来对比两个文件：\n\
\使用Vim的比较模式打开两个文件：\n\
\vim -d file1 file2\n\
\或者\n\
\vimdiff file1 file2\n\
\如果已经打开了文件file1，再打开另一个文件file2进行比较：\n\
\:vert diffsplit file2\n\
\如果没有用vert命令，diffsplit则会分上下两个窗口。\n\
\如果已经用split方式打开了两个文件file1，file2，又想比较两文件的不同。分别在两个窗口里面输入命令：\n\
\:diffthis\n\
\如果更改了某个窗口的内容，vim又没有自动更新diff检查，可以使用如下命令更新：\n\
\:diffupdate\n\
\定位到不同点：\n\
\[c 跳到前一个不同点\n\
\]c 跳到后一个不同点\n\
\合并文档：\n\
\dp 将差异点的当前文档内容应用到另一文档（diff put）\n\
\do 将差异点的另一文档的内容拷贝到当前文档（diff get）",
\'gtags ctrl + shift + c 后弹出框搜索 gscope即可',
\]

