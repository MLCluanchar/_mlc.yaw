-- require.function
local anti_aim = require 'gamesense/antiaim_funcs' or client.error_log("please install this function:https://gamesense.pub/forums/viewtopic.php?id=29665")
local images = require "gamesense/images" or client.error_log("please install this function:https://gamesense.pub/forums/viewtopic.php?id=22917")
local csgo_weapons = require("gamesense/csgo_weapons") or client.error_log("please install this function:\nhttps://gamesense.pub/forums/viewtopic.php?id=18807")
local http = require('gamesense/http') or client.error_log("please install this function:\nhttps://gamesense.pub/forums/viewtopic.php?id=19253")
    -- script.info
scriptName = "hyaline";
scriptVersion = "v1.0.0";
scriptCloudProcess = false;
local config_names = { "Global", "Taser", "Revolver", "Pistol", "Auto", "Scout", "AWP", "Rifle", "SMG", "Shotgun", "Deagle" }
local weapon_idx = { [1] = 11, [2] = 4,[3] = 4,[4] = 4,[7] = 8,[8] = 8,[9] = 7,[10] = 8,[11] = 5,[13] = 8,[14] = 8,[16] = 8,[17] = 9,[19] = 9,[23] = 9,[24] = 9,[25] = 10,[26] = 9,[27] = 10,[28] = 8,[29] = 10,[30] = 4,[31] = 2,  [32] = 4,[33] = 9,[34] = 9,[35] = 10,[36] = 4,[38] = 5,[39] = 8,[40] = 6,[60] = 8,[61] = 4,[63] = 4,[64] = 3}

local wpn_text
local function name_set()
	local plocal = entity.get_local_player()
    local weapon = entity.get_player_weapon(plocal)
    local weapon_id = bit.band(entity.get_prop(weapon, "m_iItemDefinitionIndex"), 0xFFFF)
	local global = "Global"
    wpn_text = config_names[weapon_idx[weapon_id]]
	return wpn_text
end

