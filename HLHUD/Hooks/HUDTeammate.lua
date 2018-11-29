HLHUD.Hook:Post(HUDTeammate, "init", function(self)
    self._panel:set_alpha(0)
    self._player_panel:set_alpha(0)
    self._player_panel:set_visible(false)
    
    self._hl_ammo = {primary = {current = 0, total = 0}, secondary = {current = 0, total = 0}}

    local bottom_hud = HLHUD.bottom_hud
    local me = self._main_player
    local notme = not me
    self._hl_panel = HLHUD:make_panel(HLHUD.bottom_hud, "temp", {h = notme and 68 or 256})

    local font_size = notme and 20 or 32
    local line_h = notme and 14 or 20
    local panel_h = notme and 20 or 32
    if notme then
        self._hl_panel:set_w(150)
    end
    self._hl_name = HLHUD:make_text(self._hl_panel, "name", {visible = notme, font_size = font_size})

    self._hl_ply_panel = HLHUD:make_panel(self._hl_panel, "temp")
    local bottom = notme and self._hl_name:bottom() + panel_h or self._hl_ply_panel:h()
    
    local function create_text(opt)
        local np = HLHUD:make_panel(self._hl_ply_panel, "temp", {h = panel_h, bottom = bottom})
        local icon_w, icon_h = self:rectwh(opt.rect)
        local icon = HLHUD:make_icon(np, opt.rect, "icon", {w = icon_w, h = icon_h, visible = me, x = opt.icon_offset, bottom = np:h()})
        local text = HLHUD:make_text(np, "text", {font_size = font_size, x = me and icon:right() or 0})
        
        np:set_w(text:right())
    
        if notme then
            icon:set_center_y(np:h()/2)
        end

        if opt.make_line then
            HLHUD:make_icon(np, HLHUD.TextureRects.Line, "line", {h = line_h, x = text:right() + 4, center_y = text:center_y()})
            np:grow(6)
        end
        return np
    end
    
    self._hl_health = create_text({rect = HLHUD.TextureRects.Health, make_line = true})
    self._hl_armor = create_text({rect = HLHUD.TextureRects.Armor, icon_offset = 8})
    
    local icon = self._hl_armor:child("icon")
    local fill = HLHUD:make_panel(self._hl_armor, "fill", {layer = 2, visible = me, h = icon:h()})

    local rect = HLHUD.TextureRects.ArmorFill
    local icon_w, icon_h = self:rectwh(rect)
    local fill_icon = HLHUD:make_icon(fill, rect, "icon", {w = icon_w, h = icon_h})
    fill:set_w(fill_icon:w())
    fill:set_right(icon:right())
    
    for i=1,2 do
        local np = HLHUD:make_panel(self._hl_ply_panel, i == 1 and "primary" or "secondary", {h = panel_h, bottom = bottom, visible = i == 1})
        local current_ammo = HLHUD:make_text(np, "current", {font_size = font_size})
        local total_ammo = HLHUD:make_text(np, "total", {font_size = font_size, x = current_ammo:right() + (notme and 8 or 18)})
        local icon = HLHUD:make_icon(np, HLHUD.TextureRects.Ammo.assault_rifle, "icon", {visible = self._main_player, w = notme and 0, x = total_ammo:right() + 10, center_y = current_ammo:center_y() - 4})
    
        HLHUD:make_icon(np, HLHUD.TextureRects.Line, "line", {x = current_ammo:right() + 4, h = line_h, center_y = current_ammo:center_y()})

        np:set_w(icon:right())
    end

    self._hl_equipment_panel = HLHUD:make_panel(self._hl_ply_panel, "equipment", {w = 150, h = panel_h * (notme and 1 or 3)})
    local function make_equipment(name)
        local np = HLHUD:make_panel(self._hl_equipment_panel, name, {h = panel_h, bottom = self._hl_equipment_panel:h()})
        local amount = HLHUD:make_text(np, "amount", {text = "99", font_size = font_size})
        local icon = HLHUD:make_icon(np, nil, "icon", {w = 16, h = 16, center_y = amount:center_y() - (notme and 0 or 4)})
        if notme then
            amount:set_x(icon:right() + 4)
        end
    end

    make_equipment("deployable")
    make_equipment("cableties")
    make_equipment("grenades")

    self._hl_equipment_data = {}
    self:hl_update()
end)

