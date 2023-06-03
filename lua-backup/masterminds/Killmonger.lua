function onLoad()
    mmname = "Killmonger"
    
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "discardguids"
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local mmname = params.mmname
    local epicness = params.epicness
    local mmloc = params.mmloc
    local strikeloc = params.strikeloc
    
    local woundscount = 0
    local wounds = Global.Call('get_decks_and_cards_from_zone',self.guid)
    if wounds[1] then
        woundscount = math.abs(wounds[1].getQuantity())
    end
    if not epicness then
        local mongered = {}
        for _,o in pairs(Player.getPlayers()) do
            local outwit = getObjectFromGUID(pushvillainsguid).Call('outwitPlayer',{color = o.color,
                n = 4,
                what = "HC:"})
            if not outwit then
                table.insert(mongered,o)
            end
        end
        if #mongered > woundscount then
            local colorseq = {}
            local col = Turns.turn_color
            for i = 1,#Player.getPlayers() do
                table.insert(colorseq,Player[col])
                col = getObjectFromGUID(pushvillainsguid).Call('getNextColor',col)
                if col == Turns.turn_color then
                    break
                end
            end
            for _,o in pairs(colorseq) do
                wounds[1].takeObject({position = getObjectFromGUID(discardguids[o.color]).getPosition(),
                    smooth = false})
                if wounds[1].remainder == true then
                    wounds[1].remainder.setPosition(getObjectFromGUID(discardguids[colorseq[#colorseq].color]).getPosition())
                    break
                end
            end
            for i = #mongered-woundscount,#mongered do
                local hand = mongered[i].getHandObjects()
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = mongered[i].color,
                    hand = hand,
                    n = #hand - 4})
            end
        else
            for _,o in pairs(mongered) do
                wounds[1].takeObject({position = getObjectFromGUID(discardguids[o.color]).getPosition(),
                    smooth = false})
                if wounds[1].remainder == true and #mongered == woundscount then
                    wounds[1].remainder.setPosition(getObjectFromGUID(discardguids[mongered[#mongered].color]).getPosition())
                    break
                end
            end
        end
    else
        local players = Player.getPlayers()
        for _,o in pairs(players) do
            wounds[1].takeObject({position = getObjectFromGUID(discardguids[o.color]).getPosition(),
                smooth = false})
            if wounds[1].remainder == true and #players == woundscount then
                wounds[1].remainder.setPosition(getObjectFromGUID(discardguids[players[#players].color]).getPosition())
                break
            end
        end
    end
    return strikesresolved
end