--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    setupGUID = "912967"
    
    local guids3 = {
        "discardguids",
        "cityguids",
        "vpileguids",
        "shardguids",
        "resourceguids",
        "attackguids",
        "drawguids",
        "playerBoards"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "hqguids",
       "city_zones_guids"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = callGUID(o,2)
    end
        
    local guids1 = {
        "pushvillainsguid",
        "officerZoneGUID",
        "sidekickZoneGUID",
        "kopile_guid"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = callGUID(o,1)
    end
    
    as_heroes = {"Mirage",
        "Sunspot",
        "Cypher",
        "Magik",
        "Martial Arts Master",
        "Heartless Computer Scientist",
        "Karma",
        "Warlock",
        "Wolfsbane",
        "Magma"}
    
end

function callGUID(var,what)
    if not var then
        log("Error, can't fetch guid of object with name nil.")
        return nil
    elseif not what then
        log("Error, can't fetch guid of object with missing type.")
        return nil
    end
    if what == 1 then
        return getObjectFromGUID(setupGUID).Call('returnVar',var)
    elseif what == 2 then
        return table.clone(getObjectFromGUID(setupGUID).Call('returnVar',var))
    elseif what == 3 then
        return table.clone(getObjectFromGUID(setupGUID).Call('returnVar',var),true)
    else
        log("Error, can't fetch guid of object with unknown type.")
        return nil
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
    if not obj or not tag then
        return nil
    end
    for _,o in pairs(obj.getTags()) do
        if o:find(tag) then
            if index then
                return o:sub(index,-1)
            else 
                local res = tonumber(o:match("%d+"))
                if res then
                    return res
                else
                    return o:sub(#tag+1,-1)
                end
            end
        end
    end
    return nil
end

function rescue_bystander(obj,color)
    local name = obj.getName()
    if name == "" then
        return name
    end
    
    if color == "White" then
        angle = 90
    elseif color == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    local pos = getObjectFromGUID(discardguids[color]).getPosition()
    pos.y = pos.y + 2
    
    for _,o in pairs(as_heroes) do
        if o == name then
            obj.setRotationSmooth(brot)
            obj.setPositionSmooth(pos)
            return nil
        end
    end
    --todo:
    -- Detective Wolverine
    -- Stan Lee
    -- Tourist Couple
    -- Animal Trainer
    -- Board Gamer
    -- Comic Shop Keeper
    -- Triage Nurse
    -- Photographer
    -- Damage Control
    -- Forklift Driver
    -- Lawyer
    -- Pizza Delivery Guy
    -- Double Agent of S.H.I.E.L.D.
    -- Dog Show Judge
    if name == "Actor" then
        local heroes = {}
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                table.insert(heroes,hero)
            end
        end
        local actorGains = function(hero,index,pcolor)
            local recruit = hasTag2(hero,"Recruit:")
            if recruit then
               getObjectFromGUID(resourceguids[pcolor]).Call('addValue',recruit)
            end
            local attack = hasTag2(hero,"Attack:")
            if recruit then
               getObjectFromGUID(attackguids[pcolor]).Call('addValue',attack)
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = color,
            hand = heroes, 
            pos = "Stay", 
            label = "Choose",
            tooltip = "Gain this hero's printed recruit and attack.",
            trigger_function = actorGains,
            args = "self"})
        broadcastToColor(name .. " rescued! Choose a hero in the HQ to imitate.",color,color)
    end
    if name == "Alligator Trapper" then
        local content = get_decks_and_cards_from_zone(cityguids["Sewers"])
        for _,o in pairs(content) do
            if o.hasTag("Villain") then
                return name
            end
        end
        getObjectFromGUID(resourceguids[color]).Call('addValue',2)
        broadcastToColor(name .. " rescued! You gained 2 Recruit.",color,color)
        return name
    end
    if name == "Aspiring Hero" then
        get_decks_and_cards_from_zone(sidekickZoneGUID)[1].takeObject({position = pos,
            flip = true,
            smooth = true})
        broadcastToColor(name .. " rescued! You gained a SHIELD officer. You may give it to another player.",color,color)
        return name
    end
    if name == "Banker" then
        broadcastToColor(name .. " rescued! You get 2 recruit, but only for a hero under the Bank (not scripted).",color,color)
        return name
    end
    if name == "Bulldozer Driver" then
        broadcastToColor(name .. " rescued! You may move a villain to an adjacent city space (not scripted).",color,color)
        return name
    end
    if name == "Computer Hacker" then
        getObjectFromGUID(playerBoards[color]).Call('handsizeplus')
        broadcastToColor(name .. " rescued! You will draw an extra card at the end of your next turn.",color,color)
        return name
    end
    if name == "Engineer" then
        engineerKOs = function(fcolor,stoploop)
            local deck = get_decks_and_cards_from_zone(drawguids[fcolor])[1]
            if deck and deck.tag == "Deck" then
                local topcard = deck.getObjects()[1]
                for _,tag in pairs(topcard.tags) do
                    if tag:find("Cost:") then
                        broadcastToColor("The top card of your deck was " .. topcard.name .. " and not KO'd.",fcolor,fcolor)
                        return nil
                    end
                end
                deck.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                    smooth = true,
                    flip = true})
                broadcastToColor("The top card of your deck cost 0 and was KO'd.",fcolor,fcolor)
            elseif deck and hasTag2(deck,"Cost:") then
                broadcastToColor("The top card of your deck was " .. deck.getName() .. " and not KO'd.",fcolor,fcolor)
            elseif deck and not hasTag2(deck,"Cost:") then
                deck.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                broadcastToColor("The top card of your deck cost 0 and was KO'd.",fcolor,fcolor)
            elseif not stoploop then
                getObjectFromGUID(playerBoards[fcolor]).Call('click_refillDeck')
                Wait.time(function engineerKOs(fcolor,true) end,1.5)
            end
        end
        engineerKOs(color)
        broadcastToColor(name .. " rescued! The top card of your deck will be KO'd if it costs 0.",color,color)
        return name
    end
    if name == "Fortune Teller" then
        broadcastToColor(name .. " rescued! Choose zero or nonzero and draw the top card of your deck if it has that cost (not scripted).",color,color)
        return name
    end
    if name == "Legendary Game Designer" then
        getObjectFromGUID(shardguids[color]).Call('add_subtract')
        broadcastToColor(name .. " rescued! You gained a shard.",color,color)
        return name
    end
    if name == "News Reporter" then
        getObjectFromGUID(playerBoards[color]).Call('click_draw_card')
        broadcastToColor(name .. " rescued! You drew a card.",color,color)
        return name
    end
    if name == "Paramedic" then
        broadcastToColor(name .. " rescued! You may KO a wound from your hand or any discard pile (not scripted").",color,color)
        return name
    end
    if name == "Public Speaker" then
        getObjectFromGUID(resourceguids[color]).Call('addValue',1)
        broadcastToColor(name .. " rescued! You gained 1 Recruit.",color,color)
        return name
    end
    if name == "Radiation Scientist" then
        broadcastToColor(name .. " rescued! You may KO a hero from your hand or discard pile (not scripted").",color,color)
        return name
    end
    if name == "Rock Star" then
        getObjectFromGUID(pushvillainsguid).Call('getBystander',color)
        broadcastToColor(name .. " rescued! You rescue another bystander.",color,color)
        return name
    end
    if name == "Rocket Test Pilot" then
        broadcastToColor(name .. " rescued! Hyperspeed 3 for recruit or attack (not scripted).",color,color)
        return name
    end
    if name == "Shapeshifted Copycat" then
        obj.removeTag("Bystander")
        obj.addTag("Villain")
        obj.setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,label = 3,tooltip = "This bystander is now a villain."})
        Wait.time(function getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') end,1)
        broadcastToColor(name .. " rescued, but it enters the city as a villain!",color,color)
        return name
    end
    if name == "Undercover Agent" then
        get_decks_and_cards_from_zone(officerZoneGUID)[1].takeObject({position = pos,
            flip = true,
            smooth = true})
        broadcastToColor(name .. " rescued! You gained a SHIELD officer. You may give it to another player.",color,color)
        return name
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end