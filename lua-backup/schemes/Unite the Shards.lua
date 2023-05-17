function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local cards = params.cards
    
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    getObjectFromGUID(pushvillainsguid).Call('gainShard2',{zoneGUID = mmZoneGUID,
        n = twistsstacked})
    broadcastToAll("Scheme Twist: The Mastermind gains " .. twistsstacked .. " shards.")
    return nil
end
