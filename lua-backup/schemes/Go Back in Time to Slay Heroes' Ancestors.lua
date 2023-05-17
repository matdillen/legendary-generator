function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function table.clone(org,key)
    if key then
        local new = {}
        for i,o in pairs(org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(org)}
    end
end

function purgeHero(params)
    local obj = params.obj
    local index = params.index
    
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hero.getName() == obj.getName() then
            getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
            getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
        end
    end
    getObjectFromGUID(hqguids[index]).Call('click_draw_hero')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    broadcastToAll("Scheme Twist: Purge a hero from the timestream!")
    local candidate = {}
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            table.insert(candidate,hero)
        else
            printToAll("Missing hero in HQ!!")
            return nil
        end
    end
    
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = candidate,
        pos = getObjectFromGUID(twistZoneGUID).getPosition(),
        label = "Purge",
        tooltip = "Purge this hero from the timestream!",
        trigger_function = 'purgeHero',
        args = "self",
        fsourceguid = self.guid})
    return twistsresolved
end