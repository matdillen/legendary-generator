function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local strikeloc = params.strikeloc

    local costs = {}
    local strikeZone = getObjectFromGUID(strikeloc)
    for i,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then
            broadcastToAll("Hero not found in HQ. Abort script")
            return nil
        end
        costs[i] = hasTag2(hero,"Cost:") or 0
    end
    local costs2 = table.sort(table.clone(costs))
    local maxv = {costs2[#costs2],costs2[#costs2-1]}
    broadcastToAll("Master Strike: Choose the two highest-cost Allies in the Lair. Stack them next to Professor X as \"Telepathic Pawns.\".")
    if costs2[#costs2-2] < maxv[2] then
        for i,o in pairs(costs) do
            if o >= maxv[2] then
                local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
                hero.setPositionSmooth(strikeZone.getPosition())
                getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
            end
        end
    elseif maxv[1] > maxv[2] then
        local otherguids = {}
        for i,o in pairs(costs) do
            local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
            if o == maxv[1] then
                hero.setPositionSmooth(strikeZone.getPosition())
                getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
            elseif o == maxv[2] then
                table.insert(otherguids,hero)
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = otherguids,
            pos = strikeZone.getPosition(),
            label = "Dom",
            tooltip = "Professor X dominates this hero as a telepathic pawn."})
    elseif maxv[1] == maxv[2] then
        local otherguids = {}
        for i,o in pairs(costs) do
            local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
            if o == maxv[1] then
                table.insert(otherguids,hero)
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
            hand = otherguids,
            n = 2,
            pos = strikeZone.getPosition(),
            label = "Dom",
            tooltip = "Professor X dominates this hero as a telepathic pawn."})
    end
    return strikesresolved
end
