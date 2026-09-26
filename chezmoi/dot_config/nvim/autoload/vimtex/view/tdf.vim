function! vimtex#view#tdf#new() abort
  return {
        \ 'view': function('s:view'),
        \ 'out': function('s:out'),
        \ 'compiler_callback': function('s:compiler_callback'),
        \ }
endfunction

function! s:out() dict abort
  return b:vimtex.compiler.get_file('pdf')
endfunction

function! s:view(file) dict abort
  let l:pdf = empty(a:file) ? self.out() : a:file
  call luaeval("require('tdf_view').open(_A)", l:pdf)
endfunction

function! s:compiler_callback(file) dict abort
  if get(g:, 'vimtex_view_automatic', 1)
    call luaeval("require('tdf_view').open(_A)", a:file)
  endif
endfunction
