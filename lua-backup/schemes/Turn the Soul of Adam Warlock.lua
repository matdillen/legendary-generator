function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local adam = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])
    local setUnPure = function(obj)
        obj.addTag("Unpure")
    end
    if adam[1] then
        adam[1].takeObject({position = getObjectFromGUID(pushvillainsguid).getPosition(),
            callback_function = setUnPure})
        broadcastToAll("Scheme Twist: Purify Adam or his soul becomes more corrupted!")
    else
        broadcastToAll("Adam not found?")
    end
    return twistsresolved
end
