function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 5 or twistsresolved == 6 then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    elseif twistsresolved == 7 then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
    elseif twistsresolved == 8 then
        broadcastToAll("Cosmic Cube UNLEASHED!! Evil wins",{1,0,0})
    end
    return nil
end