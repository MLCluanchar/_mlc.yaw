---mlc yaw recode 
local anti_aim = require 'gamesense/antiaim_funcs'
local ffi = require "ffi"
local vector = require("vector")
---setupcommand reference
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
---Libarys
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
local lua_log = function(...) --inspired by sapphyrus' multicolorlog
    client.color_log(255, 59, 59, "[ mlc.yaw ]\0")
    local arg_index = 1
    while select(arg_index, ...) ~= nil do
        client.color_log(217, 217, 217, " ", select(arg_index, ...), "\0")
        arg_index = arg_index + 1
    end
    client.color_log(217, 217, 217, " ") -- this is needed to end the line
end

local function velocity()
    local me = entity_get_local_player()
    local velocity_x, velocity_y = entity_get_prop(me, "m_vecVelocity")
    return math.sqrt(velocity_x ^ 2 + velocity_y ^ 2)
end

local function inair()
    return (bit_band(entity_get_prop(entity_get_local_player(), "m_fFlags"), 1) == 0)
end

local function stamina()
    return (80 - entity_get_prop(entity_get_local_player(), "m_flStamina"))
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

local multi_exec = function(func, list)
    if func == nil then
        return
    end
    
    for ref, val in pairs(list) do
        func(ref, val)
    end
end

local _V3_MT   = {};
_V3_MT.__index = _V3_MT;

function _V3_MT:dot( other ) -- dot product
    return ( self.x * other.x ) + ( self.y * other.y ) + ( self.z * other.z );
end

function angle_forward( angle ) -- angle -> direction vector (forward)
    local sin_pitch = math_sin( math_rad( angle.x ) );
    local cos_pitch = math_cos( math_rad( angle.x ) );
    local sin_yaw   = math_sin( math_rad( angle.y ) );
    local cos_yaw   = math_cos( math_rad( angle.y ) );

    return vector(
        cos_pitch * cos_yaw,
        cos_pitch * sin_yaw,
        -sin_pitch
    );
end

function get_FOV( view_angles, start_pos, end_pos ) -- get fov to a vector (needs client view angles, start position (or client eye position for example) and the end position)
    local type_str;
    local fwd;
    local delta;
    local fov;

    fwd   = angle_forward( view_angles );
    delta = ( end_pos - start_pos ):normalized();
    fov   = math.acos( fwd:dot( delta ) / delta:length() );

    return math_max( 0.0, math.deg( fov ) );
end

local function extrapolate( player , ticks , x, y, z )
    local xv, yv, zv =  entity.get_prop( player, "m_vecVelocity" )
    local new_x = x+globals_tickinterval( )*xv*ticks
    local new_y = y+globals_tickinterval( )*yv*ticks
    local new_z = z+globals_tickinterval( )*zv*ticks
    return new_x, new_y, new_z

end

local predict_ticks         = 10


local indicator_left = ">"
local indicator_right = "<"
local d = ""

local font_grabber = {

    Run = function()

        local asd_http_ouo = require "gamesense/http"

        str_to_sub = function(input, sep)
            local t = {}
            for str in  string.gmatch(input, "([^"..sep.."]+)") do
                t[#t + 1] = string.gsub(str, "\n", "")
            end
            return t
        end
        
        local http_get = function()

            asd_http_ouo.get("https://raw.githubusercontent.com/MLCluanchar/Special-font/main/font.txt", function(success, response)
                if not success or response.status ~= 200 then
                    log("Conection failed")
                end
            
                local tbl = str_to_sub(response.body, '"')
            
                indicator_right = tbl[2]
                indicator_left = tbl[4]
                d = tbl[6]
        
            end)

        end
        http_get()
    end

}

font_grabber.Run()
-- end of functions to help with on peeking and getting peeked functions

-- this is the start of a function for detecting whether the local player is peeking an enemy
local function is_enemy_peeking( player )
    local speed = velocity()
    if speed < 5 then
        return false
    end
    local ex, ey, ez = entity.get_origin(player) 
    local origin = vector(entity.get_origin(player))
    local local_p = vector(entity.get_origin(entity.get_local_player()))
    local start_distance = origin:dist(local_p)
    local smallest_distance = 999999
    for ticks = 1, predict_ticks do
        local extrapolated = vector(extrapolate(player, ticks, ex, ey, ez))
        local distance = math.abs(extrapolated:dist(local_p)) 

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
    local ex,ey,ez = entity_get_origin( player )
    local lx,ly,lz = entity_get_origin( entity_get_local_player() )

    local origin = vector(entity_get_origin(player))
    local local_p = vector(entity_get_origin(entity_get_local_player()))
    
    local start_distance = origin:dist(local_p)
    local smallest_distance = 999999
    if ticks ~= nil then
        TICKS_INFO = ticks
    else
    end
    for ticks = 1, predict_ticks do

        local extrapolated = vector(extrapolate( entity_get_local_player(), ticks, lx, ly, lz ))
        local distance = math.abs(extrapolated:dist(local_p)) 
        if distance < smallest_distance then
            smallest_distance = math.abs(distance)
        end
    if smallest_distance < start_distance then
            return true
        end
    end
    return smallest_distance < start_distance
end

---Basic Libarys
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
    third = ui.reference("Visuals", "Effects", "Force Third Person (alive)")
    -- end of menu references and menu creati
}
local onshot, onshotkey = ui.reference('aa', 'other', 'On shot anti-aim')
local gamerules_ptr = client.find_signature("client.dll", "\x83\x3D\xCC\xCC\xCC\xCC\xCC\x74\x2A\xA1")
local dsreferences = {
    gamerules = ffi.cast("intptr_t**", ffi.cast("intptr_t", gamerules_ptr) + 2)[0],
    is_valve_spoof = false,
    ticks_user = ui.reference("misc", "settings", "sv_maxusrcmdprocessticks"),
}
--Local variables
local m_render_engine = (function()
    local renderer_circle = renderer.circle
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


local solus_render = (function()
    local solus_m = {}
    local RoundedRect = function(x, y, width, height, radius, r, g, b, a)
        renderer.rectangle(x + radius, y, width - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x, y + radius, radius, height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + height - radius, width - radius * 2, radius, r, g, b, a)
        renderer.rectangle(x + width - radius, y + radius, radius, height - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius, y + radius, width - radius * 2, height - radius * 2, r, g, b, a)
        renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
        renderer.circle(x + width - radius, y + radius, r, g, b, a, radius, 90, 0.25)
        renderer.circle(x + radius, y + height - radius, r, g, b, a, radius, 270, 0.25)
        renderer.circle(x + width - radius, y + height - radius, r, g, b, a, radius, 0, 0.25)
    end
    local rounding = 4
    local rad = rounding + 2
    local n = 45
    local o = 20
    local OutlineGlow = function(x, y, w, h, radius, r, g, b, a)
        renderer.rectangle(x + 2, y + radius + rad, 1, h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + w - 3, y + radius + rad, 1, h - rad * 2 - radius * 2, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + 2, w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.rectangle(x + radius + rad, y + h - 3, w - rad * 2 - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius + rad, y + radius + rad, r, g, b, a, radius + rounding, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + radius + rad, r, g, b, a, radius + rounding, 270, 0.25, 1)
        renderer.circle_outline(x + radius + rad, y + h - radius - rad, r, g, b, a, radius + rounding, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius - rad, y + h - radius - rad, r, g, b, a, radius + rounding, 0, 0.25, 1)
    end
    local FadedRoundedRect = function(x, y, w, h, radius, r, g, b, a, glow)
        local n = a / 255 * n
        renderer.rectangle(x + radius, y, w - radius * 2, 1, r, g, b, a)
        renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, 270, 0.25, 1)
        renderer.gradient(x, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b, n, false)
        renderer.gradient(x + w - 1, y + radius, 1, h - radius * 2, r, g, b, a, r, g, b, n, false)
        renderer.circle_outline(x + radius, y + h - radius, r, g, b, n, radius, 90, 0.25, 1)
        renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, n, radius, 0, 0.25, 1)
        renderer.rectangle(x + radius, y + h - 1, w - radius * 2, 1, r, g, b, n)
        -----------can add here a restriction
            for radius = 4, glow do
                local radius = radius / 2
                OutlineGlow(x - radius, y - radius, w + radius * 2, h + radius * 2, radius, r, g, b, glow - radius * 2)
            end
    end
    solus_m.linear_interpolation = function(start, _end, time)
        return (_end - start) * time + start
    end
    solus_m.clamp = function(value, minimum, maximum)
        if minimum > maximum then
            return math.min(math.max(value, maximum), minimum)
        else
            return math.min(math.max(value, minimum), maximum)
        end
    end
    solus_m.lerp = function(start, _end, time)
        time = time or 0.005
        time = solus_m.clamp(globals_frametime.frametime() * time * 175.0, 0.01, 1.0)
        local a = solus_m.linear_interpolation(start, _end, time)
        if _end == 0.0 and a < 0.01 and a > -0.01 then
            a = 0.0
        elseif _end == 1.0 and a < 1.01 and a > 0.99 then
            a = 1.0
        end
        return a
    end
    solus_m.container = function(x, y, w, h, r, g, b, a, alpha, fn)
        if alpha * 255 > 0 then
            renderer.blur(x, y, w, h)
        end
        RoundedRect(x, y, w, h, rounding, 17, 17, 17, a)
        FadedRoundedRect(x, y, w, h, rounding, r, g, b, alpha * 255, alpha * o)
        if not fn then
            return
        end
        fn(x + rounding, y + rounding, w - rounding * 2, h - rounding * 2.0)
    end



    return solus_m
end)()
---Polygens
lua_log("Welcome to mlcyaw recode, update log 2022/7/14")
lua_log("discord:https://discord.gg/GDy32vshVG")
---Baisc logs
local TAB, Antiaim =  { "AA", "Anti-aimbot angles", "Other", "Fake lag"}, {}
local Jitter_Status, detections = "WAITING", "WAITING"
local AA_S = {"High Speed (E)", "High Speed (F)", "Low Speed (E)", "Low Speed (F)", "In Air (H)", "In Air (L)",}
local is_rolling, fake_angle, fakeyaw, Jittering, Legit_AA = false, false, false, false, false
---Basic variables
local vars = {

    yaw_left = 0, yaw_right = 0, 
    jitter_left = 0, jitter_right = 0,
    bodyyaw = 0,
    fake_limit_left = 0, fake_limit_right = 0,
    jitter_set = 0, preset_state = 'wait',

    static_yaw = 0, static_bodyyaw = 0,
    static_fake_limit = 0, static_jitter = 0,
}

