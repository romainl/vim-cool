# vim-cool

Vim-cool disables search highlighting when you are done searching and re-enables it when you search again.

Vim-cool is cool.

Vim-cool is *experimental*.

## Requirements

Vim-cool works best when used with a contemporary vim install.

## Installation

Follow your favorite plugin/runtimepath manager's instructions.

If you choose manual installation, just put `plugin/cool.vim` where it belongs:

    $HOME/.vim/plugin/cool.vim        on Unix-like systems
    $HOME\vimfiles\plugin\cool.vim    on Windows

## Background

I wrote the first iteration of vim-cool in about twenty minutes, mostly to test a few ideas I had after a short discussion on `hlsearch` and `:nohlsearch` on #vim.

Because it relied almost exclusively on mappings, that first iteration was way too brittle to be of any use and actually messed with a bunch of my own mappings.

Then came [@purpleP](https://github.com/purpleP) and [the game-changing approach](https://github.com/romainl/vim-cool/issues/9) he put together with the help of [@chrisbra](https://github.com/chrisbra), [@justinmk](https://github.com/justinmk), [@jamessan](https://github.com/jamessan), and [@ZyX-I](https://github.com/ZyX-I).

The current version, essentially a weaponized version of @purpleP's code, doesn't rely on remappings anymore and thus should be devoid of nasty side-effects.
