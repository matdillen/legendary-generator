function onLoad()
    mmname = "Poison Thanos"
    
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMPoisonThanos()
    local poisoned = Global.Call('get_decks_and_cards_from_zone',self.guid)
    local poisoncount = 0
    if poisoned[1] and poisoned[1].tag == "Deck" then
        local costs = table.clone(Global.Call('returnVar',"herocosts"))
        for _,o in pairs(poisoned[1].getObjects()) do
            for _,k in pairs(o.tags) do
                if k:find("Cost:") then
                    costs[tonumber(k:match("%d+"))] = costs[tonumber(k:match("%d+"))] + 1
                    break
                end
            end
        end
        for _,o in pairs(costs) do
            if o > 0 then
                poisoncount = poisoncount + 1
            end
        end
    elseif poisoned[1] then
        poisoncount = 1
    end
    local boost = 1
    if epicness then
        boost = 2
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = poisoncount,
        label = "+" .. poisoncount*boost,
        tooltip = "Poison Thanos gets + " .. boost .. " for each different cost among cards in his Poisoned Souls pile.",
        f = 'updateMMPoisonThanos',
        id = "poisonedsouls",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMPoisonThanos,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMPoisonThanos,0.1)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local handi = table.clone(hand)
        local iter = 0
        for i,obj in ipairs(handi) do
            if not hasTag2(obj,"HC:",4) then
                table.remove(hand,i-iter)
                iter = iter + 1
            end
        end
        if hand[1] then
            if epicness then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = hand,
                    n = #hand/2 + 0.5*(#hand % 2),
                    pos = getObjectFromGUID(strikeloc).getPosition()})
                broadcastToColor("Master Strike: " .. #hand/2 + 0.5*(#hand % 2) .. " nongrey heroes from your hand become souls poisoned by Thanos.",o.color,o.color)
            else
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = hand,
                    pos = getObjectFromGUID(strikeloc).getPosition()})
                broadcastToColor("Master Strike: A nongrey hero from your hand becomes a soul poisoned by Thanos.",o.color,o.color)
            end
        end
    end
    return strikesresolved
end