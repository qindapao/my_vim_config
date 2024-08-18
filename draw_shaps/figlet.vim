
function! DefineSmartDrawShapesFiglet(indexes, index)
    let standard_a =<< EOF
   __ _
  / _` |
 | (_| |
  \__,_|
EOF
    let standard_b =<< EOF
  _
 | |__
 | '_ \
 | |_) |
 |_.__/
EOF
    let standard_c =<< EOF
   ___
  / __|
 | (__
  \___|
EOF
    let standard_d =<< EOF
      _
   __| |
  / _` |
 | (_| |
  \__,_|
EOF
    let standard_e =<< EOF
   ___
  / _ \
 |  __/
  \___|
EOF
    let standard_f =<< EOF
   __
  / _|
 | |_
 |  _|
 |_|
EOF
    let standard_g =<< EOF
   __ _
  / _` |
 | (_| |
  \__, |
  |___/
EOF
    let standard_h =<< EOF
  _
 | |__
 | '_ \
 | | | |
 |_| |_|
EOF
    let standard_i =<< EOF
  _
 (_)
 | |
 | |
 |_|
EOF
    let standard_j =<< EOF
    _
   (_)
   | |
   | |
  _/ |
 |__/
EOF
    let standard_k =<< EOF
  _
 | | __
 | |/ /
 |   <
 |_|\_\
EOF
    let standard_l =<< EOF
  _
 | |
 | |
 | |
 |_|
EOF
    let standard_m =<< EOF
  _ __ ___
 | '_ ` _ \
 | | | | | |
 |_| |_| |_|
EOF
    let standard_n =<< EOF
  _ __
 | '_ \
 | | | |
 |_| |_|
EOF
    let standard_o =<< EOF
   ___
  / _ \
 | (_) |
  \___/
EOF
    let standard_p =<< EOF
  _ __
 | '_ \
 | |_) |
 | .__/
 |_|
EOF
    let standard_q =<< EOF
   __ _
  / _` |
 | (_| |
  \__, |
     |_|
EOF
    let standard_r =<< EOF
  _ __
 | '__|
 | |
 |_|
EOF
    let standard_s =<< EOF
  ___
 / __|
 \__ \
 |___/
EOF
    let standard_t =<< EOF
  _
 | |_
 | __|
 | |_
  \__|
EOF
    let standard_u =<< EOF
  _   _
 | | | |
 | |_| |
  \__,_|
EOF
    let standard_v =<< EOF
 __   __
 \ \ / /
  \ V /
   \_/
EOF
    let standard_w =<< EOF
 __      __
 \ \ /\ / /
  \ V  V /
   \_/\_/
EOF
    let standard_x =<< EOF
 __  __
 \ \/ /
  >  <
 /_/\_\
EOF
    let standard_y =<< EOF
  _   _
 | | | |
 | |_| |
  \__, |
  |___/
EOF
    let standard_z =<< EOF
  ____
 |_  /
  / /
 /___|
EOF
    let standard_A =<< EOF
     _
    / \
   / _ \
  / ___ \
 /_/   \_\
EOF
    let standard_B =<< EOF
  ____
 | __ )
 |  _ \
 | |_) |
 |____/
EOF
    let standard_C =<< EOF
   ____
  / ___|
 | |
 | |___
  \____|
EOF
    let standard_D =<< EOF
  ____
 |  _ \
 | | | |
 | |_| |
 |____/
EOF
    let standard_E =<< EOF
  _____
 | ____|
 |  _|
 | |___
 |_____|
EOF
    let standard_F =<< EOF
  _____
 |  ___|
 | |_
 |  _|
 |_|
EOF
    let standard_G =<< EOF
   ____
  / ___|
 | |  _
 | |_| |
  \____|
EOF
    let standard_H =<< EOF
  _   _
 | | | |
 | |_| |
 |  _  |
 |_| |_|
EOF
    let standard_I =<< EOF
  ___
 |_ _|
  | |
  | |
 |___|
EOF
    let standard_J =<< EOF
      _
     | |
  _  | |
 | |_| |
  \___/
EOF
    let standard_K =<< EOF
  _  __
 | |/ /
 | ' /
 | . \
 |_|\_\
EOF
    let standard_L =<< EOF
  _
 | |
 | |
 | |___
 |_____|
EOF
    let standard_M =<< EOF
  __  __
 |  \/  |
 | |\/| |
 | |  | |
 |_|  |_|
EOF
    let standard_N =<< EOF
  _   _
 | \ | |
 |  \| |
 | |\  |
 |_| \_|
EOF
    let standard_O =<< EOF
   ___
  / _ \
 | | | |
 | |_| |
  \___/
EOF
    let standard_P =<< EOF
  ____
 |  _ \
 | |_) |
 |  __/
 |_|
EOF
    let standard_Q =<< EOF
   ___
  / _ \
 | | | |
 | |_| |
  \__\_\
EOF
    let standard_R =<< EOF
  ____
 |  _ \
 | |_) |
 |  _ <
 |_| \_\
EOF
    let standard_S =<< EOF
  ____
 / ___|
 \___ \
  ___) |
 |____/
EOF
    let standard_T =<< EOF
  _____
 |_   _|
   | |
   | |
   |_|
EOF
    let standard_U =<< EOF
  _   _
 | | | |
 | | | |
 | |_| |
  \___/
EOF
    let standard_V =<< EOF
 __     __
 \ \   / /
  \ \ / /
   \ V /
    \_/
EOF
    let standard_W =<< EOF
 __        __
 \ \      / /
  \ \ /\ / /
   \ V  V /
    \_/\_/
EOF
    let standard_X =<< EOF
 __  __
 \ \/ /
  \  /
  /  \
 /_/\_\
EOF
    let standard_Y =<< EOF
 __   __
 \ \ / /
  \ V /
   | |
   |_|
EOF
    let standard_Z =<< EOF
  _____
 |__  /
   / /
  / /_
 /____|
EOF
    let standard_1 =<< EOF
  _
 / |
 | |
 | |
 |_|
EOF
    let standard_2 =<< EOF
  ____
 |___ \
   __) |
  / __/
 |_____|
EOF
    let standard_3 =<< EOF
  _____
 |___ /
   |_ \
  ___) |
 |____/
EOF
    let standard_4 =<< EOF
  _  _
 | || |
 | || |_
 |__   _|
    |_|
EOF
    let standard_5 =<< EOF
  ____
 | ___|
 |___ \
  ___) |
 |____/
EOF
    let standard_6 =<< EOF
   __
  / /_
 | '_ \
 | (_) |
  \___/
EOF
    let standard_7 =<< EOF
  _____
 |___  |
    / /
   / /
  /_/
EOF
    let standard_8 =<< EOF
   ___
  ( _ )
  / _ \
 | (_) |
  \___/
EOF
    let standard_9 =<< EOF
   ___
  / _ \
 | (_) |
  \__, |
    /_/
EOF
    let standard_0 =<< EOF
   ___
  / _ \
 | | | |
 | |_| |
  \___/
EOF
    let standard_mark1 =<< EOF
  _
 ( )
 |/
EOF
    let standard_mark2 =<< EOF
  _
 ( )
  \|
EOF
    let standard_mark3 =<< EOF
  _ _
 ( | )
  V V
EOF
    let standard_mark4 =<< EOF
    ____
   / __ \
  / / _` |
 | | (_| |
  \ \__,_|
   \____/
EOF
    let standard_mark5 =<< EOF
    _  _
  _| || |_
 |_  ..  _|
 |_      _|
   |_||_|
EOF
    let standard_mark6 =<< EOF
   _
  | |
 / __)
 \__ \
 (   /
  |_|
EOF
    let standard_mark7 =<< EOF
  _  __
 (_)/ /
   / /
  / /_
 /_/(_)
EOF
    let standard_mark8 =<< EOF
  /\
 |/\|
EOF
    let standard_mark9 =<< EOF
   ___
  ( _ )
  / _ \/\
 | (_>  <
  \___/\/
EOF
    let standard_mark10 =<< EOF
 __/\__
 \    /
 /_  _\
   \/
EOF
    let standard_mark11 =<< EOF
   __
  / /
 | |
 | |
 | |
  \_\
EOF
    let standard_mark12 =<< EOF
 __
 \ \
  | |
  | |
  | |
 /_/
EOF
    let standard_mark13 =<< EOF
  _
 (_)
EOF
    let standard_mark14 =<< EOF
  _
 | |
 | |
 |_|
 (_)
EOF
    let standard_mark15 =<< EOF
    _
  _| |_
 |_   _|
   |_|
EOF
    let standard_mark16 =<< EOF
  _
 (_)
  _
 (_)
EOF
    let standard_mark17 =<< EOF
  _
 (_)
  _
 ( )
 |/
EOF
    let standard_mark18 =<< EOF
  _____
 |_____|
EOF
    let standard_mark19 =<< EOF
 __
 \ \
  \ \
  / /
 /_/
EOF
    let standard_mark20 =<< EOF
   __
  / /
 / /
 \ \
  \_\
EOF
    let standard_mark21 =<< EOF
  _
 | |
 | |
 | |
 | |
 |_|
EOF
    let standard_mark22 =<< EOF
 __
 \ \
  \ \
   \ \
    \_\
EOF
    let standard_mark23 =<< EOF
     __
    / /
   / /
  / /
 /_/
EOF
    let standard_mark24 =<< EOF
  ___
 |__ \
   / /
  |_|
  (_)
EOF
    let standard_mark25 =<< EOF
   __
  / /
 | |
< <
 | |
  \_\
EOF
    let standard_mark26 =<< EOF
__
\ \
 | |
  > >
 | |
/_/
EOF
    let standard_mark27 =<< EOF
 __
| _|
| |
| |
| |
|__|
EOF
    let standard_mark28 =<< EOF
 __
|_ |
 | |
 | |
 | |
|__|
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
    \ 'step': [1, 5],
    \ 'value': [ standard_a, standard_b, standard_c, standard_d, standard_e,
    \            standard_f, standard_g, standard_h, standard_i, standard_j,
    \            standard_k, standard_l, standard_m, standard_n, standard_o,
    \            standard_p, standard_q, standard_r, standard_s, standard_t,
    \            standard_u, standard_v, standard_w, standard_x, standard_y,
    \            standard_z, standard_mark1, standard_mark2, standard_mark3, standard_mark4 ]
    \ },
    \ {
    \ 'index': a:indexes[1],
    \ 'step': [1, 5],
    \ 'value': [ standard_A, standard_B, standard_C, standard_D, standard_E,
    \            standard_F, standard_G, standard_H, standard_I, standard_J,
    \            standard_K, standard_L, standard_M, standard_N, standard_O,
    \            standard_P, standard_Q, standard_R, standard_S, standard_T,
    \            standard_U, standard_V, standard_W, standard_X, standard_Y,
    \            standard_Z, standard_mark5, standard_mark6, standard_mark7, standard_mark8 ]
    \ },
    \ {
    \ 'index': a:indexes[2],
    \ 'step': [1, 5],
    \ 'value': [ standard_1, standard_2, standard_3, standard_4, standard_5,
    \            standard_6, standard_7, standard_8, standard_9, standard_0,
    \            standard_mark9, standard_mark10, standard_mark11, standard_mark12, standard_mark13,
    \            standard_mark14, standard_mark15, standard_mark16, standard_mark17, standard_mark18,
    \            standard_mark19, standard_mark20, standard_mark21, standard_mark22, standard_mark23,
    \            standard_mark24, standard_mark25, standard_mark26, standard_mark27, standard_mark28,
    \ ]
    \ }
    \ ],
    \ }
endfunction

