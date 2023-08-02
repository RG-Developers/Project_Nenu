local PANEL = {}

function PANEL:Init()
	self.startbtn = makeMenuButton(self, "Start game", 15, 15, self:GetWide() - 30, 30)
	function self.startbtn:DoClick()
		pnlMainMenu:StartGameMenu()
	end

	self.connectbtn = makeMenuButton(self, "Search for servers", 15, 50, self:GetWide() - 30, 30)
	function self.connectbtn:DoClick()
		pnlMainMenu:ServersMenu()
	end

	self.addonsbtn = makeMenuButton(self, "Addons", 15, 85, self:GetWide() - 30, 30)
	function self.addonsbtn:DoClick()
		pnlMainMenu:AddonsMenu()
	end

	self.optionsbtn = makeMenuButton(self, "Options", 15, 120, self:GetWide() - 30, 30)
	function self.optionsbtn:DoClick()
		pnlMainMenu:Cmd("OpenOptionsDialog")
	end

	self.quitbtn = makeMenuButton(self, "Quit", 15, self:GetTall() - 45, math.floor((self:GetWide() - 30) * 0.5), 30)
	function self.quitbtn:DoClick()
		pnlMainMenu:Quit()
	end
	self.disconnectbtn = makeMenuButton(self, "Disconnect", math.floor((self:GetWide() - 30) * 0.5)+20, self:GetTall() - 45, math.floor((self:GetWide() - 30) * 0.5), 30)
	function self.disconnectbtn:DoClick()
		pnlMainMenu:Disconnect()
	end


	self.disconnectbtn:SetVisible(false)
end

function PANEL:DrawBackground(w, h)
	surface.SetDrawColor(Color(25, 25, 25, 127))
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Paint(w, h)
	self.startbtn:SetSize(w-30, 30)
	self.connectbtn:SetSize(w-30, 30)
	self.addonsbtn:SetSize(w-30, 30)
	self.optionsbtn:SetSize(w-30, 30)
	self.quitbtn:SetSize(math.floor((w - 30) * 0.5), 30)
	self.quitbtn:SetPos(15, h - 45)
	self.disconnectbtn:SetVisible(IsInGame())
	if IsInGame() then
		self.disconnectbtn:SetSize(math.floor((w - 30) * 0.5), 30)
		self.disconnectbtn:SetPos(math.floor((self:GetWide() - 30) * 0.5)+20, h - 45)
	end
	self:DrawBackground(w, h)
end

vgui.Register("MainMenuBasePanel", PANEL, "EditablePanel")