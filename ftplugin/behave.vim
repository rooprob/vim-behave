" Vim filetype plugin
" Language:	Behave
" Maintainer: Matěj Cepl mceplATceplDOTeu
" Original Author:	Tim Pope <vimNOSPAM@tpope.org>
" Last Change:	2010 Aug 09
"
" Requires cucutags Python module
" install it via
" pip install cucutags

" Only do this when not done yet for this buffer
if (exists("b:did_ftplugin"))
  finish
endif
let b:did_ftplugin = 1

if ! has('python')
  echo "It doesn't make sense to even try to run this script without Python"
  finish
endif

setlocal autowriteall
setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:# commentstring=#\ %s
setlocal omnifunc=BehaveComplete

let b:undo_ftplugin = "setl fo< com< cms< ofu< awa<"

let b:behave_root = expand('%:p:h:s?.*[\/]\%(features\|stories\)\zs[\/].*??')

if !exists("g:no_plugin_maps") && !exists("g:no_behave_maps")
  command! BehaveJump                    call s:jump('edit', 0)<CR><CR>
  nnoremap <silent><buffer> <C-]>       :exe <SID>jump('edit',v:count)<CR><CR>
  nnoremap <silent><buffer> [<C-D>      :exe <SID>jump('edit',v:count)<CR><CR>
  nnoremap <silent><buffer> ]<C-D>      :exe <SID>jump('edit',v:count)<CR><CR>
  let b:undo_ftplugin .=
        \ "|sil! nunmap <buffer> <C-]>" .
        \ "|sil! nunmap <buffer> [<C-D>" .
        \ "|sil! nunmap <buffer> ]<C-D>"
      "  \ "|sil! nunmap <buffer> <C-W>]" .
      "  \ "|sil! nunmap <buffer> <C-W><C-]>" .
      "  \ "|sil! nunmap <buffer> <C-W>d" .
      "  \ "|sil! nunmap <buffer> <C-W><C-D>" .
      "  \ "|sil! nunmap <buffer> <C-W>}" .
      "  \ "|sil! nunmap <buffer> [d" .
      "  \ "|sil! nunmap <buffer> ]d"
endif

function! s:jump(command,count)
  let filename = ""
  let lineno = 0
python << PYEND
if not('parsed_data' in globals()):
    startdir = vim.eval("expand('%:p:h:h')")
    import vim
    import string
    import cucutags
    parsed_data = cucutags.Session(startdir)

curline = vim.current.line.strip((string.punctuation+string.whitespace))
res = parsed_data.get_step(curline)
if res:
    fname, lno = res
    vim.command("let filename = '%s'" % fname)
    vim.command("let lineno = %s" % lno)
PYEND

  if len(filename) == 0 || lineno == 0
     return 'echoerr "No matching step found"'
  else
  "   let c = a:count ? a:count-1 : 0
     let out = a:command.' +'.lineno.' '.escape(filename,' %#')
     echo "out = " . out
     return out
  endif
endfunction

function! BehaveComplete(findstart,base) abort
endfunction

" code stolen from pytest.vim
" XXX rooprob 2014-12-29

function! s:BehaveRunInSplitWindow(path)
    let cmd = "behave " . a:path
    echom "inside RunInSplit with path=" . a:path
    if exists("g:ConqueTerm_Loaded")
        call conque_term#open(cmd, ['split', 'resize 20'], 0)
    else
        let command = join(map(split(cmd), 'expand(v:val)'))
        let command = join(map(split(cmd), 'expand(v:val)'))
        let winnr = bufwinnr('BehaveVerbose.behave')
        silent! execute  winnr < 0 ? 'botright new ' . 'BehaveVerbose.behave' : winnr . 'wincmd w'
        setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=behave
        silent! execute 'silent %!'. command
        silent! execute 'resize ' . line('$')
        silent! execute 'nnoremap <silent> <buffer> q :q! <CR>'
        call s:BehaveSyntax()
    endif
    autocmd BufEnter LastSession.Behave call s:BehaveCloseIfLastWindow()
endfunction

