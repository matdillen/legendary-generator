function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    if twistsresolved < 6 then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local centurions = {}
            for _,obj in ipairs(hand) do
                if obj.hasTag("Officer") or obj.getName():find("Nova %(") then
                    table.insert(centurions,obj)
                end
            end
            if not centurions[1] then
                getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                    flip=true,
                    smooth=true})
                broadcastToAll("Scheme Twist: Officer KO'd from the officer stack.")
            else
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color, hand = centurions})
                broadcastToColor("Scheme Twist: Discard an Officer or a Nova hero. You gained a shard.",o.color,o.color)
                getObjectFromGUID(pushvillainsguid).Call('gainShard',o.color)
            end
        end
    elseif twistsresolved < 10 then
        broadcastToAll("Scheme Twist: Each player KO's an Officer from the Officer stack or an Officer/Nova hero from their hand or discard pile.")
    end
    return twistsresolved
end