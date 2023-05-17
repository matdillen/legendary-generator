function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function mutateIntoDiscard(params)
    params.obj.setPositionSmooth(getObjectFromGUID(playerBoards[mutatingcolor]).positionToWorld(pos_discard))
    mutatingcolor = getNextColor(mutatingcolor)
    if mutatingcolor ~= Turns.turn_color then
        mutateFromHand(mutatingcolor)
    end 
end

function mutateIntoHand(params)
    --obj.flip()
    local obj = params.obj
    local mutatecontent = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
    local keepguids = {}
    for _,c in pairs(mutatecontent.getObjects()) do
        for _,tag in pairs(c.tags) do
            if tag:find("Cost:") and tonumber((tag:gsub("Cost:",""))) == hasTag2(obj,"Cost:") then
                table.insert(keepguids,c.guid)
                --local json = k.getJSON()
                --local id = json:match("\"CardID\": %d+"):gsub("\"CardID\": ","")
                --can't get json from a card inside a container (?)
                break
            end
        end
    end
    -- local temp = {}
    -- local keepguids2 = {}
    -- --doesn't work, guids are unique, cardids duplicated
    -- for _,c in pairs(keepguids) do
        -- if not temp[c] then
            -- keepguids2[#keepguids2+1] = c
            -- temp[c] = true
        -- end
    -- end
    if keepguids[1] and keepguids[2] then
        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = mutatingcolor,
            pile = mutatecontent,
            guids = keepguids,
            resolve_function = 'mutateIntoDiscard',
            tooltip = "Gain this card from the mutation pile.",
            label = "Gain",
            fsourceguid = self.guid})
    elseif keepguids[1] then
        mutatecontent.takeObject({position = getObjectFromGUID(playerBoards[mutatingcolor]).positionToWorld(pos_discard),
            smooth = true,
            guid = keepguids[1]})
        mutatingcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',mutatingcolor)
        if mutatingcolor ~= Turns.turn_color then
            mutateFromHand(mutatingcolor)
        end 
    else
        mutatingcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',mutatingcolor)
        if mutatingcolor ~= Turns.turn_color then
            mutateFromHand(mutatingcolor)
        end 
    end
end

function mutateFromHand(color)
    local hand = Player[color].getHandObjects()
    local handi = table.clone(hand)
    local iter = 0
    for i,obj in ipairs(handi) do
        if not hasTag2(obj,"HC:") then
            table.remove(hand,i-iter)
            iter = iter + 1
        end
    end
    if hand[1] then
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = mutatingcolor,
            hand = hand,
            pos = getObjectFromGUID(twistZoneGUID).getPosition(),
            label = "Mutate",
            tooltip = "Put this card into the mutation pile. You'll get a different card with the same cost back, if any.",
            trigger_function = 'mutateIntoHand',
            args = "self",
            fsourceguid = self.guid})
    else
        mutatingcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',mutatingcolor)
        if mutatingcolor ~= Turns.turn_color then
            mutateFromHand(mutatingcolor)
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 7 then
        broadcastToAll("Scheme Twist: Each player in turn does the following: Put a non-grey Hero from your hand into the Mutation Pile. Then you may put a different card name with the same cost from the Mutation Pile into your discard pile.")
        mutatingcolor = Turns.turn_color
        mutateFromHand(mutatingcolor)
    else
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end
