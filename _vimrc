"
" VIM使用最大原则(只要功能够用就不要折腾,不要轻易更新.时间要花在对的事情上)
" ------------------------------------------------------------------------------
"       o
"       o                ooooooooo
"       o      ooooo     o       o
"      oooooo  o   o     o       o
"      o  o    o   o     o       o
"     o   o    o   o     o       o
"         o    o   o     ooooooooo
"         o    o   o         o
"     oooooooo o   o         o
"         o    o   o     o   o
"        o o   o   o     o   oooooo
"        o o   o   o     o   o
"       o   o  ooooo    o o  o
"       o   o  o   o    o  o o
"      o    o          o    ooooooooo
"     o               o
" ------------------------------------------------------------------------------
" Vim with all enhancements
source $VIMRUNTIME/vimrc_example.vim

" Remap a few keys for Windows behavior
source $VIMRUNTIME/mswin.vim

let s:vimrc_dir = fnamemodify($MYVIMRC, ':h')
function! SourceVimrcLocal(file)
    execute 'source ' . s:vimrc_dir . '/' . a:file
endfunction

" 注意: s: 脚本作用域的变量不会共享
call SourceVimrcLocal('diff.vim')
call SourceVimrcLocal('common.vim')
call SourceVimrcLocal('global_setting.vim')
call SourceVimrcLocal('plugins.vim')
call SourceVimrcLocal('marks.vim')
call SourceVimrcLocal('tabs.vim')
call SourceVimrcLocal('files.vim')
call SourceVimrcLocal('surround.vim')
call SourceVimrcLocal('debug.vim')
call SourceVimrcLocal('translate.vim')
call SourceVimrcLocal('markup.vim')
runtime macros/matchit.vim             " 括号自动配对
call SourceVimrcLocal('search.vim')
call SourceVimrcLocal('alignment.vim')
call SourceVimrcLocal('motion.vim')
call SourceVimrcLocal('complete.vim')
call SourceVimrcLocal('window.vim')
call SourceVimrcLocal('terminal.vim')
call SourceVimrcLocal('font.vim')
call SourceVimrcLocal('edit.vim')
call SourceVimrcLocal('cmdline.vim')
call SourceVimrcLocal('quickfix.vim')
call SourceVimrcLocal('lint.vim')
call SourceVimrcLocal('tags.vim')
call SourceVimrcLocal('git.vim')
call SourceVimrcLocal('display.vim')
call SourceVimrcLocal('project.vim')
call SourceVimrcLocal('snippet.vim')
call SourceVimrcLocal('draw.vim')
call SourceVimrcLocal('popup.vim')
call SourceVimrcLocal('jump.vim')
call SourceVimrcLocal('slide.vim')
call SourceVimrcLocal('toolbar.vim')
call SourceVimrcLocal('zim.vim')
call SourceVimrcLocal('whichkey.vim')
call SourceVimrcLocal('post.vim')

