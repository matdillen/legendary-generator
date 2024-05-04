function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "kopile_guid"
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

function purge(obj)
    local purgedheroes = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    local hqguid = nil
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hero.guid == obj.guid then
            hqguid = o
            break
        end
    end
    if purgedheroes[1] then
        local pos = getObjectFromGUID(kopile_guid).getPosition()
        pos.y = pos.y + 2
        if purgedheroes[1].tag == "Deck" then
            for _,o in pairs(purgedheroes[1].getObjects()) do
                if o.name == obj.getName() then
                    broadcastToAll("Purged hero " .. obj.getName() .. " KO'd from HQ")
                    obj.setPositionSmooth(pos)
                    if hqguid then
                        getObjectFromGUID(hqguid).Call('click_draw_hero')
                    end
                    break
                end
            end
        else
            if purgedheroes[1].getName() == obj.getName() then
                broadcastToAll("Purged hero " .. obj.getName() .. " KO'd from HQ")
                obj.setPositionSmooth(pos)
                if hqguid then
                    getObjectFromGUID(hqguid).Call('click_draw_hero')
                end
            end
        end
    end
end

function drawHeroSpecial(params)
    return {["callbackf"] = 'purge'}
end

function purgeHero(params)
    local obj = params.obj
    local index = params.index
    
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and hero.getName() == obj.getName() and i ~= index then
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