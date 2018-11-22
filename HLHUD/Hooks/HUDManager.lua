Hooks:PostHook(HUDManager, "init", "HLHUDInit", function(self)
	HLHUD.main_ws = HLHUD.main_ws or managers.gui_data:create_fullscreen_workspace()
	HLHUD.main_panel = HLHUD.main_panel or HLHUD:make_panel(HLHUD.main_ws, "HLHUD")
	
	local p = HLHUD.main_panel
	HLHUD.bottom_hud = HLHUD:make_panel(p, "bottom_panel", {layer = -1000})

	--HLHUD.bottom_hud:set_w(HLHUD.bottom_hud:w() - 32)
	--HLHUD.bottom_hud:set_center_x(p:center_x())
	self:hl_update()
end)

function HUDManager:hl_update()
	HLHUD:LayoutScaledWorkspace(HLHUD.main_ws, HLHUD.Options:GetValue("Scale"), HLHUD.Options:GetValue("Spacing"))
	HLHUD.bottom_hud:set_size(HLHUD.main_panel:size())
	local x,y = 12,5
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
end

function HUDManager:hl_align_teammate_panels()
	local prev
	for _, tm in pairs(self._teammate_panels) do
		if tm._main_player then
			tm._hl_panel:set_bottom(HLHUD.bottom_hud:h())
		elseif tm:hl_visible() then
			if prev then
				tm._hl_panel:set_bottom(prev:top())
			else
				tm._hl_panel:set_bottom(HLHUD.bottom_hud:h() - tm._hl_panel:h())
			end
			prev = tm._hl_panel
		end
	end
end