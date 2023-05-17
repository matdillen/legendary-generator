function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "woundsDeckGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    for _,o in pairs(hqguids) do
        local cityzone = getObjectFromGUID(o)
        local bs = 1
        while bs do
            bs = cityzone.Call('getWound')
            if bs then
                getObjectFromGUID(pushvillainsguid).Call('koCard',bs)
            end
        end
        local pos = cityzone.getPosition()
        pos.z = pos.z - 2
        pos.y = pos.y + 3
        local spystack = getObjectFromGUID(woundsDeckGUID)
        if spystack then
            if spystack.tag == "Deck" then
                spystack.takeObject({position = pos,
                    flip=true})
                if spystack.remainder then
                    woundsDeckGUID = spystack.remainder.guid
                end
            else
                spystack.flip()
                spystack.setPositionSmooth(pos)
            end
        else
            broadcastToAll("Wounds stack ran out.")
        end
    end
    broadcastToAll("Scheme Twist: Wounds were KO'd from the HQ and new ones added!")
    return twistsresolved
end
