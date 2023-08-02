Popups = {}
local popupHasBeenRemoved = false

local function createPopup(text, update, draw, w, h, deltime, ...)
	local function easeOutCubic(x, from, to)
		local d = 1 - math.pow(1 - x, 3)
		return (from * (1-d)) + (to * d)
	end
	local popupframe = vgui.Create("DFrame")
	popupframe:SetTitle(" ")
	popupframe:ShowCloseButton(false)
	popupframe:SetZPos(32767)
	popupframe:SetPos(-w-10, 0)
	popupframe:SetSize(w, h)
	popupframe:SetDraggable(false)
	popupframe:MakePopup()
	popupframe:SetMouseInputEnabled(false)
	popupframe:SetKeyboardInputEnabled(false)
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
	function popupframe:Paint(w, h)
		update()
		if self.anim and self.anim:Active() then self.anim:Run() end
		draw(self, w, h)
		if self.deltime < SysTime() and not self.hidden then
			local from_x = popupframe:GetX()
			self.hidden = true
			local _mt = Derma_Anim("PopupHideAnim", self, function(pnl, anim, delta, data)
				pnl:SetPos(easeOutCubic(delta, from_x, -w-10), pnl:GetY())
			end)
			_mt:Start(0.5*animationSpeed)
			popupframe.anim = _mt
		elseif self.deltime + 0.51 < SysTime() and not self.anim:Active() then
			popupHasBeenRemoved = Popups[self.id]
		end
	end
	return popupframe
end

local lastYAddition = 0
local animatingBubbleUp = false

hook.Add("DrawOverlay", "DrawPopups", function()
	local lastY = 10
	if popupHasBeenRemoved then
		lastYAddition = lastYAddition + popupHasBeenRemoved:GetTall() + 5
		animatingBubbleUp = true
		Popups[popupHasBeenRemoved.id]:Remove()
		Popups[popupHasBeenRemoved.id] = nil
		popupHasBeenRemoved = false
	end
	if animatingBubbleUp then
		lastYAddition = lastYAddition - (240 * animationSpeed * FrameTime())
		if lastYAddition <= 0 then
			lastYAddition = 0
			animatingBubbleUp = false
		end
	end
	lastY = lastY + lastYAddition
	for k, v in SortedPairsByMemberValue(Popups, "id") do
		v:SetPos(v:GetX(), lastY)
		lastY = lastY + 5 + v:GetTall()
		v:PaintManual()
	end
end)

return createPopup