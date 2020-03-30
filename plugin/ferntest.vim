let s:skip_check = get(g:, 'fern#mapping#fzf#skip_check', 0)
if (!executable('sh') || !executable('find')) && !s:skip_check
  echohl WarningMsg
  echomsg '[fern-mapping-fzf.vim] Requires "sh" and "find" executable.'
  echohl None
  finish
endif

if exists('g:fern_mapping_fzf_loaded')
  finish
endif
let g:fern_mapping_fzf_loaded = 1

call extend(g:fern#mapping#mappings, ['fzf'])

