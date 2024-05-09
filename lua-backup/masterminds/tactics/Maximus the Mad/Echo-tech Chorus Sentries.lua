function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
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

function hasTag2(obj,tag,index,val)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index,val = val})
end

function tacticEffect(params)
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toKO = {}
        for _,obj in pairs(hand) do
            if hasTag2(obj,"HC:",nil,"Silver") or hasTag2(obj,"Team:",nil,"Inhumans") then
                table.insert(toKO,obj)
            end
        end
        local play = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
        if play[1] then
            for _,obj in pairs(play) do
                if hasTag2(obj,"HC:",nil,"Silver") or hasTag2(obj,"Team:",nil,"Inhumans") then
                    table.insert(toKO,obj)
                end
            end
        end
        if #toKO == 0 then
            getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
        else
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = toKO,
                pos = getObjectFromGUID(kopile_guid).getPosition(),
                label = "KO",
                tooltip = "KO this card"})
        end
    end
    broadcastToAll("Maximus Fight effect: Maximus deploys the Echo-Tech Chorus Sentries. Each player KOs a silver or Inhumans hero or gains a wound.")
end