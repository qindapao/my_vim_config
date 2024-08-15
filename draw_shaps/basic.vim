
" https://waylonwalker.com/drawing-ascii-boxes/
function! GenerateUpTriangles(count)
    "   .      .       .
    "  / \    / \     / \
    " '---'  /   \   /   \
    "       '-----' /     \
    "              '-------'
    let triangles = []
    for i in range(1, a:count)
        let triangle = []
        call add(triangle, repeat(' ', i+1) . '.' . repeat(' ', i+1))
        for j in range(1, i)
            call add(triangle, repeat(' ', i-j+1) . '/' . repeat(' ', j*2-1) . '\')
        endfor
        call add(triangle, "'" . repeat('-', 2*i+1) . "'")
        call add(triangles, triangle)
    endfor

    return triangles
endfunction


function! GenerateDownTriangles(count)
    " .---. .-----. .-------.
    "  \ /   \   /   \     / 
    "   '     \ /     \   /  
    "          '       \ /   
    "                   '    
    let triangles = []
    for i in range(1, a:count)
        let width = i * 2 + 1
        let triangle = []
        call add(triangle, '.' . repeat('-', width) . '.')
        for j in range(1, i)
            call add(triangle, repeat(' ', j) . '\' . repeat(' ', width - 2 * j) . '/')
        endfor
        call add(triangle, repeat(' ', i + 1) . "'")
        call add(triangles, triangle)
    endfor

    return triangles
endfunction

function! GenerateHexagons(count)
    "    ____
    "   / __ \
    "  / /  \ \
    "  \ \__/ /
    "   \____/
    let hexagons = []
    for i in range(1, a:count)
        let hexagon = []
        " 顶部
        call add(hexagon, repeat(' ', i) . repeat('_', i*2))
        " 上半部
        for j in range(1, i)
            call add(hexagon, repeat(' ', i-j) . '/' . repeat(' ', i*2+(j-1)*2) . '\')
        endfor
        " 下半部
        for j in range(1, i-1)
            call add(hexagon, repeat(' ', j-1) . '\' . repeat(' ', i*2+(i-j)*2) . '/')
        endfor

        " 底部边缘
        call add(hexagon, repeat(' ', i-1) . '\' . repeat('_', i*2) . '/')

        call add(hexagons, hexagon)
    endfor

    return hexagons
endfunction

function! GenerateProcessRight(row_count, col_count)
    " __   _____  
    " \ \  \    \ 
    "  ) )  )    )
    " /_/  /____/ 
    " __________   
    " \         \  
    "  \         \ 
    "   )         )
    "  /         / 
    " /_________/  
    let process_rights = []
    for i in range(1, a:row_count)
        for j in range(1, a:col_count)
            let process_right = []
            " 绘制上部
            call add(process_right, repeat('_', j))
            " 绘制上半部
            for k in range(1, i)
                call add(process_right, repeat(' ', k-1) . '\' . repeat(' ', j-1) . '\')
            endfor
            " 绘制中间部分
            call add(process_right, repeat(' ', i) . ')' . repeat(' ', j-1) . ')')
            " 绘制下半部分
            for k in range(1, i-1)
                call add(process_right, repeat(' ', i-k) . '/' . repeat(' ', j-1) . '/')
            endfor
            " 绘制最下面
            call add(process_right, '/' . repeat('_', j-1) . '/')

            call add(process_rights, process_right)
        endfor
    endfor

    return process_rights
endfunction

function! GenerateProcessLeft(row_count, col_count)
    "   __   ___
    "  / /  /  /
    " ( (  (  ( 
    "  \_\  \__\
    "    ___
    "   /  /
    "  /  /
    " (  (
    "  \  \
    "   \__\
    let process_lefts = []
    for i in range(1, a:row_count)
        for j in range(1, a:col_count)
            let process_left = []
            " 上
            call add(process_left, repeat(' ', i+1) . repeat('_', j))
            " 上半
            for k in range(1, i)
                call add(process_left, repeat(' ', i-k+1) . '/' . repeat(' ', j-1) . '/')
            endfor
            " 中间
            call add(process_left, '(' . repeat(' ', j-1) . '(')
            " 下半
            for k in range(1, i-1)
                call add(process_left, repeat(' ', k) . '\' . repeat(' ', j-1) . '\')
            endfor
            " 下
            call add(process_left, repeat(' ', i) . '\' . repeat('_', j-1) . '\')
            call add(process_lefts, process_left)
        endfor
    endfor

    return process_lefts
endfunction

function! GenerateIfBox(row_count, col_count)
    "
    "    .-.    .--.
    "   (   )  (    )
    "    '-'    '--'
    "  .-.       .--.  
    " /   \     /    \     
    "(     )   (      )                
    " \   /     \    / 
    "  '-'       '--'  
    let if_boxs = []
    for i in range(1, a:row_count)
        for j in range(1, a:col_count)
            let if_box = []
            " 上
            call add(if_box, repeat(' ', i) . '.' . repeat('-', j) . '.')
            " 上半
            for k in range(1, i-1)
                call add(if_box, repeat(' ', i-k). '/' . repeat(' ', j+k*2) . '\')
            endfor
            " 中间
            call add(if_box, '(' . repeat(' ', 2*i+j) . ')')
            " 下半
            for k in range(1, i-1)
                call add(if_box, repeat(' ', k) . '\' . repeat(' ', j+(i-k)*2) . '/')
            endfor
            " 下
            call add(if_box, repeat(' ', i) . "'" . repeat('-', j) . "'")
            call add(if_boxs, if_box)
        endfor
    endfor

    return if_boxs
endfunction

function! GenerateRhombus(radius)
    " 3 row 5 col
    "    .'. 
    "   :   :
    "    '.' 
    " 5 row 9 col
    "     .'.  
    "   .'   '. 
    "  :       :
    "   '.   .'
    "     '.'   
    " 7 row 13 col
    "      .'.      
    "    .'   '.    
    "  .'       '.  
    " :           : 
    "  '.       .'  
    "    '.   .'    
    "      '.'      
    " 9 row 17 col
    "       .'.       
    "     .'   '.     
    "   .'       '.   
    " .'           '. 
    ":               :
    " '.           .' 
    "   '.       .'   
    "     '.   .'     
    "       '.'       
    " max_col = 2 * max_row - 1
    let rhombuses = []
    for i in range(1, a:radius)
        let rhombus = []

        " 顶部
        call add(rhombus, repeat(' ', i*2-1) . ".'.")
        " 上半
        for j in range(1, i-1)
            call add(rhombus, repeat(' ', (i-j)*2-1) . ".'" . repeat(' ', j*4-1) . "'.")
        endfor
        " 中间
        call add(rhombus, ':' . repeat(' ', 4*i-1) . ':')
        " 下半
        for j in range(1, i-1)
            call add(rhombus, repeat(' ', 2*j-1) . "'." . repeat(' ', (i-j)*4-1) . ".'")
        endfor
        " 底部
        call add(rhombus, repeat(' ', i*2-1) . "'.'")
        call add(rhombuses, rhombus)
    endfor
         

    return rhombuses
endfunction



function! DefineSmartDrawShapesBasic(indexes, index)
    let l:circle_3x3 =<< EOF
 _
( )
 '
EOF

    let l:circle_3x5 =<< EOF
 .-.
(   )
 '-'
EOF

    let l:circle_3x7 =<< EOF
 .---.
(     )
 '---'
EOF
    let l:circle_7x9 =<< EOF
  .---.
 /     \
:       :
|       |
:       :
 \     /
  '---'
EOF
    let l:circle_7x15 =<< EOF
    _.---._
 .''       ''.
:             :
|             |
:             :
 '..       ..'
    '-...-'
EOF
    let l:circle_9x11 =<< EOF
   .---.
  /     \
 /       \
:         :
|         |
:         :
 \       /
  \     /
   '---'
EOF
    let l:circle_9x15 =<< EOF
    _.---._
  .'       '.
 /           \
:             :
|             |
:             :
 \           /
  '.       .'
    '-...-'
EOF

    let l:circle_9x17 =<< EOF
     _.---._
  .''       ''.
 /             \
:               :
|               |
:               :
 \             /
  '..       ..'
     '-...-'
EOF
    let l:circle_11x21 =<< EOF
      _..---.._
   .''         ''.
  /               \
 /                 \
:                   :
|                   |
:                   :
 \                 /
  \               /
   '..         ..'
      '--...--'
EOF

    let l:circle_11x25 =<< EOF
       _...---..._
    .''           ''.
  .'                 '.
 /                     \
:                       :
|                       |
:                       :
 \                     /
  '.                 .'
    '..           ..'
       '---...---'
EOF
    let l:circle_13x25 =<< EOF
        _..---.._
     .''         ''.
   .'               '.
  /                   \
 /                     \
:                       :
|                       |
:                       :
 \                     /
  \                   /
   '.               .'
     '..         ..'
        '--...--'
EOF
    let l:fill_box_1 =<< EOF
╭─────────────────────╮
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
│ ███████████████████ │
╰─────────────────────╯
EOF
    let l:process_up1 =<< EOF
  /\
 /  \
| /\ |
|/  \|
'    '
EOF
    let l:process_up2 =<< EOF
  /\
 /  \
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up3 =<< EOF
  /\
 /  \
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up4 =<< EOF
  /\
 /  \
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up5 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up6 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up7 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up8 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up9 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF
    let l:process_up10 =<< EOF
  /\
 /  \
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
| /\ |
|/  \|
'    '
EOF

    let l:process_up_1_1 =<< EOF
   .
  / \
 / . \
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_2 =<< EOF
   .
  / \
 /   \
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_3 =<< EOF
   .
  / \
 /   \
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_4 =<< EOF
   .
  / \
 /   \
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_5 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_6 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_7 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_8 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_9 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF
    let l:process_up_1_10 =<< EOF
   .
  / \
 /   \
|     |
|     |
|     |
|     |
|     |
|     |
|     |
|     |
|  .  |
| / \ |
|/   \|
'     '
EOF

    let l:process_down1 =<< EOF
.    .
|\  /|
| \/ |
 \  /
  \/
EOF

    let l:process_down2 =<< EOF
.    .
|\  /|
| \/ |
|    |
 \  /
  \/
EOF
    let l:process_down3 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down4 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down5 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down6 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down7 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down8 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down9 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down10 =<< EOF
.    .
|\  /|
| \/ |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
|    |
 \  /
  \/
EOF
    let l:process_down_1_1 =<< EOF
.     .  
|\   /|  
| \ / |  
 \ ' /   
  \ /    
   '
EOF
    let l:process_down_1_2 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
 \   /   
  \ /  
   '   
EOF
    let l:process_down_1_3 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_4 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_5 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_6 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_7 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_8 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_9 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF
    let l:process_down_1_10 =<< EOF
.     .  
|\   /|  
| \ / |  
|  '  |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
|     |  
 \   / 
  \ /  
   '   
EOF


let g:SmartDrawShapes = {'set_index': a:index, 'value': [
    \ {
    \ 'index': a:indexes[0],
    \ 'step': [1, 1],
    \ 'value': [ l:circle_3x3   , l:circle_3x5   , l:circle_3x7   ,
    \            l:circle_7x9   , l:circle_7x15  ,
    \            l:circle_9x11  , l:circle_9x15  , l:circle_9x17  ,
    \            l:circle_11x21 , l:circle_11x25 , l:circle_13x25
    \ ]
    \ },
    \ {
    \ 'index': a:indexes[1],
    \ 'step': [1, 1],
    \ 'value': GenerateDownTriangles(30)
    \ },
    \ {
    \ 'index': a:indexes[2],
    \ 'step': [1, 1],
    \ 'value': GenerateUpTriangles(30)
    \ },
    \ {
    \ 'index': a:indexes[3],
    \ 'step': [1, 1],
    \ 'value': GenerateRhombus(20)
    \ },
    \ {
    \ 'index': a:indexes[4],
    \ 'step': [1, 1],
    \ 'value': GenerateHexagons(20)
    \ },
    \ {
    \ 'index': a:indexes[5],
    \ 'step': [1, 30],
    \ 'value': GenerateProcessRight(10, 30)
    \ },
    \ {
    \ 'index': a:indexes[6],
    \ 'step': [1, 30],
    \ 'value': GenerateProcessLeft(10, 30)
    \ },
    \ {
    \ 'index': a:indexes[7],
    \ 'step': [1, 10],
    \ 'value': [ l:process_up1, l:process_up2, l:process_up3, l:process_up4,
               \ l:process_up5, l:process_up6, l:process_up7, l:process_up8,
               \ l:process_up9, l:process_up10,
               \ l:process_up_1_1, l:process_up_1_2, l:process_up_1_3, l:process_up_1_4,
               \ l:process_up_1_5, l:process_up_1_6, l:process_up_1_7, l:process_up_1_8,
               \ l:process_up_1_9, l:process_up_1_10]
    \ },
    \ {
    \ 'index': a:indexes[8],
    \ 'step': [1, 10],
    \ 'value': [ l:process_down1, l:process_down2, l:process_down3, l:process_down4,
               \ l:process_down5, l:process_down6, l:process_down7, l:process_down8,
               \ l:process_down9, l:process_down10,
               \ l:process_down_1_1, l:process_down_1_2, l:process_down_1_3, l:process_down_1_4,
               \ l:process_down_1_5, l:process_down_1_6, l:process_down_1_7, l:process_down_1_8,
               \ l:process_down_1_9, l:process_down_1_10]
    \ },
    \ {
    \ 'index': a:indexes[9],
    \ 'step': [1, 30],
    \ 'value': GenerateIfBox(10, 30)
    \ },
    \ {
    \ 'index': a:indexes[10],
    \ 'step': [1, 1],
    \ 'value':  [l:fill_box_1]
    \ },
    \ ],
    \ }

" 取消所有的子函数节省内存
delfunction! GenerateDownTriangles
delfunction! GenerateHexagons
delfunction! GenerateProcessRight
delfunction! GenerateProcessLeft
delfunction! GenerateIfBox
delfunction! GenerateUpTriangles
delfunction! GenerateRhombus

endfunction

