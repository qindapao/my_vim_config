
" =====================File: slide.vim {======================= 文本幻灯片 =====

" ----------------------------------------------------------------------------

" 文本幻灯片功能 {
" xx_1.txt
" xx_2.txt
" xx_3.txt

let g:slide_current = 1
let g:slide_total = 0
let g:slide_files = []

" ----------------------------------------------------------------------------

function! SlideLoad(slide)
    if a:slide > 0 && a:slide <= len(g:slide_files)
        let l:filename = g:slide_files[a:slide - 1]
        silent execute 'edit' l:filename
        let g:slide_current = a:slide
    else
        echo "Slide " . a:slide . " does not exist."
    endif
endfunction

" ----------------------------------------------------------------------------

function! SlideCursorZero ()
    call cursor(1, 1)
endfunction

" ----------------------------------------------------------------------------

function! SlideNext(timer)
    if g:slide_current < g:slide_total
        call SlideLoad(g:slide_current + 1)
    else
        call SlideLoad(1)
    endif
    call SlideInfoShow()
    call SlideCursorZero()
endfunction

" ----------------------------------------------------------------------------

function! SlidePrev()
    if g:slide_current > 1
        call SlideLoad(g:slide_current - 1)
    else
        call SlideLoad(g:slide_total)
    endif
    call SlideInfoShow()
    call SlideCursorZero()
endfunction

" ----------------------------------------------------------------------------

function! SlideInfoShow()
    echo "Slide " . g:slide_current . " of " . g:slide_total
endfunction

" ----------------------------------------------------------------------------

function! SlideDetect()
    let g:slide_files = glob('*.*', 0, 1)
    " 使用自定义的按照数字排序(提取最后的数字)
    let g:slide_files = sort(g:slide_files, {a, b -> str2nr(matchstr(a, '\d\+\D*$')) - str2nr(matchstr(b, '\d\+\D*$'))})
    let g:slide_total = len(g:slide_files)
endfunction

" ----------------------------------------------------------------------------

function! SlideshowStart()
    call SlideDetect()
    call SlideLoad(1)
    echo "Total slides detected: " . g:slide_total
    call SlideCursorZero()
endfunction

" ----------------------------------------------------------------------------

function! SlideshowStartAuto(interval)
    if exists("g:slideshow_timer") && g:slideshow_timer != 0
        call SlideshowStopAuto()
    endif
    let g:slideshow_timer = timer_start(a:interval, 'SlideNext', {'repeat': -1})
    echo "Auto slideshow started with interval: " . a:interval . " ms"
endfunction

" ----------------------------------------------------------------------------

function! SlideshowStopAuto()
    if exists("g:slideshow_timer") && g:slideshow_timer != 0
        call timer_stop(g:slideshow_timer)
        let g:slideshow_timer = 0
        echo "Auto slideshow stopped"
    endif
endfunction

" ----------------------------------------------------------------------------

command! SlideDetect call SlideDetect()
command! SlideNext call SlideNext(0)
command! SlidePrev call SlidePrev()
command! SlideInfo call SlideInfoShow()
command! SlideshowStart call SlideshowStart()
command! -nargs=1 SlideshowStartAuto call SlideshowStartAuto(<args>)
command! SlideshowStopAuto call SlideshowStopAuto()


" 文本幻灯片功能 }

" ----------------------------------------------------------------------------



" =====================File: slide.vim }======================= 文本幻灯片 =====

