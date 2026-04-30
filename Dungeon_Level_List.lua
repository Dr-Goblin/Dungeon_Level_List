local addonName = ...
local DungeonLevelList = CreateFrame("Frame")

local dungeonData = {
    { "RFC", "13", "16", "13", "12", "11", "18" },
    { "DMines", "14", "21", "18", "17", "16", "19" },
    { "WC", "17", "22", "19", "18", "17", "23" },
    { "SFK", "18", "26", "23", "22", "21", "24" },
    { "BFD", "22", "28", "25", "24", "23", "28" },
    { "Stock", "23", "29", "26", "25", "24", "30" },
    { "RFK", "25", "33", "30", "29", "28", "32" },
    { "Gnom", "25", "34", "31", "30", "29", "32" },
    { "SM Gy", "30", "34", "31", "30", "29", "37" },
    { "SM Lb", "33", "37", "34", "33", "32", "40" },
    { "SM Arm", "36", "40", "37", "36", "35", "44" },
    { "RFD", "34", "41", "38", "37", "36", "42" },
    { "SM Cath", "37", "42", "39", "38", "37", "47" },
    { "Uld", "39", "47", "44", "43", "42", "49" },
    { "ZF", "43", "48", "45", "44", "43", "54" },
    { "Mara", "43", "51", "48", "47", "46", "54" },
    { "ST", "47", "55", "52", "51", "50", "59" },
    { "DM:E", "54", "58", "55", "54", "53", "60" },
    { "BRD", "52", "59", "56", "55", "54", "60" },
    { "LBRS", "55", "60", "57", "56", "55", "60" },
    { "DM:W", "56", "61", "58", "57", "56", "60" },
    { "UBRS, DM:N, Scholo, Strat", "57", "62", "59", "58", "57", "60" },
}

local headers = {
    "Dungeon",
    "Mob Min",
    "Boss",
    "Tank",
    "DPS",
    "Heals",
    "Max Exp",
}

local columnWidths = { 190, 58, 52, 52, 52, 58, 62 }
local rowHeight = 16

local function ToggleMainFrame(frame)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

local function CreateMainWindow()
    local frame = CreateFrame("Frame", "DungeonLevelListMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(980, 450)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    table.insert(UISpecialFrames, frame:GetName())

    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("Dungeon Level List (Classic Era)")

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 16, -42)
    content:SetPoint("BOTTOMRIGHT", -16, 16)

    local xOffset = 0
    for i, headerText in ipairs(headers) do
        local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", xOffset, 0)
        label:SetWidth(columnWidths[i])
        label:SetJustifyH(i == 1 and "LEFT" or "CENTER")
        label:SetText(headerText)
        xOffset = xOffset + columnWidths[i]
    end

    local divider = content:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 0.82, 0, 0.7)
    divider:SetPoint("TOPLEFT", 0, -18)
    divider:SetPoint("TOPRIGHT", 0, -18)
    divider:SetHeight(1)

    for row, values in ipairs(dungeonData) do
        local y = -22 - ((row - 1) * rowHeight)
        local colX = 0

        for col = 1, #headers do
            local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            text:SetPoint("TOPLEFT", colX, y)
            text:SetWidth(columnWidths[col])
            text:SetJustifyH(col == 1 and "LEFT" or "CENTER")
            text:SetText(values[col])
            colX = colX + columnWidths[col]
        end
    end


    local note = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    note:SetPoint("BOTTOMLEFT", 0, 4)
    note:SetPoint("BOTTOMRIGHT", 0, 4)
    note:SetJustifyH("LEFT")
    note:SetText("Min level notes: Tank = Boss-3, DPS = Boss-4, Heals = Boss-5.\n-3 is a practical tank baseline for threat; DPS can be slightly lower, but groups closer to tank level are safer for final bosses.\nHealers can be lowest due to fewer miss/resist concerns, but undergeared or newer healers should stay closer to tank/DPS levels.")

    return frame
end

local function UpdateMinimapButtonPosition(button)
    local angle = math.rad(DungeonLevelListDB.minimapAngle or 225)
    local radius = 80
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton(mainFrame)
    local button = CreateFrame("Button", "DungeonLevelListMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface/Icons/INV_Misc_Map_01")

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface/Minimap/MiniMap-TrackingBorder")

    button:SetScript("OnClick", function()
        ToggleMainFrame(mainFrame)
    end)

    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(btn)
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            cx = cx / scale
            cy = cy / scale

            local dx, dy = cx - mx, cy - my
            DungeonLevelListDB.minimapAngle = math.deg(math.atan2(dy, dx))
            UpdateMinimapButtonPosition(btn)
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Dungeon Level List", 1, 1, 1)
        GameTooltip:AddLine("Click: Toggle chart", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Drag: Move button", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    UpdateMinimapButtonPosition(button)

    return button
end

DungeonLevelList:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" and addonName == "Dungeon_Level_List" then
        DungeonLevelListDB = DungeonLevelListDB or {}

        self.mainFrame = CreateMainWindow()
        self.minimapButton = CreateMinimapButton(self.mainFrame)

        SLASH_DUNGEONLEVELLIST1 = "/dungeon_level_list"
        SLASH_DUNGEONLEVELLIST2 = "/Dungeon_level_List"
        SlashCmdList.DUNGEONLEVELLIST = function()
            ToggleMainFrame(self.mainFrame)
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)

DungeonLevelList:RegisterEvent("ADDON_LOADED")
