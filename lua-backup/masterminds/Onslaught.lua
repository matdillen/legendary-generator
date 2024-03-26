function onLoad()
    mmname = "Onslaught"
    
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards"
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

function updateMMOnslaught()
    local bs = Global.Call('get_decks_and_cards_from_zone',self.guid)
    local boost = 0
    if bs[1] then
        boost = math.abs(bs[1].getQuantity())
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = "Onslaught gets +1 for each hero he dominates.",
        f = 'updateMMOnslaught',
        f_owner = self})
end

function setupMM()
    for _,o in pairs(Player.getPlayers()) do
        getObjectFromGUID(playerBoards[o.color]).Call('onslaughtpain')
    end
    broadcastToAll("Hand size reduced by 1 because of Onslaught. Good luck! You're going to need it.")

    function onObjectEnterZone(zone,object)
        Wait.time(updateMMOnslaught,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMOnslaught,0.1)
    end
end

function mmDefeated()
    for _,o in pairs(Player.getPlayers()) do
        getObjectFromGUID(playerBoards[o.color]).Call('onslaughtpain',true)
    end
    broadcastToAll("Onslaught defeated! Hand size decrease was relieved!")
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    local dominated = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    if dominated[1] then
        getObjectFromGUID(pushvillainsguid).Call('koCard',dominated[1])
    end
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local toKO = {}
        for _,obj in pairs(hand) do
            if hasTag2(obj,"HC:") then
                table.insert(toKO,obj)
            end
        end
        if toKO[1] then
            if epicness then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toKO,
                    n = 2,
                    pos = getObjectFromGUID(strikeloc).getPosition(),
                    label = "Dominate",
                    tooltip = "Onslaught dominates this hero."})
                broadcastToColor("Master Strike: Two nongrey heroes from your hand become dominated by Onslaught.",o.color,o.color)
            else
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toKO,
                    pos = getObjectFromGUID(strikeloc).getPosition(),
                    label = "Dominate",
                    tooltip = "Onslaught dominates this hero."})
                broadcastToColor("Master Strike: A nongrey hero from your hand becomes dominated by Onslaught.",o.color,o.color)
            end
        end
    end
    if epicness then
        getObjectFromGUID(setupGUID).Call('playHorror')
    end
    return strikesresolved
end