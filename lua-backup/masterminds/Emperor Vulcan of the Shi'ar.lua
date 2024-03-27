function onLoad()
    mmname = "Emperor Vulcan of the Shi'ar"
    
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function updateMMEmperorVulcan()
    local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
    local power = 0
    if thronesfavor == "mmEmperor Vulcan of the Shi'ar" then
        power = 3
        if epicness then
            power = 5
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = power,
        label = "+" .. power,
        tooltip = "Emperor Vulcan gets +" .. power .. " if he has the Throne's Favor.",
        f = 'updateMMEmperorVulcan',
        id = "vulcanthronesfavor",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    if epicness then
        getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
            player_clicker_color = "mmEmperor Vulcan of the Shi'ar"})
        updateMMEmperorVulcan()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
    if epicness then
        broadcastToAll("Master Strike: Each player without the Throne's Favor gains a wound to the top of their deck.")
    else
        broadcastToAll("Master Strike: Each player without the Throne's Favor gains a wound.")
    end
    for _,o in pairs(Player.getPlayers()) do
        if o.color ~= thronesfavor then
            if epicness then
                getObjectFromGUID(pushvillainsguid).Call('click_get_wound2',{color = o.color,top = true})
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        end
    end
    getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
        player_clicker_color = "mmEmperor Vulcan of the Shi'ar",
        notspend = true})
    updateMMEmperorVulcan()
    return strikesresolved
end