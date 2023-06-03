function onLoad()
    mmname = "Illuminati, Secret Society"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    mmZone = getObjectFromGUID(mmZoneGUID)
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

function setupMM()
    updateMMIlluminatiSS()
    
    function onObjectEnterZone(zone,object)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed and transformed == false then
            updateMMIlluminatiSS()
        end
    end
    
    function onObjectLeaveZone(zone,object)
        local transformed = mmZone.Call('returnTransformed',mmname)
        if transformed and transformed == false then
            updateMMIlluminatiSS()
        end
    end
end

function updateMMIlluminatiSS()
    local transformed = mmZone.Call('returnTransformed',mmname)
    if transformed == nil then
        return nil
    end
    local boost = 0
    local tooltip = "The Illuminati no longer get +4 unless you Outwit them."
    if transformed == false then
        local notes = getNotes()
        setNotes(notes:gsub("\r\n\r\nWhenever a card effect causes a player to draw any number of cards, that player must then also discard a card.",""))
        boost = 4
        tooltip = "The Illuminati get +4 unless you Outwit them."
        if getObjectFromGUID(pushvillainsguid).Call('outwitPlayer',{color = Turns.turn_color}) then
            boost = 0
        end
    elseif transformed == true then
        local notes = getNotes()
        setNotes(notes .. "\r\n\r\nWhenever a card effect causes a player to draw any number of cards, that player must then also discard a card.")
    end
    mmZone.Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = tooltip,
        f = 'updateMMIlluminatiSS',
        f_owner = self})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local transformedPV = mmZone.Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local toDiscard = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 1 and hasTag2(obj,"Cost:") < 4 then
                    table.insert(toDiscard,obj)
                end
            end
            if hand[1] then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toDiscard,
                    n = 2})
            end
        end
        broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 1 and 4.")
    elseif transformedPV == false then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local toDiscard = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 5 and hasTag2(obj,"Cost:") < 8 then
                    table.insert(toDiscard,obj)
                end
            end
            if hand[1] then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = toDiscard,
                    n = 2})
            end
        end
        broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 5 and 8.")
    end
    return strikesresolved
end