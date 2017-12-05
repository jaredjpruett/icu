ICU_VERSION = "1.3 - Shanktank's Version";

ICU_MAX_LINES = 10;

ICU_CLASSES = {
    ["Warrior"] = { .25,   0,   0, .25; },
    ["Mage"]    = {  .5, .25,   0, .25; },
    ["Rogue"]   = { .75,  .5,   0, .25; },
    ["Druid"]   = {   1, .75,   0, .25; },
    ["Hunter"]  = { .25,   0, .25,  .5; },
    ["Shaman"]  = {  .5, .25, .25,  .5; },
    ["Priest"]  = { .75,  .5, .25,  .5; },
    ["Warlock"] = {   1, .75, .25,  .5; },
    ["Paladin"] = { .25,   0,  .5, .75; }
};

ICU_DESCRIPTIONS = {
    ["ALERT"]    = "ALERT will immediately ping and add a message in the specified chat when you click the blip of a player of the opposite faction on the minimap",
    ["ANNOUNCE"] = "ANNOUNCE will add a message in the specified chat when you click an entry in the popup frame",
    ["ANCHOR"]   = "ANCHOR sets the location of the frame that pops up when you click a blip on the minimap"
};
ICU_OPTIONS = {
    ["ALERT"]    = { "AUTO", "SAY", "YELL", "PARTY", "RAID", "SELF", "OFF"; },
    ["ANNOUNCE"] = { "AUTO", "SAY", "YELL", "PARTY", "RAID", "SELF", "OFF"; },
    ["ANCHOR"]   = { "TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT"; }
};

ICU_PING_X = 0;
ICU_PING_Y = 0;

local icu_prevtooltip = nil;

------------------------------------------------------------------------------
-- Auxiliary functions
------------------------------------------------------------------------------

function ICU_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1);
end

function ICU_ParseCommand(str) -- ToDO: Do NOT let this function see the light of day
	local str = string.upper(str);
    local len = string.len(str);

	local cmd = "";
	local opt = "";

    local i = 1;
    while i < len + 1 and string.sub(str, i, i) ~= " " do
        cmd = cmd .. string.sub(str, i, i);
        i = i + 1;
    end
    while i < len + 1 and string.sub(str, i, i) == " " do
        i = i + 1;
    end
    while i < len + 1 and string.sub(str, i, i) ~= " " do
        opt = opt .. string.sub(str, i, i);
        i = i + 1;
    end

    return cmd, opt;
end

function ICU_StringifyKeys(tab)
	local str = "";
	for key, _ in pairs(tab) do
		str = str .. key .. ", ";
	end
	return string.sub(str, 1, -3);
end

function ICU_TableHasValue(tab, val)
    for _, v in ipairs(tab) do -- ToDO: pairs instead of ipairs?
        if val == v then
            return true;
        end
    end
    return false;
end

------------------------------------------------------------------------------
-- OnFoo() functions
------------------------------------------------------------------------------

function ICU_OnLoad()
    this:RegisterEvent("VARIABLES_LOADED");
    
    lOriginal_Minimap_OnClick_Event = Minimap_OnClick;
    Minimap_OnClick = ICU_Minimap_OnClick_Event;
    
    --if DEFAULT_CHAT_FRAME then
        --ICU_Print("ICU " .. ICU_VERSION .. " AddOn loaded");
    --end
    
    SlashCmdList["ICU"] = function(msg)
        ICU_Slash(msg);
    end
    
    SLASH_ICU1 = "/icu";
	SLASH_ICU2 = "/icu+";
	SLASH_ICU3 = "/icui";
	SLASH_ICU3 = "/icup";
end

function ICU_Slash(str)
	local cmd, opt = ICU_ParseCommand(str);
	if cmd == "" then
		ICU_Print("ICU 1.3: Shanktank's Version. Commands: " .. string.lower(ICU_StringifyKeys(ICU_OPTIONS)));
    elseif ICU_OPTIONS[cmd] == nil then
		ICU_Print("ICU: Invalid command. Commands: " .. string.lower(ICU_StringifyKeys(ICU_OPTIONS)));
	elseif opt == "" then
		ICU_Print("ICU: "  .. cmd .. " is currently set to " .. ICUvars[cmd] .. ". " .. ICU_DESCRIPTIONS[cmd] .. ". Valid values are " .. table.concat(ICU_OPTIONS[cmd], ", ") .. "."); -- ToDO: cache/precalc concat or always do on the fly?
	else
        if ICU_TableHasValue(ICU_OPTIONS[cmd], opt) then
			ICUvars[cmd] = opt;
			ICU_Print("ICU: " .. cmd .. " has been set to " .. ICUvars[cmd] .. ".");
			if cmd == "ANCHOR" then
				ICU_SetPoints();
			end
		else
			ICU_Print("ICU: Invalid " .. cmd .. " value. Valid " .. cmd .. " values are: " .. table.concat(ICU_OPTIONS[cmd], ", ") .. ".");
		end
	end
