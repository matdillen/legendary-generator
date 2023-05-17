function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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
    getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmEmperor Vulcan of the Shi'ar",true})
    getObjectFromGUID(mmZoneGUID).Call('updateMMEmperorVulcan')
    return strikesresolved
end
