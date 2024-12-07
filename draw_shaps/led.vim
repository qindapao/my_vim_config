
function! DefineSmartDrawShapesLed(indexes, index)
    let l:led1 =<< EOF
 .-.
( ～)
 '-'
EOF

    let l:led2 =<< EOF
  .
 /!\
'---'
EOF

    let l:led3 =<< EOF
 .-. .-.
|   | o |
|.-.|.-.|
EOF

    let l:led4 =<< EOF
 ─╮
╭─┼─╯
  ╰─
EOF

    let l:led5 =<< EOF
 ╭──────╮
[│ + -  │
 ╰──────╯
EOF

    let l:led6 =<< EOF
.---.
|888|
'---'
EOF
    let l:led7 =<< EOF
  .---.
 / .│. \
( (   ) )
 \ '-' /
  '---'
EOF
    let l:led8 =<< EOF
 .-_-.
( (^) )
 '-'\'
EOF

" 其实小类中也可以使用第二个index来切换类别,这样可以用鼠标快速切换
" 这样某些模板相当于有四层
" 1.函数类
" 2.大类
" 3.小类行
" 4.小类每行的列
let g:SmartDrawShapes = {'set_index': a:index, 'value': [
    \ {
    \ 'index': a:indexes[0],
    \ 'step': [1, 1],
    \ 'value': [ l:led1, l:led1, l:led3, l:led4, l:led5, l:led6, l:led7, l:led8 ]
    \ }
    \ ],
    \ }
endfunction


