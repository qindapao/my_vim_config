
" =====================File: plugins.vim {======================= 插件加载 =============================================

" 加载插件前指定coc配置文件路径不使用默认的
let g:coc_config_home = $VIM


" 插件 {
call plug#begin('~/.vim/plugged')

" 这个补全插件的位置最好放置到最前面,目前不直到原因
Plug 'qindapao/gtagsomnicomplete', {'branch': 'for_use'}                       " gtags完成插件
" Plug 'qindapao/vim-guifont'                                                    " 灵活设置字体大小
Plug 'qindapao/nerdtree'                                                       " 文件管理器
Plug 'qindapao/nerdtree-git-plugin'                                            " nerdtree中显示git变化
Plug 'qindapao/vim-surround'                                                   " 单词包围
Plug 'qindapao/vim-repeat'                                                     " vim重复插件,可以重复surround的内容
" 暂时用不着
" Plug 'WolfgangMehner/bash-support'                                           " bash开发支持
Plug 'qindapao/auto-pairs'                                                     " 插入模式下自动补全括号
Plug 'qindapao/ale'                                                            " 异步语法检查和自动格式化框架
Plug 'itchyny/lightline.vim'                                                   " 不卡顿的状态栏插件
Plug 'qindapao/tabular'                                                        " 自动对齐插件
" 下面两个插件任选其一
" Plug 'qindapao/indentLine'                                                    " 对齐参考线插件
Plug 'qindapao/vim-indent-guides'                                              " 使用高亮而不是字符来对齐参考线
Plug 'qindapao/vim-fugitive'                                                   " vim的git集成插件
Plug 'qindapao/vim-rhubarb'                                                    " 用于打开gi的远程
" 这个插件功能和vim-flog重复,先屏蔽
" Plug 'junegunn/gv.vim'                                                         " git树显示插件
Plug 'qindapao/vim-flog'                                                       " 显示漂亮的git praph插件
" 如果编辑的是远程文件或者是编辑的文件很大，下面这个插件都会很卡
" 所以默认加载插件后禁用，然后需要的时候手动打开和关闭 ggo ggc
Plug 'qindapao/vim-gitgutter'                                                  " git改变显示插件
Plug 'qindapao/vimcdoc'                                                        " vim的中文文档
if expand('%:e') ==# 'txt' || expand('%:e') ==# 'md' || expand('%:e') ==# 'adoc'
    " 这里要注意下,这个插件会导致preview预览涂鸦窗口无法关闭,影响自定义补全
    Plug 'qindapao/completor.vim'                                              " 主要是用它的中文补全功能
else
    " 这里必须使用realese分支,不能用master分支,master分支需要自己编译
    Plug 'qindapao/coc.nvim', {'branch': 'release'}
endif
Plug 'qindapao/vim-gutentags'                                                  " gtags ctags自动生成插件
Plug 'qindapao/gutentags_plus'                                                 " 方便自动化管理tags插件
" 这个插件在大文件的时候也非常卡
Plug 'qindapao/tagbar'                                                         " 当前文件的标签浏览器
Plug 'qindapao/vim-bookmarks'                                                  " vim的书签插件
" 另外一个标记管理器(这个是标记并不是书签,书签是持久化的,这个不是,并且只能字母,所以需要和书签配合起来使用)
Plug 'qindapao/vim-highlighter'                                                " 多高亮标签插件

Plug 'qindapao/vim-table-mode'                                                 " 表格模式编辑插件
Plug 'qindapao/LeaderF'                                                        " 模糊搜 索插件
Plug 'qindapao/ctrlsf.vim'                                                     " 全局搜 索替换插件
" 有ctrlsf插件够用,这个功能重复
" Plug 'brooth/far.vim'                                                          " 另外一个全局替换插件
Plug 'qindapao/vim-terminal-help'                                              " 终端帮助插件
Plug 'qindapao/vim9-stargate'
Plug 'qindapao/vim-commentary'                                                 " 简洁注释
" 按照插件的说明来安装,安装的时候需要稍微等待一些时间,让安装钩子执行完毕
Plug 'qindapao/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
" 这个插件暂时不要,默认的无法高亮就很好,这个反而弄得乱七八糟,这个插件还有个问题是,git对比的时候也弄得乱七八糟,所以先直接禁用掉
Plug 'qindapao/vim-markdown'                                                   " markdown 增强插件
Plug 'qindapao/img-paste.vim', {'branch': 'for_zim'}                           " markdown 直接粘贴图片
Plug 'qindapao/vim-markdown-toc'                                               " 自动设置标题
Plug 'jszakmeister/markdown2ctags'

