function onLoad()
    local guids1 = {
        "pushvillainsguid"
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

function dominate(params)
    params.obj.setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    strikeloc = params.strikeloc

    local strikezonecontent = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    if strikezonecontent[1] then
        getObjectFromGUID(pushvillainsguid).Call('koCard',strikezonecontent[1])
    end
    
    for _,o in pairs(Player.getPlayers()) do
        local discardguids = {}
        local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
        if discarded[1] and discarded[1].tag == "Deck" then
            for _,c in pairs(discarded[1].getObjects()) do
                for _,tag in pairs(c.tags) do
                    if tag:find("HC:") or tag == "Split" then
                        table.insert(discardguids,c.guid)
                        break
                    end
                end
            end
            if discardguids[1] and discardguids[2] then
                if epicness == true then
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                        pile = discarded[1],
                        guids = discardguids,
                        resolve_function = 'dominate',
                        args = "self",
                        fsourceguid = self.guid,
                        tooltip = "Shadow King dominates this hero.",
                        label = "Dom",
                        n = 2})
                    broadcastToColor("Master Strike: Shadow King dominates two non-grey Heroes from your discard pile.",o.color,o.color)
                else
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                        pile = discarded[1],
                        guids = discardguids,
                        resolve_function = 'dominate',
                        args = "self",
                        fsourceguid = self.guid,
                        tooltip = "Shadow King dominates this hero.",
                        label = "Dom"})
                    broadcastToColor("Master Strike: Shadow King dominates a non-grey hero from your discard pile.",o.color,o.color)
                end
            elseif discardguids[1] then
                discarded[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                    guid = discardguids[1],
                    smooth = true})
                broadcastToColor("Master Strike: Shadow King dominates the only non-grey hero from your discard pile.",o.color,o.color)
            end
        elseif discarded[1] then
            if hasTag2(discarded[1],"HC:",4) then
                dominate({obj = discarded[1]})
                broadcastToColor("Master Strike: Shadow King dominates the only non-grey hero from your discard pile.",o.color,o.color)
            end
        end
    end
    return strikesresolved
end
