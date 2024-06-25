function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "twistZoneGUID",
        "bystandersPileGUID"
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

    local guids3 = {
        "vpileguids"
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

function setupSpecial(params)
    log("21 bystanders next to scheme")
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    local twistPile = getObjectFromGUID(twistZoneGUID)
    for i=1,21 do
        bsPile.takeObject({position=twistPile.getPosition(),
            flip=false,smooth=false})
    end
end

function buyEffect(params)
    local bs = params.obj.Call('getBystander')
    if bs then
        local vpos = getObjectFromGUID(vpileguids[params.color]).getPosition()
        vpos.y = vpos.y + 2
        bs.setPositionSmooth(vpos)
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Bystanders escaped: __/12.",
                ["zoneguid"] = escape_zone_guid}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Bystander"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Bystander") then
            counter = counter + 1
        end
        return counter
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