" 这个也没啥用,先禁用掉
" Plug 'fholgado/minibufexpl.vim'                                                " buffer窗口
" 最强大的文档插件,暂时屏蔽
" Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
Plug 'qindapao/vim-startify'                                                   " vim的开始页
Plug 'qindapao/vim-lastplace'                                                  " 打开文件的上次位置
Plug 'qindapao/diffchar.vim'                                                   " 更明显的对比
" Plug 'terryma/vim-multiple-cursors'                                            " vim的多光标插件
Plug 'qindapao/vim-visual-multi'                                               " 这个插件比上面插件更轻便更快
" qindapao/colorizer这个插件的性能特别低!暂时不要打开,会导致gvim在处理大文件时候拆分窗口和TAB标签页的处理都非常缓慢
" 暂时可以先屏蔽,等需要显示颜色的时候打开
" Plug 'qindapao/vim-coloresque'                                                 " 这个也是颜色显示插件但是没有性能问题
Plug 'qindapao/vim-indent-object'                                              " 基于缩进的文本对象，用于python等语言
Plug 'qindapao/vim-paragraph-motion'                                           " 增强{  }段落选择的功能,可以用全空格行作为段落
" 这个插件的语法高亮需要说明下,可能是受默认的txt文件的语法高亮的影响
" 所以它的语法高亮的优先级并不高,需要先关闭所有的语法高亮，然后单独打开
" syntax off
" syntax on
" 依次要执行上面两条指令
Plug 'qindapao/vim-zim', {'branch': 'syntax_dev'}                              " 使用我稍微修改过的分支

" 并不需要
" Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny' }
" 用处不大,暂时屏蔽
" Plug 'mbbill/undotree'
Plug 'qindapao/vim-signature'
Plug 'qindapao/QFGrep'                                                         " Quickfix窗口过滤
Plug 'qindapao/traces.vim'                                                     " 搜 索效果显示
" Plug 'qindapao/vim-visual-star-search'                                         " 增强星号搜 索
" 暂时用不上先屏蔽
" Plug 'hari-rangarajan/CCTree'                                                  " C语言的调用树
" 使用下面这个rooter是对的,另外的一个rooter会造成set autochdir命令失效
Plug 'qindapao/vim-rooter'                                                     " root目录设置插件
" Plug 'rhysd/clever-f.vim'                                                      " 聪明的f,这样就不用逗号和分号来重复搜 索字符,它们可以用作别的映射
" 当前这个插件会导致编辑txt和zim文件变得很卡,所以只用于特定的编程语言
" 太卡了先注释吧，编程的时候再放出来(这个很卡的的插件要放出来，不然TAB键无法生效?)
" Plug 'qindapao/ultisnips', { 'for': ['python', 'c', 'sh', 'perl'] }
Plug 'qindapao/vim-snippets'                                                   " 拥有大量的现成代码片段
" Plug 'artur-shaik/vim-javacomplete2'                                           " javac语义补全
Plug 'qindapao/vim-expand-region'                                              " vim的扩展选区插件
" 并不需要
Plug 'qindapao/vimspector'                                                     " 调试插件
" Plug 'github/copilot.vim'                                                    " 智能补全,只是尝试下功能
Plug 'qindapao/winresizer'                                                     " 调整窗口



" 主题相关
Plug 'qindapao/vim', { 'as': 'catppuccin', 'branch': 'qq_modify' }               " catppuccin 主题
Plug 'pbrisbin/vim-colors-off'                                                 " 最简单的主题,所有的高亮基本关闭
Plug 'qindapao/photon.vim'                                                       " 一个极简的漂亮主题
Plug 'qindapao/Lightning', {'branch': 'qq_modify'}
Plug 'nightsense/carbonized'
Plug 'sainnhe/everforest'
Plug 'nikolvs/vim-sunbather'
Plug 'igungor/schellar'
Plug 'Donearm/Laederon'
Plug 'devsjc/vim-jb'

Plug 'qindapao/vim-go'
Plug 'vim-perl/vim-perl'
Plug 'qindapao/vimio'
Plug 'qindapao/vim-which-key'

" vim-go 插件的配置 {
" 修改 GOPATH 目录(目前导致了一些问题先不改)
" let g:go_bin_path = '~\.vim\go\bin' 
" ctrl + x + ctrl + o 触发 Go 语言的全功能补全
" vim-go 插件的配置 }


Plug 'vimwiki/vimwiki'


call plug#end()
" 插件 }

" =====================File: plugins.vim }======================= 插件加载 =============================================

