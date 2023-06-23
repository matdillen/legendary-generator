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

    local guids3 = {
        "discardguids",
        "resourceguids"
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

function buyEffect(params)
    if params.obj.Call('getWound') then
        getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = params.color,
            choices = {["pay"] = "*1",
                [self.guid] = "0"},
            fsourceguid = self.guid,
            resolve_function = "buyPlague",
            choicecolors = {["pay"] = "Yellow",
                [self.guid] = "Red"}})
    end
end

function buyPlague(params)
    if params.id == "pay" then
        local val = getObjectFromGUID(resourceguids[params.color]).Call('returnVal')
        if val < 1 then
            broadcastToColor("You don't have enough recruit to return this wound!", params.color, params.color)
            buyEffect({obj = getObjectFromGUID(params.id),
                color = params.color})
        else
            getObjectFromGUID(resourceguids[params.color]).Call('addValue',-1)
        end
    else
        local wound = getObjectFromGUID(params.id).Call('getWound')
        local pos = getObjectFromGUID(discardguids[params.color]).getPosition()
        pos.y = pos.y + 2
        wound.setPositionSmooth(pos)
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