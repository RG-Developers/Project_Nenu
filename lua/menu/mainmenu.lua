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
	log("debug", "Main panel initialisation.")
	RunConsoleCommand("stopsound")
	self.allow_music = false
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

	log("debug", "Base menu panel initialisation.")
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

	log("debug", "Start game menu panel initialisation.")
	pnlStartGameMenu = vgui.Create("MainMenuStartGamePanel", self)
	pnlStartGameMenu:SetPos(ScrW(), 10)
	pnlStartGameMenu:SetSize(ScrW() - 20, ScrH() - 20)
	pnlStartGameMenu:MakePopup()

	log("debug", "Addons menu panel initialisation.")
	pnlAddonsMenu = vgui.Create("MainMenuAddonsPanel", self)
	pnlAddonsMenu:SetPos(ScrW(), 10)
	pnlAddonsMenu:SetSize(ScrW() - 20, ScrH() - 20)
	pnlAddonsMenu:MakePopup()

	log("debug", "Connect menu panel initialisation.")
	pnlConnectMenu = vgui.Create("MainMenuConnectPanel", self)
	pnlConnectMenu:SetPos(ScrW(), 10)
	pnlConnectMenu:SetSize(ScrW() - 20, ScrH() - 20)
	pnlConnectMenu:MakePopup()

	self.gmpanelx = ScrW()
	self.gmpanelhidden = true

	log("debug", "Menu init done.")
	self:StartShowAnimation(function() end)

	timer.Simple(.02, function() self.allow_music = true end)
	--pnlConnectMenu:UpdateServers()
end

function PANEL:StartMenuMusic()
	local function SoundDuration(snd)
		return ({["title2.ogg"] = 1*60+58, ["title3.ogg"] = 3*60+52})[snd]
	end
	self.playing_music = true
	local fs, _ = file.Find("sound/nenu/menu/*", "GAME")
	local s = fs[math.random(1, #fs)]
	surface.PlaySound("nenu/menu/"..s)
	timer.Simple(SoundDuration(s)+15, function()
		self.playing_music = false
		if not IsInGame() then
			self:StartMenuMusic()
		end
	end)
end

local bg_mat = nil
local bg_st = SysTime()
local bg_alpha = 255

function PANEL:DrawBackground()
	local a = 255
	if IsInGame() then
		a = 25
	end
	surface.SetDrawColor(Color(0, 0, 0, a))
	surface.DrawRect(0, 0, ScrW(), ScrH())
	surface.SetDrawColor(Color(0, 0, 0, 255))
	if not IsInGame() then
		if not bg_mat then
			local fs, _ = file.Find("gamemodes/"..engine.ActiveGamemode().."/backgrounds/*", "GAME")
			local ps = "gamemodes/"..engine.ActiveGamemode().."/backgrounds/"
			if #fs == 0 then
				fs, _ = file.Find("backgrounds/*", "GAME")
				ps = "backgrounds/"
			end
			local obgm = bg_mat
			while bg_mat == obgm do
				bg_mat = Material(ps..fs[math.random(1, #fs)])
			end
			bg_st = SysTime()
		end
		local off = 100
		surface.SetDrawColor(Color(255, 255, 255, bg_alpha))
		surface.SetMaterial(bg_mat)
		sh = ScrH() + off
		sw = (ScrH() / bg_mat:GetTexture("$basetexture"):Height()) * bg_mat:GetTexture("$basetexture"):Width() + off
		surface.DrawTexturedRect(-(SysTime() - bg_st)*off/10, -off/2, sw, sh)
		if -(SysTime() - bg_st)*off/10 < -50 then
			bg_mat = nil
		end
	end
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
		bg_alpha = easeOutCubic(delta, 255, 25)
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
		bg_alpha = easeOutCubic(delta, 25, 255)
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

local rgd_logo = Material("nenu/rgd_logo.png")
function PANEL:Paint(w, h)
	self:DrawBackground()

	if not IsInGame() and not self.playing_music and self.allow_music then self:StartMenuMusic() end

	if self.gmname ~= engine.ActiveGamemode() then
		self.gmname = engine.ActiveGamemode() or "base"
		local mat = "gamemodes/"..self.gmname.."/logo.png"
		local material = Material(mat)
		if material:IsError() then return end
		self.material = material
	end

	surface.SetDrawColor(Color(255, 255, 255))
	surface.SetMaterial(rgd_logo)
	surface.DrawTexturedRect(self.gmpanelx + w - rgd_logo:GetTexture("$basetexture"):Width() - 10, h-10-rgd_logo:GetTexture("$basetexture"):Height(), rgd_logo:GetTexture("$basetexture"):Width(), rgd_logo:GetTexture("$basetexture"):Height())

	if not self.material then return end
	surface.SetDrawColor(Color(255, 255, 255))
	surface.SetMaterial(self.material)
	surface.DrawTexturedRect(self.gmpanelx + w - self.material:GetTexture("$basetexture"):Width() - 10, 10, self.material:GetTexture("$basetexture"):Width(), self.material:GetTexture("$basetexture"):Height())
end

log("debug", "Main menu panel register.")
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
	log("debug", "Local game start.")
	log("load", "Local game start.\nGamedata init.")
	self.gamedata.shostname = "Local game"
	GetLoadingPanel().startTime = SysTime()
	GetLoadingPanel().gamedata = self.gamedata
	GetLoadingPanel().gamedata.pt = SysTime()
	hook.Run("StartGame")
	RunConsoleCommand("progress_enable")
	RunConsoleCommand("disconnect")
	RunConsoleCommand("stopsound")
	if tonumber(self.gamedata.maxplayers) > 1 then
		RunConsoleCommand("sv_cheats", "0")
		RunConsoleCommand("commentary", "0")
	end
	RunConsoleCommand("hostname", self.gamedata.hostname)
	RunConsoleCommand("p2p_enabled", self.gamedata.p2p_enabled and 1 or 0)
	RunConsoleCommand("p2p_friendsonly", self.gamedata.p2p_friendsonly and 1 or 0)
	RunConsoleCommand("sv_lan", self.gamedata.lan and 1 or 0)
	RunConsoleCommand("maxplayers", tostring(self.gamedata.maxplayers))
	RunConsoleCommand("map", self.gamedata.map)
end

function PANEL:Connect(server)
	log("debug", "Connect game start.")
	log("load", "Connect game start.\nGamedata init.")
	self.gamedata.shostname = server.name
	self.gamedata.map = server.map
	GetLoadingPanel().startTime = SysTime()
	GetLoadingPanel().gamedata = self.gamedata
	GetLoadingPanel().gamedata.pt = SysTime()
	log("load", "Server gamemode addon not mounted!")
	if not steamworks.ShouldMountAddon(server.gmwsid) then
		if steamworks.IsSubscribed(server.gmwsid) then
			log("load", "Addon found, enabling...")
			print("Temp-enabling addon id "..server.gmwsid.." for server '"..server.name.."' gamemode")
			steamworks.SetShouldMountAddon(server.gmwsid, true)
		else
			log("load", "Server gamemode is not even installed! Aborting.")
			print("Server '"..server.name.."' gamemode is not installed.!")
			steamworks.ViewFile(server.gmwsid)
			return
		end
	end
	hook.Run("StartGame")
	RunConsoleCommand("progress_enable")
	RunConsoleCommand("disconnect")
	RunConsoleCommand("stopsound")
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
	log("debug", "Quit.")
	self:StartHideAnimation(function()
		RunGameUICommand("engine quit")
	end)
end

function PANEL:Disconnect()
	log("debug", "Disconnect.")
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