--------------------------------------------------------------------------------
-- Basic Variables
--------------------------------------------------------------------------------
local client_visible, entity_hitbox_position, math_ceil, math_pow, math_sqrt, renderer_indicator, unpack, tostring, pairs = client.visible, entity.hitbox_position, math.ceil, math.pow, math.sqrt, renderer.indicator, unpack, tostring, pairs
local ui_new_label, ui_reference, ui_new_checkbox, ui_new_combobox, ui_new_hotkey, ui_new_multiselect, ui_new_slider, ui_set, ui_get, ui_set_callback, ui_set_visible, ui_new_button = ui.new_label, ui.reference, ui.new_checkbox, ui.new_combobox, ui.new_hotkey, ui.new_multiselect, ui.new_slider, ui.set, ui.get, ui.set_callback, ui.set_visible, ui.new_button
local client_log, client_color_log, client_set_event_callback, client_unset_event_callback = client.log, client.color_log, client.set_event_callback, client.unset_event_callback

local entity_get_local_player, entity_get_player_weapon, entity_get_prop, entity_get_players, entity_is_alive = entity.get_local_player, entity.get_player_weapon, entity.get_prop, entity.get_players, entity.is_alive
--------------------------------------------------------------------------------
-- Basic Libaries
--------------------------------------------------------------------------------
local TAB = {"RAGE", "Aimbot", "LUA", "B"}
local configs, main, keybinds = {}, {}, {}
local font = "-> "
local tab

local index = {
    weapons = { "Global", "Taser", "Revolver", "Pistol", "Auto", "Scout", "AWP", "Rifle", "SMG", "Shotgun", "Deagle" },
    index_wpn = { [1] = 11, [2] = 4,[3] = 4,[4] = 4,[7] = 8,[8] = 8,[9] = 7,[10] = 8,[11] = 5,[13] = 8,[14] = 8,[16] = 8,[17] = 9,[19] = 9,[23] = 9,[24] = 9,[25] = 10,[26] = 9,[27] = 10,[28] = 8,[29] = 10,[30] = 4,[31] = 2,  [32] = 4,[33] = 9,[34] = 9,[35] = 10,[36] = 4,[38] = 5,[39] = 8,[40] = 6,[60] = 8,[61] = 4,[63] = 4,[64] = 3, [0] = 1},
    index_dmg = { [0] = "Auto", [101] = "HP + 1", [102] = "HP + 2", [103] = "HP + 3", [104] = "HP + 4", [105] = "HP + 5", [106] = "HP + 6", [107] = "HP + 7", [108] = "HP + 8", [109] = "HP + 9", [110] = "HP + 10", [111] = "HP + 11", [112] = "HP + 12", [113] = "HP + 13", [114] = "HP + 14", [115] = "HP + 15", [116] = "HP + 16", [117] = "HP + 17", [118] = "HP + 18", [119] = "HP + 19", [120] = "HP + 20", [121] = "HP + 21", [122] = "HP + 22", [123] = "HP + 23", [124] = "HP + 24", [125] = "HP + 25", [126] = "HP + 26" },
    hitgroup = { "Head", "Chest", "Arms", "Stomach", "Legs", "Feet" },
}

local lib = {

    get_weapon = function()
        local me = entity.get_local_player()
        local weapon = entity_get_player_weapon(me)
        local weapon_id = (entity_get_prop(weapon, "m_iItemDefinitionIndex"))
        if weapon_id ~= nil then
            return index.index_wpn[weapon_id]
        else
            return index.index_wpn[1]
        end
    end,

    is_key_down = function(element)
        return (ui_get(element))
    end,

    is_in_air = function()
        return (bit.band(entity_get_prop(entity_get_local_player(), "m_fFlags"), 1) == 0)
    end,

    is_double_tapping = function ()
        local doubletap = {ui.reference("RAGE", "Other", "Double Tap")}
        return (ui_get(doubletap[2]))
    end,

    contains = function(table, val)
        if #table > 0 then
            for i=1, #table do
                if table[i] == val then
                    return true
                end
            end
        end
        return false
    end,

    enemy_visible = function(idx)
        for i=0, 8 do
            local cx, cy, cz = entity_hitbox_position(idx, i)
            if client_visible(cx, cy, cz) then
                return true
            end
        end
        return false
    end,

}

