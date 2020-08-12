let s:Promise = vital#fern#import('Async.Promise')
let s:F = vital#fern#import('System.Filepath')

function! fern#mapping#fzf#init(disable_default_mappings) abort
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-files) :<C-u>call <SID>call('fzf_files')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-dirs) :<C-u>call <SID>call('fzf_dirs')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-both) :<C-u>call <SID>call('fzf_both')<CR>

  if !a:disable_default_mappings && !g:fern#mapping#fzf#disable_default_mappings
    nmap <buffer> ff <Plug>(fern-action-fzf-files)
    nmap <buffer> fd <Plug>(fern-action-fzf-dirs)
    nmap <buffer> fa <Plug>(fern-action-fzf-both)
  endif
endfunction

function! s:call(name, ...) abort
  return call(
        \ 'fern#mapping#call',
        \ [funcref(printf('s:map_%s', a:name))] + a:000,
        \)
endfunction

function! s:map_fzf_files(helper) abort
  return s:fzf(a:helper, 1, 0)
endfunction
function! s:map_fzf_dirs(helper) abort
  return s:fzf(a:helper, 0, 1)
endfunction
function! s:map_fzf_both(helper) abort
  return s:fzf(a:helper, 1, 1)
endfunction

function! s:fzf(helper, files, dirs) abort
  let nodes = a:helper.sync.get_selected_nodes()
  let root_path = s:F.to_slash(s:F.remove_last_separator(a:helper.sync.get_root_node()._path))
  if empty(root_path)
    return s:Promise.reject('Invalid root.')
  endif

  let file_paths = []
  let dir_paths = []
  for node in nodes
    let path = s:F.to_slash(s:F.remove_last_separator(node._path))
    if !empty(path) && (path[: strlen(root_path)] ==# root_path .. '/' || path ==# root_path)
      let path = path[strlen(root_path) + 1:]
      if path ==# ''
        let path = '.'
      endif
      if isdirectory(node._path)
        call add(dir_paths, path)
      elseif filereadable(node._path)
        if a:files
          call add(file_paths, path)
        endif
      endif
    endif
  endfor

  call filter(file_paths, {i,v -> len(filter(copy(dir_paths), {j, w -> s:F.contains(v, w)})) == 0})
  call filter(dir_paths, {i,v -> len(filter(copy(dir_paths), {j, w -> v !=# w && s:F.contains(v, w)})) == 0})
  call map(file_paths, {i,v -> printf('echo "%s"', s:escape(v))})
  if !a:files
    call map(dir_paths, {i,v -> printf('find -L "%s" -type d', s:escape(v))})
  elseif !a:dirs
    call map(dir_paths, {i,v -> printf('find -L "%s" -type f', s:escape(v))})
  else
    call map(dir_paths, {i,v -> printf('find -L "%s"', s:escape(v))})
  endif

  let joined_cmd = join(file_paths + dir_paths, ' && ')
  let escaped_cmd = s:escape(joined_cmd)
  call fzf#run(
        \   extend(
        \     fzf#wrap(
        \       {
        \         'source': printf('sh -c "%s"', escaped_cmd),
        \         'dir': root_path,
        \         'sink*': s:make_sink(root_path)
        \       }
        \     ), g:fern#mapping#fzf#fzf_options
        \   )
        \ )

  return s:Promise.resolve()
        \.then({ -> a:helper.async.redraw() })
endfunction

function! s:make_sink(root_path) abort
  function! s:sink(paths) abort closure
    for relative_path in a:paths
      while relative_path[:1] ==# './' || relative_path[:1] ==# '.\'
        let relative_path = relative_path[2:]
      endwhile
      let full_path = s:F.join(a:root_path, relative_path)
      let dict = {
            \   'root_path': a:root_path,
            \   'full_path': full_path,
            \   'relative_path': relative_path,
            \ }
      if isdirectory(full_path)
        if type(g:Fern_mapping_fzf_dir_sink) == v:t_func
          let dict.is_dir = v:true
          call g:Fern_mapping_fzf_dir_sink(dict)
        else
          exe 'Fern' full_path
        endif
      elseif filereadable(full_path)
        if type(g:Fern_mapping_fzf_file_sink) == v:t_func
          let dict.is_dir = v:false
          call g:Fern_mapping_fzf_file_sink(dict)
        else
          exe 'edit' full_path
        endif
      endif
    endfor
  endfunction
  return function('s:sink')
endfunction

function! s:escape(str) abort
  let str = a:str
  let str = substitute(str, '\\', '\\\\', 'g')
  let str = substitute(str, '"', '\\"', 'g')
  return str
endfunction

let g:fern#mapping#fzf#disable_default_mappings = get(g:, 'fern#mapping#fzf#disable_default_mappings', 0)
let g:Fern_mapping_fzf_dir_sink = get(g:, 'Fern_mapping_fzf_dir_sink', 0)
let g:Fern_mapping_fzf_file_sink = get(g:, 'Fern_mapping_fzf_file_sink', 0)
let g:fern#mapping#fzf#fzf_options = get(g:, 'fern#mapping#fzf#fzf_options', {})

