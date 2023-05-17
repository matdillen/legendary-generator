function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "twistZoneGUID"
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

    for i,o in pairs(hqguids) do
        local cityzone = getObjectFromGUID(o)
        local bs = cityzone.Call('getBystander')
        if bs then
            bs.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
            broadcastToAll("Scheme Twist: Spy escaped from the HQ with sensitive information!",{1,0,0})
        end
        if i % 2 > 0 then
            local pos = cityzone.getPosition()
            pos.z = pos.z - 2
            pos.y = pos.y + 3
            local spystack = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
            if spystack[1] then
                if spystack[1].tag == "Deck" then
                    spystack[1].takeObject({position = pos,
                        flip=true})
                else
                    spystack[1].flip()
                    spystack[1].setPositionSmooth(pos)
                end
            else
                broadcastToAll("No more spies left.")
            end
        end
    end
    broadcastToAll("Scheme Twist: Three bystanders infiltrated the HQ!")
    return twistsresolved
end
