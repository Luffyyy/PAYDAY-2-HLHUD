HLHUD.Hook:Post(HUDTeammate, "init", function(self)
    self._panel:set_alpha(0)
    self._player_panel:set_alpha(0)
    self._player_panel:set_visible(false)
    
    local bottom_hud = HLHUD.bottom_hud
    local notme = not self._main_player
    self._hl_panel = HLHUD:make_panel(HLHUD.bottom_hud, "temp", {h = 64})

    local font_size = notme and 20 or 32
    local line_h = notme and 14 or 20
    local panel_h = notme and 26 or 32
    if notme then
        self._hl_panel:set_w(200)        
        self._hl_name = HLHUD:make_text(self._hl_panel, "name", {font_size = font_size})
    end

    self._hl_ply_panel = HLHUD:make_panel(self._hl_panel, "temp")
    local bottom = notme and self._hl_name:bottom() + panel_h or self._hl_ply_panel:h()
    
    local function create_text(opt)
        local np = HLHUD:make_panel(self._hl_ply_panel, "temp", {h = panel_h, bottom = bottom})
        local icon_w, icon_h = self:rectwh(opt.rect)
        local icon = HLHUD:make_icon(np, opt.rect, "icon", {w = icon_w, h = icon_h, x = opt.icon_offset, bottom = np:h()})
        local text = HLHUD:make_text(np, "text", {font_size = font_size, x = icon:right()})
        
        np:set_w(text:right())
    
        if notme then
            icon:set_center_y(np:h()/2)
        end

        if opt.make_line then
            HLHUD:make_icon(np, {240, 0, 2, 40}, "line", {h = line_h, x = text:right() + 4, center_y = text:center_y()})
            np:grow(6)
        end
        return np
    end
    
    self._hl_health = create_text({rect = {84,28,24,24}, make_line = true})
    self._hl_armor = create_text({rect = {51,24,28,40}, icon_offset = 8})
    
    local icon = self._hl_armor:child("icon")
    local fill = HLHUD:make_panel(self._hl_armor, "fill", {layer = 2, h = icon:h()})

    local rect = {3, 25, 36, 38}
    local icon_w, icon_h = self:rectwh(rect)
    local fill_icon = HLHUD:make_icon(fill, rect, "icon", {w = icon_w, h = icon_h})
    fill:set_w(fill_icon:w())
    fill:set_right(icon:right())
    
    for i=1,2 do
        local np = HLHUD:make_panel(self._hl_ply_panel, i == 1 and "primary" or "secondary", {h = panel_h, bottom = bottom, visible = i == 1})
        local current_ammo = HLHUD:make_text(np, "current", {font_size = font_size})
        local total_ammo = HLHUD:make_text(np, "total", {font_size = font_size, x = current_ammo:right() + (notme and 8 or 18)})
        local icon = HLHUD:make_icon(np, {8, 74, 8, 16}, "icon", {visible = self._main_player, w = notme and 0, x = total_ammo:right() + 10, center_y = current_ammo:center_y() - 4})
    
        HLHUD:make_icon(np, {240, 0, 2, 40}, "line", {x = current_ammo:right() + 4, h = line_h, center_y = current_ammo:center_y()})

        np:set_w(icon:right())
    end
    self:hl_update()
end)

function HUDTeammate:rectwh(opt)
    local div = self._main_player and 1.25 or 1.45
    return opt[3]/div, opt[4]/div
end

function HUDTeammate:hl_visible()
    if HLHUD.Options:GetValue("NoTeammates") then
        return self._main_player
    end
    if HLHUD.Options:GetValue("NoAITeammates") then
        return not self._ai
    end
    return true
end

function HUDTeammate:hl_update(mngr)
	local plyp = self._hl_ply_panel
	
    plyp:set_visible(not self._ai)

    self._hl_panel:set_visible(self:hl_visible())

    local notme = not self._main_player

	if not notme then
		self._hl_panel:set_size(self._hl_panel:parent():size())
	end
	plyp:set_size(self._hl_panel:size())

    local panel_h = notme and 28 or 38
    local bottom = notme and self._hl_name:bottom() + panel_h or self._hl_ply_panel:h()
    local primary, secondary = plyp:child("primary"), plyp:child("secondary")
    
    self._hl_health:set_bottom(bottom)
    self._hl_armor:set_bottom(bottom)
	self._hl_armor:set_x(self._hl_health:right() + (notme and 8 or 188))

    local apply = {
        alpha = HLHUD.Options:GetValue("Opacity"),
        color = HLHUD.orange_color,
        blend_mode = HLHUD.Options:GetValue("AddBlendMode") and "add" or "normal"
    }

    for _, p in pairs({self._hl_armor, self._hl_health}) do
        HLHUD:Apply({p:child("text"), p:child("icon"), p:child("line")}, apply)
    end
    for _, p in pairs({self._hl_ply_panel:child("primary"), self._hl_ply_panel:child("secondary")}) do
        HLHUD:Apply({p:child("current"), p:child("total"), p:child("icon"), p:child("line")}, apply)
    end
    
    self._hl_armor:child("fill"):child("icon"):configure(apply)

    if self._hl_name then
        apply.color = nil
        self._hl_name:configure(apply)
    end

    primary:set_right(plyp:w())
    primary:set_bottom(bottom)
    secondary:set_right(plyp:w())
    secondary:set_bottom(bottom)
    if not mngr then
        managers.hud:hl_align_teammate_panels()
    end
