
" =====================File: zim.vim {======================= zim 特殊 =========

" ----------------------------------------------------------------------------

" 智能绘图的zim markup模式
" {
" ▫gge▫ 这个代表行内代码 ''行内代码''
" ▪gge▪ 这个代表高亮 **加粗**
" ◖gge◗ 这个代表高亮 __高亮__
" ◤gge◥ 这个代表斜体 //斜体//
" ◢gge◣ 这个代表删除线 ~~删除线~~

" :TODO: 文本中的zim链接和锚点(非自定义链接和锚点)
" 用一组特殊的符号和文本来表示
" 符号和对应的文本记录上每个链接对应的值,用于替换符号组的时候还原
" 这里要特别小心，怎么才能防止链接丢失？
" :TODO: 需要5个增加markup的快捷方式
" 需要一个增加链接的快捷方式(在底部的输入位置输入链接和现实的字符，生成符号组,如果符号超过限制)
" :TODO: zim内部锚点如何处理?vim中很好处理，但是在zim中那个锚点的贴图无法对齐。

let g:zim_inner_links = {}
" zim软件中锚点的文件是 zim\share\zim\pixmaps\pilcrow.png 这是一个png的图像,大小是固定的
" 但是代码中会缩放它，所以直接替换它是没有意义的
" 但是在 D:\programs\config\zim\style.conf中可以配置图标的大小
" [TextView]
" bullet_icon_size=GTK_ICON_SIZE_LARGE_TOOLBAR
" indent=30
" tabs=None
" ... ...
"
" 图标的大小可以配置的值有下面这些
" GTK_ICON_SIZE_MENU：适用于菜单中的图标，大小为 16 像素。
" GTK_ICON_SIZE_SMALL_TOOLBAR：适用于小工具栏的图标，大小为 16 像素。
" GTK_ICON_SIZE_LARGE_TOOLBAR：适用于大工具栏的图标，大小为 24 像素。
" GTK_ICON_SIZE_BUTTON：适用于按钮的图标，大小为 16 像素。
" GTK_ICON_SIZE_DND：适用于拖放操作的图标，大小为 32 像素。
" GTK_ICON_SIZE_DIALOG：适用于对话框的图标，大小为 48 像素。
"
"
" 然后我发现一个有趣的事情，当把图标的大小设置为GTK_ICON_SIZE_LARGE_TOOLBAR的时候，
" 字体为 MSYH ProgmataPro Mono Normal 9号的时候，正好图标占据4个字符的位置，可以完美对齐。
" 但是有锚点的列就会比别的列要高，显得有点奇怪
"
" 或者把图标的大小设置为GTK_ICON_SIZE_BUTTON,这个时候需要把MSYH ProgmataPro Mono Normal
" 字体设置为12号字体，这样锚点图标刚才占据了两个字符的空间。这或许更好。
" 如果把字体调整为6号，那么锚点占据4个字符
"
" zim的锚点导出还有问题，导出后的文本无法链接,所以干脆全部用我自己定义锚点更好。
" :TODO:还是应该把emacs的锚点导航两个功能实现
" 还有一个办法，如果要导出到html,可以用vim先处理下当前文件中的锚点。然后再显示或者打印
" 如果不想显示又可以用vim方便还原。
"

" ----------------------------------------------------------------------------

function! DeleteAndReplaceZimMarkupCharsForBuffer()
    " 获取当前缓冲区的所有行数
    let total_lines = line("$")

    for line_num in range(1, total_lines)
        let line_content = getline(line_num)
        " 不知道为什么 vim不支持正则表达式中使用+,所以这里用了[^'][^']*
        let line_content = substitute(line_content, " ''\\([^'][^']*\\)'' ", '▫\1▫', "g")
        let line_content = substitute(line_content, ' __\([^_][^_]*\)__ ', '◖\1◗', "g")
        let line_content = substitute(line_content, ' \*\*\([^*][^*]*\)\*\* ', '▪\1▪', "g")
        let line_content = substitute(line_content, ' //\([^/][^/]*\)// ', '◤\1◥', "g")
        let line_content = substitute(line_content, ' \~\~\([^~][^~]*\)\~\~ ', '◢\1◣', "g")

        " " 先不考虑链接的情况
        " " 替换两对中括号中间的连接和竖线
        " let line_content = substitute(line_content, "\\[\\[[^|]+|\\([^]]+\\)\\]\\]", "\\1", "g")
        
        " 将替换后的内容设置回当前行
        call setline(line_num, line_content)    
    endfor
endfunction

" ----------------------------------------------------------------------------

