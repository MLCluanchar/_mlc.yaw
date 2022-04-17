local bit_band = bit.band
local anti_aim = require 'gamesense/antiaim_funcs'

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
local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber
local entity_get_local_player, entity_is_enemy, entity_get_all, entity_set_prop, entity_is_alive, entity_is_dormant, entity_get_player_name, entity_get_game_rules, entity_get_origin, entity_hitbox_position, entity_get_players, entity_get_prop = entity.get_local_player, entity.is_enemy,  entity.get_all, entity.set_prop, entity.is_alive, entity.is_dormant, entity.get_player_name, entity.get_game_rules, entity.get_origin, entity.hitbox_position, entity.get_players, entity.get_prop
local math_cos, math_sin, math_rad, math_sqrt = math.cos, math.sin, math.rad, math.sqrt
local ui_new_multiselect = ui.new_multiselect
local function contains(tbl, val)
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
local misc_combobox =
    ui.new_multiselect(
    "AA",
    "Anti-aimbot angles",
    "Misc",
    "Debug Tools",
    "Roll with Fake yaw(air)",
    "Old Animation",
    "Legit Anti-aim on use",
    "Fast Zeus"
)
local b = {
    teleport_key = ui_new_hotkey("AA", "Other", "Teleport key"),
    indicators = ui_new_multiselect("AA", "Anti-aimbot angles", "Enable Indicators", "Status Netgraph", "Debug"),
    checkbox_hitchecker = ui_new_checkbox("AA", "Anti-aimbot angles", "Disable Roll when impacted", true),
    velocity_slider = ui_new_slider("AA", "Anti-aimbot angles", "Roll Velocity Trigger", 0, 250, 120, true, " "),
    stamina_slider = ui_new_slider("AA", "Anti-aimbot angles", "Stamina Recovery", 0, 80, 70, true, " "),
    in_air_roll = ui_new_slider("AA","Anti-aimbot angles","Customized Roll in air",  -50, 50, 50, true, " ")
}

local key3 = ui.new_hotkey("AA", "Anti-aimbot angles", "Force Rolling Angle on Key (Speed Decrease)")

local function velocity()
    local me = entity_get_local_player()
    local velocity_x, velocity_y = entity_get_prop(me, "m_vecVelocity")
    return math.sqrt(velocity_x ^ 2 + velocity_y ^ 2)
end

ui.set_visible(b.velocity_slider, false)
ui.set_visible(b.stamina_slider, false)
ui.set_visible(b.checkbox_hitchecker, false)
ui.set_visible(b.in_air_roll, false)
ui.set_visible(references.roll[1], false)
ui.set_visible(b.checkbox_hitchecker, false)
local TIME = 0

