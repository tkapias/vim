" Vim filetype plugin
" Language:		Markdown
" Maintainer:		Tim Pope <vimNOSPAM@tpope.org>
" Last Change:		2021 Nov 12

if exists("b:did_ftplugin")
  finish
endif

runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim

setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=<!--%s-->
setlocal formatoptions+=tcqln formatoptions-=r formatoptions-=o
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= "|setl cms< com< fo< flp<"
else
  let b:undo_ftplugin = "setl cms< com< fo< flp<"
endif

function! s:NotCodeBlock(lnum) abort
  return synIDattr(synID(v:lnum, 1, 1), 'name') !=# 'markdownCode'
endfunction

function! MarkdownFold() abort
  let line = getline(v:lnum)

  if line =~# '^#\+ ' && s:NotCodeBlock(v:lnum)
    return ">" . match(line, ' ')
  endif

  let nextline = getline(v:lnum + 1)

  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && s:NotCodeBlock(v:lnum + 1)
    return ">1"
  endif

  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && s:NotCodeBlock(v:lnum + 1) && !exists('b:markdown_frontmatter')
    return ">2"
  endif

  if v:lnum == 1 && (line =~ '^[+-]\{3}$')
    let b:markdown_frontmatter = 1
    return ">1"
  endif

  if (line =~ '^[+-]\{3}$') && b:markdown_frontmatter
    unlet b:markdown_frontmatter
    return '<1'
  endif

  return "="
endfunction

function! s:HashIndent(lnum) abort
  let hash_header = matchstr(getline(a:lnum), '^#\{1,6}\|^[+-]\{3}$')
  if len(hash_header)
    return hash_header
  else
    let nextline = getline(a:lnum + 1)
    if nextline =~# '^=\+\s*$'
      return '#'
    elseif nextline =~# '^-\+\s*$'
      return '##'
    endif
  endif
endfunction

function! MarkdownFoldText() abort
  let hash_indent = s:HashIndent(v:foldstart)
  let foldsize = (v:foldend - v:foldstart + 1)
  let linecount = '['.foldsize.' lines]'
  if getline(v:foldstart) =~ '^[+-]\{3}$'
    let currentfold = getline(2, v:foldend-1)
    let title = substitute(getline(2+match(currentfold, '^\s\{,2}title[ =:]\{1,2}')), '^\s\{,2}title[ =:]\{1,2}', '', '')
  else
    let title = substitute(getline(v:foldstart), '^#\+\s*', '', '')
  endif
  return hash_indent.' '.title.' '.linecount
endfunction

if has("folding") && exists("g:markdown_folding")
  setlocal foldexpr=MarkdownFold()
  setlocal foldmethod=expr
  setlocal foldtext=MarkdownFoldText()
  let b:undo_ftplugin .= " foldexpr< foldmethod< foldtext<"
endif

" vim:set sw=2:
