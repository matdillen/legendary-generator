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
function onLoad()
    escape_zone_guid  =  "de2016"
    city_start_zone_guid = "40b47d"
    kopile_guid = "79d60b"
    --Creates invisible button onload, hidden under the "REFILL" on the deck pad
    self.createButton({
        click_function="click_push_vilain_into_city", function_owner=self,
        position={0,0,0}, label="Push villain into city", color={1,1,1,0}, width=2000, height=3000,
        tooltip = "Push villains into the city or charge once"
    })
end

function get_decks_and_cards_from_zone(zoneGUID)
    --this function returns cards, decks and shards in a city space (or the start zone)
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

function push_all (city,init)
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
                if schemeParts then
                    schemename = schemeParts[1]
                else
                    schemename = "missing"
                end
                
                --special scheme: all cards enter the city face down
                --so no special card behavior
                if schemename == "Alien Brood Encounters" then
                    if city then
                        push_all(city,0)
                    end
                    return shift_to_next(cards,targetZone)
                end
                
                --special scripted scheme twists
                if cards[1].getName() == "Scheme Twist" and init == 1 then
                    proceed = twistSpecials(cards)
                    --this function should return nil if it covers all scheme twist behavior
                    --and hence the city should be no further affected
                    if not proceed then
                        return nil
                    end
                    --as a default, move the twist to the twists zone
                    --city is otherwise not affected
                    --Age of Ultron turns the twist into a villain, so it can enter
                    if schemename ~= "Age of Ultron" then
                        return cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
                    end
                end
                
                --master strikes always go to the master strike zone
                --maybe later on they can be scripted, but this requires knowing all masterminds that are present
                if cards[1].getName() == "Masterstrike" and cityEntering == 1 then
                    return cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
                end
                
                --bystanders behave differently when entering
                local bs = false
                for i,o in pairs(cards[1].getTags()) do
                    if o == "Bystander" and cityEntering == 1 then
                        bs = true
                    end
                end
                
                --same for villainous weapons
                local vw = false
                if cards[1].getDescription():find("VILLAINOUS WEAPON") and cityEntering == 1 then
                    vw = true
                end
                
                --entering location is moved into the first location-free city space
                if cards[1].getDescription():find("LOCATION") and cityEntering == 1 then
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
                if (bs == true or vw == true) and cityEntering == 1 then
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
                
                --if this space has only a location, it's effectively empty and no further pushing needs to be done
                if cards[1].getDescription():find("LOCATION") and not cards[2] then
                    return nil
                else
                    --otherwise, shift all and rerun this function for the next city space
                    shift_to_next(cards,targetZone,cityEntering)
                    if city then
                        push_all(city,0)
                    end
                end
            end
        end
    end
end

function click_push_vilain_into_city(obj, player_clicker_color, alt_click)
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
        push_all(city_zones_guids,1)
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

function twistSpecials(cards)
    if schemename == "Age of Ultron" then
        posi = getObjectFromGUID("1fa829")
        actuposi = {x=posi.getPosition().x+4*twistsresolved,y=posi.getPosition().y,z=posi.getPosition().z}
        heroZone=getObjectFromGUID("0cd6a9")
        herodeck = heroZone.getObjects()[2]
        --will not work if hero deck contains 1 or less cards
        herodeck.takeObject({position = actuposi,flip=true})
        twistsresolved = twistsresolved + 1    
        return twistsresolved
    end
    --if schemename == "Annihilation: Conquest" then
        --not automatable: players choose if tie
    --end
    if schemename == "Anti-Mutant Hatred" then
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
    if schemename == "Brainwash The Military" then
        if twistsresolved < 7 then
            click_draw_villain()
            print("Scheme Twist: Play another card of the villain deck!")
        elseif twistsresolved == 7 then
            print("Scheme Twist: All SHIELD Officers in the city escape!")
        end
        twistsresolved = twistsresolved + 1    
        return twistsresolved
    end
    -- if schemename == "Break The Planet Asunder" then
        -- KO heroes from HQ if they're weaker than twistsresolved
        -- requires hero tags with their base power
        -- twistsresolved = twistsresolved + 1    
    -- end
    if schemename == "Build an Army of Annihilation" then
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
    --if schemename == "Build an Underground MegaVault Prison" then
        --check sewers for villain, if so, deal wounds
        --can do, but potentially complicated with locations or mm specials
        
        --check top card and play if villain
        --requires villain tag, or could check for VP and exclude bystanders
        --still tricky with locations and weapons
    --end
    if schemename == "Cage Villains in Power-Suppressing Cells" then
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
        printToAll("TWIST: Put a non-grey hero from your hand in front of you and put a cop on top of it.")
        return nil
    end
    if schemename == "Crush Them With My Bare Hands" then
        cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
        broadcastToAll("Master Strike!")
        return nil
    end
    if schemename == "Dark Alliance" then
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
    return twistsresolved
end