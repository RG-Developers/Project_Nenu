local function makeMenuButton(parent, text, x, y, w, h)
	local btn = vgui.Create("DButton", parent)
	function btn:GetButtonText() return self.text end
	function btn:SetButtonText(text) self.text = text end
	function btn:GetColor() return self.color end
	function btn:SetColor(color) self.color = color end
	function btn:GetTextColor() return self.tcolor end
	function btn:SetTextColor(tcolor) self.tcolor = tcolor end
	function btn:GetHoverColor() return self.hcolor end
	function btn:SetHoverColor(hcolor) self.hcolor = hcolor end

	function btn:GetPVisible() return self.pvisible end
	function btn:SetPVisible(pvisible) self.pvisible = pvisible end

	function btn:DrawBackground(w, h) end
	function btn:DrawAfter(w, h) end
	function btn:Draw(w, h)
		surface.DrawRect(0, 0, w, h)
		surface.SetFont(self:GetFont() or "Default")
		local width, height = surface.GetTextSize(self:GetButtonText())
		draw.DrawText(self:GetButtonText(), self:GetFont() or "Default", w / 2 - width / 2, h / 2 - height / 2, self:GetTextColor(), TEXT_ALIGN_CENTER)
	end
	function btn:Paint(w, h)
		if self:IsHovered() and (not self.anim or self.anim.name ~= "hoverin") or self.settohover then
			self.settohover = false
			local function easeOutQuad(x, from, to)
				local d = 1 - (1 - x) * (1 - x)
				return (from * (1-d)) + (to * d)
			end
			local name = "hoverin"
			local fromcolor = self.drawcolor or self:GetColor()
			local _mt = Derma_Anim(name, self, function(pnl, anim, delta, data)
				pnl.drawcolor = Color(
					easeOutQuad(delta, fromcolor.r, pnl:GetHoverColor().r),
					easeOutQuad(delta, fromcolor.g, pnl:GetHoverColor().g),
					easeOutQuad(delta, fromcolor.b, pnl:GetHoverColor().b),
					easeOutQuad(delta, fromcolor.a, pnl:GetHoverColor().a)
					)
			end)
			_mt:Start(0.25*animationSpeed)
			_mt.name = name
			self.anim = _mt
		end
		if not self:IsHovered() and (not self.anim or self.anim.name ~= "hoverout") or self.settobase then
			self.settobase = false
			local function easeOutQuad(x, from, to)
				local d = 1 - (1 - x) * (1 - x)
				return (from * (1-d)) + (to * d)
			end
			local name = "hoverout"
			local fromcolor = self.drawcolor or self:GetHoverColor()
			local _mt = Derma_Anim(name, self, function(pnl, anim, delta, data)
				pnl.drawcolor = Color(
					easeOutQuad(delta, fromcolor.r, pnl:GetColor().r),
					easeOutQuad(delta, fromcolor.g, pnl:GetColor().g),
					easeOutQuad(delta, fromcolor.b, pnl:GetColor().b),
					easeOutQuad(delta, fromcolor.a, pnl:GetColor().a)
					)
			end)
			_mt:Start(0.25*animationSpeed)
			_mt.name = name
			self.anim = _mt
		end
		if self.anim and self.anim:Active() then
			self.anim:Run()
		end
		self.drawcolor = self.drawcolor or self:GetColor()
		local oa = self.drawcolor.a
		if IsInGame() then self.drawcolor.a = math.Clamp(self.drawcolor.a + 50, 0, 255) end
		if self.pvisible then
			surface.SetDrawColor(self.drawcolor or self:GetColor())
			self:DrawBackground(w, h)
			surface.SetDrawColor(self.drawcolor or self:GetColor())
			self:Draw(w, h)
			surface.SetDrawColor(self.drawcolor or self:GetColor())
			self:DrawAfter(w, h)
		end
		if IsInGame() then self.drawcolor.a = oa end
	end
	btn:SetSize(w, h)
	btn:SetPos(x, y)
	btn:SetButtonText(text)
	btn:SetText(" ")
	btn:SetColor(Color(82, 82, 82, 82))
	btn:SetTextColor(Color(255, 255, 255, 255))
	btn:SetHoverColor(Color(200, 200, 200, 82))
	btn:SetPVisible(true)
	return btn
end

return makeMenuButton