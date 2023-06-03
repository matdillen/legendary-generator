function onLoad()
    mmname = "Misty Knight"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
end

function table.clone(org,key)
    if key then
        local new = {}
        for i,o in pairs(org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(org)}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function setupMM()
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = 1,
        label = "*",
        tooltip="Misty Knight can be fought using Recruit as well as Attack.",
        f = 'updatePower',
        id = "bribe"})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local recruitcount = 0
        for _,h in pairs(hand) do
            if hasTag2(h,"Recruit:") then
                recruitcount = recruitcount + 1
            end
        end
        local play = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
        for _,h in pairs(play) do
            if hasTag2(h,"Recruit:") then
                recruitcount = recruitcount + 1
            end
        end
        if recruitcount < 4 then
             getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        end
    end
    broadcastToAll("Master Strike: Each player reveals 4 cards with Recruit icons or gains a Wound.")
    return strikesresolved
end