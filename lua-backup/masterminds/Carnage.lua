function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function carnageWounds(params)
    local obj = params.obj
    local color = params.color
    
    local name = obj.getName()
    if name == "" then
        name = "an unnamed card"
    end
    broadcastToColor("Carnage feasted on " .. name .. "!",color,color)
    if not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0 then
        getObjectFromGUID(pushvillainsguid).Call('getWound',color)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    broadcastToAll("Master Strike: Carnage feasts on each player!")
    for _,o in pairs(Player.getPlayers()) do
        getObjectFromGUID(pushvillainsguid).Call('feast',{color = o.color,
            triggerf = 'carnageWounds',
            fsourceguid = self.guid})
    end
    return strikesresolved
end