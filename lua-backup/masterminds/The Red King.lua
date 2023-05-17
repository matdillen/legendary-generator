function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        local towound = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
        if towound[1] then
            for _,o in pairs(towound) do
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                broadcastToAll("Master Strike: Player " .. o.color .. " had no silver heroes and was wounded.")
            end
        end
    elseif transformedPV == false then
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    end
    return strikesresolved 
end