client.set_event_callback("paint", function(e)

end)
local wpn = {
	  force_head_key = ui.new_hotkey("RAGE", "Other", "● Force head Hotkey"),
	  force_head_hitbox = ui.new_multiselect("Rage", "Other", "Force head hitbox", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"}),
	
	  multi_point_override = ui.new_checkbox("Rage", "Aimbot", "● Multipoint Override"),
	  multi_point_options = ui.new_multiselect("Rage", "Aimbot", "● Multi Point Opotion", {"On Key", "FD", "DT"}),
	  multi_point_ove_key = ui.new_hotkey("Rage", "Aimbot", "● Multipoint Override Key", false),
	  multi_point_default = ui.new_slider("Rage", "Aimbot", "● Multi-Point Scale [Def]", 24, 100, 64, true, "%", 1, {[24] = "Auto"}),
	  multi_point_on_key = ui.new_slider("Rage", "Aimbot", "● Multi-Point Scale [On Key]", 24, 100, 64, true, "%", 1, {[24] = "Auto"}),
	  multi_point_on_fd = ui.new_slider("Rage", "Aimbot", "● Multi-Point Scale [FD]", 24, 100, 64, true, "%", 1, {[24] = "Auto"}),
	  multi_point_on_dt = ui.new_slider("Rage", "Aimbot", "● Multi-Point Scale [DT]", 24, 100, 64, true, "%", 1, {[24] = "Auto"}),
	  hitchance_override = ui.new_checkbox("Rage", "Aimbot", "● Hitchance Override"),
	  hitchance_options = ui.new_multiselect("Rage", "Aimbot", "● Hitchance Opotion", {"On Key", "FD", "In Air", "No Scope"}),
	  hitchance_ove_key = ui.new_hotkey("Rage", "Aimbot", "● Hitchance Override Key", false),
	  hitchance_default = ui.new_slider("Rage", "Aimbot", "● Hitchance [Def]", 0, 100, 61, true, "%", 1, {[0] = "Auto"}),
	  hitchance_on_key = ui.new_slider("Rage", "Aimbot", "● Hitchance [On Key]", 0, 100, 61, true, "%", 1, {[0] = "Auto"}),
	  hitchance_on_fd = ui.new_slider("Rage", "Aimbot", "● Hitchance [FD]", 0, 100, 61, true, "%", 1, {[0] = "Auto"}),
	  hitchance_on_air = ui.new_slider("Rage", "Aimbot", "● Hitchance [In Air]", 0, 100, 61, true, "%", 1, {[0] = "Auto"}),
	  hitchance_on_nos = ui.new_slider("Rage", "Aimbot", "● Hitchance [NoS]", 0, 100, 61, true, "%", 1, {[0] = "Auto"}),
	
	  damage_override = ui.new_checkbox("Rage", "Aimbot", "● Damage Override"),
	  damage_options = ui.new_multiselect("Rage", "Aimbot", "● Damage Opotion", {"On Key", "On Key2", "Visible", "In Air", "DT"}),
	  damage_ove_key = ui.new_hotkey("Rage", "Aimbot", "● Damage Override Key", false),
	  damage_ove_key2 = ui.new_hotkey("Rage", "Aimbot", "● Damage Override Key2", false),
	  damage_default = ui.new_slider("Rage", "Aimbot", "● Damage [Def]", 0, 126, 20, true, "", 1, damage_labels_select),
	  damage_on_key = ui.new_slider("Rage", "Aimbot", "● Damage [On Key]", 0, 126, 20, true, "", 1, damage_labels_select),
	  damage_on_key2 = ui.new_slider("Rage", "Aimbot", "● Damage [On Key2]", 0, 126, 20, true, "", 1, damage_labels_select),
	  damage_on_vis = ui.new_slider("Rage", "Aimbot", "● Damage [Visible]", 0, 126, 20, true, "", 1, damage_labels_select),
	  damage_on_air = ui.new_slider("Rage", "Aimbot", "● Damage [In Air]", 0, 126, 20, true, "", 1, damage_labels_select),
	  damage_on_dt = ui.new_slider("Rage", "Aimbot", "● Damage [DT]", 0, 126, 20, true, "", 1, damage_labels_select),
	
	  hitbox_override = ui.new_checkbox("Rage", "Aimbot", "● Hitbox Override"),
	  hitbox_options = ui.new_multiselect("Rage", "Aimbot", "● Hitbox Opotion", {"On Key", "DT"}),
	  hitbox_ove_key = ui.new_hotkey("Rage", "Aimbot", "● Hitbox Override Key", false),
	  hitbox_default = ui.new_multiselect("Rage", "Aimbot", "● Hitbox [Def]", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"}),
	  hitbox_on_key = ui.new_multiselect("Rage", "Aimbot", "● Hitbox [On Key]", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"}),
	  hitbox_on_dt = ui.new_multiselect("Rage", "Aimbot", "● Hitbox [DT]", {"Head", "Chest", "Stomach", "Arms", "Legs", "Feet"}),
	
	  state_indicator = ui.new_multiselect("Rage", "Aimbot", "● Indicators", {"Text Value", "Text Value[Crosshair]", "Damage Value", "Damage Value[Crosshair]", "Hitchance Value", "Hitchance Value[Crosshair]","Override state"}),
	  indicator_color = ui.new_color_picker("Rage", "Aimbot", "\n ● Global Indicators Colors", 255, 255, 255, 255)
	
  }
local perfer_baim_switch
local is_perfer_baim = true

local closest_player = 0
local stored_target = nil
local function vec2_distance(f_x, f_y, t_x, t_y)
	local delta_x, delta_y = f_x - t_x, f_y - t_y
	return math.sqrt(delta_x*delta_x + delta_y*delta_y)
end

local function multi_select(tab, val)
	for index, value in ipairs(ui.get(tab)) do
		if value == val then
			return true
		end
	end

	return false
end

local function can_see(ent)
	for i = 0, 18 do
		if client.visible(entity.hitbox_position(ent, i)) then
			return true
		end
	end

	return false
end

local function get_all_player_positions(ctx, screen_width, screen_height, enemies_only)
	local player_indexes = {}
	local player_positions = {}
	local players = entity.get_players(enemies_only)
	if #players == 0 then
		return
	end

	for i=1, #players do
		local player = players[i]
		local px, py, pz = entity.get_prop(player, "m_vecOrigin")
		local vz = entity.get_prop(player, "m_vecViewOffset[2]")
		if pz ~= nil and vz ~= nil then
			pz = pz + (vz*0.5)
			local sx, sy = client.world_to_screen(ctx, px, py, pz)
			if sx ~= nil and sy ~= nil then
				if sx >= 0 and sx <= screen_width and sy >= 0 and sy <= screen_height then 
					player_indexes[#player_indexes+1] = player
					player_positions[#player_positions+1] = {sx, sy}
				end
			end
		end
	end

	return player_indexes, player_positions
end

local function check_fov(ctx)
	local fov_limit = 250
	local screen_width, screen_height = client.screen_size()
	local screen_center_x, screen_center_y = screen_width * 0.5, screen_height * 0.5
	if get_all_player_positions(ctx, screen_width, screen_height, true) == nil then
		return false
	end

	local enemy_indexes, enemy_coords = get_all_player_positions(ctx, screen_width, screen_height, true)
	if #enemy_indexes <= 0 then
		return true
	end

	if #enemy_coords == 0 then
		return true
	end

	local closest_fov = 133337
	local closest_entindex = 133337
	for i = 1, #enemy_coords do
		local x = enemy_coords[i][1]
		local y = enemy_coords[i][2]
		local current_fov = vec2_distance(x, y, screen_center_x, screen_center_y)
		if current_fov < closest_fov then
			closest_fov = current_fov
			closest_entindex = enemy_indexes[i]
		end
	end

	return closest_fov > fov_limit, closest_entindex
end

local function visible_enemys(e)
	local local_entindex = entity.get_local_player()
	if entity.get_prop(local_entindex, "m_lifeState") ~= 0 or not entity.is_alive(local_entindex) then	
		return false
	end
	
	local enemy_visible, enemy_entindex = check_fov(ctx)
	if enemy_entindex == nil then
		return false
	end

	if enemy_visible and enemy_entindex ~= nil and stored_target ~= enemy_entindex then
		stored_target = enemy_entindex
	end

	stored_target = enemy_entindex
	return can_see(enemy_entindex)
end

local calculate_multi_point = function(e)
	local ref_mpscale = ui.get(wpn.multi_point_default)
	local fakeduck = ui.reference("RAGE", "Other", "Duck peek assist")
	local double_check, double_key = ui.reference("RAGE", "Other", "Double tap")
	if ui.get(wpn.multi_point_ove_key) and multi_select(wpn.multi_point_options, "On Key") then
		ref_mpscale = ui.get(wpn.multi_point_on_key)
	elseif ui.get(fakeduck) and multi_select(wpn.multi_point_options, "FD") then
		ref_mpscale = ui.get(wpn.multi_point_on_fd)
	elseif ui.get(double_check) and ui.get(double_key) and multi_select(wpn.multi_point_options, "DT") then
		ref_mpscale = ui.get(wpn.multi_point_on_dt)
	else
		ref_mpscale = ui.get(wpn.multi_point_default)
	end

	return ref_mpscale
end

local calculate_hitchance = function(e)
	local hc_state = "Def"
	local ref_hc = ui.get(wpn.hitchance_default)
	local fakeduck = ui.reference("RAGE", "Other", "Duck peek assist")
	if ui.get(wpn.hitchance_ove_key) and multi_select(wpn.hitchance_options, "On Key") then
		hc_state = "Key"
		ref_hc = ui.get(wpn.hitchance_on_key)
	elseif entity.is_alive(entity.get_local_player()) and (entity.get_prop(entity.get_local_player(), "m_fFlags") == 256 or entity.get_prop(entity.get_local_player(), "m_fFlags") == 262) and multi_select(wpn.hitchance_options, "In Air") then
		hc_state = "Air"
		ref_hc = ui.get(wpn.hitchance_on_air)
	elseif entity.get_prop(entity.get_local_player(), "m_bIsScoped") == 0 and multi_select(wpn.hitchance_options, "No Scope") then
		hc_state = "NoS"
		ref_hc = ui.get(wpn.hitchance_on_nos)
	elseif ui.get(fakeduck) and multi_select(wpn.hitchance_options, "FD") then
		hc_state = "FD"
		ref_hc = ui.get(wpn.hitchance_on_fd)
	else
		hc_state = "Def"
		ref_hc = ui.get(wpn.hitchance_default)
	end

	return {hc_state, ref_hc}
end
local calculate_damage = function(e)
	local dmg_state = "Def"
	local ref_dmg = ui.get(wpn.damage_default)
	local fakeduck = ui.reference("RAGE", "Other", "Duck peek assist")
	local double_check, double_key = ui.reference("RAGE", "Other", "Double tap")
	if ui.get(wpn.damage_ove_key2) and multi_select(wpn.damage_options, "On Key2") then
		dmg_state = "Key2"
		ref_dmg = ui.get(wpn.damage_on_key2)
	elseif ui.get(wpn.damage_ove_key) and multi_select(wpn.damage_options, "On Key") then
		dmg_state = "Key"
		ref_dmg = ui.get(wpn.damage_on_key)
	elseif entity.is_alive(entity.get_local_player()) and (entity.get_prop(entity.get_local_player(), "m_fFlags") == 256 or entity.get_prop(entity.get_local_player(), "m_fFlags") == 262) and multi_select(wpn.damage_options, "In Air") then
		dmg_state = "Air"
		ref_dmg = ui.get(wpn.damage_on_air)
	elseif ui.get(double_check) and ui.get(double_key) and multi_select(wpn.damage_options, "DT") then
		dmg_state = "DT"
		ref_dmg = ui.get(wpn.damage_on_dt)
	elseif visible_enemys(e) and multi_select(wpn.damage_options, "Visible") then
		dmg_state = "Vis"
		ref_dmg = ui.get(wpn.damage_on_vis)
	else
		dmg_state = "Def"
		ref_dmg = ui.get(wpn.damage_default)
	end

	return {dmg_state, ref_dmg}
end

local calculate_hitbox = function(e)
	if #ui.get(wpn.hitbox_default) <= 0 then
		ui.set(wpn.hitbox_default, "Head")
	end

	if #ui.get(wpn.hitbox_on_key) <= 0 then
		ui.set(wpn.hitbox_on_key, "Head")
	end

	if #ui.get(wpn.hitbox_on_dt) <= 0 then
		ui.set(wpn.hitbox_on_dt, "Head")
	end

	local ref_hitbox = ui.get(wpn.hitbox_default)
	local double_check, double_key = ui.reference("RAGE", "Other", "Double tap")
	if ui.get(wpn.hitbox_ove_key) and multi_select(wpn.hitbox_options, "On Key") then
		ref_hitbox = ui.get(wpn.hitbox_on_key)
	elseif ui.get(double_check) and ui.get(double_key) and multi_select(wpn.hitbox_options, "DT") then
		ref_hitbox = ui.get(wpn.hitbox_on_dt)
	else
		ref_hitbox = ui.get(wpn.hitbox_default)
	end

	return #ref_hitbox <= 0 and "Head" or ref_hitbox
end
local function gradient_text(r1, g1, b1, a1, r2, g2, b2, a2, text)
	local output = ''

	local len = #text-1

	local rinc = (r2 - r1) / len
	local ginc = (g2 - g1) / len
	local binc = (b2 - b1) / len
	local ainc = (a2 - a1) / len

	for i=1, len+1 do
		output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))

		r1 = r1 + rinc

		g1 = g1 + ginc
		b1 = b1 + binc
		a1 = a1 + ainc
	end

	return output
end
local arrow_one_colourpicker = ui.new_color_picker("RAGE", "Aimbot", "Arrow color", 142, 145, 255, 255 )
local arrow_two_colourpicker = ui.new_color_picker( "RAGE", "Aimbot", "Second", 145, 24, 224, 255 )

client.set_event_callback("paint", function(e)
	local ind_r, ind_g, ind_b, ind_a = ui.get( arrow_one_colourpicker ) -- Manual arrows 
    local cac_r, cac_g, cac_b, cac_a = ui.get( arrow_two_colourpicker ) -- Peeking arrows
	local hitbox = calculate_hitbox(e)
	local mp_scale = calculate_multi_point(e)
	local ref_hitbox = ui.reference("RAGE", "Aimbot", "Target hitbox")
	local ref_damage = ui.reference("RAGE", "Aimbot", "Minimum damage")
	local ref_multi_scale = ui.reference("RAGE", "Aimbot", "Multi-point scale")
	local ref_hitchance = ui.reference("RAGE", "Aimbot", "Minimum hit chance")
	local ref_perfer_baim = ui.reference("RAGE", "Other", "Prefer body aim")
	local damage_state, damage_value = calculate_damage(e)[1], calculate_damage(e)[2]
	local hitchance_state, hitchance_value = calculate_hitchance(e)[1], calculate_hitchance(e)[2]
	if ui.get(wpn.multi_point_override) then
		ui.set(ref_multi_scale, mp_scale)
	end

	if ui.get(wpn.damage_override) then
		ui.set(ref_damage, damage_value)
	end

	if ui.get(wpn.hitchance_override) then
		ui.set(ref_hitchance, hitchance_value)
	end

	if not ui.get(wpn.hitbox_ove_key) and not ui.get(wpn.force_head_key) and is_perfer_baim then
		perfer_baim_switch = ui.get(ref_perfer_baim)
	end

	if ui.get(wpn.hitbox_override) then
		ui.set(ref_hitbox, hitbox)
	end

	if ui.get(wpn.force_head_key) then
		ui.set(ref_hitbox, "Head")
		is_perfer_baim = false
	else
		if not ui.get(wpn.hitbox_override) and #ui.get( wpn.force_head_hitbox) > 0 then
			is_perfer_baim = true
			ui.set(ref_hitbox,ui.get( wpn.force_head_hitbox))
			ui.set(ref_perfer_baim,perfer_baim_switch)
		end
	end

	local crosshair_index = 0
	local r, g, b, a = ui.get(wpn.indicator_color)
	local screen_x, screen_y = client.screen_size()
	if not entity.is_alive(entity.get_local_player()) then
		return
	end

	local D_key = damage_state

	if hitchance_state == "Key" then
		hitchance_state = "OR"
	end
	local info6 = gradient_text(ind_r, ind_g, ind_b, ind_a, cac_r, cac_g, cac_b, cac_a, "D:" ..D_key .. " | H: " ..hitchance_state)
	local info7 = gradient_text(ind_r, ind_g, ind_b, ind_a, cac_r, cac_g, cac_b, cac_a, "D:" ..D_key .. " | H: " ..hitchance_state)
	if multi_select(wpn.state_indicator, "Text Value") then
		client.draw_indicator(c, r, g, b, a, info6)
	end

	if multi_select(wpn.state_indicator, "Text Value[Crosshair]") then
		crosshair_index = crosshair_index + 1
		renderer.text(screen_x / 2, screen_y / 2 + 35, r, g, b, a, "c", 0, info7)
	end
	local info2 = gradient_text(ind_r, ind_g, ind_b, ind_a, cac_r, cac_g, cac_b, cac_a, "DMG -> ")
	local info3 = gradient_text(ind_r, ind_g, ind_b, ind_a, cac_r, cac_g, cac_b, cac_a, "HTC -> ")
	if multi_select(wpn.state_indicator, "Damage Value") then
		client.draw_indicator(c, r, g, b, a,"" .. (ui.get(ref_damage) <= 100 and ui.get(ref_damage) or ("HP+" .. (ui.get(ref_damage) - 100))))
	end

	if multi_select(wpn.state_indicator, "Damage Value[Crosshair]") then
		crosshair_index = crosshair_index + 1
		renderer.text(screen_x / 2, screen_y / 2 + (multi_select(wpn.state_indicator, "Text Value[Crosshair]") and 50 or 35), r, g, b, a, "c", 0, info2 .. (ui.get(ref_damage) <= 100 and ui.get(ref_damage) or ("HP+" .. (ui.get(ref_damage) - 100))))
	end

	if multi_select(wpn.state_indicator, "Hitchance Value") then
		client.draw_indicator(c, r, g, b, a, info3 .. ui.get(ref_hitchance))
	end

	if multi_select(wpn.state_indicator, "Hitchance Value[Crosshair]") then
		renderer.text(screen_x / 2, screen_y / 2 + 35 + (crosshair_index * 15), r, g, b, a, "c", 0, info3 .. ui.get(ref_hitchance))
	end

	local rend = renderer.text
	local color = 255,255,255
	scx = screen_x / 2
	scy = screen_y / 2
	fhead_get = ui.get(wpn.force_head_key)
	ovdmg_get = ui.get(wpn.damage_ove_key) and multi_select(wpn.damage_options, "On Key")
	ovhc_get  = ui.get(wpn.hitchance_ove_key) and multi_select(wpn.hitchance_options, "On Key")
	ovhbox_get = ui.get(wpn.hitbox_ove_key) and multi_select(wpn.hitbox_options, "On Key")
	if multi_select(wpn.state_indicator, "Override state") then
		rend(scx, scy + 35,  255, fhead_get and 50 or 255, fhead_get and 50 or 255, fhead_get and 255 or 170, "-c", 0, "HEAD")
		rend(scx, scy + 44,  ovdmg_get and 253 or 255,ovdmg_get and 108 or 255,ovdmg_get and 158 or 255, ovdmg_get and 255 or 170, "-c", 0, "DMG")
		rend(scx, scy + 53,  ovhc_get and 255 or 255, ovhc_get and 255 or 255, ovhc_get and 0 or 255, ovhc_get and 255 or 170, "-c", 0, "HC")
		rend(scx, scy + 62,  ovhbox_get and 123 or 255, ovhbox_get and 193 or 255, ovhbox_get and 21 or 255, ovhbox_get and 255 or 170, "-c", 0, "HBOX")
	end

	if ui.get(wpn.force_head_key) then
		renderer.indicator(255, 50, 50,255,"HEAD SHOT")
	end

end)

local client_eye_position, client_set_event_callback, client_userid_to_entindex, entity_get_classname, entity_get_local_player, entity_get_player_weapon, entity_get_prop, entity_is_alive, math_atan2, math_cos, math_deg, math_rad, math_sin, math_sqrt, renderer_line, renderer_triangle, renderer_world_to_screen, ui_get, ui_new_checkbox, ui_new_color_picker, ui_new_hotkey, ui_new_multiselect, ui_new_slider, ui_reference, ui_set, ui_set_callback, ui_set_visible = client.eye_position, client.set_event_callback, client.userid_to_entindex, entity.get_classname, entity.get_local_player, entity.get_player_weapon, entity.get_prop, entity.is_alive, math.atan2, math.cos, math.deg, math.rad, math.sin, math.sqrt, renderer.line, renderer.triangle, renderer.world_to_screen, ui.get, ui.new_checkbox, ui.new_color_picker, ui.new_hotkey, ui.new_multiselect, ui.new_slider, ui.reference, ui.set, ui.set_callback, ui.set_visible
local stored_target = nil 
local quickstop_reference = ui_reference("RAGE", "Other", "Quick stop")
local enabled_reference = ui_new_checkbox("RAGE", "Other", "● Quick Peek")
local hotkey_reference = ui_new_hotkey("RAGE", "Other", "● Quick Peek Hotkey", true)
local triggers_reference = ui_new_multiselect("RAGE", "Other", "● Quick Peek Triggers", {"X shots", "Kill", "Standing still"})
local shots_reference = ui_new_slider("RAGE", "Other", "● Quick Peek Shots", 1, 6, 1)
local draw_reference = ui_new_checkbox("VISUALS", "Other ESP", "● Draw quick peek")
local color_reference = ui_new_color_picker("VISUALS", "Other ESP", "\n ● Quick peek color", 198, 70, 70, 146)
local peek_reference_cycle = ui_new_slider("VISUALS", "Other ESP", "Circle draw speed", 1, 10, 3,true,"",0.1)
local circle_reference_length = ui_new_slider("VISUALS", "Other ESP", "Circle maximum length", 1, 50, 15)
local single_fire_weapons = {
	"CDeagle",
	"CWeaponSSG08",
	"CWeaponAWP"
}

local function draw_circle_3d(x, y, z, radius, r, g, b, a, accuracy, width, outline, start_degrees, percentage, fill_r, fill_g, fill_b, fill_a)
	local accuracy = accuracy ~= nil and accuracy or 3
	local width = width ~= nil and width or 1
	local outline = outline ~= nil and outline or false
	local start_degrees = start_degrees ~= nil and start_degrees or 0
	local percentage = percentage ~= nil and percentage or 1

	local center_x, center_y
	if fill_a then
		center_x, center_y = renderer_world_to_screen(x, y, z)
	end

	local screen_x_line_old, screen_y_line_old
	for rot=start_degrees, percentage*360, accuracy do
		local rot_temp = math_rad(rot)
		local lineX, lineY, lineZ = radius * math_cos(rot_temp) + x, radius * math_sin(rot_temp) + y, z
		local screen_x_line, screen_y_line = renderer_world_to_screen(lineX, lineY, lineZ)
		if screen_x_line ~=nil and screen_x_line_old ~= nil then
			if fill_a and center_x ~= nil then
				renderer_triangle(screen_x_line, screen_y_line, screen_x_line_old, screen_y_line_old, center_x, center_y, fill_r, fill_g, fill_b, fill_a)
			end
			for i=1, width do
				local i=i-1
				renderer_line(screen_x_line, screen_y_line-i, screen_x_line_old, screen_y_line_old-i, r, g, b, a)
				renderer_line(screen_x_line-1, screen_y_line, screen_x_line_old-i, screen_y_line_old, r, g, b, a)
			end
			if outline then
				local outline_a = a/255*160
				renderer_line(screen_x_line, screen_y_line-width, screen_x_line_old, screen_y_line_old-width, 16, 16, 16, outline_a)
				renderer_line(screen_x_line, screen_y_line+1, screen_x_line_old, screen_y_line_old+1, 16, 16, 16, outline_a)
			end
		end
		screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
	end
end

local function distance3d(x1, y1, z1, x2, y2, z2)
	return math_sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1))
end

local function table_contains(tbl, val)
	for i = 1, #tbl do
		if tbl[i] == val then
			return true
		end
	end

	return false
end

local function vector_angles(x1, y1, z1, x2, y2, z2)
	local origin_x, origin_y, origin_z
	local target_x, target_y, target_z
	if x2 == nil then
		target_x, target_y, target_z = x1, y1, z1
		origin_x, origin_y, origin_z = client_eye_position()
		if origin_x == nil then



			
			return
		end
	else
		origin_x, origin_y, origin_z = x1, y1, z1
		target_x, target_y, target_z = x2, y2, z2
	end

	local delta_x, delta_y, delta_z = target_x-origin_x, target_y-origin_y, target_z-origin_z
	if delta_x == 0 and delta_y == 0 then
		return (delta_z > 0 and 270 or 90), 0
	else
		local yaw = math_deg(math_atan2(delta_y, delta_x))
		local hyp = math_sqrt(delta_x*delta_x + delta_y*delta_y)
		local pitch = math_deg(math_atan2(-delta_z, hyp))
		return pitch, yaw
	end
end

local hotkey_prev, shots, pos_x, pos_y, pos_z = false, 0
local quickstop_prev, quickstop_allowed, standing

local function update_visiblity()
	local enabled = ui_get(enabled_reference)
	ui.set_visible(hotkey_reference, enabled)
	ui_set_visible(triggers_reference, enabled)
	ui_set_visible(shots_reference, enabled and table_contains(ui_get(triggers_reference), "X shots"))

	if not enabled then
		hotkey_prev = false
		shots = 0
		pos_x = nil
	end
end
ui_set_callback(enabled_reference, update_visiblity)
ui_set_callback(triggers_reference, update_visiblity)
update_visiblity()

local nssb = 0
local function on_paint()
	if not ui_get(enabled_reference) then
		nssb = 0
		return
	end

	if ui_get(hotkey_reference) then
		nssb = nssb + ui.get(peek_reference_cycle)/10
		if nssb >= ui.get(circle_reference_length) then
			nssb = ui.get(circle_reference_length)
		end
	else
		nssb = nssb - ui.get(peek_reference_cycle)/10
		if nssb <= 0 then
			nssb = 0
		end
	end
	
	local is_enabled = ui_get(enabled_reference) and ui_get(hotkey_reference) and pos_x ~= nil and entity_is_alive(entity_get_local_player())

	if quickstop_allowed or not is_enabled then
		if quickstop_prev ~= nil then
			ui_set(quickstop_reference, true)
			quickstop_prev = nil
		end
		quickstop_allowed = nil
	end

	if not is_enabled or not ui_get(draw_reference) then
		return
	end

	local wx, wy = renderer_world_to_screen(pos_x, pos_y, pos_z)

	if wx ~= nil then
		local r, g, b, a = ui_get(color_reference)
		draw_circle_3d(pos_x, pos_y, pos_z, nssb, r, g, b, a, 3, 2, false, 0, 1, r, g, b, a*0.6)
	end
end
client_set_event_callback("paint", on_paint)

local function on_aim_fire(e)
	shots = shots + 1
end
client_set_event_callback("aim_fire", on_aim_fire)

local function on_player_death(e)
	if table_contains(ui_get(triggers_reference), "Kill") and client_userid_to_entindex(e.attacker) == entity_get_local_player() then
		shots = -1
	end
end
client_set_event_callback("player_death", on_player_death)

local ref_hitboxs = ui.reference("RAGE", "Aimbot", "Target hitbox")

local function on_setup_command(cmd)
	if not ui_get(enabled_reference) then
		return
	end

	if #ui.get( wpn.force_head_hitbox) <= 1 and #ui.get(ref_hitboxs) >= 2 then
		ui.set( wpn.force_head_hitbox,ui.get(ref_hitboxs))
	end

	local hotkey = ui_get(hotkey_reference)
	if hotkey then
		local local_player = entity_get_local_player()
		if not hotkey_prev then
			pos_x, pos_y, pos_z = entity_get_prop(local_player, "m_vecAbsOrigin")
			shots = 0
		end

		if cmd.in_attack == 1 then
			shots = -1
		end

		local is_single_fire_weapon = table_contains(single_fire_weapons, entity_get_classname(entity_get_player_weapon(local_player)))
		local shots_min = is_single_fire_weapon and 1 or ui_get(shots_reference)
		local triggers = ui_get(triggers_reference)

		if table_contains(triggers, "Standing still") then
			if not standing and distance3d(0, 0, 0, entity_get_prop(local_player, "m_vecVelocity")) < 15 then
				standing = true
			elseif cmd.sidemove ~= 0 or cmd.forwardmove ~= 0 then
				standing = false
			end
		else
			standing = false
		end

		if (table_contains(triggers, "X shots") and (shots >= shots_min or shots == -1)) or standing then
			local x, y, z = entity_get_prop(local_player, "m_vecAbsOrigin")

			if 15 > distance3d(x, y, z, pos_x, pos_y, pos_z) then
				shots = 0
				quickstop_allowed = true
			else
				local pitch, yaw = vector_angles(x, y, z, pos_x, pos_y, pos_z)
				local require_moving = false
				if not require_moving or cmd.forwardmove ~= 0 or cmd.sidemove ~= 0 then
					cmd.in_forward = 1
					cmd.in_back = 0
					cmd.in_moveleft = 0
					cmd.in_moveright = 0
					cmd.in_speed = 0

					cmd.forwardmove = 450
					cmd.sidemove = 0

					cmd.move_yaw = yaw

					if ui_get(quickstop_reference) then
						quickstop_prev = true
						ui_set(quickstop_reference, false)
					end
				end
			end
		else
			quickstop_allowed = true
		end
	else
		shots = 0
		pos_x = nil
	end

	hotkey_prev = hotkey
end
client_set_event_callback("setup_command", on_setup_command)
local hdf_dog = ui.new_checkbox("VISUALS", "Other ESP", "Text indicator for quick peek")

client.set_event_callback("paint", function()
if ui_get(enabled_reference) then
if ui_get(hdf_dog) then
	if ui_get(hotkey_reference) then
		local r, g, b, a = ui_get(color_reference)
			renderer.indicator(r, g, b, 255, "QUICK")
		else
			return
		end
	else
		return
	end
else
	return
end
end)

local function on_shutdown()
	if quickstop_prev ~= nil then
		ui_set(quickstop_reference, true)
		quickstop_prev = nil
	end
end

client_set_event_callback("shutdown", on_shutdown)

local callback_ui = function()
	ui.set_visible(wpn.multi_point_options, ui.get(wpn.multi_point_override))
	ui.set_visible(wpn.multi_point_default, ui.get(wpn.multi_point_override))
	ui.set_visible(wpn.multi_point_on_key, ui.get(wpn.multi_point_override) and multi_select(wpn.multi_point_options, "On Key"))
	ui.set_visible(wpn.multi_point_on_fd, ui.get(wpn.multi_point_override) and multi_select(wpn.multi_point_options, "FD"))
	ui.set_visible(wpn.multi_point_on_dt, ui.get(wpn.multi_point_override) and multi_select(wpn.multi_point_options, "DT"))
	ui.set_visible(wpn.hitchance_options, ui.get(wpn.hitchance_override))
	ui.set_visible(wpn.hitchance_default, ui.get(wpn.hitchance_override))
	ui.set_visible(wpn.hitchance_on_key, ui.get(wpn.hitchance_override) and multi_select(wpn.hitchance_options, "On Key"))
	ui.set_visible(wpn.hitchance_on_fd, ui.get(wpn.hitchance_override) and multi_select(wpn.hitchance_options, "FD"))
	ui.set_visible(wpn.hitchance_on_air, ui.get(wpn.hitchance_override) and multi_select(wpn.hitchance_options, "In Air"))
	ui.set_visible(wpn.hitchance_on_nos, ui.get(wpn.hitchance_override) and multi_select(wpn.hitchance_options, "No Scope"))
	ui.set_visible(wpn.damage_options, ui.get(wpn.damage_override))
	ui.set_visible(wpn.damage_default, ui.get(wpn.damage_override))
	ui.set_visible(wpn.damage_on_key, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "On Key"))
	ui.set_visible(wpn.damage_on_key2, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "On Key2"))
	ui.set_visible(wpn.damage_on_vis, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "Visible"))
	ui.set_visible(wpn.damage_on_air, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "In Air"))
	ui.set_visible(wpn.damage_on_dt, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "DT"))
	ui.set_visible(wpn.hitbox_options, ui.get(wpn.hitbox_override))
	ui.set_visible(wpn.hitbox_default, ui.get(wpn.hitbox_override))
	ui.set_visible(wpn.hitbox_on_key, ui.get(wpn.hitbox_override) and multi_select(wpn.hitbox_options, "On Key"))
	ui.set_visible(wpn.hitbox_on_dt, ui.get(wpn.hitbox_override) and multi_select(wpn.hitbox_options, "DT"))
	ui.set_visible(wpn.multi_point_ove_key, ui.get(wpn.multi_point_override) and multi_select(wpn.multi_point_options, "On Key"))
	ui.set_visible(wpn.hitchance_ove_key, ui.get(wpn.hitchance_override) and multi_select(wpn.hitchance_options, "On Key"))
	ui.set_visible(wpn.damage_ove_key, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "On Key"))
	ui.set_visible(wpn.damage_ove_key2, ui.get(wpn.damage_override) and multi_select(wpn.damage_options, "On Key2"))
	ui.set_visible(wpn.hitbox_ove_key, ui.get(wpn.hitbox_override) and multi_select(wpn.hitbox_options, "On Key"))
	ui.set_visible(wpn.indicator_color, #ui.get(wpn.state_indicator) ~= 0)
	ui.set_visible( wpn.force_head_hitbox,false)
end

callback_ui()
ui.set_callback(wpn.multi_point_options, callback_ui)
ui.set_callback(wpn.multi_point_override, callback_ui)
ui.set_callback(wpn.hitchance_options, callback_ui)
ui.set_callback(wpn.hitchance_override, callback_ui)
ui.set_callback(wpn.damage_override, callback_ui)
ui.set_callback(wpn.damage_options, callback_ui)
ui.set_callback(wpn.hitbox_override, callback_ui)
ui.set_callback(wpn.hitbox_options, callback_ui)
ui.set_callback(wpn.state_indicator, callback_ui)

local label_ref
local config_ref
local enable_ref
local references  = {}
local IDX_BUILTIN = 1
local IDX_GLOBAL  = 2
local active_config_idx = nil
local config_idx_to_name = {}
local config_name_to_idx = {}
local SPECATOR_TEAM_ID = 1
local weapon_id_to_config_idx = {}
local function copy_settings(config_idx_src, config_idx_dst)
    local src_refs = references[config_idx_src]
    local dst_refs = references[config_idx_dst]
    for i=1, #dst_refs do
        ui.set(dst_refs[i], ui.get(src_refs[i]))
    end
    ui.set( wpn.force_head_hitbox, ui.get(src_refs[2]))
end

local function load_config(config_idx)
    if active_config_idx ~= config_idx then
        active_config_idx = config_idx
        copy_settings(config_idx, IDX_BUILTIN)
        ui.set(label_ref, "Active Weapon Config: " .. config_idx_to_name[config_idx])
    end
end

local function update_config_visibility(state)
    local display_config = state
    local script_state = ui.get(enable_ref)
    if display_config == nil then
        display_config = entity.is_alive(entity.get_local_player()) == false
    end

    local display_label = not display_config
    ui.set_visible(config_ref, display_config and script_state)
    ui.set_visible(label_ref, display_label and script_state)
    return display_config
end

local function save_reference(config_idx, setting_idx, ref)
    references[config_idx][setting_idx] = ref
    return ref
end

local function bind(func, ...)
    local args = {...}
    return function(ref)
        func(ref, unpack(args))
    end
end

local function delayed_bind(func, delay, ...)
    local args = {...}
    return function(ref)
        client.delay_call(delay, func, ref, unpack(args))
    end
end

local function temp_task()
    update_config_visibility()
    client.delay_call(5, temp_task)
end

local function on_setup_command()
    local local_player = entity.get_local_player()
    local weapon = entity.get_player_weapon(local_player)
    local weapon_id = bit.band(entity.get_prop(weapon, "m_iItemDefinitionIndex"), 0xFFFF)
    load_config(weapon_id_to_config_idx[weapon_id] or IDX_GLOBAL)
end

local function on_player_death(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        update_config_visibility(true)
    end
end

local function on_player_spawn(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        update_config_visibility(false)
    end
end

local function on_player_team_change(e)
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        if e.team == SPECATOR_TEAM_ID then
            update_config_visibility(true)
        end
    end
end

local function on_game_disconnect(e)
    update_config_visibility(true)
end

local function on_weapon_config_selected(ref)
    if update_config_visibility() == false then
        return
    end

    local config_name = ui.get(ref)
    local config_idx = config_name_to_idx[config_name]
    load_config(config_idx)
end

local function on_builtin_setting_change(ref, setting_idx)
    if active_config_idx ~= nil and ui.get(enable_ref) == true then
        ui.set(references[active_config_idx][setting_idx], ui.get(ref))
    end
end

local function on_adaptive_setting_changed(ref, config_idx, setting_idx)
    if config_idx == active_config_idx and ui.get(enable_ref) == true then
        ui.set(references[IDX_BUILTIN][setting_idx], ui.get(ref))
    end
end

local function on_adaptive_config_toggled(ref)
    local script_state = ui.get(ref)
    update_config_visibility()
    local update_callback = script_state and client.set_event_callback or client.unset_event_callback
    update_callback("setup_command", on_setup_command)
    update_callback("player_death", on_player_death)
    update_callback("player_spawn", on_player_spawn)
    update_callback("player_team", on_player_team_change)
    update_callback("cs_game_disconnected", on_game_disconnect)
end

local function duplicate(tab, container, name, ui_func, ...)
    local setting_index = #references[IDX_BUILTIN] + 1
    for i = IDX_GLOBAL, #references do
        local config_name = config_idx_to_name[i]
        local ref = save_reference(i, setting_index, ui_func(tab, container, config_name .. " " .. name:lower(), ...))
        if name == "Target hitbox" then
            ui.set(ref, {"Head"})
        end

        if name == "● Hitbox [Def]" then
            ui.set(ref, {"Head"})
        end


        if name == "● Hitbox [On Key]" then
            ui.set(ref, {"Head"})
        end

        if name == "● Hitbox [DT]" then
            ui.set(ref, {"Head"})
        end

        ui.set_visible(ref, false)
        ui.set_callback(ref, bind(on_adaptive_setting_changed, i, setting_index))
    end

    local ref = save_reference(IDX_BUILTIN, setting_index, ui.reference(tab, container, name))
    ui.set_callback(ref, delayed_bind(on_builtin_setting_change, 0.01, setting_index))
end

local function init_config(name, ...)
    local config_idx = #references + 1
    references[config_idx] = {}
    config_idx_to_name[config_idx] = name
    config_name_to_idx[name] = config_idx
    for _, weapon_id in ipairs({...}) do
        weapon_id_to_config_idx[weapon_id] = config_idx
    end

    return config_idx
end

local function init()
    IDX_BUILTIN = init_config("Built-in menu items")
    init_config("Global")
    init_config("Awp", 9)
    init_config("Scout", 40)
    init_config("Desert Eagle", 1)
    init_config("Auto", 11, 38)
    init_config("Revolver", 64)
    init_config("Pistol", 2, 3, 4, 30, 32, 36, 61, 63)
    init_config("Rifle", 7, 8, 10, 13, 16, 39, 60)
    init_config("Submachine gun", 17, 19, 23, 24, 26, 33, 34)
    init_config("Machine gun", 14, 28)
    init_config("Shotgun", 25, 27, 29, 35)
    init_config("Taser Zeus", 31)
    assert(config_idx_to_name[IDX_GLOBAL] == "Global")
    enable_ref = ui.new_checkbox("RAGE", "Other", "Adaptive Config")
    config_ref = ui.new_combobox("RAGE", "Other", "\n Adaptive Config Actives", config_idx_to_name)
    label_ref = ui.new_label("RAGE", "Other", "Active Weapon Config: " .. ui.get(config_ref))
    duplicate("RAGE", "Aimbot", "Target selection", ui.new_combobox, "Cycle", "Cycle (2x)", "Near crosshair", "Highest damage", "Lowest ping", "Best K/D ratio", "Best hit chance")
    duplicate("RAGE", "Aimbot", "Target hitbox", ui.new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    duplicate("RAGE", "Aimbot", "Multi-point", ui.new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    duplicate("RAGE", "Aimbot", "● Multipoint Override", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "● Multi Point Opotion", ui.new_multiselect, {"On Key", "FD", "DT"})
    duplicate("RAGE", "Aimbot", "● Multi-Point Scale [Def]", ui.new_slider, 24, 100, 64, true, "%", 1, multipoint_override)
    duplicate("RAGE", "Aimbot", "● Multi-Point Scale [On Key]", ui.new_slider, 24, 100, 64, true, "%", 1, multipoint_override)
    duplicate("RAGE", "Aimbot", "● Multi-Point Scale [FD]", ui.new_slider, 24, 100, 64, true, "%", 1, multipoint_override)
    duplicate("RAGE", "Aimbot", "● Multi-Point Scale [DT]", ui.new_slider, 24, 100, 64, true, "%", 1, multipoint_override)
    duplicate("RAGE", "Aimbot", "● Hitchance Override", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "● Hitchance Opotion", ui.new_multiselect, {"On Key", "FD", "In Air", "No Scope"})
    duplicate("RAGE", "Aimbot", "● Hitchance [Def]", ui.new_slider, 0, 100, 61, true, "%", 1, {[0] = "Auto"})
    duplicate("RAGE", "Aimbot", "● Hitchance [On Key]", ui.new_slider, 0, 100, 61, true, "%", 1, {[0] = "Auto"})
    duplicate("RAGE", "Aimbot", "● Hitchance [FD]", ui.new_slider, 0, 100, 61, true, "%", 1, {[0] = "Auto"})
    duplicate("RAGE", "Aimbot", "● Hitchance [In Air]", ui.new_slider, 0, 100, 61, true, "%", 1, {[0] = "Auto"})
    duplicate("RAGE", "Aimbot", "● Hitchance [Nos]", ui.new_slider, 0, 100, 61, true, "%", 1, {[0] = "Auto"})
    duplicate("RAGE", "Aimbot", "● Damage Override", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "● Damage Opotion", ui.new_multiselect, {"On Key", "On Key2", "Visible", "In Air", "DT"})
    duplicate("RAGE", "Aimbot", "● Damage [Def]", ui.new_slider, 0, 126, 20, true, "", 1, damage_labels_select)
    duplicate("RAGE", "Aimbot", "● Damage [On Key]", ui.new_slider, 0, 126, 20, true, "", 1, damage_labels_select)
    duplicate("RAGE", "Aimbot", "● Damage [On Key2]", ui.new_slider, 0, 126, 20, true, "", 1, damage_labels_select)
    duplicate("RAGE", "Aimbot", "● Damage [Visible]", ui.new_slider, 0, 126, 20, true, "", 1, damage_labels_select)
    duplicate("RAGE", "Aimbot", "● Damage [In Air]", ui.new_slider, 0, 126, 20, true, "", 1, damage_labels_select)
    duplicate("RAGE", "Aimbot", "● Damage [DT]", ui.new_slider, 0, 126, 20, true, "", 1, damage_labels_select)
    duplicate("RAGE", "Aimbot", "● Hitbox Override", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "● Hitbox Opotion", ui.new_multiselect, {"On Key", "DT"})
    duplicate("RAGE", "Aimbot", "● Hitbox [Def]", ui.new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    duplicate("RAGE", "Aimbot", "● Hitbox [On Key]", ui.new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    duplicate("RAGE", "Aimbot", "● Hitbox [DT]", ui.new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs", "Feet")
    duplicate("RAGE", "Aimbot", "Multi-point scale", ui.new_slider, 24, 100, 24, true, "%", 1, multipoint_override)
    -- duplicate("RAGE", "Aimbot", "Dynamic multi-point", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "Prefer safe point", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "Avoid unsafe hitboxes", ui.new_multiselect, "Head", "Chest", "Stomach", "Arms", "Legs")
    -- duplicate("RAGE", "Aimbot", "Automatic fire", ui.new_checkbox)
    -- duplicate("RAGE", "Aimbot", "Automatic penetration", ui.new_checkbox)
    -- duplicate("RAGE", "Aimbot", "Silent aim", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "Minimum hit chance", ui.new_slider, 0, 100, 50, true, "%", 1, wpn.hitchance_override)
    duplicate("RAGE", "Aimbot", "Minimum damage", ui.new_slider, 0, 126, 0, true, "%", 1, mindamage_override)
    duplicate("RAGE", "Aimbot", "Automatic scope", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "Maximum FOV", ui.new_slider, 1, 180, 180, true, "°")
    -- duplicate("RAGE", "Other", "Remove recoil", ui.new_checkbox)
    duplicate("RAGE", "Other", "Accuracy boost", ui.new_combobox,"Low", "Medium", "High", "Maximum")
    duplicate("RAGE", "Other", "Delay shot", ui.new_checkbox)
    duplicate("RAGE", "Other", "Quick stop", ui.new_checkbox)
    duplicate("RAGE", "Other", "Quick stop options", ui.new_multiselect, "Early", "Slow motion", "Duck", "Move between shots", "Ignore molotov","Taser")
    duplicate("RAGE", "Other", "Prefer body aim", ui.new_checkbox)
    duplicate("RAGE", "Other", "Prefer body aim disablers", ui.new_multiselect, "Low inaccuracy", "Target shot fired", "Target resolved", "Safe point headshot", "Low damage")
--    duplicate("RAGE", "Other", "Force body aim on peek", ui.new_checkbox)
    duplicate("RAGE", "Other", "Double tap quick stop", ui.new_multiselect, "Slow motion", "Duck", "Move between shots")
    duplicate("RAGE", "Other", "Double tap", ui.new_checkbox)
    duplicate("RAGE", "Aimbot", "Low FPS mitigations", ui.new_multiselect, "Force low accuracy boost", "Disable multipoint: feet", "Disable multipoint: arms", "Disable multipoint: legs", "Disable hitbox: feet", "Force low multipoint", "Lower hit chance precision", "Limit targets per tick")
    duplicate("RAGE", "Other", "● Quick Peek", ui.new_checkbox)
    duplicate("RAGE", "Other", "● Quick Peek Triggers", ui.new_multiselect, {"X shots", "Kill", "Standing still"})
    duplicate("RAGE", "Other", "● Quick Peek Shots", ui.new_slider, 1, 6, 1)
    local create_custom_reference = function(req, ref)
        local reference_if_exists = function(...)
            if pcall(ui.reference, ...) then
                 return true
            end
        end

        local get_script_name = function()
            local funca, err = pcall(function() _G() end)
            local get_script_name = function()
       return "XXX-Weapon"
end
        end

        if not reference_if_exists(ref[1], ref[2], ref[3]) then
            if pcall(require, req) and reference_if_exists(ref[1], ref[2], ref[3]) then
                duplicate(unpack(ref))
            else
                client.log(string.format('%s: Unable to reference - %s (%s.lua/ljbc)', get_script_name(), ref[3], req))
            end
        else
            duplicate(unpack(ref))
        end
    end

    --create_custom_reference("o_weapon_super_safety", { "RAGE", "Other", "Force safe point", ui.new_checkbox })
    create_custom_reference("o_weapon_mindmg", { "RAGE", "Other", "Minimum damage override", ui.new_checkbox })
    create_custom_reference("o_weapon_mindmg", { "RAGE", "Other", "Override damage", ui.new_slider, 0, 126, 0, true, "%", 1, mindamage_override })
    create_custom_reference("o_weapon_mindmg", { "RAGE", "Other", "Restore damage", ui.new_slider, 0, 126, 0, true, "%", 1, mindamage_override })

    --[[
        local el = {
            prefer_head = { 'Target shot fired', 'In air', 'Is crouching', 'Is walking', 'Backwards/Forwards', 'Sideways' },
            prefer_body = { 'Force condition', 'Target shot fired', 'In air', 'Is crouching', 'Is walking', 'Backwards/Forwards', 'Sideways', '2 Shots', 'Lethal', '<x HP', 'Correction active' },
        }
    
        create_custom_reference("m_threat_scan", { "RAGE", "Other", "Prefer head-aim", ui.new_multiselect, el.prefer_head })
        create_custom_reference("m_threat_scan", { "RAGE", "Other", "Prefer body-aim", ui.new_multiselect, el.prefer_body })
        create_custom_reference("m_threat_scan", { "RAGE", "Other", "Force body-aim", ui.new_multiselect, el.prefer_body })
        create_custom_reference("m_threat_scan", { "RAGE", "Other", "Force safety", ui.new_multiselect, el.prefer_body })
        create_custom_reference("m_threat_scan", { "RAGE", "Other", "Force safety after x misses", ui.new_slider, 0, 10, 0, true, "", 1, { [0] = 'Off' } })
        create_custom_reference("m_threat_scan", { "RAGE", "Other", "<x HP Condition", ui.new_slider, 1, 100, 25 })
    ]]

    ui.set_callback(config_ref, on_weapon_config_selected)
	ui.set_callback(enable_ref, on_adaptive_config_toggled)
    
    temp_task()
	on_adaptive_config_toggled(enable_ref)
end

init()

local client_set_event_callback, client_unset_event_callback, client_userid_to_entindex, client_register_esp_flag, entity_get_players, entity_is_enemy, globals_tickcount, globals_tickinterval, plist_set, plist_get, ui_get, ui_new_checkbox, ui_new_slider, ui_new_color_picker, ui_set_callback, ui_set_visible = client.set_event_callback, client.unset_event_callback, client.userid_to_entindex, client.register_esp_flag, entity.get_players, entity.is_enemy, globals.tickcount, globals.tickinterval, plist.set, plist.get, ui.get, ui.new_checkbox, ui.new_slider, ui.new_color_picker, ui.set_callback, ui.set_visible
local sp = {
	 Label         = ui.new_label("RAGE", "Other", "-----------Force Baim/SP Options-----------"),
	 master_switch = ui_new_checkbox("RAGE", "Other", "Enable Force SP after X misses"),
	 max_misses    = ui_new_slider("RAGE", "Other", "- Misses to enable Force SP", 1, 5, 2),
	 reset_time    = ui_new_slider("RAGE", "Other", "- Seconds to reset misses", 5, 15, 10),	
	 esp_flag      = ui_new_checkbox("RAGE", "Other", "- Add 'SAFE' flag to ESP")
}


ui_set_visible(sp.max_misses, false)
ui_set_visible(sp.reset_time, false)
ui_set_visible(sp.esp_flag, false)

local shot_data = {}

local function on_aim_miss(e)
    if not ui_get(sp.master_switch) then return end
	
    if e.reason ~= "?" then return end
	
    local entindex  = e.target
    local data      = {}

    if shot_data[entindex] == nil then
        data.tickcount  = globals_tickcount()
        data.misses     = 0

        shot_data[entindex] = data
    end

    data.tickcount  = globals_tickcount()
    data.misses     = shot_data[entindex].misses + 1

    shot_data[entindex] = data

    if shot_data[entindex].misses >= ui_get(sp.max_misses) then
	    print("Missed. Force safe point")
		plist_set(entindex, "Override safe point", "On")
    end
end

local function on_run_command(e)
    if not ui_get(sp.master_switch) then return end

    if shot_data == nil then return end
    
    local current_tickcount = globals_tickcount()
    local players           = entity_get_players(true)

    for i = 1, #players do
        local entindex = players[i]

        if shot_data[entindex] == nil then return end

        local miss_tickcount    = shot_data[entindex].tickcount
        local delta             = current_tickcount - miss_tickcount
        local time_elapsed      = delta * globals_tickinterval()

        if time_elapsed >= ui_get(sp.reset_time) then
            plist_set(entindex, "Override safe point", "-")
            shot_data[entindex] = nil
        end
    end
end

local function on_player_death(e)
    if not ui_get(sp.master_switch) then return end

    if shot_data == nil then return end

    local entindex = client_userid_to_entindex(e.userid)
    
    if not entity_is_enemy(entindex) then return end

            plist_set(entindex, "Override safe point", "-")
    shot_data[entindex] = nil
end
local function on_round_prestart()
    if not ui_get(sp.master_switch) then return end

    if shot_data == nil then return end

    local players = entity_get_players(true)

    for i = 1, #players do
        local entindex = players[i]

        if shot_data[entindex] == nil then return end

        plist_set(entindex, "Override safe point", "-")
        shot_data[entindex] = nil
    end
end

client_register_esp_flag("SAFE", 255, 0, 0, function(player)
    if not ui_get(sp.master_switch) then return false end

    if not ui_get(sp.esp_flag) then return false end

    return plist_get(player, "Override safe point") == "On"
end)




ui_set_callback(sp.master_switch, function()
    local enabled = ui_get(sp.master_switch)
    local update_callback = enabled and client_set_event_callback or client_unset_event_callback

    update_callback("aim_miss", on_aim_miss)
    update_callback("run_command", on_run_command)
    update_callback("player_death", on_player_death)
    update_callback("round_prestart", on_round_prestart)

    ui_set_visible(sp.max_misses, enabled)
    ui_set_visible(sp.reset_time, enabled)
    ui_set_visible(sp.esp_flag, enabled)
end)

local aa = {
  ref_plist = ui.reference("PLAYERS", "Players", "Player list"),
  ref_pref_baim = ui.reference("PLAYERS", "Adjustments", "Override prefer body aim"),
  options = ui.new_multiselect("Rage", "Other" , "Prefer body aim","Backwards/Forwards","Moving targets","Slow targets","Shooting","x2 HP","<x HP","Big desync","Walking jitter desync","Always on"),
  force_options = ui.new_multiselect("Rage", "Other" , "Force body aim", "Backwards/Forwards","Sideways targets","Slow targets","Shooting","x1 HP", "x2 HP","<x HP","Walking jitter desync","1 miss","2 miss"),
  indicator = ui.new_checkbox("Rage", "Other" ,"Indicator"),
  ref_hp_slider = ui.new_slider("Rage", "Other" , "HP",1,100),
  reset_misses = ui.new_checkbox("Rage", "Other" , "Reset misses after round end"),
  ref_desync = ui.new_slider("Rage", "Other" , "Desync limit",290,580,290,true,"掳",0.1),
  range_slider = ui.new_slider("Rage", "Other" , "Range",1,70,30,true,"掳"),
  jitter_sensitivity = ui.new_slider("Rage", "Other" , "Jitter Sensitivity",1,10,6,true),
  fakelag_slider = ui.new_slider("Rage", "Other" , "Headaim fakelag ammount",0,14),
  reset_hotkey = ui.new_hotkey("Rage", "Other" , "Reset enemy"),
  ref_mindamage = ui.reference("RAGE", "Aimbot", "Minimum damage")
}


ui.set_visible(aa.range_slider,false)
ui.set_visible(aa.ref_desync,false)
ui.set_visible(aa.ref_hp_slider,false)
ui.set_visible(aa.jitter_sensitivity,false)
ui.set_visible(aa.fakelag_slider,false)
local missLogs = {}
local simTimes = {}
local oldSimTimes = {}
local chokes = {}
local cached_plist
for i=1, 64 do
	missLogs[i] = 0
end

local function vector_angles(x1, y1, z1, x2, y2, z2) -- @sapphyrus
    --https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/mathlib/mathlib_base.cpp#L535-L563
    local origin_x, origin_y, origin_z
    local target_x, target_y, target_z
    if x2 == nil then
        target_x, target_y, target_z = x1, y1, z1
        origin_x, origin_y, origin_z = client.eye_position()
        if origin_x == nil then
            return
        end
    else
        origin_x, origin_y, origin_z = x1, y1, z1
        target_x, target_y, target_z = x2, y2, z2
    end
 
    --calculate delta of vectors
    local delta_x, delta_y, delta_z = target_x-origin_x, target_y-origin_y, target_z-origin_z
 
    if delta_x == 0 and delta_y == 0 then
        return (delta_z > 0 and 270 or 90), 0
    else
        --calculate yaw
        local yaw = math.deg(math.atan2(delta_y, delta_x))
 
        --calculate pitch
        local hyp = math.sqrt(delta_x*delta_x + delta_y*delta_y)
        local pitch = math.deg(math.atan2(-delta_z, hyp))
 
        return pitch, yaw
    end
end

local function normalise_angle(angle)
	angle =  angle % 360 
	angle = (angle + 360) % 360
	if (angle > 180)  then
		angle = angle - 360
	end
	return angle
end

local function is_moving(index)
	local x,y,z = entity.get_prop(index, "m_vecVelocity")
	return math.sqrt(x * x + y * y + z * z) > 1.0
end


local function ent_speed_2d(index)
	local x,y,z = entity.get_prop(index, "m_vecVelocity")
	return math.sqrt(x * x + y * y)
end


local function body_yaw(entityindex)
	bodyyaw = entity.get_prop(entityindex, "m_flPoseParameter", 11)
	if bodyyaw ~= nil then
		bodyyaw = bodyyaw * 120 - 60
	else
		return nil
	end
	return bodyyaw
end


local function max_desync(entityindex)
	local spd = math.min(260, ent_speed_2d(entityindex))
	local walkfrac = math.max(0, math.min(1, spd / 135))
	local mult = 1 - 0.5*walkfrac
	local duckamnt = entity.get_prop(entityindex, "m_flDuckAmount")
	
	if duckamnt > 0 then
		local duckfrac = math.max(0, math.min(1, spd / 88))
		mult = mult + ((duckamnt * duckfrac) * (0.5 - mult))
	end
	
	return(58 * mult)
end


local closest_player = 0

local function vec3_normalize(x, y, z)
	local len = math.sqrt(x * x + y * y + z * z)
	if len == 0 then
		return 0, 0, 0
	end
	local r = 1 / len
	return x*r, y*r, z*r
end

local function vec3_dot(ax, ay, az, bx, by, bz)
	return ax*bx + ay*by + az*bz
end

local function angle_to_vec(pitch, yaw)
	local p, y = math.rad(pitch), math.rad(yaw)
	local sp, cp, sy, cy = math.sin(p), math.cos(p), math.sin(y), math.cos(y)
	return cp*cy, cp*sy, -sp
end

local function ent_speed(index)
	local x,y,z = entity.get_prop(index, "m_vecVelocity")
	if x == nil then
		return 0
	end
	return math.sqrt(x * x + y * y + z * z)
end

-- ent: entity index of target player
-- vx,vy,vz: local player view direction
-- lx,ly,lz: local player origin
local function get_fov_cos(ent, vx,vy,vz, lx,ly,lz)
	local ox,oy,oz = entity.get_prop(ent, "m_vecOrigin")
	if ox == nil then
		return -1
	end

	-- get direction to player
	local dx,dy,dz = vec3_normalize(ox-lx, oy-ly, oz-lz)
	return vec3_dot(dx,dy,dz, vx,vy,vz)
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function is_x_shots(local_player,target,shots)
	
	local px, py, pz = entity.hitbox_position(target, 6) -- middle chest
	local px1, py1, pz1 = entity.hitbox_position(target, 4) -- upper chest
	local px2, py2, pz2 = entity.hitbox_position(target, 2) -- pelvis
	local lx,ly,lz = client.eye_position()
	for i=0, 2 do
	
		if i==0 then
			entindex,dmg = client.trace_bullet(local_player,lx,ly,lz,px,py,pz)
		else 
			if i==1 then
				entindex,dmg = client.trace_bullet(local_player,lx,ly,lz,px1,py1,pz1)
			else
				entindex,dmg = client.trace_bullet(local_player,lx,ly,lz,px2,py2,pz2)
			end
		end
		
		
		if entindex == nil then
			return false
		end
		
		if entindex == local_player then
			return false
		end
		
		if not entity.is_enemy(entindex) then
			return false
		end
		
		if dmg >= (entity.get_prop(target, "m_iHealth") / shots) then
			return true
		end
	end
	return false
end


local history = {}
local jitter_delta = 15

local function detect_jitter(i)
	local length = #history[i]
	if length == nil then 
		return 
	end
	
	if length < 65 then
		return 
	end

	local count = 0
	
	for j=(length - 64), length do
	--if both or either body yaws are positive/negative, then we subtract
		if history[i][j] ~= nil and history[i][j - 1] ~= nil then
			if (history[i][j] > 0 and history[i][j - 1] > 0) or (history[i][j] < 0 and history[i][j - 1] < 0) then
				if math.abs((history[i][j] - history[i][j - 1])) > jitter_delta then
					count = count + 1
				end
			else
				--if xor, then we add
				if (history[i][j] > 0 and history[i][j - 1] < 0) or (history[i][j] < 0 and history[i][j - 1] > 0)  then 
					if math.abs((history[i][j] + history[i][j - 1])) > jitter_delta then
						count = count + 1
					end
				end
			end	
		end
	end
	
	if count >= (10 - ui.get(aa.jitter_sensitivity)) then 
		return true
	else
		return false
	end
end

local player_preference = {}

local function on_paint(c)
	if has_value(ui.get(aa.options),"Backwards/Forwards") or has_value(ui.get(aa.force_options),"Backwards/Forwards") 
	or has_value(ui.get(aa.force_options),"Sideways targets")  then
		ui.set_visible(aa.range_slider,true)
	else
		ui.set_visible(aa.range_slider,false)
	end
	
	if has_value(ui.get(aa.options),"Walking jitter desync") or has_value(ui.get(aa.force_options),"Walking jitter desync") then
		ui.set_visible(aa.jitter_sensitivity,true)
	else
		ui.set_visible(aa.jitter_sensitivity,false)
	end
	
	if has_value(ui.get(aa.options),"<x HP") or has_value(ui.get(aa.force_options),"<x HP")  then
		ui.set_visible(aa.ref_hp_slider,true)
	else
		ui.set_visible(aa.ref_hp_slider,false)
	end
	-- getting nearest player
	
	local entindex = entity.get_local_player()
	if entindex == nil then
		return
	end
	
	local lx,ly,lz = entity.get_prop(entindex, "m_vecOrigin")
	if lx == nil then return end
	local players = entity.get_players(true)
	local pitch, yaw = client.camera_angles()
	local vx, vy, vz = angle_to_vec(pitch, yaw)
	
	-- start out with 180 degrees as the closest
	-- cos(deg2rad(180)) is -1
	local closest_fov_cos = -1

	for i=1, #players do
		entindex = players[i]

		local fov_cos = get_fov_cos(entindex, vx,vy,vz, lx,ly,lz)
		if fov_cos > closest_fov_cos then
			-- this player is closer to our crosshair
			closest_fov_cos = fov_cos
			closest_player = entindex
		end
	end


	-- drawing the aa.indicator
	if not ui.get(aa.indicator) then
		return
	end
	
	local local_player = entity.get_local_player()
	
	if local_player == nil then
		return
	end
	
	if not entity.is_alive(local_player) then
		return
	end

    local players = entity.get_players(true)
	
	if players == nil then
		return
	end
	
	-- getting eyeposition
	local lx,ly,lz = client.eye_position()
	
	if lx == nil then
		return
	end
	
	
	for i=1, #players do
		
        local player_index = players[i]
		
		if not entity.is_enemy(player_index) then
			return
		end
		
		local pos_x, pos_y, pos_z = entity.get_prop(player_index, "m_vecAbsOrigin")
		
        if pos_x == nil then
            return
        end
		local pulse = math.sin(math.abs((math.pi * -1) + (globals.curtime() * (1 / 0.23)) % (math.pi * 2))) * 255
		local selected = player_preference[player_index]
		local r,g,b = 0
		if selected == "-" or selected == "Off" then
			selected = " "
			r,g,b = 255,0,0
			else if selected == "On" then
				selected = "PREFER"
				r,g,b = 231,91,18
				else if selected == "Force" then
					selected = "FORCE"
					r,g,b = 255,255,255
				end
			end
		end
		
		local x1, y1, x2 , y2 , mult = entity.get_bounding_box(player_index)
		if x1 ~= nil and mult > 0 then
			y1 = y1 - 17
			x1 = x1 + ((x2 - x1) / 2)
			if  y1 ~= nil then
				renderer.text(x1, y1, r, g, b, pulse, "cb", 0, selected)
			end
		end
	end
	
	-- resetting the person we are aiming at, if the hotkey is held.
	
	if ui.get(aa.reset_hotkey) then
		if closest_player ~= 0 then
			missLogs[closest_player] = 0
		end
	end

end
client.set_event_callback('paint', on_paint)

local headaim_delay = {}

local function normalise_angle(angle)
	angle =  angle % 360 
	angle = (angle + 360) % 360
	if (angle > 180)  then
		angle = angle - 360
	end
	return angle
end

local function run_command(cmd)
	local local_player = entity.get_local_player()
	
	if local_player == nil then
		return
	end
	
	if not entity.is_alive(local_player) then
		return
	end

    local players = entity.get_players(true)
	
	if players == nil then
		return
	end
	
	-- getting eyeposition
	local lx,ly,lz = client.eye_position()
	
	if lx == nil then
		return
	end
	
	local lpx, lpy, lpz = entity.hitbox_position(local_player, 0) -- head
	local lpx1, lpy1, lpz1 = entity.hitbox_position(local_player, 4) -- upper chest
	local lpx2, lpy2, lpz2 = entity.hitbox_position(local_player, 2) -- pelvis
	
    cached_plist = ui.get( aa.ref_plist)
	
	
	local active_weapon = entity.get_prop(local_player, "m_hActiveWeapon")
		
	if active_weapon == nil then
		return
	end
		
	local idx = entity.get_prop(active_weapon, "m_iItemDefinitionIndex")
		
	if idx == nil then 
		return
	end
		
	local item = bit.band(idx, 0xFFFF)
		
	if item == nil then
		return
	end
	
	for i=1, #players do
		
        local player_index = players[i]
		local pos_x, pos_y, pos_z = entity.get_prop(player_index, "m_vecAbsOrigin")
		
        if pos_x ~= nil then
		
			local t = body_yaw(player_index)
			
			if t ~= nil then
				if history[player_index] == nil then
					history[player_index] = {}
				end
				list_len = #history[player_index]
				history[player_index][list_len+ 1] = t --push back their body yaw
			end
			
			if not entity.is_dormant(player_index) and entity.is_alive(player_index) then
			
				ui.set( aa.ref_plist, player_index) -- target this player_index
				ui.set( aa.ref_pref_baim, "-")
				
				local selected_options = ui.get(aa.options)
				local forced = false
				local prefer = false
				local head = false
				
				
				if item == 31 then
					--client.log("zeus force")
					ui.set( aa.ref_pref_baim, "Force")
					forced = true
				end
				if not forced then
				-- baim aa.options
					if ui.get( aa.ref_pref_baim) ~= "On" then
						if has_value(selected_options,"Backwards/Forwards") then
							local pitch, yaw = vector_angles(pos_x, pos_y, pos_z, lx,ly,lz)
							local _,model_yaw = entity.get_prop(player_index, "m_angEyeAngles")
							local delta = math.abs(normalise_angle(yaw - model_yaw))
							if delta > 90 + ui.get(aa.range_slider) or delta < 90 - ui.get(aa.range_slider) then
								ui.set( aa.ref_pref_baim, "On")
								prefer = true
							end
						end
						if has_value(selected_options,"Moving targets") and not prefer then
							if is_moving(player_index) then
								ui.set( aa.ref_pref_baim, "On")
								prefer = true
							end
						end
						if has_value(selected_options,"Slow targets") and not prefer then
							if ent_speed(player_index) > 1.0 and ent_speed(player_index) < 80 then
								ui.set( aa.ref_pref_baim, "On")
								prefer = true
							end
						end
						if has_value(selected_options,"x2 HP") and not prefer then
							if  is_x_shots(local_player,player_index,2) then
								ui.set( aa.ref_pref_baim, "On")
								prefer = true
							end
						end
						if has_value(selected_options,"<x HP") and not prefer then
							if entity.get_prop(player_index,"m_iHealth") <= ui.get(aa.ref_hp_slider) then
								ui.set( aa.ref_pref_baim, "On")
								prefer = true
							end
						end
						if has_value(selected_options,"Shooting") and not prefer then
							local wep = entity.get_player_weapon(player_index)
							if wep ~= nil then
								local last_shot = entity.get_prop(wep,"m_fLastShotTime")
								if (last_shot + 0.500) > globals.curtime() then
									ui.set( aa.ref_pref_baim, "On")
									prefer = true
								end
							end
						end
						if has_value(selected_options,"Big desync") and not prefer then
							local t = max_desync(player_index)
							if t > ui.get(aa.ref_desync) / 10 then
								ui.set( aa.ref_pref_baim, "On")
								prefer = true
							end
						end
						if has_value(selected_options,"Walking jitter desync") and not prefer then
							if ent_speed(player_index) > 2.0 and ent_speed(player_index) < 100 then
								if detect_jitter(player_index) then
									ui.set( aa.ref_pref_baim, "On")
									prefer = true
								end
							end
						end
						if has_value(selected_options,"Always on") and not prefer then
							ui.set( aa.ref_pref_baim, "On")
							prefer = true
						end
					end

					
				
				
					local selected_options = ui.get(aa.force_options)
				
					-- Force baim aa.options

					if ui.get( aa.ref_pref_baim) ~= "Force" then
						if has_value(selected_options,"Backwards/Forwards") then
							local pitch, yaw = vector_angles(pos_x, pos_y, pos_z, lx,ly,lz)
							local _,model_yaw = entity.get_prop(player_index, "m_angEyeAngles")
							local delta = math.abs(normalise_angle(yaw - model_yaw))
							if delta > 90 + ui.get(aa.range_slider) or delta < 90 - ui.get(aa.range_slider) then
									ui.set( aa.ref_pref_baim, "Force")
									forced = true
							end
						end
						if has_value(selected_options,"Sideways targets") and not forced then
							local pitch, yaw = vector_angles(pos_x, pos_y, pos_z, lx,ly,lz)
							local _,model_yaw = entity.get_prop(player_index, "m_angEyeAngles")
							local delta = math.abs(normalise_angle(yaw - model_yaw))
							if delta < 90 + ui.get(aa.range_slider) and delta > 90 - ui.get(aa.range_slider) then
								if ent_speed(player_index) > 10 then
									ui.set( aa.ref_pref_baim, "Force")
									forced = true
								end
							end
						end
						if has_value(selected_options,"Slow targets") and not forced then
							if ent_speed(player_index) > 1.0 and ent_speed(player_index) < 80 then
								ui.set( aa.ref_pref_baim, "Force")
								forced = true
							end
						end
						if has_value(selected_options,"x1 HP") and not forced then
							if is_x_shots(local_player,player_index,1) then
								ui.set( aa.ref_pref_baim, "Force")
								forced = true
							end
						end
						if has_value(selected_options,"<x HP") and not forced then
							if entity.get_prop(player_index,"m_iHealth") <= ui.get(aa.ref_hp_slider) then
								ui.set( aa.ref_pref_baim, "Force")
								forced = true
							end
						end
						if has_value(selected_options,"1 miss") and not forced then
							if missLogs[player_index] >= 1 then
								ui.set( aa.ref_pref_baim, "Force")
								forced = true
							end
						end
						if has_value(selected_options,"2 miss") and not forced then
							if missLogs[player_index] >= 2 then
								ui.set( aa.ref_pref_baim, "Force")
								forced = true
							end
						end
						if has_value(selected_options,"x2 HP")  and not forced then
							if is_x_shots(local_player,player_index,2) then
								ui.set( aa.ref_pref_baim, "Force")
								forced = true
							end
						end
						if has_value(selected_options,"Shooting") and not forced then
							local wep = entity.get_player_weapon(player_index)
							if wep ~= nil then
								local last_shot = entity.get_prop(wep,"m_fLastShotTime")
								if (last_shot + 0.500) > globals.curtime() then
									ui.set( aa.ref_pref_baim, "Force")
									forced = true
								end
							end
						end
						if has_value(selected_options,"Walking jitter desync") then
							if ent_speed(player_index) > 1.0 and ent_speed(player_index) < 100 then
								if detect_jitter(player_index) then
									ui.set( aa.ref_pref_baim, "Force")
									forced = true
								end
							end
						end
					end
				end
			
				
					player_preference[player_index] = ui.get( aa.ref_pref_baim)
					if not forced then
						local entindex = entity.get_local_player()
						if entindex == nil then
							return
						end
						
						local lx,ly,lz = entity.get_prop(entindex, "m_vecOrigin")
						if lx == nil then return end
						local players = entity.get_players(true)
						local pitch, yaw = client.camera_angles()
						local vx, vy, vz = angle_to_vec(pitch, yaw)
						
						-- start out with 180 degrees as the closest
						-- cos(deg2rad(180)) is -1
						local closest_fov_cos = -1

						for i=1, #players do
							entindex = players[i]

							local fov_cos = get_fov_cos(entindex, vx,vy,vz, lx,ly,lz)
							if fov_cos > closest_fov_cos then
								-- this player is closer to our crosshair
								closest_fov_cos = fov_cos
								closest_player = entindex
							end
						end
						
				
						
					end
			end
		end
	end
	
	if cached_plist ~= nil then -- restore plist so people can click
		ui.set( aa.ref_plist,cached_plist)
	end
	
end

local function clear_misses(index)
	missLogs[index] = 0
end

client.set_event_callback("aim_miss", function(c)
	local options = ui.get(aa.force_options)
	if c.reason ~= "spread" then
		local t = c.target
		if missLogs[t] == nil then
			missLogs[t] = 1
			if ui.get(aa.reset_misses) then
				if has_value(aa.options,"1 miss") then
					client.delay_call(5,clear_misses,t)
				end
			end
		else
			missLogs[t] = missLogs[t] + 1
			if ui.get(aa.reset_misses) then
				if has_value(aa.options,"2 miss") or has_value(aa.options,"1 miss") then
					client.delay_call(5,clear_misses,t)
				end
			end
		end
	end
end)

client.set_event_callback("player_hurt", function(c)
	local i = client.userid_to_entindex(c.userid)
	if c.health == 0 then
		missLogs[i] = 0
	end
end)

client.set_event_callback("round_end", function(c)
	for i=1, 64 do
		missLogs[i] = 0
		player_preference[i] = ""
		cached_plist = nil
		closest_player = 0
	end
end)

client.set_event_callback("cs_game_disconnected", function(c) 
	ui.set(ui.reference("PLAYERS", "Players", "Reset all"), true)
	
	for i=1, 64 do
		missLogs[i] = 0
		player_preference[i] = ""
		cached_plist = nil
		closest_player = 0
	end
	
end)

client.set_event_callback("game_newmap", function(c) 
	ui.set(ui.reference("PLAYERS", "Players", "Reset all"), true)
	
	for i=1, 64 do
		missLogs[i] = 0
		player_preference[i] = ""
		cached_plist = nil
		closest_player = 0
	end
	
end)

client.set_event_callback("player_team", function(c)
	client.update_player_list()
end)

client.set_event_callback("round_prestart", function(c)
	client.update_player_list()
end)
client.set_event_callback('run_command', run_command)