-----------------Valve Sever Bypasser-----------------
local gamerules_ptr = client.find_signature("client.dll", "\x83\x3D\xCC\xCC\xCC\xCC\xCC\x74\x2A\xA1")
local gamerules = ffi.cast("intptr_t**", ffi.cast("intptr_t", gamerules_ptr) + 2)[0]
local is_valve_spoof = false
local ticks_user = ui.reference("misc", "settings", "sv_maxusrcmdprocessticks")
client.set_event_callback("setup_command", function()
    local is_valve_ds = ffi.cast('bool*', gamerules[0] + 124)
    if is_valve_ds ~= nil then
        if contains(ui.get(Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then
            is_valve_ds[0] = 0
            is_valve_spoof = true
            ui.set(ticks_user, 7)
        else 
            is_valve_spoof = false
            ui.set(ticks_user, 18)
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
        ui.set_visible(b.stamina_slider, true)
        return ui.get(b.stamina_slider)
    else
        ui.set_visible(b.stamina_slider, false)
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
        ui.set_visible(b.velocity_slider, true)
        ui.set_visible(b.checkbox_hitchecker, true)
        if ui.get(b.checkbox_hitchecker) and hit_health <= 0.9 then
            return 0
        else if is_on_ladder == 1 then
            return  0
        else
            return ui.get(b.velocity_slider)
            end
        end
    end
    ui.set_visible(b.velocity_slider, false)
    ui.set_visible(b.checkbox_hitchecker, false)
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
        ui.set_visible(b.in_air_roll, true)
    else
        ui.set_visible(b.in_air_roll, false)
    end
    if air_status() == 1 then
        roll_set = ui.get(b.in_air_roll)
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
--------------------Main Functions for Rolling--------------------
local is_rolling = false
client.set_event_callback("run_command", function(cmd)
        hide_keys()
        stamina_bind()
        hit_bind()
        local speed = velocity()
        local recovery = stamina()
        if contains(ui.get(Exploit_mode_combobox), "Roll Angle") then
        
                -- your aa
                local local_player = entity_get_local_player()
                if not entity_is_alive(local_player) then
                    return
                end
                local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)

                local my_weapon = entity.get_player_weapon(local_player)
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
                --if bit_band(pUserCmd.buttons, buttons_e.use) > 0 then
                --return
                --end

                --if bit_band(pUserCmd.buttons, buttons_e.attack) > 0 then
                --return
                --end

                --if wepaon_id == 64 and bit_band(pUserCmd.buttons, buttons_e.attack_2) > 0 then
                --return
                --end
                local real_slide = (velocity() - 110)
                if real_slide < 0 then real_slide = 0 end
                local revsered = 100 - real_slide
                local divide = revsered / 2
                if divide < 10 then divide = 10 end
                if velocity() < 120 then
                    ui.set(slider_roll, anti_aim.get_desync(1) > 0 and -1 * (50) or 50)
                end
                if on_hit() <= 0.8 then is_rolling = false return end
                if velocity() > 130 and velocity() < 250 and not inair()  then
                     ui.set(slider_roll, anti_aim.get_desync(1) > 0 and -1 * (divide) or (divide))
                end
                if inair() then
                    ui.set(slider_roll, anti_aim.get_desync(1) > 0 and 50 or -1 * (50))
                end

                if air_status() == 0 and not ui.get(key3) and speed >= hit_bind() and recovery >= stamina_bind() and Ladder_status() == 0 then
                    is_rolling = false
                else
                    is_rolling = true
                end
                pUserCmd.viewangles.roll = roll_bind()
                --    g_ForwardMove = pUserCmd.forwardmove
                --    g_SideMove = pUserCmd.sidemove
                --    g_pOldAngles = vector(pUserCmd.viewangles.pitch, pUserCmd.viewangles.yaw, pUserCmd.viewangles.roll)

                if contains(ui.get(b.indicators), "Debug") then
                --        pUserCmd.forwardmove = math_clamp(new_forward, -450.0, 450.0)           not working properly
                --        pUserCmd.sidemove = math_clamp(new_side, -450.0, 450.0)
                end
            else
                is_rolling = false
        end

end)

--------------------Main Functions for fake angle--------------------
local speed_slider = ui.new_slider("AA", "Anti-aimbot angles", "Fake Angle Speed Trigger", 0, 250, 10, true, " ")
local fake_angle = false
local num = 90
local reverse_num = 180
client.set_event_callback(
    "setup_command",
    function(cmd)
        if contains(ui.get(Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then return end
        ui.set(references.fake_lag_limit, 15)
        local speed = velocity()
        fake_angle = false
        if contains(ui.get(Exploit_mode_combobox), "Fake Angle") then
            if inair() or stamina() < 79 or velocity() < ui.get(speed_slider) then return end
            if ui.get(references.doubletap[2]) then return end
                local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)
                local local_player = entity_get_local_player()
                local my_weapon = entity.get_player_weapon(local_player)
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
                local Left = client.key_state(0x41)
                local Right = client.key_state(0x44)
                if Left == true then
                    num = 70
                    reverse_num = 180
                    else if Right == true then
                        num = 240
                        reverse_num = 180
                    end
                    num = num 
                    reverse_num = reverse_num
                end
                ui.set(references.fake_lag_limit, 17)
                local angles = {client.camera_angles()}
                fake_angle = true
                if (cmd.chokedcommands % 2 == 0) then
                    cmd.allow_send_packet = false
                    cmd.yaw = angles[2] + num
                    cmd.pitch = 80, angles[1]
                else
                    cmd.yaw = angles[2] + reverse_num
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

local renderer_circle = renderer.circle
local vector = require 'vector'

local m_render_engine = (function()
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

-------------------Teleport function-------------------
local double_tap, double_tap_key = ui.reference('Rage','Other','Double tap')
local fakeducking = ui.reference('RAGE', 'Other', 'Duck peek assist')
local limit = ui.reference('aa', 'Fake lag', 'Limit')
local box, key = ui.reference( 'Rage', 'Other', 'Quick peek assist' )


local is_tp
function teleport()
    if contains(ui.get(Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then return end
    local getstate = ui.get(b.teleport_key) and not ui.get(fakeducking) 
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
-------------------------Render LBY Circle---------------------
local function draw_circle_3d(x, y, z, radius, degrees, start_at, r, g, b, a)
	local accuracy = 10/10
    local old = { x, y }
	for rot=start_at, degrees+start_at, accuracy do
		local rot_t = math.rad(rot)
		local line_ = vector(radius * math.cos(rot_t) + x, radius * math.sin(rot_t) + y, z)
        local current = { x, y }
        current.x, current.y = renderer.world_to_screen(line_.x, line_.y, line_.z)
		if current.x ~=nil and old.x ~= nil then
			renderer.line(current.x, current.y, old.x, old.y, r, g, b, a)
            --m_render_engine.render_glow_line(current.x, current.y, old.x, old.y, r, g, b, a, r, g, b, 10)
		end
		old.x, old.y = current.x, current.y
	end
end
-------------------------Basic Anti Aim----------------------

local function left_peek()
    ui.set(references.body_yaw[1], "Static")
    ui.set(references.yaw[2],  -15)
    ui.set(references.body_yaw[2], -80)

    ui.set(b.in_air_roll, 50)
    ui.set(references.jitter[2], 0)
end
local function right_peek()
    ui.set(references.body_yaw[1], "Static")
    ui.set(references.yaw[2],  15)
    ui.set(references.body_yaw[2], 80)
    ui.set(b.in_air_roll, -50)
    ui.set(references.jitter[2], 0)
end
local _V3_MT   = {};
_V3_MT.__index = _V3_MT;

local function Vector3( x, y, z )
    -- check args
    if( type( x ) ~= "number" ) then
        x = 0.0;
    end

    if( type( y ) ~= "number" ) then
        y = 0.0;
    end

    if( type( z ) ~= "number" ) then
        z = 0.0;
    end

    x = x or 0.0;
    y = y or 0.0;
    z = z or 0.0;

    return setmetatable(
        {
            x = x,
            y = y,
            z = z
        },
        _V3_MT
    );
end


function _V3_MT.__sub( a, b ) -- subtract another vector or number
    local a_type = type( a );
    local b_type = type( b );

    if( a_type == "table" and b_type == "table" ) then
        return Vector3(
            a.x - b.x,
            a.y - b.y,
            a.z - b.z
        );
    elseif( a_type == "table" and b_type == "number" ) then
        return Vector3(
            a.x - b,
            a.y - b,
            a.z - b
        );
    elseif( a_type == "number" and b_type == "table" ) then
        return Vector3(
            a - b.x,
            a - b.y,
            a - b.z
        );
    end
end

function _V3_MT:length_sqr() -- squared 3D length
    return ( self.x * self.x ) + ( self.y * self.y ) + ( self.z * self.z );
end

function _V3_MT:length() -- 3D length
    return math_sqrt( self:length_sqr() );
end

function _V3_MT:dot( other ) -- dot product
    return ( self.x * other.x ) + ( self.y * other.y ) + ( self.z * other.z );
end

function _V3_MT:cross( other ) -- cross product
    return Vector3(
        ( self.y * other.z ) - ( self.z * other.y ),
        ( self.z * other.x ) - ( self.x * other.z ),
        ( self.x * other.y ) - ( self.y * other.x )
    );
end

function _V3_MT:dist_to( other ) -- 3D length to another vector
    return ( other - self ):length();
end

function _V3_MT:normalize() -- normalizes this vector and returns the length
    local l = self:length();
    if( l <= 0.0 ) then
        return 0.0;
    end

    self.x = self.x / l;
    self.y = self.y / l;
    self.z = self.z / l;

    return l;
end


function _V3_MT:normalized() -- returns a normalized unit vector
    local l = self:length();
    if( l <= 0.0 ) then
        return Vector3();
    end

    return Vector3(
        self.x / l,
        self.y / l,
        self.z / l
    );
end


local function angle_forward( angle ) -- angle -> direction vector (forward)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );

    return Vector3(
        cos_pitch * cos_yaw,
        cos_pitch * sin_yaw,
        -sin_pitch
    );
end

local function get_FOV( view_angles, start_pos, end_pos ) -- get fov to a vector (needs client view angles, start position (or client eye position for example) and the end position)
    local type_str;
    local fwd;
    local delta;
    local fov;

    fwd   = angle_forward( view_angles );
    delta = ( end_pos - start_pos ):normalized();
    fov   = math.acos( fwd:dot( delta ) / delta:length() );

    return math_max( 0.0, math.deg( fov ) );
end

local predict_ticks         = 17
-- end of the anti-aim peeking function for smart jitter

-- this is a function to help with on peeking and getting peeked functions
local function distance_3d( x1, y1, z1, x2, y2, z2 )

        return math.sqrt( ( x1-x2 )*( x1-x2 )+( y1-y2 )*( y1-y2 ) )
end

-- function for extrapolating player
local function extrapolate( player , ticks , x, y, z )
    local xv, yv, zv =  entity.get_prop( player, "m_vecVelocity" )
    local new_x = x+globals.tickinterval( )*xv*ticks
    local new_y = y+globals.tickinterval( )*yv*ticks
    local new_z = z+globals.tickinterval( )*zv*ticks
    return new_x, new_y, new_z

end
-- end of functions to help with on peeking and getting peeked functions

-- this is the start of a function for detecting whether the local player is peeking an enemy
local function is_enemy_peeking( player )
    local speed = velocity()
    if speed < 5 then
        return false
    end
    local ex, ey, ez = entity.get_origin( player ) 
    local lx, ly, lz = entity.get_origin( entity.get_local_player ( ) )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    for ticks = 1, predict_ticks do
        local tex,tey,tez = extrapolate( player, ticks, ex, ey, ez )
        local distance = math.abs( distance_3d( tex, tey, tez, lx, ly, lz ) )

        if distance < smallest_distance then
            smallest_distance = distance
        end
        if smallest_distance < start_distance then
            return true
        end
    end
    --client.log(smallest_distance .. "      " .. start_distance)
    return smallest_distance < start_distance
end
-- this is the end of a function for detecting whether the local player is peeking an enemy

-- this is the start of a function for detecting whether the enemy is peeking the local player
local function is_local_peeking_enemy( player )
    local speed = velocity()
    if speed < 5 then
        return false
    end
    local ex,ey,ez = entity.get_origin( player )
    local lx,ly,lz = entity.get_origin( entity.get_local_player() )
    local start_distance = math.abs( distance_3d( ex, ey, ez, lx, ly, lz ) )
    local smallest_distance = 999999
    if ticks ~= nil then
        TICKS_INFO = ticks
    else
    end
    for ticks = 1, predict_ticks do

        local tex,tey,tez = extrapolate( entity.get_local_player(), ticks, lx, ly, lz )
        local distance = distance_3d( ex, ey, ez, tex, tey, tez )

        if distance < smallest_distance then
            smallest_distance = math.abs(distance)
        end
    if smallest_distance < start_distance then
            return true
        end
    end
    return smallest_distance < start_distance
end

local detections = "WAITING"
function detection()
if not contains(ui.get(Exploit_mode_combobox), "Roll Angle") then return end
    local closest_fov           = 100000

    local player_list           = entity.get_players( true )

    local eye_pos               = Vector3( x, y, z )
    x,y,z                       = client.camera_angles( )
    local cam_angles            = Vector3( x, y, z )
    
    for i = 1 , #player_list do
        player                  = player_list[ i ]
        if not entity.is_dormant( player ) and entity.is_alive( player ) then
            if is_enemy_peeking( player ) or is_local_peeking_enemy( player ) then
                last_time_peeked        = globals.curtime( )
                local enemy_head_pos    = Vector3( entity.hitbox_position( player, 0 ) )
                local current_fov       = get_FOV( cam_angles,eye_pos, enemy_head_pos )
                if current_fov < closest_fov then
                    closest_fov         = current_fov
                    needed_player       = player
                end
            end
        end
    end
    detections = "DORMANCY"
    if needed_player ~= -1 then
        if not entity.is_dormant( player ) and entity.is_alive( player ) and is_rolling == true then
            if ( ( is_enemy_peeking( player ) or is_local_peeking_enemy( player ) ) ) == true then
                left_peek()
                detections = "LEFT PEEKS"
            else
                right_peek()
                detections = "RIGHT PEEKS"
            end
        end
    end
    if detections == "DORMANCY" then
    end
end

-- this is the end of a function for detecting whether the enemy is peeking the local player

local vars = {
    y_reversed = 1,
    by_reversed = 1,

    by_vars = 0,
    y_vars = 0,
    chocke = 0,
    chocking = 0
}

local function antiaim_yaw_jitter(a,b)
    if globals.tickcount() - vars.y_vars > 1  then
        vars.y_reversed = vars.y_reversed == 1 and 0 or 1
        vars.y_vars = globals.tickcount()
    end
    return vars.y_reversed >= 1 and a or b
end

local fake_yaw = 0
local status = "WAITING"
local function static()
    ui.set(references.yaw[1], "180")
    ui.set(references.yaw_base, "At targets")
    ui.set(references.fake_limit, 60)
    TIME = globals_realtime() + 0.12
end
local function jitter()
    local pulse_m = math.sin(math.abs((math.pi * -1) + (globals.curtime() * (1 / 0.35)) % (math.pi * 2))) * 60
    if pulse_m > 59 then pulse_m = 0 end
    ui.set(ref.aa.fyaw_limit, math.random(30,60))
if globals_realtime() >= TIME then
    --ui.set(references.yaw[2], antiaim_yaw_jitter(15,-25))
    ui.set(ref.aa.jitter[1], "Center")
    ui.set(ref.aa.pitch, "Minimal")
    ui.set(ref.aa.yaw[1], "180")
    ui.set(references.body_yaw[1], "Jitter")
    ui.set(references.body_yaw[2], 0)
    ui.set(ref.aa.freestanding_body_yaw, false)
    if velocity() > 200 then
        ui.set(ref.aa.jitter[2], math.random(60,80))
    else
        ui.set(ref.aa.jitter[2], 29)
    end
    TIME = globals_realtime() + 0.09
end
end
local antiaim_state
local Jittering = false
client.set_event_callback('setup_command', function(cmd)
    Jittering = false
    if contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then
        if is_rolling == true or fake_angle == true then
            static()
            Jittering = false
            else if is_rolling == false or fake_angle == false and not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then
                Jittering = true
                antiaim_state = status
                jitter ()
            end
        end
    end
end)

local function antiaim_yaw_jitter_abs()
    return ui.get(references.yaw[2]) > 0
end


client.set_event_callback('setup_command', function(cmd)
    -----------Moving overlap
    --send packets can be considered not using it
    local local_player = entity_get_local_player( )
    if ( not entity_is_alive( local_player ) ) then
        return     
    end
    ---------------------------------------------
    if cmd.chokedcommands ~= 0 then return end
    if velocity() < 120 then return end
    if Jittering == false then return end
    if not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.77 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(15,-25))
        if contains(ui.get(misc_combobox), "Roll with Fake yaw(air)") then
            if inair() then
            cmd.roll = antiaim_yaw_jitter_abs() and -50 or 50
            status = "FAKE YAW +"
            end
        end
    else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.9 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(15,-25))
        if contains(ui.get(misc_combobox), "Roll with Fake yaw(air)") then
            if inair() then
            cmd.roll = antiaim_yaw_jitter_abs() and -50 or 50
            status = "FAKE YAW +"
            end
        end
    else status = "OVERLAPED"
        return end
    end
    end)

client.set_event_callback('setup_command', function(cmd)
    -----------Standing overlap
    --send packets can be considered not using it
    local local_player = entity_get_local_player( )
    if ( not entity_is_alive( local_player ) ) then
        return     
    end
    ---------------------------------------------
    if velocity() > 120 then return end
    if Jittering == false then return end
    if not contains(ui.get(Exploit_mode_combobox), "Fake Yaw") then return end
    if ui.get(references.jitter[2]) < 60 and anti_aim.get_overlap(rotation) > 0.63 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(15,-25))
        if contains(ui.get(misc_combobox), "Roll with Fake yaw(air)") then
            if inair() then
            cmd.roll = antiaim_yaw_jitter_abs() and -50 or 50
            status = "FAKE YAW +"
            end
        end
    else if ui.get(references.jitter[2]) > 60 and anti_aim.get_overlap(rotation) > 0.84 then
        status = "FAKE YAW"
        ui.set(references.yaw[2], antiaim_yaw_jitter(15,-25))
        if contains(ui.get(misc_combobox), "Roll with Fake yaw(air)") then
            if inair() then
            cmd.roll = antiaim_yaw_jitter_abs() and -50 or 50
            status = "FAKE YAW +"
            end
        end
    else status = "OVERLAPED"
        return end
end
end)

local overlap = function(cmd)
    local local_player = entity_get_local_player( )
    if ( not entity_is_alive( local_player ) ) then
        return     
    end

    if not is_rolling then return end 
    if cmd.chokedcommands ~= 0 then return end
    detection()
    if contains(ui.get(misc_combobox), "Jitter roll in air") and anti_aim.get_overlap(rotation) < 0.75 and inair() then
    end
end

client.set_event_callback('setup_command', overlap)
-------------------------Logging-----------------------------

local function KaysFunction(A,B,C)
    local d = (A-B) / A:dist(B)
    local v = C - B
    local t = v:dot(d) 
    local P = B + d:scaled(t)
    
    return P:dist(C)
end

local function on_bullet_impact(e)
	local local_player = entity.get_local_player()
	local shooter = client.userid_to_entindex(e.userid)

	if not entity.is_enemy(shooter) or not entity.is_alive(local_player) then
		return
	end

    if not contains(ui.get(misc_combobox), "Debug Tools") then return end

	local shot_start_pos 	= vector(entity.get_prop(shooter, "m_vecOrigin"))
	shot_start_pos.z 		= shot_start_pos.z + entity.get_prop(shooter, "m_vecViewOffset[2]")
	local eye_pos			= vector(client.eye_position())
	local shot_end_pos 		= vector(e.x, e.y, e.z)
	local closest			= KaysFunction(shot_start_pos, shot_end_pos, eye_pos)

    local Overlap = math.floor(anti_aim.get_overlap(rotation) * 100)
    local Desync = math.floor(anti_aim.get_desync(1))

    local boolean_roll 
    local boolean_fake
    
    if is_rolling then
        boolean_roll = "true"
    else
        boolean_roll = "false"
    end

    if Jittering then
        boolean_fake = "true"
    else
        boolean_fake = "false"
    end

	if closest < 32 then
        lua_log("Detected Impact, Roll:"..boolean_roll..", Fake yaw:"..boolean_fake.. " Overlap:"..Overlap.."°, Desync: "..Desync.."")
	end
end

client.set_event_callback('bullet_impact', on_bullet_impact)
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
    baim_offset = 0,
    baim_offset_exp = 0,
    safe = 0,
    safe_offset = 0,
    baim = 0,
    alpha_fakeangle = 0,
    charged = 0,
    
    -----------
    manual_lef = 0,
    manual_right = 0,
    -----------
    LBY = 0
}
function lerp(start, vend, time)
return start + (vend - start) * time end

-------------Indicators

local ss = {client.screen_size()}
local center_x, center_y = ss[1] / 2, ss[2] / 2 
client.set_event_callback(
    "paint",
    function(e)
        if contains(ui.get(misc_combobox), "Debug Tools") then
            local overlap_out = math.floor(100 *anti_aim.get_overlap(rotation))

            local r5 = 255
            local g5 = 255
            local b5 = 255
            if overlap_out > 90 then
                r5 = 188
                g5 = 150
                b5 = 150
                else if overlap_out < 30 then
                r5 = 0
                g5 = 180
                b5 = 0
                end
            end

            renderer.text(center_x + 50, center_y + 35, r5, g5, b5, 255, " ", nil, "("..overlap_out.."%)")
            renderer.text(center_x + 50, center_y + 45, r5, g5, b5, 255, " ", nil, "Roll:")
            renderer.text(center_x + 73, center_y + 45, r5, g5, b5, 255, " ", nil, is_rolling)
            renderer.text(center_x + 50, center_y + 55, r5, g5, b5, 255, " ", nil, "Fake Angle:")
            renderer.text(center_x + 107, center_y + 55, r5, g5, b5, 255, " ", nil, fake_angle)
            renderer.text(center_x + 50, center_y + 65, r5, g5, b5, 255, " ", nil, "Fake Yaw:")
            renderer.text(center_x + 99, center_y + 65, r5, g5, b5, 255, " ", nil, Jittering)
        end

            local local_player = entity_get_local_player( )
    if ( not entity_is_alive( local_player ) ) then
        return     
    end
        local _, head_rot = entity.get_prop(entity.get_local_player(), "m_angAbsRotation");local _, fake_rot = entity.get_prop(entity.get_local_player(), "m_angEyeAngles");local lby_rot = entity.get_prop(entity.get_local_player(), "m_flLowerBodyYawTarget");local _, cam_rot = client.camera_angles()
        local c3d = { degrees=50, start_at=head_rot, start_at2=fake_rot, start_at3=lby_rot }
        local lp_pos = vector(entity.get_origin(entity.get_local_player()))
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
        local tp_check = ui.get(b.teleport_key) and 100 or 6
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
            ani.baim = math.floor(lerp(ani.baim,255,globals.frametime() * 6))
            ani.baim_offset = math.floor(lerp(ani.baim,255,globals.frametime() * 6))
            ani.baim_offset_exp = math.floor(lerp(ani.baim,255,globals.frametime() * 6))
        else
            ani.baim = math.floor(lerp(ani.baim,0,globals.frametime() * 6))
            ani.baim_offset = math.floor(lerp(ani.baim,255,globals.frametime() * 3.5))
            ani.baim_offset_exp = math.floor(lerp(ani.baim,0,globals.frametime() * 6))
        end
    
        if ani.baim_offset > 230 then ani.baim_offset = 230 end
        if ani.baim_offset_exp > 230 then ani.baim_offset_exp  = 230 end

        if ui.get(references.fsp_key) then
            ani.safe = math.floor(lerp(ani.safe,255,globals.frametime() * 6))
            ani.safe_offset = math.floor(lerp(ani.safe_offset,255,globals.frametime() * 6))
        else
            ani.safe = math.floor(lerp(ani.safe,0,globals.frametime() * 6))
            ani.safe_offset = math.floor(lerp(ani.safe_offset,0,globals.frametime() * 6))
        end

        if ani.safe_offset > 230 then ani.safe_offset = 230 end

        if anti_aim.get_double_tap() then
            ani.charged = math.floor(lerp(ani.charged,255,globals.frametime() * 6))
        else
            ani.charged = math.floor(lerp(ani.charged,0,globals.frametime() * 6))
        end
        teleport()
        local local_player = entity.get_local_player()
        if contains(ui.get(b.indicators), "Status Netgraph") then
            local pulse = math.sin(math.abs((math.pi * -1) + (globals.curtime() * (1 / 0.35)) % (math.pi * 2))) * 255
            local r, g, b = 30, 255, 109
            local recovery = stamina()


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

    
            local header = gradient_text(255, 255, 255, 255, r4, g4, b4, 255, "_MLC.YAW")
            renderer.text(center_x, center_y + 35, 255, 255, 255, 255, "-", nil, header)
            m_render_engine.render_container(center_x + 2, center_y + 46, ani.speed_offset / 6, 5, rr, gr, br, ani.alpha)
            renderer.text(center_x + ani.speed_offset / 6 + 2, center_y + 43, rr, gr, br, ani.alpha, "-", nil, speed_text)

            local state = gradient_text(253, 162, 180, 255, 64, 224, 208, 255, "FAKE ANGLE +")
            local fake_yaw = gradient_text(184, 187, 230, 255, 184, 187, 230, 255, status)
            if status == "FAKE YAW +" then
                fake_yaw = gradient_text(184, 187, 230, 255, 253, 162, 180, 255, status)
            else
                fake_yaw = gradient_text(184, 187, 230, 255, 184, 187, 230, 255, status)
            end
            if fake_angle == true and is_rolling == true then
                renderer.text(center_x, center_y + 43 + ani.offset, 253, 162, 180, 255, "-", nil, state)
                else if fake_angle == true  then
                    renderer.text(center_x, center_y + 43 + ani.offset, 64, 224, 208, 255, "-", nil, "FAKE ANGLE")
                    else if  is_rolling == true then
                        renderer.text(center_x, center_y + 43 + ani.offset, 253, 162, 180, 255, "-", nil, detections)
                        else if Jittering == true then
                            renderer.text(center_x, center_y + 43 + ani.offset, 184, 187, 230, 255, "-", nil, fake_yaw)
                            else if Jittering == false and fake_angle == false and is_rolling == false then
                                renderer.text(center_x, center_y + 43 + ani.offset, 255, 255, 255, 255, "-", nil, "WAITING...")
                            end
                        end
                    end
                end
            end
            draw_circle_3d(lp_pos.x, lp_pos.y, lp_pos.z, 43+2*1, c3d.degrees, c3d.start_at2, rr, gr, br, 255)
            if contains(ui.get(Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then
                renderer.text(center_x, center_y + 43 + ani.offset, 255, 255, 0, pulse, "-", nil, "BYPASS")
            else

            end
            local first_exp = ani.dt_offset_exp / 21
            local second_exp = first_exp + ani.hide_offset_exp / 13
            local third_exp = second_exp + ani.baim_offset_exp / 12
            renderer.text(center_x + 30 - ani.dt_offset / 7.67, center_y + 50 + ani.offset, 255 - ani.charged, 255, 255 - ani.charged, ani.dt, "-",nil, "DT")
            renderer.text(center_x + 31 - ani.hide_offset / 7.67 + first_exp, center_y + 50 + ani.offset, 255, 255, 255, ani.hide, "-",nil, "HIDE")
            renderer.text(center_x + 31 - ani.baim_offset / 7.67 + second_exp, center_y + 50 + ani.offset, 255, 255, 255, ani.baim, "-",nil, "BAIM")
            renderer.text(center_x + 32 - ani.safe_offset / 7.67 + third_exp, center_y + 50 + ani.offset, 255, 255, 255, ani.safe, "-",nil, "SP")
    end
end
)

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
    end

    if direction == 2 then
        ui.set(bodyyaw[2], -180)
        ui.set(slider_roll, 50)
    else
    end
    if manual_yaw[direction] == 0 then return end
    ui.set(yaw[2], manual_yaw[direction])
end)

client.set_event_callback("paint", function()
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
        
        if m_state == 1 then
            ani.manual_lef = lerp(ani.manual_lef,40,globals.frametime() * 6)
            renderer.text(w/2 - distance - ani.manual_lef, h / 2 - 1,  r, g, b, ani.manual_lef * 4 + 90, "+c", 0, "❮")
            else
            ani.manual_lef = lerp(ani.manual_lef,0,globals.frametime() * 6)
            renderer.text(w/2 - distance - ani.manual_lef, h / 2 - 1, r, g, b, ani.manual_lef * 4 + 90, "+c", 0, "❮")
        end        
        if m_state == 2 then 
            ani.manual_right = lerp(ani.manual_right,40,globals.frametime() * 6)
            renderer.text(w/2 + distance + ani.manual_right, h / 2 - 1, r, g, b, ani.manual_right * 4 + 90, "+c", 0, "❯") 
        else
            ani.manual_right = lerp(ani.manual_right,0,globals.frametime() * 6)
            renderer.text(w/2 + distance + ani.manual_right, h / 2 - 1, r, g, b, ani.manual_right * 4 + 90, "+c", 0, "❯") 
        end
        if m_state == 3 or m_state == 0 then renderer.text(w/2, h / 2 + distance, r, g, b, a, "+c", 0, "") end
    end
end)

-----------------Animation

client.set_event_callback("pre_render", function()
    if contains(ui.get(misc_combobox), "Old Animation") then 
        entity.set_prop(entity.get_local_player(), "m_flPoseParameter", 1, 6) 
    end
 end)