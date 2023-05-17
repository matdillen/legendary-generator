function onLoad()   
    local guids1 = {
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 6 then
        getObjectFromGUID(setupGUID).Call('playHorror')
        broadcastToAll("Scheme Twist: Random Horror was played!")
    elseif twistsresolved == 6 then
        broadcastToAll("Scheme Twist: Evil Wins.")
    end
    return twistsresolved
end