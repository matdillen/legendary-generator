function onLoad()   
    villaindeckcount = 0
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "vpileguids",
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
    return {["villdeckc"] = 4}
end

function moveToVilDeck(params)
    params.obj.flip()
    params.obj.setPosition(getObjectFromGUID(villainDeckZoneGUID).getPosition())
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    local villain_deck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
    if villain_deck[1] then
        villaindeckcount = math.abs(villain_deck[1].getQuantity())
    else
        villaindeckcount = 0
    end
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
            local tacticFound = {}
            if vpilecontent[1] then
                if vpilecontent[1].getQuantity() > 1  then
                    local vpileCards = vpilecontent[1].getObjects()
                    for j = 1, #vpileCards do
                        for _,k in pairs(vpileCards[j].tags) do
                            if k:find("Tactic:") then
                                table.insert(tacticFound,vpileCards[j].guid)
                                break
                            end
                        end
                    end
                    if tacticFound[1] and not tacticFound[2] then
                        vpilecontent[1].takeObject({position = getObjectFromGUID(villainDeckZoneGUID).getPosition(),
                            flip = true,
                            guid = tacticFound[1]})
                        villaindeckcount = villaindeckcount + 1
                    elseif tacticFound[1] then
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                            pile = vpilecontent[1],
                            guids = tacticFound,
                            resolve_function = 'moveToVilDeck',
                            tooltip = "Shuffle this tactic back into the Villain deck.",
                            label = "Shuffle",
                            fsourceguid = self.guid})
                        villaindeckcount = villaindeckcount + 1
                    end
                else
                    if hasTag2(vpilecontent[1],"Tactic:",7) then
                        vpilecontent[1].flip()
                        vpilecontent[1].setPositionSmooth(getObjectFromGUID(villainDeckZoneGUID).getPosition())
                        table.insert(tacticFound,vpilecontent[1].guid)
                        villaindeckcount = villaindeckcount + 1
                    end
                end
                if tacticFound[1] then
                    local playerBoard = getObjectFromGUID(playerBoards[i])
                    playerBoard.Call('click_draw_card')
                    Wait.time(function() playerBoard.Call('click_draw_card') end,1)
                    broadcastToAll(playerBoards[i] .. " player's tactic was shuffled back in the Villain deck and so they drew two cards.")
                end
            end
        end
    end
    local tacticsAdded = function()
        local villain_deck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
        if villain_deck[1] and math.abs(villain_deck[1].getQuantity()) == villaindeckcount then
            return true
        else
            return false
        end
    end
    local tacticsFollowup = function()
        local villain_deck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
        if villain_deck[1] then
            villain_deck[1].randomize()
            local pos = getObjectFromGUID("f3c7e3").getPosition()
            pos.y = pos.y + 3
            villain_deck[1].takeObject({position = pos,
                flip=true})
            pos = getObjectFromGUID("8280ca").getPosition()
            pos.y = pos.y + 3
            villain_deck[1].takeObject({position = pos,
                flip=true})
            broadcastToAll("Scheme Twist: A tactic from these two cards enters the city. Put the rest back on top or bottom of the villain deck.")
        end
    end
    Wait.condition(tacticsFollowup,tacticsAdded)
end
