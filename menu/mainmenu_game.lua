local PANEL = {}

function PANEL:Init()
	self.maptitlelabel = vgui.Create("DLabel", self)
	self.maptitlelabel:SetPos((self:GetWide() - 30) * 0.75 + 15, 15)
	self.maptitlelabel:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.maptitlelabel:SetText("...")
	self.maptitlelabel:SetColor(Color(255, 255, 255, 255))

	self.startbtn = makeMenuButton(self, "Start game", 15, self:GetTall() - 45, self:GetWide() - 85, 30)
	function self.startbtn:DoClick()
		self:GetParent():StartHideAnimation(function()
			pnlMainMenu:StartGame()
			pnlMainMenu:StartShowAnimation(function() end)
		end)
	end
	self.backbtn = makeMenuButton(self, "Back", self:GetWide() - 80, self:GetTall() - 45, 65, 30)
	function self.backbtn:DoClick()
		self:GetParent():StartHideAnimation(function()
			pnlMainMenu:StartShowAnimation(function() end)
		end)
	end

	function self:UpdateGamemodeInfo()
		local array = {
			hostname = GetConVarString("hostname"),
			sv_lan = GetConVarString("sv_lan"),
			p2p_enabled = GetConVarString("p2p_enabled")
		}
		local settings_file = file.Read("gamemodes/" .. engine.ActiveGamemode() .. "/" .. engine.ActiveGamemode() .. ".txt", true)
		if (settings_file) then
			local Settings = util.KeyValuesToTable(settings_file)
			if (istable(Settings.settings)) then
				array.settings = {}
				for k, v in pairs(Settings.settings) do
					local cvar = GetConVar(v.name)
					if not cvar then continue end
					array.settings[k] = v
					array.settings[k].CVar = cvar
					array.settings[k].Value = cvar:GetString()
					array.settings[k].Singleplayer = v.singleplayer && true || false
				end
			end
		end
		if self.settings then self.settings:Remove() end
		self.settings = vgui.Create("DScrollPanel", self)
		self.settings:SetPos((self:GetWide() - 30) * 0.75 + 30, 60)
		self.settings:SetSize((self:GetWide() - 40) * 0.25, self:GetTall() - 120)

		local panel = self.settings:Add("Panel")
		panel:Dock(TOP)
		panel:DockMargin(5, 0, 5, 5)
		panel:SetMouseInputEnabled(true)
		local control = makeMenuButton(panel, "Gamemode", 0, 0, 0, 0)
		function control:DrawAfter(w, h)
			if not control:IsHovered() then return end
			hook.Add("DrawOverlay", control, function()
				if not control:IsHovered() then hook.Remove("DrawOverlay", control) return end
				local mx = gui.MouseX()
				local my = gui.MouseY()

				surface.SetFont(self:GetFont() or "Default")
				local width, height = surface.GetTextSize("Gamemode with what game will begin.")
				surface.SetDrawColor(Color(0, 127, 255, 127))
				surface.DrawRect(mx - width - 10, my, width+10, height+10)
				draw.DrawText("Gamemode with what game will begin.", self:GetFont() or "Default", mx-5 - width, my+5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			end)
		end
		function control:DoClick()
			local menu = DermaMenu()
			local HideGamemodes = {
				base = true
			}
			for _, gm in pairs(engine.GetGamemodes()) do
				if HideGamemodes[gm.name] then continue end
				menu:AddOption(gm.title, function() RunConsoleCommand("gamemode", gm.name) end):SetIcon("gamemodes/"..gm.name.."/icon24.png")
			end
			menu:Open()
		end
		control:Dock(FILL)
		control:DockMargin(5, 0, 5, 5)
		control:SetMouseInputEnabled(true)
		panel:SizeToContents()

		local panel = self.settings:Add("Panel")
		panel:Dock(TOP)
		panel:DockMargin(5, 0, 5, 5)
		panel:SetMouseInputEnabled(true)
		local lbl = vgui.Create("DLabel", panel)
		lbl:SetText("Max players")
		lbl:SetZPos(128)
		lbl:SetMouseInputEnabled(true)
		function lbl:Paint()
			if not lbl:IsHovered() then return end
			hook.Add("DrawOverlay", lbl, function()
				if not lbl:IsHovered() then hook.Remove("DrawOverlay", lbl) return end
				local mx = gui.MouseX()
				local my = gui.MouseY()

				surface.SetFont(self:GetFont() or "Default")
				local width, height = surface.GetTextSize("Max players count.")
				surface.SetDrawColor(Color(0, 127, 255, 127))
				surface.DrawRect(mx - width - 10, my, width+10, height+10)
				draw.DrawText("Max players count.", self:GetFont() or "Default", mx-5 - width, my+5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			end)
		end
		local control = vgui.Create("DNumberWang", panel)
		function control:OnValueChanged(s)
			RunConsoleCommand("maxplayers", tostring(s))
		end
		function control:Think()
			if self:GetValue() < self:GetMax() and self:GetValue() > self:GetMin() then return end
			self:SetValue(math.max(self:GetMin(), math.min(self:GetMax(), self:GetValue())))
		end
		control:SetValue(1)
		control:SetMin(1)
		control:SetMax(128)
		control:Dock(FILL)
		control:DockMargin(5, 0, 5, 5)
		lbl:SizeToContents()
		lbl:Dock(LEFT)
		lbl:DockMargin(5, 0, 5, 5)
		control:SetMouseInputEnabled(true)
		panel:SizeToContents()

		for _,setting in pairs(array.settings or {}) do
			local type = setting.type
			local value = setting.Value
			local sinply = setting.Singleplayer

			local class = "DTextEntry"
			if type == "CheckBox" then
				class = "DCheckBox"
			end

			local panel = self.settings:Add("Panel")
			panel:Dock(TOP)
			panel:DockMargin(5, 0, 5, 5)
			panel:SetMouseInputEnabled(true)

			local lbl = vgui.Create("DLabel", panel)
			lbl:SetText(language.GetPhrase(setting.text) or setting.text)
			lbl.setting = setting
			lbl:SetZPos(128)
			lbl:SetMouseInputEnabled(true)

			function lbl:Paint()
				if not lbl:IsHovered() then return end
				hook.Add("DrawOverlay", lbl, function()
					if not lbl:IsHovered() then hook.Remove("DrawOverlay", lbl) return end
					local mx = gui.MouseX()
					local my = gui.MouseY()

					surface.SetFont(self:GetFont() or "Default")
					local width, height = surface.GetTextSize(lbl.setting.help)
					surface.SetDrawColor(Color(0, 127, 255, 127))
					surface.DrawRect(mx - width - 10, my, width+10, height+10)
					draw.DrawText(lbl.setting.help, self:GetFont() or "Default", mx-5 - width, my+5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
				end)
			end

			local control = vgui.Create(class, panel)

			lbl:SizeToContents()
			lbl:Dock(LEFT)
			lbl:DockMargin(5, 0, 5, 5)
			control:SetMouseInputEnabled(true)
			if type == "CheckBox" then
				control:Dock(RIGHT)
				control:DockMargin(5, 0, 5, 5)
				control:SetSize(lbl:GetTall()+6, lbl:GetTall())
				control:SetPos(lbl:GetX()-3, lbl:GetY())
			else
				control:Dock(FILL)
				control:DockMargin(5, 0, 5, 5)
			end
			panel:SizeToContents()

			control.setting = setting
			if type == "Text" then
				function control:OnEnter(s)
					RunConsoleCommand(self.setting.CVar:GetName(), tostring(s))
					--self.setting.CVar:SetString(s)
				end
				control:SetText(tostring(value))
				control:SetValue(tostring(value))
			elseif type == "Numeric" then
				control:SetNumeric(true)
				function control:OnEnter(s)
					RunConsoleCommand(self.setting.CVar:GetName(), tostring(s))
					--self.setting.CVar:SetFloat(tonumber(s))
				end
				control:SetValue(tostring(value))
			elseif type == "CheckBox" then
				function control:OnChange(c)
					RunConsoleCommand(self.setting.CVar:GetName(), tostring(tonumber(c)))
					--self.setting.CVar:SetBool(c)
				end
				control:SetChecked(tobool(value))
			end
		end
	end

	function self:UpdateMaps()
		local IgnorePatterns = {
			"^background",
			"^devtest",
			"^ep1_background",
			"^ep2_background",
			"^styleguide",
		}
		local IgnoreMaps = {
			[ "sdk_" ] = true,
			[ "test_" ] = true,
			[ "vst_" ] = true,
			[ "c4a1y" ] = true,
			[ "credits" ] = true,
			[ "d2_coast_02" ] = true,
			[ "d3_c17_02_camera" ] = true,
			[ "ep1_citadel_00_demo" ] = true,
			[ "c5m1_waterfront_sndscape" ] = true,
			[ "intro" ] = true,
			[ "test" ] = true
		}

		local maps = file.Find("maps/*.bsp", "GAME")
		if self.mapslist then self.mapslist:Remove() end
		local mapslistscroller = vgui.Create("DScrollPanel", self)
		self.mapslist = vgui.Create("DGrid", mapslistscroller)
		self.mapslist.scroller = mapslistscroller
		self.mapslist:SetPos(15, 15)
		self.mapslist:SetSize((self:GetWide() - 30) * 0.75, self:GetTall() - 70)
		self.mapslist.scroller:SetPos(15, 15)
		self.mapslist.scroller:SetSize((self:GetWide() - 30) * 0.75, self:GetTall() - 70)
		--self.mapslist
		self.mapslist:SetColWide(128)
		self.mapslist:SetRowHeight(128)
		self.mapslist:SetCols(math.floor(self.mapslist:GetWide() / 128))
		self.mapslist.scroller:SetWide(math.floor(self.mapslist:GetWide() / 128)*128+25)
		self.mapslist.maps = {}
		local mapthumbs = file.Find("maps/thumb/*", "GAME")
		function tableKeyFromVal(tbl, value)
			for k,v in pairs(tbl) do
				if v == value then return k end
			end
			return false
		end
		for _,m in pairs(maps) do
			local name = string.lower(string.gsub(m, "%.bsp$", ""))
			local prefix = string.match(name, "^(.-_)")
			local Ignore = IgnoreMaps[name] or IgnoreMaps[prefix]

				local btn = makeMenuButton(self.mapslist, name, 0, 0, 128, 128)
				btn.map = m
				self.mapslist:AddItem(btn)
				self.mapslist.maps[_] = btn
				if m == self:GetParent().gamedata.map then 
					self.omapbtn = btn
					btn:SetColor(Color(150, 150, 150, 40))
					self.pickedmap = btn.map
					self.maptitlelabel:SetText(btn:GetButtonText())
				end
				function btn:DoClick()
					self:GetParent():GetParent():GetParent():GetParent():PickMap(btn)
				end
				local mat = ""
				if tableKeyFromVal(mapthumbs, name..".png") then
					mat = "maps/thumb/"..name..".png"
				end
				btn.material = Material(mat)

				function btn:DrawBackground(w,h)
					local c = self.drawcolor or self:GetColor()
					local oa = c.a
					c.a = 255
					surface.SetDrawColor(c)
					if not self.material or self.material:IsError() then self.material = Material("effects/tvscreen_noise002a") end
					surface.SetMaterial(self.material)
					surface.DrawTexturedRect(0,0,w,h)
					c.a = oa
				end
				local c = btn:GetColor()
				btn:SetColor(Color(c.r, c.g, c.b, 40))
				local c = btn:GetHoverColor()
				btn:SetHoverColor(Color(c.r, c.g, c.b, 40))
				function btn:Draw(w, h)
					local c = self.drawcolor or self:GetColor()
					surface.SetDrawColor(c)
					surface.DrawRect(0, 0, w, h)
					surface.SetFont(self:GetFont() or "Default")
					local width, height = surface.GetTextSize(self:GetButtonText())
					draw.DrawText(self:GetButtonText(), self:GetFont() or "Default", w / 2 - width / 2, h / 2 - height / 2, self:GetTextColor(), TEXT_ALIGN_CENTER)
				end
		end
	end

	local function DelayedRefreshMaps()
		timer.Create("menu_refreshmaps", 0.1, 1, function() self:UpdateMaps() end)
	end
	hook.Add("MenuStart", "FindMaps", DelayedRefreshMaps)
	hook.Add("GameContentChanged", "RefreshMaps", DelayedRefreshMaps)
end

function PANEL:PickMap(mapbtn)
	if self.omapbtn then self.omapbtn:SetColor(Color(82, 82, 82, 40)) self.omapbtn.settobase = true end
	self.omapbtn = mapbtn
	mapbtn:SetColor(Color(150, 150, 150, 40))
	self.pickedmap = mapbtn.map
	self:GetParent().gamedata.map = self.pickedmap
	self.maptitlelabel:SetText(self.gamemode.title .. ": " .. mapbtn:GetButtonText())
end

function PANEL:DrawBackground(w, h)
	surface.SetDrawColor(Color(25, 25, 25, 127))
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Paint(w, h)
	self.startbtn:SetSize(w-100, 30)
	self.startbtn:SetPos(15, h - 45)

	self.backbtn:SetSize(65, 30)
	self.backbtn:SetPos(w - 80, h - 45)

	self.maptitlelabel:SetPos((w - 30) * 0.75 + 15, 15)
	self.maptitlelabel:SetSize((w - 40) * 0.25, 30)

	self:DrawBackground(w, h)

	if not self.mapslist then return end
	if not self.gamemode or engine.ActiveGamemode() ~= self.gamemode.name then
		local gm
		for _,g in pairs(engine.GetGamemodes()) do
			if g.name == engine.ActiveGamemode() then gm = g break end
		end
		self.gamemode = gm
		if not self.omapbtn then self.omapbtn = self.mapslist.maps[1] end
		self.maptitlelabel:SetText(self.gamemode.title .. ": " .. self.omapbtn:GetButtonText())
		self:UpdateGamemodeInfo()
		self:PickMap(self.omapbtn)
	end
end

function PANEL:StartHideAnimation(callback)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local from_x = self:GetX()
	local _mt = Derma_Anim("StartGameMenuHideAnim", self, function(pnl, anim, delta, data)
		pnl:SetPos(easeOutCubic(delta, from_x, ScrW()), pnl:GetY())
	end)
	function self:Think()
		if _mt:Active() then
			_mt:Run()
		else
			function self:Think() end
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
	local from_x = self:GetX()
	local _mt = Derma_Anim("StartGameMenuShowAnim", self, function(pnl, anim, delta, data)
		pnl:SetPos(easeOutCubic(delta, from_x, 10), pnl:GetY())
	end)
	function self:Think()
		if _mt:Active() then
			_mt:Run()
		else
			function self:Think() end
			callback()
		end
	end
	_mt:Start(0.5*animationSpeed)
end

vgui.Register("MainMenuStartGamePanel", PANEL, "EditablePanel")