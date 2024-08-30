-- save old ref, safe to change vim.keymap.set after this
local keymap = vim.keymap.set

---@param mode string[]
---@param curr_opts table<string>?
local function new_mapper(mode, curr_opts)
  return setmetatable({}, {
    __index = function(curr, k)
      local next_opts = vim.deepcopy(curr_opts or {}, true)
      if type(k) == 'number' then
        next_opts.buffer = k
      else
        next_opts[k] = true
      end
      local next = new_mapper(mode, next_opts)
      rawset(curr, k, next)
      return next
    end,
    __call = function(_, lhs, rhs) return keymap(mode, lhs, rhs, curr_opts) end,
  })
end

-- cost = O(modes * max(bufnr) * #opts^#opts)
return setmetatable({}, {
  ---@param mode string
  __index = function(map, mode)
    local next = new_mapper(vim.split(mode, ''))
    rawset(map, mode, next)
    return next
  end,
  __call = function(_, ...) return keymap(...) end,
})
