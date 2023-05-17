function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function fillHQ()
    Global.Call('bump',{obj = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1],y = 5})
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            getObjectFromGUID(o).Call('click_draw_hero')
            break
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    broadcastToAll("Choose a Hero in the HQ that doesn't have a printed Power of 2 or more to be put on the bottom of the Hero Deck.")
    local heroes = {}
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and (not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < 2) then
            table.insert(heroes,hero)
        end
    end
    if heroes[1] then
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = heroes,
            pos = getObjectFromGUID(heroDeckZoneGUID).getPosition(),
            flip = true,
            label = "Tuck",
            tooltip = "Put this hero on the bottom of the hero deck.",
            trigger_function = 'fillHQ',
            fsourceguid = self.guid})
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end