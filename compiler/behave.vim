" Vim compiler file
" Compiler:	Behave
" Maintainer:	Matěj Cepl <mceplATceplDOTeu>
" Last Change:	2013 Oct 02

if exists("current_compiler")
  finish
endif
let current_compiler = "behave"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=behave

" CompilerSet errorformat=
"       \%W%m\ (Behave::Undefined),
"       \%E%m\ (%.%#),
"       \%Z%f:%l,
"       \%Z%f:%l:%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2:
