local PANEL = {}

local function format_size(bytes)
    local sizes = {"KB", "MB", "GB"}
    local size = bytes
    local formatted = "b"
    for _,s in pairs(sizes) do
        if size / 1024 >= 0.9 then
            size = size / 1024
            formatted = s
        else
            break
        end
    end
    return math.Round(size, 2)..formatted
end

function PANEL:Init()
	self.filters = {false, false}

	self.addoninfopnl = vgui.Create("DPanel", self)
	self.addoninfopnl:SetPos((self:GetWide() - 30) * 0.75 + 15, 15)
	self.addoninfopnl:SetSize((self:GetWide() - 40) * 0.25, self:GetTall() - 70)
	function self.addoninfopnl:Paint() end

	self.addonlabel = vgui.Create("DLabel", self.addoninfopnl)
	--self.addonlabel:SetPos((self:GetWide() - 30) * 0.75 + 15, 15)
	self.addonlabel:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.addonlabel:Dock(TOP)
	self.addonlabel:SetText("Unknown")
	self.addonlabel:SetColor(Color(255, 255, 255, 255))
	self.addonlabel:SetFont("DermaLarge")

	self.addonsize = vgui.Create("DLabel", self.addoninfopnl)
	--self.addonsize:SetPos((self:GetWide() - 30) * 0.75 + 15, 75)
	--self.addonsize:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.addonsize:SetText("0 bytes")
	self.addonsize:SetColor(Color(255, 255, 255, 255))
	self.addonsize:Dock(TOP)

	self.addontags = vgui.Create("DLabel", self.addoninfopnl)
	--self.addontags:SetPos((self:GetWide() - 30) * 0.75 + 15, 105)
	--self.addontags:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.addontags:SetText("Unknown")
	self.addontags:SetColor(Color(255, 255, 255, 255))
	self.addontags:Dock(TOP)

	self.addonwsid = vgui.Create("DLabel", self.addoninfopnl)
	--self.addonwsid:SetPos((self:GetWide() - 30) * 0.75 + 15, 135)
	--self.addonwsid:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.addonwsid:SetText("WSID 0")
	self.addonwsid:SetColor(Color(255, 255, 255, 255))
	self.addonwsid:Dock(TOP)

	self.addonstatus = vgui.Create("DLabel", self.addoninfopnl)
	--self.addonstatus:SetPos((self:GetWide() - 30) * 0.75 + 15, 165)
	--self.addonstatus:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.addonstatus:SetText("Unknown")
	self.addonstatus:SetColor(Color(255, 255, 255, 255))
	self.addonstatus:Dock(TOP)

	self.addondescicn = vgui.Create("DPanel", self.addoninfopnl)
	function self.addondescicn:Paint() end
	self.addonicn = vgui.Create("DImage", self.addondescicn)
	self.addonicn:SetSize(128, 128)
	--self.addonicn:SetPos((self:GetWide() - 30) * 0.75 + 15, 195)
	self.addonicn:SetImage("effects/tvscreen_noise002a")
	self.addondescription = vgui.Create("DLabel", self.addondescicn)
	self.addondescription.scroller = vgui.Create("DVScrollBar", self.addondescicn)
	self.addondescription.scroller:SetSize(10, 128)
	--self.addondescription:SetSize((self:GetWide() - 40) * 0.25 - 158, 128)
	self.addondescription.text = "no description"
	self.addondescription:SetText(" ")
	self.addondescription:SetColor(Color(255, 255, 255, 255))
	function self.addondescription:Paint(w, h)
		local parsed = markup.Parse(self.text, w-30)
		self.scroller:SetUp(128, parsed:GetHeight())
		parsed:Draw(0, self.scroller:GetOffset(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.addonicn:Dock(LEFT)
	self.addondescription:Dock(FILL)
	self.addondescription:DockMargin(5, 0, 5, 0)
	self.addondescription.scroller:Dock(RIGHT)
	self.addondescicn:Dock(TOP)
	self.addondescicn:DockMargin(5, 5, 5, 5)
	self.addondescicn:SetSize(self.addondescicn:GetWide(), 128)

	self.filter_onlyenabled = vgui.Create("DCheckBoxLabel", self.addoninfopnl)
	self.filter_onlyenabled:SetText("Filter disabled addons")
	function self.filter_onlyenabled:OnChange(v)
		self:GetParent():GetParent().filters[1] = v
		self:GetParent():GetParent():UpdateAddons()
	end
	--self.filter_onlyenabled:SetValue(false)
	self.filter_onlyenabled:SizeToContents()
	self.filter_onlyenabled:Dock(TOP)

	self.filter_onlydisabled = vgui.Create("DCheckBoxLabel", self.addoninfopnl)
	self.filter_onlydisabled:SetText("Filter enabled addons")
	function self.filter_onlydisabled:OnChange(v)
		self:GetParent():GetParent().filters[2] = v
		self:GetParent():GetParent():UpdateAddons()
	end
	--self.filter_onlydisabled:SetValue(false)
	self.filter_onlydisabled:SizeToContents()
	self.filter_onlydisabled:Dock(TOP)

	self.backbtn = makeMenuButton(self, "Back", self:GetWide() - 80, self:GetTall() - 45, 60, 30)
	function self.backbtn:DoClick()
		self:GetParent():StartHideAnimation(function()
			pnlMainMenu:StartShowAnimation(function() end)
		end)
	end


	self.searchte = vgui.Create("DTextEntry", self.addoninfopnl)
	self.searchte.drawcolor = self.backbtn:GetColor()
	self.searchte:SetPlaceholderText("Search text...")
	function self.searchte:OnEnter(v)
		self:GetParent():GetParent():UpdateAddons(v)
	end
	function self.searchte:Paint(w, h)
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
	self.searchte:SetTextColor(Color(255, 255, 255, 255))
	--self.searchte:SetPos((self:GetWide() - 30) * 0.75 + 15, self:GetTall() - 85)
	--self.searchte:SetSize((self:GetWide() - 40) * 0.25, 30)
	self.searchte:Dock(BOTTOM)
	self.searchte:DockMargin(5, 5, 5, 5)

	self.tglbtn = makeMenuButton(self.addoninfopnl, "Toggle addon", (self:GetWide() - 30) * 0.75 + 15, self:GetTall() - 125, (self:GetWide() - 40) * 0.25, 30)
	function self.tglbtn:DoClick()
		if not self:GetParent():GetParent().oadnbtn then return end
		if not IsValid(self:GetParent():GetParent().oadnbtn) then return end
		self:GetParent():GetParent().oadnbtn.addon.enabled = not self:GetParent():GetParent().oadnbtn.addon.enabled
		steamworks.SetShouldMountAddon(self:GetParent():GetParent().oadnbtn.addon.wsid, self:GetParent():GetParent().oadnbtn.addon.enabled)
		self:GetParent():GetParent():SelectAddon(self:GetParent():GetParent().oadnbtn)
	end
	self.tglbtn:Dock(BOTTOM)

	self.applybtn = makeMenuButton(self, "Apply addons", self:GetWide() - 185, self:GetTall() - 45, 100, 30)
	function self.applybtn:DoClick()
		steamworks.ApplyAddons()
	end

	local function RefreshAddons()
		timer.Create("menu_refreshaddons", 0.1, 1, function()
			self:UpdateAddons()
			if self.oadnbtn then
				self:SelectAddon(self.oadnbtn)
			end
		end)
	end
	hook.Add("MenuStart", "FindAddons", RefreshAddons)
	hook.Add("GameContentChanged", "RefreshAddons", RefreshAddons)
end

function PANEL:UpdateAddons(search)
	search = search or self.search or ""
	local addons = GetAddons()
	local filters = self.filters
	self.addons = addons
	if #addons == self.oldcount and self.search == search and self.filters == self.ofilters then return end
	self.oldcount = #addons
	self.search = search
	self.ofilters = table.Copy(self.filters)
	if self.addonslist then self.addonslist:Remove() end
	local addonslistscroller = vgui.Create("DScrollPanel", self)
	self.addonslist = vgui.Create("DGrid", addonslistscroller)
	self.addonslist.scroller = addonslistscroller
	self.addonslist:SetPos(15, 15)
	self.addonslist:SetSize((self:GetWide() - 30) * 0.75, self:GetTall() - 70)
	self.addonslist.scroller:SetPos(15, 15)
	self.addonslist.scroller:SetSize((self:GetWide() - 30) * 0.75, self:GetTall() - 70)
	self.addonslist:SetColWide(128)
	self.addonslist:SetRowHeight(128)
	self.addonslist:SetCols(math.floor(self.addonslist:GetWide() / 128))
	self.addonslist.scroller:SetWide(math.floor(self.addonslist:GetWide() / 128)*128+25)
	self.addonslist.addons = {}

	if self.popup and IsValid(self.popup) then
		self.popup.deltime = -1
		self.popup = nil
	end

	local coro = coroutine.create(function()
		local matLoading = Material("nenu/icon/loading.png")
		local p = makePopup("Loading addon list... 0/"..#addons,
		function() end,
		function(self, w, h)
			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.DrawRect(0, 0, w, h)
			surface.SetFont("Default")
			local width, height = surface.GetTextSize(self.text)
			draw.DrawText(self.text,  "Default", 26, h / 2 - height / 2, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(255, 255, 255, 255))
			surface.SetMaterial(matLoading)
			surface.DrawTexturedRect(7, 7, 16, 16)
		end,
		300, 30, SysTime() + 32767)
		self.popup = p
		for _,a in pairs(addons) do
			p.text = "Loading addon list... ".._.."/"..#addons
			if not a.title:lower():StartsWith(search:lower()) then coroutine.yield() continue end
			if filters[1] and a.enabled == false then coroutine.yield() continue end
			if filters[2] and a.enabled == true then coroutine.yield() continue end
			coroutine.yield()
			local btn = makeMenuButton(self.addonslist, a.title, 0, 0, 128, 128)
				btn.addon = a
				self.addonslist:AddItem(btn)
				self.addonslist.addons[_] = btn
				function btn:DoClick()
					self:GetParent():GetParent():GetParent():GetParent():SelectAddon(btn)
				end
				btn.material = Material("__error")

				function btn:DrawBackground(w,h)

					local gx, gy = self:GetGlobalPos()

					if gx + w < 0 or
						gx > ScrW() or
						gy + h < 0 or
						gy > ScrH() then return end
					
					local c = self.drawcolor or self:GetColor()
					local oa = c.a
					c.a = 255
					surface.SetDrawColor(c)
					if self.material:IsError() then self.material = Material("nenu/addon/not_found.png") end
					surface.SetMaterial(self.material)
					surface.DrawTexturedRect(0,0,w,h)
					c.a = oa
				end
				local c = btn:GetColor()
				btn:SetColor(Color(c.r, c.g, c.b, 40))
				local c = btn:GetHoverColor()
				btn:SetHoverColor(Color(c.r, c.g, c.b, 40))

				function btn:GetGlobalPos()
					local x, y = self:GetX(), self:GetY()
					local panel = self
					while panel:GetParent() do
						panel = panel:GetParent()
						x = x + panel:GetX()
						y = y + panel:GetY()
					end
					return x, y
				end

				function btn:Draw(w, h)

					local gx, gy = self:GetGlobalPos()

					if gx + w < 0 or
						gx > ScrW() or
						gy + h < 0 or
						gy > ScrH() then return end

					if self.coro and coroutine.status(self.coro) ~= "dead" then coroutine.resume(self.coro, self) else self.coro = nil end
					local c = self.drawcolor or self:GetColor()
					surface.SetDrawColor(c)
					if not self.addon.enabled then
						local cm = Color(c.r, c.g, c.b, c.a)
						cm.r = cm.r - 20
						cm.g = cm.g - 20
						cm.b = cm.b - 20
						surface.SetDrawColor(cm)
					end
					surface.DrawRect(0, 0, w, h)
					surface.SetFont(self:GetFont() or "Default")
					markup.Parse(self:GetButtonText(), w):Draw(0, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
					local ca = self:GetColor().a
					surface.SetDrawColor(Color(0, 255, 0, c.a+20))
					if not self.addon.enabled then
						surface.SetDrawColor(Color(255, 0, 0, c.a+20))
					end
					surface.DrawRect(w-21, h-21, 16, 16)
				end
				btn.coro = coroutine.create(function(self)
					--print(self)
					
					steamworks.FileInfo(self.addon.wsid, function(result)
						steamworks.Download(result.previewid, true, function(name)
							if not IsValid(self) then return end
							self.material = AddonMaterial(name)
						end)
						if not IsValid(self) then return end
						self.fileinfo = result
					end)
				end)

			steamworks.SetShouldMountAddon(a.wsid, a.enabled)
		end
		p.deltime = -1
		coroutine.yield()
	end)
	hook.Add("Think", "AddonMenuLoad", function()
		if coro and coroutine.status(coro) ~= "dead" then coroutine.resume(coro) else coro = nil end
	end)
end

function PANEL:SelectAddon(adnbtn)
	--if self.oadnbtn == adnbtn then
	--	adnbtn.addon.enabled = not adnbtn.addon.enabled
	--	steamworks.SetShouldMountAddon(adnbtn.addon.wsid, adnbtn.addon.enabled)
	if self.oadnbtn and IsValid(self.oadnbtn) then self.oadnbtn:SetColor(Color(82, 82, 82, 40)) self.oadnbtn.settobase = true end
	self.oadnbtn = adnbtn
	adnbtn:SetColor(Color(150, 150, 150, 40))

	self.addonlabel:SetText(adnbtn.addon.title)
	self.addonsize:SetText(format_size(adnbtn.addon.size))
	self.addontags:SetText(adnbtn.addon.tags)
	self.addonwsid:SetText("WSID "..adnbtn.addon.wsid)
	self.addondescription.text = adnbtn.fileinfo.description
	self.addonicn:SetMaterial(adnbtn.material)
	if adnbtn.addon.enabled then
		if adnbtn.addon.mounted then
			self.addonstatus:SetText("Enabled, Mounted")
		else
			self.addonstatus:SetText("Enabled, Unmounted")
		end
	else
		self.addonstatus:SetText("Disabled")
	end
	self.addons[adnbtn.addon.lid] = adnbtn.addon
	SaveAddonsStatuses(self.addons)
end

function PANEL:DrawBackground(w, h)
	surface.SetDrawColor(Color(25, 25, 25, 127))
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Paint(w, h)
	self.backbtn:SetSize(60, 30)
	self.backbtn:SetPos(w - 80, h - 45)
	self.applybtn:SetSize(100, 30)
	self.applybtn:SetPos(w - 185, h - 45)
--[[
	self.addonlabel:SetPos((w - 30) * 0.75 + 15, 15)
	self.addonlabel:SetSize((w - 40) * 0.25, 30)
	self.addonsize:SetPos((w - 30) * 0.75 + 15, 75)
	self.addonsize:SetSize((w - 40) * 0.25, 30)
	self.addontags:SetPos((w - 30) * 0.75 + 15, 105)
	self.addontags:SetSize((w - 40) * 0.25, 30)
	self.addonwsid:SetPos((w - 30) * 0.75 + 15, 135)
	self.addonwsid:SetSize((w - 40) * 0.25, 30)
	self.addonstatus:SetPos((w - 30) * 0.75 + 15, 165)
	self.addonstatus:SetSize((w - 40) * 0.25, 30)
	self.addonicn:SetPos((w - 30) * 0.75 + 15, 195)
	self.addondescription:SetSize((w - 40) * 0.25 - 98, 128)
	self.addondescription:SetPos((w - 30) * 0.75 + 148, 195)
	self.addondescription.scroller:SetSize(10, 128)
	--self.addondescription.scroller:SetPos((w - 30) * 0.75 + 148, 195)
	self.addondescription.scroller:SetPos((w - 10), 195)

	self.searchte:SetPos((w - 30) * 0.75 + 15, h - 80)
	self.searchte:SetSize((w - 40) * 0.25, 30)

	self.tglbtn:SetPos((w - 30) * 0.75 + 15, h - 125)
	self.tglbtn:SetSize((w - 40) * 0.25, 30)
	]]--
	self.addoninfopnl:SetPos((w - 30) * 0.75 + 15, 20)
	self.addoninfopnl:SetSize((w - 40) * 0.25, h - 75)

	self:DrawBackground(w, h)
end

function PANEL:StartHideAnimation(callback)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local from_x = self:GetX()
	local _mt = Derma_Anim("AddonsMenuHideAnim", self, function(pnl, anim, delta, data)
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
	local _mt = Derma_Anim("AddonsMenuShowAnim", self, function(pnl, anim, delta, data)
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

vgui.Register("MainMenuAddonsPanel", PANEL, "EditablePanel")