end

function HUDTeammate:set_hlhud_health(data)
    local p = data.current / data.total
    local text = self._hl_health:child("text")
    local prev = text:text()
    text:set_text(string.format("%i", p * 100))

    local color = p >= 0.26 and HLHUD.orange_color or HLHUD.red_color
    text:set_color(color)
    self._hl_health:child("icon"):set_color(color)
    if prev ~= text:text() then
        HLHUD:lightup(self._hl_health:child("text"))
        HLHUD:lightup(self._hl_health:child("icon"))
        HLHUD:lightup(self._hl_health:child("line"))
    end
end

HLHUD.Hook:Post(HUDTeammate, "set_health", HUDTeammate.set_hlhud_health)
HLHUD.Hook:Post(HUDTeammate, "set_custom_radial", HUDTeammate.set_hlhud_health)

HLHUD.Hook:Post(HUDTeammate, "set_name", function(self, name)
    if self._hl_name then
        self._hl_name:set_text(name)
        managers.hud:make_fine_text(self._hl_name)
    end
end)

HLHUD.Hook:Post(HUDTeammate, "set_callsign", function(self, id)
    if self._hl_name then
        self._hl_name:set_color(tweak_data.chat_colors[id])
    end
end)

HLHUD.Hook:Post(HUDTeammate, "set_armor", function(self, data)
    local p = data.current / data.total
    local text = self._hl_armor:child("text")
    local prev = text:text()
    text:set_text(string.format("%i", math.round(p * 100)))
    local fill = self._hl_armor:child("fill")
    fill:set_h(p * self._hl_armor:child("icon"):h())
    fill:set_bottom(self._hl_armor:h())
    fill:child("icon"):set_world_bottom(fill:world_bottom())
    if prev ~= text:text() then
        HLHUD:lightup(self._hl_armor:child("text"))
        HLHUD:lightup(self._hl_armor:child("icon"))
        HLHUD:lightup(self._hl_armor:child("fill"):child("icon"))
    end
end)

HLHUD.Hook:Post(HUDTeammate, "set_ammo_amount_by_type", function(self, type, max_clip, current_clip, current_left, max)
	local weapon_panel = self._hl_ply_panel:child(type)
	if HLHUD.Options:GetValue("HLAmmoTotal") and ((type == "primary" and managers.blackmarket:equipped_primary().weapon_id ~= "saw") or (type == "secondary" and managers.blackmarket:equipped_secondary().weapon_id ~= "saw_secondary") ) then
		current_left = current_left - current_clip
	end
	local ammo_clip = weapon_panel:child("current")
    local ammo_total = weapon_panel:child("total")
    local prev_clip, prev_total = ammo_clip:text(), ammo_total:text()
    if self._main_player then
        ammo_clip:set_text(tostring(current_clip))
        ammo_total:set_text(tostring(current_left))
    else
        if type == "primary" then
            ammo_clip:set_text(tostring(current_left))
        else
            ammo_total:set_text(tostring(current_left))
        end
    end
    if HLHUD.Options:GetValue("LightUpAmmo") then
        if prev_clip ~= ammo_clip:text() or prev_total ~= ammo_total:text() then
            for _, v in pairs({ammo_clip, ammo_total, weapon_panel:child("icon"), weapon_panel:child("line")}) do
                HLHUD:lightup(v)
            end
        end
    end
end)

HLHUD.Hook:Post(HUDTeammate, "_set_weapon_selected", function(self, id)
    local primary = self._hl_ply_panel:child("primary")
    local secondary = self._hl_ply_panel:child("secondary")
	secondary:set_visible(id == 1)
    primary:set_visible(id ~= 1)
    local current = id == 1 and secondary or primary
    if HLHUD.Options:GetValue("LightUpAmmo") then
        for _, v in pairs({current:child("current"), current:child("total"), current:child("icon"), current:child("line")}) do
           HLHUD:lightup(v)
        end
    end
end)

HLHUD.Hook:Post(HUDTeammate, "set_waiting", function(self, waiting, peer)
	self._wait_panel:hide()
	self:hl_update()
end)

HLHUD.Hook:Post(HUDTeammate, "set_ai", HUDTeammate.hl_update)
HLHUD.Hook:Post(HUDTeammate, "set_peer_id", HUDTeammate.hl_update)
HLHUD.Hook:Post(HUDTeammate, "add_panel", HUDTeammate.hl_update)
HLHUD.Hook:Post(HUDTeammate, "set_state", HUDTeammate.hl_update)