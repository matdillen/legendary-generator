twistsresolved = 0
playerBoards = {
    ["Red"]="8a35bd",
    ["Green"]="d7ee3e",
    ["Yellow"]="ed0d43",
    ["Blue"]="9d82f3",
    ["White"]="206c9c"
}

vpileguids = {
    ["Red"]="fac743",
    ["Green"]="a42b83",
    ["Yellow"]="7f3bcd",
    ["Blue"]="f6396a",
    ["White"]="7732c7"
}

hqguids = {
    "aabe45",
    "bf3815",
    "11b14c",
    "b8a776",
    "75241e"
}
function onLoad()
    escape_zone_guid  =  "de2016"
    city_start_zone_guid = "40b47d"
    kopile_guid = "79d60b"
    --Creates invisible button onload, hidden under the "REFILL" on the deck pad
    self.createButton({
        click_function="click_push_villain_into_city", function_owner=self,
        position={0,0,0}, label="Push villain into city", color={1,1,1,0}, width=2000, height=3000,
        tooltip = "Push villains into the city or charge once"
    })
end

function get_decks_and_cards_from_zone(zoneGUID)
    --this function returns cards, decks and shards in a city space (or the start zone)
    --returns a table of objects
    local zone = getObjectFromGUID(zoneGUID)
    if zone then
        decks = zone.getObjects()
    else
        return nil
    end
    local result = {}
    if decks then
        for k, deck in pairs(decks) do
            local desc = deck.getDescription()
            if deck.tag == "Deck" or deck.tag == "Card" or deck.getName() == "Shard" then
                table.insert(result, deck)
            end
        end
    end
    return result
end

function shift_to_next(objects,targetZone,enterscity)
    --all found cards, decks and shards (objects) in a city space will be moved to the next space (targetzone)
    --enterscity is equal to 1 if this shift is a single card moving into the city
    isEnteringCity = enterscity or 0
    local shard = false
    for k, obj in pairs(objects) do
        local targetZone_final = targetZone
        local xshift = 0
        local zPos = obj.getPosition().z
        local bs = false
        --if an object enters or leaves the city, then it should move vertically accordingly
        if targetZone.guid == escape_zone_guid or isEnteringCity == 1 then
            zPos = targetZone.getPosition().z
        end
        local desc = obj.getDescription()
        --is the object a bystander?
        for i,o in pairs(obj.getTags()) do
            if o == "Bystander" then
                bs = true
            end
        end
        --is the object a villainous weapon
        if desc:find("VILLAINOUS WEAPON") then
            bs = true
        end
        --is the object leaving the city?
        if targetZone.guid == escape_zone_guid and not desc:find("LOCATION") then
            if obj.getName() == "Shard" then
                --first shard moves to the mastermind
                if shard == false then
                    targetZone_final = getObjectFromGUID("a91fe7")
                    shard = true
                    broadcastToAll("A Shard from an escaping villain was moved to the mastermind!",{r=1,g=0,b=0})
                else
                --other shards go back to the supply
                    targetZone_final = getObjectFromGUID("0cd6a9")
                    --shard supply is located through the herodeck zone, so also nudge a bit to the right 
                    xshift = xshift + 4
                    zPos = targetZone_final.getPosition().z
                    broadcastToAll("Additional shards beyond the first were returned to the supply!",{r=0,g=1,b=0}) 
                end
            elseif desc:find("VILLAINOUS WEAPON") then
                -- weapons move to mastermind upon escaping
                broadcastToAll("Villainous Weapon Escaped", {r=1,g=0,b=0})
                targetZone_final = getObjectFromGUID("a91fe7")
                zPos = targetZone_final.getPosition().z - 1.5
            elseif bs == true then
                broadcastToAll("Bystander Escaped", {r=1,g=0,b=0})
            else
                broadcastToAll("Villain Escaped", {r=1,g=0,b=0})
            end
        end
        if desc:find("LOCATION") then
            --locations will be nudged a bit upwards to distinguish from villains
            zPos = zPos + 1.5
        end
        if isEnteringCity == 1 and bs == true then
            --bystanders (when entering) will be nudged downwards to distinguish
            zPos = targetZone.getPosition().z - 1.5
        end
        if isEnteringCity == 1 or not desc:find("LOCATION") then
            --locations don't move unless they are entering
            obj.setPositionSmooth({targetZone_final.getPosition().x+xshift,
                targetZone_final.getPosition().y + 3,
                zPos},
                false,
                false)
        end
    end