local function export_config()
    local settings = {}
    local clipboard = require("gamesense/clipboard")
    local base64 = require("gamesense/base64")
    for key, value in pairs(AA_S) do
        settings[tostring(value)] = {}
        for k, v in pairs(Antiaim[key]) do
            settings[value][k] = ui_get(v)
        end
    end

    clipboard.set(json.stringify(settings), "base64")

end

local function import_config()
    local clipboard = require("gamesense/clipboard")
    local base64 = require("gamesense/base64")
    local settings = json.parse(clipboard.get())
    for key, value in pairs(AA_S) do
        for k, v in pairs(Antiaim[key]) do
            local current = settings[value][k]
            if (current ~= nil) then
                ui_set(v, current)
            end
        end
    end

end
---Export/Import Configs

local mlc = {

    label = ui_new_label(TAB[1], TAB[2], ">> mlc.yaw"),

    ---Main Exploits Parts
    Exploit_mode_combobox = ui_new_multiselect(TAB[1], TAB[2], "Enable Exploit",
    "Roll Angle", "Fake Angle", "Fake Yaw", "\aB6B665FFValve Server Bypass"),

    --Indicator Parts
    indicators = ui_new_multiselect(TAB[1], TAB[2], 
    "Enable Indicators", "Status Netgraph", "Manual Indicator", "Debug"),

    custom_ind = { 

        enable = ui_new_checkbox(TAB[1], TAB[2], "Customized Indicator Panel", false),

        panel_box = ui_new_multiselect(TAB[1], TAB[2], "\nCustomized Indicator Panel",
        "Enable name Tag", "Enable Slider Bar", "Enable State indicator", "Enable Keybinds"),

    },

    tag = {


        enabled = ui_new_checkbox(TAB[1], TAB[2], "Enable Costum tag"),
    
        label = ui_new_label(TAB[1], TAB[2], "Custom lua tag"),
    
        name = ui_new_textbox(TAB[1], TAB[2], "   "),
    
    },

    --Misc Parts
    misc_combobox = ui_new_multiselect(TAB[1], TAB[2], "Misc",
    "Debug Tools", "Old Animation", 
    "Legit Anti-aim on use","Legit Anti-aim on Backstab",
    "Logs", "Logs Console"),
    
    ---Roll Exploits Part
    roll = {

        label = ui_new_label(TAB[1], TAB[2], ">> Roll Angle"),
        ---Main Multiselect
        mode = ui_new_multiselect(TAB[1], TAB[2], "Roll State On:",
        "In Air", "On Ladders", "Low Stamina", "On Key", "< Speed Velocity"),

        ---Main Slider
        slider_adjust = ui_new_slider(TAB[1], TAB[2], "Roll", 0, 90, 50, true, ""),
        slider_roll = ui_new_slider(TAB[1], TAB[2], "Roll Angle", -90, 90, 50, true, "°"),

        ---On Hit
        checkbox_hitchecker = ui_new_checkbox(TAB[1], TAB[2], "Disable Roll when impacted", true),

        ---Velocity
        velocity_slider = ui_new_slider(TAB[1], TAB[2], "Roll Velocity Trigger", 0, 250, 120, true, " "),

        ---Stamina
        stamina_slider = ui_new_slider(TAB[1], TAB[2], "Stamina Recovery", 0, 80, 70, true, " "),

        ---Air
        in_air_roll = ui_new_slider(TAB[1], TAB[2],"Customized Roll in air",  -50, 50, 50, true, " "),

        ---On hotkey
        key = ui_new_hotkey(TAB[1], TAB[2], "On Key"),

    },


    ---Fake Angle Exploits Part
    fakeangle = {

        label = ui_new_label(TAB[1], TAB[2], ">> Fake Angle"),

        ---Speed Slider
        speed_slider = ui_new_slider(TAB[1], TAB[2], "Fake Angle Speed Trigger", 0, 250, 10, true, " "),

    },


    ---Fake Yaw Exploits Part
    fakeyaw = {

        label = ui_new_label(TAB[1], TAB[2], ">> Fake Yaw"),

        enable = ui_new_combobox( TAB[1], TAB[2], "Fake Yaw Preset", 
        "Preset", "Costum"),
    
        custom_menu = ui_new_combobox( TAB[1], TAB[2], "Customized State", AA_S),
    
        hide_menu = ui_new_checkbox( TAB[1], TAB[2], "Hide Preset Panel", false),
    
        config_export = ui_new_button( TAB[1], TAB[2], "Export Preset", export_config),
        config_import = ui_new_button( TAB[1], TAB[2], "Import Preset", import_config)

    },

    manual = {
        enabled = ui_new_checkbox(TAB[1], TAB[3], "Enable manual anti-aim"),
        indicator_color = ui_new_color_picker(TAB[1], TAB[3], "enable_manual_anti_aim", 130, 156, 212, 255),
        left_dir = ui_new_hotkey(TAB[1], TAB[3], "Left direction"),
        right_dir = ui_new_hotkey(TAB[1], TAB[3], "Right direction"),
        back_dir = ui_new_hotkey(TAB[1], TAB[3], "Backwards direction"),
        indicator_dist = ui_new_slider(TAB[1], TAB[3], "Distance between arrows", 1, 100, 15, true, "px"),
        manual_inactive_color = ui_new_color_picker(TAB[1], TAB[3], "manual_inactive_color", 130, 156, 212, 255),
        manual_state = ui_new_slider(TAB[1], TAB[3], "Manual direction", 0, 3, 0),
    },

    fakelag = {
        limit = ui_new_slider(TAB[1], TAB[4], "Limit", 1, 16, 15, true, "")
    }

}
---Main menu elements
for i = 1, #AA_S do
    Antiaim[i] = {
        yaw_left = ui_new_slider( TAB[1], TAB[2], "Yaw +/-" ..AA_S[i], -180, 180, 15, true, d),
        yaw_right = ui_new_slider( TAB[1], TAB[2], "\nYaw +/-" ..AA_S[i], -180, 180, 15, true, d),

        jitter_left = ui_new_slider( TAB[1], TAB[2], "Yaw Jitter +/-" ..AA_S[i], -180, 180, 15, true, d),
        jitter_right = ui_new_slider( TAB[1], TAB[2], "\nYaw Jitter +/-" ..AA_S[i], -180, 180, 15, true, d), 

        bodyyaw = ui_new_slider( TAB[1], TAB[2], "Body Yaw +/-" ..AA_S[i], -180, 180, 15, true, d),

        fake_limit_left = ui_new_slider( TAB[1], TAB[2], "Fake Limit +/-" ..AA_S[i], 0, 60, 15, true, d),
        fake_limit_right = ui_new_slider( TAB[1], TAB[2], "\nFake Limit" ..AA_S[i], 0, 60, 15, true, d),
    }
