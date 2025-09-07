vim9script

def ToStr(lines: list<string>): string
    return join(lines, "\n")
enddef


# 多行字符串定义
const str_demo_text =<< trim END
other_str
other_str
other_str2
END

const demo_info_text =<< trim END
gege
中文没问题
END

# 函数定义
export def g:ComPleteAllDemo(): string
    const result =<< trim END
this ia demo
other line
END
    return ToStr(result)
enddef

# 字典定义
g:word_to_complete_all = {
    'date print': 'strftime("%Y-%m-%d %H:%M:%S")',
    'demo': 'g:ComPleteAllDemo()',
    'str_demo': ToStr(str_demo_text),
}

# 补全列表定义
g:complete_list_all = [
    { word: 'date print', abbr: 'date print value', menu: '* 打印当前时间(%Y-%m-%d %H:%M:%S)', info: '', kind: 'ic', icase: 1, dup: 1 },
    { word: 'str_demo', abbr: 'str_demo', menu: '* 跨行的字符串', info: '', kind: 'w', icase: 1, dup: 1 },
    { word: 'demo', abbr: 'demo', menu: '* 跨行的字符串', info: ToStr(demo_info_text), kind: 'if', icase: 1, dup: 1 }
]

