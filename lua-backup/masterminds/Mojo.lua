function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_discard"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city
    local epicness = params.epicness
    local strikeloc = params.strikeloc
    
    getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = strikeloc,
        face = false,
        posabsolute = true})
    if epicness then
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,p in pairs(citycontent) do
                    if p.hasTag("Group:Mojoverse") then
                        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = o,face = false})
                        break
                    end
                end
            end
        end
    end
    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Silver")
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if epicness and #hand > 4 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = #hand-4})
            broadcastToColor("Master Strike: Discard down to 4 cards.",o.color,o.color)
        else
            if #hand > 0 then
                local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
                hand[math.random(#hand)].setPosition(posdiscard)
            end
            broadcastToColor("Master Strike: Discard a card at random.",o.color,o.color)
        end
    end
    return strikesresolved
end
