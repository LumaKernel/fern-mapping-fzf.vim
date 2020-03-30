# fern-mapping-call-function

[![fern plugin](https://img.shields.io/badge/🌿%20fern-plugin-yellowgreen)](https://github.com/lambdalisue/fern.vim)

## Dependencies

- [lambdalisue/fern.vim](https://github.com/lambdalisue/fern.vim)
- [junegunn/fzf](https://github.com/junegunn/fzf)
- For Windows users, `sh` and `find` command compatible with UNIX.
  - You can find them from like `scoop install unxutils`.

## Installation

Example for [dein](https://github.com/Shougo/dein.vim) with TOML.

```toml
[[plugins]]
repo = 'LumaKernel/fern-mapping-fzf.vim'
depends = ['fzf', 'fern.vim']
```

## Usage

| Mapping | Action        | Description                             |
| ------- | ------------- | --------------------------------------- |
| `ff`    | `fzf-files`   | Fzf for files                           |
| `fd`    | `fzf-dirs`    | Fzf for directories                     |
| `fa`    | `fzf-both`    | Fzf for both files and directoris       |

More details, see [`:help fern-mapping-fzf`](https://github.com/LumaKernel/fern-mapping-fzf.vim/blob/master/doc/fern-mapping-fzf.txt) .
## Screenshot


## License

[MIT](https://github.com/LumaKernel/fern-mapping-fzf.vim/blob/master/LICENSE) .

