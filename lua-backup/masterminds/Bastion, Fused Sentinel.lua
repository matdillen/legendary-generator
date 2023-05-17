function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "bystandersPileGUID",
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local mmZone = getObjectFromGUID(mmZoneGUID)
    local zoneguid = mmZone.Call('getNextMMLoc')
    local power = 3
    if epicness then
        power = 4
    end
    if zoneguid then
        getObjectFromGUID(bystandersPileGUID).takeObject({position = getObjectFromGUID(zoneguid).getPosition(),
            flip = true,
            smooth = true,
            callback_function = function(obj) 
                obj.addTag("Power:" .. power) 
                obj.addTag("Mastermind")
                obj.setName("Prime Sentinel " .. strikesresolved)
                mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 0})
            end})
        mmZone.Call('updateMasterminds',"Prime Sentinel " .. strikesresolved)
        mmZone.Call('updateMastermindsLocation',{"Prime Sentinel " .. strikesresolved,zoneguid})
    else
        broadcastToAll("No additional locations for masterminds found. Sort the extra Prime Sentinel out yourself.")
        return nil
    end
    return strikesresolved
end
