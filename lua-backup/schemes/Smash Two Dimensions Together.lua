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
    
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    broadcastToAll("Scheme Twist: Two cards are played from the villain deck!")
    return twistsresolved
end