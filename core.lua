-- Setting up the local scope
local myname, ns = ...

-- Config
local font = STANDARD_TEXT_FONT
local fontSize = 12

local backdrop = {
    bgFile = "Interface\Buttons\WHITE8x8",
    edgeFile = "Interface\Buttons\WHITE8x8",
    tiled = false,
    edgeSize = 1,
    insets = { left = -1, right = -1, top = -1, bottom = -1}
  }
local backdropColor = { .1,.1,.1,1 }
local borderColor = { .6,.6,.6,1 }

-- Functions
local function funcname(args,...)
  --Do something witty
end

-- Registering Events
ns.RegisterEvent("PLAYER_LOGIN", funcname)