end

function click_draw_villain()
    obj=getObjectFromGUID("e6b0bc")
    villain_deck_zone = getObjectFromGUID("4bc134")
    villain_decks   = villain_deck_zone.getObjects()
    if villain_decks then
        for k, deck in pairs(villain_decks) do
          if deck.tag == "Deck" then
            villain_deck=deck
          end
          if deck.tag == "Card" then
            villain_deck=deck
          end
        end
    end
    local schemeZone=getObjectFromGUID("c39f60")
    flip_villains = true
    if schemeZone.getObjects()[2] then
        if schemeZone.getObjects()[2].getName() == "Alien Brood Encounters" then
            flip_villains = false
        end
    end
    if villain_deck then
        takeParams = {
            position = {obj.getPosition().x,obj.getPosition().y+5,obj.getPosition().z},
            flip = flip_villains
        }
        takeParams_single = {obj.getPosition().x,obj.getPosition().y+5,obj.getPosition().z}
        if villain_deck.tag == "Deck" then
            villain_deck.takeObject(takeParams)
        end
        if villain_deck.tag == "Card" then
            villain_deck.flip()
            villain_deck.setPositionSmooth(takeParams_single)
            villain_deck = nil
        end
    else
        print("Villain deck is empty!")
    end
end

function push_all (city)
    --init is 1 when this function is called by the button, otherwise it should be 0
    -- this is important for some scheme twists
    
    --if all guids are still there, cards will be entering the city
    --this will cause issues if multiple cards enter at the same time
    --that should therefore never happen!
    if city[1] == "e6b0bc" then
        cityEntering = 1
    else
        cityEntering = 0
    end
    --does the city table exist and does it have any elements in it
    if city and city[1] then
        --the zone which will be checked with this push
        local zoneGUID=table.remove(city,1)
        --the zone cards should be moved to
        local targetZoneGUID=city[1]
        if not targetZoneGUID then
            targetZoneGUID=escape_zone_guid
        end
        local targetZone=getObjectFromGUID(targetZoneGUID)
        --find all cards, decks and shards in a zone
        local cards=get_decks_and_cards_from_zone(zoneGUID)
        if cards then
            --any cards found:
            if cards[1] and targetZone then
                --retrieve setup information
                local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
                if not schemeParts then
                    printToAll("No scheme specified!")
                    return nil
                end
                --special scheme: all cards enter the city face down
                --so no special card behavior
                if schemeParts[1] == "Alien Brood Encounters" then
                    if city then
                        push_all(city)
                    end
                    return shift_to_next(cards,targetZone)
                end
                
                if cityEntering == 1 then
                    --special events in certain schemes not related to twists
                    nonTwistspecials(cards,city,schemeParts)
                
                    --special scripted scheme twists
                    if cards[1].getName() == "Scheme Twist" then
                        proceed = twistSpecials(cards,city,schemeParts)
                        --this function should return nil if it covers all scheme twist behavior
                        --and hence the city should be no further affected
                        if not proceed then
                            return nil
                        end
                        --as a default, move the twist to the twists zone
                        --city is otherwise not affected
                        --Age of Ultron turns the twist into a villain, so it can enter
                        if schemeParts[1] ~= "Age of Ultron" then
                            return cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
                        end
                    end
                
                    --master strikes always go to the master strike zone
                    --maybe later on they can be scripted, but this requires knowing all masterminds that are present
                    if cards[1].getName() == "Masterstrike" then
                        return cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
                    end
                
                    --bystanders behave differently when entering
                    local bs = false
                    for i,o in pairs(cards[1].getTags()) do
                        if o == "Bystander" then
                            bs = true
                        end
                    end
                
                    --same for villainous weapons
                    local vw = false
                    if cards[1].getDescription():find("VILLAINOUS WEAPON") then
                        vw = true
                    end
                
                    --entering location is moved into the first location-free city space
                    if cards[1].getDescription():find("LOCATION") then
                        local cityspaces = city
                        local locationfound = true
                        while locationfound == true do
                            local cards=get_decks_and_cards_from_zone(cityspaces[1])
                            --any cards found?
                            if next(cards) then
                                --is any of them a location?
                                local locationhere = false
                                for i,o in pairs(cards) do
                                    if o.getDescription():find("LOCATION") then
                                        locationhere = true
                                    end
                                end
                                --if so, check next city space
                                if locationhere == true then
                                    table.remove(cityspaces,1)
                                else
                                    --if not, move the location here
                                    locationfound = false
                                    targetZone = getObjectFromGUID(cityspaces[1])
                                end
                                if not cityspaces[1] then
                                    broadcastToAll("City is filled with locations. Please KO the weakest one!",{r=1,g=0,b=0})
                                    return nil
                                end
                            else
                                --if no cards are here, move the location here
                                locationfound = false
                                targetZone = getObjectFromGUID(cityspaces[1])
                            end
                        end
                        return shift_to_next(cards,targetZone,cityEntering)
                    end
                
                    --bystanders and weapons go to the first villain in the city
                    if (bs == true or vw == true) then
                        local cityspaces = city
                        local cardfound = false
                        while cardfound == false do
                            local cards=get_decks_and_cards_from_zone(cityspaces[1])
                            --locations don't count as villains, so they get skipped
                            --locations may rarely capture bystanders. place these OUTSIDE the city or this will break
                            local locationfound = false
                            if cards[1] and not cards[2] then
                                if cards[1].getDescription():find("LOCATION") then
                                    locationfound = true
                                end
                            end
                            
                            --if no cards or only a location, check next city space
                            if not next(cards) or locationfound == true then
                                table.remove(cityspaces,1)
                            else
                                --villain found, so put bystander here
                                --this will break if something other than a villain or location is on its own in the city
                                cardfound = true
                                targetZone = getObjectFromGUID(cityspaces[1])
                            end
                            if not cityspaces[1] then
                                --if the city is empty:
                                cardfound = true
                                if bs == true then
                                    --bystanders go to the mastermind
                                    targetZone = getObjectFromGUID("be6070")
                                    broadcastToAll("Bystander moved to Mastermind as city is empty!",{r=1,g=0,b=0})
                                elseif vw == true then
                                    --weapons get KO'd
                                    targetZone = getObjectFromGUID(kopile_guid)
                                    broadcastToAll("Villainous Weapon KO'd as city is empty!",{r=1,g=0,b=0})
                                end
                            end
                        end
                        return shift_to_next(cards,targetZone,cityEntering)
                    end
                end
                --if this space has only a location, it's effectively empty and no further pushing needs to be done
                if cards[1].getDescription():find("LOCATION") and not cards[2] then
                    return nil
                else
                    --otherwise, shift all and rerun this function for the next city space
                    shift_to_next(cards,targetZone,cityEntering)
                    if city then
                        push_all(city)
                    end
                end
            end
        else
            updateUltronPower()
        end
    end
