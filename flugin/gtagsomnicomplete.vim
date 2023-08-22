let s:global_command = "global"
let s:str_split_char = '\n'
let s:min_len_invoke = 2
function! gtagsomnicomplete#Complete(findstart, base)
    let l:completions=[]
	if a:findstart
		" Locate the start of the item, including ".", "->" and "[...]".
		let line = getline('.')
		let start = col('.') - 1
		
		"echo "current line " . getline('.')[0:col('.') - 1]
		let lastword = -1
		while start > 0
			if line[start - 1 ] =~ '\w'
			    let start -= 1
			else
			    break
			endif
		endwhile
		if start==col('.') - 1
		    return -1
		else
		    return start
		endif
	endif	
	
 	if empty(a:base) || strlen(a:base) < s:min_len_invoke
		return l:completions
	else 
		"echo "need replace is "  . a:base
	      
		let  l:completions=split(system( s:global_command . ' ' . '-c' . ' ' . a:base),s:str_split_char)
		"echo l:completions
		call map( l:completions,"{'word': v:val, 'menu':'gtags'}")
		"echo l:completions
		return l:completions
		
	endif
	
endfunction