--------------------------------------------------------------------------------
-- Menu References
--------------------------------------------------------------------------------
local references = {
    target_selection = ui_reference(TAB[1], TAB[2], "Target selection"),
    target_hitbox = ui_reference(TAB[1], TAB[2], "Target hitbox"),
    multipoint = ui_reference(TAB[1], TAB[2], "Multi-point"),
    multipoint_scale = ui_reference(TAB[1], TAB[2], "Multi-point scale"),
    prefer_safepoint = ui_reference(TAB[1], TAB[2], "Prefer safe point"),
    force_safepoint = ui_reference(TAB[1], TAB[2], "Force safe point"),
    avoid_unsafe_hitbox = ui_reference(TAB[1], TAB[2], "Avoid unsafe hitboxes"),
    automatic_fire = ui_reference(TAB[1], TAB[2], "Automatic fire"),
    automatic_penetration = ui_reference(TAB[1], TAB[2], "Automatic penetration"),
    silent_aim = ui_reference(TAB[1], TAB[2], "Silent aim"),
    hitchance = ui_reference(TAB[1], TAB[2], "Minimum hit chance"),
    mindamage = ui_reference(TAB[1], TAB[2], "Minimum damage"),
    automatic_scope = ui_reference(TAB[1], TAB[2], "Automatic scope"),
    reduce_aimstep = ui_reference(TAB[1], TAB[2], "Reduce aim step"),
    log_spread = ui_reference(TAB[1], TAB[2], "Log misses due to spread"),
    low_fps_mitigations = ui_reference(TAB[1], TAB[2], "Low FPS mitigations"),
    Maximum_FOV = ui_reference(TAB[1], TAB[2], 'Maximum FOV'),
}
--------------------------------------------------------------------------------
-- Initialize UI Elements
--------------------------------------------------------------------------------
local inti = {

    main = function()
        main = {
            enable = ui_new_checkbox(TAB[3], TAB[4], "Enable", false),
            tab = ui_new_combobox(TAB[3], TAB[4], "Weapon Selection", index.weapons)
        }
    end,


    --------------------------------------------------------------------------------
    -- Initialize Weapon Config
    --------------------------------------------------------------------------------

    config_1 = function()

        local target_selection = ui_new_combobox(TAB[3], TAB[4], "Target selection", {"Cycle", "Cycle (2x)", "Near crosshair", "Highest damage", "Best hit chance"})

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end

            configs[i].current_labels = ui_new_label(TAB[3], TAB[4], "Current config: " .. index.weapons[i])

            configs[i].target_hitbox = ui_new_multiselect(TAB[3], TAB[4], "Target hitbox", index.hitgroup)

            configs[i].enable_hitbox = ui_new_checkbox(TAB[3], TAB[4], font .."Hitbox Override")
            configs[i].custom_hitbox = ui_new_multiselect(TAB[3], TAB[4], "\nHitbox Option", { "On-key", "On-key 2", "In-Air", "Double tap", "Force Body Aim"})

        end

        --------------------------------------------------------------------------------
        -- Inserting Keybinds : Hitbox
        --------------------------------------------------------------------------------

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end
            configs[i].hitbox_ovr = ui_new_multiselect(TAB[3], TAB[4],  font .."Hitbox [On Key]", index.hitgroup)   
        end

        keybinds.hitbox_key = ui_new_hotkey(TAB[3], TAB[4], "Hitbox Override [On Key]", true)

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end
            configs[i].hitbox_ovr2 = ui_new_multiselect(TAB[3], TAB[4],  font .."Hitbox [On Key2]", index.hitgroup)
        end

        keybinds.hitbox_key2 = ui_new_hotkey(TAB[3], TAB[4], "Hitbox Override [On Key2]", true)

        --------------------------------------------------------------------------------

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end

            configs[i].hitbox_air = ui_new_multiselect(TAB[3], TAB[4],  font .."Hitbox [In Air]", index.hitgroup)
            configs[i].hitbox_dt = ui_new_multiselect(TAB[3], TAB[4],  font .."Hitbox [DT]", index.hitgroup)

            configs[i].multipoint = ui_new_multiselect(TAB[3], TAB[4], "Multi-point", index.hitgroup)
            configs[i].multipoint_scale = ui_new_slider(TAB[3], TAB[4], "Multi-point scale", 24, 100, 60, true, "%", 1, { [24] = "Auto" })

            configs[i].enable_multipoint = ui_new_checkbox(TAB[3], TAB[4], font .."Multi-point Override")
            configs[i].custom_multipoint = ui_new_multiselect(TAB[3], TAB[4], "\nMultipoint Option", { "On-key", "On-key 2", "In-Air", "Double tap"})

        end

        --------------------------------------------------------------------------------
        -- Inserting Keybinds : Multi-point
        --------------------------------------------------------------------------------

        for i=1, #index.weapons do
            if not configs[i] then
                configs[i] = {}
            end
            configs[i].multipoint_ovr = ui_new_slider(TAB[3], TAB[4],  font .."Multi-point scale [On Key]", 0, 100, 50, true, "%", 1, {"Off"}) 
        end

        keybinds.multipoint_key = ui_new_hotkey(TAB[3], TAB[4], "Multi-point Override [On Key]", true)


        for i=1, #index.weapons do
            if not configs[i] then
                configs[i] = {}
            end
            configs[i].multipoint_ovr2 = ui_new_slider(TAB[3], TAB[4],  font .."Multi-point scale [On Key2]", 0, 100, 50, true, "%", 1, {"Off"})    
        end

        keybinds.multipoint_key2 = ui_new_hotkey(TAB[3], TAB[4], "Multi-point Override [On Key 2]", true)

        --------------------------------------------------------------------------------

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end

            configs[i].multipoint_air = ui_new_slider(TAB[3], TAB[4],  font .."Multi-point scale [In Air]", 0, 100, 50, true, "%", 1, {"Off"})
            configs[i].multipoint_dt = ui_new_slider(TAB[3], TAB[4],  font .."Multi-point scale [DT]", 0, 100, 50, true, "%", 1, {"Off"})

            configs[i].prefer_safe_point = ui_new_checkbox(TAB[3], TAB[4], "Prefer safe point")
            configs[i].unsafe = ui_new_multiselect(TAB[3], TAB[4], "Avoid unsafe hitboxes", index.hitgroup)
            configs[i].automatic_fire = ui_new_checkbox(TAB[3], TAB[4], "Automatic fire")
            configs[i].automatic_penetration = ui_new_checkbox(TAB[3], TAB[4], "Automatic penetration")
            configs[i].automatic_scope = ui_new_checkbox(TAB[3], TAB[4], "Automatic scope")
            configs[i].silent_aim = ui_new_checkbox(TAB[3], TAB[4], "Silent aim")
        
            configs[i].hitchance = ui_new_slider(TAB[3], TAB[4], "Minimum Hitchance", 0, 100, 50, true, "%", 1, {"Off"})
            configs[i].enable_hitchance = ui_new_checkbox(TAB[3], TAB[4],  font .."Hitchance Override")
            configs[i].custom_hitchance = ui_new_multiselect(TAB[3], TAB[4], "\nHitchance Option", {"On-key", "On-key 2", "In-Air", "Double tap", "No Scope"})


        end

        --------------------------------------------------------------------------------
        -- Inserting Keybinds : Hitchance
        --------------------------------------------------------------------------------

        for i=1, #index.weapons do
            if not configs[i] then
                configs[i] = {}
            end
            configs[i].hitchance_ovr = ui_new_slider(TAB[3], TAB[4],  font .."Hitchance [On Key]", 0, 100, 50, true, "%", 1, {"Off"}) 
        end

        keybinds.hitchance_key = ui_new_hotkey(TAB[3], TAB[4], "Hitchance Override [On-key]", true)


        for i=1, #index.weapons do
            if not configs[i] then
                configs[i] = {}
            end
            configs[i].hitchance_ovr2 = ui_new_slider(TAB[3], TAB[4],  font .."Hitchance [On Key2]", 0, 100, 50, true, "%", 1, {"Off"})    
        end

        keybinds.hitchance_key2 = ui_new_hotkey(TAB[3], TAB[4], "Hitchance Override [On-key 2]", true)

        --------------------------------------------------------------------------------

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end

            configs[i].hitchance_air = ui_new_slider(TAB[3], TAB[4],  font .."Hitchance [In Air]", 0, 100, 50, true, "%", 1, {"Off"})   
            configs[i].dt_hitchance = ui_new_slider(TAB[3], TAB[4],  font .."Hitchance [DT]", 0, 100, 50, true, "%", 1, {"Off"})     
            configs[i].ns_hitchance = ui_new_slider(TAB[3], TAB[4],  font .."Hitchance [No Scope]", 0, 100, 50, true, "%", 1, {"Off"})

            configs[i].min_damage = ui_new_slider(TAB[3], TAB[4], "Minimum damage", 0, 126, 20, true, nil, 1, index.index_dmg)
            configs[i].enable_damage = ui_new_checkbox(TAB[3], TAB[4],  font .."Damage Override")
            configs[i].custom_damage = ui_new_multiselect(TAB[3], TAB[4], "\nDamage Option", {"On-key", "On-key 2", "Visible", "In-Air", "No Scope", "Double tap"})

        end

        --------------------------------------------------------------------------------
        -- Inserting Keybinds : Damage
        --------------------------------------------------------------------------------


        for i=1, #index.weapons do
            if not configs[i] then
                configs[i] = {}
            end
            configs[i].ovr_min_damage = ui_new_slider(TAB[3], TAB[4],  font .."Damage [On Key]", 0, 126, 20, true, nil, 1, index.index_dmg)
        end

        keybinds.damage_key = ui_new_hotkey(TAB[3], TAB[4], "Damage Override [On-key]", true)

        for i=1, #index.weapons do
            if not configs[i] then
                configs[i] = {}
            end
            configs[i].ovr_min_damage2 = ui_new_slider(TAB[3], TAB[4],  font .."Damage [On Key2]", -1, 126, -1, true, nil, 1, index.index_dmg)
        end

        keybinds.damage_key2 = ui_new_hotkey(TAB[3], TAB[4], "Damage Override [On-key 2]", true)

        --------------------------------------------------------------------------------

        for i=1, #index.weapons do

            if not configs[i] then
                configs[i] = {}
            end

            configs[i].vis_min_damage = ui_new_slider(TAB[3], TAB[4],  font .."Damage [Visible]", 0, 126, 20, true, nil, 1, index.index_dmg)
            configs[i].air_min_damage = ui_new_slider(TAB[3], TAB[4],  font .."Hitchance [In Air]", 0, 126, 20, true, nil, 1, index.index_dmg)
            configs[i].dt_min_damage = ui_new_slider(TAB[3], TAB[4],  font .."Damage [DT]", 0, 126, 20, true, nil, 1, index.index_dmg)

        end

    end,

    --------------------------------------------------------------------------------
    -- Innitialize Weapon Loigcs
    --------------------------------------------------------------------------------

    hitbox = function()
    end
}
--------------------------------------------------------------------------------
-- Set Ui Element Visible
--------------------------------------------------------------------------------
local visible = {

    config = function()
        for i=1, #index.weapons do
            local current = (index.weapons[i] == ui_get(main.tab))
            if index.weapons[i] == ui_get(main.tab) then tab = i end
            ui_set_visible(configs[i].current_labels, current)
            ui_set_visible(configs[i].multipoint, current)
            ui_set_visible(configs[i].prefer_safe_point, current)
            ui_set_visible(configs[i].unsafe, current)
            ui_set_visible(configs[i].automatic_fire, current)
            ui_set_visible(configs[i].automatic_penetration, current)
            ui_set_visible(configs[i].automatic_scope, current)
            ui_set_visible(configs[i].silent_aim, current)

            -->> Default utils
            ui_set_visible(configs[i].target_hitbox, current)
            ui_set_visible(configs[i].multipoint_scale, current)
            ui_set_visible(configs[i].hitchance, current)
            ui_set_visible(configs[i].min_damage, current)

            -->> Custom Hitbox
            local ht_enable = ui_get(configs[i].enable_hitbox)
            local ht_ovr = lib.contains(ui_get(configs[i].custom_hitbox), "On-key") and current and ht_enable
            local ht_ovr2 = lib.contains(ui_get(configs[i].custom_hitbox), "On-key 2") and current and ht_enable
            local ht_air = lib.contains(ui_get(configs[i].custom_hitbox), "In-Air") and current and ht_enable
            local ht_dt = lib.contains(ui_get(configs[i].custom_hitbox), "Double tap") and current and ht_enable

            ui_set_visible(configs[i].enable_hitbox, current)
            ui_set_visible(configs[i].custom_hitbox, ht_enable)

            ui_set_visible(configs[i].hitbox_ovr, ht_ovr)
            ui_set_visible(keybinds.hitbox_key, ht_ovr)

            ui_set_visible(configs[i].hitbox_ovr2, ht_ovr2)
            ui_set_visible(keybinds.hitbox_key2, ht_ovr2)

            ui_set_visible(configs[i].hitbox_air, ht_air)
            ui_set_visible(configs[i].hitbox_dt, ht_dt)

            -->> Custom Multipoint
            local mp_enable = ui_get(configs[i].enable_multipoint)
            local mp_ovr = lib.contains(ui_get(configs[i].custom_multipoint), "On-key") and current and mp_enable
            local mp_ovr2 = lib.contains(ui_get(configs[i].custom_multipoint), "On-key 2") and current and mp_enable
            local mp_air = lib.contains(ui_get(configs[i].custom_multipoint), "In-Air") and current and mp_enable
            local mp_dt = lib.contains(ui_get(configs[i].custom_multipoint), "Double tap") and current and mp_enable

            ui_set_visible(configs[i].enable_multipoint, current)
            ui_set_visible(configs[i].custom_multipoint, mp_enable)

            ui_set_visible(configs[i].multipoint_ovr, mp_ovr)


            ui_set_visible(configs[i].multipoint_ovr2, mp_ovr2)


            ui_set_visible(configs[i].multipoint_air, mp_air)
            ui_set_visible(configs[i].multipoint_dt, mp_dt)

            -->> Custom Hitchance
            local hc_enable = ui_get(configs[i].enable_hitchance)
            local hc_ovr = lib.contains(ui_get(configs[i].custom_hitchance), "On-key") and current and hc_enable
            local hc_ovr2 = lib.contains(ui_get(configs[i].custom_hitchance), "On-key 2") and current and hc_enable
            local hc_air = lib.contains(ui_get(configs[i].custom_hitchance), "In-Air") and current and hc_enable
            local hc_dt = lib.contains(ui_get(configs[i].custom_hitchance), "Double tap") and current and hc_enable
            local hc_ns = lib.contains(ui_get(configs[i].custom_hitchance), "No Scope") and current and hc_enable

            ui_set_visible(configs[i].enable_hitchance, current)
            ui_set_visible(configs[i].custom_hitchance, hc_enable)
            ui_set_visible(configs[i].hitchance_ovr, hc_ovr)
            ui_set_visible(configs[i].hitchance_ovr2, hc_ovr2)
            ui_set_visible(configs[i].hitchance_air, hc_air)
            ui_set_visible(configs[i].dt_hitchance, hc_dt)
            ui_set_visible(configs[i].ns_hitchance, hc_ns)

            -->>Custom Damage
            local cd_enable = ui_get(configs[i].enable_damage)
            local cd_ovr = lib.contains(ui_get(configs[i].custom_damage), "On-key") and current and cd_enable
            local cd_ovr2 = lib.contains(ui_get(configs[i].custom_damage), "On-key 2") and current and cd_enable
            local cd_vis = lib.contains(ui_get(configs[i].custom_damage), "Visible") and current and cd_enable
            local cd_air = lib.contains(ui_get(configs[i].custom_damage), "In-Air") and current and cd_enable
            local cd_dt = lib.contains(ui_get(configs[i].custom_damage), "Double tap") and current and cd_enable

            ui_set_visible(configs[i].enable_damage, current)
            ui_set_visible(configs[i].custom_damage, cd_enable)
            ui_set_visible(configs[i].ovr_min_damage, cd_ovr)
            ui_set_visible(configs[i].ovr_min_damage2, cd_ovr2)
            ui_set_visible(configs[i].vis_min_damage, cd_vis)
            ui_set_visible(configs[i].air_min_damage, cd_air)
            ui_set_visible(configs[i].dt_min_damage, cd_dt)

        end
    end,
    
    keybinds = function()

        local ht_enable = ui_get(configs[tab].enable_hitbox)
        local ht_ovr = lib.contains(ui_get(configs[tab].custom_hitbox), "On-key") and ht_enable
        local ht_ovr2 = lib.contains(ui_get(configs[tab].custom_hitbox), "On-key 2") and ht_enable

        ui_set_visible(keybinds.hitbox_key, ht_ovr)
        ui_set_visible(keybinds.hitbox_key2, ht_ovr2)

        local mp_enable = ui_get(configs[tab].enable_multipoint)
        local mp_ovr = lib.contains(ui_get(configs[tab].custom_multipoint), "On-key") and mp_enable
        local mp_ovr2 = lib.contains(ui_get(configs[tab].custom_multipoint), "On-key 2") and mp_enable

        ui_set_visible(keybinds.multipoint_key, mp_ovr)
        ui_set_visible(keybinds.multipoint_key2, mp_ovr2)

        local hc_enable = ui_get(configs[tab].enable_hitchance)
        local hc_ovr = lib.contains(ui_get(configs[tab].custom_hitchance), "On-key") and hc_enable
        local hc_ovr2 = lib.contains(ui_get(configs[tab].custom_hitchance), "On-key 2") and hc_enable

        ui_set_visible(keybinds.hitchance_key, hc_ovr)
        ui_set_visible(keybinds.hitchance_key2, hc_ovr2)

        local cd_enable = ui_get(configs[tab].enable_damage)
        local cd_ovr = lib.contains(ui_get(configs[tab].custom_damage), "On-key") and cd_enable
        local cd_ovr2 = lib.contains(ui_get(configs[tab].custom_damage), "On-key 2") and cd_enable

        ui_set_visible(keybinds.damage_key, cd_ovr)
        ui_set_visible(keybinds.damage_key2, cd_ovr2)
    end
}