end

function click_push_villain_into_city(obj, player_clicker_color, alt_click)
-- when moving the villain deck buttons, change the first guid to a new scripting zone
    local city_zones_guids = {"e6b0bc","40b47d","5a74e7","07423f","5bc848","82ccd7"}
    local cardfound = false
    while cardfound == false do
        local cards=get_decks_and_cards_from_zone(city_zones_guids[1])
        local locationfound = false
        if cards[1] and not cards[2] then
            if cards[1].getDescription():find("LOCATION") and city_zones_guids[1] ~= "e6b0bc" then
                locationfound = true
            end
        end
        if not next(cards) or locationfound == true then
            table.remove(city_zones_guids,1)
        else
            cardfound = true
        end
        if not city_zones_guids[1] then
            cardfound = true
        end
    end
    --log (city_zones_guids)
    if city_zones_guids[1] then
        push_all(city_zones_guids)
    end
end

--destroy buttons upon escape:
--card.removeButton(0)

function updateTwistPower()
    local city_zones = {"e6b0bc","40b47d","5a74e7","07423f","5bc848","82ccd7"}
    local twistsstack = get_decks_and_cards_from_zone("4f53f9")
    --log(twistsstack)
    if twistsstack[1] then
        twistsstacked = math.abs(twistsstack[1].getQuantity())
    else
        twistsstacked = 0
    end
    for i,o in pairs(city_zones) do
        local cityobjects = get_decks_and_cards_from_zone(o)
        for index,object in pairs(cityobjects) do
            if object.getName() == "S.H.I.E.L.D. Officer" or object.getName() == "Madame Hydra" then
                object.editButton({label=twistsstacked+3})
            end
        end
    end
end

