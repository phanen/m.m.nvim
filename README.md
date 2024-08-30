# m.m.nvim

A meta abstraction for `vim.keymap.set`.
* Similar to neovim's meta accessors (e.g. `vim.bo[bufnr]` -> `api.nvim_get_option_value`).
* But accessors are used for currying.

## Example
```lua
-- backward compatible, m -> vim.keymap.set
m('n', lhs, rhs, { silent = true })

-- vim.keymap.set({ 'n', 'x' }, lhs, rhs)
m.nx(lhs, rhs)

-- vim.keymap.set({ 'n', 'x', 'i' }, lhs, rhs, { buffer = bufnr, expr = true })
m.nxi[bufnr].expr(lhs, rhs)

-- vim.keymap.set('nx', lhs, rhs, { buffer = bufnr, expr = true })
m.n[bufnr].expr(lhs, rhs)

-- vim.keymap.set({ '!' }, lhs, rhs, { buffer = bufnr, expr = true, silent = true, remap = true })
m['!'].expr.silent.remap[bufnr](lhs, rhs)
```

## Tip
This module can only "turn on" flag, if you find opposite patterns (e.g. `replace_keycodes = false` is needed):
```lua
vim.keymap.set(
  'nx',
  '<down>',
  'v:count ? "<down>" : "g<down>"',
  { expr = true, replace_keycodes = false }
)

vim.keymap.set(
  'nx',
  '<down>',
  function() return vim.v.count ~= 0 and '<down>' or 'g<down>' end,
  { expr = true }
)

-- so it shoud be:
m.nx.expr('<down>', function() return vim.v.count ~= 0 and '<down>' or 'g<down>' end)
```
