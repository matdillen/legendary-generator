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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1]
    if herodeck then
        Global.Call('bump',herodeck)
    end
    local costs = table.clone("herocosts",3)
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero and (not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < 2) then
            hero.flip()
            costs[hasTag2(hero,"Cost:")] = costs[hasTag2(hero,"Cost:")] + 1
            getObjectFromGUID(o).Call('tuckHero')
        end
    end
    broadcastToAll("Master Strike! Weak heroes in HQ replaced with new ones. Discard cards with the same cost as the heroes replaced in the HQ (Automatically, unless there are ties).")
    getObjectFromGUID(pushvillainsguid).Call('demolish',{altsource = costs})
    return strikesresolved
end
