exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
exmap surround_star surround * *
exmap surround_wavy_line surround ~~ ~~
exmap surround_highlight surround == ==
exmap surround_angle_brackets surround < >

" NOTE: must use 'map' and not 'nmap'
map [[ :surround_wiki
nunmap S
vunmap S
map S" :surround_double_quotes
map S' :surround_single_quotes
map S` :surround_backticks
map Sb :surround_brackets
map S( :surround_brackets
map S) :surround_brackets
map S[ :surround_square_brackets
map S] :surround_square_brackets
map S{ :surround_curly_brackets
map S} :surround_curly_brackets
map S* :surround_star
map S~ :surround_wavy_line
map S= :surround_highlight
map S< :surround_angle_brackets
map S> :surround_angle_brackets

set guicursor+=a:blinkon0