local fetch = {

    hitbox = function(tab)
        local hitbox = ui_get(configs[tab].enable_hitbox)
        local hitbox_ovr = lib.contains(ui_get(configs[tab].custom_hitbox), "On-key") and hitbox
        local hitbox_ovr2 = lib.contains(ui_get(configs[tab].custom_hitbox), "On-key 2") and hitbox
        local hitbox_air = lib.contains(ui_get(configs[tab].custom_hitbox), "In-Air") and hitbox
        local hitbox_dt = lib.contains(ui_get(configs[tab].custom_hitbox), "Double tap") and hitbox
        local hitbox_o = ui_get(configs[tab].target_hitbox)

        if hitbox_ovr and lib.is_key_down(keybinds.hitbox_key) then
            return hitbox_ovr
        elseif hitbox_ovr2 and lib.is_key_down(keybinds.hitbox_key2) then
            return hitbox_ovr2
        elseif hitbox_air and lib.is_in_air() then
            return hitbox_air
        elseif hitbox_dt and lib.is_double_tapping() then
            return hitbox_dt
        else
            return hitbox_o
        end
    end,

    multipoint = function(tab)
        local multipoint = ui_get(configs[tab].enable_multipoint)
        local multipoint_ovr = lib.contains(ui_get(configs[tab].custom_multipoint), "On-key") and multipoint
        local multipoint_ovr2 = lib.contains(ui_get(configs[tab].custom_multipoint), "On-key 2") and multipoint
        local multipoint_vis = lib.contains(ui_get(configs[tab].custom_multipoint), "Visible") and multipoint
        local multipoint_air = lib.contains(ui_get(configs[tab].custom_multipoint), "In-Air") and multipoint
        local multipoint_dt = lib.contains(ui_get(configs[tab].custom_multipoint), "Double tap") and multipoint
        local multipoint_o = ui_get(configs[tab].multipoint)

        if multipoint_ovr and lib.is_key_down(keybinds.multipoint_key) then
            return multipoint_ovr
        elseif multipoint_ovr2 and lib.is_key_down(keybinds.multipoint_key2) then
            return multipoint_ovr2
        elseif multipoint_air and lib.is_in_air() then
            return multipoint_air
        elseif multipoint_dt and lib.is_double_tapping() then
            return multipoint_dt
        else
            return multipoint_o
        end
    end,

    hitchance = function(tab)
        local hitchance = ui_get(configs[tab].enable_hitchance)
        local hitchance_ovr = lib.contains(ui_get(configs[tab].custom_hitchance), "On-key") and hitchance
        local hitchance_ovr2 = lib.contains(ui_get(configs[tab].custom_hitchance), "On-key 2") and hitchance
        local hitchance_air = lib.contains(ui_get(configs[tab].custom_hitchance), "In-Air") and hitchance
        local hitchance_dt = lib.contains(ui_get(configs[tab].custom_hitchance), "Double tap") and hitchance

        local hitchance_o = ui_get(configs[tab].hitchance)


        if hitchance_ovr and lib.is_key_down(keybinds.hitchance_key) then
            return hitchance_ovr
        elseif hitchance_ovr2 and lib.is_key_down(keybinds.hitchance_key2) then
            return hitchance_ovr2
        elseif hitchance_air and lib.is_in_air() then
            return hitchance_air
        elseif hitchance_dt and lib.is_double_tapping() then
            return hitchance_dt
        else
            return hitchance_o
        end
    end,

    damage = function(tab)
        local damage = ui_get(configs[tab].enable_damage)
        --{"On-key", "On-key 2", "Visible", "In-Air", "No Scope", "Double tap"}
        local damage_ovr = lib.contains(ui_get(configs[tab].custom_damage), "On-key") and damage
        local damage_ovr2 = lib.contains(ui_get(configs[tab].custom_damage), "On-key 2") and damage
        local damage_air = lib.contains(ui_get(configs[tab].custom_damage), "In-air") and damage
        local damage_nc = lib.contains(ui_get(configs[tab].custom_damage), "No Scope") and damage
        local damage_dt = lib.contains(ui_get(configs[tab].custom_damage), "Double tap") and damage
        local damage_o = ui_get(configs[tab].min_damage)

        if damage_ovr and lib.is_key_down(keybinds.damage_key) then
            return damage_ovr
        elseif damage_ovr2 and lib.is_key_down(keybinds.damage_key2) then
            return damage_ovr2
        elseif damage_air and lib.is_in_air() then
            return damage_air
        elseif damage_dt and lib.is_double_tapping() then
            return damage_dt
        elseif damage_nc and not lib.is_scoped() then
            return damage_nc
        else
            return damage_o
        end
    end
}

inti.main()
inti.config_1()

client.set_event_callback("paint", function()
    visible.config()
    visible.keybinds()
end)