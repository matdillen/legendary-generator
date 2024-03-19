function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "villainDeckZoneGUID",
        "setupGUID",
        "heroPileGUID"
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

function setupSpecial(params)
    log("Jean Grey in villain deck.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Jean Grey (DC)",
        pileGUID = heroPileGUID,
        destGUID = villainDeckZoneGUID})
    return {["villdeckc"] = 14}
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.getName() == "Jean Grey (DC)" then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,
            label = hasTag2(obj,"Cost:"),
            tooltip = "Jean Grey heroes are villains with power equal to their cost. Gain them if you fight them."})
        obj.addTag("Villain")
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local kopilecontent = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
    local vildeckZone = getObjectFromGUID(villainDeckZoneGUID)
    local jeanfound = 0
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
    local vildeckcount = 0
    if vildeck[1] then
        vildeckcount = vildeck[1].getQuantity()
    end
    broadcastToAll("Scheme Twist: All Jean Grey hero cards in discard piles, hand or the KO pile are shuffled back into the Villain deck.")
    if kopilecontent[1] and kopilecontent[1].tag == "Deck" then
        for _,o in pairs(kopilecontent[1].getObjects()) do
            if o.name == "Jean Grey (DC)" then
                kopilecontent[1].takeObject({position = vildeckZone.getPosition(),
                    guid = o.guid,
                    flip=true})
                jeanfound = jeanfound + 1
                if kopilecontent[1].remainder then
                    if kopilecontent[1].remainder.getName() == "Jean Grey (DC)" then
                        kopilecontent[1].flip()
                        kopilecontent[1].setPositionSmooth(vildeckZone.getPosition())
                        jeanfound = jeanfound + 1
                    end
                    break
                end
            end
        end
    elseif kopilecontent[1] then
        if kopilecontent[1].getName() == "Jean Grey (DC)" then
            kopilecontent[1].flip()
            kopilecontent[1].setPositionSmooth(vildeckZone.getPosition())
            jeanfound = jeanfound + 1
        end
    end
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        if hand[1] then
            for _,h in pairs(hand) do
                if h.getName() == "Jean Grey (DC)" then
                    h.flip()
                    h.setPosition(vildeckZone.getPosition())
                    jeanfound = jeanfound + 1
                end
            end
        end
    end
    for i,o in pairs(playerBoards) do
        if Player[i].seated == true then
            local discard = getObjectFromGUID(o).Call('returnDiscardPile')
            if discard[1] and discard[1].tag == "Deck" then
                for _,o in pairs(discard[1].getObjects()) do
                    if o.name == "Jean Grey (DC)" then
                        discard[1].takeObject({position = vildeckZone.getPosition(),
                            guid = o.guid,
                            flip=true})
                        jeanfound = jeanfound + 1
                        if discard[1].remainder then
                            if discard[1].remainder.getName() == "Jean Grey (DC)" then
                                discard[1].flip()
                                discard[1].setPositionSmooth(vildeckZone.getPosition())
                                jeanfound = jeanfound + 1
                            end
                            break
                        end
                    end
                end
            elseif discard[1] then
                if discard[1].getName() == "Jean Grey (DC)" then
                    discard[1].flip()
                    discard[1].setPositionSmooth(vildeckZone.getPosition())
                    jeanfound = jeanfound + 1
                end
            end
        end
    end
    local jeangreyadded = function()
        local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
        if vildeck[1] and vildeck[1].getQuantity() == vildeckcount + jeanfound then
            return true
        else
            return false
        end
    end
    local shufflejean = function()
        local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
        vildeck[1].randomize()
    end
    if jeanfound > 0 then
        Wait.condition(shufflejean,jeangreyadded)
    end
    return twistsresolved
end