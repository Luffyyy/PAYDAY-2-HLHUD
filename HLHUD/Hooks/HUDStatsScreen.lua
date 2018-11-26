HLHUD.Hook:Post(HUDStatsScreen, "recreate_right", function(self)
    self._hl_tm_panel = HLHUD:make_panel(self._right, "extra_teammates_info", {
        h = 320, x = 10, bottom = self._right:h() - 10 - tweak_data.menu.pd2_small_font_size
    })
    
    local font_size = 20
    local prev
    local prev_t
    local function make_text(name, text, color, next_to_and_offset)
        local t = prev:text({name = name, text = tostring(text), color = color, font = "fonts/font_medium_mf", font_size = font_size})
        managers.hud:make_fine_text(t)
        if prev_t then
			if next_to_and_offset then
				t:set_y(prev_t:y())
                t:set_x(prev_t:right() + next_to_and_offset)
            else
                t:set_y(prev_t:bottom())
            end
        end
        prev_t = t
        return t
    end
    for i,tm in pairs(managers.hud._teammate_panels) do
        prev = HLHUD:make_panel(self._hl_tm_panel, tostring(i), {h = self._hl_tm_panel:h() / HUDManager.PLAYER_PANEL, y = prev and prev:bottom() or 0})

        prev_t = nil

        make_text("name", tm._hl_name:text(), tm._hl_name:color())
		local health = tm._hl_health:child("text")
		if not tm._ai then
			make_text("health", health:text(), health:color())
			make_text("primary_total", tm._hl_ammo.primary.total, nil, 20)
			make_text("secondary_total", "| " .. tm._hl_ammo.secondary.total, nil, 2)
		end

        HLHUD:make_panel(prev, "equipment", {y = prev_t:bottom() + 2})
        
        tm:hl_request_equipment(self)
    end
    self._hl_tm_panel:animate(function()
        wait(1)
        if managers.hud and managers.hud._showing_stats_screen then
            self:recreate_right()
        end
    end)
end)

function HUDStatsScreen:hl_align_equipment()
    for _, pnl in pairs(self._hl_tm_panel:children()) do
        local prev
        for _, equip in pairs(pnl:child("equipment"):children()) do
            local x = prev and prev:right() + 6 or 0
            local next_right = x + equip:w()
            if next_right <= pnl:w() then
                equip:set_x(x)
            else
                equip:set_y(prev and prev:bottom() or 0)
                equip:set_x(0)
            end
            prev = equip
        end
    end
end

function HUDStatsScreen:hl_add_equipment(i, id, icon, value, from_string)
    local white = tweak_data.screen_colors.text
    local pnl = self._hl_tm_panel:child(tostring(i))
    if pnl and (from_string or value > 0) then
        local icon, rect = tweak_data.hud_icons:get_icon_data(icon)
        local equipment = pnl:child("equipment")
        local np = HLHUD:make_panel(equipment, id)
        local icon = np:bitmap({
            name = name, color = color, texture = icon, texture_rect = rect
        })
        local amount = np:text({
            name = "amount", center_y = icon:center_y(), x = icon:right() + 4, text = tostring(value) or "--", font = "fonts/font_medium_mf", font_size = 16, color = white
        })

        if from_string then
            local amounts = ""
            local zero_ranges = {}
            for i, amount in ipairs(value) do
                local amount_str = string.format("%01d", amount)
        
                if i > 1 then amounts = amounts .. "|" end
        
                if amount == 0 then
                    local current_length = string.len(amounts)
                    table.insert(zero_ranges, {current_length, current_length + string.len(amount_str)})
                end
        
                amounts = amounts .. amount_str
            end
        
            amount:set_text(amounts)
        
            for _, range in ipairs(zero_ranges) do
                amount:set_range_color(range[1], range[2], white:with_alpha(0.5))
            end
        end

        managers.hud:make_fine_text(amount)
        np:set_h(amount:h())

        icon:set_size(np:h(), np:h())
        amount:set_x(icon:right() + 10)
        np:set_w(amount:right())
    end
    self:hl_align_equipment()
end