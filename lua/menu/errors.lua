local Errors = {}
local matAlert = Material("nenu/icon/warning.png")

local function createError(error)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	if error.panel then
		error.panel.deltime = error.last + 10
		return
	end
	error.panel = makePopup(" ",
		function() end,
		function(self, w, h)
			local t = math.Clamp(SysTime() - error.last, 0, 1)
			surface.SetDrawColor(Color(255, easeOutCubic(t, 127, 255), easeOutCubic(t, 0, 255), 255))
			surface.DrawRect(0, 0, w, h)
			surface.SetFont("Default")
			local countmod = ""
			if error.times == 1 then
				countmod = "once..."
			elseif error.times == 2 then
				countmod = "again..."
			elseif error.times == 3 then
				countmod = "again and again..."
			else
				countmod = "x"..error.times
			end
			local width, height = surface.GetTextSize("["..error.realm:upper().."] "..error.title.." caused lua error "..countmod)
			draw.DrawText("["..error.realm:upper().."] "..error.title.." caused lua error "..countmod,  "Default", 26, h / 2 - height / 2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(255, 255, 255, 127 + (63 * (math.sin((SysTime()+error.last)*10)+1))))
			surface.SetMaterial(matAlert)
			surface.DrawTexturedRect(7, 7, 16, 16)
		end,
		300, 30, error.last + 10)
end
hook.Add("OnLuaError", "MenuErrorHandler", function(str, realm, stack, addontitle, addonid)
	if addonid == nil then addonid = 0 end
	if addontitle == nil then addontitle = "Something" end
	if realm == nil then realm = "unknown" end
	if not Errors[addonid] then Errors[addonid] = {} end
	if not Errors[addonid][realm] then
		log("lua", "["..os.date("%H:%M:%S %d.%m.%Y").." REALM "..realm:upper().."] "..str.."\nCaused by "..addontitle.." / ID "..addonid)
		for n, call in pairs(stack) do
			if call.Function == " " or call.Function == nil or call.Function == "" then
				call.Function = "<unknown function>"
			end
			log("lua", string.rep("  ", n)..call.Function.." - "..call.File..":"..call.Line)
		end
	end

	if Errors[addonid][realm] then
		if Errors[addonid][realm].last < SysTime() - 10 then
			Errors[addonid][realm] = nil
		end
	end

	if Errors[addonid][realm] then
		Errors[addonid][realm].times = Errors[addonid][realm].times + 1
		Errors[addonid][realm].last = SysTime()
	else
		local error = {
			first = SysTime(),
			last = SysTime(),
			times = 1,
			title = addontitle,
			id = addonid,
			realm = realm
		}
		Errors[addonid][realm] = error
	end
	createError(Errors[addonid][realm])
end)