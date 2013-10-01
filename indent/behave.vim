" Vim indent file
" Language:	Behave (actually mostly just Cucumber)
" Maintainer:	Tim Pope <vimNOSPAM@tpope.org>
" Last Change:	2010 May 21

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=GetBehaveIndent()
setlocal indentkeys=o,O,*<Return>,<:>,0<Bar>,0#,=,!^F

let b:undo_indent = 'setl ai< inde< indk<'

" Only define the function once.
if exists("*GetBehaveIndent")
  finish
endif

function! s:syn(lnum)
  return synIDattr(synID(a:lnum,1+indent(a:lnum),1),'name')
endfunction

function! GetBehaveIndent()
  let line  = getline(prevnonblank(v:lnum-1))
  let cline = getline(v:lnum)
  let nline = getline(nextnonblank(v:lnum+1))
  let syn = s:syn(prevnonblank(v:lnum-1))
  let csyn = s:syn(v:lnum)
  let nsyn = s:syn(nextnonblank(v:lnum+1))
  if csyn ==# 'behaveFeature' || cline =~# '^\s*Feature:'
    " feature heading
    return 0
  elseif csyn ==# 'behaveExamples' || cline =~# '^\s*\%(Examples\|Scenarios\):'
    " examples heading
    return 2 * &sw
  elseif csyn =~# '^behave\%(Background\|Scenario\|ScenarioOutline\)$' || cline =~# '^\s*\%(Background\|Scenario\|Scenario Outline\):'
    " background, scenario or outline heading
    return &sw
  elseif syn ==# 'behaveFeature' || line =~# '^\s*Feature:'
    " line after feature heading
    return &sw
  elseif syn ==# 'behaveExamples' || line =~# '^\s*\%(Examples\|Scenarios\):'
    " line after examples heading
    return 3 * &sw
  elseif syn =~# '^behave\%(Background\|Scenario\|ScenarioOutline\)$' || line =~# '^\s*\%(Background\|Scenario\|Scenario Outline\):'
    " line after background, scenario or outline heading
    return 2 * &sw
  elseif cline =~# '^\s*[@#]' && (nsyn == 'behaveFeature' || nline =~# '^\s*Feature:' || indent(prevnonblank(v:lnum-1)) <= 0)
    " tag or comment before a feature heading
    return 0
  elseif cline =~# '^\s*@'
    " other tags
    return &sw
  elseif cline =~# '^\s*[#|]' && line =~# '^\s*|'
    " mid-table
    " preserve indent
    return indent(prevnonblank(v:lnum-1))
  elseif cline =~# '^\s*|' && line =~# '^\s*[^|]'
    " first line of a table, relative indent
    return indent(prevnonblank(v:lnum-1)) + &sw
  elseif cline =~# '^\s*[^|]' && line =~# '^\s*|'
    " line after a table, relative unindent
    return indent(prevnonblank(v:lnum-1)) - &sw
  elseif cline =~# '^\s*#' && getline(v:lnum-1) =~ '^\s*$' && (nsyn =~# '^behave\%(Background\|Scenario\|ScenarioOutline\)$' || nline =~# '^\s*\%(Background\|Scenario\|Scenario Outline\):')
    " comments on scenarios
    return &sw
  endif
  return indent(prevnonblank(v:lnum-1))
endfunction

" vim:set sts=2 sw=2:
