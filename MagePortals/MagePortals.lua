-- ========================
-- MagePortals
-- Working with version 3.3.5a (Warmane)
-- ========================


-- CONSTANTS
local BUTTON_MARGIN = 10
local BUTTON_SIZE = 36
local BUTTON_SPACING = 4
local BUTTON_HEIGHT = BUTTON_SIZE + 2 * BUTTON_MARGIN


-- These could be used for localization in the future if ever wanted
local CLASS_MAGE = "MAGE"

local FACTION_ALLIANCE = "Alliance"
local FACTION_HORDE = "Horde"

local ITEM_RUNE_OF_PORTALS = "Rune of Portals"
local ITEM_RUNE_OF_TELEPORTATION = "Rune of Teleportation"

local SPELL_FILTER_PORTAL = "Portal: "
local SPELL_FILTER_TELEPORT = "Teleport: "

local SPELL_PORTAL_DALARAN = "Portal: Dalaran"
local SPELL_PORTAL_DARNASSUS = "Portal: Darnassus"
local SPELL_PORTAL_EXODAR = "Portal: Exodar"
local SPELL_PORTAL_IRONFORGE = "Portal: Ironforge"
local SPELL_PORTAL_ORGRIMMAR = "Portal: Orgrimmar"
local SPELL_PORTAL_SHATTRATH = "Portal: Shattrath"
local SPELL_PORTAL_SILVERMOON = "Portal: Silvermoon"
local SPELL_PORTAL_STONARD = "Portal: Stonard"
local SPELL_PORTAL_STORMWIND = "Portal: Stormwind"
local SPELL_PORTAL_THERAMORE = "Portal: Theramore"
local SPELL_PORTAL_THUNDER_BLUFF = "Portal: Thunder Bluff"
local SPELL_PORTAL_UNDERCITY = "Portal: Undercity"
local SPELL_TELEPORT_DALARAN = "Teleport: Dalaran"
local SPELL_TELEPORT_DARNASSUS = "Teleport: Darnassus"
local SPELL_TELEPORT_EXODAR = "Teleport: Exodar"
local SPELL_TELEPORT_IRONFORGE = "Teleport: Ironforge"
local SPELL_TELEPORT_ORGRIMMAR = "Teleport: Orgrimmar"
local SPELL_TELEPORT_SHATTRATH = "Teleport: Shattrath"
local SPELL_TELEPORT_SILVERMOON = "Teleport: Silvermoon"
local SPELL_TELEPORT_STONARD = "Teleport: Stonard"
local SPELL_TELEPORT_STORMWIND = "Teleport: Stormwind"
local SPELL_TELEPORT_THERAMORE = "Teleport: Theramore"
local SPELL_TELEPORT_THUNDER_BLUFF = "Teleport: Thunder Bluff"
local SPELL_TELEPORT_UNDERCITY = "Teleport: Undercity"


-- GLOBALS
local spellButtons = {}
local runeCountLabel = ""
local faction = ""
local frame


-- Helper function to check if char is a Mage
local function isMage()
    local _, class = UnitClass("player")
    return class == CLASS_MAGE
end


-- Helper function to get the Spell type out of the name
local function getSpellType(spell)
    return spell:match("([^:]+)")
end


-- Helper function to get the item count by name in the bags
local function getItemCount(itemName)
    return GetItemCount(itemName) or 0
end


-- Helper function to get amount of runes in the bags
local function getRuneCountText()
    return getItemCount(ITEM_RUNE_OF_TELEPORTATION) .. " | " .. getItemCount(ITEM_RUNE_OF_PORTALS)
end


