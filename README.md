# fern-mapping-fzf.vim

[![fern plugin](https://img.shields.io/badge/🌿%20fern-plugin-yellowgreen)](https://github.com/lambdalisue/fern.vim)

## Dependencies

- [lambdalisue/fern.vim](https://github.com/lambdalisue/fern.vim)
- [junegunn/fzf](https://github.com/junegunn/fzf)
- For Windows users, `sh` and `find` command compatible with UNIX-like.
  - You can find them from like Cygwin. (Note that some tools are not working fine.)

## Installation

Example for [dein](https://github.com/Shougo/dein.vim) with TOML.

```toml
[[plugins]]
repo = 'LumaKernel/fern-mapping-fzf.vim'
depends = ['fzf', 'fern.vim']
```

## Usage

| Mapping | Action           | Description                                  |
| ------- | ---------------- | -------------------------------------------- |
| `ff`    | `fzf-files`      | Fzf for files                                |
| `fd`    | `fzf-dirs`       | Fzf for directories                          |
| `fa`    | `fzf-both`       | Fzf for both files and directories           |
| `frf`   | `fzf-root-files` | Fzf for files from root                      |
| `frd`   | `fzf-root-dirs`  | Fzf for directories from root                |
| `fra`   | `fzf-root-both`  | Fzf for both files and directories from root |

More details, see [`:help fern-mapping-fzf`](https://github.com/LumaKernel/fern-mapping-fzf.vim/blob/master/doc/fern-mapping-fzf.txt) .

## Screenshot

![fern-mapping-fzf](https://user-images.githubusercontent.com/29811106/77903876-8e00ef00-72be-11ea-8d17-fa312cc2ab93.gif)

## Sample settings

### FZF multiple and mark on Fern

```vim
function! Fern_mapping_fzf_customize_option(spec)
    let a:spec.options .= ' --multi'
    " Note that fzf#vim#with_preview comes from fzf.vim
    if exists('*fzf#vim#with_preview')
        return fzf#vim#with_preview(a:spec)
    else
        return a:spec
    endif
endfunction

function! Fern_mapping_fzf_before_all(dict)
    if !len(a:dict.lines)
        return
    endif
    return a:dict.fern_helper.async.update_marks([])
endfunction

function! s:reveal(dict)
    execute "FernReveal -wait" a:dict.relative_path
    execute "normal \<Plug>(fern-action-mark:set)"
endfunction

let g:Fern_mapping_fzf_file_sink = function('s:reveal')
let g:Fern_mapping_fzf_dir_sink = function('s:reveal')
```

## License

[MIT](https://github.com/LumaKernel/fern-mapping-fzf.vim/blob/master/LICENSE)
