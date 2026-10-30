-- Reply and a clicked name sometimes whisper Name- because the 1.14 client
-- appended an empty realm. The 1.12 server has no player by that name.

local function dropTrailingDash(name)
  if type(name) ~= "string" then
    return name
  end
  local trimmed = string.gsub(name, "%-+$", "")
  if trimmed == "" then
    return name
  end
  return trimmed
end

local function hook(name, wrapper)
  local previous = _G[name]
  if type(previous) ~= "function" then
    return
  end
  _G[name] = function(...)
    return wrapper(previous, ...)
  end
end

local function hookWhisperName(name)
  hook(name, function(previous, target, chatType)
    if chatType == "WHISPER" then
      target = dropTrailingDash(target)
    end
    return previous(target, chatType)
  end)
end

hook("SendChatMessage", function(previous, message, chatType, language, target)
  if chatType == "WHISPER" then
    target = dropTrailingDash(target)
  end
  return previous(message, chatType, language, target)
end)

hook("ChatFrame_SendTell", function(previous, name, chatFrame)
  return previous(dropTrailingDash(name), chatFrame)
end)

hookWhisperName("ChatEdit_SetLastTellTarget")
hookWhisperName("ChatEdit_SetLastToldTarget")

hook("ChatEdit_UpdateHeader", function(previous, editBox)
  local canEdit = editBox and editBox.GetAttribute and editBox.SetAttribute
  if canEdit and editBox:GetAttribute("chatType") == "WHISPER" then
    local target = editBox:GetAttribute("tellTarget")
    local trimmed = dropTrailingDash(target)
    if trimmed ~= target then
      editBox:SetAttribute("tellTarget", trimmed)
    end
  end
  return previous(editBox)
end)
