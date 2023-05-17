function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city

    local subescaped = false
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,p in pairs(citycontent) do
                if hasTag2(p,"Group:",7) and hasTag2(p,"Group:",7) == "Subterranea" then
                    subescaped = true
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycontent,
                        targetZone = getObjectFromGUID(escape_zone_guid),
                        enterscity = 0})
                    break
                end
            end
        end
    end
    if subescaped == true then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    end
    broadcastToAll("Master Strike: All Subterranea Villains in the city escape. If any Villains escaped this way, each player gains a Wound.")
    return strikesresolved
end
