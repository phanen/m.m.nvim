# m.m.nvim
> experiment

## map
* no `remap`, always use `noremap`
* when use `expr`, always `replace_keycodes`

```lua
local map = require('m.m').map
map.nx[' ff'] = require('fzf-lua').files

-- delete keymap
map.nx['<c-p>'] = nil

-- or buffer-local
map[bufnr].nx['<c-p>'] = nil

-- expr map on string work just like viml (replace_keycodes=nil)
map.n.expr.S = [['<cmd>'.v:count.'InspectTree<cr>']]
```

## autogroup
```lua
local aug = require('m.m').augroup
local com = require('m.m').command

aug.bigfile = { 'BufReadPre', function(_) u.misc.bigfile_preset(_) end }
aug.lastpos = { 'BufReadPost', [[sil! norm! g`"zv']] }
aug.autowrite = -- auto reload buffer on external write
  { { 'FocusGained', 'BufEnter', 'CursorHold' }, [[if getcmdwintype() == ''| checkt | endif]] }
```

## command
```lua
com.AppendModeline = function() return u.misc.append_modeline() end
com.EditFtplugin =
  { function(_) return u.misc.edit_ftplugin(_.fargs[1]) end, nargs = '*', complete = 'filetype' }
com.Ghist = [[G log -p --follow -- %]]
```

# bench
```lua
-- nvim --headless '+PlenaryBustedDirectory test/bench_spec.lua'
{ {
    cost = 3230.500004,
    run = "vim.api.nvim_set_keymap"
  }, {
    cost = 3336.545565,
    run = "map.n.noremap.silent"
  }, {
    cost = 4334.651312,
    run = "vim.keymap.set"
  } }
```

## TODO
Maybe it's meaningless to integrate tons of features (which may never be used), but here's the main ideas...
* [ ] inject fallback via maparg + setfenv
* [ ] easy hydra key builder
* [ ] make getter meaningful in each context
