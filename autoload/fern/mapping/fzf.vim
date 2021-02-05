let s:Promise = vital#fern#import('Async.Promise')
let s:F = vital#fern#import('System.Filepath')

function! fern#mapping#fzf#init(disable_default_mappings) abort
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-files) :<C-u>call <SID>call('fzf_files')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-dirs) :<C-u>call <SID>call('fzf_dirs')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-both) :<C-u>call <SID>call('fzf_both')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-root-files) :<C-u>call <SID>call('fzf_root_files')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-root-dirs) :<C-u>call <SID>call('fzf_root_dirs')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-fzf-root-both) :<C-u>call <SID>call('fzf_root_both')<CR>

  if !a:disable_default_mappings && !g:fern#mapping#fzf#disable_default_mappings
    nmap <buffer> ff <Plug>(fern-action-fzf-files)
    nmap <buffer> fd <Plug>(fern-action-fzf-dirs)
    nmap <buffer> fa <Plug>(fern-action-fzf-both)
    nmap <buffer> frf <Plug>(fern-action-fzf-root-files)
    nmap <buffer> frd <Plug>(fern-action-fzf-root-dirs)
    nmap <buffer> fra <Plug>(fern-action-fzf-root-both)
  endif
endfunction

function! s:call(name, ...) abort
  return call(
        \ 'fern#mapping#call',
        \ [funcref(printf('s:map_%s', a:name))] + a:000,
        \)
endfunction

function! s:map_fzf_files(helper) abort
  return s:fzf(a:helper, 1, 0, 0)
endfunction
function! s:map_fzf_dirs(helper) abort
  return s:fzf(a:helper, 0, 1, 0)
endfunction
function! s:map_fzf_both(helper) abort
  return s:fzf(a:helper, 1, 1, 0)
endfunction

function! s:map_fzf_root_files(helper) abort
  return s:fzf(a:helper, 1, 0, 1)
endfunction
function! s:map_fzf_root_dirs(helper) abort
  return s:fzf(a:helper, 0, 1, 1)
endfunction
function! s:map_fzf_root_both(helper) abort
  return s:fzf(a:helper, 1, 1, 1)
endfunction

function! s:fzf(helper, files, dirs, from_root) abort
  let nodes = a:from_root ? [a:helper.sync.get_root_node()] : a:helper.sync.get_selected_nodes()
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
  let opts = fzf#wrap(
        \   {
        \     'source': printf('sh -c "%s"', escaped_cmd),
        \     'dir': root_path,
        \   }
        \ )
  let opts['sink*'] = s:make_sink(root_path, opts['sink*'], a:helper, a:from_root)
  if exists("*g:Fern_mapping_fzf_customize_option") || type(get(g:, "Fern_mapping_fzf_customize_option")) == v:t_func
    let opts = g:Fern_mapping_fzf_customize_option(opts)
  endif
  call fzf#run(
        \   extend(
        \     opts, g:fern#mapping#fzf#fzf_options
        \   )
        \ )

  return s:Promise.resolve()
        \.then({ -> a:helper.async.redraw() })
endfunction

function! s:nomalize_rel(rel) abort
  let rel = a:rel
  while rel[:1] ==# './' || rel[:1] ==# '.\'
    let rel = rel[2:]
  endwhile
  return rel
endfunction

function! s:make_sink(root_path, common_sink, helper, from_root) abort
  function! s:sink(lines) abort closure
    function! s:sink_main(...) abort closure
      if len(a:lines) < 2
        return s:Promise.resolve()
      endif
      let rel_paths = copy(a:lines)
      let key = remove(rel_paths, 0)
      call map(rel_paths, {->s:nomalize_rel(v:val)})
      let ex_dir_sink = exists("*g:Fern_mapping_fzf_dir_sink") || type(get(g:, "Fern_mapping_fzf_dir_sink")) == v:t_func
      let ex_file_sink = exists("*g:Fern_mapping_fzf_file_sink") || type(get(g:, "Fern_mapping_fzf_file_sink")) == v:t_func

      if !ex_dir_sink && !ex_file_sink
        let full_paths = copy(rel_paths)
        call map(full_paths, {->s:F.join(a:root_path, v:val)})
        call a:common_sink([key] + full_paths)
      else
        let dir_paths = [key]
        let file_paths = [key]
        for relative_path in rel_paths
          let full_path = s:F.join(a:root_path, relative_path)
          let dict = {
                \   'key': key,
                \   'lines': a:lines,
                \   'fern_helper': a:helper,
                \   'root_path': a:root_path,
                \   'full_path': full_path,
                \   'relative_path': relative_path,
                \   'from_root': a:from_root,
                \ }
          if isdirectory(full_path)
            if ex_dir_sink
              let dict.is_dir = v:true
              call g:Fern_mapping_fzf_dir_sink(dict)
            else
              let dir_paths += [full_path]
            endif
          elseif filereadable(full_path)
            if ex_file_sink
              let dict.is_dir = v:false
              call g:Fern_mapping_fzf_file_sink(dict)
            else
              let file_paths += [full_path]
            endif
          endif
        endfor
        if !ex_dir_sink
          call a:common_sink(dir_paths)
        endif
        if !ex_file_sink
          call a:common_sink(file_paths)
        endif
      endif
      return s:Promise.resolve()
    endfunction

    function! s:sink_before_all(...) abort closure
      let dict = {
          \   'lines': copy(a:lines),
          \   'fern_helper': a:helper,
          \   'root_path': a:root_path,
          \ }
      let ex_before_all = exists("*g:Fern_mapping_fzf_before_all") || type(get(g:, "Fern_mapping_fzf_before_all")) == v:t_func
      if ex_before_all
        return s:Promise.resolve(g:Fern_mapping_fzf_before_all(dict))
      endif
      return s:Promise.resolve()
    endfunction

    function! s:sink_after_all(...) abort closure
      let dict = {
          \   'lines': copy(a:lines),
          \   'fern_helper': a:helper,
          \   'root_path': a:root_path,
          \ }
      let ex_after_all = exists("*g:Fern_mapping_fzf_after_all") || type(get(g:, "Fern_mapping_fzf_after_all")) == v:t_func
      if ex_after_all
        return s:Promise.resolve(g:Fern_mapping_fzf_after_all(dict))
      endif
      return s:Promise.resolve()
    endfunction

    call s:sink_before_all()
      \.then(funcref('s:sink_main'))
      \.then(funcref('s:sink_after_all'))
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

" Deprecated
let g:fern#mapping#fzf#fzf_options = get(g:, 'fern#mapping#fzf#fzf_options', {})
