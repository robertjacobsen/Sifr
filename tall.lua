local addon = CreateFrame"Frame"

local font = select(1, GameFontNormal:GetFont())
local healthSize = 24
local powerSize = 18
local class = select(2, UnitClass"player")

local powerColor = {}
powerColor["MANA"] = { r = 0.30, g = 0.30, b = 1.00 }
powerColor["RAGE"] = { r = 1.00, g = 0.00, b = 0.00 }
powerColor["FOCUS"] = { r = 1.00, g = 0.50, b = 0.25 }
powerColor["ENERGY"] = { r = 1.00, g = 1.00, b = 0.00 }
powerColor["HAPPINESS"] = { r = 0.00, g = 1.00, b = 1.00 }
powerColor["RUNES"] = { r = 0.50, g = 0.50, b = 0.50 }
powerColor["RUNIC_POWER"] = { r = 0.00, g = 0.82, b = 1.00 }
powerColor["SOUL_SHARDS"] = { r = 0.50, g = 0.32, b = 0.55 }
powerColor["ECLIPSE"] = { negative = { r = 0.30, g = 0.52, b = 0.90 },  positive = { r = 0.80, g = 0.82, b = 0.60 }}
powerColor["HOLY_POWER"] = { r = 0.95, g = 0.90, b = 0.60 }

-- vehicle colors
powerColor["AMMOSLOT"] = { r = 0.80, g = 0.60, b = 0.00 }
powerColor["FUEL"] = { r = 0.0, g = 0.55, b = 0.5 }

local ph = addon:CreateFontString"SifrPlayerHealth"
ph:SetPoint("CENTER", UIParent, "CENTER", -200, -50)
ph:SetFont(font, healthSize, "OUTLINE")
ph:SetTextColor(0, .7, 0, .9)

local pp = addon:CreateFontString"SifrPlayerPower"
pp:SetPoint("TOP", ph, "BOTTOM", 0, -10)
pp:SetFont(font, powerSize, "OUTLINE")

local sp = addon:CreateFontString"SifrSpecialPower"
sp:SetPoint("TOP", pp, "BOTTOM", 0, -10)
sp:SetFont(font, healthSize, "OUTLINE")
sp:SetTextColor(powerColor["HOLY_POWER"].r, powerColor["HOLY_POWER"].g, powerColor["HOLY_POWER"].b, .9)

local th = addon:CreateFontString"SifrTargetHealth"
th:SetPoint("CENTER", UIParent, "CENTER", 200, -50)
th:SetFont(font, healthSize, "OUTLINE")
th:SetTextColor(0, .7, 0, .9)

local tp = addon:CreateFontString"SifrTargetPower"
tp:SetPoint("TOP", th, "BOTTOM", 0, -10)
tp:SetFont(font, powerSize, "OUTLINE")

local si = function(val) 
	if val > 1000000 then
		return string.format("%.1fM", val / 1000000)
	end
	return val
end

local per = function(cur, max)
	if max == 0 then
		return 0
	end
	return math.floor(100 * cur / max)
end

addon.UNIT_HEALTH = function(self, event, unit) 
	if unit ~= "player" and unit ~= "target" then 
		return
	end

	local cur = UnitHealth(unit)
	local max = UnitHealthMax(unit) or 1
	local health = string.format("%s (%d%%)", si(cur), per(cur, max))
	if unit == "player" then
		ph:SetText(health)
	else
		th:SetText(health)
	end
end

addon.UNIT_POWER = function(self, event, unit)
	if unit ~= "player" and unit ~= "target" then 
		return
	end

	local cur = UnitPower(unit)
	local max = UnitPowerMax(unit) 
	local power = string.format("%s (%d%%)", si(cur), per(cur, max))
	if unit == "player" then
		pp:SetText(power)

		if class == "PALADIN" then
			local p = UnitPower("player", 9)
			if (p > 0) then
				sp:SetText(p)
			else 
				sp:SetText""
			end
		end
	else
		if cur == 0 then
			tp:SetText""	
		else
			tp:SetText(power)
			local pt = select(2, UnitPowerType"target")
			if (pt ~= "RAGE" and pt ~= "ENERGY" and pt ~= "FOCUS" ) then
				pt = "MANA"
			end
			local tt = powerColor[pt]
			tp:SetTextColor(tt.r, tt.g, tt.b, .9)
		end
	end
end

addon.PLAYER_TARGET_CHANGED = function(self, event)
	if not UnitExists"target" then 
		th:Hide()
		tp:Hide()
		return
	else 
		th:Show()
		tp:Show()
	end
	addon.UNIT_HEALTH(self, event, "target")
	addon.UNIT_POWER(self, event, "target")
end

addon.PLAYER_ENTERING_WORLD = function(self, event)
	local pt = powerColor[select(2, UnitPowerType"player")]
	pp:SetTextColor(pt.r, pt.g, pt.b, .9)

	addon.UNIT_HEALTH(self, event, "player")
	addon.UNIT_POWER(self, event, "player")
end

addon:RegisterEvent"UNIT_HEALTH"
addon:RegisterEvent"UNIT_POWER"
addon:RegisterEvent"PLAYER_ENTERING_WORLD"
addon:RegisterEvent"PLAYER_TARGET_CHANGED"
addon:SetScript("OnEvent", function (self, event, ...) 
    self[event](self, event, ...)
end)
