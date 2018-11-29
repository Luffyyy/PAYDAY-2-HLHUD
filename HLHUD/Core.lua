HLHUD.Hook = Hooks:QuickClass("HLHUD")
HLHUD.TextureRects = {
	Health = {84,28,24,24},
	Armor = {51,24,28,40},
	ArmorFill = {3, 25, 36, 38},
	Line = {240, 0, 2, 40},
	Ammo = {
		pistol = {12, 76, 7, 15},
		assault_rifle = {36, 76, 8, 23},
		smg = {36, 76, 8, 23}, -- same as ar
		lmg = {36, 76, 8, 23}, -- same as ar
		minigun = {36, 76, 8, 23}, -- same as ar
		snp = {60, 73, 8, 24},
		revolver = {60, 73, 8, 24}, -- same as snp
		grenade_launcher = {10, 99, 12, 18},
		shotgun = {34, 98, 12, 20},
		rocket = {59, 97, 11, 25},
		bow = {7, 120, 14, 25},
		crossbow = {7, 120, 14, 25}, -- same as bow
		saw = {28, 120, 25, 25},
		flamethrower = {53, 122, 22, 21},
	},
}
local function extra_funcs(ret, opt)
	if not opt then return ret end

	local possible = {
		center_x = "set_center_x",
		center_y = "set_center_y",
		bottom = "set_bottom",
		right = "set_right",
	}
	for val, func in pairs(possible) do
		if opt[val] then
			ret[func](ret, opt[val])
		end
	end
	return ret
end

function HLHUD:Init()
	self:OptionsChanged()
end

function HLHUD:make_panel(pan, name, opt)
	return extra_funcs(pan:panel(table.merge({name = name}, opt)), opt)
end

function HLHUD:lightup(o)
	play_value(o, "alpha", HLHUD.Options:GetValue("LightOpacity"), {callback = function()
		play_value(o, "alpha", HLHUD.Options:GetValue("Opacity"), {wait = 1})
	end})
end

function HLHUD:make_text(pan, name, opt)
	local text = pan:text(table.merge({
		name = name or "text",
		text = "100",
		align = "right",
		blend_mode = HLHUD.Options:GetValue("AddBlendMode") and "add" or "normal",
		font_size = 32,
		color = self.orange_color,
		font = "hl/hud_font_bold"
    }, opt))

	managers.hud:make_fine_text(text)

	return extra_funcs(text, opt)
end

function HLHUD:Apply(tbl, config)
	if tbl then
		for _, o in pairs(tbl) do
			o:configure(config)
		end
	end
end

function HLHUD:make_icon(pan, rect, name, opt)
	return extra_funcs(pan:bitmap(table.merge({
		name = name,
		blend_mode = HLHUD.Options:GetValue("AddBlendMode") and "add" or "normal",
		texture = "hl/hud_icons",
		texture_rect = rect,
		color = self.orange_color
	}, opt)), opt)
end

function HLHUD:Post(clss, func, after_orig)
	Hooks:PostHook(clss, func, "HLHUD"..func, after_orig)
end

function HLHUD:Pre(clss, func, after_orig)
	Hooks:PostHook(clss, func, "PreHLHUD"..func, after_orig)
end

function HLHUD:OptionsChanged(name, val)
	self.orange_color = HLHUD.Options:GetValue("MainColor")
	self.red_color = HLHUD.Options:GetValue("NegColor")
	if managers.hud then
		managers.hud:hl_update()
	end
end

function HLHUD:LayoutScaledWorkspace(ws, scale, on_screen_scale)
    local data = {}
    local res = RenderSettings.resolution
    data.base_res = {x = 1280, y = 720}
    data.sc = (2 - scale)
    data.aspect_width = data.base_res.x / managers.gui_data:_aspect_ratio()
    data.h = math.round(data.sc * math.max(data.base_res.y, data.aspect_width))
    data.w = math.round(data.sc * math.max(data.base_res.x, data.aspect_width / data.h))

    data.safe_w = math.round(on_screen_scale * res.x)
    data.safe_h = math.round(on_screen_scale * res.y)   
    data.sh = math.min(data.safe_h, data.safe_w / (data.w / data.h))
    data.sw = math.min(data.safe_w, data.safe_h * (data.w / data.h))
    data.on_screen_width = data.sw
    data.x = res.x / 2 - data.sh * (data.w / data.h) / 2
    data.y = res.y / 2 - data.sw / (data.w / data.h) / 2
    
	data.convert_x = math.floor((managers.gui_data._fullrect_data.w - data.w) / 2)
	data.convert_y = math.floor((managers.gui_data._fullrect_data.h - data.h) / 2)
    managers.gui_data:_set_layout(ws, data)
    ws:set_screen(data.w, data.h, data.x, data.y, math.min(data.sw, data.sh * (data.w / data.h)))
end