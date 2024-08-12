
function! DefineSmartDrawShapesBasic(indexes, index)
    let l:circle1 =<< EOF
 _
( )
 '
EOF

    let l:circle2 =<< EOF
 .-.
(   )
 '-'
EOF

    let l:circle3 =<< EOF
 .---.
(     )
 '---'
EOF

    let l:circle4 =<< EOF
    _.---._
 .''       ''.
:             :
|             |
:             :
 '..       ..'
    '-...-'
EOF

    let l:triangle1 =<< EOF
.---.
 \ /
  '
EOF

    let l:triangle2 =<< EOF
.-----.
 \   /
  \ /
   '
EOF


    let l:triangle3 =<< EOF
.-------------.
 \           /
  \         /
   \       /
    \     /
     \   /
      \ /
       '
EOF

    let l:rhombus1 =<< EOF
   ,',
 ,'   ',
:       :
 ',   ,'
   ','
EOF

    let l:rhombus2 =<< EOF
       ,',
     ,'   ',
   ,'       ',
 ,'           ',
:               :
 ',           ,'
   ',       ,'
     ',   ,'
       ','
EOF

    let l:rhombus3 =<< EOF
               ,',
             ,'   ',
           ,'       ',
         ,'           ',
       ,'               ',
     ,'                   ',
   ,'                       ',
 ,'                           ',
:                               :
 ',                           ,'
   ',                       ,'
     ',                   ,'
       ',               ,'
         ',           ,'
           ',       ,'
             ',   ,'
               ','
EOF

let g:SmartDrawShapes = {'set_index': a:index, 'value': [
    \ {
    \ 'index': a:indexes[0],
    \ 'value': [ l:circle1, l:circle2, l:circle3, l:circle4 ]
    \ },
    \ {
    \ 'index': a:indexes[1],
    \ 'value': [ l:triangle1, l:triangle2, l:triangle3 ]
    \ },
    \ {
    \ 'index': a:indexes[2],
    \ 'value': [ l:rhombus1, l:rhombus2, l:rhombus3 ]
    \ }
    \ ],
    \ }
endfunction

