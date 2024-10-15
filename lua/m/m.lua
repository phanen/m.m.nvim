-- meta abstractions
local M = {}

---@class vim.keymap.ctx
---@field opts? vim.keymap.set.Opts
---@field buf? integer
---@field mode? string[]
---@field parent table
---@field key string|integer

local api = vim.api
local extend = function(...) return vim.tbl_extend('force', ...) end

---@param ctx vim.keymap.ctx
local function make_map(ctx)
  local make_child = function(ext)
    local _ctx = extend(ctx, ext or {})
    local opts, buf, mode = _ctx.opts, _ctx.buf, _ctx.mode
    local child = setmetatable({}, {
      __index = function(self, key) return make_map(extend(_ctx, { parent = self, key = key })) end,
      __newindex = function(_, lhs, rhs)
        if type(rhs) == 'function' then
          opts.callback, rhs = rhs, ''
        end
        if buf then
          for _, m in ipairs(mode) do
            api.nvim_buf_set_keymap(buf, m, lhs, rhs, opts)
          end
        else
          for _, m in ipairs(mode) do
            api.nvim_set_keymap(m, lhs, rhs, opts)
          end
        end
        opts.callback = nil
      end,
    })
    rawset(ctx.parent, ctx.key, child)
    return child
  end

  local key = ctx.key
  if not ctx.buf and type(ctx.key) == 'number' then return make_child { buf = ctx.key } end
  if not ctx.mode then ---@cast key string
    return make_child { mode = vim.split(key, ''), opts = { noremap = true } }
  end

  local opts = extend(ctx.opts, { [key] = true })
  if opts.expr then opts.replace_keycodes = true end
  if opts.remap then
    opts.remap, opts.noremap = nil, false
  end
  return make_child { opts = opts }
end

---@type table
M.map = setmetatable({}, {
  __index = function(self, key) return make_map { parent = self, key = key } end,
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
