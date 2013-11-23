---------------------------------------------
-- Setting up the local scope
---------------------------------------------

---------------------------------------------
-- Variables and shit
---------------------------------------------
local player = UnitName("player")
local server = GetRealmName()
local tooltips = {   -- hijacking the tooltips
  GameTooltip,
  ItemRefTooltip,
  ShoppingTooltip1,
  ShoppingTooltip2,
  ShoppingTooltip3,
  ItemRefShoppingTooltip1,
  ItemRefShoppingTooltip2,
  ItemRefShoppingTooltip3,
  WorldMapTooltip
}
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local GameTooltipStatusBar = GameTooltipStatusBar

---------------------------------------------
-- Config
---------------------------------------------
local font = STANDARD_TEXT_FONT

local backdrop = {
    bgFile = "Interface\Buttons\WHITE8x8",
    edgeFile = "Interface\Buttons\WHITE8x8",
    tiled = false,
    edgeSize = 1,
    insets = { left = -1, right = -1, top = -1, bottom = -1}
  }
local backdropColor = { .1,.1,.1,1 }
local borderColor = { .6,.6,.6,1 }
local scale = 1
local position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 250 }

---------------------------------------------
-- Functions
---------------------------------------------
-- Changing the textures
for i = 1, #tooltips do
  tooltips[i]:SetBackdrop(backdrop)
  tooltips[i]:SetScale(scale)
  tooltips[i]:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b)
  tooltips[i]:SetBackdropBorderColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
end

--change some text sizes
GameTooltipHeaderText:SetFont(font, 14, "THINOUTLINE")
GameTooltipText:SetFont(font, 12, "THINOUTLINE")
Tooltip_Small:SetFont(font, 11, "THINOUTLINE")

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

---------------------------------------------
-- Event Handlers
---------------------------------------------
