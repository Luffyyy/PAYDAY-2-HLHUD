HLHUD.Hook:Post(HUDChat, "init", function(self)
    self:hl_update()
end)

function HUDChat:hl_update()
	self._panel:set_leftbottom(HLHUD.Options:GetValue("ChatX"), HLHUD.Options:GetValue("ChatY"))
end