end

local function init_preset()

    ui_set(Antiaim[1].yaw_left,0) ui_set(Antiaim[1].yaw_right,12) 
    ui_set(Antiaim[1].jitter_left,70) ui_set(Antiaim[1].jitter_right,90) 
    ui_set(Antiaim[1].bodyyaw,0)
    ui_set(Antiaim[1].fake_limit_left,55) ui_set(Antiaim[1].fake_limit_right,59)

    ui_set(Antiaim[2].yaw_left,0) ui_set(Antiaim[2].yaw_right,0)
    ui_set(Antiaim[2].jitter_left,0) ui_set(Antiaim[2].jitter_right,0)
    ui_set(Antiaim[2].bodyyaw,0)
    ui_set(Antiaim[2].fake_limit_left,60) ui_set(Antiaim[2].fake_limit_right,60)

    ui_set(Antiaim[3].yaw_left,12) ui_set(Antiaim[3].yaw_right,9)
    ui_set(Antiaim[3].jitter_left,36) ui_set(Antiaim[3].jitter_right,40)
    ui_set(Antiaim[3].bodyyaw,0)
    ui_set(Antiaim[3].fake_limit_left,50) ui_set(Antiaim[3].fake_limit_right,59)

    ui_set(Antiaim[4].yaw_left,0) ui_set(Antiaim[4].yaw_right,0)
    ui_set(Antiaim[4].jitter_left,0) ui_set(Antiaim[4].jitter_right,0)
    ui_set(Antiaim[4].bodyyaw,0)
    ui_set(Antiaim[4].fake_limit_left,60) ui_set(Antiaim[4].fake_limit_right,60)

    ui_set(Antiaim[5].yaw_left,18) ui_set(Antiaim[5].yaw_right,12)
    ui_set(Antiaim[5].jitter_left,46) ui_set(Antiaim[5].jitter_right,45)
    ui_set(Antiaim[5].bodyyaw,5)
    ui_set(Antiaim[5].fake_limit_left,55) ui_set(Antiaim[5].fake_limit_right,59)

    ui_set(Antiaim[6].yaw_left,18) ui_set(Antiaim[6].yaw_right,12)
    ui_set(Antiaim[6].jitter_left,46) ui_set(Antiaim[6].jitter_right,45)
    ui_set(Antiaim[6].bodyyaw,5)
    ui_set(Antiaim[6].fake_limit_left,55) ui_set(Antiaim[6].fake_limit_right,59)
end

---Init Fake yaw menu elements

local function handle_function_menu()

    -->> Indicator Section
    local Indicator = contains(ui_get(mlc.indicators), "Status Netgraph")
    local Advance = ui_get(mlc.custom_ind.enable)
    ui_set_visible(mlc.custom_ind.enable, Indicator)
    ui_set_visible(mlc.custom_ind.panel_box, Indicator and Advance)

    -->> Name tag section
    local NameTag = contains(ui_get(mlc.custom_ind.panel_box), "Enable name Tag") and Indicator and Advance
    ui_set_visible(mlc.tag.enabled, NameTag)
    ui_set_visible(mlc.tag.label, NameTag)
    ui_set_visible(mlc.tag.name, NameTag)

    -->> Roll Angle Section
    local rollangle = contains(ui_get(mlc.Exploit_mode_combobox), "Roll Angle")
    ui_set_visible(mlc.roll.label, rollangle)
    ui_set_visible(mlc.roll.mode, rollangle)
    ui_set_visible(mlc.roll.slider_adjust, rollangle)
    ui_set_visible(mlc.roll.slider_roll, rollangle)

    -->> Select mode
    local inair = contains(ui_get(mlc.roll.mode), "In Air") and rollangle
    ui_set_visible(mlc.roll.in_air_roll, inair)

    -->> Stamina
    local stamina = contains(ui_get(mlc.roll.mode), "Low Stamina") and rollangle
    ui_set_visible(mlc.roll.stamina_slider, stamina)

    -->> Speed
    local speed = contains(ui_get(mlc.roll.mode), "< Speed Velocity") and rollangle
    ui_set_visible(mlc.roll.velocity_slider, speed)
    ui_set_visible(mlc.roll.checkbox_hitchecker, speed)

    -->> On key
    local on_key = contains(ui_get(mlc.roll.mode), "On Key") and rollangle
    ui_set_visible(mlc.roll.key, on_key)

    -----------------------------------------------

    -->> Fake Angle Section
    local fakeangle = contains(ui_get(mlc.Exploit_mode_combobox), "Fake Angle")
    ui_set_visible(mlc.fakeangle.label, fakeangle)
    ui_set_visible(mlc.fakeangle.speed_slider, fakeangle)

    -----------------------------------------------

    -->> Fake Yaw Section
    local fakeyaw = contains(ui_get(mlc.Exploit_mode_combobox), "Fake Yaw")
    ui_set_visible(mlc.fakeyaw.label, fakeyaw)
    -->> Select mode
    ui_set_visible(mlc.fakeyaw.enable, fakeyaw)
    local preset = ui_get(mlc.fakeyaw.enable) == "Preset"
    local custom = ui_get(mlc.fakeyaw.enable) == "Costum" and fakeyaw
    local is_hiding = ui_get(mlc.fakeyaw.hide_menu)
    -->> Go for preset
    if preset then init_preset() end

    -->> Go for custom
    ui_set_visible(mlc.fakeyaw.hide_menu, custom)
    ui_set_visible(mlc.fakeyaw.custom_menu, custom)

    ui_set_visible(mlc.fakeyaw.config_import, custom and not is_hiding)
    ui_set_visible(mlc.fakeyaw.config_export, custom and not is_hiding)
    for i=1, #AA_S do
        local set_visible = ui_get(mlc.fakeyaw.custom_menu) == AA_S[i]
        local visible = custom and set_visible and not is_hiding

        ui_set_visible(Antiaim[i].yaw_left, visible)
        ui_set_visible(Antiaim[i].yaw_right, visible)
        ui_set_visible(Antiaim[i].jitter_left, visible)
        ui_set_visible(Antiaim[i].jitter_right, visible)
        ui_set_visible(Antiaim[i].bodyyaw, visible)
        ui_set_visible(Antiaim[i].fake_limit_left, visible)
        ui_set_visible(Antiaim[i].fake_limit_right, visible)
    end

    -->> Handle Manual Anti aim
    local state = not ui.get(mlc.manual.enabled) -- or (e == nil and menu_call == nil)
    multi_exec(ui.set_visible, {
        [mlc.manual.indicator_color] = not state,
        [mlc.manual.manual_inactive_color] = not state,
        [mlc.manual.indicator_dist] = not state ,
        [mlc.manual.left_dir] = not state,
        [mlc.manual.right_dir] = not state,
        [mlc.manual.back_dir] = not state,
        [mlc.manual.manual_state] = not state,
    })
    -->> Handle Fake lag
    ui_set_visible(references.fake_lag_limit, false)
