function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID",
        "setupGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function nonTwist(params)
    local obj = params.obj
    
    local schemeParts = table.clone(getObjectFromGUID(setupGUID).Call('returnVar',"setupParts"))
    
    if obj.getName() == schemeParts[9] or (hasTag2(obj,"Group:") and hasTag2(obj,"Group:") == schemeParts[9]) then
        obj.setName("Xerogen Experiments")
        if obj.getDescription() == "" then
            obj.setDescription("ABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
        end
    end
    return 1
end

function fillHQ(params)
    Global.Call('bump',{obj = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1],y = 5})
    getObjectFromGUID(hqguids[params.index]).Call('click_draw_hero')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    broadcastToAll("Choose a Hero in the HQ that doesn't have a printed Power of 2 or more to be put on the bottom of the Hero Deck.")
    local heroes = {}
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Missing hero in the HQ?")
            return nil
        end
        heroes[i] = hero
        if hasTag2(hero,"Attack:") and hasTag2(hero,"Attack:") > 1 then
            heroes[i] = nil
        end
    end
    if next(heroes) then
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = heroes,
            pos = getObjectFromGUID(heroDeckZoneGUID).getPosition(),
            flip = true,
            label = "Tuck",
            tooltip = "Put this hero on the bottom of the hero deck.",
            trigger_function = 'fillHQ',
            args = "self",
            fsourceguid = self.guid})
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end