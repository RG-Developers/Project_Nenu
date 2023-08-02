local matLoading = Material("icon16/loading.png")

local popup_workshop
hook.Add("WorkshopStart", "WorkshopStart", function()
	if IsValid(popup_workshop) then popup_workshop.deltime = -1 end
	popup_workshop = makePopup("Workshop start",
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
				surface.SetDrawColor(Color(0, 127, 255, 255))
				surface.DrawRect(self.barx, 0, 16, 2)
				surface.DrawRect(self.barx, 28, 16, 2)
				self.barx = self.barx + (self.bars * FrameTime())
				if self.barx <= 0 then
					self.bars = 30
					self.barx = 0
				elseif self.barx >= 300 - 16 then
					self.bars = -30
					self.barx = 300 - 16
				end
			end,
			300, 30, SysTime() + 32767)
	popup_workshop.barx = 0
	popup_workshop.bars = 30
end)

hook.Add("WorkshopEnd", "WorkshopEnd", function()
	if not IsValid(popup_workshop) then return end
	popup_workshop.deltime = -1
end)

hook.Add( "WorkshopDownloadFile", "WorkshopDownloadFile", function(id, iImageID, title, iSize)
	if not IsValid(popup_workshop) then return end
end)

hook.Add("WorkshopDownloadedFile", "WorkshopDownloadedFile", function(id)
	if not IsValid(popup_workshop) then return end
end)

hook.Add("WorkshopDownloadProgress", "WorkshopDownloadProgress", function(id, iImageID, title, downloaded, expected)
	if not IsValid(popup_workshop) then return end
	popup_workshop.text = "Downloading "..title.." "..(math.Round(downloaded / expected * 100)).."%"
end)

hook.Add("WorkshopExtractProgress", "WorkshopExtractProgress", function(id, iImageID, title, percent)
	if not IsValid(popup_workshop) then return end
	popup_workshop.text = "Extracting "..title.." "..percent.."%"
end)

hook.Add("WorkshopDownloadTotals", "WorkshopDownloadTotals", function(iRemain, iTotal)
	if not IsValid(popup_workshop) then return end
	if iRemain == iTotal then
		return
	end
	local completed = iTotal - iRemain
	popup_workshop.text = "Downloaded "..completed.."/"..iTotal
end )

hook.Add("WorkshopSubscriptionsProgress", "WorkshopSubscriptionsProgress", function(iCurrent, iMax)
	if not IsValid(popup_workshop) then return end
	popup_workshop.text = "Subscriptions progress "..iCurrent.."/"..iMax
end)

hook.Add("WorkshopSubscriptionsMessage", "WorkshopSubscriptionsMessage", function(msg)
	if not IsValid(popup_workshop) then return end
	popup_workshop.text = msg
end)