local bit_band = bit.band
local antiaim_funcs = require 'gamesense/antiaim_funcs'
local entity_get_local_player, entity_is_alive, entity_get_prop, entity_get_player_weapon =
    entity.get_local_player,
    entity.is_alive,
    entity.get_prop,
    entity.get_player_weapon
    local ffi = require "ffi"
    local vector = require("vector")
    local ui_set = ui.set
    local globals_tickcount, globals_realtime = globals.tickcount, globals.realtime
-- Libraries

local buttons_e = {
    attack = bit.lshift(1, 0),
    attack_2 = bit.lshift(1, 11),
    use = bit.lshift(1, 5)

}
local entity_get_local_player, entity_is_enemy, entity_get_all, entity_set_prop, entity_is_alive, entity_is_dormant, entity_get_player_name, entity_get_game_rules, entity_get_origin, entity_hitbox_position, entity_get_players, entity_get_prop = entity.get_local_player, entity.is_enemy,  entity.get_all, entity.set_prop, entity.is_alive, entity.is_dormant, entity.get_player_name, entity.get_game_rules, entity.get_origin, entity.hitbox_position, entity.get_players, entity.get_prop
local math_cos, math_sin, math_rad, math_sqrt = math.cos, math.sin, math.rad, math.sqrt
local function math_clamp(v, min, max)
    if v < min then
        v = min
    elseif v > max then
        v = max
    end
    return v
