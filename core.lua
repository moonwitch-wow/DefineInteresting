---------------------------------------------
-- Config
local font = STANDARD_TEXT_FONT

local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tiled = false,
    edgeSize = 1,
    insets = { left = -1, right = -1, top = -1, bottom = -1}
  }

local scale = 1
local position = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 250 }

local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS


---------------------------------------------
-- Variables and shit
local tooltips = {   -- hijacking the tooltips
  GameTooltip,
  ItemRefTooltip,
  ItemRefShoppingTooltip1,
  ItemRefShoppingTooltip2,
  ShoppingTooltip1,
  ShoppingTooltip2,
  WorldMapTooltip
}

-----------------------------
-- Modifying the default values
TOOLTIP_DEFAULT_COLOR.r = .3
TOOLTIP_DEFAULT_COLOR.g = .3
TOOLTIP_DEFAULT_COLOR.b = .3
TOOLTIP_DEFAULT_COLOR.a = .8

TOOLTIP_DEFAULT_BACKGROUND_COLOR.r = .1
TOOLTIP_DEFAULT_BACKGROUND_COLOR.g = .1
TOOLTIP_DEFAULT_BACKGROUND_COLOR.b = .1
TOOLTIP_DEFAULT_BACKGROUND_COLOR.a = .8

-----------------------------
-- Changing the textures
for i = 1, #tooltips do -- turns out the default color for non-textures tooltips is rgba(0,0,1,1)
  tooltips[i]:SetBackdrop(backdrop)
  tooltips[i]:SetScale(scale)
  tooltips[i]:SetBackdropColor( TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, TOOLTIP_DEFAULT_BACKGROUND_COLOR.a )
  tooltips[i]:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, TOOLTIP_DEFAULT_COLOR.a)
end

-----------------------------
--  Modify default position
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
  tooltip:SetOwner(parent, "ANCHOR_NONE")
  tooltip:ClearAllPoints()
  tooltip:SetPoint(unpack(position))
end)

-----------------------------
--change some text sizes
GameTooltipHeaderText:SetFont(font, 13, nil)
GameTooltipText:SetFont(font, 12, nil)
Tooltip_Small:SetFont(font, 11, nil)
Tooltip_Small:SetShadowColor(0,0,0,1)
Tooltip_Small:SetShadowOffset(1, -1)

-----------------------------
-- Reposition the HP bar
do
  local bar = GameTooltipStatusBar
  bar:ClearAllPoints()
  bar:SetPoint("BOTTOMLEFT", 3, 3)
  bar:SetPoint("BOTTOMRIGHT", -3, 3)
  bar:SetHeight(6)

  local barbg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
  barbg:SetPoint("TOPLEFT",-1,1)
  barbg:SetPoint("BOTTOMRIGHT",1,-1)
  barbg:SetTexture(1,1,1)
  barbg:SetVertexColor(0,0,0,.7)

  GameTooltip.statusBar = bar
end

-----------------------------
--  Add raid target icon to GameTooltip
do
  local icon = GameTooltip:CreateTexture(nil, "OVERLAY")
  icon:SetPoint("TOPRIGHT", GameTooltip, "TOPLEFT", -3, -3)
  icon:SetWidth(36)
  icon:SetHeight(36)
  icon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
  icon:Hide()

  GameTooltip.raidTargetIcon = icon
end

----------------------------------------------------------------------
--  General
hooksecurefunc(GameTooltip, "Show", function(self)
  self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
  if not self:GetItem() and not self:GetUnit() then
    self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
  end
  if self.addHeight then
    self.newHeight = self:GetHeight() + self.addHeight
  end
end)

GameTooltip:HookScript("OnHide", function(self)
  self.raidTargetIcon:SetTexture(nil)
  self.raidTargetIcon:Hide()
end)

GameTooltip:HookScript("OnUpdate", function(self, elapsed)
  if not self.currentItem and not self.currentUnit then
    self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
    self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
  end

  if self.currentUnit and not UnitExists(self.currentUnit) then
    self:Hide()
  end

  if self.newHeight and abs(self:GetHeight() - self.newHeight) > 0.1 then
    self:SetHeight(self.newHeight)
  end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self)
  self.unit = nil
  GameTooltip_ClearStatusBars(self)
end)

----------------------------------------------------------------------
-- Changes based on tooltip owner
------------------------------
-- Units
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  if not playerRealm then playerRealm = GetRealmName() end
  if not playerFaction then playerFaction = UnitFactionGroup("player") end

  local unit = (select(2, self:GetUnit())) or (GetMouseFocus() and GetMouseFocus():GetAttribute("unit")) or (UnitExists("mouseover") and "mouseover") or nil

  self:SetBackdropColor( TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, TOOLTIP_DEFAULT_BACKGROUND_COLOR.a )
  -- self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
  self.unit = nil

  if unit then
    self.unit = unit

    GameTooltipTextLeft1:SetFontObject(GameTooltipHeaderText)

    if UnitIsPlayer(unit) then
      local name = GetUnitName(unit) -- make sure no realm is added and no titles
      if name == UNKNOWN then return end

      -- Unit based class coloring
      local classcolor = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
      GameTooltipStatusBar:SetStatusBarColor(classcolor.r,classcolor.g,classcolor.b)
      GameTooltipTextLeft1:SetTextColor(classcolor.r,classcolor.g,classcolor.b)
      GameTooltip:SetBackdropBorderColor(classcolor.r/2, classcolor.g/2, classcolor.b/2)

      if (name) then GameTooltipTextLeft1:SetText(name) end

      local relationship = UnitRealmRelationship(unit)
      if (relationship == LE_REALM_RELATION_VIRTUAL) then
        self:AppendText(INTERACTIVE_SERVER_LABEL)
      elseif (relationship == LE_REALM_RELATION_COALESCED) then
        self:AppendText(FOREIGN_SERVER_LABEL)
      end

      local status = UnitIsAFK(unit) and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or not UnitIsConnected(unit) and "<DC>"
      if (status) then
      self:AppendText((" |cff00cc00%s|r"):format(status))
      end

      -- Guild Info
      local playerGuild = GetGuildInfo(unit)
      local text = GameTooltipTextLeft2:GetText()
      if playerGuild and text and text:find("^"..playerGuild) then
        GameTooltipTextLeft2:SetText("<"..text..">")
        GameTooltipTextLeft2:SetTextColor(255/255, 20/255, 200/255)
      end

      -- Level text and all that jazzy
      local playerLevel = UnitLevel(unit)
      local playerClass = UnitClass(unit)
      local text = GameTooltipTextLeft3:GetText()
      if playerLevel and playerClass and text then
        GameTooltipTextLeft3:SetFormattedText("L%d %s", playerLevel, playerClass)
      end

      -- PVP
      local pvp
      if faction == playerFaction then
        pvp = UnitIsPVPFreeForAll(unit)
      else
        pvp = UnitIsPVP(unit) and not UnitIsPVPSanctuary(unit)
      end
      if pvp then
        local c = {1, .2, .2} --hostile as color
        GameTooltip:SetBackdropBorderColor(c[1], c[2], c[3])
      else
        GameTooltip:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
      end
    end
  end
end)

-- Funcs needed later on
-- GameTooltip_ShowStatusBar
-- GameTooltip_OnTooltipSetItem

---------------------------------------------
-- Event Handlers
---------------------------------------------