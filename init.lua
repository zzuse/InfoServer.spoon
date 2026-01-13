--- === InfoServer ===
---
--- Simple HTTP server for receiving tasks and alerts.
---
--- Download: [https://github.com/zzuse/hammerspoon/tree/master/Spoons/InfoServer.spoon](.)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "InfoServer"
obj.version = "1.0"
obj.author = "zzuse"
obj.homepage = "https://github.com/zzuse/hammerspoon/tree/master/Spoons/InfoServer.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.server = nil
obj.port = 9181
obj.taskInfoCanvas = nil

function obj:updateTaskInfoDisplay(data)
    if self.taskInfoCanvas then
        self.taskInfoCanvas:delete()
        self.taskInfoCanvas = nil
    end

    if not data then return end

    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    
    local w, h = 600, 250
    local x = frame.x + frame.w - w - 20
    local y = frame.y + frame.h - h - 20

    self.taskInfoCanvas = hs.canvas.new({x = x, y = y, w = w, h = h})
    -- Level overlay to sit above normal windows
    self.taskInfoCanvas:level(hs.canvas.windowLevels.overlay)
    self.taskInfoCanvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.stationary)
    
    self.taskInfoCanvas:appendElements({
        {
            type = "text",
            text = "Doer: " .. (data.doer or "N/A"),
            textSize = 55,
            textColor = { hex = "#76d80e", alpha = 0.3 },
            textFont = "Impact",
            frame = { x = 0, y = 0, w = w, h = 70 }
        },
        {
            type = "text",
            text = "Task: " .. (data.task_name or "N/A"),
            textSize = 55,
            textColor = { hex = "#76d80e", alpha = 0.3 },
            textFont = "Impact",
            frame = { x = 0, y = 70, w = w, h = 90 },
            lineBreak = "truncateTail"
        },
        {
            type = "text",
            text = "Time: " .. (data.time_slot or "N/A"),
            textSize = 55,
            textColor = { hex = "#76d80e", alpha = 0.3 },
            textFont = "Impact",
            frame = { x = 0, y = 160, w = w, h = 70 }
        }
    })
    self.taskInfoCanvas:show()
end

function obj:centerAlert(message)
  local screen = hs.screen.mainScreen()
  hs.alert.closeAll(0)
  hs.alert.show(
    message,
    {
      strokeWidth = 8,
      strokeColor = { white = 1, alpha = 0.9 },
      fillColor = { red = 0.1, green = 0.12, blue = 0.15, alpha = 0.92 },
      textColor = { white = 1, alpha = 1 },
      textSize = 80,
      radius = 12,
      fadeInDuration = 0.12,
      fadeOutDuration = 0.2
    },
    screen,
    4
  )
end

function obj:start()
    if self.server then self.server:stop() end
    
    self.server = hs.httpserver.new()
    self.server:setPort(self.port)
    
    self.server:setCallback(function(method, path, headers, body)
      if method ~= "POST" then
        return "Only POST allowed", 405, { ["Content-Type"] = "text/plain" }
      end
    
      local ok, decoded = pcall(hs.json.decode, body)
      if not ok then decoded = {} end
    
      if path == "/alert" then
        local msg = "Task feedback needed"
        if decoded.message then
            msg = decoded.message
        end
        self:centerAlert(msg)
        return "OK", 200, { ["Content-Type"] = "text/plain" }
      
      -- Handle task info. Either specific path or duck typing the payload
      elseif path == "/task" or (decoded.doer and decoded.task_name) then
          self:updateTaskInfoDisplay(decoded)
          return "OK", 200, { ["Content-Type"] = "application/json" }
      end
    
      return "Not found", 404, { ["Content-Type"] = "text/plain" }
    end)
    
    self.server:start()
    return self
end

function obj:stop()
    if self.server then
        self.server:stop()
        self.server = nil
    end
    if self.taskInfoCanvas then
        self.taskInfoCanvas:delete()
        self.taskInfoCanvas = nil
    end
    return self
end

return obj