end
local function contains(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end
local function contains2(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end
ui_reference = ui.reference
local ref = {
    ["rage"] = {
        ["dt"] = {ui_reference("RAGE", "Other", "Double tap")},
        ["dtmode"] = ui_reference("RAGE", "Other", "Double tap mode"),
        ["dtfl"] = ui_reference("RAGE", "Other", "Double tap fake lag limit"),
        ["duck_assist"] = ui_reference("RAGE", "Other", "Duck peek assist"),
        ["multp"] = {ui_reference("RAGE", "Aimbot", "Multi-point")},
        ["prefer_sp"] = ui_reference("RAGE", "Aimbot", "Prefer safe point")
    },
    ["aa"] = {
        ["pitch"] = ui_reference("AA", "Anti-aimbot angles", "Pitch"),
        ["yaw_base"] = ui_reference("AA", "Anti-aimbot angles", "Yaw base"),
        ["yaw"] = {ui_reference("AA", "Anti-aimbot angles", "Yaw")},
        ["jitter"] = {ui_reference("AA", "Anti-aimbot angles", "Yaw Jitter")},
        ["body"] = {ui_reference("AA", "Anti-aimbot angles", "Body yaw")},
        ["freestanding_body_yaw"] = ui_reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
        ["fyaw_limit"] = ui_reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
        ["edge_yaw"] = ui_reference("AA", "Anti-aimbot angles", "Edge yaw"),
        ["freestanding"] = {ui_reference("AA", "Anti-aimbot angles", "Freestanding")},
        ["limit_ref"] = ui_reference("AA", "Fake lag", "Limit"),
        ["onshot"] = {ui_reference("AA", "Other", "On shot anti-aim")},
        ["slowwalk"] = {ui_reference("AA", "Other", "Slow motion")},
        ["amount"] = ui_reference("AA", "Fake lag", "Amount"),
        ["variance"] = ui_reference("AA", "Fake lag", "Variance"),
        ["fake_peek"] = {ui_reference("AA", "Other", "Fake peek")}
    },
    ["ticks"] = ui_reference("MISC", "Settings", "sv_maxusrcmdprocessticks")
}
local angle_t = ffi.typeof("struct { float pitch; float yaw; float roll; }")
local vector3_t = ffi.typeof("struct { float x; float y; float z; }")

local usercmd_t =
    ffi.typeof(
    [[
    struct
    {
        uintptr_t vfptr;
        int command_number;
        int tick_count;
        $ viewangles;
        $ aimdirection;
        float forwardmove;
        float sidemove;
        float upmove;
        int buttons;
        uint8_t impulse;
        int weaponselect;
        int weaponsubtype;
        int random_seed;
        short mousedx;
        short mousedy;
        bool hasbeenpredicted;
        $ headangles;
        $ headoffset;
    }
    ]],
    angle_t,
    vector3_t,
    angle_t,
    vector3_t
)

local get_user_cmd_t = ffi.typeof("$* (__thiscall*)(uintptr_t ecx, int nSlot, int sequence_number)", usercmd_t)

local input_vtbl_t =
    ffi.typeof(
    [[
    struct
    {
        uintptr_t padding[8];
        $ GetUserCmd;
    }
    ]],
    get_user_cmd_t
)

local input_t = ffi.typeof([[
    struct
    {
        $* vfptr;
    }*
    ]], input_vtbl_t)

-- ugly casting LMAO
local g_pInput =
    ffi.cast(
    input_t,
    ffi.cast(
        "uintptr_t**",
        tonumber(
            ffi.cast(
                "uintptr_t",
                client.find_signature("client.dll", "\xB9\xCC\xCC\xCC\xCC\x8B\x40\x38\xFF\xD0\x84\xC0\x0F\x85") or
                    error("client.dll!:input not found.")
            )
        ) + 1
    )[0]
)



local lua_log = function(...) --inspired by sapphyrus' multicolorlog
    client.color_log(255, 59, 59, "[ mlc.yaw ]\0")
    local arg_index = 1
    while select(arg_index, ...) ~= nil do
        client.color_log(217, 217, 217, " ", select(arg_index, ...), "\0")
        arg_index = arg_index + 1
    end
    client.color_log(217, 217, 217, " ") -- this is needed to end the line
end

lua_log("欢迎使用_roll, Update Version: 2022/3/31")
lua_log("discord:https://discord.gg/GDy32vshVG")
lua_log("Set Velocity Triggers to 80 if you are using Auto/AWP, Load Roll Preset is suggested")

local references = {
    fake_yaw_limit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    aa_enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled"),
    body_freestanding = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw"),
    pitch = ui.reference("AA", "Anti-aimbot angles", "Pitch"),
    yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")},
    body_yaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
    yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
    jitter = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")},
    fake_limit = ui.reference("AA", "Anti-aimbot angles", "Fake yaw limit"),
    edge_yaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
    freestanding = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")},
    fake_lag = ui.reference("AA", "Fake lag", "Amount"),
    fake_lag_limit = ui.reference("AA", "Fake lag", "Limit"),
    fakeduck = {ui.reference("RAGE", "Other", "Duck peek assist")},
    legmovement = ui.reference("AA", "Other", "Leg movement"),
    slow_walk = {ui.reference("AA", "Other", "Slow motion")},
    roll = {ui.reference("AA", "Anti-aimbot angles", "Roll")},
    -- rage references
    doubletap = {ui.reference("RAGE", "Other", "Double Tap")},
    doubletap_mode = ui.reference("RAGE", "Other", "Double tap mode"),
    dt_hit_chance = ui.reference("RAGE", "Other", "Double tap hit chance"),
    osaa, osaa_hkey = ui.reference("AA", "Other", "On shot anti-aim"),
    mindmg = ui.reference("RAGE", "Aimbot", "Minimum damage"),
    fba_key = ui.reference("RAGE", "Other", "Force body aim"),
    fsp_key = ui.reference("RAGE", "Aimbot", "Force safe point"),
    ap = ui.reference("RAGE", "Other", "Delay shot"),
    sw,
    slowmotion_key = ui.reference("AA", "Other", "Slow motion"),
    quick_peek = {ui.reference("Rage", "Other", "Quick peek assist")},
    fake_lag_limit = ui.reference("aa", "Fake lag", "Limit"),

    -- misc references
    untrust = ui.reference("MISC", "Settings", "Anti-untrusted"),
    sv_maxusrcmdprocessticks = ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks"),
    -- end of menu references and menu creation
}
local onshot, onshotkey = ui.reference('aa', 'other', 'On shot anti-aim')

local function on_setup_command(cmd)
    g_pOldAngles = vector(cmd.pitch, cmd.yaw, cmd.roll)
end
local slider_roll = ui.new_slider("AA", "Anti-aimbot angles", "Roll Angle", -90, 90, 50, true, "°")
local Exploit_mode_combobox =
    ui.new_multiselect(
    "AA",
    "Anti-aimbot angles",
    "Enable Exploit",
    "Roll Angle",
    "Fake Angle",
    "Fake Yaw",
    "\aB6B665FFValve Server Bypass"
)
local static_mode_combobox =
    ui.new_multiselect(
    "AA",
    "Anti-aimbot angles",
    "Roll State On:",
    "In Air",
    "On Ladders",
    "Low Stamina",
    "On Key",
    "< Speed Velocity"
)
local teleport_key = ui.new_hotkey("AA", "Other", "Teleport key")
local indicators = ui.new_multiselect("AA", "Anti-aimbot angles", "Enable Indicators", "Status Netgraph", "Debug")
local key3 = ui.new_hotkey("AA", "Anti-aimbot angles", "Force Rolling Angle on Key (Speed Decrease)")
local checkbox_hitchecker = ui.new_checkbox("AA", "Anti-aimbot angles", "Disable Roll when impacted", true)
local velocity_slider = ui.new_slider("AA", "Anti-aimbot angles", "Roll Velocity Trigger", 0, 250, 120, true, " ")
local stamina_slider = ui.new_slider("AA", "Anti-aimbot angles", "Stamina Recovery", 0, 80, 70, true, " ")
local in_air_roll = ui.new_slider("AA","Anti-aimbot angles","Customized Roll in air",  -50, 50, 50, true, " ")
local function velocity()
    local me = entity_get_local_player()
    local velocity_x, velocity_y = entity_get_prop(me, "m_vecVelocity")
    return math.sqrt(velocity_x ^ 2 + velocity_y ^ 2)
end
ui.set_visible(key3, false)
ui.set_visible(velocity_slider, false)
ui.set_visible(stamina_slider, false)
ui.set_visible(checkbox_hitchecker, false)
ui.set_visible(in_air_roll, false)
ui.set_visible(references.roll[1], false)
ui.set_visible(checkbox_hitchecker, false)
local TIME = 0

-----------------Valve Sever Bypasser-----------------
local gamerules_ptr = client.find_signature("client.dll", "\x83\x3D\xCC\xCC\xCC\xCC\xCC\x74\x2A\xA1")
local gamerules = ffi.cast("intptr_t**", ffi.cast("intptr_t", gamerules_ptr) + 2)[0]
local is_valve_spoof = false
client.set_event_callback("setup_command", function()
    local is_valve_ds = ffi.cast('bool*', gamerules[0] + 124)
    if is_valve_ds ~= nil then
        if contains(ui.get(Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then
            is_valve_ds[0] = 0
            is_valve_spoof = true
        else 
            is_valve_spoof = false
        end
    end
end)

client.set_event_callback("shutdown", function()
    local is_valve_ds = ffi.cast('bool*', gamerules[0] + 124)
    if is_valve_spoof == true then 
        is_valve_ds[0] = 0
    end
end)
---------------The end of Sever Bypasser---------------

--------------Movement state--------------

--------------Stamina Checkers--------------
local function stamina()
    return (80 - entity_get_prop(entity_get_local_player(), "m_flStamina"))
end

local function stamina_bind()
    if contains(ui.get(static_mode_combobox), "Low Stamina") then
        ui.set_visible(stamina_slider, true)
        return ui.get(stamina_slider)
    else
        ui.set_visible(stamina_slider, false)
        return 0
    end
end

--------------Impact Checkers--------------
local function on_hit()
    return (entity.get_prop(entity.get_local_player(), "m_flVelocityModifier"))
end

local function hit_bind()
    local hit_health = on_hit()
    if contains(ui.get(static_mode_combobox), "< Speed Velocity") then
        ui.set_visible(velocity_slider, true)
        ui.set_visible(checkbox_hitchecker, true)
        if ui.get(checkbox_hitchecker) and hit_health <= 0.9 then
            return 0
        else if is_on_ladder == 1 then
            return  0
        else
            return ui.get(velocity_slider)
            end
        end
    end
    ui.set_visible(velocity_slider, false)
    ui.set_visible(checkbox_hitchecker, false)
    return 0
end

--------------Ladders Checker--------------
local function Ladder_status()
    local ladd_stat = 0
    if contains(ui.get(static_mode_combobox), "On Ladders") then
        if is_on_ladder == 1 then
            ladd_stat = 1
        else
            ladd_stat = 0
        end
    end
    return ladd_stat
end

client.set_event_callback(
    "setup_command",
    function(e)
        local local_player = entity.get_local_player()
        if entity.get_prop(local_player, "m_MoveType") == 9 then
            is_on_ladder = 1
        else
            is_on_ladder = 0
        end
    end
)

--------------In Air Checker--------------
local function inair()
    return (bit_band(entity_get_prop(entity_get_local_player(), "m_fFlags"), 1) == 0)
end

local function air_status()
    local air_stat = 0
    if contains(ui.get(static_mode_combobox), "In Air") then
        if inair() then
            air_stat = 1
        else
            air_stat = 0
        end
    end
    return air_stat
end

--------------Sliders Check--------------
local function roll_bind()
    local roll_set = ui.get(slider_roll)
    if contains(ui.get(static_mode_combobox), "In Air") then
        ui.set_visible(in_air_roll, true)
    else
        ui.set_visible(in_air_roll, false)
    end
    if air_status() == 1 then
        roll_set = ui.get(in_air_roll)
    else
        return ui.get(slider_roll)
    end
        return roll_set
end

local function hide_keys()
    local key100 = 1
    if contains(ui.get(static_mode_combobox), "On Key") then
        ui.set_visible(key3, true)
    else
        ui.set_visible(key3, false)
        return key100
    end
end

--------------------End of Player Movement state----------------------
local is_rolling 
--------------------Main Functions for Rolling--------------------
local function on_run_command(cmd)
    hide_keys()
    local speed = velocity()
    local recovery = stamina()
    if air_status() == 0 and not ui.get(key3) and speed >= hit_bind() and recovery >= stamina_bind() and Ladder_status() == 0 then
        is_rolling = false
        return
    end
    local local_player = entity_get_local_player()
    if not entity_is_alive(local_player) then
        return
    end
    is_rolling = true
    stamina_bind()
    hit_bind()
    local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)

    local my_weapon = entity_get_player_weapon(local_player)
    local wepaon_id = bit_band(0xffff, entity_get_prop(my_weapon, "m_iItemDefinitionIndex"))
    local is_grenade =
        ({
        [43] = true,
        [44] = true,
        [45] = true,
        [46] = true,
        [47] = true,
        [48] = true,
        [68] = true
    })[wepaon_id] or false

    if is_grenade then
        local throw_time = entity_get_prop(my_weapon, "m_fThrowTime")
        if bit_band(pUserCmd.buttons, buttons_e.attack) == 0 or bit_band(pUserCmd.buttons, buttons_e.attack_2) == 0 then
            if throw_time > 0 then
                return
            end
        end
    end

    -- +use to disable like any anti aim
    --if bit_band(pUserCmd.buttons, buttons_e.use) > 0 then
        --return
    --end

    --if bit_band(pUserCmd.buttons, buttons_e.attack) > 0 then
        --return
    --end

    --if wepaon_id == 64 and bit_band(pUserCmd.buttons, buttons_e.attack_2) > 0 then
        --return
    --end
    if contains(ui.get(Exploit_mode_combobox), "Roll Angle") then
        pUserCmd.viewangles.roll = roll_bind()
    else end



--    g_ForwardMove = pUserCmd.forwardmove
--    g_SideMove = pUserCmd.sidemove
--    g_pOldAngles = vector(pUserCmd.viewangles.pitch, pUserCmd.viewangles.yaw, pUserCmd.viewangles.roll)

    if contains(ui.get(indicators), "Debug") then
--        pUserCmd.forwardmove = math_clamp(new_forward, -450.0, 450.0)           not working properly
--        pUserCmd.sidemove = math_clamp(new_side, -450.0, 450.0)
    end

    -- your aa
end
--------------------Main Functions for fake angle--------------------
local invert_key = ui.new_hotkey("aa", "fake lag", "Fake Angle Invert")
local fakelag = ui.reference("aa", "fake lag", "limit") 
local ticks_user = ui.reference("misc", "settings", "sv_maxusrcmdprocessticks")
local speed_slider = ui.new_slider("AA", "Anti-aimbot angles", "Fake Angle Speed Trigger", 0, 250, 10, true, " ")
local fake_angle
local num = 90
client.set_event_callback(
    "setup_command",
    function(cmd)
        ui.set(fakelag, 15)
        ui.set(ticks_user, 18)
        local speed = velocity()
        fake_angle = false
        if contains(ui.get(Exploit_mode_combobox), "Fake Angle") then
            if inair() or stamina() < 79 or velocity() < ui.get(speed_slider) then return end
            if ui.get(references.doubletap[2]) then return end
                local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)
                local local_player = entity_get_local_player()
                local my_weapon = entity_get_player_weapon(local_player)
                local wepaon_id = bit_band(0xffff, entity_get_prop(my_weapon, "m_iItemDefinitionIndex"))
                local is_grenade =
                    ({
                    [43] = true,
                    [44] = true,
                    [45] = true,
                    [46] = true,
                    [47] = true,
                    [48] = true,
                    [68] = true
                })[wepaon_id] or false

                if is_grenade then
                    local throw_time = entity_get_prop(my_weapon, "m_fThrowTime")
                    if
                        bit_band(pUserCmd.buttons, buttons_e.attack) == 0 or
                            bit_band(pUserCmd.buttons, buttons_e.attack_2) == 0
                     then
                        if throw_time > 0 then
                            return
                        end
                    end
                end

                -- +use to disable like any anti aim
                if bit_band(pUserCmd.buttons, buttons_e.use) > 0 then
                    return
                end

                if bit_band(pUserCmd.buttons, buttons_e.attack) > 0 then
                    return
                end

                if wepaon_id == 64 and bit_band(pUserCmd.buttons, buttons_e.attack_2) > 0 then
                    return
                end

                if inair() then
                    return
                end
                cmd.allow_send_packet = false
                local nigger = ui.get(invert_key)
                local Left = client.key_state(0x41)
                local Right = client.key_state(0x44)
                if Left == true then
                    num = 90
                    else if Right == true then
                        num = 270
                    end
                    num = num 
                end
                ui.set(fakelag, 17)
                local angles = {client.camera_angles()}
                fake_angle = true
                if (cmd.chokedcommands % 2 == 0) then
                    cmd.allow_send_packet = false
                    cmd.yaw = angles[2] + num
                    cmd.pitch = 80, angles[1]
                else
                    cmd.allow_send_packet = true
                    cmd.yaw = angles[2] + 180
                    cmd.pitch = 80, angles[1] - 80
                end
        end
    end
)


client.set_event_callback("paint", function()
    if not contains(ui.get(Exploit_mode_combobox), "Fake Angle") then return end
    if num > 90 then
        renderer.indicator(255, 255, 255, 255, "RIGHT")
    else
        renderer.indicator(255, 255, 255, 255, "LEFT")
    end
end)

---------------------Polygens

local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber
local renderer_circle = renderer.circle
local ffi = require 'ffi'
local vector = require 'vector'
local images = require 'gamesense/images'
local anti_aim = require 'gamesense/antiaim_funcs'

local m_render_engine = (function()
    local rr, gr, br = 255, 255, 255
    if is_rolling == true then
        rr, gr, br = 253, 162, 180
        else if fake_angle == true then
            rr, gr, br = 64, 224, 208
        else
            rr, gr, br = 255, 255, 255
        end
    end
	local a = {}
	local b = function(c, d, e, f, g, h, i, j, k)
		renderer_rectangle(c + g, d, e - g * 2, g, h, i, j, k)
		renderer_rectangle(c, d + g, g, f - g * 2, h, i, j, k)
		renderer_rectangle(c + g, d + f - g, e - g * 2, g, h, i, j, k)
		renderer_rectangle(c + e - g, d + g, g, f - g * 2, h, i, j, k)
		renderer_rectangle(c + g, d + g, e - g * 2, f - g * 2, h, i, j, k)
		renderer_circle(c + g, d + g, h, i, j, k, g, 180, 0.25)
		renderer_circle(c + e - g, d + g, h, i, j, k, g, 90, 0.25)
		renderer_circle(c + g, d + f - g, h, i, j, k, g, 270, 0.25)
		renderer_circle(c + e - g, d + f - g, h, i, j, k, g, 0, 0.25)
	end;
	local l = function(c, d, e, f, g, h, i, j, k)
		renderer_rectangle(c, d + g, 1, f - g * 2 + 2, h, i, j, k)
		renderer_rectangle(c + e - 1, d + g, 1, f - g * 2 + 1, h, i, j, k)
		renderer_rectangle(c + g, d, e - g * 2, 1, h, i, j, k)
		renderer_rectangle(c + g, d + f, e - g * 2, 1, h, i, j, k)
		renderer_circle_outline(c + g, d + g, h, i, j, k, g, 180, 0.25, 2)
		renderer_circle_outline(c + e - g, d + g, h, i, j, k, g, 270, 0.25, 2)
		renderer_circle_outline(c + g, d + f - g + 1, h, i, j, k, g, 90, 0.25, 2)
		renderer_circle_outline(c + e - g, d + f - g + 1, h, i, j, k, g, 0, 0.25, 2)
	end;
	local m = 2;
	local n = 45;
	local o = 15;
	local p = function(c, d, e, f, g, h, i, j, k, q)
		renderer_rectangle(c + g, d, e - g * 2, 2, h, i, j, k)
		renderer_circle_outline(c + g, d + g, h, i, j, k, g, 180, 0.25, 2)
		renderer_circle_outline(c + e - g, d + g, h, i, j, k, g, 270, 0.25, 2)
		renderer_gradient(c, d + g, 2, f - g * 2, h, i, j, k, h, i, j, n, false)
		renderer_gradient(c + e - 2, d + g, 2, f - g * 2, h, i, j, k, h, i, j, n, false)
		renderer_circle_outline(c + g, d + f - g, h, i, j, n + 50, g, 90, 0.25, 2)
		renderer_circle_outline(c + e - g, d + f - g, h, i, j, n + 50, g, 0, 0.25, 2)
		renderer_rectangle(c + g, d + f - 2, e - g * 2, 2, h, i, j, n + 50)
		for r = 1, q do
			l(c - r, d - r, e + r * 2, f + r * 2, g, h, i, j, q - r)
		end
	end;
	local s, t, u, v = 17, 17, 17, 80;
	a.render_container = function(c, d, e, f, h, i, j, k, w)
		renderer.blur(c, d, e, f, 100, 100)
		b(c, d, e, f, m, s, t, u, v)
		p(c, d, e, f, m, h, i, j, k, o)
		if w then
			w(c + m, d + m, e - m * 2, f - m * 2)
		end
	end;
	a.render_glow_line = function(c, d, x, y, h, i, j, k, z, A, B, q)
		local C = vector(c, d, 0)
		local D = vector(x, y, 0)
		local E = ({
			C:to(D):angles()
		})[2]
		for r = 1, q do
			renderer_circle_outline(c, d, z, A, B, q - r, r, E + 90, 0.5, 1)
			renderer_circle_outline(x, y, z, A, B, q - r, r, E - 90, 0.5, 1)
			local F = vector(math_cos(math_rad(E + 90)), math_sin(math_rad(E + 90)), 0):scaled(r * 0.95)
			local G = vector(math_cos(math_rad(E - 90)), math_sin(math_rad(E - 90)), 0):scaled(r * 0.95)
			local H = F + C;
			local I = F + D;
			local J = G + C;
			local K = G + D;
			renderer_line(H.x, H.y, I.x, I.y, z, A, B, q - r)
			renderer_line(J.x, J.y, K.x, K.y, z, A, B, q - r)
		end;
		renderer_line(c, d, x, y, h, i, j, k)
	end;
	return a
end)()

local double_tap, double_tap_key = ui.reference('Rage','Other','Double tap')
local fakeducking = ui.reference('RAGE', 'Other', 'Duck peek assist')
local limit = ui.reference('aa', 'Fake lag', 'Limit')
local box, key = ui.reference( 'Rage', 'Other', 'Quick peek assist' )

-------------------Teleport function-------------------
local is_tp
function teleport()
    local getstate = ui.get(teleport_key) and not ui.get(fakeducking) 
    local is_tp = getstate
    ui.set(key, getstate and 'On hotkey' or 'On hotkey')
    ui.set(double_tap_key, getstate and 'Always on' or 'toggle')
    if fake_angle == true then
        ui.set(limit, getstate and 1 or 17)
        else
        ui.set(limit, getstate and 1 or 15)
    end
end

-------------Gradient Text

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

-------------------------Basic Anti Aim----------------------

local vars = {
    y_reversed = 1,
    by_reversed = 1,

    by_vars = 0,
    y_vars = 0,
    chocke = 0,
    chocking = 0
}
client.set_event_callback('setup_command', function(c)
    c.chokedcommands = vars.chocking
end)
local function antiaim_yaw_jitter(a,b)
    if vars.chocking ~= 0 then return end
    if not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then return end
    if globals.tickcount() - vars.y_vars > 1  then
        vars.y_reversed = vars.y_reversed == 1 and 0 or 1
        vars.y_vars = globals.tickcount()
    end
    return vars.y_reversed >= 1 and a or b
end
local fake_yaw = 0
local status

local function static()
    ui.set(references.yaw[2], 24)
    ui.set(references.yaw[1], "180")
    ui.set(references.body_yaw[2], 137)
    ui.set(references.yaw_base, "At targets")
    ui.set(references.body_yaw[1], "Static")
    ui.set(references.jitter[2], 0)
    ui.set(references.fake_limit, 58)
    TIME = globals_realtime() + 0.12
end
local function jitter()
if globals_realtime() >= TIME then
    --ui.set(references.yaw[2], antiaim_yaw_jitter(15,-25))
    ui.set(ref.aa.jitter[1], "Center")
    ui.set(ref.aa.fyaw_limit, 58)
    ui.set(ref.aa.pitch, "Minimal")
    ui.set(ref.aa.yaw[1], "180")
    ui.set(references.body_yaw[1], "Jitter")
    ui.set(ref.aa.jitter[2], 45)
    ui.set(references.body_yaw[2], 0)
    ui.set(ref.aa.freestanding_body_yaw, false)
    TIME = globals_realtime() + 0.09
end
end
local antiaim_state
local Jittering = false
local aa_setup = function(cmd)
if not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then return end
    if is_rolling == true or fake_angle == true then
        Jittering = false
        static()
        else if is_rolling == false then
            Jittering = true
            antiaim_state = status
            jitter ()
        else
            jitter ()
        end
    end
end

local function antiaim_yaw_jitter(a,b)

    if globals.tickcount() - vars.y_vars > 1  then
        vars.y_reversed = vars.y_reversed == 1 and 0 or 1
        vars.y_vars = globals.tickcount()
    end
    return vars.y_reversed >= 1 and a or b
end
client.set_event_callback('setup_command', function(cmd)
    -----------Moving overlap
    --send packets can be considered not using it
    if cmd.chokedcommands ~= 0 then return end
    if velocity() < 120 then return end
    if Jittering == false then return end
    if not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.77 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(40,-40))
    else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.77 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(40,-40))
    else status = "OVERLAPED"
        return end
    end
    end)

