-- meta abstractions
local M = {}

local api = vim.api

---@param mode string[]
---@param opts vim.keymap.set.Opts
local function new_mapper(mode, opts)
  opts.noremap = true
  if opts.expr then opts.replace_keycodes = true end
  return setmetatable({}, {
    __index = function(self, flag)
      local _opts = vim.deepcopy(opts or {}, true)
      if type(flag) == 'number' then
        _opts.buffer = flag
      else
        _opts[flag] = true
      end
      rawset(self, flag, new_mapper(mode, _opts))
      return rawget(self, flag)
    end,
    __newindex = function(_, lhs, rhs)
      if type(rhs) == 'function' then
        opts.callback = rhs
        rhs = ''
      end
      local buf = opts.buffer == true and 0 or opts.buffer --[[@as integer]]
      if buf then
        opts.buffer = nil ---@type integer?
        for _, m in ipairs(mode) do
          api.nvim_buf_set_keymap(buf, m, lhs, rhs, opts)
        end
        opts.buffer = buf
      else
        for _, m in ipairs(mode) do
          api.nvim_set_keymap(m, lhs, rhs, opts)
        end
      end
      opts.callback = nil
    end,
  })
end

---@type table
M.map = setmetatable({}, {
  ---@param mode string
  __index = function(self, mode)
    rawset(self, mode, new_mapper(vim.split(mode, ''), {}))
    return rawget(self, mode)
  end,
})

M.augroup = setmetatable({}, {
  ---@param name string
  ---@param opts table event with handler { ev1, args1, ev2, args2, ... }
  __newindex = function(self, name, opts)
    rawset(self, name, opts)
    local id = api.nvim_create_augroup(name, {})
    for i = 1, #opts, 2 do
      local event = opts[i]
      local _opts = opts[i + 1]
      local ty = type(_opts)
      if ty == 'string' then
        _opts = { command = _opts }
      elseif ty == 'function' then
        _opts = { callback = _opts }
      end
      _opts.group = id
      api.nvim_create_autocmd(event, _opts)
    end
  end,
})

M.command = setmetatable({}, {
  --- @param name string
  --- @param opts string|function|vim.api.keyset.user_command
  __newindex = function(self, name, opts)
    rawset(self, name, opts)
    if type(opts) == 'function' or type(opts) == 'string' then
      return api.nvim_create_user_command(name, opts, {})
    end
    local command = opts[1]
    opts[1] = nil
    return api.nvim_create_user_command(name, command, opts)
  end,
})

return M
