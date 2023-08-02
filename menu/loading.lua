g_ServerName	= ""
g_MapName		= ""
g_ServerURL		= ""
g_MaxPlayers	= ""
g_SteamID		= ""

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self.startTime = SysTime()
end

function PANEL:DrawBackground()
	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawRect(0, 0, ScrW(), ScrH())
	if self.map ~= self.omap then
		local mapthumbs = file.Find("maps/thumb/*", "GAME")
		local mat = ""
		if tableKeyFromVal(mapthumbs, self.map..".png") then
			mat = "maps/thumb/"..self.map..".png"
		end
		self.material = Material(mat)
	end

	if not self.material or self.material:IsError() then self.material = Material("effects/tvscreen_noise002a") end
	surface.SetMaterial(self.material)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawRect(10, 10, 138, 138)
	surface.DrawTexturedRect(15, 15, 128, 128)

	local text = pnlMainMenu.gamedata.shostname
	draw.DrawText(text, "DermaLarge", 153, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT)
end

local mapthumbs = file.Find("maps/thumb/*", "GAME")
function tableKeyFromVal(tbl, value)
	for k,v in pairs(tbl) do
		if v == value then return k end
	end
end

function PANEL:Paint(w, h)
	self.map = pnlMainMenu.gamedata.map
	self:DrawBackground()
	surface.SetFont("Default")
	local width, height = surface.GetTextSize(GetLoadStatus())
	draw.DrawText(GetLoadStatus(), "Default", w / 2 - width / 2, h - 50 - height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
	local gamemode = engine.GetGamemodes()
	for _,g in pairs(gamemode) do
		if g.name == engine.ActiveGamemode() then
			gamemode = g
			break
		end
	end
	local text = "Starting game on "..self.map..", "..gamemode.title.."..."
	local width, height = surface.GetTextSize(text)
	draw.DrawText(text, "Default", w / 2 - width / 2, h - 80 - height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)

	local text = os.date("%M:%S", SysTime() - self.startTime)
	local width, height = surface.GetTextSize(text)
	draw.DrawText(text, "Default", w / 2 - width / 2, 80 - height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)
end

local PanelType_Loading = vgui.RegisterTable( PANEL, "EditablePanel" )
local pnlLoading = nil

function GetLoadPanel()
	if not IsValid(pnlLoading) then
		pnlLoading = vgui.CreateFromTable(PanelType_Loading)
	end

	return pnlLoading
end

function GetLoadingPanel()
	if not IsValid(pnlLoading) then
		pnlLoading = vgui.CreateFromTable(PanelType_Loading)
	end

	return pnlLoading
end

function IsInLoading()
	if not IsValid(pnlLoading) then
		return false
	end

	return true
end