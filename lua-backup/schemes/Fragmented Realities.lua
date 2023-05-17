function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    
    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    local villain_deck_zone = nil
    for _,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
        local zone = getObjectFromGUID(o)
        if zone.hasTag(Turns.turn_color) then
            villain_deck_zone = o
            break
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,vildeckguid=villain_deck_zone})
    return nil
end