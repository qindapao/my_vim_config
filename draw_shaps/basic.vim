function! GenerateLeftRightTriangle(index)
    " .   .    .   
    " |\  |\   |\  
    " '-' | \  | \ 
    "     '--' |  \
    "          '---'
    let triangle = []
    call add(triangle, '.')
    for j in range(0, a:index)
        call add(triangle, '|' . repeat(' ', j) . '\')
    endfor
    call add(triangle, "'" . repeat('-', a:index+1) . "'")
    
    return triangle
endfunction

" :TODO: 还有3种三角形
"              . 
"        .    /| 
"   .   /|   / | 
"  /|  / |  /  | 
" '-' '--' '---' 
" .-.  .--. .---.
"  \|   \ |  \  |
"   '    \|   \ |
"         '    \|
"               '
"  .-. .--. .---.
"  |/  | /  |  / 
"  '   |/   | /  
"      '    |/   
"           '    


" :TODO: 空了再实现吧,这个图形还有点麻烦
function! GenerateSixPointedStar(index)
    "  __/\__       /\                /\         
    "  \    /  ____/  \____          /  \        
    "  /_  _\  \          /   ______/    \______ 
    "    \/     \        /    \                / 
    "           /        \     \              /  
    "          /___    ___\     \            /   
    "              \  /         /            \   
    "               \/         /              \  
    "                         /_____      _____\ 
    "                               \    /       
    "                                \  /        
    "                                 \/         
    let six_pointed_star = []
    let range = a:index
endfunction


" https://waylonwalker.com/drawing-ascii-boxes/
function! GenerateUpTriangle(index)
    "   .      .       .
    "  / \    / \     / \
    " '---'  /   \   /   \
    "       '-----' /     \
    "              '-------'
    let i = a:index + 1

    let triangle = []
    call add(triangle, repeat(' ', i+1) . '.' . repeat(' ', i+1))
    for j in range(1, i)
        call add(triangle, repeat(' ', i-j+1) . '/' . repeat(' ', j*2-1) . '\')
    endfor
    call add(triangle, "'" . repeat('-', 2*i+1) . "'")

    return triangle
endfunction


function! GenerateDownTriangle(index)
    " .---. .-----. .-------.
    "  \ /   \   /   \     / 
    "   '     \ /     \   /  
    "          '       \ /   
    "                   '    
    let i = a:index + 1

    let width = i * 2 + 1
    let triangle = []
    call add(triangle, '.' . repeat('-', width) . '.')
    for j in range(1, i)
        call add(triangle, repeat(' ', j) . '\' . repeat(' ', width - 2 * j) . '/')
    endfor
    call add(triangle, repeat(' ', i + 1) . "'")

    return triangle
endfunction

function! GenerateHexagon(index)
    "    ____
    "   / __ \
    "  / /  \ \
    "  \ \__/ /
    "   \____/
    let i = a:index + 1

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

    return hexagon
endfunction

function! GenerateProcessRight(row_index, col_index)
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
    let i = a:row_index
    let j = a:col_index

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

    return process_right
endfunction

function! GenerateProcessLeft(row_index, col_index)
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
    let i = a:row_index
    let j = a:col_index

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

    return process_left
endfunction

function! GenerateIfBox(row_index, col_index)
    "
    "    .-.    .--.
    "   (   )  (    )
    "    '-'    '--'
    "  .-.       .--.  
    " /   \     /    \     
    "(     )   (      )                
    " \   /     \    / 
    "  '-'       '--'  
    let i = a:row_index + 1
    let j = a:col_index + 1

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

    return if_box
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
    let i = a:radius + 1
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

    return rhombus
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
    \ 'value': 'GenerateDownTriangle'
    \ },
    \ {
    \ 'index': a:indexes[2],
    \ 'step': [1, 1],
    \ 'value': 'GenerateUpTriangle'
    \ },
    \ {
    \ 'index': a:indexes[3],
    \ 'step': [1, 1],
    \ 'value': 'GenerateRhombus'
    \ },
    \ {
    \ 'index': a:indexes[4],
    \ 'step': [1, 1],
    \ 'value': 'GenerateHexagon'
    \ },
    \ {
    \ 'index': a:indexes[5],
    \ 'step': [1, 30],
    \ 'value': 'GenerateProcessRight'
    \ },
    \ {
    \ 'index': a:indexes[6],
    \ 'step': [1, 30],
    \ 'value': 'GenerateProcessLeft'
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
    \ 'value': 'GenerateIfBox'
    \ },
    \ {
    \ 'index': a:indexes[10],
    \ 'step': [1, 1],
    \ 'value':  [l:fill_box_1]
    \ },
    \ {
    \ 'index': a:indexes[11],
    \ 'step': [1, 1],
    \ 'value': 'GenerateLeftRightTriangle'
    \ },
    \ {
    \ 'index': a:indexes[12],
    \ 'step': [1, 1],
    \ 'value': [ ['✓'], ['✔'], ['✗'], ['✘'], ['☐'], ['☑'], ['☒'], ['□'], ['■'], ['○'], ['●'], ['∨'] ]
    \ },
    \ {
    \ 'index': a:indexes[13],
    \ 'step': [1, 1],
    \ 'value': [ ['▀'], ['▁'], ['▂'], ['▃'], ['▄'], ['▅'], ['▆'], ['▇'], ['█'], ['▉'], ['▊'], ['▋'], ['▌'], ['▍'], ['▎'], ['▏'],
    \            ['▐'], ['░'], ['▒'], ['▓'], ['▔'], ['▕'], ['▖'], ['▗'], ['▘'], ['▙'], ['▚'], ['▛'], ['▜'], ['▝'], ['▞'], ['▟'] ] 
    \ },
    \ ],
    \ {
    \ 'index': a:indexes[14],
    \ 'step': [1, 1],
    \ 'value': [ ['▫'], ['◖'], ['◗'], ['▪'], ['◤'], ['◥'], ['◢'], ['◣'] ]
    \ },
    \ }

" " 取消所有的子函数节省内存(这一步当前不需要了,函数用于动态生成图形)
" delfunction! GenerateDownTriangle
" ... ...

endfunction


