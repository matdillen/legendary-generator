function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "bystandersPileGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    prime_sentinel_lua = [[
        local guids1 = {
            "pushvillainsguid",
            "kopile_guid"
            }
            
        for _,o in pairs(guids1) do
            _G[o] = Global.Call('returnVar',o)
        end
        function bonusInCity(params)
            local kopilecontent = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
            local strikes = 0
            for _,o in pairs(kopilecontent.getObjects()) do
                if o.name == "Masterstrike" then
                    strikes = strikes + 1
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = getObjectFromGUID(sentinelzoneguid),
                label = "+" .. strikes,
                tooltip = "Sentinels get +1 for each Master Strike in the KO pile.",
                zoneguid = params.zoneguid,
                id = "bastionsentinel"})
        end
    ]]
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
    local mmname = "Bastion, Fused Sentinel"
    if epicness then
        power = 4
        mmname = "Bastion, Fused Sentinel - epic"
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
        local strikeloc = mmZone.Call('getStrikeloc',"Prime Sentinel " .. strikesresolved)
        prime_sentinel_lua = "sentinelzoneguid = \"" .. zoneguid .. "\"\r\n" .. prime_sentinel_lua
        getObjectFromGUID(strikeloc).setLuaScript(prime_sentinel_lua)
        getObjectFromGUID(strikeloc).reload()
    else
        broadcastToAll("No additional locations for masterminds found. Sort the extra Prime Sentinel out yourself.")
        return nil
    end
    return strikesresolved
end
