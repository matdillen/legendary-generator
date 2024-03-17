function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "hmPileGUID",
        "setupGUID",
        "bystandersPileGUID"
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
end

function setupSpecial(params)
    log("Make a cytoplasm and bystander infected deck.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Cytoplasm Spikes",
        pileGUID = hmPileGUID,
        destGUID = twistZoneGUID})
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    local pos = getObjectFromGUID(twistZoneGUID).getPosition()
    for i=1,20 do
        bsPile.takeObject({position = pos,
            flip=true,smooth=false})
    end
    local infectedDeckReady = function()
        local infectedDeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        if infectedDeck and infectedDeck.getQuantity() == 30 then
            return true
        else
            return false
        end
    end
    local infectedDeckShuffle = function()
        local infectedDeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        infectedDeck.flip()
        infectedDeck.randomize()
    end
    Wait.condition(infectedDeckShuffle,infectedDeckReady)
    log("Infected deck moved to twists pile.")
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function spikePush(obj)
    if obj.hasTag("Bystander") then
        getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
    elseif obj.getName() == "Cytoplasm Spikes" then
        click_push_villain_into_city()
    end
end

function drawSpike()
    local spikedeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if spikedeck[1] and spikedeck[1].tag == "Deck" then
        spikedeck[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
            callback_function = spikePush, flip = true, smooth = true})
    elseif spikedeck[1] then
        spikedeck[1].flip()
        if spikedeck[1].hasTag("Bystander") then
            getObjectFromGUID(pushvillainsguid).Call('koCard',spikedeck[1])
        else
            spikedeck[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            Wait.time(click_push_villain_into_city,1)
        end
    else
        broadcastToAll("Spike deck is empty!")
    end
end

function resolveTwist(params)
    local cards = params.cards
    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    Wait.time(drawSpike,1)
    Wait.time(drawSpike,2)
    Wait.time(drawSpike,3)
    return nil
end