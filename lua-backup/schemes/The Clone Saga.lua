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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local cardids = {}
        local clonecheck = false
        for _,k in pairs(hand) do
            if hasTag2(k,"HC:",4) then
                local json = k.getJSON()
                local id = json:match("\"CardID\": %d+"):gsub("\"CardID\": ","")
                --log(id)
                for _,l in pairs(cardids) do
                    if id == l then
                        clonecheck = true
                        break
                    end
                end
                if clonecheck == true then
                    break
                else
                    table.insert(cardids,id)
                end
            end
        end
        if clonecheck == false and #hand > 3 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color, n = #hand-3})
            broadcastToColor("Scheme Twist: Discard down to 3 cards!",o.color,o.color)
        end
    end
    return twistsresolved
end
