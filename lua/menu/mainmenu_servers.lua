local ServerList = {}

local PANEL = {}

function PANEL:Init()
	self.StopQuery = false
	self.filters = {false, false, false, false}

	self.servinfopnl = vgui.Create("DPanel", self)
	self.servinfopnl:SetPos((self:GetWide() - 30) * 0.75 + 15, 15)
	self.servinfopnl:SetSize((self:GetWide() - 40) * 0.25, self:GetTall() - 70)
	function self.servinfopnl:Paint() end

	self.servgmlabel = vgui.Create("DLabel", self.servinfopnl)
	--self.servgmlabel:SetPos((self:GetWide() - 30) * 0.75 + 15, 15)
	self.servgmlabel:SetSize((self:GetWide() - 40) * 0.25, 40)
	self.servgmlabel:SetText("...")
	self.servgmlabel:SetColor(Color(255, 255, 255, 255))
	self.servgmlabel:SetFont("DermaLarge")
	self.servgmlabel:Dock(TOP)

	self.servnmlabel = vgui.Create("DLabel", self.servinfopnl)
	--self.servnmlabel:SetPos((self:GetWide() - 30) * 0.75 + 15, 55)
	self.servnmlabel:SetSize((self:GetWide() - 40) * 0.25, 20)
	self.servnmlabel:SetText("...")
	self.servnmlabel:SetColor(Color(255, 255, 255, 255))
	self.servnmlabel:Dock(TOP)

	self.servdatalabel = vgui.Create("DLabel", self.servinfopnl)
	--self.servdatalabel:SetPos((self:GetWide() - 30) * 0.75 + 15, 190)
	self.servdatalabel:SetSize((self:GetWide() - 40) * 0.25, 256)
	self.servdatalabel:SetText("...")
	self.servdatalabel:SetColor(Color(255, 255, 255, 255))
	self.servdatalabel:Dock(TOP)

	self.filter_passwordonly = vgui.Create("DCheckBoxLabel", self.servinfopnl)
	self.filter_passwordonly:SetText("Filter servers without password")
	function self.filter_passwordonly:OnChange(v)
		self:GetParent():GetParent().filters[1] = v
	end
	self.filter_passwordonly:SetValue(false)
	self.filter_passwordonly:SizeToContents()
	self.filter_passwordonly:Dock(TOP)

	self.filter_nopasswordonly = vgui.Create("DCheckBoxLabel", self.servinfopnl)
	self.filter_nopasswordonly:SetText("Filter servers with password")
	function self.filter_nopasswordonly:OnChange(v)
		self:GetParent():GetParent().filters[2] = v
	end
	self.filter_nopasswordonly:SetValue(false)
	self.filter_nopasswordonly:SizeToContents()
	self.filter_nopasswordonly:Dock(TOP)

	self.filter_noplayers = vgui.Create("DCheckBoxLabel", self.servinfopnl)
	self.filter_noplayers:SetText("Filter servers without players")
	function self.filter_noplayers:OnChange(v)
		self:GetParent():GetParent().filters[3] = v
	end
	self.filter_noplayers:SetValue(false)
	self.filter_noplayers:SizeToContents()
	self.filter_noplayers:Dock(TOP)

	self.filter_fullserver = vgui.Create("DCheckBoxLabel", self.servinfopnl)
	self.filter_fullserver:SetText("Filter full servers")
	function self.filter_fullserver:OnChange(v)
		self:GetParent():GetParent().filters[4] = v
	end
	self.filter_fullserver:SetValue(false)
	self.filter_fullserver:SizeToContents()
	self.filter_fullserver:Dock(TOP)

	self.connectbtn = makeMenuButton(self, "Connect", 15, self:GetTall() - 45, self:GetWide() - 85, 30)
	function self.connectbtn:DoClick()
		self:GetParent().StopQuery = true
		self:GetParent():StartHideAnimation(function()
			if self:GetParent().pickedserv.hasPassword then
				self:GetParent():RequestPassword(function(password)
					pnlMainMenu:Connect(self:GetParent().pickedserv, password)
					pnlMainMenu:StartShowAnimation(function() end)
				end, function()
					self:GetParent():StartShowAnimation(function() end)
				end)
				return
			end
			pnlMainMenu:Connect(self:GetParent().pickedserv)
			pnlMainMenu:StartShowAnimation(function() end)
		end)
	end

	self.backbtn = makeMenuButton(self, "Back", self:GetWide() - 80, self:GetTall() - 45, 65, 30)
	function self.backbtn:DoClick()
		self:GetParent():StartHideAnimation(function()
			pnlMainMenu:StartShowAnimation(function() end)
		end)
	end

	self.update = makeMenuButton(self.servinfopnl, "Update serverlist", (self:GetWide() - 30) * 0.75 + 30, 120, (self:GetWide() - 40) * 0.25, 30)
	function self.update:DoClick()
		self:GetParent():GetParent():UpdateServers()
	end
	self.update:Dock(TOP)
	self.update:DockMargin(5, 5, 5, 5)

	self.stop = makeMenuButton(self.servinfopnl, "Stop updating", (self:GetWide() - 30) * 0.75 + 30, 155, (self:GetWide() - 40) * 0.25, 30)
	function self.stop:DoClick()
		self:GetParent():GetParent().StopQuery = true
	end
	function self.stop:Think()
		self:SetPVisible(not self:GetParent():GetParent().StopQuery)
	end
	self.stop:Dock(TOP)
	self.stop:DockMargin(5, 5, 5, 5)

	self.mkfav = makeMenuButton(self.servinfopnl, "Favourite", (self:GetWide() - 30) * 0.75 + 30, 190, (self:GetWide() - 40) * 0.25, 30)
	function self.mkfav:DoClick()
		local fs = self:GetParent():GetParent().serverlist.categories.favservers
		local ps = self:GetParent():GetParent().pickedserv
		if fs[ps.address] then
			fs[ps.address] = nil
			SaveFavServers(fs)
			self:GetParent():GetParent().serverlist.categories.favservers = GetFavServers()
			if self:GetParent():GetParent().pickedcat == "favourite" then
				self:GetParent():GetParent():PickCategory(self:GetParent():GetParent().serverlist.categories.fav)
			end
			return
		end
		fs[ps.address] = true
		SaveFavServers(fs)
		self:GetParent():GetParent().serverlist.categories.favservers = GetFavServers()
	end
	function self.mkfav:Think()
		self:SetPVisible(self:GetParent():GetParent().pickedserv)
		if self:GetParent():GetParent().pickedserv then
			local fs = self:GetParent():GetParent().serverlist.categories.favservers
			if fs[self:GetParent():GetParent().pickedserv.address] then
				self:SetButtonText("Unfavorite")
			else
				self:SetButtonText("Favorite")
			end
		end
	end
	self.mkfav:Dock(TOP)
	self.mkfav:DockMargin(5, 5, 5, 5)

	function self:UpdateServers()
		if self.serverlist then
			self.serverlist.categories:Remove()
			self.serverlist.servers:Remove()
			self.serverlist = {}
		end
		self.pickedcat = "favourite"
		ServerList = {}
		self.serverlist = {}
		self.serverlist.filters = self.filters
		self.serverlist.categories = vgui.Create("DScrollPanel", self)
		self.serverlist.categories:SetPos(15, 15)
		self.serverlist.categories:SetSize((self:GetWide() - 30) * 0.75 * 0.5, self:GetTall() - 70)
		self.serverlist.categories.cats = {}

		self.serverlist.categories.favservers = GetFavServers()
		self.serverlist.categories.fav = makeMenuButton(self.serverlist.categories, "Favourite", 0, 0, 0, 0)
		self.serverlist.categories:Add(self.serverlist.categories.fav)
		self.serverlist.categories.fav:Dock(TOP)
		self.serverlist.categories.fav:SetSize(self.serverlist.categories.fav:GetWide(), 30)
		self.serverlist.categories.fav:DockMargin(5, 0, 5, 5)
		self.serverlist.categories.fav.cat = "favourite"
		function self.serverlist.categories.fav:DoClick()
			self:GetParent():GetParent():GetParent():PickCategory(self)
		end

		self.serverlist.servers = vgui.Create("DScrollPanel", self)
		self.serverlist.servers:SetPos(15 + (self:GetWide() - 30) * 0.75 * 0.5, 15)
		self.serverlist.servers:SetSize((self:GetWide() - 30) * 0.75 * 0.5 - 15, self:GetTall() - 70)
		self.serverlist.servers.servs = {}

		self.StopQuery = false
		self:PickCategory(self.serverlist.categories.fav)

		serverlist.Query({
			Callback = function(serverPing, serverName, serverGMName, serverMap,
								serverPlayers, serverMaxPlayers, serverBotPlayers,
								serverHasPassword, lastTimePlayed, serverAddress,
								serverGamemode, serverGamemodeWSID, serverIsAnonymous,
								serverVersion, serverVection2, serverLocale, serverCategory)
				if not ServerList[serverGamemode] then ServerList[serverGamemode] = {} end
				ServerList[serverGamemode][#ServerList[serverGamemode]+1] = {ping = serverPing,
											 name = serverName, nicegmname = serverGMName, map = serverMap,
											 players = serverPlayers, maxPlayers = serverMaxPlayers, botPlayers = serverBotPlayers,
											 hasPassword = serverHasPassword,
											 gm = serverGamemode, gmwsid = serverGamemodeWSID,
											 anonymous = serverIsAnonymous,
											 version = serverVersion, locale = serverLocale,
											 category = serverCategory,
											 address = serverAddress}
				if not self or not self.serverlist then return end
				if self.serverlist.filters[1] and not serverHasPassword then return end
				if self.serverlist.filters[2] and serverHasPassword then return end
				if self.serverlist.filters[3] and serverPlayers - serverBotPlayers <= 0 then return end
				if self.serverlist.filters[4] and serverPlayers == serverMaxPlayers then return end

				if not self.serverlist.categories.cats[serverGamemode] then
					self.serverlist.categories.cats[serverGamemode] = true
					local btn = makeMenuButton(self.serverlist.categories, serverGMName, 0, 0, 0, 0)
					self.serverlist.categories:Add(btn)
					btn:Dock(TOP)
					btn:SetSize(btn:GetWide(), 30)
					btn:DockMargin(5, 0, 5, 5)
					btn.cat = serverGamemode
					function btn:DoClick()
						self:GetParent():GetParent():GetParent():PickCategory(self)
					end
					if btn.cat == self.pickedcat then self:PickCategory(btn) end
				end

				local btn = makeMenuButton(self.serverlist, serverName, 0, 0, 0, 0)
				self.serverlist.servers:Add(btn)
				btn:Dock(TOP)
				btn:SetSize(btn:GetWide(), 30)
				btn:DockMargin(5, 0, 5, 5)
				btn.serv = ServerList[serverGamemode][#ServerList[serverGamemode]]
				btn.cat = serverGamemode
				self.serverlist.servers.servs[#self.serverlist.servers.servs+1] = btn
				if self.pickedcat ~= "favourite" then
					btn:SetVisible(btn.cat == self.pickedcat)
				else
					btn:SetVisible(self.serverlist.categories.favservers[btn.serv.address] or false)
				end
				function btn:DoClick()
					self:GetParent():GetParent():GetParent():PickServer(self)
				end
				if self.StopQuery then return false end
			end,
			CallbackFailed = function(serverAddress)
				--print("Server list callback failed for "..serverAddress)
			end,
			Finished = function()
				self.StopQuery = true
			end
		})
	end

	local function DelayedRefreshServers()
		timer.Create("menu_refreshservers", 0.1, 1, function() self:UpdateServers() end)
	end

	hook.Add("MenuStart", "FindServers", DelayedRefreshServers)
end

function PANEL:RequestPassword(callbackOK, callbackBACK)
	local pnl = {}
	function pnl:Init()
		self:SetDraggable(false)
		self:ShowCloseButton(false)
		self:SetTitle("Server requires password to join.")
		self.passwdte = vgui.Create("DTextEntry", self)
		self.passwdte.drawcolor = Color(82, 82, 82, 82)
		self.passwdte:SetPlaceholderText("Input password...")
		function self.passwdte:Paint(w, h)
			local oa = self.drawcolor.a
			if IsInGame() then self.drawcolor.a = math.Clamp(self.drawcolor.a + 50, 0, 255) end
			surface.SetDrawColor(self.drawcolor)
			surface.DrawRect(0, 0, w, h)
			surface.SetFont("Default")
			local width, height = surface.GetTextSize(self:GetValue())
			if self:GetValue() == "" then
				width, height = surface.GetTextSize(self:GetPlaceholderText())
				local c = Color(self:GetTextColor().r - 100, self:GetTextColor().g - 100, self:GetTextColor().b - 100)
				draw.DrawText(self:GetPlaceholderText(), "Default", w / 2 - width / 2, h / 2 - height / 2, c, TEXT_ALIGN_CENTER)
			else
				draw.DrawText(self:GetValue(), "Default", w / 2 - width / 2, h / 2 - height / 2, self:GetTextColor(), TEXT_ALIGN_CENTER)
			end
			if IsInGame() then self.drawcolor.a = oa end
		end
		self.passwdte:SetTextColor(Color(255, 255, 255, 255))
		self.passwdte:Dock(TOP)
		self.passwdte:DockMargin(5,5,0,5)
		self.passwdte:SetSize(self.passwdte:GetWide(), 30)

		self.okbtn = makeMenuButton(self, "Connect", 0, 0, 0, 0)
		function self.okbtn:DoClick()
			self:GetParent():StartHideAnimation(function()
				self:GetParent().callbackOK(self:GetParent().passwdte:GetValue())
			end)
		end
		self.okbtn:SizeToContents()
		self.okbtn:Dock(TOP)
		self.okbtn:DockMargin(5,5,0,5)

		self.backbtn = makeMenuButton(self, "Cancel", 0, 0, 0, 0)
		function self.backbtn:DoClick()
			self:GetParent():StartHideAnimation(function()
				self:GetParent().callbackBACK()
			end)
		end
		self.backbtn:SizeToContents()
		self.backbtn:Dock(TOP)
		self.backbtn:DockMargin(5,5,0,5)

		self:SizeToContents()
		self:MakePopup()
	end
	function pnl:DrawBackground(w, h)
		surface.SetDrawColor(Color(25, 25, 25, 127))
		surface.DrawRect(0, 0, w, h)
	end
	function pnl:Paint(w, h)
		self:DrawBackground(w, h)
	end
	function pnl:StartHideAnimation(callback)
		local function easeOutCubic(x, from, to)
			local d = 1 - math.pow(1 - x, 3)
			return (from * (1-d)) + (to * d)
		end
		local from_x = self:GetX()
		local _mt = Derma_Anim("ConnectGamePasswordRequestHideAnim", self, function(pnl, anim, delta, data)
			pnl:SetPos(easeOutCubic(delta, from_x, -self:GetWide()), pnl:GetY())
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

	function pnl:StartShowAnimation(callback)
		local function easeOutCubic(x, from, to)
			local d = 1 - math.pow(1 - x, 3)
			return (from * (1-d)) + (to * d)
		end
		local from_x = self:GetX()
		local _mt = Derma_Anim("ConnectGamePasswordRequestShowAnim", self, function(pnl, anim, delta, data)
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
	local pnl = vgui.CreateFromTable(vgui.RegisterTable(pnl, "DFrame"), self)
	pnl:SetSize(ScrW() / 4, ScrH() / 4)
	pnl:SetPos(-pnl:GetWide(), 10)
	pnl:StartShowAnimation(function() end)
	pnl.callbackOK = callbackOK
	pnl.callbackBACK = callbackBACK
end

function PANEL:PickCategory(catbtn)
	if self.ocatbtn and IsValid(self.ocatbtn) then self.ocatbtn:SetColor(Color(82, 82, 82, 40)) self.ocatbtn.settobase = true end
	self.ocatbtn = catbtn
	catbtn:SetColor(Color(150, 150, 150, 40))
	self.pickedcat = catbtn.cat
	if self.pickedcat ~= "favourite" then
		for _,btn in pairs(self.serverlist.servers.servs) do
			btn:SetVisible(btn.cat == self.pickedcat)
		end
	else
		for _,btn in pairs(self.serverlist.servers.servs) do
			btn:SetVisible(self.serverlist.categories.favservers[btn.serv.address] or false)
		end
	end
	self.servgmlabel:SetText(catbtn:GetButtonText())
	self.servnmlabel:SetText("...")
	self.servdatalabel:SetText("...")
	self.pickedserv = nil
	if not self.oservbtn or not IsValid(self.oservbtn) then return end
	self.oservbtn:SetColor(Color(82, 82, 82, 82))
	self.oservbtn.settobase = true
	self.oservbtn = nil
end

function PANEL:PickServer(servbtn)
	if self.oservbtn and IsValid(self.oservbtn) then self.oservbtn:SetColor(Color(82, 82, 82, 82)) self.oservbtn.settobase = true end
	self.oservbtn = servbtn
	servbtn:SetColor(Color(150, 150, 150, 40))
	self.pickedserv = servbtn.serv
	self.servnmlabel:SetText(servbtn:GetButtonText())
	self.servdatalabel:SetText("Ping: "..servbtn.serv.ping.."ms\n"..
							   "Players: "..servbtn.serv.players.." / "..servbtn.serv.maxPlayers.." ("..servbtn.serv.botPlayers.." bots)\n"..
							   "Map: "..servbtn.serv.map.."\n"..
							   "Address: "..servbtn.serv.address.."\n\n"..
							   "Password only: "..(servbtn.serv.hasPassword and "YES" or "NO").."\n\n"..
							   "Ready to connect.")
end

function PANEL:DrawBackground(w, h)
	surface.SetDrawColor(Color(25, 25, 25, 127))
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Paint(w, h)
	self.connectbtn:SetSize(w-100, 30)
	self.connectbtn:SetPos(15, h - 45)

	self.backbtn:SetSize(65, 30)
	self.backbtn:SetPos(w - 80, h - 45)
	--[[
	self.servgmlabel:SetPos((w - 30) * 0.75 + 15, 15)
	self.servgmlabel:SetSize((w - 40) * 0.25, 40)
	self.servnmlabel:SetPos((w - 30) * 0.75 + 15, 55)
	self.servnmlabel:SetSize((w - 40) * 0.25, 20)
	self.servdatalabel:SetPos((w - 30) * 0.75 + 15, 190)
	self.servdatalabel:SetSize((w - 40) * 0.25, 256)

	self.update:SetPos((w - 30) * 0.75 + 30, 120)
	self.update:SetSize((w - 40) * 0.25, 30)
	self.stop:SetPos((w - 30) * 0.75 + 30, 155)
	self.stop:SetSize((w - 40) * 0.25, 30)
	self.mkfav:SetPos((w - 30) * 0.75 + 30, 190)
	self.mkfav:SetSize((w - 40) * 0.25, 30)
	]]

	self.servinfopnl:SetPos((w - 30) * 0.75 + 15, 15)
	self.servinfopnl:SetSize((w - 40) * 0.25, h - 70)

	self:DrawBackground(w, h)

	if not self.serverlist then return end
end

function PANEL:StartHideAnimation(callback)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local from_x = self:GetX()
	local _mt = Derma_Anim("ConnectGameMenuHideAnim", self, function(pnl, anim, delta, data)
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
	local _mt = Derma_Anim("ConnectGameMenuShowAnim", self, function(pnl, anim, delta, data)
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

vgui.Register("MainMenuConnectPanel", PANEL, "EditablePanel")