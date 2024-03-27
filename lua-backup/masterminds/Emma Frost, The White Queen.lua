function onLoad()
    strikesstacked = 0
    
    mmname = "Emma Frost, the White Queen"
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

function updateMMEmma()
    local playedcards = Global.Call('get_decks_and_cards_from_zone',playguids[Turns.turn_color])
    local power = 0
    local boost = 1
    if epicness then
        boost = 2
    end
    if playedcards[1] then
        for _,o in pairs(playedcards) do
            if o.hasTag("Starter") or o.getName() == "Sidekick" or o.getName() == "New Recruits" or (o.hasTag("Officer") and not hasTag2(o,"HC:")) then
                power = power + boost
            end
        end
    end
    local hand = Player[Turns.turn_color].getHandObjects()
    if hand[1] then
        for _,o in pairs(hand) do
            if o.hasTag("Starter") or o.getName() == "Sidekick" or o.getName() == "New Recruits" or (o.hasTag("Officer") and not hasTag2(o,"HC:")) then
                power = power + boost
            end
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = power,
        label = "+" .. power,
        tooltip = "Emma Frost gets +" .. boost .. " for each grey hero you have.",
        f = 'updateMMEmma',
        id = "greyherobonus",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    updateMMEmma()
    function onObjectEnterZone(zone,object)
        updateMMEmma()
    end
    function onObjectLeaveZone(zone,object)
        updateMMEmma()
    end
    function onPlayerTurn(player,previous_player)
        updateMMEmma()
    end
end

function resolveStrike(params)
    local cards = params.cards
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    if cards[1] then
        cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
        strikesstacked = strikesstacked + 1
    end
    local c = strikesstacked
    if epicness then
        c = strikesstacked + 1
    end
    for _,o in pairs(Player.getPlayers()) do
        getObjectFromGUID(pushvillainsguid).Call('wakingNightmare',{n = c,color = o.color})
    end
    broadcastToAll("Master Strike: Each player has " .. c .. " Waking Nightmares.")
    return nil
end