end
---Menu element visible
local function Roll_Angle(cmd)
    local local_player = entity_get_local_player()
    local rollangle = contains(ui_get(mlc.Exploit_mode_combobox), "Roll Angle")
    -->> InAir -> On key -> Speed -> Stamina -> On hit -> On ladders
    local InAir = (bit_band(entity_get_prop(local_player, "m_fFlags"), 1) == 0)
    local InAir_bind = contains(ui_get(mlc.roll.mode), "In Air")

    local onkey = contains(ui_get(mlc.roll.mode), "On Key")
    local onkey_bind = ui_get(mlc.roll.key)

    local Speed = velocity()
    local Speed_bind = contains(ui_get(mlc.roll.mode), "< Speed Velocity")
    local speed_slider = ui_get(mlc.roll.velocity_slider)

    local Stamina = (80 - entity_get_prop(local_player, "m_flStamina"))
    local Stamina_bind = contains(ui_get(mlc.roll.mode), "Low Stamina")
    local Stamina_slider = ui_get(mlc.roll.stamina_slider)

    local onhit = (entity_get_prop(local_player, "m_flVelocityModifier"))
    local onhit_bind = (ui_get(mlc.roll.checkbox_hitchecker))

    local on_ladders = entity.get_prop(local_player, "m_MoveType") == 9
    local on_ladders_bind = contains(ui_get(mlc.roll.mode), "On Ladders")
    --Movement Libary

    local roll_bind = ui_get(mlc.roll.slider_roll)
    local air_status = (InAir and InAir_bind)
    local key_status = (onkey and onkey_bind)
    local ladder_status = (on_ladders and on_ladders_bind)
    local hit_bind = (speed_slider)
    local stamina_status = (Stamina_bind and Stamina_slider) or 0

    --Status libary


    local should_roll   = rollangle and (
                        air_status == true or 
                        key_status == true or
                        ((onhit >= 0.9 and Speed_bind) and Speed <= hit_bind) or
                        Stamina <= stamina_status or
                        ladder_status)

    local pUserCmd = g_pInput.vfptr.GetUserCmd(ffi.cast("uintptr_t", g_pInput), 0, cmd.command_number)

    if should_roll then

        is_rolling = true
        local my_weapon = entity.get_player_weapon(local_player)
        local wepaon_id = bit_band(0xffff, entity_get_prop(my_weapon, "m_iItemDefinitionIndex"))
        local is_grenade =
            ({
            [43] = true, [44] = true, [45] = true,
            [46] = true, [47] = true, [48] = true,
            [68] = true
        })[wepaon_id] or false
        if is_grenade then return end
        pUserCmd.viewangles.roll = roll_bind

    else
        is_rolling = false
    end



end
---Rolling Functions
local function detection()

    local closest_fov           = 100000

    local player_list           = entity.get_players( true )

    local eye_pos               = vector( x, y, z )

    x,y,z                       = client.camera_angles( )

    local cam_angles            = vector( x, y, z )
    
    for i = 1 , #player_list do
        player                  = player_list[ i ]
        if not entity_is_dormant( player ) and entity_is_alive( player ) then
            if is_enemy_peeking( player ) or is_local_peeking_enemy( player ) then
                last_time_peeked        = globals_curtime( )
                local enemy_head_pos    = vector( entity_hitbox_position( player, 0 ) )
                local current_fov       = get_FOV( cam_angles,eye_pos, enemy_head_pos )
                if current_fov < closest_fov then
                    closest_fov         = current_fov
                    needed_player       = player
                end
            end
        end
    end
        detections = "DORMANCY"
        local is_slowwalk = ui_get(references.slow_walk[2])
    if needed_player ~= -1 then
        if not entity_is_dormant( player ) and entity_is_alive( player ) and is_rolling == true and not is_slowwalk then
            if ( ( is_enemy_peeking( player ) or is_local_peeking_enemy( player ) ) ) == true then
                detections = "LEFT PEEKS"
                vars.static_yaw = -7
                vars.static_bodyyaw = -180
            else
                detections = "RIGHT PEEKS"
                vars.static_yaw = 7
                vars.static_bodyyaw = 180
            end
        elseif is_slowwalk and is_rolling == true then
            detections = "SLOW WALK"
            vars.static_yaw = 7
            vars.static_bodyyaw = 180
        end
    end
    if detections == "DORMANCY" then
        --ui.set(slider_roll, anti_aim.get_desync(1) > 0 and ui.get(slider_adjust) or -(ui.get(slider_adjust)))
    end
end

