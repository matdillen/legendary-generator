function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 9 then
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID and getObjectFromGUID(mmZoneGUID).Call('mmActive',i) then
                getObjectFromGUID(pushvillainsguid).Call('addNewLurkingMM',i)
                break
            end
        end
    elseif twistsresolved == 9 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end