client.set_event_callback('setup_command', function(cmd)
    -----------Standing overlap
    --send packets can be considered not using it
    if cmd.chokedcommands ~= 0 then return end
    if velocity() > 120 then return end
    if Jittering == false then return end
    if not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.63 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(40,-40))
    else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.84 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(40,-40))
    else status = "OVERLAPED"
        return end
end
end)

--------------Animation
local ani = {
    alpha = 0,
    offset = 0,
    speed_offset = 0,
    alpha_off = 0,
    dt = 0,
    dt_offset = 0,
    dt_offset_exp = 0,
    hide = 0,
    hide_offset = 0,
    hide_offset_exp = 0,
    baim = 0,
    tp = 0,
    alpha_fakeangle = 0,
    charged = 0
}
local alpha = 0
local offset = 0
local speed_offset = 0
function lerp(start, vend, time)
return start + (vend - start) * time end

-------------Indicators

local ss = {client.screen_size()}
local center_x, center_y = ss[1] / 2, ss[2] / 2 
client.set_event_callback(
    "paint",
    function(e)
        speed = velocity()
        if velocity() > 30 and velocity() < 250  then
            ani.alpha = lerp(ani.alpha,255,globals.frametime() * 6)
            ani.offset = lerp(ani.offset,7,globals.frametime() * 6)
            ani.speed_offset = lerp(ani.speed_offset, speed, globals.frametime() * 6 )
            else if velocity() < 30 then
                ani.alpha = lerp(ani.alpha,0,globals.frametime() * 6)
                ani.offset = lerp(ani.offset,0,globals.frametime() * 6)
                ani.speed_offset = lerp(ani.speed_offset, 0, globals.frametime() * 6 )
                else if ani.speed_offset > 250 then
                    ani.speed_offset = 250
                else 
                    ani.offset = 7
                    ani.alpha = 255
                end
            end
        end

        if inair() then
            speed_text = "AIR"
            else if velocity() <= 250 then
                speed_text = math.floor(velocity())
            end
        end
        
        if fake_angle == true then
            ani.alpha_fakeangle = lerp(ani.alpha,255,globals.frametime() * 6)
        else
            ani.alpha_fakeangle = lerp(ani.alpha,0,globals.frametime() * 6)
        end
        local tp_check = ui.get(teleport_key) and 100 or 6
        if ui.get(references.doubletap[2]) then
            ani.dt = math.floor(lerp(ani.dt,255,globals.frametime() * 6))
            ani.dt_offset = math.floor(lerp(ani.dt_offset,250,globals.frametime() * tp_check))
            ani.dt_offset_exp = math.floor(lerp(ani.dt_offset_exp,250,globals.frametime() * 6))
        else
            ani.dt = math.floor(lerp(ani.dt,0,globals.frametime() * 8))
            ani.dt_offset = math.floor(lerp(ani.dt_offset, 0,globals.frametime() * 1))
            ani.dt_offset_exp = math.floor(lerp(ani.dt_offset_exp,0,globals.frametime() * 6))
        end

        if ani.dt_offset > 230 then ani.dt_offset = 230 end
        if ani.dt_offset_exp > 230 then ani.dt_offset_exp = 230 end

        if ui.get(onshotkey) then
            ani.hide = math.floor(lerp(ani.hide,255,globals.frametime() * 6))
            ani.hide_offset = math.floor(lerp(ani.hide_offset,255,globals.frametime() * 6))
            ani.hide_offset_exp = math.floor(lerp(ani.hide_offset_exp,268,globals.frametime() * 6))
        else
            ani.hide = math.floor(lerp(ani.hide,0,globals.frametime() * 6))
            ani.hide_offset = math.floor(lerp(ani.hide_offset,0,globals.frametime() * 3.5))
            ani.hide_offset_exp = math.floor(lerp(ani.hide_offset_exp,0,globals.frametime() * 3.5))
        end
        if ani.hide_offset > 230 then ani.dt_offset = 230 end
        if ani.hide_offset_exp > 230 then ani.hide_offset_exp = 230 end

        if ui.get(references.fba_key) then
            ani.tp = math.floor(lerp(ani.tp,255,globals.frametime() * 6))
            ani.baim = math.floor(lerp(ani.tp,255,globals.frametime() * 6))
        else
            ani.tp = math.floor(lerp(ani.tp,0,globals.frametime() * 6))
            ani.baim = math.floor(lerp(ani.tp,255,globals.frametime() * 3.5))
        end
        if ani.baim > 230 then ani.baim = 230 end
        if anti_aim.get_double_tap() then
            ani.charged = math.floor(lerp(ani.charged,255,globals.frametime() * 6))
        else
            ani.charged = math.floor(lerp(ani.charged,0,globals.frametime() * 6))
        end

        if alpha < 1 then alpha = 0 end
        if alpha > 255 then alpha = 255 end
        teleport()
        local local_player = entity.get_local_player()
        if contains(ui.get(indicators), "Status Netgraph") then
            local pulse = math.sin(math.abs((math.pi * -1) + (globals.curtime() * (1 / 0.35)) % (math.pi * 2))) * 255
            local r, g, b = 30, 255, 109
            local recovery = stamina()
            if velocity() > hit_bind() then
                if ui.get(key3) then
                    r, g, b = 250, 140, 53
                else
                    r, g, b = 64, 224, 208
                end
            end

            if velocity() <= hit_bind() then
                if ui.get(key3) then
                    r, g, b = 250, 140, 53
                else
                    r, g, b = 253, 162, 180
                end
            end

            local r2, g2, b2 = 30, 255, 109

            if recovery <= stamina_bind() then
                if ui.get(key3) then
                    r2, g2, b2 = 250, 140, 53
                else
                    r2, g2, b2 = 255, 119, 119
                end
            end

            if recovery >= stamina_bind() then
                if ui.get(key3) then
                    r2, g2, b2 = 250, 140, 53
                else
                    r2, g2, b2 = 30, 255, 109
                end
            end

            local r4 = 124 * 2 - 124 * on_hit()
            local g4 = 255 * on_hit()
            local b4 = 13

            local rr, gr, br = 255, 255, 255
            if is_rolling == true then
                rr, gr, br = 253, 162, 180
                else if fake_angle == true then
                    rr, gr, br = 64, 224, 208
                    else if Jittering == true then
                        rr, gr, br = 184, 187, 255
                        else if Jittering == false and fake_angle == false and is_rolling == false then
                            rr, gr, br = 255, 255, 255
                        end
                    end
                end
            end

        
            if ui.get(key3) then
                renderer.text(center_x, center_y + 57 + offset, 253, 162, 180, pulse, "-", nil, "FORCE ROLL ( KEY )")
            end
            local header = gradient_text(255, 255, 255, 255, r4, g4, b4, 255, "_MLC.YAW")
            renderer.text(center_x, center_y + 35, 255, 255, 255, 255, "-", nil, header)
            --renderer.text(center_x + 20, center_y + 35, r4, g4, b4, 255, "-", nil, ".YAW")
            --renderer.text(center_x, center_y + 28, r, g, b, 255, "-", nil, "SPEED")
            --    renderer.text(center_x + 35, center_y + 28, r, g, b, 255, "-", nil, math.floor(velocity()))
            --renderer.text(center_x, center_y + 43, r2, g2, b2, 255, "-", nil, "STAMINA")
            --renderer.text(center_x, center_y + 43, 255, 255, 255, 199, "-", nil, "EXPLOIT:")
            m_render_engine.render_container(center_x + 2, center_y + 46, ani.speed_offset / 6, 5, rr, gr, br, ani.alpha)
            renderer.text(center_x + ani.speed_offset / 6 + 2, center_y + 43, rr, gr, br, ani.alpha, "-", nil, speed_text)
            --renderer.text(center_x + animations.speed_offset / 6 + 2, 253, 162, 180, pulse, "-", nil, "FORCE ROLL ( DISABLE )")
			--renderer_rectangle(center_x + 2, center_y + 46, velocity() / 8, 5, r, g, b, velocity())
            --        if stamina() >= 45 and velocity() <= ui.get(velocity_slider)  then
            --           renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL")
            --       end
            --        if inair() and stamina() >= 45  then
            --            renderer.text(center_x, center_y + 50, 253, 162, 180, pulse, "-", nil, "FORCE ROLL")
            --        end
            local state = gradient_text(253, 162, 180, 255, 64, 224, 208, 255, "FAKE ANGLE +")
            if fake_angle == true and is_rolling == true then
                renderer.text(center_x, center_y + 43 + ani.offset, 253, 162, 180, 255, "-", nil, state)
                else if fake_angle == true then
                    renderer.text(center_x, center_y + 43 + ani.offset, 64, 224, 208, 255, "-", nil, "FAKE ANGLE")
                    else if  is_rolling == true then
                        renderer.text(center_x, center_y + 43 + ani.offset, 253, 162, 180, 255, "-", nil, "FORCE ROLL")
                        else if Jittering == true then
                            renderer.text(center_x, center_y + 43 + ani.offset, 184, 187, 230, 255, "-", nil, antiaim_state)
                            else if Jittering == false and fake_angle == false and is_rolling == false then
                                renderer.text(center_x, center_y + 43 + ani.offset, 255, 255, 255, 255, "-", nil, "WAITING...")
                            end
                        end
                    end
                end
            end
            if fake_angle == true then
                --renderer.text(center_x, center_y + 50 + offset, 64, 224, 208, 255, "-", nil, "FAKE ANGLE")
            else
                --renderer.text(center_x, center_y + 50 + offset, 255, 255, 255, 100, "-", nil, "FAKE ANGLE")
            end
            if contains(ui.get(Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then
                renderer.text(center_x, center_y + 43 + ani.offset, 255, 255, 0, pulse, "-", nil, "BYPASS")
            else
                --renderer.text(center_x + 32, center_y + 64, 255, 255, 255, ui.get(ref['fs'][2]) and 255 or 100, "-",nil, "FS")
                --renderer.text(center_x, center_y + 64, 253, 162, 180, 255, "-", nil, "FORCE ROLL")
            end
            renderer.text(center_x + 30 - ani.dt_offset / 7.67, center_y + 50 + ani.offset, 255 - ani.charged, 255, 255 - ani.charged, ani.dt, "-",nil, "DT")
            renderer.text(center_x + ani.dt_offset_exp / 21 + 32 - ani.hide_offset / 7.67, center_y + 50 + ani.offset, 255, 255, 255, ani.hide, "-",nil, "HIDE")
            renderer.text(center_x + 31 - ani.baim / 7.67 + ani.dt_offset_exp / 21 + ani.hide_offset_exp / 13, center_y + 50 + ani.offset, 255, 255, 255, ani.tp, "-",nil, "BAIM")
            if not ui.get(checkbox_hitchecker) and on_hit() < 0.9 and air_status() == 1 and not ui.get(key3) and
                is_on_ladder
             then
                renderer.text(center_x, center_y + 53 + ani.offset, 253, 162, 180, pulse, "-", nil, "FORCE ROLL ( DISABLE )")
            end
        if contains(ui.get(indicators), "Debug") then
         --   renderer.text(center_x, center_y + 50, 253, 162, 180, 255, "+", nil, stamina_bind())
         --   renderer.text(center_x, center_y + 70, 253, 162, 180, 255, "+", nil, air_status())
         --   renderer.text(center_x, center_y + 90, 253, 162, 180, 255, "+", nil, hit_bind())
        --    renderer.text(center_x, center_y + 110, 253, 162, 180, 255, "+", nil, is_on_ladder)
            renderer.text(center_x, center_y + 130, 253, 162, 180, 255, "+", nil, "Is Rolling:")
            renderer.text(center_x + 100, center_y + 130, 253, 162, 180, 255, "+", nil, is_rolling)
        end
    end
end
)

client.set_event_callback("run_command", on_run_command)
client.set_event_callback("setup_command", on_setup_command)
























--------------------------------MANUAL ANTI AIM
--#region new controls
local enabled = ui.new_checkbox("AA", "Other", "Enable manual anti-aim")
local indicator_color = ui.new_color_picker("AA", "Other", "enable_manual_anti_aim", 130, 156, 212, 255)
local left_dir = ui.new_hotkey("AA", "Other", "Left direction")
local right_dir = ui.new_hotkey("AA", "Other", "Right direction")
local back_dir = ui.new_hotkey("AA", "Other", "Backwards direction")
local indicator_dist = ui.new_slider("AA", "Other", "Distance between arrows", 1, 100, 15, true, "px")
local manual_inactive_color = ui.new_color_picker("AA", "Other", "manual_inactive_color", 130, 156, 212, 255)
local manual_state = ui.new_slider("AA", "Other", "Manual direction", 0, 3, 0)
--#endregion /new controls
--#region references
local yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base")
local yaw = { ui.reference("AA", "Anti-aimbot angles", "Yaw") }
local bodyyaw = { ui.reference("AA", "Anti-aimbot angles", "Body yaw") }
--#endregion references
--#region helpers

local multi_exec = function(func, list)
    if func == nil then
        return
    end
    
    for ref, val in pairs(list) do
        func(ref, val)
    end
end

local compare = function(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return true
        end
    end
    
    return false
end
--#endregion /helpers

local bind_system = {
    left = false,
    right = false,
    back = false,
}

function bind_system:update()
    ui.set(left_dir, "On hotkey")
    ui.set(right_dir, "On hotkey")
    ui.set(back_dir, "On hotkey")

    local m_state = ui.get(manual_state)

    local left_state, right_state, backward_state = 
        ui.get(left_dir), 
        ui.get(right_dir),
        ui.get(back_dir)

    if  left_state == self.left and 
        right_state == self.right and
        backward_state == self.back then
        return
    end

    self.left, self.right, self.back = 
        left_state, 
        right_state, 
        backward_state

    if (left_state and m_state == 1) or (right_state and m_state == 2) or (backward_state and m_state == 3) then
        ui.set(manual_state, 0)
        return
    end

    if left_state and m_state ~= 1 then
        ui.set(manual_state, 1)
    end

    if right_state and m_state ~= 2 then
        ui.set(manual_state, 2)
    end

    if backward_state and m_state ~= 3 then
        ui.set(manual_state, 3)
    end
end

local menu_callback = function(e, menu_call)
    local state = not ui.get(enabled) -- or (e == nil and menu_call == nil)
    multi_exec(ui.set_visible, {
        [indicator_color] = not state,
        [manual_inactive_color] = not state,
        [indicator_dist] = not state ,
        [left_dir] = not state,
        [right_dir] = not state,
        [back_dir] = not state,
        [manual_state] = false,
    })
end

ui.set_callback(enabled, menu_callback)
client.set_event_callback("setup_command", function(e)
    if not ui.get(enabled) then
        return
    end

    local direction = ui.get(manual_state)

    local manual_yaw = {
        [0] = 0,
        [1] = -90, [2] = 90,
        [3] = 0,
    }

    if direction == 1 or direction == 2 then
        ui.set(yaw_base, "Local view")
    else
        ui.set(yaw_base, "At targets")
    end
    if direction == 1 then
        ui.set(bodyyaw[2], 180)
        ui.set(slider_roll, -50)
    else
        ui.set(bodyyaw[2], 137)
        ui.set(slider_roll, 50)
    end

    if direction == 2 then
        ui.set(bodyyaw[2], -180)
    else
        ui.set(bodyyaw[2], 137)
    end

    ui.set(yaw[2], manual_yaw[direction])
end)

client.set_event_callback("paint", function()
    aa_setup()
    menu_callback(true, true)
    bind_system:update()

    local me = entity.get_local_player()
    
    if not entity.is_alive(me) or not ui.get(enabled) then
        return
    end

    if ui.get(enabled) then
        local w, h = client.screen_size()
        local r, g, b, a = ui.get(indicator_color)
        local r1, g1, b1, a1 = ui.get(manual_inactive_color)
        local m_state = ui.get(manual_state)
    
        local realtime = globals.realtime() % 3
        local distance = (w/2) / 210 * ui.get(indicator_dist)
        local alpha = math.floor(math.sin(realtime * 4) * (a/2-1) + a/2) or a
        -- ⯇ ⯈ ⯅ ⯆

        renderer.text(w/2 - distance, h / 2 - 1, r1, g1, b1, a1, "+c", 0, "❮")
        renderer.text(w/2 + distance, h / 2 - 1, r1, g1, b1, a1, "+c", 0, "❯")
        renderer.text(w/2, h / 2 + distance, r1, g1, b1, a1, "+c", 0, "")
        
        if m_state == 1 then renderer.text(w/2 - distance, h / 2 - 1, r, g, b, a, "+c", 0, "❮") end
        if m_state == 2 then renderer.text(w/2 + distance, h / 2 - 1, r, g, b, a, "+c", 0, "❯") end
        if m_state == 3 or m_state == 0 then renderer.text(w/2, h / 2 + distance, r, g, b, a, "+c", 0, "") end
    end
end)