end

function ICU_OnEvent(event)
    if event == "VARIABLES_LOADED" then
		if not ICUvars then
            ICUvars = { };
            ICUvars["ALERT"]    = "AUTO";
            ICUvars["ANNOUNCE"] = "AUTO";
            ICUvars["ANCHOR"]   = "BOTTOMRIGHT";
        end
        
        ICU_SetPoints();
    end
end

function ICU_SetPoints()
    ICU_Popup:ClearAllPoints();
    
    if ICUvars["ANCHOR"] == "BOTTOMRIGHT" then
        ICU_Popup:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", 0, 0);
    elseif ICUvars["ANCHOR"] == "TOPRIGHT" then
        ICU_Popup:SetPoint("BOTTOMRIGHT", "MinimapCluster", "TOPRIGHT", 0, 0);
    elseif ICUvars["ANCHOR"] == "BOTTOM" then
        ICU_Popup:SetPoint("TOP", "MinimapCluster", "BOTTOM", 0, 0);
    elseif ICUvars["ANCHOR"] == "TOP" then
        ICU_Popup:SetPoint("BOTTOM", "MinimapCluster", "TOP", 0, 0);
    elseif ICUvars["ANCHOR"] == "BOTTOMLEFT" then
        ICU_Popup:SetPoint("TOPLEFT", "MinimapCluster", "BOTTOMLEFT", 0, 0);
    elseif ICUvars["ANCHOR"] == "TOPLEFT" then
        ICU_Popup:SetPoint("BOTTOMLEFT", "MinimapCluster", "TOPLEFT", 0, 0);
    elseif ICUvars["ANCHOR"] == "RIGHT" then
        ICU_Popup:SetPoint("RIGHT", "MinimapCluster", "LEFT", 0, 0);
    elseif ICUvars["ANCHOR"] == "LEFT" then
        ICU_Popup:SetPoint("LEFT", "MinimapCluster", "RIGHT", 0, 0);
    end
end

function ICU_Popup_OnUpdate()
    if not MouseIsOver(MinimapCluster) and not MouseIsOver(ICU_Popup) then
        ICU_Clear_Popup();
    end
end

function ICU_ButtonClick()
    if string.len(this.ICU_DATA) ~= string.len(this:GetText()) then
        local lOriginal_ERR_UNIT_NOT_FOUND = ERR_UNIT_NOT_FOUND;
        local lOriginal_ERR_GENERIC_NO_TARGET = ERR_GENERIC_NO_TARGET;
        ERR_UNIT_NOT_FOUND = "";
        ERR_GENERIC_NO_TARGET = "";
        
        TargetByName(this.ICU_DATA);
        
        if UnitIsDead("target") then
            ClearTarget();
        end
        
        if not IsControlKeyDown() then 
            if ICUvars["ANNOUNCE"] ~= "SELF" and ICUvars["ANNOUNCE"] ~= "OFF" then
                if ICUvars["ANNOUNCE"] ~= "AUTO" then
                    SendChatMessage("ICU -> " .. this:GetText() .. ".", ICUvars["ANNOUNCE"]);
                else
                    if GetNumRaidMembers() > 0 then
                        SendChatMessage("ICU -> " .. this:GetText() .. ".", "RAID");
                    elseif GetNumPartyMembers() > 0 then
                        SendChatMessage("ICU -> " .. this:GetText() .. ".", "PARTY");
                    else
                        ICU_Print("ICU ->  " .. this:GetText() .. ".");
                    end
                end
            elseif ICUvars["ANNOUNCE"] == "SELF" then
                ICU_Print("ICU ->  " .. this:GetText() .. ".");
            end
        else
            ICU_Print("ICU ->  " .. this:GetText() .. ".");
        end

        ERR_UNIT_NOT_FOUND = lOriginal_ERR_UNIT_NOT_FOUND;
        ERR_GENERIC_NO_TARGET = lOriginal_ERR_GENERIC_NO_TARGET;
    end
end

------------------------------------------------------------------------------
-- OnFoo() hooked function
------------------------------------------------------------------------------

