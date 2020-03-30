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

| Mapping | Action        | Description                             |
| ------- | ------------- | --------------------------------------- |
| `ff`    | `fzf-files`   | Fzf for files                           |
| `fd`    | `fzf-dirs`    | Fzf for directories                     |
| `fa`    | `fzf-both`    | Fzf for both files and directories      |

More details, see [`:help fern-mapping-fzf`](https://github.com/LumaKernel/fern-mapping-fzf.vim/blob/master/doc/fern-mapping-fzf.txt) .

## Screenshot

![fern-mapping-fzf](https://user-images.githubusercontent.com/29811106/77903876-8e00ef00-72be-11ea-8d17-fa312cc2ab93.gif)

## License

[MIT](https://github.com/LumaKernel/fern-mapping-fzf.vim/blob/master/LICENSE) .

