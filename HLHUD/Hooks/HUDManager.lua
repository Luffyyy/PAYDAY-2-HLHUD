HLHUD.Hook:Post(HUDManager, "init", function(self)
	HLHUD.main_ws = HLHUD.main_ws or managers.gui_data:create_fullscreen_workspace()
	HLHUD.main_panel = HLHUD.main_panel or HLHUD:make_panel(HLHUD.main_ws, "HLHUD")
	HLHUD.main_ws:hide()
	local p = HLHUD.main_panel
	HLHUD.bottom_hud = HLHUD:make_panel(p, "bottom_panel", {layer = -1000})

	--HLHUD.bottom_hud:set_w(HLHUD.bottom_hud:w() - 32)
	--HLHUD.bottom_hud:set_center_x(p:center_x())
	self:hl_update()
end)

HLHUD.Hook:Post(HUDManager, "set_enabled", function(self)
	HLHUD.main_ws:show()
end)

HLHUD.Hook:Post(HUDManager, "set_disabled", function(self)
	HLHUD.main_ws:hide()
end)

HLHUD.Hook:Post(HUDManager, "hide_mission_briefing_hud", function(self)
	HLHUD.main_ws:show()
end)

HLHUD.Hook:Post(HUDManager, "show_endscreen_hud", function(self)
	HLHUD.main_ws:hide()
end)

function HUDManager:hl_update()
	HLHUD:LayoutScaledWorkspace(HLHUD.main_ws, HLHUD.Options:GetValue("Scale"), HLHUD.Options:GetValue("Spacing"))
	HLHUD.bottom_hud:set_size(HLHUD.main_panel:size())
	local x,y = 16,5
	HLHUD.bottom_hud:grow(-x*2,-y*2)
	HLHUD.bottom_hud:set_center(HLHUD.main_panel:center())
	if self._teammate_panels then
		for _, tm in pairs(self._teammate_panels) do
			if tm.hl_update then
				tm:hl_update(true)
			end
		end
		self:hl_align_teammate_panels()
	end
	if self._hud_chat_access then
		self._hud_chat_access:hl_update()
		self._hud_chat_ingame:hl_update()
	end
end

function HUDManager:hl_align_teammate_panels()
	local prev
	for _, tm in pairs(self._teammate_panels) do
		if tm._main_player then
			tm._hl_panel:set_bottom(HLHUD.bottom_hud:h())
		elseif tm:hl_visible() then
			if prev then
				tm._hl_panel:set_bottom(prev:top() - 2)
			else
				tm._hl_panel:set_bottom(HLHUD.bottom_hud:h() - 36)
			end
			prev = tm._hl_panel
		end
	end
end