function ICU_Minimap_OnClick_Event()
    if IsShiftKeyDown() then
        lOriginal_Minimap_OnClick_Event();
    else
        if GameTooltip:IsVisible() then
            local x, y = GetCursorPosition();
            x = x / Minimap:GetEffectiveScale();
            y = y / Minimap:GetEffectiveScale();
            
            local cx, cy = Minimap:GetCenter();
            ICU_PING_X = x + CURSOR_OFFSET_X - cx;
            ICU_PING_Y = y + CURSOR_OFFSET_Y - cy;
            
            ICU_Clear_Popup();
            ICU_Process_Tooltip(GameTooltipTextLeft1:GetText());
            
            PlaySound("UChatScrollButton");
        end
    end
end

------------------------------------------------------------------------------
-- Internal functions
------------------------------------------------------------------------------

function ICU_Process_Tooltip(tooltip, silent)
    local pos = 0;
    local width = 0;
    local result_line, r, g, b, target, class, health, rank;
    local prev_trg = nil;
    local lOriginal_TargetFrame_OnShow_Event = TargetFrame_OnShow;
    local lOriginal_TargetFrame_OnHide_Event = TargetFrame_OnHide;
    TargetFrame_OnShow = ICU_TargetFrame_OnShow_Event;
    TargetFrame_OnHide = ICU_TargetFrame_OnHide_Event;
    local lOriginal_ERR_UNIT_NOT_FOUND = ERR_UNIT_NOT_FOUND;
    local lOriginal_ERR_GENERIC_NO_TARGET = ERR_GENERIC_NO_TARGET;
    ERR_UNIT_NOT_FOUND = "";
    ERR_GENERIC_NO_TARGET = "";
    
    prev_trg = UnitName("target");
    ClearTarget();
    
    for target in string.gfind(tooltip, "[^\n]*") do
        if string.len(target) > 0 then
            result_line, class, health, rank, r, g, b = ICU2_Process_Trg(target);
            
            if result_line ~= nil then
                pos = pos + 1;
                
                if not health then
                    health = 0;
                end
                
                local button = getglobal("ICU_PopupButton" .. pos .. "Button");
                local bar = getglobal("ICU_PopupButton" .. pos .. "ButtonBar");
                local bg = getglobal("ICU_PopupButton" .. pos .. "ButtonBGBar");
                local ranktex = getglobal("ICU_PopupButton" .. pos .. "ButtonRankIcon");
                
                SetPortraitTexture(getglobal("ICU_PopupButton" .. pos .. "ButtonPortraitIcon"), "target");
                
                if ICU_CLASSES[class] then
                    getglobal("ICU_PopupButton" .. pos .. "ButtonClassIcon"):SetTexCoord(unpack(ICU_CLASSES[class]));
                else
                    getglobal("ICU_PopupButton" .. pos .. "ButtonClassIcon"):SetTexCoord(0, .25, 0, .25);
                end
                
                getglobal("ICU_PopupButton" .. pos .. "ButtonClassIcon"):SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
                
                if rank and rank ~= 0 then
                    ranktex:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank", rank - 4));
                    ranktex:Show();
                else    
                    ranktex:Hide();
                end
                
                getglobal("ICU_PopupButton" .. pos):SetBackdropBorderColor(r, g, b);
                bar:SetStatusBarColor(r, g, b, 0.75);
                bar:SetValue(health);
                bg:SetStatusBarColor(r, g, b, 0.1);
                button:SetTextColor(r + 0.3, g + 0.3, b + 0.3);
                button:SetText(result_line);
                button.ICU_DATA = target;
                button:GetParent():Show();
                button:Show();
                
                local w = button:GetTextWidth();
                if w > width then
                    width = w;
                end
            end
        end
        
        if pos >= ICU_MAX_LINES then
            break
        end;
    end
    
    TargetFrame_OnShow = lOriginal_TargetFrame_OnShow_Event;
    TargetFrame_OnHide = lOriginal_TargetFrame_OnHide_Event;
    ERR_UNIT_NOT_FOUND = lOriginal_ERR_UNIT_NOT_FOUND;
    ERR_GENERIC_NO_TARGET = lOriginal_ERR_GENERIC_NO_TARGET;
    
    if pos > 0 then
        ICU_Display_Popup(pos, width + 10);
    else
        ICU_Clear_Popup();
    end
end

