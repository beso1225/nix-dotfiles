function! vimtex#view#tdf#new() abort
  return deepcopy(s:viewer)
endfunction

let s:viewer = {}

function! s:viewer.check() dict abort
  return executable('tdf') && executable('herdr')
endfunction

function! s:viewer.xdo_check() dict abort
  return v:false
endfunction

function! s:viewer.out() dict abort
  return b:vimtex.compiler.get_file('pdf')
endfunction

function! s:viewer.view(file) dict abort
  let l:pdf = empty(a:file) ? self.out() : a:file
  call luaeval("require('tdf_view').open(_A)", l:pdf)
endfunction

function! s:viewer.compiler_callback(file) dict abort
  if get(g:, 'vimtex_view_automatic', 1)
    call luaeval("require('tdf_view').open(_A)", a:file)
  endif
endfunction