function! s:LastSession()
    echom "inside LastSession, calling BehaveClearAll"
    call s:BehaveClearAll()
    if (len(g:behave_last_session) == 0)
        call s:BehaveEcho("There is currently no saved last session to display")
        return
    endif
	let winnr = bufwinnr('LastSession.behave')
	silent! execute  winnr < 0 ? 'botright new ' . 'LastSession.behave' : winnr . 'wincmd w'
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=behave
    let session = split(g:behave_last_session, '\n')
    call append(0, session)
	silent! execute 'resize ' . line('$')
    silent! execute 'normal! gg'
    autocmd! BufEnter LastSession.behave call s:BehaveCloseIfLastWindow()
    nnoremap <silent> <buffer> q       :call <sid>BehaveClearAll(1)<CR>
    nnoremap <silent> <buffer> <Enter> :call <sid>BehaveClearAll(1)<CR>
    call s:BehaveSyntax()
    exe 'wincmd p'
endfunction

" Close the Pytest buffer if it is the last one open
function! s:BehaveCloseIfLastWindow()
  if winnr("$") == 1
    q
  endif
endfunction

function! s:BehaveSyntax() abort
  let b:current_syntax = 'behave'
"  syn match BehavePlatform              '\v^(platform(.*))'
"  syn match BehaveTitleDecoration       "\v\={2,}"
"  syn match BehaveTitle                 "\v\s+(test session starts)\s+"
"  syn match BehaveCollecting            "\v(collecting\s+(.*))"
"  syn match BehavePythonFile            "\v((.*.py\s+))"
"  syn match BehaveFooterFail            "\v\s+((.*)(failed|error) in(.*))\s+"
"  syn match BehaveFooter                "\v\s+((.*)passed in(.*))\s+"
"  syn match BehaveFailures              "\v\s+(FAILURES|ERRORS)\s+"
"  syn match BehaveErrors                "\v^E\s+(.*)"
"  syn match BehaveDelimiter             "\v_{3,}"
"  syn match BehaveFailedTest            "\v_{3,}\s+(.*)\s+_{3,}"
"
"  hi def link BehavePythonFile          String
"  hi def link BehavePlatform            String
"  hi def link BehaveCollecting          String
"  hi def link BehaveTitleDecoration     Comment
"  hi def link BehaveTitle               String
"  hi def link BehaveFooterFail          String
"  hi def link BehaveFooter              String
"  hi def link BehaveFailures            Number
"  hi def link BehaveErrors              Number
"  hi def link BehaveDelimiter           Comment
"  hi def link BehaveFailedTest          Comment
endfunction

function! s:BehaveCurrentPath()
    let cwd = '"' . expand("%:p") . '"'
    return cwd
endfunction

function! s:ThisBehave()
    let save_cursor = getpos('.')
    call s:BehaveClearAll()
    let abspath     = s:BehaveCurrentPath()
    let message  = "behave ==> Running tests in: " . abspath
    call s:BehaveEcho(message, 1)

    let path = abspath

    call s:BehaveRunInSplitWindow(path)
endfunction

function! s:BehaveEcho(msg, ...)
    redraw!
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    if (a:0 == 1)
        echo a:msg
    else
        echohl WarningMsg | echo a:msg | echohl None
    endif

    let &ruler=x | let &showcmd=y
endfun

function! s:BehaveClearAll(...)
    call s:BehaveEcho("inside BehaveClearAll")
    let current = winnr()
    let bufferL = [ 'Fails.behave', 'LastSession.behave', 'ShowError.behave', 'BehaveVerbose.behave' ]
    for b in bufferL
        let _window = bufwinnr(b)
        if (_window != -1)
            silent! execute _window . 'wincmd w'
            silent! execute 'q'
        endif
    endfor

    " Remove any echoed messages
    if (a:0 == 1)
        " Try going back to our starting window
        " and remove any left messages
        call s:BehaveEcho('')
        silent! execute 'wincmd p'
    else
        execute current . 'wincmd w'
    endif
endfunction

function! s:BehaveProxy(action, ...)
    if (executable("behave") == 0)
        call s:BehaveEcho("behave not found. This plugin needs behave installed and accessible")
        return
    endif

    " Some defaults
    let verbose = 0
    let pdb     = 'False'
    let looponfail = 0
    let delgado = []
    let verbose = 1

    call s:ThisBehave()
endfunction

command! -nargs=+ -complete=custom,s:Completion Behave call s:BehaveProxy(<f-args>)
" vim:set sts=2 sw=2:
