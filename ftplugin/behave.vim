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

" vim:set sts=2 sw=2:
