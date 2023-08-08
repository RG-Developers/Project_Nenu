pnlMainMenu = nil
pnlStartGameMenu = nil
pnlConnectMenu = nil
pnlAddonsMenu = nil
include("mainmenu_base.lua")
include("mainmenu_game.lua")
include("mainmenu_servers.lua")
include("mainmenu_addons.lua")

local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)
	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)
	self:MakePopup()
	self:SetPopupStayAtBack(true)
	if gui.IsConsoleVisible() then
		gui.ShowConsole()
	end
	self.Particles = {}
	for i=0,50,1 do
		self.Particles[#self.Particles+1] = self.CreateParticle()
	end

	for i=0,50,1 do
		self.Particles[#self.Particles+1] = self.CreateStripe()
	end

	self.base = vgui.Create("MainMenuBasePanel", self)
	self.base:SetPos(-ScrW() * 0.25 - 20, 10)
	self.base:SetSize(ScrW() * 0.25 - 20, ScrH() - 20)
	self.base:MakePopup()

	self.gamedata = {
		maxplayers = 1,
		hostname = "Server",
		shostname = "Server",
		p2p_enabled = false,
		p2p_friendsonly = false,
		lan = true,
		map = "gm_construct.bsp",
	}

	pnlStartGameMenu = vgui.Create("MainMenuStartGamePanel", self)
	pnlStartGameMenu:SetPos(ScrW(), 10)
	pnlStartGameMenu:SetSize(ScrW() - 20, ScrH() - 20)
	pnlStartGameMenu:MakePopup()

	pnlAddonsMenu = vgui.Create("MainMenuAddonsPanel", self)
	pnlAddonsMenu:SetPos(ScrW(), 10)
	pnlAddonsMenu:SetSize(ScrW() - 20, ScrH() - 20)
	pnlAddonsMenu:MakePopup()

	pnlConnectMenu = vgui.Create("MainMenuConnectPanel", self)
	pnlConnectMenu:SetPos(ScrW(), 10)
	pnlConnectMenu:SetSize(ScrW() - 20, ScrH() - 20)
	pnlConnectMenu:MakePopup()

	--pnlConnectMenu = nil

	--pnlConnectMenu = vgui.Create("MainMenuConnectPanel", self)
	--pnlConnectMenu:SetPos(ScrW(), 10)
	--pnlConnectMenu:SetSize(ScrW() - 20, ScrH() - 20)
	--pnlConnectMenu:MakePopup()
	self.gmpanelx = ScrW()
	self.gmpanelhidden = true

	self:StartShowAnimation(function() end)
	--pnlConnectMenu:UpdateServers()
end

function PANEL:DrawBackground()
	local a = 255
	if IsInGame() then
		a = 25
	end
	surface.SetDrawColor(Color(0, 0, 0, a))
	surface.DrawRect(0, 0, ScrW(), ScrH())
	surface.SetDrawColor(Color(0, 0, 0, 255))
	for _,particle in pairs(self.Particles) do
		particle:draw()
		particle:update()
	end
end

function PANEL:StartHideAnimation(callback)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local from_x = self.base:GetX()
	local gm_from_x = self.gmpanelx
	local _mt = Derma_Anim("MainMenuHideAnim", self.base, function(pnl, anim, delta, data)
		pnl:SetPos(easeOutCubic(delta, from_x, -pnl:GetWide()-10), pnl:GetY())
		pnl:GetParent().gmpanelx = easeOutCubic(delta, gm_from_x, ScrW())
	end)
	function self:Think()
		if _mt:Active() then
			_mt:Run()
		else
			function self:Think() end
			self.gmpanelhidden = true
			callback()
		end
	end
	_mt:Start(0.5*animationSpeed)
end

function PANEL:StartShowAnimation(callback)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local from_x = self.base:GetX()
	local gm_from_x = self.gmpanelx
	local _mt = Derma_Anim("MainMenuShowAnim", self.base, function(pnl, anim, delta, data)
		pnl:SetPos(easeOutCubic(delta, from_x, 10), pnl:GetY())
		pnl:GetParent().gmpanelx = easeOutCubic(delta, gm_from_x, 0)
	end)
	function self:Think()
		if _mt:Active() then
			_mt:Run()
		else
			function self:Think() end
			self.gmpanelhidden = false
			callback()
		end
	end
	_mt:Start(0.5*animationSpeed)
end

function PANEL.CreateParticle()
	local ry = math.random(0, ScrH())
	local rx = math.random(ScrW() + 50, ScrW() + 500)
	local rv = -math.random(100, 300) / 1000
	local rs = math.random(10, 50)
	local particle = {}
	particle.pos = Vector(rx, ry, 0)
	particle.speed = Vector(rv, 0, 0)
	particle.color = Color(math.random(147, 255), math.random(0, 147), math.random(147, 255), 255)
	particle.s = rs
	function particle:update()
		self.pos = self.pos + self.speed
		if self.pos.x <= ScrW() then
			self.s = self.s - 0.05
		end
		if self.pos.x < -50 then self.pos.x = ScrW() + 50 end
		if self.s <= -51 then
			self.s = math.random(10, 50)
			self.pos.x = math.random(ScrW() + 50, ScrW() + 500)
		end
	end
	function particle:draw()
		for s = self.s+50, self.s, -5 do
			surface.SetDrawColor(Color(self.color.r, self.color.g, self.color.b, 10))
			surface.DrawRect(self.pos.x - s / 2, self.pos.y - s / 2, s, s)
		end
	end
	return particle
end

function PANEL.CreateStripe()
	local rl = math.random(300, 400)
	local ry = math.random(0, ScrH())
	local rx = math.random(ScrW()+50, ScrW()+500)
	local rv = -math.random(100, 300) / 100
	local rs = math.random(1, 5)
	local particle = {}
	particle.pos = Vector(rx, ry, 0)
	particle.speed = Vector(rv, 0, 0)
	particle.color = Color(math.random(147, 255), math.random(0, 147), math.random(147, 255), 255)
	particle.size = Vector(rl, rs, 0)
	function particle:update()
		self.pos = self.pos + self.speed
		if self.pos.x <= -self.size.x then
			self.size.x = math.random(300, 400)
			self.pos.y = math.random(0, ScrH())
			self.pos.x = math.random(ScrW(), ScrW()+50)
		end
	end
	function particle:draw()
		local c = self.color
		if IsInGame() then c.a = 255 else c.a = 25 end
		surface.SetDrawColor(c)
		surface.DrawRect(self.pos.x, self.pos.y, self.size.x, self.size.y)
	end
	return particle
end

function PANEL:Paint(w, h)
	self:DrawBackground()
	if self.gmname ~= engine.ActiveGamemode() then
		self.gmname = engine.ActiveGamemode() or "base"
		local mat = "gamemodes/"..self.gmname.."/logo.png"
		local material = Material(mat)
		if material:IsError() then return end
		self.material = material
	end
	if not self.material then return end
	surface.SetDrawColor(Color(255, 255, 255))
	surface.SetMaterial(self.material)
	surface.DrawTexturedRect(self.gmpanelx + w - self.material:GetTexture("$basetexture"):Width() - 10, 10, self.material:GetTexture("$basetexture"):Width(), self.material:GetTexture("$basetexture"):Height())
end

vgui.Register("MainMenuPanel", PANEL, "EditablePanel")

function PANEL:StartGameMenu()
	self:StartHideAnimation(function()
		pnlStartGameMenu:StartShowAnimation(function() end)
	end)
end

function PANEL:ServersMenu()
	self:StartHideAnimation(function()
		pnlConnectMenu:StartShowAnimation(function() end)
	end)
end

function PANEL:AddonsMenu()
	self:StartHideAnimation(function()
		pnlAddonsMenu:StartShowAnimation(function() end)
	end)
end

function PANEL:StartGame()
	self.gamedata.shostname = "Local game"
	GetLoadingPanel().startTime = SysTime()
	GetLoadingPanel().gamedata = self.gamedata
	GetLoadingPanel().gamedata.pt = SysTime()

	hook.Run("StartGame")
	
	RunConsoleCommand("progress_enable")
	RunConsoleCommand("disconnect")
	RunConsoleCommand("maxplayers", self.gamedata.maxplayers)
	if self.gamedata.maxplayers > 1 then
		RunConsoleCommand("sv_cheats", "0")
		RunConsoleCommand("commentary", "0")
	end
	RunConsoleCommand("hostname", self.gamedata.hostname)
	RunConsoleCommand("p2p_enabled", self.gamedata.p2p_enabled and 1 or 0)
	RunConsoleCommand("p2p_friendsonly", self.gamedata.p2p_friendsonly and 1 or 0)
	RunConsoleCommand("sv_lan", self.gamedata.lan and 1 or 0)
	RunConsoleCommand("maxplayers", self.gamedata.maxplayers)
	RunConsoleCommand("map", self.gamedata.map)
end

function PANEL:Connect(server)
	self.gamedata.shostname = server.name
	self.gamedata.map = server.map
	GetLoadingPanel().startTime = SysTime()
	GetLoadingPanel().gamedata = self.gamedata
	GetLoadingPanel().gamedata.pt = SysTime()
	
	if not steamworks.ShouldMountAddon(server.gmwsid) then
		if steamworks.IsSubscribed(server.gmwsid) then
			print("Temp-enabling addon id "..server.gmwsid.." for server '"..server.name.."' gamemode")
			steamworks.SetShouldMountAddon(server.gmwsid, true)
		else
			print("Server '"..server.name.."' gamemode is not installed.!")
			steamworks.ViewFile(server.gmwsid)
			return
		end
	end
	hook.Run("StartGame")
	RunConsoleCommand("progress_enable")
	RunConsoleCommand("disconnect")
	RunConsoleCommand("password", password or "no_password")
	JoinServer(server.address)
end

function PANEL:Cmd(cmd)
	RunGameUICommand(cmd)
end
function PANEL:ECmd(ecmd)
	RunGameUICommand("engine "..ecmd)
end

function PANEL:Quit()
	self:StartHideAnimation(function()
		RunGameUICommand("engine quit")
	end)
end

function PANEL:Disconnect()
	RunGameUICommand("engine disconnect")
end

function LanguageChanged(lang)
	if not IsValid(pnlMainMenu) then return end
end

timer.Simple(0, function()
	pnlMainMenu = vgui.Create("MainMenuPanel")
	local language = GetConVarString("gmod_language")
	LanguageChanged(language)
	hook.Run("MenuStart")
end)