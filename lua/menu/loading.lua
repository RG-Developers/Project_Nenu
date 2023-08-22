g_ServerName	= ""
g_MapName		= ""
g_ServerURL		= ""
g_MaxPlayers	= ""
g_SteamID		= ""

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self.startTime = SysTime()
	self.gamedata = {pt=-2}
	self.ogamedata = {pt=-1}
	self.lstrings = {}
	self.stage = 0
	self.downloading = false
	self.d_done = 0
	self.d_need = 0
	self.server = false
end

function PANEL:DrawBackground()
	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawRect(0, 0, ScrW(), ScrH())

	if self.ogamedata and self.gamedata.pt ~= self.ogamedata.pt then
		local mapthumbs = file.Find("maps/thumb/*", "GAME")
		local mat = ""
		if tableKeyFromVal(mapthumbs, string.lower(string.gsub(self.gamedata.map, "%.bsp$", ""))..".png") then
			mat = "maps/thumb/"..string.lower(string.gsub(self.gamedata.map, "%.bsp$", ""))..".png"
		end
		self.material = Material(mat)
		self.ogamedata = table.Copy(self.gamedata)
	end

	local loadpercent = self.stage / 12
	if self.downloading then
		loadpercent = self.stage + (self.d_done / self.d_need) / 14
	end
	loadpercent = math.min(loadpercent, 1)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawRect(30, ScrH() - 170, (ScrW()-60) * loadpercent, 5)

	for k,v in pairs(ReverseTable(self.lstrings)) do
		local width, height = surface.GetTextSize(v)
		draw.DrawText(v, "Default", ScrW() / 2 - width / 2, ScrH() - 150 - height / 2 + k * 10, Color(255, 255, 255, math.max(255-(k-1)*50, 0)), TEXT_ALIGN_CENTER)
	end

	local text = os.date("%M:%S", SysTime() - self.startTime)
	local width, height = surface.GetTextSize(text)
	draw.DrawText(text, "Default", ScrW() / 2 - width / 2, 100 - height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER)

	if not self.material or self.material:IsError() then self.material = Material("effects/tvscreen_noise002a") end
	surface.SetMaterial(self.material)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawRect(10, 10, 138, 138)
	surface.DrawTexturedRect(15, 15, 128, 128)

	local gamemode = "Unknown gamemode"
	for _,g in pairs(engine.GetGamemodes()) do
		if g.name == engine.ActiveGamemode() then
			gamemode = g.title
			break
		end
	end

	local text = pnlMainMenu.gamedata.shostname .. ", " .. gamemode .. ", " .. string.lower(string.gsub(self.gamedata.map, "%.bsp$", ""))
	draw.DrawText(text, "DermaLarge", 153, 15, Color(255, 255, 255), TEXT_ALIGN_LEFT)
end

local mapthumbs = file.Find("maps/thumb/*", "GAME")
function tableKeyFromVal(tbl, value)
	for k,v in pairs(tbl) do
		if v == value then return k end
	end
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function PANEL:Paint(w, h)
	surface.SetFont("Default")
	if GetLoadStatus() == "" then
		self.lstrings = {}
		self.stage = 0
		self.downloading = false
	end
	if not table.HasValue(self.lstrings, string.gsub(GetLoadStatus() or "", '^%s*(.-)%s*$', '%1')) then
		self.lstrings[#self.lstrings+1] = string.gsub(GetLoadStatus() or "", '^%s*(.-)%s*$', '%1')
		log("load", string.gsub(GetLoadStatus() or "", '^%s*(.-)%s*$', '%1'))
		if GetLoadStatus():find("Extracting") or GetLoadStatus():find("Downloading") or GetLoadStatus():find("Loading") then 
			self.downloading = true
			self.server = true
			self.d_need = tonumber(GetLoadStatus():Split("/")[2]:Split(" ")[1])
			self.d_done = tonumber(GetLoadStatus():Split("/")[1])
		else
			self.downloading = false
			self.stage = self.stage + 1
		end
	end
	self:DrawBackground()
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