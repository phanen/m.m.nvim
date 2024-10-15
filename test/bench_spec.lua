local function time(f)
  local start = vim.uv.hrtime()
  f()
  -- vim.wait(0)
  return (vim.uv.hrtime() - start) / 1e+6
end

local map = require('m.m').map
describe('bench', function()
  before_each(function()
    local f = function() return _ end
    for i = 1, 1000000 do
      _ = i * i
      f(_)
    end
  end)

  local loop = 1000000
  it('default', function()
    local t1 = time(function()
      for _ = 1, loop do
        map.n.noremap.silent['<leader>mp'] = ":lua require('map').print()<CR>"
      end
    end)

    local t2 = time(function()
      for _ = 1, loop do
        vim.keymap.set(
          'n',
          '<leader>mp',
          ":lua require('map').print()<CR>",
          { noremap = true, silent = true }
        )
      end
    end)

    local t3 = time(function()
      for _ = 1, loop do
        vim.api.nvim_set_keymap(
          'n',
          '<leader>mp',
          ":lua require('map').print()<CR>",
          { noremap = true, silent = true }
        )
      end
    end)

    local costs = {
      { cost = t1, run = 'map.n.noremap.silent' },
      { cost = t2, run = 'vim.keymap.set' },
      { cost = t3, run = 'vim.api.nvim_set_keymap' },
    }

    table.sort(costs, function(a, b) return a.cost < b.cost end)
    print(vim.inspect(costs))
  end)
end)
