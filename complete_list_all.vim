
function! CompleteAllDemo()
    return "this is demo\nother line\n"
endfunction

let g:word_to_complete_all = {
    \'date_print': 'strftime("%Y-%m-%d %H:%M:%S")',
    \'demo': 'CompleteAllDemo()',
    \'str_demo': "other_str\n\
    \otherstr1\n\
    \otherstr2\n",
    \}


let g:complete_list_all = [
\ {'word': 'foo', 'abbr': 'foo' , 'menu': '* 一个补全的范例' , 'info': "预览的详细信息\n有换行的情况\n", 'kind': 'w', 'icase': 1, 'dup': 1},
\ {'word': 'date_print', 'abbr': 'date_print' , 'menu': '* 打印当前时间' , 'info': '', 'kind': 'ic', 'icase': 1, 'dup': 1},
\ {'word': 'demo', 'abbr': 'demo' , 'menu': '* 执行一个函数' , 'info': '', 'kind': 'if', 'icase': 1, 'dup': 1},
\]

