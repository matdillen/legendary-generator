function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID",
        "kopile_guid",
        "setupGUID",
        "heroPileGUID",
        "heroDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end

    local guids3 = {
        "playerBoards"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
end

function table.clone(val)
    local new = {}
    for i,o in pairs(val) do
        new[i] = o
    end
    return new
end

function novaDist(obj)
    log("Moving additional cards to starter decks.")
    local novaguids = {}
    for _,o in pairs(obj.getObjects()) do
        for _,p in pairs(o.tags) do
            if p == "Cost:2" then
                table.insert(novaguids,o.guid)
            end
        end
    end
    local wndPile = getObjectFromGUID(woundsDeckGUID)
    local soPile = getObjectFromGUID(officerDeckGUID)
    for i,o in pairs(Player.getPlayers()) do
        local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
        wndPile.takeObject({position=playerdeck.getPosition(),
            flip=false,
            smooth=false})
        wndPile.takeObject({position=playerdeck.getPosition(),
            flip=false,
            smooth=false})    
        soPile.takeObject({position=playerdeck.getPosition(),
            flip=false,
            smooth=false})
        obj.takeObject({position=playerdeck.getPosition(),
            flip=true,
            smooth=false,
            guid=novaguids[i]})
    end
end

function setupSpecial(params)
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = params.setupParts[9],
        pileGUID = heroPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "novaDist",
        fsourceguid = self.guid})
    local novaMoved = function()
        local novaloc = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])
        local q = 14 - #Player.getPlayers()
        if novaloc[1] and novaloc[1].getQuantity() == q then
            return true
        else
            return false
        end
    end
    local novaShuffle = function()
        log("Moving remaining Nova cards to hero deck.")
        local novaloc = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])
        local q = 14 - #Player.getPlayers()
        local heroZone = getObjectFromGUID(heroDeckZoneGUID)
        for i=1,q do
            novaloc[1].takeObject({position=heroZone.getPosition(),
                flip=true,smooth=false})
        end
    end
    Wait.condition(novaShuffle,novaMoved)
end

function setupCounter(init)
    if init then
        local playercounter = 5*#Player.getPlayers()
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd Nova Centurions: __/" .. playercounter .. "."}
    else 
        local escaped = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if escaped[1] then
            local counter = 0
            for _,o in pairs(escaped) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "Officer"})
                    if escapees then
                        counter = counter + #escapees
                    end
                    for _,o2 in pairs(o.getObjects()) do
                        if o2.name:find("Nova") then
                            for _,t in pairs(o2.tags) do
                                if t == "Hero" or t:find("HC:") then
                                    counter = counter + 1
                                    break
                                end
                            end
                        end
                    end
                elseif o.hasTag("Officer") or (o.hasTag("Hero") and o.getName():find("Nova")) then
                    counter = counter + 1
                end
            end
            return counter
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    if twistsresolved < 6 then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local centurions = {}
            for _,obj in ipairs(hand) do
                if obj.hasTag("Officer") or obj.getName():find("Nova %(") then
                    table.insert(centurions,obj)
                end
            end
            if not centurions[1] then
                getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                    flip=true,
                    smooth=true})
                broadcastToAll("Scheme Twist: Officer KO'd from the officer stack.")
            else
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color, hand = centurions})
                broadcastToColor("Scheme Twist: Discard an Officer or a Nova hero. You gained a shard.",o.color,o.color)
                getObjectFromGUID(pushvillainsguid).Call('gainShard',o.color)
            end
        end
    elseif twistsresolved < 10 then
        broadcastToAll("Scheme Twist: Each player KO's an Officer from the Officer stack or an Officer/Nova hero from their hand or discard pile.")
    end
    return twistsresolved
end