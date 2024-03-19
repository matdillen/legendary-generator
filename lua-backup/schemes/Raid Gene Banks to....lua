function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function setupSpecial()
    local mmZone = getObjectFromGUID(mmZoneGUID)
    mmZone.Call('lockTopZone',topBoardGUIDs[1])
    mmZone.Call('lockTopZone',topBoardGUIDs[2])
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    if twistsresolved < 4 then
        local bankcontent = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[3])
        for _,c in pairs(bankcontent) do
            if c.hasTag("Villain") then
                cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
                return nil
            end
        end
        broadcastToColor("Move a villain to the bank, if any!",Turns.turn_color,Turns.turn_color)
    elseif twistsresolved == 4 then
        getObjectFromGUID(pushvillainsguid).Call('unveilScheme',self)
        return nil
    end
    return twistsresolved
end