function updateUltronPower()
    ultronpower = 4
    evolutionPile = get_decks_and_cards_from_zone("1fa829")
    if next(evolutionPile) then
        if evolutionPile[1].tag == "Deck" then
            evolutionPileCards = evolutionPile[1].getObjects()
            evolutionPileSize = #evolutionPileCards
        elseif evolutionPile[1].tag == "Card" then
            evolutionPileCards = evolutionPile[1]
            evolutionPileSize = 1
        else
            printToAll("Get those shards out of there.")
            return nil
        end
    else
        printToAll("Evolution deck missing???")
        return nil
    end
    local evolutionColors = {
            ["HC:Red"]=false,
            ["HC:Green"]=false,
            ["HC:Yellow"]=false,
            ["HC:Blue"]=false,
            ["HC:Silver"]=false
    }
    if evolutionPileSize > 1 then
        for i=1,evolutionPileSize do
            for j,k in pairs(evolutionPileCards[i].tags) do
                if k:find("HC:") then
                    evolutionColors[k] = true
                end
            end
        end
    else
        for i,o in pairs(evolutionPileCards.getTags()) do
                if o:find("HC:") then
                    evolutionColors[o] = true
                end
        end
    end
    for i,o in pairs(hqguids) do
        local herocard = getObjectFromGUID(o).Call('getHero')
        if herocard then
            for index,object in pairs(herocard.getTags()) do
                if object:find("HC:") then
                    if evolutionColors[object] == true then
                        ultronpower = ultronpower + 1
                        break
                    end
                end
            end
        end
    end
    
    local city_zones = {"e6b0bc","40b47d","5a74e7","07423f","5bc848","82ccd7"}
    for i,o in pairs(city_zones) do
        local cityobjects = get_decks_and_cards_from_zone(o)
        for index,object in pairs(cityobjects) do
            if object.getName() == "Evolved Ultron" then
                object.editButton({label=ultronpower})
            end
        end
    end
end

function ultronCallback(obj)
    Wait.time(updateUltronPower,1)
end

