---------------------------------------------
-- Setting up the local scope
---------------------------------------------
-- local ns = CreateFrame("ns")

---------------------------------------------
-- Variables and shit
---------------------------------------------
local tooltips = {   -- hijacking the tooltips
  GameTooltip,
  ItemRefTooltip,
  ShoppingTooltip1,
  ShoppingTooltip2,
  ShoppingTooltip3,
  ItemRefShoppingTooltip1,
  ItemRefShoppingTooltip2,
  ItemRefShoppingTooltip3,
  --WorldMapTooltip
}
SetCVar("breakUpLargeNumbers", 1)

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

---------------------------------------------
-- Config
---------------------------------------------
local font = STANDARD_TEXT_FONT

local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tiled = false,
    edgeSize = 1,
    insets = { left = -1, right = -1, top = -1, bottom = -1}
  }
local backdropColor = { r = 0.1, g = 0.1, b = 0.1, a = .8}
local borderColor = { r = .6, g = .6, b = .6, a = .8 }
local scale = 1
local position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 250 }

---------------------------------------------
-- Functions
---------------------------------------------
-- Changing the textures
for i = 1, #tooltips do -- turns out the default color for non-textures tooltips is rgba(0,0,1,1)
  tooltips[i]:SetBackdrop(backdrop)
  -- tooltips[i].SetBackdrop = function() end -- use empty func as dummy
  tooltips[i]:SetScale(scale)
  -- tooltips[i].SetBackdropColor = function() end -- use empty func as dummy
  tooltips[i]:SetBackdropColor( backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a )
  -- tooltips[i].SetBackdropBorderColor = function() end -- use empty func as dummy
  tooltips[i]:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
end

--change some text sizes
GameTooltipHeaderText:SetFont(font, 13, nil)
GameTooltipText:SetFont(font, 12, nil)
Tooltip_Small:SetFont(font, 11, nil)
Tooltip_Small:SetShadowColor(0,0,0,1)
Tooltip_Small:SetShadowOffset(1, -1)

-- Reposition the HP bar
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("LEFT",3,0)
GameTooltipStatusBar:SetPoint("RIGHT",-3,0)
GameTooltipStatusBar:SetPoint("BOTTOM",GameTooltipStatusBar:GetParent(),"BOTTOM",0,3)
GameTooltipStatusBar:SetHeight(5)

GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
GameTooltipStatusBar.bg:SetPoint("TOPLEFT",-1,1)
GameTooltipStatusBar.bg:SetPoint("BOTTOMRIGHT",1,-1)
GameTooltipStatusBar.bg:SetTexture(1,1,1)
GameTooltipStatusBar.bg:SetVertexColor(0,0,0,0.7)

-- Hook to move
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    tooltip:SetOwner(parent, "ANCHOR_NONE")
    tooltip:SetPoint(unpack(position))
end)

-- Since we're moving around shit on the tooltip, we need to call this one too
GameTooltip:HookScript("OnTooltipCleared", function(self)
  self.unit = nil
  GameTooltip_ClearStatusBars(self)
end)

-- GameTooltip_OnLoad()
GameTooltip:HookScript("OnLoad", function(self)
  -- assigning default DOESNT WORK
  self:SetBackdropColor( backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a )
  self:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
end)

-- Hook to colorize our shit
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  local unit = (select(2, self:GetUnit())) or (GetMouseFocus() and GetMouseFocus():GetAttribute("unit")) or (UnitExists("mouseover") and "mouseover") or nil
  self:SetBackdropColor( backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a )
  self:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b)
  self.unit = nil

  if unit then
    self.unit = unit

    GameTooltipTextLeft1:SetFontObject(GameTooltipHeaderText)

    if UnitPlayerControlled(unit) then
      -- if unit is a playable character -- classcolors!
      local classcolor = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
      GameTooltipStatusBar:SetStatusBarColor(classcolor.r,classcolor.g,classcolor.b)
      GameTooltipTextLeft1:SetTextColor(classcolor.r,classcolor.g,classcolor.b)
      -- GameTooltip:SetBackdropBorderColor(classcolor.r, classcolor.g, classcolor.b)
      -- GameTooltip.SetBackdropBorderColor = function() end

      -- if units are AFK/DND/DEAD/GHOST
      if UnitIsAFK(unit) then
        self:AppendText(" |cff00cccc<AFK>|r")
      elseif UnitIsDND(unit) then
        self:AppendText(" |cffcc0000<DND>|r")
      elseif UnitIsDeadOrGhost(unit) then
        self:AppendText(' |cffcc0000<DEAD>|r')
        GameTooltip_ClearStatusBars(self) -- dont need empty healthbars
      end

      -- Guild Info
      local unitGuild = GetGuildInfo(unit)
      local text = GameTooltipTextLeft2:GetText()
      if unitGuild and text and text:find("^"..unitGuild) then
        GameTooltipTextLeft2:SetText("<"..text..">")
        GameTooltipTextLeft2:SetTextColor(255/255, 20/255, 200/255)
      end
    end
  end
end)

-- Funcs needed later on
-- GameTooltip_ShowStatusBar
-- GameTooltip_Hide
-- GameTooltip_OnTooltipSetItem

---------------------------------------------
-- Event Handlers
---------------------------------------------