-- Function to initialize the frame and buttons
local function InitializeFrame()
    -- If frame already exists -> exit
    if frame then return end
    
    -- Create the actual frame
    frame = CreateFrame("Frame", "MagePortalsFrame", UIParent)

    -- Create spell buttons
    local numButtons = #spellButtons
    local frameWidth = (numButtons * BUTTON_SIZE) + ((numButtons - 1) * BUTTON_SPACING) + (2 * BUTTON_MARGIN)

    -- Add space for the rune count button at the end
    frameWidth = frameWidth + BUTTON_SIZE + BUTTON_SPACING  -- Add width for the rune count button

    frame:SetSize(frameWidth, BUTTON_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
     -- To persist frame location
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        MagePortalsSaved = MagePortalsSaved or {}
        MagePortalsSaved.point = point
        MagePortalsSaved.relativePoint = relativePoint
        MagePortalsSaved.x = xOfs
        MagePortalsSaved.y = yOfs
    end)

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.6)

    -- Create spell buttons
    for i, spells in ipairs(spellButtons) do
        local button = CreateFrame("Button", "MagePortalButton"..i, frame, "SecureActionButtonTemplate")
        button:SetSize(36, 36)
        button:SetPoint("LEFT", frame, "LEFT", (i - 1) * (BUTTON_SIZE + BUTTON_SPACING) + BUTTON_MARGIN, 0)

        button:RegisterForClicks("AnyUp")
        if spells.left then
            button:SetAttribute("type1", "spell")
            button:SetAttribute("spell1", spells.left)
        end

        if spells.right then
            button:SetAttribute("type2", "spell")
            button:SetAttribute("spell2", spells.right)
        end

        local icon = button:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        local texture = spells.left and GetSpellTexture(spells.left) or spells.right and GetSpellTexture(spells.right)
        if texture then
            icon:SetTexture(texture)
        else
            icon:SetTexture(0.2, 0.2, 0.2, 1)
        end

        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local spellName = spells.left or spells.right
            local portalName = spellName and (spellName:match(SPELL_FILTER_TELEPORT .. "(.+)") or spellName:match(SPELL_FILTER_PORTAL .. "(.+)")) or "Unknown"
            GameTooltip:AddLine(portalName, 1, 1, 1)
            
            if spells.left then
                GameTooltip:AddLine(getSpellType(spells.left) .. " (Left)", 0.8, 0.8, 1)
            end
            if spells.right then
                GameTooltip:AddLine(getSpellType(spells.right) .. " (Right)", 0.8, 0.8, 1)
            end
            GameTooltip:Show()
        end)
        
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    -- Add a button to display the rune counts
    local runeCountButton = CreateFrame("Button", "RuneCountButton", frame)
    runeCountButton:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    runeCountButton:SetPoint("LEFT", frame, "LEFT", (numButtons) * (BUTTON_SIZE + BUTTON_SPACING) + BUTTON_MARGIN, 0)

    -- Set label for the rune count button to show the rune counts
    runeCountLabel = runeCountButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    runeCountLabel:SetPoint("CENTER")
    runeCountLabel:SetText(getRuneCountText())


    -- Make the rune count button non-clickable
    runeCountButton:SetScript("OnClick", function() end)

    -- Tooltip for the rune count button
    runeCountButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Rune Count", 1, 1, 1)
        GameTooltip:AddLine(ITEM_RUNE_OF_TELEPORTATION .. ": " .. getItemCount(ITEM_RUNE_OF_TELEPORTATION), 0.8, 0.8, 1)
        GameTooltip:AddLine(ITEM_RUNE_OF_PORTALS .. ": " .. getItemCount(ITEM_RUNE_OF_PORTALS), 0.8, 0.8, 1)
        GameTooltip:Show()
    end)

    runeCountButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Update the frame size after all buttons are added
    frame:SetSize(frameWidth, 50)
    
    -- Restore save frame position
    if MagePortalsSaved and MagePortalsSaved.point then
        frame:ClearAllPoints()
        frame:SetPoint(
            MagePortalsSaved.point,
            UIParent,
            MagePortalsSaved.relativePoint or MagePortalsSaved.point,
            MagePortalsSaved.x or 0,
            MagePortalsSaved.y or 0
        )
    else
        -- fallback
        frame:SetPoint("CENTER")
    end
    
    -- Craete a slash command to toggle visibility of the frame
    SLASH_MAGEPORTALS1 = "/mageportals"
    SlashCmdList["MAGEPORTALS"] = function()
        if not frame then
            return
        end

        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end


-- Helper function to add a teleport/portal pair
local function AddPortalPair(teleport, portal)
    local hasTeleport = GetSpellTexture(teleport)
    local hasPortal = GetSpellTexture(portal)

    -- Only add speel if it is already known (Spellbook)
    if hasTeleport or hasPortal then
        table.insert(spellButtons, {
            left = hasTeleport and teleport or nil,
            right = hasPortal and portal or nil,
        })
    end
end


local function addPortalSpells()
    -- Alliance portals
    if faction == FACTION_ALLIANCE then
        AddPortalPair(SPELL_TELEPORT_STORMWIND, SPELL_PORTAL_STORMWIND)
        AddPortalPair(SPELL_TELEPORT_IRONFORGE, SPELL_PORTAL_IRONFORGE)
        AddPortalPair(SPELL_TELEPORT_DARNASSUS, SPELL_PORTAL_DARNASSUS)
        AddPortalPair(SPELL_TELEPORT_EXODAR, SPELL_PORTAL_EXODAR)
        AddPortalPair(SPELL_TELEPORT_THERAMORE, SPELL_PORTAL_THERAMORE)
    -- Horde portals
    elseif faction == FACTION_HORDE then
        AddPortalPair(SPELL_TELEPORT_ORGRIMMAR, SPELL_PORTAL_ORGRIMMAR)
        AddPortalPair(SPELL_TELEPORT_UNDERCITY, SPELL_PORTAL_UNDERCITY)
        AddPortalPair(SPELL_TELEPORT_THUNDER_BLUFF, SPELL_PORTAL_THUNDER_BLUFF)
        AddPortalPair(SPELL_TELEPORT_SILVERMOON, SPELL_PORTAL_SILVERMOON)
        AddPortalPair(SPELL_TELEPORT_STONARD, SPELL_PORTAL_STONARD)
    end

    -- Shared for both factions
    AddPortalPair(SPELL_TELEPORT_SHATTRATH, SPELL_PORTAL_SHATTRATH)
    AddPortalPair(SPELL_TELEPORT_DALARAN, SPELL_PORTAL_DALARAN)
end


function MagePortals_OnLoad(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
        if isMage() then
            -- Determine faction
            faction = UnitFactionGroup("player")
            -- Add portal spells
            addPortalSpells()
            -- Init action frame
            InitializeFrame()
            self:RegisterEvent("BAG_UPDATE")
        end
	elseif event == "BAG_UPDATE" then
        if runeCountLabel then
            runeCountLabel:SetText(getRuneCountText())
        end
    end
end


local exeFrame = CreateFrame("Frame", "MagePortalsExeFrame")
exeFrame:SetScript("OnEvent", MagePortals_OnLoad);
exeFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
