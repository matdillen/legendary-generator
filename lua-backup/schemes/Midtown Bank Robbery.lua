function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local bankz = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[3])
    if bankz[1] then
        for _,o in pairs(bankz) do
            if o.hasTag("Villain") then
                getObjectFromGUID(pushvillainsguid).Call('addBystanders',city_zones_guids[3])
                getObjectFromGUID(pushvillainsguid).Call('addBystanders',city_zones_guids[3])
                break
            end
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains')
    return twistsresolved
end