--Roll Angle Anti Aim
local num = 90
local function fake_angle_handler(cmd)
    local reverse_num = 180
    if contains(ui_get(mlc.Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then return end
    local speed = velocity()
    fake_angle = false
    if contains(ui_get(mlc.Exploit_mode_combobox), "Fake Angle") then
        if inair() or stamina() < 79 or velocity() < ui_get(mlc.fakeangle.speed_slider) then return end
        if ui_get(references.doubletap[2]) then return end
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

            -- +use to disable like any anti aim

            if inair() then
                return
            end
            cmd.allow_send_packet = false
            local Left = client_key_state(0x41)
            local Right = client_key_state(0x44)
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
---Fake Angle Anti Aim

local function antiaim_yaw_jitter(a,b)
    local desync = entity_get_prop(entity_get_local_player(), "m_flPoseParameter", 11) * 120 - 60
    local overlap = anti_aim.get_overlap(rotation)
    Jitter_Status = (overlap > 0.7 and "FAKE YAW +/-") or "OVERLAP-"
    return (desync < 0 and overlap > 0.6 and a or b)
end

local function fake_yaw(cmd)
    local local_player = entity_get_local_player()
    local current_threat = client.current_threat()
    local origin_local = vector(entity_get_origin(local_player))
    local origin_threat = (current_threat ~= nil and vector(entity_get_origin(current_threat)) or nil)

    local height = (origin_threat ~= nil and (origin_local.z > origin_threat.z + 10)) or false

    local is_expoliting =  contains(ui_get(mlc.Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") or ui_get(references.doubletap[2]) or ui_get(onshotkey)
    ---Libary required

    local state = (inair() and (height and 5 or 6)) or
                (velocity() > 90 and (is_expoliting and 1 or 2)) or
                (is_expoliting and 3 or 4)


    vars.yaw_left = ui_get(Antiaim[state].yaw_left)
    vars.yaw_right = ui_get(Antiaim[state].yaw_right)
    vars.jitter_left = ui_get(Antiaim[state].jitter_left)
    vars.jitter_right = ui_get(Antiaim[state].jitter_right)
    vars.bodyyaw = ui_get(Antiaim[state].bodyyaw)
    vars.fake_limit_left = ui_get(Antiaim[state].fake_limit_left)
    vars.fake_limit_right = ui_get(Antiaim[state].fake_limit_right)
end
---Fake Yaw Anti Aim

local bind_system = {
    left = false,
    right = false,
    back = false,
}

local function manual()
    ui_get(mlc.manual.left_dir, "On hotkey")
    ui_get(mlc.manual.right_dir, "On hotkey")
    ui_get(mlc.manual.back_dir, "On hotkey")

    local m_state = ui_get(mlc.manual.manual_state)

    local left_state, right_state, backward_state = ui_get(mlc.manual.left_dir), ui_get(mlc.manual.right_dir),ui_get(mlc.manual.back_dir)

    if left_state == bind_system.left and right_state == bind_system.right and backward_state == bind_system.back then return end

    bind_system.left, bind_system.right, bind_system.back = left_state, right_state, backward_state

    if (left_state and m_state == 1) or (right_state and m_state == 2) or (backward_state and m_state == 3) then ui_set(mlc.manual.manual_state, 0) return end

    if left_state and m_state ~= 1 then ui_set(mlc.manual.manual_state, 1) end

    if right_state and m_state ~= 2 then ui_set(mlc.manual.manual_state, 2) end

    if backward_state and m_state ~= 3 then ui_set(mlc.manual.manual_state, 3) end
end
--Manual Anti Aim

local pi = 3.14159265358979323846
local function d2r(value)
	return value * (pi / 180)
end

local function vectorangle(x,y,z)
	local fwd_x, fwd_y, fwd_z
	local sp, sy, cp, cy
	
	sy = math.sin(d2r(y))
	cy = math.cos(d2r(y))
	sp = math.sin(d2r(x))
	cp = math.cos(d2r(x))
	fwd_x = cp * cy
	fwd_y = cp * sy
	fwd_z = -sp
	return fwd_x, fwd_y, fwd_z
end


local function multiplyvalues(x,y,z,val)
	x = x * val y = y * val z = z * val
	return x, y, z
end

local function freestanding()
    local localp = entity.get_local_player()
    if entity_get_prop(localp, "m_lifeState") ~= 0 then
        return false
     --we are dead who cares
    end

    --ui.set(references.body_yaw[1], "Static")

    local eyepos_x, eyepos_y, eyepos_z = entity_get_prop(localp, "m_vecAbsOrigin")
    local offsetx, offsety, offsetz = entity_get_prop(localp, "m_vecViewOffset")
    eyepos_z = eyepos_z + offsetz
    local lowestfrac = 1
    local dir = false
    local cpitch, cyaw = client.camera_angles()
    local fractionleft, fractionright = 0, 0
    local amountleft, amountright = 0, 0

    for i = -45, 45, 5 do
        if i ~= 0 then
            local fwdx, fwdy, fwdz = vectorangle(0, cyaw + i, 0)
            fwdx, fwdy, fwdz = multiplyvalues(fwdx, fwdy, fwdz, 70)
            --debug drawing if u want to play with the values

            local fraction =
                client.trace_line(
                localp,
                eyepos_x,
                eyepos_y,
                eyepos_z,
                eyepos_x + fwdx,
                eyepos_y + fwdy,
                eyepos_z + fwdz
            )
            local outx, outy = renderer.world_to_screen(eyepos_x + fwdx, eyepos_y + fwdy, eyepos_z + fwdz)
            if fraction < 1 then

                  --renderer.rectangle(outx - 2, outy - 2, 4, 4, 0, 255, 0, 255)
            else
                --renderer.rectangle(outx - 2, outy - 2, 4, 4, 255, 255, 255, 255)

            end
            if i > 0 then
                fractionleft = fractionleft + fraction
                amountleft = amountleft + 1
            else
                fractionright = fractionright + fraction
                amountright = amountright + 1
            end
        end
    end

    local averageleft, averageright = fractionleft / amountleft, fractionright / amountright

    if averageleft < averageright then
        return "left"
    elseif averageleft > averageright then
        return "right"
    else
        return "none"
    end
end

local function inuse(e)
    local weaponn = entity.get_player_weapon()
    if weaponn ~= nil and entity.get_classname(weaponn) == "CC4" then
        if e.in_attack == 1 then
            e.in_attack = 0 
            e.in_use = 1
        end
    else
        if e.chokedcommands == 0 then
            e.in_use = 0
        end
    end
end
--Legit Anti Aim

local function backstab()
    local enemies = entity.get_players(true)
    local local_origin = vector(entity.get_origin(entity.get_local_player()))
    local is_near = false
    for i = 1, #enemies do
        local enemy_origin = vector(entity.get_origin(enemies[i]))
        local distance = local_origin:dist(enemy_origin)
        local weapon = entity.get_player_weapon(enemies[i])
        local class = entity_get_classname(weapon) --we get enemy's weapon here
        if distance < 128 and class == "CKnife" then return true end
    end
    return false
end
--Back Stab detections

--Make Antiaim vars independent for dormancy mode
local antiaim = {

    Pitch = "Minimal",

    Yaw_base = "At targets",

    Yaw_mode = "180",

    Yaw = 0,

    Jitter_Mode = "Center",

    Yaw_Jitter = 0,

    Bodyyaw_mode = "Jitter",

    Bodyyaw = 0,

    Fake_Limit = 0,

}

local function antiaim_handler(cmd)
    local is_roll = contains(ui_get(mlc.Exploit_mode_combobox), "Roll Angle") and is_rolling
    local is_fakeangle = contains(ui_get(mlc.Exploit_mode_combobox), "Fake Angle") and fake_angle
    Jittering = is_rolling == false and fake_angle == false and contains(ui_get(mlc.Exploit_mode_combobox), "Fake Yaw")
    --Logic Handling

    local is_legit = contains(ui_get(mlc.misc_combobox), "Legit Anti-aim on use")
    if is_legit then inuse(cmd) end
    local avoid_stab = contains(ui_get(mlc.misc_combobox), "Legit Anti-aim on Backstab")
    if avoid_stab then backstab() end
    local is_manual = ui_get(mlc.manual.enabled)
    if is_manual then manual() end
    local is_static = is_roll or is_fakeangle
    if is_static then detection() end
    local is_jitter = not is_static and Jittering
    if is_jitter then fake_yaw() end
    --Priority Handling(legit aa >> manual >> is_static >> is_jitter)

    local Legit_status = freestanding()
    local is_legit_run = (client_key_state(0x45) and is_legit) or (avoid_stab and backstab())
    local Legit_Bodyyaw = (Legit_status == "left" and -180) or (Legit_status == "right" and 180)
    local legit_off = "Off"

    --Handling Legit Anti Aim
    local manual_info = (ui_get(mlc.manual.manual_state) == 2 and "RIGHT") or 
                        (ui_get(mlc.manual.manual_state) == 1 and "LEFT") or 
                        (ui_get(mlc.manual.manual_state) == 3 and "BACK") or "NONE"
    local manual_yaw = ((ui_get(mlc.manual.manual_state) == 2 and 90) or (ui_get(mlc.manual.manual_state) == 1 and -90) or (ui_get(mlc.manual.manual_state) == 0) and false)
    local manual_run = ((manual_info == "RIGHT") or (manual_info == "LEFT")) or false
    --Handling Manual Anti aim

    local dormancy = (detections == "DORMANCY" or detections == "WAITING")
    local static_jitter = 0
    local static_fake_limit = 60
    --Handling Static Mode Anti aim

    local jitter_yaw = antiaim_yaw_jitter(vars.yaw_left, vars.yaw_right)
    local jitter_jitter = antiaim_yaw_jitter(vars.jitter_left, vars.jitter_right)
    local jitter_fake_limit = antiaim_yaw_jitter(vars.fake_limit_left, vars.fake_limit_right)
    local jitter_bodyyaw = vars.bodyyaw
    --Handling Jitter Mode Anti aim

    antiaim.Pitch = (is_legit_run and legit_off) or "Minimal"
    antiaim.Yaw_base = "At targets"
    antiaim.Yaw_mode = (is_legit_run and legit_off) or "180"
    antiaim.Yaw = (manual_run and manual_yaw) or (is_static and vars.static_yaw) or (is_jitter and jitter_yaw) or ui_get(references.yaw[2])
    antiaim.Jitter_Mode = (is_legit_run and legit_off) or "Center"
    antiaim.Yaw_Jitter = (is_static and static_jitter) or (is_jitter and jitter_jitter) or ui_get(references.jitter[2])
    antiaim.Bodyyaw_mode = (is_static and "Static") or (is_jitter and "Jitter") or ui_get(references.body_yaw[1])
    antiaim.Bodyyaw = (is_legit_run and Legit_Bodyyaw) or (is_static and vars.static_bodyyaw) or (is_jitter and jitter_bodyyaw) or ui_get(references.body_yaw[2])
    antiaim.Fake_Limit = (is_static and static_fake_limit) or (is_jitter and jitter_fake_limit) or ui_get(references.fake_limit)
    --Configing Anti aim

    if cmd.chokedcommands ~= 0 then return end
    --If Chocking or its dormancy then dont do anything

    if not is_manual and not is_static and not is_jitter and not is_legit and not avoid_stab then return end
    --If no mode is selected then dont do anything

    if dormancy and not (manual_run or is_jitter) then return end
    --If its in dormancy mode and not in manual mode then dont do anything

    ui_set(references.pitch, antiaim.Pitch)
    ui_set(references.yaw_base, antiaim.Yaw_base)
    ui_set(references.yaw[1], antiaim.Yaw_mode)
    ui_set(references.yaw[2], antiaim.Yaw)
    ui_set(references.jitter[1], antiaim.Jitter_Mode)
    ui_set(references.jitter[2], antiaim.Yaw_Jitter)
    ui_set(references.body_yaw[1], antiaim.Bodyyaw_mode)
    ui_set(references.body_yaw[2], antiaim.Bodyyaw)
    ui_set(references.fake_limit, antiaim.Fake_Limit)

end

local function fakelag_handle(cmd)
    local is_onshot = ((ui_get(onshotkey) --[[or ui.get(references.doubletap[2])]]    ))
    local is_valve_server = contains(ui_get(mlc.Exploit_mode_combobox), "\aB6B665FFValve Server Bypass")
    local is_fakeangle = contains(ui_get(mlc.Exploit_mode_combobox), "Fake Angle") and fake_angle
    local real_fakelag = (is_onshot and not ui_get(references.fakeduck[1]) and 1) or (is_fakeangle and 17) or
                        (is_valve_server and ((ui_get(mlc.fakelag.limit) > 6) and 6) or (ui_get(mlc.fakelag.limit))) or 
                        (ui_get(mlc.fakelag.limit) > ui.get(dsreferences.ticks_user) - 1 and ui.get(dsreferences.ticks_user) - 1)

    ui_set(references.fake_lag_limit, real_fakelag)
end

local function tickbase_nadle(cmd)
    local is_valve_ds = ffi.cast('bool*', dsreferences.gamerules[0] + 124)
    if is_valve_ds ~= nil then
        if contains(ui.get(mlc.Exploit_mode_combobox), "\aB6B665FFValve Server Bypass") then
            is_valve_ds[0] = 0
            dsreferences.is_valve_spoof = true
            ui_set(dsreferences.ticks_user, 7)
        else 
            dsreferences.is_valve_spoof = false
            ui_set(dsreferences.ticks_user, 18)
        end
    end
end

local a = {
    header = {0, 0, 0},
    speed_slider = {0, 0, 0},
    theme_color = {0, 0, 0},

    ind_a = {0, 0, 0, 0},
    ind_offset = {0, 0, 0, 0},
    ind_offset_exp = {0, 0, 0, 0},
    ind_text = {"DT", "HIDE", "BAIM", "SP"},

    offset = 0,

    manual_left = 0,
    manual_right = 0,
}

function lerp(start, vend, time)
return start + (vend - start) * time end

local function indicator()
    local ss = {client_screen_size()}
    local center_x, center_y = ss[1] / 2, ss[2] / 2

    for i = 1,  #a.header, 1 do
        local hit = (entity_get_prop(entity_get_local_player(), "m_flVelocityModifier"))
        local color = (i == 1 and (124 * 2 - 124 * hit)) or (i == 2 and 255 * hit) or (i == 3 and 13)
        a.header[i] = lerp(a.header[i], color, globals_frametime() * 6)
    end
    -->> On Hit Color handler

    local theme_color = {
        roll = {253, 162, 180},
        fake_angle = {64, 224, 208},
        fake_yaw = {184, 187, 255},
        waiting = {255, 255, 255}
    }
    for i = 1, #a.theme_color, 1 do
        local state = is_rolling and theme_color.roll[i] or
                    (fake_angle and theme_color.fake_angle[i]) or
                    (Jittering and theme_color.fake_yaw[i]) or
                    (not is_rolling and not fake_angle and not Jittering and theme_color.waiting[i]) 
        a.theme_color[i] = lerp(a.theme_color[i], state, globals_frametime() * 6)
    end
    -->> Theme color for each mode

    local speed = velocity()
    if velocity() > 30 and velocity() < 250  then
        a.speed_slider[1] = lerp(a.speed_slider[1], 255,globals_frametime() * 6)
        a.speed_slider[2] = lerp(a.speed_slider[2], 7,globals_frametime() * 6)
        a.speed_slider[3] = lerp(a.speed_slider[3], speed, globals_frametime() * 6)
        else if velocity() < 30 then
            a.speed_slider[1] = lerp(a.speed_slider[1], 0,globals_frametime() * 6)
            a.speed_slider[2] = lerp(a.speed_slider[2], 0,globals_frametime() * 6)
            a.speed_slider[3] = lerp(a.speed_slider[3], 0, globals_frametime() * 6)
            else if a.speed_slider[3] > 250 then
                a.speed_slider[3] = 250
            else 
                a.speed_slider[1] = 255
                a.speed_slider[2] = 7
            end
        end
    end
    -->> Speed Slider Handler

    local fb = ui.get(references.fba_key)
    local sp = ui.get(references.fsp_key)
    local dt = ui.get(references.doubletap[2])
    local os = ui.get(onshotkey)
    local keybind = {key = {dt, os, fb, sp}}

    for i = 1, #keybind.key, 1 do
        a.ind_a[i] = lerp(a.ind_a[i], keybind.key[i] and 255 or 0, globals_frametime() * 6)
        a.ind_offset[i] = lerp(a.ind_offset[i], keybind.key[i] and 233 or 0, globals_frametime() * 6)
        a.ind_offset_exp[i] = lerp(a.ind_offset_exp[i], keybind.key[i] and 233 or 0, globals_frametime() * 6)
    end

    local first_exp = a.ind_offset_exp[1] / 22
    local second_exp = first_exp + a.ind_offset_exp[2] / 12
    local third_exp = second_exp + a.ind_offset_exp[3] / 12
    -->> Key binds handler

    local advance = ui_get(mlc.custom_ind.enable)
    local Indicator = contains(ui_get(mlc.indicators), "Status Netgraph")
    local custom_tag = (contains(ui_get(mlc.custom_ind.panel_box), "Enable name Tag") and advance) or (Indicator and not advance)
    local slider_bar = (contains(ui_get(mlc.custom_ind.panel_box), "Enable Slider Bar") and advance) or (Indicator and not advance)
    local state_tag = (contains(ui_get(mlc.custom_ind.panel_box), "Enable State indicator") and advance) or (Indicator and not advance)
    local keybinds = (contains(ui_get(mlc.custom_ind.panel_box), "Enable Keybinds") and advance) or (Indicator and not advance)


    if custom_tag then
        local header = gradient_text(255, 255, 255, 255, a.header[1], a.header[2], a.header[3], 255, 
        (ui_get(mlc.tag.enabled) and ui_get(mlc.tag.name)) or "MLC.YAW")
        renderer_text(center_x, center_y + 35, 255, 255, 255, 255, "-", nil, header)
    end
    -->> Header text

    if slider_bar then
        m_render_engine.render_container(center_x + 2, center_y + 46, a.speed_slider[1] / 6, 5, 
        a.theme_color[1], a.theme_color[2], a.theme_color[3], 255)
    else
        a.speed_slider[2] = 0
    end
    -->> Speed Slider Bar

    if state_tag then
        local state = (is_rolling and detections) or (fake_angle and "FAKE ANGLE") or (Jittering and Jitter_Status) or (not is_rolling and not fake_angle and not Jittering and "WAITING")
        local info = gradient_text(a.theme_color[1], a.theme_color[2], a.theme_color[3], 255, a.theme_color[1], a.theme_color[2], a.theme_color[3], 255, state)
        renderer_text(center_x, center_y + 43 + a.speed_slider[2], 255, 255, 255, 255, "-", nil, info)
    end

    a.offset = lerp(a.offset, state_tag and 7 or 0, globals_frametime() * 6)
    -->> Status Text 

    if keybinds then
        ---nigger stfu im lazy to do for loop
        renderer_text(center_x + 31 - a.ind_offset[1] / 7.67, center_y + 44 + a.offset + a.speed_slider[2], 255, 255, 255, a.ind_a[1], "-",nil, "DT")
        renderer_text(center_x + 31 - a.ind_offset[2] / 7.67 + first_exp, center_y + 44 + a.offset + a.speed_slider[2], 255, 255, 255, a.ind_a[2], "-",nil, "HIDE")
        renderer_text(center_x + 31 - a.ind_offset[3] / 7.67 + second_exp, center_y + 44 + a.offset + a.speed_slider[2], 255, 255, 255, a.ind_a[3], "-",nil, "BAIM")
        renderer_text(center_x + 31 - a.ind_offset[4] / 7.67 + third_exp, center_y + 44 + a.offset + a.speed_slider[2], 255, 255, 255, a.ind_a[4], "-",nil, "SP")
    end
    -->> Keybinds
    
end

local manual = {
    left = 0,
    right = 0
}
local function manual_indicator()
    local m_state = ui_get(mlc.manual.manual_state)
    local r, g, b, a = ui_get(mlc.manual.indicator_color)
    local w, h = client.screen_size()
    local realtime = globals_realtime() % 3
    local distance = (w/2) / 210 * ui_get(mlc.manual.indicator_dist)
    -- ⯇ ⯈ ⯅ ⯆
    
    if m_state == 1 then
        manual.left = lerp(manual.left,40, globals_frametime() * 6)
        renderer_text(w/2 - distance - manual.left, h / 2 - 1,  r, g, b, manual.left * 4 + 90, "+c", 0, indicator_left)
        else
        manual.left = lerp(manual.left, 0, globals_frametime() * 6)
        renderer_text(w/2 - distance - manual.left, h / 2 - 1, r, g, b, manual.left * 4 + 90, "+c", 0, indicator_left)
    end        
    if m_state == 2 then 
        manual.right = lerp(manual.right,40, globals_frametime() * 6)
        renderer_text(w/2 + distance + manual.right, h / 2 - 1, r, g, b, manual.right * 4 + 90, "+c", 0, indicator_right) 
    else
        manual.right = lerp(manual.right,0, globals_frametime() * 6)
        renderer_text(w/2 + distance + manual.right, h / 2 - 1, r, g, b, manual.right * 4 + 90, "+c", 0, indicator_right) 
    end
end


local log = {}

log.byaw_log = {
    info = '',
    state = false,
}

log.on_aim_miss = function(e)
    local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
    local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local target_name = entity.get_player_name(e.target)
    local reason
    if e.reason == "?" then
    	reason = "Resolver"
    else
    	reason = e.reason
    end

    log.byaw_log.state = true
    if e.reason == 'spread' then
    log.byaw_log.info = 'Missed \a90FF98FF'..target_name..'\aFFFFFFFF HB: \aFFFDA6FF'..group..', \aFFFFFFFFreason: \affbebeff'..reason.." \aFFFDA6FF("..math.floor(e.hit_chance).."%)"
        if console then
            lua_log('Missed '..target_name..' HB: '..group..', reason: '..reason.." ("..math.floor(e.hit_chance).."%)")
        end
    else
    
    log.byaw_log.info = 'Missed \a90FF98FF'..target_name..'\aFFFFFFFF HB: \aFFFDA6FF'..group..', \aFFFFFFFFreason: \affbebeff'..reason
        if console then
            lua_log('Missed '..target_name..' HB: '..group..', reason: '..reason)
        end
    end
end

log.on_player_hurt = function(e)
    local attacker_id = client.userid_to_entindex(e.attacker)
    local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
    local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
    if attacker_id == nil then
        return
    end

    if attacker_id ~= entity.get_local_player() then
        return
    end

    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local target_id = client.userid_to_entindex(e.userid)
    local target_name = entity.get_player_name(target_id)
        log.byaw_log.state = true
        log.byaw_log.info = 'Hit \a90FF98FF'..target_name..'\aFFFFFFFF in\affbebeff '.. e.dmg_health ..'\aFFFFFFFF, HB: \aFFFDA6FF'..group..',\aFFFFFFFF HP:'.. e.health
        lua_log('Hit \a90FF98FF'..target_name..'\aFFFFFFFF in\affbebeff '.. e.dmg_health ..'\aFFFFFFFF, HB: \aFFFDA6FF'..group..',\aFFFFFFFF HP:'.. e.health)
end
local hurt = false

log.local_got_hurt = function(e)
    local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
    local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    if client.userid_to_entindex( e.userid ) == entity.get_local_player( ) then
        local overlap = 100 - math.floor(anti_aim.get_overlap() * 100)
        local attN = entity.get_player_name(client.userid_to_entindex( e.attacker ) )
        hurt = true
        log.byaw_log.state = true
        log.byaw_log.info = 'Impact Detected. Hit \aFFFDA6FF'..group..'\aFFFFFFFF with Overlap: (\aFFFDA6FF'..overlap..'%\aFFFFFFFF).Jitter:'..ui.get(references.jitter[2]..'.')
        if console then
            lua_log('Impact Detected. Hit \aFFFDA6FF'..group..'\aFFFFFFFF with Overlap: (\aFFFDA6FF'..overlap..'%\aFFFFFFFF).Jitter:'..ui.get(references.jitter[2]..'.'))
        end
    else
        hurt = false
    end

end
log.miss_brute = function(e)
    -- credit to @ally https://gamesense.pub/forums/viewtopic.php?id=31914
    -- credit to @ally https://gamesense.pub/forums/viewtopic.php?id=31914
    local function KaysFunction(A,B,C)
        local d = (A-B) / A:dist(B)
        local v = C - B
        local t = v:dot(d) 
        local P = B + d:scaled(t)
        
        return P:dist(C)
    end

	local local_player = entity.get_local_player()
	local shooter = client.userid_to_entindex(e.userid)

	if not entity.is_enemy(shooter) or not entity.is_alive(local_player) then
		return
	end

	local shot_start_pos 	= vector(entity.get_prop(shooter, "m_vecOrigin"))
	shot_start_pos.z 		= shot_start_pos.z + entity.get_prop(shooter, "m_vecViewOffset[2]")
	local eye_pos			= vector(client.eye_position())
	local shot_end_pos 		= vector(e.x, e.y, e.z)
	local closest			= KaysFunction(shot_start_pos, shot_end_pos, eye_pos)

	if closest < 35 then
        local overlap = math.floor(anti_aim.get_overlap() * 100)
        --if hurt then return end
        log.byaw_log.state = true
        log.byaw_log.info = 'Miss Detected. Overlap: \aFFFDA6FF('..overlap..'%\aFFFFFFFF), Jitter:'..ui.get(references.jitter[2]..'.')

	end

end

log.draw = function(...)

    local animation_cache = {}
    local draw_event_list = {}

    local function lerp(start, vend, time)
        if not start then start = 0 end
        local cache_name = string.format('%s,%s,%s',start,vend,time)
        if animation_cache[cache_name] == nil then
            animation_cache[cache_name] = 0
        end

        animation_cache[cache_name] = start + (vend - start) * time
        return animation_cache[cache_name]
    end

    local function handler_event()
        local sx, sy = client.screen_size()
        local x, y = 20 , sy/4
        if log.byaw_log.state then
            log.byaw_log.state = false
            table.insert(draw_event_list,{
                text = log.byaw_log.info ,
                timer = globals.realtime() ,
                alpha = 0 ,
                x_add = x ,
            })
            log.byaw_log.info = ''
        end
    end

    local function draw()

        local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
        local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
        if not logs then return end
        local sx, sy = client.screen_size()
        local x, y = sx/2 , sy/2
        local font = ''
        handler_event()

        event_name = event_name == nil and 0 or event_name
        if #draw_event_list > 0 then
            event_name = lerp(
                event_name, 200, globals.frametime() * 6
            )
        else
            event_name = lerp(
                event_name, 0, globals.frametime() * 6
            )
        end

        local _,normal_width = renderer.measure_text(font)

        for i,info in ipairs(draw_event_list) do

            if i > 4 then
                table.remove(draw_event_list,i)
            end

            if not info.text or info.text == '' then goto skip end

            local length,width = renderer.measure_text(font, '['..i..'] '..info.text)
            
            if info.timer + 3.5 < globals.realtime() then
                info.alpha = lerp(
                    info.alpha, 0, globals.frametime() * 6
                )
                info.x_add = lerp(
                    info.x_add,80,globals.frametime() * 2
                )
            else
                info.alpha = lerp(
                    info.alpha, 255, globals.frametime() * 6
                )
                info.x_add = lerp(
                    info.x_add,-40,globals.frametime() * 2
                )
            end
            local x_offset = 28
            local y_offset = 20
            local text_size = {renderer.measure_text(nil,info.text)}
            if logs then
                solus_render.container(x - text_size[1]/2 - 7 - x_offset ,y+i * (width+10) + info.x_add  + 250 + y_offset, text_size[1] + 55, width + 6, 255, 125, 145, 100, 1.5)
                renderer.text(x - text_size[1]/2 + 2 - x_offset,y+i * (width+10) + info.x_add + 250 + 2 + y_offset,255,255,255,info.alpha,font,0,'  \aFFB6C1FF[mlc]\aFFFFFFFF '..info.text)
            end
            if info.timer + 4 < globals.realtime() then
                table.remove(draw_event_list,i)
            end

            ::skip::
        end
    end

    return {
        main = draw
    }
end

local au_dog = log.draw()

local function bullet_impact(shot)
    local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
    local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
    if logs or console then
        log.miss_brute(shot)
    end
end

local function player_hurt(shot)
    local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
    local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
    if logs or console then
        log.local_got_hurt(shot)
        log.on_player_hurt(shot)
    end
end

local function aim_miss(shot)
    local logs = contains(ui_get(mlc.misc_combobox), 'Logs')
    local console = contains(ui_get(mlc.misc_combobox), 'Logs Console')
    if logs or console then
        log.on_aim_miss(shot)
    end
end

local function pre_render()
    if contains(ui_get(mlc.misc_combobox), "Old Animation") then 
        entity_set_prop(entity_get_local_player(), "m_flPoseParameter", 1, 6) 
    end
end

local function shutdown()
    local is_valve_ds = ffi.cast('bool*', dsreferences.gamerules[0] + 124)
    if dsreferences.is_valve_spoof == true then 
        is_valve_ds[0] = 0
    end
    ui_set_visible(references.fake_lag_limit, true)
end

local function handle_menu2(state)
    ui_set_visible(mlc.Exploit_mode_combobox, state)
    ui_set_visible(mlc.indicators, state)
    ui_set_visible(mlc.misc_combobox, state)
end

local function run_command(cmd)
    Roll_Angle(cmd)
end

local function setup_command(cmd)

    local local_player = entity.get_local_player()
	if not entity.is_alive(local_player) then return end

    fake_angle_handler(cmd)
    antiaim_handler(cmd)
    fakelag_handle(cmd)
    tickbase_nadle(cmd)
end

local function paint_ui()

    local local_player = entity.get_local_player()
	if not entity.is_alive(local_player) then return end

    local status_netgraph = contains(ui_get(mlc.indicators), "Status Netgraph")
    if status_netgraph then indicator() end

    local manual_ind = contains(ui_get(mlc.indicators), "Manual Indicator")
    if manual_ind then manual_indicator() end

    au_dog.main()

    handle_function_menu()
end

local disable = true
handle_function_menu()
handle_menu2(false)
local function initialize()
    client.set_event_callback('bullet_impact', bullet_impact)
    client.set_event_callback('player_hurt', player_hurt)
    client.set_event_callback('aim_miss',aim_miss)
    client.set_event_callback("shutdown", shutdown)
    client.set_event_callback("pre_render", pre_render)
    client.set_event_callback("setup_command", setup_command)
    client.set_event_callback("paint_ui", paint_ui)
    client.set_event_callback("run_command", run_command)
    handle_menu2(true)
    disable = false
end
local initialize_btn = ui.new_button("AA", "Anti-aimbot angles", "Initialize mlc yaw", initialize)

client.set_event_callback("paint_ui", function()
    ui.set_visible(initialize_btn, disable)
end)