function ICU2_Process_Trg(trg)
    for name in string.gfind(trg, "|c%x%x%x%x%x%x%x%x([^|]+)|r") do
        trg = name;
    end
    
    local result_strn = nil;
    local health, rank;
    
    TargetByName(trg);
    
    if UnitExists("target") and UnitName("target") then
        result_strn = trg .. " " .. UnitLevel( "target" );
        
        if UnitIsPlayer("target") then
            -- TODO: BEGIN -- NOTE: UnitIsPVP(), UnitPVPName()
            myFaction, _ = UnitFactionGroup("player");
            theirFaction, _ = UnitFactionGroup("target");

            if myFaction ~= theirFaction and not UnitOnTaxi("target") then
                Minimap:PingLocation(ICU_PING_X, ICU_PING_Y);

				local flagged = UnitIsPVP("target");

                message = UnitPVPName("target") .. ": " .. UnitLevel("target") .. " " .. UnitRace("target") .. " " .. UnitClass("target");
				if flagged then
					message = message .. " (FLAGGED)";
				else
					message = message .. " (UNFLAGGED)";
				end
                if ICUvars["ALERT"] == "AUTO" then
                    if GetNumRaidMembers() > 0 then
                        SendChatMessage(message, "RAID");
                    elseif GetNumPartyMembers() > 0 then
                        SendChatMessage(message, "PARTY");
                    else
                        ICU_Print(message);
                    end
                elseif ICUvars["ALERT"] == "SELF" then
                    ICU_Print(message);
                elseif ICUvars["ALERT"] ~= "OFF" and not ((ICUvars["ALERT"] == "PARTY" and GetNumPartyMembers() == 0) or (ICUvars["ALERT"] == "RAID" and GetNumRaidMembers() == 0)) then
                    SendChatMessage(message, ICUvars["ALERT"]);
                end
            end
            -- TODO: END --

            result_strn = result_strn .. " " .. UnitRace("target") .. " " .. UnitClass("target");
            rank = UnitPVPRank("target");
            local guildname, _, _ = GetGuildInfo("target");
            
            if(guildname ~= nil) then
                result_strn = result_strn .. " <" .. guildname .. ">";
            end
            
            if UnitInParty("target") or UnitInRaid("target") then
                result_strn = result_strn .. " [" .. UnitHealth("target") .. "/" .. UnitHealthMax("target") .. "]";
                health = UnitHealth("target") / UnitHealthMax("target") * 100;
            else
                result_strn = result_strn .. " [" .. UnitHealth( "target" ) .. "%]";
                health = UnitHealth("target");
            end
        else
            result_strn = "NPC:- " .. result_strn;
            result_strn = result_strn .. " [" .. UnitHealth( "target" ) .. "%]";
            health = UnitHealth("target");
        end
        
        local r, g, b = GameTooltip_UnitColor("target");
        
        return result_strn, UnitClass("target"), health, rank, r, g, b;     
    end
    
    return result_strn;
end

function ICU_TargetFrame_OnShow_Event()
    -- Do nothing
end

function ICU_TargetFrame_OnHide_Event()
    CloseDropDownMenus();
end

function ICU_Display_Popup(numTrgs, width)
    for i = 1, 10 do 
        getglobal("ICU_PopupButton" .. i):SetWidth(width + 40 + 9);
        getglobal("ICU_PopupButton" .. i .. "Button"):SetWidth(width + 40);
        getglobal("ICU_PopupButton" .. i .. "ButtonBar"):SetWidth(width);
        getglobal("ICU_PopupButton" .. i .. "ButtonBGBar"):SetWidth(width);
    end
    
    ICU_Popup:SetWidth(width + 40 + UNITPOPUP_BORDER_WIDTH);
    ICU_Popup:SetHeight(numTrgs * ICU_PopupButton1:GetHeight() + 12);
    ICU_Popup:Show();
end

function ICU_Clear_Popup()
    for i = 1, 10 do
        getglobal("ICU_PopupButton" .. i .. "Button"):SetText("");
        getglobal("ICU_PopupButton" .. i).ICU_DATA = "";
        getglobal("ICU_PopupButton" .. i):Hide();
    end
    
    ICU_Popup:Hide();
end

function ICU_MouseOverUpdate()
    if ICUvars["mouseOver"] and IsControlKeyDown() and MouseIsOver(MinimapCluster) and GetMouseFocus():GetName() == "Minimap" then
        if GameTooltip:IsVisible() then
            if GameTooltipTextLeft1:GetText() ~= icu_prevtooltip then
                ICU_Clear_Popup();
                icu_prevtooltip = GameTooltipTextLeft1:GetText()
                ICU_Minimap_OnClick_Event();
            end 
        end
    end
end