function! RecoverZimMarkupCharsForBuffer()
    " 获取当前缓冲区的所有行数
    let total_lines = line("$")

    for line_num in range(1, total_lines)
        let line_content = getline(line_num)
        let line_content = substitute(line_content, '▫\([^▫][^▫]*\)▫', " ''\\1'' ", "g")
        let line_content = substitute(line_content, '◖\([^◖◗][^◖◗]*\)◗', ' __\1__ ', "g")
        let line_content = substitute(line_content, '▪\([^▪][^▪]*\)▪', ' \*\*\1\*\* ', "g")
        let line_content = substitute(line_content, '◤\([^◤◥][^◤◥]*\)◥', ' //\1// ', "g")
        let line_content = substitute(line_content, '◢\([^◢◣][^◢◣]*\)◣', ' \~\~\1\~\~ ', "g")

        " 将替换后的内容设置回当前行
        call setline(line_num, line_content)    
    endfor
endfunction

" :TODO: 增加插入5种符号和链接的快捷键(可视插入,不影响当前列的物理位置排列)
" 算了,不做实现,直接简单的添加到智能图形图中即可

" ----------------------------------------------------------------------------

" 设置快捷键 F12 来交替调用两个函数
nnoremap <silent> sh :call ToggleZimMarkupChars()<CR>

" ----------------------------------------------------------------------------

function! ToggleZimMarkupChars()
    if exists('g:zim_markup_chars_enabled') && g:zim_markup_chars_enabled
        " 如果已启用，执行恢复函数
        call RecoverZimMarkupCharsForBuffer()
        let g:zim_markup_chars_enabled = 0
        echo "已切换到恢复模式"
    else
        " 如果未启用，执行删除和替换函数
        call DeleteAndReplaceZimMarkupCharsForBuffer()
        let g:zim_markup_chars_enabled = 1
        echo "已切换到删除和替换模式"
    endif
endfunction

" }

" ----------------------------------------------------------------------------

" 函数的实现方案如下:
" 如果有锚点,那么连续两次就可以跳转过去
" 使用vim在当前的位置生成一个随机锚点,然后跳转过去
" 锚点的名字可以用当前的时间,这行避免冲突的可能
" 跳转完成后再让vim删除添加的这个临时锚点
" 然后执行zim的刷新功能更新页面,然后往右移动一下光标(:TODO:这里暂时不做自动化,自己按一下ctrl+r刷新下页面)
" :TODO:可以执行一个zim的插件,插件执行刷新当前页面并且把光标往右移动一位的操作
" zim --gui zim_book "项目管理:北辰项目:项目进度整理:5902参数"
" zim --gui zim_book "项目管理:北辰项目:项目进度整理:5902参数#不上次"
function! JumpToZimPagePosition()
    " 生成当前的时间戳
    let timestamp = strftime("%Y%m%d%H%M%S")
    " 当前位置插入临时锚点
    let id_string = "{{id: " . timestamp . "}}"
    execute "normal! i" . id_string    
    " 保存当前文件
    write
    " 获取当前zim日记本的名字(根目录下有.git文件夹或者.root文件,通过这个识别)
    let root_dir = CommonFindRootDir()
    let notebook_name = fnamemodify(root_dir, ':t')
    " 获取笔记本的相对索引
    let relative_path = CommonGetRelationPath()
    " 去掉扩展名.txt
    let relative_path = fnamemodify(relative_path, ':r')
    " /替换成冒号:
    let relative_path = substitute(relative_path, '/', ':', 'g')
    " 通过系统命令打开笔记本实例(多次打开也会在一个实例)
    " zim.exe的路径需要被添加到环境变量中
    let command_str = 'zim --gui ' . notebook_name . ' ' . relative_path . '#' . timestamp
    " vim实例不能关闭,如果关闭了zim也会一起被关闭
    " 这里使用参数就可以保证在一个实例中打开zim(只要保证所有打开实例的根目录相同即可)
    let job_opts = {'cwd': root_dir}
    call job_start(command_str, job_opts)
    sleep 1
    call job_start(command_str, job_opts)
    " 这里靠延时还有有一定的缺陷,因为如果GUI界面还没来得及跳转到锚点,vim就删除锚点,会导致跳转失败
    sleep 3
    " 最后一个步骤,删除添加的临时锚点并保存文件
    let lnum = line('.')
    let current_line = getline(lnum)
    let modified_line = substitute(current_line, '{{id: ' . timestamp . '}}', '', 'g')
    call setline(lnum, modified_line)
    write
    " :TODO: 下面这里似乎无法正常调用,现在并不知道插件调用方法
    " let command_str = 'zim --plugin refresh_and_move --action refresh_and_move'
    " call job_start(command_str, job_opts)
endfunction

" ----------------------------------------------------------------------------

" 跳转到zim的文件和位置
nnoremap <silent> s; :call JumpToZimPagePosition()<CR>

" ----------------------------------------------------------------------------

" =====================File: zim.vim }======================= zim 特殊 =========

