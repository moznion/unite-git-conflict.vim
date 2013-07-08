" Unite source for git conflicts.
"   File:          git_conflict.vim
"   Author:        moznion (Taiki Kawakami) <moznion@gmail.com>
"   License:       MIT License

let s:save_cpo = &cpo
set cpo&vim

let s:unite_git_conflict_source = {'name': 'git-conflict'}

function! s:unite_git_conflict_source.gather_candidates(args, context)
  let l:result = unite#util#system('git status --short')

  " Error (Not a git repository)
  if empty(matchstr(l:result, '^..\=\s\+'))
    return [{
      \   "word":   substitute(l:result, "\n", "", ""),
      \   "source": "git-conflict",
      \ }]
  endif

  let l:conflict_statuses = filter(
    \   split(l:result, "\n"),
    \   '(v:val[0] == "A" || v:val[0] == "D" || v:val[0] == "U") && ' .
    \   '(v:val[1] == "A" || v:val[1] == "D" || v:val[1] == "U")'
    \ )

  let l:candidates = []
  for l:conflict_status in l:conflict_statuses
    let l:conflict      = split(l:conflict_status, "\\\s\\\+")
    let l:conflict_type = l:conflict[0]
    let l:conflict_file = fnamemodify(l:conflict[1], ":p")
    call add(l:candidates, {
      \   "word":         l:conflict_type . ' ' . l:conflict_file,
      \   "source":       "git-conflict",
      \   "kind":         "file",
      \   "action__path": l:conflict_file
      \ })
  endfor

  return l:candidates
endfunction

function! unite#sources#git_conflict#define()
  return executable('git') ? s:unite_git_conflict_source : []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