function powerButton(obj,click_f,label_f)
    if obj and click_f and label_f then
        obj.createButton({click_function=click_f,
            function_owner=self,
            position={0,22,0},
            label=label_f,
            tooltip="Click to update villain's power!",
            font_size=500,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    end
end

function twistSpecials(cards,city,schemeParts)
    --log("special" .. schemename)
    if schemeParts[1] == "Age of Ultron" then
        posi = getObjectFromGUID("1fa829")
        --actuposi = {x=posi.getPosition().x+4*twistsresolved,y=posi.getPosition().y,z=posi.getPosition().z}
        heroZone=getObjectFromGUID("0cd6a9")
        herodeck = heroZone.getObjects()[2]
        --will not work if hero deck contains 1 or less cards
        if twistsresolved == 0 then
            ultronpower = 4
        end
        twistsresolved = twistsresolved + 1
        herodeck.takeObject({position = posi.getPosition(),
            flip=true,
            callback_function=ultronCallback})
        cards[1].setName("Evolved Ultron")
        cards[1].setTags({"VP6"})
        cards[1].setDescription("EMPOWERED: This card gets extra Power for each Hero with the listed Hero Class in the Evolution Pile.")
        powerButton(cards[1],"updateUltronPower",ultronpower)
        return twistsresolved
    end
    --if schemeParts[1] == "Annihilation: Conquest" then
        --not automatable: players choose if tie
    --end
    if schemeParts[1] == "Anti-Mutant Hatred" then
        pcolor = Turns.turn_color
        if pcolor == "White" then
            angle = 90
        elseif pcolor == "Blue" then
            angle = -90
        else
            angle = 0
        end
        brot = {x=0, y=angle, z=0}
        local playerBoard = getObjectFromGUID(playerBoards[pcolor])
        local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
        print("Angry Mob moved to player's discard pile!")
        cards[1].setRotationSmooth(brot)
        cards[1].setPositionSmooth({x=dest.x,y=dest.y+3,z=dest.z})
        return nil
    end
    if schemeParts[1] == "Brainwash the Military" then
        --cards[1].setName("Traitor Batallion")
        twistsresolved = twistsresolved + 1 
        --log("twists:" .. twistsresolved)
        if twistsresolved < 7 then
            click_draw_villain()
            updateTwistPower()
            printToAll("Scheme Twist: Play another card of the villain deck!")
        elseif twistsresolved == 7 then
            printToAll("Scheme Twist: All SHIELD Officers in the city escape!")
            for i,o in pairs(city) do
                local cardsincity = get_decks_and_cards_from_zone(o) 
                if next(cardsincity) then
                    for index,object in pairs(cardsincity) do
                        if object.getName() == "S.H.I.E.L.D. Officer" or object.getName() == "Madame Hydra" then
                            object.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                            broadcastToAll("S.H.I.E.L.D. Officer escaped!",{r=1,g=0,b=0})
                        end
                    end
                end
            end
        end
        return twistsresolved
    end
    -- if sschemeParts[1] == "Break The Planet Asunder" then
        -- KO heroes from HQ if they're weaker than twistsresolved
        -- requires hero tags with their base power
        -- twistsresolved = twistsresolved + 1    
    -- end
    if schemeParts[1] == "Build an Army of Annihilation" then
        local twistpile = getObjectFromGUID("4f53f9")
        annipile = getObjectFromGUID("8656c3")
        cards[1].setPositionSmooth(twistpile.getPosition())
        twistsresolved = twistsresolved + 1
        if annipile.getObjects()[2] then
            henchpresent = annipile.getObjects()[2].getQuantity()
        else
            henchpresent = 0
        end
        henchcaught = 0
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                vpilecontent = getObjectFromGUID(o).getObjects()[1]
                copguids = {}
                if vpilecontent then
                    if vpilecontent.getQuantity() > 1  then
                        local vpileCards = vpilecontent.getObjects()
                        for j = 1, vpilecontent.getQuantity() do
                            if vpileCards[j].name == "Annihilation Wave Henchmen" then
                                table.insert(copguids,vpileCards[j].guid)
                            end
                        end
                        henchcaught = henchcaught + #copguids
                        if vpilecontent.getQuantity() ~= #copguids then
                            for j = 1,#copguids do
                                vpilecontent.takeObject({position=annipile.getPosition(),
                                    guid=copguids[j]})
                            end
                        else
                            vpilecontent.setPositionSmooth(annipile.getPosition())
                        end
                    elseif vpilecontent.getQuantity() == -1 then
                        if vpilecontent.getName() == "Annihilation Wave Henchmen" then
                            awh = vpilecontent.setPositionSmooth(annipile.getPosition())
                            henchcaught = henchcaught + 1
                        end
                    end
                end
            end
        end
        annimmpile = getObjectFromGUID("bf7e87")
        local refeedMM = function()
            --twist card's setPosition may be too slow, so use a variable
            --twistsstacked = twistpile.getObjects()[2].getQuantity()
            --if twistsstacked == -1 then twistsstacked = 1 end
            annicount = annipile.getObjects()[2].getQuantity()
            for i=1,twistsresolved do
                if i < annicount then
                    annipile.getObjects()[2].takeObject({position=annimmpile.getPosition()})
                elseif i == annicount then
                    annipile.setPositionSmooth(annimmpile.getPosition())
                else
                    printToAll("Not enough annihilation wave henchmen left! Evil wins?")
                    return nil
                end
            end
            printToAll(twistsresolved .. " annihilation henchmen moved to the mastermind!")
        end
        local anniGathered = function()
            annicards = annipile.getObjects()[2]
            if annicards then
                if annicards.getQuantity() == henchpresent + henchcaught then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        Wait.condition(refeedMM,anniGathered)
        return nil
    end
    --if schemeParts[1] == "Build an Underground MegaVault Prison" then
        --check sewers for villain, if so, deal wounds
        --can do, but potentially complicated with locations or mm specials
        
        --check top card and play if villain
        --requires villain tag, or could check for VP and exclude bystanders
        --still tricky with locations and weapons
    --end
    if schemeParts[1] == "Cage Villains in Power-Suppressing Cells" then
        local twistpile = getObjectFromGUID("4f53f9")
        cards[1].setPositionSmooth(twistpile.getPosition())
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                vpilecontent = getObjectFromGUID(o).getObjects()[1]
                annipile = getObjectFromGUID("8656c3")
                copguids = {}
                if vpilecontent then
                    if vpilecontent.getQuantity() > 1  then
                        local vpileCards = vpilecontent.getObjects()
                        for j = 1, vpilecontent.getQuantity() do
                            if vpileCards[j].name == "Cops" then
                                table.insert(copguids,vpileCards[j].guid)
                            end
                        end
                        if vpilecontent.getQuantity() ~= #copguids then
                            for j = 1,#copguids do
                                vpilecontent.takeObject({position=annipile.getPosition(),
                                    guid=copguids[j]})
                            end
                        else
                            vpilecontent.setPositionSmooth(annipile.getPosition())
                        end
                    end
                    if vpilecontent.getQuantity() == -1 then
                        if vpilecontent.getName() == "Cops" then
                            vpilecontent.setPositionSmooth(annipile.getPosition())
                        end
                    end
                end
            end
        end
        broadcastToAll("TWIST: Put a non-grey hero from your hand in front of you and put a cop on top of it.")
        return nil
    end
    if schemeParts[1] == "Capture Baby Hope" then
        babyfound = false
        for i,o in pairs(city) do
            local cityobjects = getObjectFromGUID(o).getObjects()
            if next(cityobjects) then
                babycheck = false
                for index,object in pairs(cityobjects) do
                    if object.getName() == "Baby Hope Token" then
                        babycheck = true
                        babyfound = true
                    end
                end
                if babycheck == true then
                    for index,object in pairs(cityobjects) do
                        if object.getName() == "Baby Hope Token" then
                            object.setPositionSmooth(getObjectFromGUID("c39f60").getPosition())
                            broadcastToAll("Villain with Baby Hope escaped!",{r=1,g=0,b=0})
                        end
                    end
                    cityobjects = get_decks_and_cards_from_zone(o)
                    shift_to_next(cityobjects,getObjectFromGUID(escape_zone_guid),0)
                    cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
                end
            end
        end
        if babyfound == false then
            babyHope = getObjectFromGUID("e27f77")
            local cityspaces = city
            local cardfound = false
            while cardfound == false do
                local cityobjects=get_decks_and_cards_from_zone(cityspaces[1])
                --locations don't count as villains, so they get skipped
                --locations may rarely capture bystanders. place these OUTSIDE the city or this will break
                local locationfound = false
                if cityobjects[1] and not cityobjects[2] then
                    if cityobjects[1].getDescription():find("LOCATION") then
                        locationfound = true
                    end
                end
                --if no cards or only a location, check next city space
                if not next(cityobjects) or locationfound == true then
                    table.remove(cityspaces,1)
                else
                    --villain found, so put bystander here
                    --this will break if something other than a villain or location is on its own in the city
                    cardfound = true
                    targetZone = getObjectFromGUID(cityspaces[1])
                    shift_to_next({babyHope},targetZone,1)
                end
                if not cityspaces[1] then
                    --if the city is empty:
                    cardfound = true
                    babyHope.setPositionSmooth(getObjectFromGUID("c39f60").getPosition())
                end
            end
            cards[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
        end
        return nil
    end
    if schemeParts[1] == "Crush Them With My Bare Hands" then
        cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
        broadcastToAll("Master Strike!")
        return nil
    end
    if schemeParts[1] == "Dark Alliance" then
        if twistsresolved == 0 then
            mmPile=getObjectFromGUID("c7e1d5")
            annipile = getObjectFromGUID("8656c3")
            mmPile.randomize()
            local stripTactics = function(obj)
                keep = math.random(4)
                tacguids = {}
                for i = 1,4 do
                    table.insert(tacguids,obj.getObjects()[i].guid)
                end
                annimmpile = getObjectFromGUID("bf7e87")
                for i = 1,4 do
                    if i ~= keep then
                        obj.takeObject({position = annimmpile.getPosition(),
                            guid = tacguids[i],
                            flip = true})
                    end
                end
            end
            mmPile.takeObject({position = annipile.getPosition(),callback_function = stripTactics})
        elseif twistsresolved < 4 then
            annipile = getObjectFromGUID("8656c3")
            if annipile.getObjects()[2] then
                postop = annipile.getPosition()
                postop.y = postop.y + 4
                tacticShuffle = function(obj)
                    annipile.getObjects()[2].randomize()
                end
                addTactic = function(obj)
                    if annimmpile.getObjects()[2].getQuantity() > 1 then
                        annimmpile.getObjects()[2].takeObject({position = annipile.getPosition(),
                            flip=true,
                            smooth=false,
                            callback_function = tacticShuffle})
                    elseif annimmpile.getObjects()[2].getQuantity() == -1 then
                        annimmpile.getObjects()[2].flip()
                        ann = annimmpile.getObjects()[2].setPosition(annipile.getPosition())
                        tacticShuffle(ann)
                    end
                end
                if annipile.getObjects()[2].getQuantity() > 1 then
                    annipile.getObjects()[2].takeObject({position =postop,
                        callback_function = addTactic})
                elseif annipile.getObjects()[2].getQuantity() == -1 then
                    ann = annipile.getObjects()[2].setPosition(postop)
                    addTactic(ann)
                end
            end
        end
        twistsresolved = twistsresolved + 1
        --log(twistsresolved)
        return twistsresolved
    end
    if schemeParts[1] == "Deadpool Kills the Marvel Universe" then
        twistsresolved = twistsresolved + 1
        heroZone=getObjectFromGUID("0cd6a9")
        herodeck = heroZone.getObjects()[2]
        herodeckcards = herodeck.getObjects()
        deadpoolfound = -1
        --don't do pairs as it doesn't iterate in the right order
        for i = 1,#herodeckcards do
            for index,o in pairs(herodeckcards[i].tags) do
                if o == "Team:Deadpool" then
                    deadpoolfound = i
                end
            end
            if deadpoolfound > -1 then
                break
            end
        end
        for i = 1,deadpoolfound do
            herodeck.takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                flip=true,
                smooth=true}) 
        end
        return twistsresolved
    end
    if schemeParts[1] == "Mutant-Hunting Super Sentinels" then
        local twistpile = getObjectFromGUID("4f53f9")
        cards[1].setPositionSmooth(twistpile.getPosition())
        vildeckzone = getObjectFromGUID("4bc134")
        vildeck = getObjectFromGUID("4bc134").getObjects()[2]
        vildeckcurrentcount = vildeck.getQuantity()
        sentinelsfound = 0
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                vpilecontent = getObjectFromGUID(o).getObjects()[1]
                copguids = {}
                if vpilecontent then
                    if vpilecontent.getQuantity() > 1  then
                        local vpileCards = vpilecontent.getObjects()
                        for j = 1, vpilecontent.getQuantity() do
                            if vpileCards[j].name == "Sentinel" then
                                table.insert(copguids,vpileCards[j].guid)
                                sentinelsfound = sentinelsfound + 1
                            end
                        end
                        for j = 1,#copguids do
                            if not vpilecontent.remainder then
                                vpilecontent.takeObject({position=vildeckzone.getPosition(),
                                    guid=copguids[j],flip=true})
                            else
                                vpilecontent.remainder.flip()
                                vpilecontent.remainder.setPositionSmooth(vildeckzone.getPosition())
                            end  
                        end
                    end
                    if vpilecontent.getQuantity() == -1 then
                        if vpilecontent.getName() == "Sentinel" then
                            vpilecontent.flip()
                            vpilecontent.setPositionSmooth(vildeckzone.getPosition())
                            sentinelsfound = sentinelsfound + 1
                        end
                    end
                end
            end
        end
        local sentinelsAdded = function()
            test = vildeckcurrentcount + sentinelsfound
            if vildeckzone.getObjects()[2] then
                if vildeckzone.getObjects()[2].getQuantity() == test then
                    return true
                else
                    return false
                end
                return false
            end
        end
        local sentinelsNext = function()
            if sentinelsfound > 0 then
                vildeckzone.getObjects()[2].randomize()
            end
            click_draw_villain()
        end
        Wait.condition(sentinelsNext,sentinelsAdded)
        return nil
    end
    return twistsresolved
end

function nonTwistspecials(cards,city,schemeParts)
    if schemeParts[1] == "Brainwash the Military" then
        if cards[1].getName() == "S.H.I.E.L.D. Officer" or cards[1].getName() == "Madame Hydra" then
            local twistsstack = get_decks_and_cards_from_zone("4f53f9")
            if twistsstack[1] then
                twistsstacked = math.abs(twistsstack[1].getQuantity())
            else
                twistsstacked = 0
            end
            powerButton(cards[1],"updateTwistPower",twistsstacked+3)
        end
    end
    
    if schemeParts[1] == "Devolve with Xerogen Crystals" and cityEntering == 1 then
        if cards[1].getName() == schemeParts[9] then
            cards[1].setName("Xerogen Experiments")
            if cards[1].getDescription() == "" then
                cards[1].setDescription("ABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
            end
        end
    end
    
    if schemeParts[1] == "Scavenge Alien Weaponry" and cityEntering == 1 then
        cards[1].setName("Smugglers")
        if cards[1].getDescription() == "" then
            cards[1].setDescription("STRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
        else
            cards[1].setDescription(cards[1].getDescription() .. "\r\nSTRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
        end
    end
end