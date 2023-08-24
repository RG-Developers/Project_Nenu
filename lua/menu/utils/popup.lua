local Popups = {}
local lastYAddition = 0
local animatingBubbleUp = false
local removedID = 0

local function createPopup(text, update, draw, w, h, deltime, ...)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local popupframe = vgui.Create("DPanel")
	popupframe:SetZPos(32767)
	popupframe:SetPos(-w-10, 0)
	popupframe:SetSize(w, h)
	popupframe:SetPaintedManually(true)
	popupframe.deltime = deltime
	popupframe.id = #Popups + 1
	popupframe.text = text
	Popups[popupframe.id] = popupframe
	local from_x = popupframe:GetX()
	local _mt = Derma_Anim("PopupShowAnim", popupframe, function(pnl, anim, delta, data)
		pnl:SetPos(easeOutCubic(delta, from_x, 10), pnl:GetY())
	end)
	_mt:Start(0.5*animationSpeed)
	popupframe.anim = _mt
	function popupframe:IsVisible() return true end
	function popupframe:Think()
		if self.anim and self.anim:Active() then self.anim:Run() end
		if self.deltime < SysTime() and not self.hidden then
			local from_x = self:GetX()
			self.hidden = true
			local _mt = Derma_Anim("PopupHideAnim", self, function(pnl, anim, delta, data)
				pnl:SetPos(easeOutCubic(delta, from_x, -w-10), pnl:GetY())
			end)
			_mt:Start(0.5*animationSpeed)
			self.anim = _mt
		elseif self.deltime + 0.51 < SysTime() and not self.anim:Active() then
			removedID = self.id
		end
	end
	function popupframe:Paint(w, h)
		update()
		draw(self, w, h)
	end
	return popupframe
end

hook.Add("DrawOverlay", "DrawPopups", function()
	local lastY = 10
	if removedID > 0 and not animatingBubbleUp then
		lastYAddition = lastYAddition + Popups[removedID]:GetTall() + 5
		animatingBubbleUp = true
		Popups[removedID]:Remove()
		Popups[removedID] = nil
	end
	if animatingBubbleUp then
		lastYAddition = lastYAddition - (240 * animationSpeed * FrameTime())
		if lastYAddition <= 0 then
			lastYAddition = 0
			removedID = 0
			animatingBubbleUp = false
		end
	end
	lastY = lastY + lastYAddition
	for k, v in SortedPairsByMemberValue(Popups, "id") do
		if v.id < removedID then
			v:SetPos(v:GetX(), lastY - lastYAddition)
		else
			v:SetPos(v:GetX(), lastY)
		end
		lastY = lastY + 5 + v:GetTall()
		v:PaintAt(v:GetPos())
		v:PaintManual()
	end
end)

return createPopup