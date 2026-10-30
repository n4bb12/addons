-- Chain a global and pass every Lua 5.0 argument through.
-- The replacement is declared with `...` so Lua 5.0 fills the local `arg` table.
-- The wrapper is wrapper(previous, args) where args is that table (args.n, args[1]..).

Balf = Balf or {}

function Balf.Hook(name, wrapper)
  local previous = getglobal(name)
  if type(previous) ~= "function" then
    return false
  end
  setglobal(name, function(...)
    return wrapper(previous, arg)
  end)
  return true
end
