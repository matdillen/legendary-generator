function onLoad()
    mmname = "Thanos"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMThanos()
    local gemfound = 0
    for _,o in pairs(playguids) do
        local playcontent = Global.Call('get_decks_and_cards_from_zone',o)
        if playcontent[1] then
            for _,k in pairs(playcontent) do
                if k.hasTag("Group:Infinity Gems") then
                    gemfound = gemfound + 1
                end
            end
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = gemfound,
        label = "-" .. gemfound*2,
        tooltip = "Thanos gets -2 for each Infinity Gem Artifact card controlled by any player.",
        f = 'updateMMThanos',
        f_owner = self})
end

function setupMM()
    updateMMThanos()
    function onObjectEnterZone(zone,object)
        if object.hasTag("Group:Infinity Gems") then
            updateMMThanos()
        end
    end
    function onObjectLeaveZone(zone,object)
        if object.hasTag("Group:Infinity Gems") then
            updateMMThanos()
        end
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toBound = {}
        for _,obj in pairs(hand) do
            if hasTag2(obj,"HC:") then
                table.insert(toBound,obj)
            end
        end
        if toBound[1] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = toBound,
                pos = getObjectFromGUID(strikeloc).getPosition(),
                label = "Bind",
                tooltip = "Thanos binds this soul. You're unlikely to ever see it back again."})
            broadcastToColor("Master Strike: A nongrey hero from your hand becomes a soul bound by Thanos.",o.color,o.color)
        end
    end
    return strikesresolved
end