function HUDTeammate:hl_update(mngr)
	local plyp = self._hl_ply_panel
	
    plyp:set_visible(not self._ai)

    self._hl_panel:set_visible(self:hl_visible())

    local notme = not self._main_player

	if not notme then
		self._hl_panel:set_size(self._hl_panel:parent():size())
	end
	plyp:set_size(self._hl_panel:size())

    local panel_h = notme and 20 or 32
    local bottom = notme and self._hl_name:bottom() + panel_h or self._hl_ply_panel:h()
    local primary, secondary = plyp:child("primary"), plyp:child("secondary")
    
    self._hl_health:set_bottom(bottom)
    self._hl_armor:set_bottom(bottom)
	self._hl_armor:set_x(self._hl_health:right() + (notme and 2 or 188))

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
    for _, p in pairs(self._hl_equipment_panel:children()) do
        HLHUD:Apply({p:child("amount"), p:child("icon")}, apply)
    end
    self._hl_armor:child("fill"):child("icon"):configure(apply)

    apply.color = nil
    self._hl_name:configure(apply)

    for i=1,2 do
        local current = i == 1 and primary or secondary
        local eq_current = i == 1 and managers.blackmarket:equipped_primary() or managers.blackmarket:equipped_secondary()
        if eq_current then
            local wep_tweak = tweak_data.weapon[eq_current.weapon_id]
            if wep_tweak then
                local rect = HLHUD.TextureRects.Ammo[wep_tweak.categories[#wep_tweak.categories]] or HLHUD.TextureRects.Ammo.assault_rifle
                if wep_tweak.projectile_type == "rocket_frag" or wep_tweak.projectile_type == "launcher_frag_m32" then
                    rect = HLHUD.TextureRects.Ammo.rocket
                end
                if rect then
                    local icon = current:child("icon")
                    icon:set_texture_rect(unpack(rect))
                    icon:set_size(rect[3], rect[4])
                    icon:set_center_y(current:child("current"):center_y() - 4)
                    current:set_w(icon:right())
                end
            end
        end
        current:set_bottom(bottom)
        if notme then
            current:set_x(self._hl_armor:right() + 8)
        else
            current:set_right(plyp:w())
        end
    end

    if notme then
        self._hl_equipment_panel:set_y(primary:bottom() + 2)
    else
        self._hl_equipment_panel:set_right(self._hl_ply_panel:w())
        self._hl_equipment_panel:set_bottom(primary:y() - 2)
    end

    if not mngr then
        managers.hud:hl_align_teammate_panels()
    end
    self:hl_align_equipment()
end

function HUDTeammate:hl_request_equipment(this)
    for _, data in pairs(self._hl_equipment_data) do
        if data.visible then
            this:hl_add_equipment(self._id, data.id, data.icon, data.amount, data.from_string)
        end
    end
end

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

function HUDTeammate:hl_align_equipment()
    local prev
    for _, p in pairs(self._hl_equipment_panel:children()) do
        if p:visible() then
            local amount, icon = p:child("amount"), p:child("icon")
            managers.hud:make_fine_text(amount)
            if self._main_player then
                icon:set_x(amount:right() + 10)
                p:set_w(icon:right())
                p:set_rightbottom(self._hl_equipment_panel:w(), prev and prev:y() or self._hl_equipment_panel:h())
            else
                p:set_w(amount:right())
                p:set_x(prev and prev:right() + 4 or 0)
            end
            prev = p
        end
    end
end

function HUDTeammate:hl_get_amounts_and_range(tbl)
    local amounts = ""
    local zero_ranges = {}
    for i, amount in pairs(tbl) do
        local amount_str = string.format("%01d", amount)

        if i > 1 then amounts = amounts .. "|" end

        if amount == 0 then
            local current_length = string.len(amounts)
            table.insert(zero_ranges, {current_length, current_length + string.len(amount_str)})
        end

        amounts = amounts .. amount_str
    end
    return amounts, zero_ranges
end

function HUDTeammate:hl_set_quipment(name, data, from_string)
    local equipment = self._hl_equipment_panel:child(name)
    if equipment then
        local amount = data

        local saved_data
        for i, data in pairs(self._hl_equipment_data) do
            if data.id == name then
                saved_data = data
            end
        end
        if not saved_data then
            saved_data = {id = name}
            table.insert(self._hl_equipment_data, saved_data)
        end

        local amount_t = equipment:child("amount")
        local icon_b = equipment:child("icon")

        if type(amount) == "table" and data.amount then
            amount = data.amount
            local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon, name == "grenades" and {0,0,32,32} or nil)
            icon_b:set_image(icon, unpack(texture_rect))
            saved_data.icon = data.icon
        end
        
        if HLHUD.Options:GetValue("LightUpAmmo") then
            if amount_t:text() ~= tostring(amount) then
                HLHUD:lightup(amount_t)
                HLHUD:lightup(icon_b)
            end
        end

        local visible = false
        if from_string and type(amount) == "table" then
            local amounts, zero_ranges = self:hl_get_amounts_and_range(amount)
            amount_t:set_text(amounts)
            local color = amount_t:color()
            for _, range in ipairs(zero_ranges) do
                amount_t:set_range_color(range[1], range[2], color:with_alpha(0.5))
            end

            for _, val in pairs(amount) do
                if val > 0 then
                    visible = true
                end
            end
        else
            visible = (tonumber(amount) or 0) > 0
            amount_t:set_text(tostring(amount))
        end
        
        equipment:set_visible(visible)
        self:hl_align_equipment()
        saved_data.amount = amount
        saved_data.visible = visible
        saved_data.from_string = from_string
    end
end

function HUDTeammate:hl_set_health(data)
    local p = data.current / data.total
    local text = self._hl_health:child("text")
    local prev = text:text()

    if HLHUD.Options:GetValue("VanillaValues") then
        text:set_text(string.format("%i", data.current * tweak_data.gui.stats_present_multiplier))
    else
        text:set_text(string.format("%i", p * 100))
    end

    local color = p >= 0.26 and HLHUD.orange_color or HLHUD.red_color
    text:set_color(color)
    self._hl_health:child("icon"):set_color(color)
    if prev ~= text:text() then
        HLHUD:lightup(self._hl_health:child("text"))
        HLHUD:lightup(self._hl_health:child("icon"))
        HLHUD:lightup(self._hl_health:child("line"))
    end
end
HLHUD.Hook:Post(HUDTeammate, "set_deployable_equipment", function(self, data) self:hl_set_quipment("deployable", data) end)
HLHUD.Hook:Post(HUDTeammate, "set_cable_tie", function(self, data) self:hl_set_quipment("cableties", data) end)
HLHUD.Hook:Post(HUDTeammate, "set_grenades", function(self, data) self:hl_set_quipment("grenades", data) end)

HLHUD.Hook:Post(HUDTeammate, "set_deployable_equipment_from_string", function(self, data) self:hl_set_quipment("deployable", data, true) end)
HLHUD.Hook:Post(HUDTeammate, "set_deployable_equipment_amount_from_string", function(self, i, data) self:hl_set_quipment("deployable", data.amount, true) end)
HLHUD.Hook:Post(HUDTeammate, "set_deployable_equipment_amount", function(self, i, data) self:hl_set_quipment("deployable", data.amount) end)
HLHUD.Hook:Post(HUDTeammate, "set_cable_ties_amount", function(self, amount) self:hl_set_quipment("cableties", amount) end)
HLHUD.Hook:Post(HUDTeammate, "set_grenades_amount", function(self, data) self:hl_set_quipment("grenades", data.amount) end)

HLHUD.Hook:Post(HUDTeammate, "add_special_equipment", function(self, data) 
    table.insert(self._hl_equipment_data, clone(data))
end)

HLHUD.Hook:Post(HUDTeammate, "remove_special_equipment", function(self, id)
    for i, data in pairs(self._hl_equipment_data) do
        if data.id == id then
            table.remove(self._hl_equipment_data, i)
            break
        end
    end
end)

HLHUD.Hook:Post(HUDTeammate, "set_special_equipment_amount", function(self, amount)
    for i, data in pairs(self._hl_equipment_data) do
        if data.id == id then
            data.amount = amount
            break
        end
    end
end)

HLHUD.Hook:Post(HUDTeammate, "set_health", HUDTeammate.hl_set_health)
HLHUD.Hook:Post(HUDTeammate, "set_custom_radial", HUDTeammate.hl_set_health)

HLHUD.Hook:Post(HUDTeammate, "set_name", function(self, name)
    self._hl_name:set_text(name)
    managers.hud:make_fine_text(self._hl_name)
end)

HLHUD.Hook:Post(HUDTeammate, "set_callsign", function(self, id)
    local color = tweak_data.chat_colors[id]
    self._hl_name:set_color(color)
end)

HLHUD.Hook:Post(HUDTeammate, "set_armor", function(self, data)
    local p = data.current / data.total
    local text = self._hl_armor:child("text")
    local prev = text:text()
    if HLHUD.Options:GetValue("VanillaValues") then
        text:set_text(string.format("%i", data.current * tweak_data.gui.stats_present_multiplier))
    else
        text:set_text(string.format("%i", math.round(p * 100)))
    end
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

    self._hl_ammo[type].current = current_clip
    self._hl_ammo[type].total = current_left
    
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