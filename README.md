# m.m.nvim
> experiment

## map
* no `remap`, always use `noremap`
* when use `expr`, always `replace_keycodes`

```lua
local map = require('m.m').map
map.nx.expr['C'] = [[v:register ==# '+' ? '"kC' : '"'.v:register.'C']]
map.nx['<c-p>'] = '"kP'

-- buffer-local
local n = map.n[0]
n['u'] = '<c-u>'
n['a'] = '<c-u>'
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

## TODO
Maybe it's meaningless to integrate tons of features (which may never be used), but here's the main ideas...
* [ ] inject fallback via maparg + setfenv
* [ ] easy hydra key builder
* [ ] make getter meaningful in each context
