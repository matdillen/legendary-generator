
function onLoad()
    --starting values
    twistsresolved = 0
    twistsstacked = 0
    strikesresolved = 0
    strikesstacked = 0
    basestrength = 0
    wwiiInvasion = false
    villainstoplay = 0
    goblincount = 0
    othermm = false
    mmStorage = {}
    
    setNotes("[FF0000][b]Scheme Twists resolved:[/b][-] 0\r\n\r\n[ffd700][b]Master Strikes resolved:[/b][-] 0")
    
    herocosts = {}
    for i=0,9 do
        table.insert(herocosts,0)
    end
    
    transformedPV = {}
    
    --guids
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
    
    city_zones_guids = {"e6b0bc",
        "40b47d",
        "5a74e7",
        "07423f",
        "5bc848",
        "82ccd7"}
        
    top_city_guids = {
        "725c5d",
        "3d3ba7",
        "533311",
        "8656c3",
        "4c1868"
    }
    
    hqZonesGUIDs={
        "4c1868",
        "8656c3",
        "533311",
        "3d3ba7",
        "725c5d"}
    
    topBoardGUIDs ={
        "1fa829",
        "bf7e87",
        "4c1868",
        "8656c3",
        "533311",
        "3d3ba7",
        "725c5d",
        "4e3b7e"
    }
    --the guids don't change, the current_city might
    current_city = table.clone(city_zones_guids)
    
    escape_zone_guid = "de2016"
    kopile_guid = "79d60b"
    
    bystandersPileGUID = "0b48dd"
    woundsDeckGUID = "653663"
    sidekickDeckGUID = "959976"
    officerDeckGUID = "9c9649"
    
    schemePileGUID = "0716a4"
    mmPileGUID = "c7e1d5"
    strikePileGUID = "aff2e5"
    horrorPileGUID = "b119a8"
    twistPileGUID = "c82082"
    villainPileGUID = "375566"
    hmPileGUID = "de8160"
    ambPileGUID = "cf8452"
    heroPileGUID = "16594d"
    
    heroDeckZoneGUID = "0cd6a9"
    villainDeckZoneGUID = "4bc134"
    schemeZoneGUID = "c39f60"
    mmZoneGUID = "a91fe7"
    strikeZoneGUID = "be6070"
    horrorZoneGUID = "ef2805"
    twistZoneGUID = "4f53f9"
    
    --Creates invisible button onload, hidden under the "REFILL" on the deck pad
    self.createButton({
        click_function="click_push_villain_into_city", function_owner=self,
        position={0,0,0}, label="Push villain into city", color={1,1,1,0}, width=2000, height=3000,
        tooltip = "Push villains into the city or charge once",
        font_size = 250
    })
    
    --buttons above bystander and wound deck
    self.createButton({
        click_function="click_rescue_bystander", function_owner=self,
        position={0,2.7,-15}, label="Rescue Bystander", color={0.6,0.4,0.8,1}, width=2000, height=1000,
        tooltip = "Rescue a bystander",
        font_size = 250
    })
    
    self.createButton({
        click_function="click_get_wound", function_owner=self,
        position={0,2.7,-22}, label="Gain wound", color={1,0.2,0.1,1}, width=2000, height=1000,
        tooltip = "Gain a wound",
        font_size = 250
    })

    --Local positions for each pile of cards
    pos_vp2 = {-5, 0.178, 0.222}
    pos_discard = {-0.957, 0.178, 0.222}
    
end

-- tables always refer to the same object in memory
-- this function allows to replicate them
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

function click_rescue_bystander(obj, player_clicker_color, alt_click) 
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local bspile = getObjectFromGUID(bystandersPileGUID)
    --following is a fix if mojo changes the bspile guid
    if not bspile then
        bystandersPileGUID = getObjectFromGUID("912967").Call('returnbsGUID')
        log(bystandersPileGUID)
        bspile = getObjectFromGUID(bystandersPileGUID)
    end
    local dest = playerBoard.positionToWorld(pos_vp2)
    dest.y = dest.y + 3
	if player_clicker_color == "White" then
		angle = 90
	elseif player_clicker_color == "Blue" then
		angle = -90
	else
		angle = 180
	end
	local brot = {x=0, y=angle, z=0}
    if bspile then
        if bspile.tag == "Deck" then
            bspile.takeObject({position=dest,
                rotation=brot,
                flip=true,
                smooth=true})
            if bspile.remainder then
                bystandersPileGUID = bspile.remainder.guid
            end
        elseif bspile.tag == "Card" then
            bspile.flip()
            bspile.setPositionSmooth(dest)
        end
        broadcastToAll("Player " .. player_clicker_color .. " rescued a bystander!")
    else
        broadcastToAll("Bystander deck is empty!")
    end
end

function click_get_wound(obj, player_clicker_color, alt_click)
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local woundsDeck=getObjectFromGUID(woundsDeckGUID)
    local dest = playerBoard.positionToWorld(pos_discard)
    dest.y = dest.y + 3
    local toflip = nil
    if mmStorage[1] then
        for _,o in pairs(mmStorage) do
            if o == "Mephisto" then
                dest = playerBoard.positionToWorld({0.957, 3.178, 0.222})
                toflip = function(obj)
                    obj.flip()
                end
                break
            end
        end
    end
	if player_clicker_color == "White" then
		angle = 90
	elseif player_clicker_color == "Blue" then
		angle = -90
	else
		angle = 180
	end
	local brot = {x=0, y=angle, z=0}
    if woundsDeck then
        if woundsDeck.tag == "Deck" then
            woundsDeck.takeObject({position=dest,
                rotation = brot,
                flip = false,
                smooth = true,
                callback_function = toflip})
            if woundsDeck.remainder then
                woundsDeckGUID = woundsDeck.remainder.guid
            end
        elseif woundsDeck.tag == "Card" then
            if not toflip then
                woundsDeck.flip()
            end
            woundsDeck.setPositionSmooth(dest)
        end
        broadcastToAll("Player " .. player_clicker_color .. " got a wound!")  
    else
        broadcastToAll("Wounds deck is empty!")
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    --this function returns cards, decks and shards in a city space (or the start zone)
    --returns a table of objects
    local zone = getObjectFromGUID(zoneGUID)
    if zone then
        decks = zone.getObjects()
    else
        return nil
    end
    local shardname = "Shard"
    local hopename = "Baby Hope Token"
    if shardinc == false then
        shardname = "notShardName"
        hopename = "notBaby Hope Token"
    end
    local result = {}
    if decks then
        for k, deck in pairs(decks) do
            if deck.tag == "Deck" or deck.tag == "Card" or deck.getName() == shardname or deck.getName() == hopename then
                if bsinc == nil or not deck.hasTag("Bystander") then
                    table.insert(result, deck)
                end
            end
        end
    end
    return result
end

function shift_to_next(objects,targetZone,enterscity,schemeParts)
    --all found cards, decks and shards (objects) in a city space will be moved to the next space (targetzone)
    --enterscity is equal to 1 if this shift is a single card moving into the city
    local isEnteringCity = enterscity or 0
    local shard = false
    for _,obj in pairs(objects) do
        local targetZone_final = targetZone
        local xshift = 0
        local zPos = obj.getPosition().z
        local bs = false
        --if an object enters or leaves the city, then it should move vertically accordingly
        if targetZone.guid == escape_zone_guid or isEnteringCity == 1 then
            zPos = targetZone.getPosition().z
        end
        local desc = obj.getDescription()
        --is the object a bystander or a villainous weapon?
        if (obj.hasTag("Bystander") and obj.hasTag("Killbot") == false) or desc:find("VILLAINOUS WEAPON") then
            bs = true
        end
        if obj.tag == "Deck" and bs == false then
            for _,o in pairs(obj.getObjects()) do
                for _,tag in pairs(o.tags) do
                    if tag == "Bystander" then
                        bs = true
                        break
                    end
                end
                if bs == true then
                    break
                end
            end
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
                broadcastToAll("Bystander(s) Escaped", {r=1,g=0,b=0})
                for _,o in pairs(Player.getPlayers()) do
                    promptDiscard(o.color)
                end
                --if multiple bystanders escape, they're often stacked as a deck
                --only one notice will be given
            elseif obj.getName() == "Baby Hope Token" and schemeParts and schemeParts[1] == "Capture Baby Hope" then
                broadcastToAll("Baby Hope was taken away by a villain!", {r=1,g=0,b=0})
                getObjectFromGUID("c82082").takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition()})
                targetZone_final = getObjectFromGUID("c39f60")
            else
                broadcastToAll("Villain Escaped", {r=1,g=0,b=0})
                if obj.getName() == "King Hyperion" then
                    targetZone_final = getObjectFromGUID(mmZoneGUID)
                    dealWounds()
                    broadcastToAll("King Hyperion escaped! Everyone gains a wound!")
                elseif obj.getName() == "Thor" and schemeParts and schemeParts[1] == "Crown Thor King of Asgard" then
                    getObjectFromGUID("c82082").takeObject({position = getObjectFromGUID("4f53f9").getPosition(),
                        smooth=false})
                        --this should be from the KO pile, but that is still a mess to sort out
                        --take them from the scheme twist pile for now
                    broadcastToAll("Thor escaped! Triumph of Asgard!")
                elseif obj.getName() == "Demon Bear" and schemeParts and schemeParts[1] == "The Demon Bear Saga" then
                    getObjectFromGUID("c82082").takeObject({position = getObjectFromGUID("4f53f9").getPosition(),
                        smooth=false})
                        --this should be from the KO pile, but that is still a mess to sort out
                        --take them from the scheme twist pile for now
                    broadcastToAll("The Demon Bear escaped! Dream Horror!")
                end
                if schemeParts and schemeParts[1] == "Change the Outcome of WWII" and wwiiInvasion == false then
                    wwiiInvasion = true
                    getObjectFromGUID("c82082").takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
                        smooth=false})
                    broadcastToAll("The Axis successfully conquered this country!")
                end
            end
        end
        if desc:find("LOCATION") then
            --locations will be nudged a bit upwards to distinguish from villains
            zPos = zPos + 1.5
        end
        if isEnteringCity == 1 and bs == true and targetZone.guid ~= kopile_guid then
            --bystanders (when entering) will be nudged downwards to distinguish
            zPos = targetZone.getPosition().z - 2
        end
        if isEnteringCity == 1 or not desc:find("LOCATION") then
            --locations don't move unless they are entering
            obj.setPositionSmooth({targetZone_final.getPosition().x+xshift,
                targetZone_final.getPosition().y + 3,
                zPos})
        end
    end
end

function click_draw_villain()
    local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
    pos.y = pos.y + 5
    local vildeckguid = villainDeckZoneGUID
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    local flip_villains = true
    if schemeParts then
        if schemeParts[1] == "Alien Brood Encounters" then
            flip_villains = false
        end
        if schemeParts[1] == "Fragmented Realities" then
            for _,o in pairs(hqZonesGUIDs) do
                local zone = getObjectFromGUID(o)
                if zone.hasTag(Turns.turn_color) then
                    vildeckguid = zone.guid
                    break
                end
            end
        end
    end
    local villain_deck = get_decks_and_cards_from_zone(vildeckguid)[1]
    if villain_deck then
        if villain_deck.tag == "Deck" then
            villain_deck.takeObject({position = pos,
                flip = flip_villains})
        else
            if flip_villains == true then
                villain_deck.flip()
            end
            villain_deck.setPositionSmooth(pos)
            villain_deck = nil
        end
    else
        broadcastToAll("Villain deck is empty!")
    end
end

function addBystanders(cityspace,face,posabsolute)
    if face == nil then
        face = true
    end
    local targetZone = getObjectFromGUID(cityspace).getPosition()
    if posabsolute == nil then
        targetZone.z = targetZone.z - 2
    end
    getObjectFromGUID(bystandersPileGUID).takeObject({position=targetZone,
        smooth=true,
        flip=face})
end

function push_all(city)
    --if all guids are still there, cards will be entering the city
    --this will cause issues if multiple cards enter at the same time
    --that should therefore never happen!
    if city[1] == city_zones_guids[1] then
        cityEntering = 1
    else
        cityEntering = 0
    end
    --does the city table exist and does it have any elements in it
    if city and city[1] then
        --the zone which will be checked with this push
        local zoneGUID = table.remove(city,1)
        --the zone cards should be moved to
        local targetZoneGUID = city[1]
        if not targetZoneGUID then
            targetZoneGUID = escape_zone_guid
        end
        updateTwistPower()
        local targetZone = getObjectFromGUID(targetZoneGUID)
        --find all cards, decks and shards in a zone
        local cards = get_decks_and_cards_from_zone(zoneGUID)
        if cards then
            --any cards found:
            if cards[1] and targetZone then
                --retrieve setup information
                local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
                local bspile = getObjectFromGUID(bystandersPileGUID)
                if not bspile then
                    bystandersPileGUID = getObjectFromGUID("912967").Call('returnbsGUID')
                end
                if not schemeParts then
                    printToAll("No scheme specified!")
                    return nil
                end
                if schemeParts[1] == "Tornado of Terrigen Mists" and twistsresolved > 5 and targetZoneGUID == escape_zone_guid then
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
                    local proceed = nonTwistspecials(cards,city,schemeParts)
                    if not proceed then
                        return nil
                    end
                    --special scripted scheme twists
                    if cards[1].getName() == "Scheme Twist" then
                        twistsresolved = twistsresolved + 1
                        local notes = getNotes()
                        notes = notes:gsub("%[%-%] %d+","[-] " .. twistsresolved,1)
                        setNotes(notes)
                        local proceed = twistSpecials(cards,city,schemeParts)
                        --this function should return nil if it covers all scheme twist behavior
                        --and hence the city should be no further affected
                        if not proceed then
                            return nil
                        end
                        --as a default, move the twist to the twists zone
                        --city is otherwise not affected
                        --Age of Ultron turns the twist into a villain, so it can enter
                        if schemeParts[1] ~= "Age of Ultron" and schemeParts[1] ~= "Steal the Weaponized Plutonium" then
                            return cards[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                        end
                    end
                
                    --master strikes always go to the master strike zone
                    --maybe later on they can be scripted, but this requires knowing all masterminds that are present
                    if cards[1].getName() == "Masterstrike" then
                        strikesresolved = strikesresolved + 1
                        updateTwistPower()
                        local notes = getNotes()
                        notes = notes:gsub("Strikes resolved:%[/b%]%[%-%] %d+","Strikes resolved:[/b][-] " .. strikesresolved,1)
                        setNotes(notes)
                        local proceed = strikeSpecials(cards,city,schemeParts)
                        if not proceed then
                            return nil
                        else
                            return koCard(cards[1])
                        end
                    end
                
                    --bystanders behave differently when entering
                    local bs = false
                    if cards[1].hasTag("Bystander") and cards[1].hasTag("Killbot") == false then
                        bs = true
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
                    
                    if cards[1].getDescription():find("TRAP") then
                        broadcastToAll("Trap! Resolve it by end of turn or suffer the consequences!",{r=1,g=0,b=0})
                        return nil
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
                                    targetZone = getObjectFromGUID(mmZoneGUID)
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
                    shift_to_next(cards,targetZone,cityEntering,schemeParts)
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
    local city_topush = table.clone(current_city)
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    if schemeParts then
        if schemeParts[1] == "Fragmented Realities" then
            for i,o in pairs(hqZonesGUIDs) do
                local zone = getObjectFromGUID(o)
                if zone.hasTag(player_clicker_color) then
                    villain_deck_zone = i
                    break
                end
            end
            city_topush = {"e6b0bc",city_zones_guids[6-villain_deck_zone+1]}
        end
    end
    local cardfound = false
    while cardfound == false do
        local cards = get_decks_and_cards_from_zone(city_topush[1])
        local locationfound = false
        if cards[1] and not cards[2] then
            if cards[1].getDescription():find("LOCATION") and city_topush[1] ~= city_zones_guids[1] then
                locationfound = true
            end
        end
        if not next(cards) or locationfound == true then
            table.remove(city_topush,1)
        else
            cardfound = true
        end
        if not city_topush[1] then
            cardfound = true
        end
    end
    if city_topush[1] then
        push_all(city_topush)
    end
end

function updateTwistPower()
    for _,o in pairs(city_zones_guids) do
        local cityobjects = get_decks_and_cards_from_zone(o)
        for _,object in pairs(cityobjects) do
            if object.getButtons() then
                if object.hasTag("Corrupted") or object.hasTag("Brainwashed") or object.hasTag("Possessed") or object.hasTag("Killbot") then
                    object.editButton({label=twistsstacked+basestrength})
                elseif object.hasTag("Phalanx-Infected") then
                    object.editButton({label=twistsstacked+hasTag2(object,"Cost:")})
                elseif object.getName() == "Smugglers" then
                    object.editButton({label = "+" .. strikesresolved})
                elseif object.hasTag("Khonshu Guardian") then
                    if i % 2 == 0 then
                        object.editButton({label = hasTag2(object,"Cost:")*2})
                    else
                        object.editButton({label = hasTag2(object,"Cost:")})
                    end
                elseif noMoreMutants and object.getName() == "Scarlet Witch (R)" then
                    object.editButton({label = hasTag2(object,"Cost:") + 4})
                elseif object.getName() == "Jean Grey (DC)" and object.hasTag("VP4") then
                    object.editButton({label = hasTag2(object,"Cost:") + goblincount})
                elseif object.getName() == "S.H.I.E.L.D. Assault Squad" or object.hasTag("Ambition") then
                    object.editButton({label = "+" .. twistsstacked})
                elseif object.getName() == "Graveyard" and object.hasTag("Location") then
                    for _,obj in pairs(cityobjects) do
                        if obj.hasTag("Villain") then
                            object.editButton({label = 7 + 2*reaperbonus + 2})
                            return nil
                        end
                    end
                    object.editButton({label = 7 + 2*reaperbonus})
                end
            end
        end
    end
end

function updateUltronPower()
    ultronpower = 4
    local evolutionPile = get_decks_and_cards_from_zone(topBoardGUIDs[1])
    if evolutionPile[1] then
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
            for _,k in pairs(evolutionPileCards[i].tags) do
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
        local herocard = getObjectFromGUID(o).Call('getHeroUp')
        if herocard then
            for _,object in pairs(herocard.getTags()) do
                if object:find("HC:") then
                    if evolutionColors[object] == true then
                        ultronpower = ultronpower + 1
                        break
                    end
                end
            end
        else
            broadcastToAll("Hero in hq space " .. i .. " is missing?")
        end
    end
    
    for _,o in pairs(city_zones_guids) do
        local cityobjects = get_decks_and_cards_from_zone(o)
        for _,object in pairs(cityobjects) do
            if object.getName() == "Evolved Ultron" then
                object.editButton({label=ultronpower})
            end
        end
    end
end

function ultronCallback(obj)
    Wait.time(updateUltronPower,1)
end

function updateHQTags()
    for i,o in pairs(hqZonesGUIDs) do
        local content = get_decks_and_cards_from_zone(o)
        local zone = getObjectFromGUID(o)
        if content[1] and content[1].getQuantity() < 3 then
            if #zone.getButtons() == 1 then
                zone.createButton({click_function="updateHQTags",
                function_owner=self,
                position={0,0,-3.7},
                rotation={0,180,0},
                label="+" .. math.abs(content[1].getQuantity()),
                tooltip="Additional cost due to subjugation disks",
                font_size=300,
                font_color="Yellow",
                color={0,0,0,0.75},
                width=250,height=250})
            else
                zone.editButton({index=1,label="+" .. math.abs(content[1].getQuantity())})
            end
        elseif content[1] and content[1].getQuantity() > 2 then
            broadcastToAll("Too many obedience disks in zone " .. i .. " above the board")
        elseif not content[1] and #zone.getButtons() > 1 then
            zone.removeButton(1)
        end
    end
end

function powerButton(obj,click_f,label_f,otherposition,toolt)
    if not otherposition then
        otherposition = {0,22,0}
    end
    if not toolt then
        toolt = "Click to update villain's power!"
    end
    if obj and click_f and label_f then
        obj.createButton({click_function=click_f,
            function_owner=self,
            position=otherposition,
            label=label_f,
            tooltip=toolt,
            font_size=500,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    end
end

function dealWounds()
    for i,_ in pairs(playerBoards) do
        if Player[i].seated == true then
            click_get_wound(getObjectFromGUID(woundsDeckGUID),i)
        end
    end
end

function cityLowTides()
    table.insert(current_city,"d30aa1")
    table.insert(current_city,"bd3ef1")
end

function playVillains(n,condition_f,vildeckguid)
    --plays n cards from the villain deck (default n=1)
    --the first only if condition_f is met (optional)
    if not n then
        n = 1
    end
    --you may specify a custom villain deck (scripting zone) guid for some schemes
    if not vildeckguid then
        vildeckguid = "4bc134"
    end
    if villainstoplay == 0 then
        villainstoplay = villainstoplay + n
        getObjectFromGUID(vildeckguid).createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="(" .. villainstoplay .. ")",
                tooltip="Additional villain cards to play",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        broadcastToAll("Playing " .. n .. " card(s) from the villain deck, one by one.")
        --this variable to check whether a card has been played and pushed into the city
        villaintopcardguid = nil
        --to limit villains played to n, this tracks each iteration
        local villainPlayed = function()
            --has the previous villain been played, then the next iteration can go on the stack
            local card = get_decks_and_cards_from_zone(city_zones_guids[1])
            if card[1] and card[1].guid == villaintopcardguid then
                return true
            else
                return false
            end
        end
        local villainGone = function()
            --has the played villain been moved from the enter-city zone
            local card = get_decks_and_cards_from_zone(city_zones_guids[1])
            if not card[1] then
                return true
            else
                return false
            end
        end
        local playVillainCallback = function(obj)
            --checks whether the top card that was taken to get a guid is back on top
            --of the villain deck again
            local objLanded = function()
                local vildeck = get_decks_and_cards_from_zone(vildeckguid)[1]
                if vildeck.getObjects()[1].guid == obj.guid then
                    return true
                else
                    return false
                end
            end
            Wait.condition(playVillain,objLanded)
        end
        local drawVillain = function()
            click_draw_villain()
            villainstoplay = villainstoplay - 1
            local vildeckzone = getObjectFromGUID(vildeckguid)
            local butt = vildeckzone.getButtons()
            if butt and villainstoplay > 0 then
                vildeckzone.editButton({index=#butt-1,label="(" .. villainstoplay .. ")"})
            elseif butt and villainstoplay == 0 then
                vildeckzone.removeButton(#butt-1)
            end
            if villainstoplay > 0 then
                --do it all over again until n iterations
                Wait.condition(playVillain,villainPlayed)
            end
        end
        playVillain = function()
            local vildeck = get_decks_and_cards_from_zone(vildeckguid)[1]
            if vildeck and vildeck.getQuantity() > 1 then
                --store the guid of the current top card
                villaintopcardguid = vildeck.getObjects()[1].guid
                if villaintopcardguid == "" then
                    --some cards have no guid
                    --if so, they're moved out and back into the villain deck to get a guid
                    local pos = vildeck.getPosition()
                    pos.y = pos.y + 1
                    vildeck.takeObject({position = pos,
                        smooth = false,
                        callback_function = playVillainCallback})
                else
                    --if we have the guid for the next card, play a card
                    --as soon as the twist or previous villain has left
                    Wait.condition(drawVillain,villainGone)
                end
            else
                broadcastToAll("Villain deck ran out!!")
                return nil
            end
        end
        if condition_f then
            Wait.condition(playVillain,condition_f)
        else
            playVillain()
        end
    else
        villainstoplay = villainstoplay + n
        local vildeckzone = getObjectFromGUID(vildeckguid)
        local butt = vildeckzone.getButtons()
        if butt then
            vildeckzone.editButton({index=#butt-1,label="(" .. villainstoplay .. ")"})
        end
    end
end

function nonCityZone(obj,player_clicker_color)
    broadcastToColor("This city zone does not currently exist!",player_clicker_color)
end

function obedienceDisk(obj,player_clicker_color)
    printToColor("Heroes in the HQ zone below this one cost 1 more for each Obedience Disk (twist) here.",player_clicker_color)
    return nil
end

function nonCityZoneShade(guid)
    getObjectFromGUID(guid).createButton({
        click_function="nonCityZone",
        function_owner=self,
        position={0,-0.5,0},
        height=470,
        width=700,
        color={1,0,0,0.9}})
end

function koCard(obj,smooth)
    if smooth then
        obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
    else
        obj.setPosition(getObjectFromGUID(kopile_guid).getPosition())
    end
end

function stackTwist(obj)
    obj.setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
    twistsstacked = twistsstacked + 1
end

function twistSpecials(cards,city,schemeParts)
    --log("special" .. schemename)
    if schemeParts[1] == "Age of Ultron" then
        if twistsresolved == 1 then
            ultronpower = 4
        end
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        if herodeck[1] then
            if herodeck[1].tag == "Deck" then
                herodeck[1].takeObject({position = getObjectFromGUID(topBoardGUIDs[1]).getPosition(),
                    flip=true,
                    callback_function=ultronCallback})
            else
                herodeck[1].flip()
                herodeck[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
                Wait.time(updateUltronPower,1)
            end
        end
        cards[1].setName("Evolved Ultron")
        cards[1].setTags({"VP6"})
        cards[1].setDescription("EMPOWERED: This card gets extra Power for each Hero with the listed Hero Class in the Evolution Pile.")
        powerButton(cards[1],"updateUltronPower",ultronpower)
        return twistsresolved
    end
    if schemeParts[1] == "Annihilation: Conquest" then
        stackTwist(cards[1])
        local candidate = {["Cost"]=0,["GUID"]=""}
        local tie = false
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                for _,i in pairs(hero.getTags()) do
                    if i:find("Cost:") then
                        local costtag = tonumber(i:match("%d+"))
                        if costtag > candidate["Cost"] then
                            candidate["Cost"] = costtag
                            candidate["GUID"] = o
                            tie = false
                        elseif costtag == candidate["Cost"] then
                            tie = true
                        end
                    end
                end
            else
                printToAll("Missing hero in HQ!!")
                return nil
            end
        end
        if tie == true then
            broadcastToAll("Scheme Twist: Choose one of the tied highest cost heroes in the HQ and place it in the Enter City zone.")
            return nil
        else
            local hqzone = getObjectFromGUID(candidate["GUID"])
            local hero = hqzone.Call('getHeroUp')
            local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
            pos.y = pos.y + 3
            hero.setPositionSmooth(pos)
            hqzone.Call('click_draw_hero')
            return nil
        end
    end
    if schemeParts[1] == "Anti-Mutant Hatred" then
        local pcolor = Turns.turn_color
        if pcolor == "White" then
            angle = 90
        elseif pcolor == "Blue" then
            angle = -90
        else
            angle = 0
        end
        local brot = {x=0, y=angle, z=0}
        local playerBoard = getObjectFromGUID(playerBoards[pcolor])
        local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
        dest.y = dest.y + 3
        broadcastToAll("Scheme Twist: Angry Mob moved to " .. pcolor .. " player's discard pile!")
        cards[1].setRotationSmooth(brot)
        cards[1].setPositionSmooth(dest)
        return nil
    end
    if schemeParts[1] == "Avengers vs. X-Men" then
        local teams = getObjectFromGUID("912967").Call('returnSetupParts')
        local teamchecks = {}
        if teams and teams[9] then
            for s in string.gmatch(teams[9],"[^|]+") do
                table.insert(teamchecks, s)
            end
        else
            broadcastToAll("Missing teams from setup?")
            return nil
        end
        if twistsresolved < 8 then
            for i,o in pairs(playerBoards) do
                if Player[i].seated == true then
                    local hand = Player[i].getHandObjects()
                    if hand then
                        local teamcount1 = 0
                        local teamcount2 = 0
                        for _,card in pairs(hand) do
                            local team = hasTag2(card,"Team:",6)
                            if team then
                                if team == teamchecks[1] then
                                    teamcount1 = teamcount1 + 1
                                elseif team == teamchecks[2] then
                                    teamcount2 = teamcount2 + 1
                                end
                            end
                        end
                        if teamcount1 > 0 and teamcount2 > 0 then
                            click_get_wound(getObjectFromGUID(woundsDeckGUID),i)
                            broadcastToAll(i .. " player received a wound with this Scheme Twist",i)
                        end
                    end
                end
            end
        else
            broadcastToAll("Twist 8: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Brainwash the Military" then
        basestrength = 3
        stackTwist(cards[1])
        if twistsresolved < 7 then
            click_draw_villain()
            Wait.time(updateTwistPower,1)
            broadcastToAll("Scheme Twist: Another card was played from the villain deck!")
        elseif twistsresolved == 7 then
            broadcastToAll("Scheme Twist: All SHIELD Officers in the city escape!")
            for _,o in pairs(city) do
                local cardsincity = get_decks_and_cards_from_zone(o) 
                if cardsincity[1] then
                    for _,object in pairs(cardsincity) do
                        if object.hasTag("Officer") == true then
                            object.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                            broadcastToAll("S.H.I.E.L.D. Officer escaped!",{r=1,g=0,b=0})
                        end
                    end
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Break the Planet Asunder" then
        stackTwist(cards[1])
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            local attack = 0
            if hero then
                for _,k in pairs(hero.getTags()) do
                    if k:find("Attack:") then
                        if attack == 0 then
                            attack = tonumber(k:match("%d+"))
                        elseif attack < tonumber(k:match("%d+")) then
                            attack = tonumber(k:match("%d+"))
                        end
                    end
                end
                if attack < twistsresolved then
                    koCard(hero)
                    getObjectFromGUID(o).Call('click_draw_hero')
                    broadcastToAll("Scheme Twist! Weak hero " .. hero.getName() .. " KO'd from HQ!")
                end
            else
                broadcastToAll("Hero missing in hq!")
                return nil
            end
        end
        return nil
    end
    if schemeParts[1] == "Build an Army of Annihilation" then
        stackTwist(cards[1])
        local annihilationZone = getObjectFromGUID(topBoardGUIDs[4])
        local annihilationdeck = get_decks_and_cards_from_zone(topBoardGUIDs[4])
        local henchpresent = 0
        if annihilationdeck[1] then
            henchpresent = annihilationdeck[1].getQuantity()
        end
        local henchcaught = 0
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                local annihilationguids = {}
                if vpilecontent[1] then
                    if vpilecontent[1].getQuantity() > 1  then
                        for _,j in pairs(vpilecontent[1].getObjects()) do
                            if j.name == "Annihilation Wave Henchmen" then
                                table.insert(annihilationguids,j.guid)
                            end
                        end
                        henchcaught = henchcaught + #annihilationguids
                        if vpilecontent[1].getQuantity() ~= #annihilationguids then
                            for j = 1,#annihilationguids do
                                vpilecontent[1].takeObject({position=annihilationZone.getPosition(),
                                    guid=annihilationguids[j]})
                            end
                        else
                            vpilecontent[1].setPositionSmooth(annihilationZone.getPosition())
                        end
                    else
                        if vpilecontent[1].getName() == "Annihilation Wave Henchmen" then
                            vpilecontent[1].setPositionSmooth(annihilationZone.getPosition())
                            henchcaught = henchcaught + 1
                        end
                    end
                end
            end
        end
        local annihilationMMzone = getObjectFromGUID(topBoardGUIDs[2])
        local refeedMM = function()
            --twist card's setPosition may be too slow, so use a variable
            --twistsstacked = twistpile.getObjects()[2].getQuantity()
            --if twistsstacked == -1 then twistsstacked = 1 end
            local deck = get_decks_and_cards_from_zone(topBoardGUIDs[4])
            local annihilationcount = 0
            if deck[1] then
                annihilationcount = math.abs(deck[1].getQuantity())
            end
            for i=1,twistsresolved do
                if i < annihilationcount then
                    deck[1].takeObject({position=annihilationMMzone.getPosition()})
                elseif i == annihilationcount then
                    deck[1].setPositionSmooth(annihilationMMzone.getPosition())
                else
                    broadcastToAll("Not enough annihilation wave henchmen left! Evil wins?")
                    return nil
                end
            end
            broadcastToAll(twistsresolved .. " annihilation henchmen moved to the mastermind!")
        end
        local anniGathered = function()
            local deck = get_decks_and_cards_from_zone(topBoardGUIDs[4])
            if deck[1] and deck[1].getQuantity() == henchpresent + henchcaught then
                return true
            else
                return false
            end
        end
        Wait.condition(refeedMM,anniGathered)
        return nil
    end
    if schemeParts[1] == "Build an Underground MegaVault Prison" then
        local sewersCards = get_decks_and_cards_from_zone(city_zones_guids[2])
        if sewersCards[1] then
            for i,o in pairs(sewersCards) do
                if o.hasTag("Villain") then
                    dealWounds()
                    broadcastToAll("Scheme Twist: There's a villain in the sewers! Everyone gets a wound!")
                    return twistsresolved
                end
            end
        end
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
        if vildeck[1] then
            local pos = getObjectFromGUID(city_zones_guids[2]).getPosition()
            pos.y = pos.y + 3
            if vildeck[1].tag == "Deck" then
                for _,o in pairs(vildeck[1].getObjects()[1].tags) do
                    if o == "Villain" then
                        vildeck[1].takeObject({position = pos,
                            flip=true})
                        broadcastToAll("The top card of the villain deck enters the sewers!")
                        return twistsresolved
                    end
                end
                local pos = vildeck[1].getPosition()
                pos.y = pos.y +3
                local showCardCallback = function(obj)
                    broadcastToAll("Top card of villain deck is " .. obj.getName() .. ", not a villain!")
                    Wait.time(function() obj.flip() end,1)
                end
                vildeck[1].takeObject({position = pos,flip=true,
                    callback_function = showCardCallback})
            else 
                if vildeck[1].hasTag("Villain") then
                    vildeck[1].flip()
                    vildeck[1].setPositionSmooth(getObjectFromGUID(pos))
                else
                    vildeck[1].flip()
                    broadcastToAll("Top card of villain deck is " .. vildeck[1].getName() .. ", not a villain!")
                    Wait.time(function() vildeck[1].flip() end,1)
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Cage Villains in Power-Suppressing Cells" then
        stackTwist(cards[1])
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                local annipile = getObjectFromGUID("8656c3")
                local copguids = {}
                if vpilecontent[1] then
                    if vpilecontent[1].getQuantity() > 1  then
                        local vpileCards = vpilecontent[1].getObjects()
                        for j = 1, vpilecontent[1].getQuantity() do
                            if vpileCards[j].name == "Cops" then
                                table.insert(copguids,vpileCards[j].guid)
                            end
                        end
                        if vpilecontent[1].getQuantity() ~= #copguids then
                            for j = 1,#copguids do
                                vpilecontent[1].takeObject({position=annipile.getPosition(),
                                    guid=copguids[j]})
                            end
                        else
                            vpilecontent[1].setPositionSmooth(annipile.getPosition())
                        end
                    end
                    if vpilecontent[1].getQuantity() == -1 then
                        if vpilecontent[1].getName() == "Cops" then
                            vpilecontent[1].setPositionSmooth(annipile.getPosition())
                        end
                    end
                end
            end
        end
        broadcastToAll("TWIST: Put a non-grey hero from your hand in front of you and put a cop on top of it.")
        return nil
    end
    if schemeParts[1] == "Capture Baby Hope" then
        local babyfound = false
        for _,o in pairs(city) do
            local cityobjects = getObjectFromGUID(o).getObjects()
            if cityobjects[1] then
                for _,object in pairs(cityobjects) do
                    if object.getName() == "Baby Hope Token" then
                        babyfound = true
                        object.setPositionSmooth(getObjectFromGUID("c39f60").getPosition())
                    end
                end
                if babyfound == true then
                    broadcastToAll("Villain with Baby Hope escaped!",{r=1,g=0,b=0})
                    local cityobjects = get_decks_and_cards_from_zone(o)
                    shift_to_next(cityobjects,getObjectFromGUID(escape_zone_guid),0)
                    stackTwist(cards[1])
                    break
                end
            end
        end
        if babyfound == false then
            local babyHope = getObjectFromGUID("e27f77")
            local cityspaces = table.clone(city)
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
                if not cityobjects[1] or locationfound == true then
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
            koCard(cards[1])
        end
        return nil
    end
    if schemeParts[1] == "Change the Outcome of WWII" then
        koCard(cards[1])
        local vildeck = get_decks_and_cards_from_zone("4bc134")[1]
        local vildeckcount = math.abs(vildeck.getQuantity())
        for _,o in pairs(city) do
            local cards = get_decks_and_cards_from_zone(o)
            if cards[1] then
                for _,card in pairs(cards) do
                    if card.hasTag("Villain") or card.hasTag("Bystander") or card.getDescription():find("VILLAINOUS WEAPON") then
                        card.flip()
                        card.setPosition(vildeck.getPosition())
                        vildeckcount = vildeckcount + 1
                    end
                end
            end
        end
        if vildeckcount ~= math.abs(vildeck.getQuantity()) then
            local vildeckpos = vildeck.getPosition()
            vildeckpos.y = vildeckpos.y + 3
            vildeck.setPositionSmooth(vildeckpos)
        end
        if twistsresolved < 8 then
            local wwcountries = {4,3,6,3,5,2,1}
            broadcastToAll("Scheme Twist: The axis invade another country and the city is now " .. wwcountries[twistsresolved] .. " spaces!")
            for i,o in pairs(city_zones_guids) do
                local zone = getObjectFromGUID(o)
                if zone.getButtons() then
                    zone.removeButton(0)
                end
            end
            if not getObjectFromGUID("bd3ef1").getButtons() then
                nonCityZoneShade("bd3ef1")
            end
            if not getObjectFromGUID("d30aa1").getButtons() then
                nonCityZoneShade("d30aa1")
            end
            if getObjectFromGUID("d30aa1").getButtons() and twistsresolved == 3 then
                getObjectFromGUID("d30aa1").removeButton(0)
            end
            city = table.clone(city_zones_guids)
            table.remove(city,1)
            if wwcountries[twistsresolved] < 5 then
                for i=1,#city - wwcountries[twistsresolved] do
                    table.remove(city)
                end
                current_city = table.clone(city)
                table.insert(current_city,1,"e6b0bc")
            elseif wwcountries[twistsresolved] > 5 then
                table.insert(city,"d30aa1")
                current_city = table.clone(city)
                table.insert(current_city,1,"e6b0bc")
            else
                current_city = table.clone(city)
                table.insert(current_city,1,"e6b0bc")
            end
            for i,o in pairs(city_zones_guids) do
                if not current_city[i] then
                    nonCityZoneShade(o)
                end
            end
        end
        local vildeckLanded = function()
            local vildeck = get_decks_and_cards_from_zone("4bc134")[1]
            if vildeck then
                if vildeck.getQuantity() == vildeckcount then
                    return true
                else 
                    return false
                end
            else
                return false
            end
        end
        playVillains(2,vildeckLanded)
        wwiiInvasion = false
        return nil
    end
    if schemeParts[1] == "Clash of the Monsters Unleashed" then
        koCard(cards[1])
        local monsterpit = get_decks_and_cards_from_zone("4f53f9")
        local monsterpower = 0
        if monsterpit[1] then
            if monsterpit[1].tag == "Deck" then
                local monsterToEnter = monsterpit[1].getObjects()[1]
                for _,i in pairs(monsterToEnter.tags) do
                    if i:find("Power:") then
                        monsterpower = tonumber(i:match("%d+"))
                    end
                end
                monsterpit[1].takeObject({position = getObjectFromGUID("e6b0bc").getPosition(),
                    flip=true,
                    callback_function = click_push_villain_into_city})
            else
                monsterpower = hasTag2(monsterpit[1],"Power:")
                monsterpit[1].flip()
                monsterpit[1].setPositionSmooth(getObjectFromGUID("e6b0bc").getPosition())
                local lastMonsterSpawned = function()
                    local monster = get_decks_and_cards_from_zone("e6b0bc")
                    if monster[1] and monster[1].guid == monsterpit[1].guid then
                        return true
                    else
                        return false
                    end   
                end
                Wait.condition(click_push_villain_into_city,lastMonsterSpawned)
            end
        end
        if twistsresolved > 2 and twistsresolved < 11 then
            for i,o in pairs(vpileguids) do
                if Player[i].seated == true then
                    local vpilecontent = getObjectFromGUID(o).getObjects()[1]
                    local maxpower = 0
                    if vpilecontent then
                        if vpilecontent.getQuantity() > 1  then
                            local vpileCards = vpilecontent.getObjects()
                            for j = 1, #vpilecards do
                                for _,k in pairs(vpilecards[j].tags) do
                                    if k:find("Power:") then
                                        maxpower = math.max(maxpower,tonumber(k:match("%d+")))
                                    end
                                end
                            end
                        elseif vpilecontent.getQuantity() == -1 then
                            if hasTag2(vpilecontent,"Power:") then
                                maxpower = hasTag2(vpilecontent,"Power:")
                            end
                        end
                    end
                    if monsterpower > maxpower then
                        broadcastToAll("Player " .. i .. "'s Gladiator was no good (power of only " .. maxpower .. ") and they got a wound!",i)
                        click_get_wound(monsterpit,i)
                    end
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Corrupt the Next Generation of Heroes" then
        stackTwist(cards[1])
        local skpile = getObjectFromGUID("959976")
        basestrength = 2
        broadcastToAll("Scheme Twist!",{1,0,0})
        local pushSidekick = function(obj)
            obj.addTag("Corrupted")
            powerButton(obj,"updateTwistPower",twistsstacked+basestrength)
            obj.setDescription("WALL-CRAWL: When fighting this card, gain it to top of your deck as a hero instead of your victory pile.")
            local sidekickLanded = function()
                local landed = get_decks_and_cards_from_zone("e6b0bc")
                if landed[1] and landed[1].guid == obj.guid then
                    return true
                else
                    return false
                end
            end
            broadcastToAll("Corrupted sidekick enters the city!",{1,0,0})
            Wait.condition(click_push_villain_into_city,sidekickLanded)
        end
        local getSidekick = function()
            skpile.takeObject({position = getObjectFromGUID("e6b0bc").getPosition(),
                smooth = false,
                flip = true,
                callback_function = pushSidekick})
        end
        local twistMoved = function()
            local twist = get_decks_and_cards_from_zone("e6b0bc")
            if twist[1] and twist[1].getName() == "Scheme Twist" then
                return false
            else
                return true
            end
        end
        local corruptHeroes = function()
            for i,o in pairs(playerBoards) do
                if Player[i].seated == true then
                    local discard = getObjectFromGUID(o).Call('returnDiscardPile')
                    if discard[1] and discard[1].tag == "Card" then
                        if discard[1].hasTag("Sidekick") == true then
                            discard[1].flip()
                            discard[1].setPositionSmooth(skpile.getPosition())
                        end
                    elseif discard[1] and discard[1].tag == "Deck" then
                        local skfound = false
                        for _,object in pairs(discard[1].getObjects()) do
                            for _,tag in pairs(object.tags) do
                                if tag == "Sidekick" then
                                    discard[1].takeObject({position = skpile.getPosition(),
                                        smooth=true,
                                        flip=true,
                                        guid = object.guid})
                                    skfound = true
                                    break
                                end
                            end
                            if skfound == true then
                                break
                            end
                        end
                    end
                end
            end
            getSidekick()
            Wait.time(getSidekick,2)
        end
        if twistsresolved < 8 then
            Wait.condition(corruptHeroes,twistMoved)
            return nil
        elseif twistsresolved == 8 then
            broadcastToAll("Scheme Twist: All Sidekicks in the city escape!")
            for _,o in pairs(city) do
                local cardsincity = get_decks_and_cards_from_zone(o) 
                if cardsincity[1] then
                    for _,object in pairs(cardsincity) do
                        if object.hasTag("Sidekick") == true then
                            shift_to_next(cardsincity,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                        end
                    end
                end
            end
        end
    end
    if schemeParts[1] == "Crash the Moon into the Sun" then
        local sunlight = 0
        local moonlight = 0
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                local cost = hasTag2(hero,"Cost:")
                if cost then
                    if cost % 2 == 0 then
                        sunlight = sunlight + 1
                    else
                        moonlight = moonlight + 1
                    end
                end
            end
        end
        local light = sunlight - moonlight
        if twistsresolved < 9 then
            if (light > 0 and twistsresolved % 2 == 1) or (light < 0 and twistsresolved % 2 == 0) then
                cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
                broadcastToAll("Scheme Twist caused an Altered Orbit!",{1,0,0})
            else
                cards[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                broadcastToAll("Scheme Twist, but the light aligned!",{0,1,0})
            end
        else
            cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
            broadcastToAll("Scheme Twist caused an Altered Orbit!",{1,0,0})
        end
        return nil
    end
    if schemeParts[1] == "Crown Thor King of Asgard" then
        --check if Thor is in the city
        for _,o in pairs(city) do
            local cityobjects = get_decks_and_cards_from_zone(o)
            if cityobjects[1] then
                for _,object in pairs(cityobjects) do
                    if object.getName() == "Thor" then
                        shift_to_next(cityobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                        broadcastToAll("Scheme Twist! Thor escapes!",{1,0,0})
                        return twistsresolved
                    end
                end
            end
        end
        --or his starting spot
        local cityobjects = get_decks_and_cards_from_zone("4f53f9")
        if cityobjects[1] and cityobjects[1].getName() == "Thor" then
            local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
            if bridgeobjects[1] then
                shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
            end
            cityobjects[1].setPositionSmooth(getObjectFromGUID("82ccd7").getPosition())
            addBystanders("82ccd7")
            addBystanders("82ccd7")
            addBystanders("82ccd7")
            broadcastToAll("Scheme Twist! Thor entered the city.",{1,0,0})
            return twistsresolved
        end
        --or the escape pile
        local escapedobjects = get_decks_and_cards_from_zone(escape_zone_guid)
        if escapedobjects[1] and escapedobjects[1].tag == "Deck" then
            for _,object in pairs(escapedobjects[1].getObjects()) do
                if object.name == "Thor" then
                    local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
                    if bridgeobjects[1] then
                        shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                    end
                    escapedobjects[1].takeObject({guid=object.guid,
                        position=getObjectFromGUID("82ccd7").getPosition(),
                        smooth=true})
                    addBystanders("82ccd7")
                    addBystanders("82ccd7")
                    addBystanders("82ccd7")
                    broadcastToAll("Scheme Twist! Thor re-entered the city from the escape pile.",{1,0,0})
                    return twistsresolved
                end
            end
        elseif escapedobjects[1] and escapedobjects[1].tag == "Card" then
            if escapedobjects[1].getName() == "Thor" then
                local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
                if bridgeobjects[1] then
                    shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                end
                escapedobjects[1].setPositionSmooth(getObjectFromGUID("82ccd7").getPosition())
                addBystanders("82ccd7")
                addBystanders("82ccd7")
                addBystanders("82ccd7")
                broadcastToAll("Scheme Twist! Thor re-entered the city from the escape pile.",{1,0,0})
                return twistsresolved
            end
        end
        --or the victory pile
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpobjects = get_decks_and_cards_from_zone(o)
                if vpobjects[1] and vpobjects[1].tag == "Deck" then
                    for _,object in pairs(vpobjects[1].getObjects()) do
                        if object.name == "Thor" then
                            local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
                            if bridgeobjects[1] then
                                shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                            end
                            vpobjects[1].takeObject({guid=object.guid,
                                position=getObjectFromGUID("82ccd7").getPosition(),
                                smooth=true})
                            addBystanders("82ccd7")
                            addBystanders("82ccd7")
                            addBystanders("82ccd7")
                            broadcastToAll("Scheme Twist! Thor re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                            return twistsresolved
                        end
                    end
                elseif vpobjects[1] and vpobjects[1].tag == "Card" then
                    if vpobjects[1].getName() == "Thor" then
                        local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
                        if bridgeobjects[1] then
                            shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                        end
                        vpobjects[1].setPositionSmooth(getObjectFromGUID("82ccd7").getPosition())
                        addBystanders("82ccd7")
                        addBystanders("82ccd7")
                        addBystanders("82ccd7")
                        broadcastToAll("Scheme Twist! Thor re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                        return twistsresolved
                    end
                end
            end
        end
        local kodobjects = get_decks_and_cards_from_zone(kopile_guid)
        if kodobjects[1] and kodobjects[1].tag == "Deck" then
            for _,object in pairs(kodobjects[1].getObjects()) do
                if object.name == "Thor" then
                    local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
                    if bridgeobjects[1] then
                        shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                    end
                    kodobjects[1].takeObject({guid=object.guid,
                        position=getObjectFromGUID("82ccd7").getPosition(),
                        smooth=true})
                    addBystanders("82ccd7")
                    addBystanders("82ccd7")
                    addBystanders("82ccd7")
                    broadcastToAll("Scheme Twist! Thor re-entered the city from the KO pile.",{1,0,0})
                    return twistsresolved
                end
            end
        elseif kodobjects[1] and kodobjects[1].tag == "Card" then
            if kodobjects[1].getName() == "Thor" then
                local bridgeobjects = get_decks_and_cards_from_zone("82ccd7")
                if bridgeobjects[1] then
                    shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                end
                kodobjects[1].setPositionSmooth(getObjectFromGUID("82ccd7").getPosition())
                addBystanders("82ccd7")
                addBystanders("82ccd7")
                addBystanders("82ccd7")
                broadcastToAll("Scheme Twist! Thor re-entered the city from the KO pile.",{1,0,0})
                return twistsresolved
            end
        end
        --thor not found
        broadcastToAll("Thor not found? Where is he? Maybe KO pile.")
        return nil
    end
    if schemeParts[1] == "Crush HYDRA" then
        if twistsresolved < 8 then
            for _,o in pairs(city) do
                local cards = get_decks_and_cards_from_zone(o)
                if cards[1] then
                    for _,k in pairs(cards) do
                        if k.hasTag("Villain") then
                            local pos = k.getPosition()
                            pos.z = pos.z - 2
                            local skpile = getObjectFromGUID("959976")
                            if skpile then
                                skpile.takeObject({position=pos,flip=true})
                                --if not, check if one card left
                                --otherwise give an officer
                            end
                            --still annotate villain's power boost
                            --also goes in updatetwistpower
                            break
                        end
                    end
                end
            end
        elseif twistsresolved == 8 then
            broadcastToAll("Scheme Twist 8: All heroes in the city escape (don't KO anything)!")
            for _,o in pairs(city) do
                local cards = get_decks_and_cards_from_zone(o)
                if cards[1] then
                    for _,k in pairs(cards) do
                        if k.hasTag("Sidekick") or k.hasTag("Officer") or hasTag2(k,"Cost:") then
                            k.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                        end
                    end
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Crush Them With My Bare Hands" then
        cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
        broadcastToAll("Master Strike!")
        return nil
    end
    if schemeParts[1] == "Cytoplasm Spike Invasion" then
        koCard(cards[1])
        local spikepush = function(obj)
            if obj.hasTag("Bystander") then
                koCard(obj)
            elseif obj.getName() == "Cytoplasm Spikes" then
                click_push_villain_into_city()
            end
        end
        local drawspike = function()
            local spikedeck =  get_decks_and_cards_from_zone("4f53f9")
            if spikedeck[1] then
                if spikedeck[1].tag == "Deck" then
                    spikedeck[1].takeObject({position = getObjectFromGUID("e6b0bc").getPosition(),
                        callback_function = spikepush, flip = true, smooth = true})
                elseif spikedeck[1].tag == "Card" then
                    spikedeck[1].flip()
                    if spikedeck[1].hasTag("Bystander") then
                        koCard(spikedeck[1])
                    else
                        spikedeck[1].setPositionSmooth(getObjectFromGUID("e6b0bc").getPosition())
                        Wait.time(click_push_villain_into_city,1)
                    end
                end
            else
                printToAll("Spike deck is empty!")
            end
        end
        Wait.time(drawspike,1)
        Wait.time(drawspike,2)
        Wait.time(drawspike,3)
        return nil
    end
    if schemeParts[1] == "Dark Alliance" then
        if twistsresolved == 1 then
            local mmPile = getObjectFromGUID(mmPileGUID)
            mmPile.randomize()
            local stripTactics = function(obj)
                obj.flip()
                table.insert(mmStorage,obj.getName())
                mmLocations[obj.getName()] = topBoardGUIDs[4]
                getObjectFromGUID("912967").Call('updateMM')
                getObjectFromGUID("912967").Call('setupMasterminds',obj.getName())
                local keep = math.random(4)
                local tacguids = {}
                for i = 1,4 do
                    table.insert(tacguids,obj.getObjects()[i].guid)
                end
                local tacticsPile = getObjectFromGUID(topBoardGUIDs[2])
                for i = 1,4 do
                    if i ~= keep then
                        obj.takeObject({position = tacticsPile.getPosition(),
                            guid = tacguids[i],
                            flip = true})
                    end
                end
                local flipTactics = function()
                    local pos = obj.getPosition()
                    pos.y = pos.y + 3
                    obj.takeObject({position = pos,
                        index = obj.getQuantity()-1,
                        flip=true})
                end
                Wait.time(flipTactics,1)
            end
            mmPile.takeObject({position = getObjectFromGUID(topBoardGUIDs[4]).getPosition(),callback_function = stripTactics})
        elseif twistsresolved < 5 then
            local allianceMM = get_decks_and_cards_from_zone(topBoardGUIDs[4])
            local mmcard = nil
            if allianceMM[1] then
                for _,o in pairs(allianceMM) do
                    for _,k in pairs(mmStorage) do
                        if k:find(o.getName()) and o.tag == "Card" then
                            mmcard = o
                            break
                        end
                    end
                    if mmcard then
                        break
                    end
                end
                if not mmcard then
                    broadcastToAll("Alliance mastermind card not found.")
                    return nil
                end
                local postop = allianceMM[1].getPosition()
                postop.y = postop.y + 4
                local tacticShuffle = function(obj)
                    get_decks_and_cards_from_zone(topBoardGUIDs[4])[1].randomize()
                end
                local addTactic = function(obj)
                    local tacticsPile = get_decks_and_cards_from_zone(topBoardGUIDs[2])
                    if tacticsPile[1].getQuantity() > 1 then
                        tacticsPile[1].takeObject({position = allianceMM[1].getPosition(),
                            flip=false,
                            smooth=false,
                            callback_function = tacticShuffle})
                    else
                        local ann = tacticsPile[1].setPosition(allianceMM[1].getPosition())
                        tacticShuffle(ann)
                    end
                end
                local ann = mmcard.setPosition(postop)
                addTactic(ann)
            end
        elseif twistsresolved < 7 then
            for _,o in pairs(mmStorage) do
                addBystanders(mmLocations[o])
            end
        elseif twistsresolved == 7 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Dark Reign of H.A.M.M.E.R. Officers" then
        stackTwist(cards[1])
        local sostack = getObjectFromGUID("9c9649")
        for i = 1,twistsresolved do
            sostack.takeObject({position=getObjectFromGUID("bf7e87").getPosition(),
                flip=true,smooth=false})
        end
        return nil
    end
    if schemeParts[1] == "Deadlands Hordes Charge the Wall" then
        koCard(cards[1])
        Wait.time(click_push_villain_into_city,1)
        Wait.time(click_push_villain_into_city,3)
        Wait.time(click_draw_villain,4)
        --could be done with conditions, but then needs to check whether all cards have landed again
        --don't play the new card automatically as this makes the automation unstoppable
        --if the automation breaks, players should be able to continue manually
        return nil
    end
    if schemeParts[1] == "Deadpool Kills the Marvel Universe" then
        local herodeck = get_decks_and_cards_from_zone("0cd6a9")
        if herodeck[1] then
            if herodeck[1].tag == "Deck" then
                local herodeckcards = herodeck[1].getObjects()
                local deadpoolfound = -1
                --don't do pairs as it doesn't iterate in the right order
                for i = 1,#herodeckcards do
                    for _,o in pairs(herodeckcards[i].tags) do
                        if o == "Team:Deadpool" or herodeckcards[i].name == "Deadpool (B)" then
                            deadpoolfound = i
                            break
                        end
                    end
                    if deadpoolfound > -1 then
                        break
                    end
                end
                if deadpoolfound == -1 or deadpoolfound == #herodeckcards then
                    herodeck[1].flip()
                    herodeck[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                else
                    for i = 1,deadpoolfound do
                        herodeck[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                            flip=true,
                            smooth=true}) 
                    end
                end
            else 
                herodeck[1].flip()
                herodeck[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
            end
        else
            broadcastToAll("Hero deck is empty!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Deadpool Wants A Chimichanga" then
        for _,o in pairs(city) do
            local cards = get_decks_and_cards_from_zone(o)
            if cards[1] then
                for _,object in pairs(cards) do
                    if object.hasTag("Bystander") then
                        object.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                        broadcastToAll("Bystander moved to escape pile (do not discard).")
                    end
                end
            end
        end
        local vildeckshuffle = function(obj)
            vildeck = get_decks_and_cards_from_zone("4bc134")[1]
            vildeck.randomize()
        end
        local bsfound = false
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local cards = get_decks_and_cards_from_zone(o)
                local vildeck = get_decks_and_cards_from_zone("4bc134")[1]
                if cards[1] then
                    if cards[1].tag == "Deck" then
                        local bystanderguids = {}
                        for _,object in pairs(cards[1].getObjects()) do
                            for _,k in pairs(object.tags) do
                                if k == "Bystander" then
                                    table.insert(bystanderguids,object.guid)
                                end
                            end
                        end
                        local bsguid = nil
                        if bystanderguids[2] then
                            bsguid = bystanderguids[math.random(#bystanderguids)]
                        elseif bystanderguids[1] then
                            bsguid = bystanderguids[1]
                        end
                        if bsguid then
                            cards[1].takeObject({position = vildeck.getPosition(),
                                guid = bsguid,flip=true})
                            bsfound = true
                        else
                            click_get_wound(cards[1],i)
                        end
                    else
                        if cards[1].hasTag("Bystander") then
                            cards[1].flip()
                            cards[1].setPositionSmooth(vildeck.getPosition())
                            bsfound = true
                        else
                            click_get_wound(cards[1],i)
                        end
                    end
                else
                    click_get_wound(cards[1],i)
                end
            end
        end
        if bsfound == true then
            Wait.time(vildeckshuffle,2)
        end
        return twistsresolved
    end
    if schemeParts[1] == "Deadpool Writes a Scheme" then
        koCard(cards[1])
        if twistsresolved == 1 then
            for i,o in pairs(playerBoards) do
                if Player[i].seated then
                    getObjectFromGUID(o).Call('click_draw_card')
                end
            end
            broadcastToAll("Scheme Twist: Everybody draw 1 card. Wait, are these supposed to be bad?")
        elseif twistsresolved == 2 then
            broadcastToAll("Scheme Twist: Anyone without a Deadpool in hand is doing it wrong -- discard 2 cards.")
        elseif twistsresolved == 3 then  
            playVillains(3)
            broadcastToAll("Scheme Twist: Play 3 cards from the Villain Deck. That sounds pretty bad, right?")
        elseif twistsresolved == 4 then
            for _,o in pairs(city) do
                local citycards = get_decks_and_cards_from_zone(o)
                if citycards[1] then
                    for _,i in pairs(citycards) do
                        if i.hasTag("Villain") then
                            for i = 1,4 do
                                addBystanders(o)
                            end
                            break
                        end
                    end
                end
            end
            broadcastToAll("Scheme Twist: Each Villain captures 4 Bystanders. Hey, I'm not a balance expert.")
        elseif twistsresolved == 5 then
            for i = 1,4 do
                dealWounds()
            end
            broadcastToAll("Scheme Twist: Each player gains 5 Wounds. Is that a good number?")
        elseif twistsresolved == 6 then
            for i = 1,6 do
                broadcastToAll("Deadpool wins 6 times! Wow, I'm way better at this game than you.",{1,0,0})
            end
        end
        return nil    
    end
    if schemeParts[1] == "Destroy the Nova Corps" then
        if twistsresolved < 6 then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if not obj.hasTag("Officer") and not obj.getName():find("Nova %(") then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                if not hand[1] then
                    getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        flip=true,
                        smooth=true})
                    broadcastToAll("Scheme Twist: Officer KO'd from the officer stack.")
                else
                    promptDiscard(o.color,hand)
                    broadcastToColor("Scheme Twist: Discard an Officer or a Nova hero. You gained a shard.",o.color,o.color)
                    gainShard(o.color)
                end
            end
        elseif twistsresolved < 10 then
            broadcastToAll("Scheme Twist: Each player KO's an Officer from the Officer stack or from their hand or discard pile.")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Detonate the Helicarrier" then
        stackTwist(cards[1])
        local heroboom = 0
        local hq = hqguids
        broadcastToAll("Scheme Twist: " .. twistsresolved .. " heroes will be KO'd from the HQ!")
        local explode_heroes = function(zone,n)
            local currenthero = nil
            local explode_hero = function()
                local hero = getObjectFromGUID(zone).Call('getHeroUp')
                if hero then
                    currenthero = hero
                    local hq_cards = getObjectFromGUID(zone).Call('getHeroDown')
                    hero.flip()
                    if not hq_cards or hq_cards.getQuantity() < 5 then
                        getObjectFromGUID(zone).Call('click_draw_hero')
                    end
                else
                    printToAll("Error: hero not found in HQ.",{1,0,0})
                end
            end
            local hero_drawn = function()
                if not currenthero then
                    return true
                end
                local hero = getObjectFromGUID(zone).Call('getHeroUp')
                if hero then
                    if hero.guid == currenthero.guid then
                        return false
                    else
                        return true
                    end
                else
                    return false
                end
            end
            for i=1,n do
                Wait.condition(explode_hero,hero_drawn)
            end
        end
        while heroboom < twistsresolved do
            local boomstack = nil
            local hq_cards = getObjectFromGUID(hq[1]).Call('getHeroDown')
            if hq_cards then
                boomstack_count = math.abs(hq_cards.getQuantity())
            else
                boomstack_count = 0
            end
            if boomstack_count > 5 then
                table.remove(hq,1)
            else
                local todestroy = math.min(6-boomstack_count,twistsresolved-heroboom)
                explode_heroes(hq[1],todestroy)
                heroboom = heroboom + todestroy
                if heroboom < twistsresolved then
                    table.remove(hq,1)
                end
            end
            if not hq[1] then
                broadcastToAll("Helicarrier destroyed!!!",{1,0,0})
                return nil
            end
        end
        return nil
    end
    if schemeParts[1] == "Devolve with Xerogen Crystals" then
        broadcastToAll("Choose a Hero in the HQ that doesn't have a printed Power of 2 or more. Put it on the bottom of the Hero Deck.")
        --can be automated if there's only one
        playVillains(2)
        return twistsresolved
    end
    if schemeParts[1] == "Distract the Hero" then
        broadcastToAll("Scheme Twist: If you get any Victory Points this turn, put this Twist on the bottom of the Villain Deck. Otherwise, stack this Twist next to the Scheme as a Villainous Interruption.")
        local pcolor = Turns.turn_color
        local guid = cards[1].guid
        local turnChanged = function()
            if Turns.turn_color == pcolor then
                return false
            else
                return true
            end
        end
        local villainousInterruption = function()
            local card = get_decks_and_cards_from_zone(city_zones_guids[1])
            if card[1] and card[1].guid == guid then
                stackTwist(card[1])
                broadcastToAll("Last turn's twist stacked next to the Scheme as a Villainous Interruption.")
            end
        end
        Wait.condition(villainousInterruption,turnChanged)
        return nil
    end
    if schemeParts[1] == "Divide and Conquer" then
        if twistsresolved < 4 then
            for i,o in pairs(hqguids) do
                local hqzone = getObjectFromGUID(o)
                local herocard = hqzone.Call('getHeroUp')
                if herocard then
                    herocard.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                    hqzone.Call('click_draw_hero')
                end
            end
            broadcastToAll("Scheme Twist: All heroes in HQ KO'd!")
        else
            broadcastToAll("Scheme Twist: KO one of the hero decks!!",{1,0,0})
        end
        return twistsresolved
    end
    if schemeParts[1] == "Earthquake Drains the Ocean" then
        if twistsresolved % 2 == 1 then
            local scheme = get_decks_and_cards_from_zone("c39f60")
            if scheme[1] then
                scheme[1].flip()
                scheme[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[5]).getPosition())
                table.remove(current_city)
                table.remove(current_city)
                table.remove(current_city)
                table.remove(current_city)
                broadcastToAll("Scheme Twist: The tide rushes in and the city is now only three spaces.")
            else
                broadcastToAll("Scheme card is missing from the Scheme zone?")
            end
        else
            local scheme = get_decks_and_cards_from_zone(city_zones_guids[5])
            if scheme[1] then
                scheme[1].flip()
                scheme[1].setPositionSmooth(getObjectFromGUID("c39f60").getPosition())
                current_city = table.clone(city_zones_guids)
                table.insert(current_city,"d30aa1")
                table.insert(current_city,"bd3ef1")
                broadcastToAll("Scheme Twist: The tide rushes out and the city is now seven spaces.")
                click_draw_villain()
            else
                broadcastToAll("Scheme card is missing from the Streets?")
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Enthrone the Barons of Battleworld" then
        local maxpower = 0
        local toAscend = nil
        local ascendCard = nil
        local mmpos = "4e3b7e"
        for i=1,#top_city_guids do
            local citycards = get_decks_and_cards_from_zone(top_city_guids[6-i])
            if not citycards[1] then
                mmpos = top_city_guids[6-i]
                break
            end
        end
        if twistsresolved < 8 then
            for _,o in pairs(city) do
                local citycards = get_decks_and_cards_from_zone(o)
                if citycards[1] then
                    local spacepower = 0
                    for _,i in pairs(citycards) do
                        if hasTag2(i,"Power:") and not i.getDescription():find("LOCATION") then
                            spacepower = spacepower + hasTag2(i,"Power:")
                            if spacepower > maxpower then
                                toAscend = o
                                ascendCard = i
                                maxpower = spacepower
                                break
                            end
                        end
                    end
                end
            end
            local escapee = false
            local escapedcards = get_decks_and_cards_from_zone(escape_zone_guid)
            if escapedcards[1] then
                if escapedcards[1].tag == "Deck" then
                    for _,i in pairs(escapedcards[1].getObjects()) do
                        for _,j in pairs(i.tags) do
                            if j:find("Power:") then
                                local power = tonumber(j:match("%d+"))
                                if power > maxpower then
                                    toAscend = i.guid
                                    maxpower = power
                                    escapee = true
                                    break
                                end
                            end
                        end
                    end
                else
                    if hasTag2(escapedcards[1],"Power:") and hasTag2(escapedcards[1],"Power:") > maxpower then
                        toAscend = escape_zone_guid
                        ascendCard = escapedcards[1]
                        maxpower = hasTag2(escapedcards[1],"Power:")
                    end
                end
            end
            if toAscend then
                if escapee == true then
                    local annotateNewMM = function(obj)
                        obj.addTag("Ascended")
                        powerButton(obj,"updateTwistPower",hasTag2(obj,"Power:")+2)
                        getObjectFromGUID("912967").Call('fightButton',{mmpos})
                        local vp = hasTag2(obj,"VP") or 0
                        table.insert(mmStorage,"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")")
                        mmLocations["Ascended Baron " .. obj.getName() .. "(" .. vp .. ")"] = mmpos
                    end
                    escapedcards[1].takeObject({position = getObjectFromGUID(mmpos).getPosition(),
                        guid=toAscend,
                        callback_function = annotateNewMM})
                    broadcastToAll("Scheme Twist: Escaped villain ascended to become a mastermind!")
                else
                    local vilgroup = get_decks_and_cards_from_zone(toAscend)
                    local power = 0
                    for i,o in pairs(vilgroup) do
                        if o.getDescription():find("LOCATION") then
                            table.remove(vilgroup,i)
                        elseif hasTag2(o,"Power:") then
                            o.addTag("Ascended")
                            power = power + hasTag2(o,"Power:")
                        end
                    end
                    powerButton(ascendCard,"updateTwistPower",power+2)
                    getObjectFromGUID("912967").Call('fightButton',{mmpos})
                    local vp = hasTag2(ascendCard,"VP") or 0
                    table.insert(mmStorage,"Ascended Baron " .. ascendCard.getName() .. "(" .. vp .. ")")
                    mmLocations["Ascended Baron " .. ascendCard.getName() .. "(" .. vp .. ")"] = mmpos
                    shift_to_next(vilgroup,getObjectFromGUID(mmpos),1)
                    broadcastToAll("Scheme Twist: Villain in city ascended to become a mastermind!")
                end
            else
                broadcastToAll("Scheme Twist: No villains found.")
            end
        elseif twistsresolved == 8 then
            local ultimm = table.clone(top_city_guids)
            table.insert(ultimm,"4e3b7e")
            for i=1,#ultimm do
                local citycards = get_decks_and_cards_from_zone(ultimm[i])
                if citycards[1] then
                    ultimm[i] = nil
                end
            end
            for i,o in pairs(vpileguids) do
                if Player[i].seated then
                    local vpilecontent = get_decks_and_cards_from_zone(o)
                    if vpilecontent[1] then
                        local maxpower = 0
                        if vpilecontent[1].tag == "Deck" then
                            for _,k in pairs(vpilecontent[1].getObjects()) do
                                for _,j in pairs(k.tags) do
                                    if j:find("Power:") then
                                        local power = tonumber(j:match("%d+"))
                                        toAscend = k.guid
                                        if power > maxpower then
                                            maxpower = power
                                        end
                                        break
                                    end
                                end
                            end
                        else
                            if hasTag2(vpilecontent[1],"Power:") then
                                toAscend = o
                            end
                        end
                        local mmpos = nil
                        for j=1,6 do
                            if ultimm[j] then
                                mmpos = ultimm[j]
                                ultimm[j] = nil
                                break
                            end
                        end
                        if toAscend and mmpos then
                            broadcastToAll("Scheme Twist: Villain from " .. i .. "'s victory pile ascends!",i)
                            if vpilecontent[1].tag == "Deck" then
                                local annotateNewMM = function(obj)
                                    obj.addTag("Ascended")
                                    powerButton(obj,"updateTwistPower",hasTag2(obj,"Power:")+2)
                                    getObjectFromGUID("912967").Call('fightButton',{mmpos})
                                    local vp = hasTag2(obj,"VP") or 0
                                    table.insert(mmStorage,"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")")
                                    mmLocations["Ascended Baron " .. obj.getName() .. "(" .. vp .. ")"] = mmpos
                                end
                                vpilecontent[1].takeObject({position = getObjectFromGUID(mmpos).getPosition(),
                                    guid=toAscend,
                                    callback_function = annotateNewMM})
                            else
                                vpilecontent[1].addTag("Ascended")
                                powerButton(vpilecontent[1],"updateTwistPower",hasTag2(vpilecontent[1],"Power:")+2)
                                vpilecontent[1].setPositionSmooth(getObjectFromGUID(mmpos).getPosition())
                            end
                        elseif not toAscend then
                            broadcastToAll("Scheme Twist: No villains found in victory piles?")
                        elseif not mmpos then
                            broadcastToAll("Too many masterminds to deal with. YOU LOSE!!!")
                        end
                    end
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Epic Super Hero Civil War" then
        stackTwist(cards[1])
        local toko = twistsstacked
        broadcastToAll("Scheme Twist: KO " .. twistsstacked .. " heroes from the HQ, one at a time.")
        click_ko = function(obj)
            local hero = obj.Call('getHeroUp')
            if hero then
                koCard(hero)
                obj.Call('click_draw_hero')
                toko = toko - 1
                if toko == 0 then
                    for _,o in pairs(hqguids) do
                        getObjectFromGUID(o).removeButton(2)
                    end
                    getObjectFromGUID(heroDeckZoneGUID).clearButtons()
                else
                    getObjectFromGUID(heroDeckZoneGUID).editButton({label = "(" .. toko .. ")"})
                end
            end
        end
        for _,o in pairs(hqguids) do
            getObjectFromGUID(o).createButton({click_function="click_ko",
                function_owner=self,
                position={0,3,0},
                label="KO",
                tooltip="KO this hero.",
                color={0,0,0,1}, 
                width=1500, height=750,
                font_size = 250,
                font_color = "Red"})
        end
        getObjectFromGUID(heroDeckZoneGUID).createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,3,0},
                rotation={0,180,0},
                label="(" .. toko .. ")",
                tooltip="Heroes to KO.",
                width=0,
                font_size = 250,
                font_color = "Red"})
        return nil
    end
    if schemeParts[1] == "Everybody Hates Deadpool" then
        local deadpoolinhand = {}
        local deadpoolloser = nil
        for i,o in pairs(playerBoards) do
            if Player[i].seated == true then
                local hand = Player[i].getHandObjects()
                if hand then
                    local deadpoolcount = 0
                    for _,card in pairs(hand) do
                        local team = hasTag2(card,"Team:",6)
                        if team and team == "Deadpool" or card.getName() == "Deadpool (B)" then
                            deadpoolcount = deadpoolcount + 1
                        end
                    end
                    deadpoolinhand[i] = deadpoolcount
                    if not deadpoolloser then
                        deadpoolloser = deadpoolcount
                    else
                        deadpoolloser = math.min(deadpoolloser,deadpoolcount)
                    end
                end
            end
        end
        for i,o in pairs(deadpoolinhand) do
            if o == deadpoolloser then
                click_get_wound(deadpoolloser,i)
                broadcastToAll("Scheme Twist: Player " .. i .. " fell short on amazing Deadpools and was wounded for it.",i)
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Explosion at the Washington Monument" then
        local floorboom = table.remove(topBoardGUIDs)
        local floorcontent = get_decks_and_cards_from_zone(floorboom)
        if floorcontent and floorcontent[1] then
            local pcolor = Turns.turn_color
            if pcolor == "White" then
                angle = 90
            elseif pcolor == "Blue" then
                angle = -90
            else
                angle = 180
            end
            local brot = {x=0, y=angle, z=0}
            local playerBoard = getObjectFromGUID(playerBoards[pcolor])
            local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
            dest.y = dest.y + 3
            local floorcount = 0
            for _,o in pairs(floorcontent) do
                if o.is_face_down == false then
                    o.flip()
                end
                floorcount = floorcount + math.abs(o.getQuantity())
            end
            local floorSecure = function()
                local floor = get_decks_and_cards_from_zone(floorboom)
                if floor[1] and math.abs(floor[1].getQuantity()) == floorcount then
                    for _,o in pairs(floor) do
                        if o.is_face_down == false then
                            return false
                        end
                    end
                    return true
                else
                    return false
                end
            end
            local explodeFloor = function(obj)
                floorcontent[1].flip()
                floorcontent[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                broadcastToAll("Scheme Twist: Top floor of the Washington Monument Destroyed!")
            end
            local floorcollapse = function()
                if floorcontent[1].tag == "Deck" then
                    local bs = false
                    for _,o in pairs(floorcontent[1].getObjects()) do
                        bs = false
                        for _,k in pairs(o.tags) do
                            if k == "Bystander" then
                                bs = true
                                break
                            end
                        end
                        if bs == false then
                            floorcontent[1].takeObject({position = dest,
                                rotation = brot,
                                guid = o.guid,
                                callback_function = explodeFloor})
                            broadcastToAll("Player " .. pcolor .. " got a wound from the destroyed Monument floor.",pcolor)
                            break
                        end
                    end
                    if bs == true then
                        explodeFloor(floorcontent[1])
                    end
                else
                    if floorcontent[1].hasTag("Bystander") then
                        explodeFloor()
                    else
                        floorcontent[1].flip()
                        floorcontent[1].setRotationSmooth(brot)
                        floorcontent[1].setPositionSmooth(dest)
                        broadcastToAll("Player " .. pcolor .. " got a wound from the destroyed Monument floor.",pcolor)
                    end
                end
            end
            Wait.condition(floorcollapse,floorSecure)
        end
        return twistsresolved
    end
    if schemeParts[1] == "Fall of the Hulks" then
        if twistsresolved < 3 then
            broadcastToAll("Scheme Twist: Nothing yet!")
        elseif twistsresolved < 7 then
            crossDimensionalRampage("hulk")
        elseif twistsresolved < 11 then
            dealWounds()
        end
        return twistsresolved
    end
    if schemeParts[1] == "Fear Itself" then
        broadcastToAll("Scheme Twist: This Scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Ferry Disaster" then
        if twistsresolved == 1 or twistsresolved == 5 then
            ferryzones = table.clone(top_city_guids)
        end
        if twistsresolved < 5 then
            table.remove(ferryzones,1)
            local bspile = getObjectFromGUID(bystandersPileGUID)
            bspile.setPositionSmooth(getObjectFromGUID(ferryzones[1]).getPosition())
            local citycards = get_decks_and_cards_from_zone(city_zones_guids[twistsresolved+1])
            if citycards[1] then
                for _,o in pairs(citycards) do
                    if o.hasTag("Villain") then
                        bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                            flip=true,smooth=true})
                        bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                            flip=true,smooth=true})
                        broadcastToAll("Scheme Twist: Two bystanders fell from the ferry and were KO'd!")
                        break
                    end
                end
            end
        elseif twistsresolved < 9 then
            table.remove(ferryzones)
            local bspile = getObjectFromGUID(bystandersPileGUID)
            bspile.setPositionSmooth(getObjectFromGUID(ferryzones[9-twistsresolved]).getPosition())
            local citycards = get_decks_and_cards_from_zone(city_zones_guids[#ferryzones+1])
            if citycards[1] then
                for _,o in pairs(citycards) do
                    if o.hasTag("Villain") then
                        bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                            flip=true,smooth=true})
                        bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                            flip=true,smooth=true})
                        broadcastToAll("Scheme Twist: Two bystanders fell from the ferry and were KO'd!")
                        break
                    end
                end
            end
        elseif twistsresolved == 9 then
            local bspile = getObjectFromGUID(bystandersPileGUID)
            for i=1,math.floor(0.5+bspile.getQuantity()/2) do
                bspile.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                    flip=true,smooth=true})
            end
            broadcastToAll("The ferry sank. Half of all the bystanders drowned!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Find the Split Personality Killer" or schemeParts[1] == "Five Families of Crime" then
        broadcastToAll("Scheme Twist: This Scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Flood the Planet with Melted Glaciers" then
        stackTwist(cards[1])
        for i,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                if hasTag2(hero,"Cost:") <= twistsresolved then
                    koCard(hero)
                    getObjectFromGUID(o).Call('click_draw_hero')
                    broadcastToAll("Scheme Twist! Cheap hero " .. hero.getName() .. " drowned and was KO'd from the HQ!")
                end
            else
                broadcastToAll("Hero missing in hq!")
                return nil
            end
        end
        return nil
    end
    if schemeParts[1] == "Forge the Infinity Gauntlet" then
        broadcastToAll("Scheme Twist: This Scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Fragmented Realities" then
        koCard(cards[1])
        for _,o in pairs(hqZonesGUIDs) do
            local zone = getObjectFromGUID(o)
            if zone.hasTag(Turns.turn_color) then
                villain_deck_zone = o
                break
            end
        end
        playVillains(2,nil,villain_deck_zone)
        return nil
    end
    if schemeParts[1] == "Gladiator Pits of Sakaar" then
        local playzone = getObjectFromGUID("f49fc9")
        local color = Turns.turn_color
        playzone.createButton({click_function='updateTwistPower',
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            scale={0.1,0.5,1},
            label="You can only play cards from a single Team of your choice!!",
            tooltip="Play restriction because of Scheme Twist!",
            font_size=100,
            font_color={1,0.1,0},
            color={0,0,0},
            width=0})
        if Player["White"].seated then
            playzone_white = getObjectFromGUID("558e75")
            playzone_white.createButton({click_function='updateTwistPower',
                function_owner=self,
                position={0,0,0},
                scale={0.25,0.5,1},
                label="You can only play cards from a single Team of your choice!!",
                tooltip="Play restriction because of Scheme Twist!",
                font_size=75,
                font_color={1,0.1,0},
                color={0,0,0},
                width=0})
        end
        if Player["Blue"].seated then
            playzone_blue = getObjectFromGUID("2b36c3")
            playzone_blue.createButton({click_function='updateTwistPower',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                scale={0.25,0.5,1},
                label="You can only play cards from a single Team of your choice!!",
                tooltip="Play restriction because of Scheme Twist!",
                font_size=75,
                font_color={1,0.1,0},
                color={0,0,0},
                width=0})
        end
        local turnHasPassed = function()
            if Turns.getPreviousTurnColor() == color then
                return true
            else 
                return false
            end
        end
        local turnAgain = function()
            if Turns.turn_color == color then
                return true
            else 
                return false
            end
        end
        local killButton = function()
            playzone.removeButton(0)
            if Player["White"].seated then
                playzone_white.removeButton(0)
            end
            if Player["Blue"].seated then
                playzone_blue.removeButton(0)
            end
        end
        local killButtonCallback = function()
            Wait.condition(killButton,turnAgain)
        end
        Wait.condition(killButtonCallback,turnHasPassed)
    end
    if schemeParts[1] == "Go Back in Time to Slay Heroes' Ancestors" then
        broadcastToAll("Scheme Twist: Purge a hero and place it next to the scheme!")
        return twistsresolved
    end
    if schemeParts[1] == "Graduation at Xavier's X-Academy" then
        local twistpile = get_decks_and_cards_from_zone(twistZoneGUID)
        if twistpile[1] then
            broadcastToAll("Scheme Twist: Bystander moves to escape pile!")
            if twistpile[1].tag == "Deck" then
                twistpile[1].takeObject({position=getObjectFromGUID(escape_zone_guid).getPosition(),
                    flip=true,smooth=true})
            else
                twistpile[1].flip()
                twistpile[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Hail Hydra" then
        broadcastToAll("Scheme Twist: This Scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Hidden Heart of Darkness" then
        local villain_deck = get_decks_and_cards_from_zone("4bc134")
        local villaindeckcount = 0
        if villain_deck[1] then
            villaindeckcount = math.abs(villain_deck[1].getQuantity())
        end
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                local tacticFound = {}
                if vpilecontent[1] then
                    if vpilecontent[1].getQuantity() > 1  then
                        local vpileCards = vpilecontent[1].getObjects()
                        for j = 1, #vpileCards do
                            for _,k in pairs(vpileCards[j].tags) do
                                if k == "Mastermind" then
                                    table.insert(tacticFound,vpileCards[j].guid)
                                    break
                                end
                            end
                        end
                        if tacticFound[1] then
                            --random shuffle not strictly correct
                            vpilecontent[1].takeObject({position = getObjectFromGUID("4bc134").getPosition(),
                                flip=true,guid=tacticFound[math.random(#tacticFound)]})
                            villaindeckcount = villaindeckcount + 1
                        end
                    else
                        if vpilecontent[1].hasTag("Mastermind") then
                            vpilecontent[1].flip()
                            vpilecontent[1].setPositionSmooth(getObjectFromGUID("4bc134").getPosition())
                            table.insert(tacticFound,vpilecontent[1].guid)
                            villaindeckcount = villaindeckcount + 1
                        end
                    end
                    if tacticFound[1] then
                        local playerBoard = getObjectFromGUID(playerBoards[i])
                        playerBoard.Call('click_draw_card')
                        Wait.time(function() playerBoard.Call('click_draw_card') end,1)
                        printToAll(playerBoards[i] .. " player's tactic was shuffled back in the Villain deck and so they drew two cards.")
                    end
                end
            end
        end
        local tacticsAdded = function()
            local villain_deck = get_decks_and_cards_from_zone("4bc134")
            if villain_deck[1] and math.abs(villain_deck[1].getQuantity()) == villaindeckcount then
                return true
            else
                return false
            end
        end
        local tacticsFollowup = function()
            local villain_deck = get_decks_and_cards_from_zone("4bc134")
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
    if schemeParts[1] == "Horror of Horrors" then
        if twistsresolved < 6 then
            local horrorPile = getObjectFromGUID(horrorPileGUID)
            horrorPile.randomize()
            local horror = horrorPile.takeObject({position = getObjectFromGUID(topBoardGUIDs[2+twistsresolved]).getPosition(),
                flip=false,
                smooth=false})
            broadcastToAll("Scheme Twist: Random Horror was played! These are not scripted (or named) yet.")
        elseif twistsresolved == 6 then
            broadcastToAll("Scheme Twist: Evil Wins.")
        end
        return twistsresolved
    end
    if schemeParts[1] == "House of M" then
        if not noMoreMutants then
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    if hasTag2(hero,"Team:",6) and hasTag2(hero,"Team:",6) ~= "X-Men" then
                        koCard(hero)
                        broadcastToAll("Sapiens hero KO'd from the HQ!")
                        getObjectFromGUID(o).Call('click_draw_hero')
                    end
                end
            end
            local scarletWitchCount = 0
            for _,o in pairs(city) do
                local citycards = get_decks_and_cards_from_zone(o)
                if citycards[1] then
                    for _,k in pairs(citycards) do
                        if k.getName() == "Scarlet Witch (R)" then
                            scarletWitchCount = scarletWitchCount +1
                        end
                    end
                end
            end
            if scarletWitchCount > 1 then
                local scheme = get_decks_and_cards_from_zone("c39f60")
                if scheme[1] then
                    scheme[1].flip()
                    noMoreMutants = true
                    basestrength = 4
                    broadcastToAll("No More Mutants!")
                else
                    broadcastToAll("Scheme card missing?")
                end
            else
                click_draw_villain()
            end
        else
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    if hasTag2(hero,"Team:",6) and hasTag2(hero,"Team:",6) == "X-Men" then
                        koCard(hero)
                        getObjectFromGUID(o).Call('click_draw_hero')
                        broadcastToAll("Mutant hero KO'd from the HQ!")
                    end
                end
            end 
            click_draw_villain()
        end
        return twistsresolved
    end
    if schemeParts[1] == "Hydra Helicarriers Hunt Heroes" then
        stackTwist(cards[1])
        if twistsresolved < 5 then
            broadcastToAll("Scheme Twist: Choose " .. twistsresolved .. " different Hero Classes and KO each hero in the HQ that is any of them.",{1,0,0})
        else
            broadcastToAll("Scheme Twist: All heroes in the HQ with a hero class KO'd!")
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                --log(hero)
                if hero and hasTag2(hero,"HC:",4) then
                    koCard(hero)
                    getObjectFromGUID(o).Call('click_draw_hero')
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Hypnotize Every Human" then
        if twistsresolved < 7 then
            local bspile = getObjectFromGUID(bystandersPileGUID)
            for i,o in pairs(top_city_guids) do
                local topzone = getObjectFromGUID(o)
                bspile.takeObject({position = topzone.getPosition(),
                    flip=false})
            end
        elseif twistsresolved < 9 then
            broadcastToAll("Scheme Twist: Each player puts a villain from their victory pile into the escape pile (don't KO).",{1,0,0})
        end
        return twistsresolved
    end
    if schemeParts[1] == "Imprison Unregistered Superhumans" then
        if twistsresolved % 2 == 1 and twistsresolved < 10 then
            local id = math.modf(twistsresolved/2)
            if twistsresolved > 2 then
                getObjectFromGUID(fortifiedCityZoneGUID).clearButtons()
            end
            fortifiedCityZoneGUID = city_zones_guids[6 - id]
            local fortifiedCityZone = getObjectFromGUID(fortifiedCityZoneGUID)
            fortifiedCityZone.createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="+1",
                tooltip="Click to update villain's power!",
                font_size=350,
                font_color={1,0,0},
                color={0,0,0,0.75},
                width=250,height=250})
        else
            local citycards = get_decks_and_cards_from_zone(fortifiedCityZoneGUID)
            if citycards[1] then
                for _,o in pairs(citycards) do
                    if o.hasTag("Villain") then
                        getObjectFromGUID(bystandersPileGUID).takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                            flip=true})
                        broadcastToAll("Scheme Twist: Bystander KO'd!")
                        break
                    end
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Infiltrate the Lair with Spies" then
        for i,o in pairs(hqguids) do
            local cityzone = getObjectFromGUID(o)
            local bs = cityzone.Call('getBystander')
            if bs then
                bs.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                broadcastToAll("Scheme Twist: Spy escaped from the HQ with sensitive information!",{1,0,0})
            end
            if i % 2 > 0 then
                local pos = cityzone.getPosition()
                pos.z = pos.z - 2
                pos.y = pos.y + 3
                local spystack = get_decks_and_cards_from_zone(twistZoneGUID)
                if spystack[1] then
                    if spystack[1].tag == "Deck" then
                        spystack[1].takeObject({position = pos,
                            flip=true})
                    else
                        spystack[1].flip()
                        spystack[1].setPositionSmooth(pos)
                    end
                else
                    broadcastToAll("No more spies left.")
                end
            end
        end
        broadcastToAll("Scheme Twist: Three bystanders infiltrated the HQ!")
        return twistsresolved
    end
    if schemeParts[1] == "Intergalactic Kree Nega-Bomb" then
        local negabomb = get_decks_and_cards_from_zone(twistZoneGUID)
        cards[1].flip()
        cards[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
        local twistMoved = function()
            local negabomb_check = get_decks_and_cards_from_zone(twistZoneGUID)
            if negabomb_check[1] and negabomb_check[1].getQuantity() == 7 then
                return true
            else
                return false
            end
        end
        local triggerBomb = function()
            local negabomb = get_decks_and_cards_from_zone(twistZoneGUID)[1]
            negabomb.randomize()
            local negabombcontent = negabomb.getObjects()
            if negabombcontent[1].name == "Scheme Twist" then
                broadcastToAll("Scheme Twist: Nega Bomb detonated. All heroes in HQ KO'd and every player wounded.")
                negabomb.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                    flip=true})
                dealWounds()
                for _,o in pairs(hqguids) do
                    local hero = getObjectFromGUID(o).Call('getHeroUp')
                    if hero then
                        hero.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                        getObjectFromGUID(o).Call('click_draw_hero')
                    end
                end
            else
                broadcastToAll("Scheme Twist: Nega Bomb detonation averted (for now) and bystander rescued.")
                local pcolor = Turns.turn_color
                if pcolor == "White" then
                    angle = 90
                elseif pcolor == "Blue" then
                    angle = -90
                else
                    angle = 180
                end
                local brot = {x=0, y=angle, z=0}
                local playerBoard = getObjectFromGUID(playerBoards[pcolor])
                local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
                dest.y = dest.y + 3
                negabomb.takeObject({position=dest,
                    flip=true})
            end
        end
        Wait.condition(triggerBomb,twistMoved)
        return nil
    end
    if schemeParts[1] == "Invade the Daily Bugle News HQ" or schemeParts[1] == "Invasion of the Venom Symbiotes" then
        broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Invincible Force Field" then
        cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
        if twistsresolved == 1 then
            local mmzone = getObjectFromGUID("a91fe7")
            mmzone.createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0.5,0,0},
                rotation={0,180,0},
                label="+1",
                tooltip="Spend this much Recruit and Attack to fight the Mastermind",
                font_size=350,
                font_color="Yellow",
                color={0,0,0,0.75},
                width=250,height=250})
            mmzone.createButton({click_function="updateTwistPower",
                function_owner=self,
                position={-0.5,0,0},
                rotation={0,180,0},
                label="+1",
                tooltip="Spend this much Recruit and Attack to fight the Mastermind",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        elseif twistsresolved < 7 then
            local mmzone = getObjectFromGUID("a91fe7")
            mmzone.editButton({index = 0,
                label = "+" .. twistsresolved})
            mmzone.editButton({index = 1,
                label = "+" .. twistsresolved})
        else
            broadcastToAll("Scheme Twist: Evil Wins!")
        end
        return nil
    end
    if schemeParts[1] == "Last Stand at Avengers Tower" then
        stackTwist(cards[1])
        if twistsresolved == 1 then
            --may want to modify scale or dimensions
            getObjectFromGUID(city_zones_guids[4]).createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="+1",
                tooltip="Stark defenses extra Attack",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        else
            getObjectFromGUID(city_zones_guids[4]).editButton({index=0,
                label="+" .. twistsresolved})
        end
        local citycards = get_decks_and_cards_from_zone(city_zones_guids[4])
        if citycards[1] then
            for _,o in pairs(citycards) do
                if o.hasTag("Villain") then
                    broadcastToAll("Scheme Twist: KO three Heroes from the HQ!",{1,0,0})
                    break
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Massive Earthquake Generator" then
        local players = revealCardTrait("Green")
        for i,o in pairs(players) do
            local feastOn = function()
                local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
                if deck[1] and deck[1].tag == "Deck" then
                    local pos = getObjectFromGUID(kopile_guid).getPosition()
                    deck[1].takeObject({position = pos,
                        flip=true})
                    return true
                elseif deck[1] then
                    deck[1].flip()
                    koCard(deck[1])
                    return true
                else
                    return false
                end
            end
            local feasted = feastOn()
            broadcastToAll("Scheme Twist: Player " .. o.color .. " had no Green hero and KOs the top card of their deck")
            if feasted == false then
                broadcastToAll("Shuffling " .. o.color .. " player's discard pile into their deck first...")
                local discard = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
                if discard[1] then
                    getObjectFromGUID(playerBoards[o.color]).Call('click_refillDeck')
                    Wait.time(feastOn,2)
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Mass Produce War Machine Armor" then
        local twistpile = getObjectFromGUID(twistZoneGUID)
        local twistcount = get_decks_and_cards_from_zone(twistZoneGUID)
        if twistcount[1] then
            twistcountPrevious = twistcount[1].getQuantity()
        else
            twistcountPrevious = 0
        end
        stackTwist(cards[1])
        local twistMoved = function()
            local twist = get_decks_and_cards_from_zone(twistZoneGUID)
            if twist[1] and twist[1].getQuantity() ~= twistcountPrevious then
                return true
            else
                return false
            end
        end
        Wait.condition(updateTwistPower,twistMoved)
        local vpile = get_decks_and_cards_from_zone(vpileguids[Turns.turn_color])
        if vpile[1] then
            local updateAndPush = function()
                updateTwistPower()
                click_push_villain_into_city()
            end
            if vpile[1].tag == "Deck"  then
                local vpileCards = vpile[1].getObjects()
                for j = 1, vpile[1].getQuantity() do
                    if vpileCards[j].name == "S.H.I.E.L.D. Assault Squad" then
                        vpile[1].takeObject({position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                            guid=vpileCards[j].guid,
                            callback_function = updateAndPush})
                        break
                    end
                end
            else
                if vpile[1].getName() == "S.H.I.E.L.D. Assault Squad" then
                    vpile[1].clearButtons()
                    vpile[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                    local squadMoved = function()
                        local squad = get_decks_and_cards_from_zone(city_zones_guids[1])
                        if squad[1] and squad[1].getName() == "S.H.I.E.L.D. Assault Squad" then
                            return true
                        else
                            return false
                        end
                    end
                    Wait.condition(updateAndPush,squadMoved)
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Master of Tyrants" then
        if twistsresolved < 8 then
            broadcastToAll("Scheme Twist: Put this twist under a tyrant as a Dark Power!")
            powerButton(cards[1],"updateTwistPower","+2")
            cards[1].setName("Dark Power")
            return nil
        elseif twistsresolved == 8 then
            for _,o in pairs(city) do
                local citycards = get_decks_and_cards_from_zone(o)
                if citycards[1] then
                    for _,object in pairs(citycards) do
                        if object.hasTag("Tyrant") then
                            shift_to_next(citycards,getObjectFromGUID(escape_zone_guid),0)
                            broadcastToAll("Scheme Twist: A tyrant escaped!")
                            break
                        end
                    end
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Master the Mysteries of Kung-Fu" then
        stackTwist(cards[1])
        local scheme = get_decks_and_cards_from_zone("c39f60")[1]
        if twistsresolved == 1 then
            powerButton(scheme,"updateTwistPower","Kung Fu: " .. twistsstacked)
            setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Circle of Kung-Fu:[/b][-] 1")
        else
            scheme.editButton({index=0,label="Kung Fu: " .. twistsstacked})
            local notes = getNotes():gsub("Circle of Kung%-Fu:%[/b%]%[%-%] %d+","Circle of Kung-Fu:[/b][-] " .. twistsstacked,1)
            setNotes(notes)
        end
        return nil
    end
    if schemeParts[1] == "Maximum Carnage" then
        stackTwist(cards[1])
        local streetz = get_decks_and_cards_from_zone(city_zones_guids[5])
        if streetz[1] then
            for _,o in pairs(streetz) do
                if o.hasTag("Villain") then
                    dealWounds()
                    Wait.time(updateTwistPower,2)
                    return nil
                end
            end
        end
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        local possessedPsychotic = function(obj)
            obj.addTag("Possessed")
            obj.addTag("Villain")
            obj.removeTag("Bystander") -- complicates vp count!!
            local twistsstack = get_decks_and_cards_from_zone("4f53f9")
            if twistsstack[1] then
                twistsstacked = math.abs(twistsstack[1].getQuantity())
            else
                twistsstacked = 0
            end
            powerButton(obj,"updateTwistPower",twistsstacked)
            updateTwistPower()
        end
        bsPile.takeObject({position = getObjectFromGUID(city_zones_guids[5]).getPosition(),
            flip=true,
            callback_function=possessedPsychotic})
        return nil
    end
    if schemeParts[1] == "Midtown Bank Robbery" then
        local bankz = get_decks_and_cards_from_zone(city_zones_guids[3])
        if bankz[1] then
            for _,o in pairs(bankz) do
                if o.hasTag("Villain") then
                    addBystanders(city_zones_guids[3])
                    addBystanders(city_zones_guids[3])
                    break
                end
            end
        end
        click_draw_villain()
        return twistsresolved
    end
    if schemeParts[1] == "Mutant-Hunting Super Sentinels" then
        stackTwist(cards[1])
        local vildeckzone = getObjectFromGUID("4bc134")
        local vildeck = vildeckzone.getObjects()[2]
        local vildeckcurrentcount = vildeck.getQuantity()
        local sentinelsfound = 0
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = getObjectFromGUID(o).getObjects()[1]
                local copguids = {}
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
            local test = vildeckcurrentcount + sentinelsfound
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
    if schemeParts[1] == "Mutating Gamma Rays" then
        broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Negative Zone Prison Breakout" then
        playVillains(2)
        return twistsresolved
    end
    if schemeParts[1] == "Nitro the Supervillain Threatens Crowds" then
        local powerspace = nil
        local power = 0
        for _,o in pairs(city) do
            local citycards = get_decks_and_cards_from_zone(o)
            if citycards[1] then
                for _,object in pairs(citycards) do
                    if object.hasTag("Bystander") then
                        koCard(object)
                        broadcastToAll("Scheme Twist: Bystander KO'd from city!")
                    elseif object.hasTag("Villain") then
                        if powerspace == o then
                            power = power + hasTag2(object,"Power:")
                        elseif hasTag2(object,"Power:") > power then
                            powerspace = o
                            power = hasTag2(object,"Power:")
                        end
                    end
                end
            end
        end
        if powerspace then
            addBystanders(powerspace)
            addBystanders(powerspace)
            addBystanders(powerspace)
        end
        return twistsresolved
    end
    if schemeParts[1] == "Nuclear Armageddon" then
        local destroyed = table.remove(current_city)
        local escapees = get_decks_and_cards_from_zone(destroyed)
        if escapees[1] then
            shift_to_next(escapees,getObjectFromGUID(escape_zone_guid),0)
            for _,o in pairs(escapees) do
                if o.getDescription():find("LOCATION") then
                    koCard(o)
                end
            end
        end
        local setTwist = function()
            cards[1].setPositionSmooth(getObjectFromGUID(destroyed).getPosition())
        end
        Wait.time(setTwist,1)
        return nil
    end
    if schemeParts[1] == "Organized Crime Wave" then
        for _,o in pairs(city) do
            local citycards = get_decks_and_cards_from_zone(o)
            if citycards[1] then
                for _,object in pairs(citycards) do
                    if object.getName() == "Maggia Goons" then
                        shift_to_next(citycards,getObjectFromGUID(escape_zone_guid),0)
                        break
                    end
                end
            end
        end
        local vildeckzone = getObjectFromGUID("4bc134")
        local vildeckcurrentcount = get_decks_and_cards_from_zone("4bc134")[1].getQuantity()
        local goonsfound = 0
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                if vpilecontent[1] then
                    if vpilecontent[1].getQuantity() > 1  then
                        local goonguids = {}
                        local vpileCards = vpilecontent[1].getObjects()
                        for j = 1, vpilecontent[1].getQuantity() do
                            if vpileCards[j].name == "Maggia Goons" then
                                table.insert(goonguids,vpileCards[j].guid)
                            end
                        end
                        goonsfound = goonsfound + #goonguids
                        if vpilecontent[1].getQuantity() ~= #goonguids then
                            for j = 1,#copguids do
                                vpilecontent[1].takeObject({position=vildeckzone.getPosition(),
                                    guid=goonguids[j],
                                    flip=true})
                            end
                        else
                            vpilecontent[1].flip()
                            vpilecontent[1].setPositionSmooth(vildeckzone.getPosition())
                        end
                    end
                    if vpilecontent[1].getQuantity() == -1 then
                        if vpilecontent[1].getName() == "Maggia Goons" then
                            vpilecontent[1].flip()
                            vpilecontent[1].setPositionSmooth(vildeckzone.getPosition())
                            goonsfound = goonsfound + 1
                        end
                    end
                end
            end
        end
        local goonsAdded = function()
            local test = vildeckcurrentcount + goonsfound
            local vildeck = get_decks_and_cards_from_zone("4bc134")
            if vildeck[1] and vildeck[1].getQuantity() == test then
                return true
            else
                return false
            end
        end
        local goonsShuffle = function()
            if goonsfound > 0 then
                local vildeck = get_decks_and_cards_from_zone("4bc134")
                vildeck[1].randomize()
            end
        end
        Wait.condition(goonsShuffle,goonsAdded)
        return twistsresolved
    end
    if schemeParts[1] == "Pan-Dimensional Plague" then
        broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Paralyzing Venom" then
        broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Portals to the Dark Dimension" then
        if twistsresolved == 1 then
            local mmpos = getObjectFromGUID(mmZoneGUID).getPosition()
            mmpos.z = mmpos.z + 2
            mmpos.y = mmpos.y + 2
            cards[1].setPositionSmooth(mmpos)
            cards[1].setName("Dark Portal")
            powerButton(cards[1],"updateTwistPower","+1")
            broadcastToAll("Scheme Twist: A dark portal reinforces the mastermind!")
        elseif twistsresolved < 7 then
            if city[7-twistsresolved] then
                cards[1].setName("Dark Portal")
                powerButton(cards[1],"updateTwistPower","+1")
                cards[1].setDescription("LOCATION: this isn't actually a location, but the scripts treat it as one and leave it alone.")
                local citypos = getObjectFromGUID(city[7-twistsresolved]).getPosition()
                citypos.z = citypos.z + 2
                citypos.y = citypos.y + 2
                cards[1].setPositionSmooth(citypos)
                broadcastToAll("Scheme Twist: A dark portal reinforces a city space!")
            else
                koCard(cards[1])
                broadcastToAll("Scheme Twist: But the city zone does not exist? KO'ing the dark portal.")
            end
        elseif twistsresolved == 7 then
            broadcastToAll("Scheme Twist: Evil wins!")
            koCard(cards[1])
        end
        return nil
    end
    if schemeParts[1] == "Predict Future Crime" then
        local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        if vildeck then
            local vildeckcount = vildeck.getQuantity()
            local villainsfound = 0
            if vildeck.tag == "Deck" and vildeckcount > 3 then
                local vildeckcontent = vildeck.getObjects()
                local vilcheck = {}
                for j = 1,3 do
                    broadcastToAll("Card revealed from villain deck: " .. vildeckcontent[j].name)
                    for _,k in pairs(vildeckcontent[j].tags) do
                        if k == "Villain" then
                            table.insert(vilcheck,5)
                            villainsfound = villainsfound + 1
                            break
                        end
                    end
                    if not vilcheck[j] then
                        table.insert(vilcheck,2)
                    end
                end
                if villainsfound > 0 and villainsfound < 3 then
                    local playCriminals = function(obj)
                        local cardsLanded = function()
                            local test = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].getQuantity()
                            if test == vildeckcount then
                                return true
                            else
                                return false
                            end
                        end
                        local playCards = function()
                            playVillains(villainsfound)
                        end
                        Wait.condition(playCards,cardsLanded)
                    end
                    local callback_f = nil
                    for j = 1,3 do
                        if j == 3 then
                            callback_f = playCriminals
                        else
                            callback_f = nil
                        end 
                        local vildeckpos = vildeck.getPosition()
                        --add another j to prevent taken objects from spawning into a container
                        --as this prevents the callback from triggering
                        vildeckpos.y = vildeckpos.y + vilcheck[j] + j
                        vildeck.takeObject({position=vildeckpos,
                            callback_function = callback_f})
                    end
                elseif villainsfound == 3 then
                    playVillains(3)
                end
            --still script for villain decks of size 3 and 2
            elseif vildeck.tag == "Card" and vildeck.hasTag("Villain") then
                playVillain(1)
            end
        else
            broadcastToAll("Villain deck is empty?")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Pull Earth into Medieval Times" then
        if twistsresolved < 7 then
            local color = Turns.turn_color
            broadcastToAll("All enemies have Chivalrous Duel until " .. color .. "'s next turn!")
            local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
            vildeckzone.createButton({click_function='updateTwistPower',
                function_owner=self,
                position={3.4,0,0.5},
                rotation={0,180,0},
                scale={2.2,0.5,1.5},
                label="All enemies have Chivalrous Duel!",
                tooltip="Play restriction because of Scheme Twist!",
                font_size=100,
                font_color="Red",
                color={0,0,0},
                width=0})
            local turnHasPassed = function()
                if Turns.getPreviousTurnColor() == color then
                    return true
                else 
                    return false
                end
            end
            local turnAgain = function()
                if Turns.turn_color == color then
                    return true
                else 
                    return false
                end
            end
            local killButton = function()
                vildeckzone.clearButtons()
            end
            local killButtonCallback = function()
                Wait.condition(killButton,turnAgain)
            end
            Wait.condition(killButtonCallback,turnHasPassed)
        elseif twistsresolved < 10 then
            broadcastToAll("Scheme Twist: Each player puts a Villains from their Victory Pile into the Escape Pile.")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Pull Reality Into the Negative Zone" then
        local herodeckzone = getObjectFromGUID(heroDeckZoneGUID)
        local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
        if twistsresolved % 2 == 0 and twistsresolved < 7 then
            broadcastToAll("Scheme Twist: Until next twist, heroes cost attack to recruit and enemies recruit to fight!")
            herodeckzone.createButton({click_function='updateTwistPower',
                function_owner=self,
                position={4,0,0.5},
                rotation={0,180,0},
                scale={3,0.5,1.5},
                label="Heroes cost Attack to recruit!",
                tooltip="Play restriction because of Scheme Twist!",
                font_size=100,
                font_color={1,0.1,0},
                color={0,0,0},
                width=0})
            vildeckzone.createButton({click_function='updateTwistPower',
                function_owner=self,
                position={3.4,0,0.5},
                rotation={0,180,0},
                scale={2.2,0.5,1.5},
                label="Enemies cost Recruit to fight!",
                tooltip="Play restriction because of Scheme Twist!",
                font_size=100,
                font_color="Yellow",
                color={0,0,0},
                width=0})
        elseif twistsresolved < 7 and twistsresolved > 1 then
            broadcastToAll("Scheme Twist: Resource reversions are relieved!")
            herodeckzone.clearButtons()
            vildeckzone.clearButtons()
        elseif twistsresolved == 7 then
            broadcastToAll("Evil Wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Ragnarok, Twilight of the Gods" then
        broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Replace Earth's Leaders with Killbots" then
        stackTwist(cards[1])
        updateTwistPower()
        return nil
    end
    if schemeParts[1] == "Ruin the Perfect Wedding" then
        local pcolor = Turns.turn_color
        if pcolor == "White" then
            angle = 90
        elseif pcolor == "Blue" then
            angle = -90
        else
            angle = 180
        end
        local brot = {x=0, y=angle, z=0}
        local playerBoard = getObjectFromGUID(playerBoards[pcolor])
        local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
        dest.y = dest.y + 3
        if twistsresolved == 1 then
            local tobewed = get_decks_and_cards_from_zone(topBoardGUIDs[8])
            tobewed[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[7]).getPosition())
            tobewed[1].takeObject({position = dest,rotation = brot})
            broadcastToAll("Scheme Twist: Hero " .. schemeParts[9]:gsub(".*%|","") .. " moved to the altar!")
        elseif twistsresolved == 2 then
            local tobewed = get_decks_and_cards_from_zone(topBoardGUIDs[1])
            tobewed[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
            tobewed[1].takeObject({position = dest,rotation = brot})
            broadcastToAll("Scheme Twist: Hero " .. schemeParts[9]:gsub("%|.*","") .. " moved to the door!")
        elseif twistsresolved < 8 then
            broadcastToAll("Scheme Twist: Gain the top card of one of the hero stacks. Then, KO two cards from each hero stack if an enemy occupies the city space below it. Then move the left stack one space to the right (don't merge them).")
        elseif twistsresolved < 12 then
            broadcastToAll("Scheme Twist: KO two cards from each hero stack.")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Save Humanity" then
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getBystander')
            if hero and hero.hasTag("Bystander") then
                koCard(hero)
                getObjectFromGUID(o).Call('click_draw_hero')
                broadcastToAll("Scheme Twist: Bystander KO'd from the HQ!")
            end
        end
        broadcastToAll("Scheme Twist: Each player reveals a Yellow Hero or KOs a Bystander from their Victory Pile.") 
        return twistsresolved
    end
    if schemeParts[1] == "Scavenge Alien Weaponry" then
        playVillains(2)
        return twistsresolved
    end
    if schemeParts[1] == "Secret Empire of Betrayal" then
        cards[1].flip()
        cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[5]).getPosition())
        local twistAdded = function()
            local darkloyalty = get_decks_and_cards_from_zone(topBoardGUIDs[5])
            if darkloyalty[1] and darkloyalty[1].getQuantity() == 6 then
                return true
            else
                return false
            end
        end
        local twistPlay = function()
            local darkloyalty = get_decks_and_cards_from_zone(topBoardGUIDs[5])
            darkloyalty[1].randomize()
            local darkCard = darkloyalty[1].getObjects()[1]
            if darkCard.name == "Scheme Twist" then
                darkloyalty[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                    flip=true})
                for i,_ in pairs(playerBoards) do
                    if Player[i].seated == true and i ~= Turns.turn_color then
                        click_get_wound(nil,i)
                        broadcastToAll("Scheme Twist: Vicious Betrayal!")
                    end
                end
            else
                local pcolor = Turns.turn_color
                if pcolor == "White" then
                    angle = 90
                elseif pcolor == "Blue" then
                    angle = -90
                else
                    angle = 180
                end
                local brot = {x=0, y=angle, z=0}
                local playerBoard = getObjectFromGUID(playerBoards[pcolor])
                local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
                dest.y = dest.y + 3
                darkloyalty[1].takeObject({position = dest,
                    flip=true})
                broadcastToAll("Scheme Twist: " .. pcolor .. " player gained a random hero!")
            end
        end
        Wait.condition(twistPlay,twistAdded)
        return nil
    end
    if schemeParts[1] == "Secret HYDRA Corruption" then
        local twistpile = getObjectFromGUID(twistZoneGUID)
        local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)[1]
        if not scheme then
            broadcastToAll("Scheme card missing???")
            return nil
        end
        if twistsresolved == 1 then
            officerdeck = getObjectFromGUID(officerDeckGUID)
            twistpile.createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="3",
                tooltip="Pay 3 Recruit to have any player gain one of these Officers.",
                font_size=350,
                font_color="Yellow",
                color={0,0,0,0.75},
                width=250,height=250})
        end
        if scheme.is_face_down == false then
            scheme.flip()
            twistpile.editButton({tooltip = "Fight for 3 to return any of these officers to the Officer deck and KO one of your heroes.",
                font_color = "Red"})
        else
            scheme.flip()
            twistpile.editButton({tooltip = "Pay 3 Recruit to have any player gain one of these Officers.",
                font_color = "Yellow"})
        end
        for i = 1,twistsresolved do
            if officerdeck.getQuantity() > 1 then
                officerdeck.takeObject({position=twistpile.getPosition(),
                    flip=true,
                    smooth=true})
                if officerdeck.remainder then
                    officerdeck = officerdeck.remainder
                end
            else
                officerdeck.flip()
                officerdeck.setPositionSmooth(twistpile.getPosition())
                officerdeck = nil
                break
            end
        end
        if not officerdeck then
            broadcastToAll("Officer deck ran out. Evil wins!",{1,0,0})
        end
        return twistsresolved
    end
    if schemeParts[1] == "Secret Invasion of the Skrull Shapeshifters" then
        koCard(cards[1])
        local cost = 0
        local highestguid = nil
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero and hasTag2(hero,"Cost:") > cost then
                cost = hasTag2(hero,"Cost:")
                highestguid = hero.guid
            elseif hero and hasTag2(hero,"Cost:") == cost then
                highestguid = highestguid .. "|" .. hero.guid
            end
        end
        if highestguid:find("%|") then
            broadcastToAll("Choose one of the highest cost heroes in the HQ and have it enter the city from the enter city spot.")
        else
            local hero = getObjectFromGUID(highestguid)
            hero.setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            local pushHero = function()
                Wait.time(click_push_villain_into_city,0.5)
            end
            local heroMoved = function()
                local entercard = get_decks_and_cards_from_zone(city_zones_guids[1])
                if entercard[1] and entercard[1].guid == highestguid then
                    return true
                else
                    return false
                end
            end
            Wait.condition(pushHero,heroMoved)
        end
        return nil
    end
    if schemeParts[1] == "Secret Wars" then
        if twistsresolved < 4 then
            local mmPile = getObjectFromGUID(mmPileGUID)
            mmPile.randomize()
            local stripTactics = function(obj)
                obj.flip()
                table.insert(mmStorage,obj.getName())
                mmLocations[obj.getName()] = topBoardGUIDs[4+2*(twistsresolved-1)]
                getObjectFromGUID("912967").Call('updateMM')
                getObjectFromGUID("912967").Call('setupMasterminds',obj.getName())
                local keep = math.random(4)
                local tacguids = {}
                for i = 1,4 do
                    table.insert(tacguids,obj.getObjects()[i].guid)
                end
                local tacticsPile = getObjectFromGUID(topBoardGUIDs[2])
                for i = 1,4 do
                    if i ~= keep then
                        obj.takeObject({position = tacticsPile.getPosition(),
                            guid = tacguids[i],
                            flip = true})
                    end
                end
                local flipTactics = function()
                    if obj then
                        local pos = obj.getPosition()
                        pos.y = pos.y + 3
                        obj.takeObject({position = pos,
                            index = obj.getQuantity()-1,
                            flip=true})
                    end
                end
                Wait.time(flipTactics,1)
            end
            mmPile.takeObject({position = getObjectFromGUID(topBoardGUIDs[4+2*(twistsresolved-1)]).getPosition(),callback_function = stripTactics})
        elseif twistsresolved == 8 then
            broadcastToAll("Scheme Twist: Evil Wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "S.H.I.E.L.D. vs. HYDRA War" then
        local officerdeck = getObjectFromGUID(officerDeckGUID)
        local twistpilecontent = get_decks_and_cards_from_zone(twistZoneGUID)
        if twistsresolved == 1 then
            getObjectFromGUID(twistZoneGUID).createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="3",
                tooltip="Fight for 3 to gain any of these Officers as heroes or send them Undercover to your Victory Pile.",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        end
        if twistpilecontent[1] then
            broadcastToAll("Scheme Twist: An Officer escaped! HYDRA level increased!")
            if twistpilecontent[1].tag == "Deck" then
                local bottomRest = function(obj)
                    local twistpilecontent = get_decks_and_cards_from_zone(twistZoneGUID)
                    twistpilecontent[1].flip()
                    twistpilecontent[1].setPositionSmooth(officerdeck.getPosition())
                end
                twistpilecontent[1].takeObject({position=getObjectFromGUID(escape_zone_guid).getPosition(),
                    callback_function = bottomRest})
            else
                twistpilecontent[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
            end
        end
        for i = 1,#Player.getPlayers() do
            officerdeck.takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
                flip=true})
        end
        return twistsresolved
    end
    if schemeParts[1] == "Silence the Witnesses" then
        local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
        if not scheme[1] then
            broadcastToAll("Scheme card missing?")
            return nil
        elseif scheme[1] and scheme[2] then
            for _,o in pairs(scheme) do
                if string.lower(o.getName()) ~= string.lower(schemeParts[1]) then
                    o.flip()
                    o.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                end
            end
        end
        addBystanders(schemeZoneGUID,false)
        addBystanders(schemeZoneGUID,false)
        addBystanders(schemeZoneGUID,false)
        return twistsresolved
    end
    if schemeParts[1] == "Sinister Ambitions" then
        stackTwist(cards[1])
        if twistsresolved < 6 then
            updateTwistPower()
            playVillains(1)
        elseif twistsresolved == 6 then
            koCard(cards[1])
            for _,o in pairs(city) do
                local citycards = get_decks_and_cards_from_zone(o)
                if citycards[1] then
                    for _,o in pairs(citycards) do
                        if o.hasTag("Ambition") then
                           shift_to_next(citycards,getObjectFromGUID(escape_zone_guid),0)
                           broadcastToAll("Scheme Twist: Ambition villain escapes!")
                           break
                        end
                    end
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Splice Humans with Spider DNA" then
        broadcastToAll("Each player puts a Sinister Six villain from their Victory Pile on top of the villain deck. Then, play a single card from the villain deck.")
        return twistsresolved
    end
    if schemeParts[1] == "Steal All Oxygen on Earth" then
        stackTwist(cards[1])
        local notes = getNotes():gsub("Oxygen Level:%[/b%]%[%-%] %d+","Oxygen Level:[/b][-] " .. 8-twistsstacked,1)
        setNotes(notes)
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero and hasTag2(hero,"Cost:") > 8 - twistsstacked then
                koCard(hero)
                getObjectFromGUID(o).Call('click_draw_hero')
                broadcastToAll("Scheme Twist: " .. hero.getName() .. " suffocated and was KO'd")
            end
        end
        return nil
    end
    if schemeParts[1] == "Steal the Weaponized Plutonium" then
        cards[1].setDescription("VILLAINOUS WEAPON: This plutonium gives +1. Shuffle it back into the villain deck if the villain holding it is defeated.")
        powerButton(cards[1],"updateTwistPower","+1")
        --these will often become stacks and that will kill the button...
        playVillains(1)
        return twistsresolved
    end
    if schemeParts[1] == "Subjugate with Obedience Disks" then
        broadcastToAll("Put this twist in one of the zones above the board. A zone cannot have more than two twists in it.")
        function onObjectEnterZone()
            updateHQTags()
            Wait.time(updateHQTags,1)
        end
        return nil
    end
    if schemeParts[1] == "Super Hero Civil War" then
        broadcastToAll("Scheme Twist: All heroes in the HQ KO'd")
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                koCard(hero)
                getObjectFromGUID(o).Call('click_draw_hero')
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Symbiotic Absorption" then
        local mmZone=getObjectFromGUID(mmZoneGUID)
        if twistsresolved < 5 then
            local mmcards = get_decks_and_cards_from_zone(mmZoneGUID)
            local mmcount = 0
            if mmcards[1] then
                for _,o in pairs(mmcards) do
                    if o.is_face_down == true then
                        mmcount = math.abs(o.getQuantity())
                    end
                end
            else
                broadcastToAll("No mastermind found?")
                return nil
            end
            local mmshuffle = function(obj)
                local mmcards = get_decks_and_cards_from_zone(mmZoneGUID)
                local pos = getObjectFromGUID(mmZoneGUID).getPosition()
                pos.y = pos.y + 3
                if mmcards[1] then
                    for _,o in pairs(mmcards) do
                        if o.is_face_down == false then
                            o.setPositionSmooth(pos)
                            break
                        end
                    end
                end
                local mmSepShuffle = function()
                    local mmcards = get_decks_and_cards_from_zone(mmZoneGUID)
                    mmcards[1].randomize()
                    log("Mastermind tactics shuffled")
                end
                Wait.time(mmSepShuffle,1)
            end
            local tacticMoved = function()
                local mmcards = get_decks_and_cards_from_zone(mmZoneGUID)
                if mmcards[1] then
                    for _,o in pairs(mmcards) do
                        if o.is_face_down == true then
                            if mmcount == math.abs(o.getQuantity())-1 then
                                return true
                            end
                        end
                    end
                    return false
                else
                    return false
                end
            end
            local drainedmm = get_decks_and_cards_from_zone(topBoardGUIDs[1])
            if drainedmm[1] then
                for _,o in pairs(drainedmm) do
                    if o.is_face_down == true then
                        if o.getQuantity() > 1 then
                            o.takeObject({position = mmZone.getPosition()})
                        else
                            o.setPositionSmooth(mmZone.getPosition())
                        end
                        Wait.condition(mmshuffle,tacticMoved)
                    end
                end
            else
                broadcastToAll("Drained mastermind not found.")
                return nil
            end
        elseif twistsresolved % 2 == 0 and twistsresolved < 11 then
            broadcastToAll("Scheme Twist: This twist copies the master strike effect of the drained mastermind!")
        elseif twistsresolved == 11 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Televised Deathtraps of Mojoworld" then
        stackTwist(cards[1])
        broadcastToAll("Scheme Twist: Fight the deathtraps (click the value hovering the scheme card) before end of turn or every player gets a wound!")
        resolveDeathtraps = function(obj,player_clicker_color)
            broadcastToAll("Deathtraps averted by player " .. player_clicker_color)
            obj.clearButtons()
        end
        local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
        if scheme[1] then
            powerButton(scheme[1],"resolveDeathtraps",twistsstacked,nil,"Resolve the deathtraps by spending this much Attack.")
            local pcolor = Turns.turn_color
            local turnChanged = function()
                if Turns.turn_color == pcolor then
                    return false
                else
                    return true
                end
            end
            local deathTrapsActivated = function()
                local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
                if scheme[1] and scheme[1].getButtons() then
                    scheme[1].clearButtons()
                    broadcastToAll("Death traps activated. Each player gains a wound.")
                    dealWounds()
                elseif not scheme[1] then
                    broadcastToAll("Scheme card not found?")
                end
            end
            Wait.condition(deathTrapsActivated,turnChanged)
        else
            broadcastToAll("Scheme card not found?")
        end
        return nil
    end
    if schemeParts[1] == "The Dark Phoenix Saga" then
        local kopilecontent = get_decks_and_cards_from_zone(kopile_guid)
        local vildeckZone = getObjectFromGUID(villainDeckZoneGUID)
        local jeanfound = 0
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
        local vildeckcount = 0
        if vildeck[1] then
            vildeckcount = vildeck[1].getQuantity()
        end
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
            local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
            if vildeck[1] and vildeck[1].getQuantity() == vildeckcount + jeanfound then
                return true
            else
                return false
            end
        end
        local shufflejean = function()
            local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
            vildeck[1].randomize()
        end
        Wait.condition(shufflejean,jeangreyadded)
        return twistsresolved
    end
    if schemeParts[1] == "The Demon Bear Saga" then
        koCard(cards[1])
        --check if Bear is in the city
        for _,o in pairs(city) do
            local cityobjects = get_decks_and_cards_from_zone(o)
            if cityobjects[1] then
                for _,object in pairs(cityobjects) do
                    if object.getName() == "Demon Bear" then
                        shift_to_next(cityobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                        broadcastToAll("Scheme Twist! Demon Bear escapes!",{1,0,0})
                        return nil
                    end
                end
            end
        end
        --or his starting spot
        local cityobjects = get_decks_and_cards_from_zone(twistZoneGUID)
        if cityobjects[1] and cityobjects[1].getName() == "Demon Bear" then
            cityobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
            local bearMoved = function()
                local bear = get_decks_and_cards_from_zone(city_zones_guids[1])
                if bear[1] and bear[1].getName() == "Demon Bear" then
                    return true
                else
                    return false
                end
            end
            Wait.condition(click_push_villain_into_city,bearMoved)
            broadcastToAll("Scheme Twist! The Demon Bear entered the city.",{1,0,0})
            return nil
        end
        --or the escape pile
        local escapedobjects = get_decks_and_cards_from_zone(escape_zone_guid)
        if escapedobjects[1] and escapedobjects[1].tag == "Deck" then
            for _,object in pairs(escapedobjects[1].getObjects()) do
                if object.name == "Demon Bear" then
                    escapedobjects[1].takeObject({guid=object.guid,
                        position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                        smooth=true,
                        callback_function = click_push_villain_into_city})
                    broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the escape pile.",{1,0,0})
                    return nil
                end
            end
        elseif escapedobjects[1] and escapedobjects[1].tag == "Card" then
            if escapedobjects[1].getName() == "Demon Bear" then
                escapedobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                local bearMoved = function()
                    local bear = get_decks_and_cards_from_zone(city_zones_guids[1])
                    if bear[1] and bear[1].getName() == "Demon Bear" then
                        return true
                    else
                        return false
                    end
                end
                Wait.condition(click_push_villain_into_city,bearMoved)
                broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the escape pile.",{1,0,0})
                return nil
            end
        end
        --or the victory pile
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpobjects = get_decks_and_cards_from_zone(o)
                if vpobjects[1] and vpobjects[1].tag == "Deck" then
                    for _,object in pairs(vpobjects[1].getObjects()) do
                        if object.name == "Demon Bear" then
                            vpobjects[1].takeObject({guid=object.guid,
                                position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                                smooth=true,
                                callback_function = click_push_villain_into_city})
                            broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                            click_rescue_bystander(nil,i)
                            click_rescue_bystander(nil,i)
                            click_rescue_bystander(nil,i)
                            click_rescue_bystander(nil,i)
                            return nil
                        end
                    end
                elseif vpobjects[1] and vpobjects[1].tag == "Card" then
                    if vpobjects[1].getName() == "Demon Bear" then
                        vpobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                        local bearMoved = function()
                            local bear = get_decks_and_cards_from_zone(city_zones_guids[1])
                            if bear[1] and bear[1].getName() == "Demon Bear" then
                                return true
                            else
                                return false
                            end
                        end
                        Wait.condition(click_push_villain_into_city,bearMoved)
                        broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                        click_rescue_bystander(nil,i)
                        click_rescue_bystander(nil,i)
                        click_rescue_bystander(nil,i)
                        click_rescue_bystander(nil,i)
                        return nil
                    end
                end
            end
        end
        local kodobjects = get_decks_and_cards_from_zone(kopile_guid)
        if kodobjects[1] and kodobjects[1].tag == "Deck" then
            for _,object in pairs(kodobjects[1].getObjects()) do
                if object.name == "Demon Bear" then
                    kodobjects[1].takeObject({guid=object.guid,
                        position=getObjectFromGUID(city_zones_guids[1]).getPosition(),
                        smooth=true,
                        callback_function = click_push_villain_into_city})

                    broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the KO pile.",{1,0,0})
                    return nil
                end
            end
        elseif kodobjects[1] and kodobjects[1].tag == "Card" then
            if kodobjects[1].getName() == "Demon Bear" then
                kodobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                local bearMoved = function()
                    local bear = get_decks_and_cards_from_zone(city_zones_guids[1])
                    if bear[1] and bear[1].getName() == "Demon Bear" then
                        return true
                    else
                        return false
                    end
                end
                Wait.condition(click_push_villain_into_city,bearMoved)
                broadcastToAll("Scheme Twist! The Demon Bear re-entered the city from the KO pile.",{1,0,0})
                return nil
            end
        end
        --thor not found
        broadcastToAll("The Demon Bear not found? Where is he?")
        return nil
    end
    if schemeParts[1] == "The Fountain of Eternal Life" then
        broadcastToAll("Scheme Twist: A villain from your victory pile enters the sewers. Please choose one! Twist card put on bottom of villain deck.")
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
        if vildeck[1] then
            local pos = vildeck[1].getPosition()
            pos.y = pos.y + 3
            vildeck[1].setPositionSmooth(pos)
        end
        cards[1].flip()
        cards[1].setPositionSmooth(getObjectFromGUID(villainDeckZoneGUID).getPosition())
        return nil
    end
    if schemeParts[1] == "The God-Emperor of Battleworld" then
        if twistsresolved == 1 then
            local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
            if scheme[1] then
                broadcastToAll("Scheme Twist: The scheme ascended to be a Mastermind!")
                powerButton(scheme[1],"updateTwistPower",9)
                scheme[1].addTag("Mastermind")
                scheme[1].addTag("VP9")
            else
                broadcastToAll("Missing scheme card?")
                return nil    
            end
        elseif twistsresolved < 7 then
            stackTwist(cards[1])
            local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
            if scheme[1] then 
                scheme[1].editButton({label = 9 + 2*twistsstacked})
            end
            return nil
        elseif twistsresolved == 7 then
            local mm =get_decks_and_cards_from_zone(mmZoneGUID)
            broadcastToAll("Scheme Twist: The God-Emperor KO'd the mastermind! KO any other remaining masterminds other than the God-Emperor!")
            if mm[1] then
                for _,o in pairs(mm) do
                    if o.is_face_down then
                        o.flip()
                    end
                    koCard(o)
                end
            end
        elseif twistsresolved == 8 then
            broadcastToAll("Scheme Twist: Evil Wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "The Mark of Khonshu" then
        playVillains(2)
        return twistsresolved
    end
    if schemeParts[1] == "Tornado of Terrigen Mists" then
        koCard(cards[1])
        if twistsresolved == 6 then
            invertedcity = {}
            for i=1,5 do
                table.insert(invertedcity,city[6-i])
            end
        end
        if twistsresolved == 1 then
            local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
            if scheme[1] then
                scheme[1].setPositionSmooth(getObjectFromGUID(hqZonesGUIDs[5]).getPosition())
            else
                broadcastToAll("Scheme card missing?")
                return nil
            end
        elseif twistsresolved < 6 then
            local citycontent = getObjectFromGUID(city[twistsresolved-1]).getObjects()
            if citycontent then
                for _,o in pairs(citycontent) do
                    if o.tag == "Figurine" then
                        click_get_wound(nil,o.getName():gsub(" Player",""))
                    end
                end
            end
            local scheme = get_decks_and_cards_from_zone(hqZonesGUIDs[7-twistsresolved])[1]
            scheme.setPositionSmooth(getObjectFromGUID(hqZonesGUIDs[6-twistsresolved]).getPosition())
            Wait.time(click_push_villain_into_city,1)
        elseif twistsresolved < 10 then
            local citycontent = getObjectFromGUID(invertedcity[twistsresolved-5]).getObjects()
            if citycontent then
                for _,o in pairs(citycontent) do
                    if o.tag == "Figurine" then
                        click_get_wound(nil,o.getName():gsub(" Player",""))
                    end
                end
            end
            local scheme = get_decks_and_cards_from_zone(hqZonesGUIDs[twistsresolved-5])[1]
            scheme.setPositionSmooth(getObjectFromGUID(hqZonesGUIDs[twistsresolved-4]).getPosition())
            local inverted_push = function()
                local city_topush = table.clone(invertedcity)
                local cardfound = false
                while cardfound == false do
                    local cards = get_decks_and_cards_from_zone(city_topush[1])
                    local locationfound = false
                    if cards[1] and not cards[2] then
                        if cards[1].getDescription():find("LOCATION") then
                            locationfound = true
                        end
                    end
                    if not next(cards) or locationfound == true then
                        table.remove(city_topush,1)
                    else
                        cardfound = true
                    end
                    if not city_topush[1] then
                        cardfound = true
                    end
                end
                if city_topush[1] then
                    push_all(city_topush)
                end
            end
            Wait.time(inverted_push,1)
        end
        return nil
    end
    if schemeParts[1] == "Transform Citizens Into Demons" then
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        if twistsresolved == 1 then
            getObjectFromGUID(twistZoneGUID).createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="2",
                tooltip="Fight for 2 to rescue one of these bystanders.",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
            getObjectFromGUID(twistZoneGUID).createButton({click_function="updateTwistPower",
                function_owner=self,
                position={0,0,1},
                rotation={0,180,0},
                label="(5)",
                tooltip="5 Bystanders remaining",
                font_size=350,
                font_color="White",
                color={0,0,0,0.75},
                width=250,height=250})
        end
        for i=1,5 do
            bsPile.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                smooth = true})
        end
        function onObjectEnterZone(zone,object)
            if zone == getObjectFromGUID(twistZoneGUID) then
                local goblin = get_decks_and_cards_from_zone(twistZoneGUID)
                if goblin[1] then
                    goblincount = math.abs(goblin[1].getQuantity())
                else
                    goblincount = 0
                end
                zone.editButton({index=1,
                    label="(" .. goblincount .. ")",
                    tooltip=goblincount .. " Bystanders remaining"})
                updateTwistPower()
            end
        end
        function onObjectLeaveZone(zone,object)
            if zone == getObjectFromGUID(twistZoneGUID) then
                local goblin = get_decks_and_cards_from_zone(twistZoneGUID)
                if goblin[1] then
                    goblincount = math.abs(goblin[1].getQuantity())
                else
                    goblincount = 0
                end
                zone.editButton({index=1,
                    label="(" .. goblincount .. ")",
                    tooltip=goblincount .. " Bystanders remaining"})
                updateTwistPower()
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Turn the Soul of Adam Warlock" then
        local adam = get_decks_and_cards_from_zone(topBoardGUIDs[1])
        local setUnPure = function(obj)
            obj.addTag("Unpure")
        end
        if adam[1] then
            adam[1].takeObject({position = self.getPosition(),
                callback_function = setUnPure})
            broadcastToAll("Scheme Twist: Purify Adam or his soul becomes more corrupted!")
        else
            broadcastToAll("Adam not found?")
        end
        return twistsresolved
    end
    if schemeParts[1] == "United States Split by Civil War" then
        for i=4,5 do
            local cardz = get_decks_and_cards_from_zone(city[i])
            if cardz[1] then
                for _,o in pairs(cardz) do
                    if o.hasTag("Villain") then
                        cards[1].setPositionSmooth(getObjectFromGUID(top_city_guids[5]).getPosition())
                        broadcastToAll("Scheme Twist! Western State Victory!")
                        return nil
                    end
                end
            end
        end
        local cardz = get_decks_and_cards_from_zone(city[1])
        if cardz[1] then
            for _,o in pairs(cardz) do
                if o.hasTag("Villain") then
                    cards[1].setPositionSmooth(getObjectFromGUID(top_city_guids[1]).getPosition())
                    broadcastToAll("Scheme Twist! Eastern State Victory!")
                    return nil
                end
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Unleash the Power of the Cosmic Cube" then
        stackTwist(cards[1])
        if twistsresolved == 5 or twistsresolved == 6 then
            dealWounds()
        elseif twistsresolved == 7 then
            dealWounds()
            dealWounds()
            dealWounds()
        elseif twistsresolved == 8 then
            broadcastToAll("Cosmic Cube UNLEASHED!! Evil wins",{1,0,0})
        end
        return nil
    end
    if schemeParts[1] == "Weave a Web of Lies" then
        stackTwist(cards[1])
        return nil
    end
    return twistsresolved
end

function retrieveMM()
    mmStorage = table.clone(getObjectFromGUID("912967").Call('returnMM'))
    log(mmStorage)
    mmLocations = table.clone(getObjectFromGUID("912967").Call('returnMMLocation'),true)
    log(mmLocations)
end

function returnMM(loc)
    if loc then
        return(table.clone(mmLocations,true))
    else
        return(table.clone(mmStorage))
    end
end

function strikeSpecials(cards,city)
    if not mmStorage[1] then
        broadcastToAll("No mastermind specified!")
        return nil
    elseif mmStorage[2] then
        broadcastToAll("Multiple masterminds. Resolve effects manually in the order of your choice.")
        local mmpromptzone = getObjectFromGUID(city_zones_guids[4])
        local zshift = 0
        local resolvingStrikes = {}
        for i,o in ipairs(mmStorage) do
            resolvingStrikes[i] = i-1
            _G["resolveStrike" .. i] = function()
                --log("buttonpress:" .. resolvingStrikes[i])
                mmpromptzone.removeButton(resolvingStrikes[i])
                for i2,o2 in pairs(resolvingStrikes) do
                    if i2 > i then
                        resolvingStrikes[i2] = o2-1
                    end
                end
                local proceed = resolveStrike(o,epicness,city,cards)
                if not proceed then
                    cards[1] = nil
                elseif cards[1] and not mmpromptzone.getButtons() then
                    koCard(cards[1])
                end
            end
            mmpromptzone.createButton({click_function="resolveStrike" .. i,
                function_owner=self,
                position={0,0,zshift},
                rotation={0,180,0},
                label=o,
                tooltip="Resolve the Master Strike effect of " .. o,
                font_size=100,
                font_color="Black",
                color={1,0.64,0},
                width=1500,height=50})
            zshift = zshift + 0.5
        end
        return nil
    else
        mmname = mmStorage[1]
    end
    local epicness = false
    if mmname:find(" %- epic") then
        mmname = mmname:gsub(" %- epic","")
        epicness = true
    end
    local proceed = resolveStrike(mmname,epicness,city,cards)
    if proceed then
        return strikesresolved
    else
        return nil
    end
end

function msno(mmname)
    broadcastToAll("Master Strike: " .. mmname .. " wasn't scripted yet.")
end

function resolveStrike(mmname,epicness,city,cards)
    if mmname:find("Ascended Baron") then
        local vp = tonumber(mmname:match("%(%d+%)"):match("%d+"))
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            for i,obj in ipairs(handi) do
                if vp == 0 then
                    if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") ~= vp then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                else
                    if not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") ~= vp then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
            end
            if hand[1] then
                promptDiscard(o.color,hand)
                broadcastToColor("Master Strike: Discard a hero with cost " .. vp,o.color,o.color)
            end
        end
        return strikesresolved
    end
    local mmloc = nil
    local strikeloc = nil
    if not mmLocations[mmname] then
        broadcastToAll("Mastermind " .. mmname .. " not found?")
        return nil
    elseif mmLocations[mmname] == mmZoneGUID then
        mmloc = mmZoneGUID
        strikeloc = strikeZoneGUID
    else
        mmloc = mmLocations[mmname]
        for i,o in pairs(topBoardGUIDs) do
            if o == mmloc then
                strikeloc = topBoardGUIDs[i-1]
                break
            end
        end
    end
    if mmname == "Adrian Toomes" then
        msno(mmname)
        return nil
    end
    if mmname == "Apocalypse" then
        local playercolors = Player.getPlayers()
        broadcastToAll("Master Strike: Each player puts all cards costing more than 0 on top of their deck.")
        for i=1,#playercolors do
            local hand = playercolors[i].getHandObjects()
            if hand[1] then
                for _,o in pairs(hand) do
                    if hasTag2(o,"Cost:") and hasTag2(o,"Cost:") > 0 then
                        o.flip()
                        local dest = getObjectFromGUID(playerBoards[playercolors[i].color]).positionToWorld({0.957, 0.178, 0.222})
                        o.setPosition(dest)
                    end
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Arcade" then
        local playercolors = Player.getPlayers()
        local shieldspresent = get_decks_and_cards_from_zone(strikeloc)
        local shieldcount = 0
        if shieldspresent[1] then
            shieldcount = math.abs(shieldspresent[1].getQuantity())
        end
        local bsadded = 0
        for i=1,#playercolors do
            local vpile = get_decks_and_cards_from_zone(vpileguids[playercolors[i].color])
            if vpile[1] and vpile[1].tag == "Deck" then
                local bsguids = {}
                for _,o in pairs(vpile[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k == ("Bystander") then
                            table.insert(bsguids,o.guid)
                            break
                        end
                    end
                end
                if bsguids[1] and epicness == false then
                    bsadded = bsadded + 1
                    vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                        flip=true,
                        guid=bsguids[math.random(#bsguids)],
                        smooth=true})
                elseif epicness == true and bsguids[2] then
                    bsadded = bsadded + 2
                    for i=1,2 do
                        local guid = table.remove(bsguids,math.random(#bsguids)-1)
                        vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                            flip=true,
                            guid=guid,
                            smooth=true})
                    end
                else
                    click_get_wound(nil,playercolors[i].color)
                end
            elseif vpile[1] and vpile[1].tag == "Card" and epicness == false then
                if vpile[1].hasTag("Bystander") then
                    bsadded = bsadded + 1
                    vpile[1].flip()
                    vpile[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                else
                    click_get_wound(nil,playercolors[i].color)
                end
            else
                click_get_wound(nil,playercolors[i].color)
            end
        end
        if bsadded > 0 then
            local shuffleShields = function()
                get_decks_and_cards_from_zone(strikeloc)[1].randomize()
            end
            local shieldsAdded = function()
                local shields = get_decks_and_cards_from_zone(strikeloc)
                if shields[1] and math.abs(shields[1].getQuantity()) == bsadded + shieldcount then
                    return true
                else
                    return false
                end
            end
            Wait.condition(shuffleShields,shieldsAdded)
        end
        return strikesresolved
    end
    if mmname == "Arnim Zola" then
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
        if herodeck then
            bump(herodeck)
        end
        local costs = table.clone(herocosts)
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero and (not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < 2) then
                hero.flip()
                costs[hasTag2(hero,"Cost:")] = costs[hasTag2(hero,"Cost:")] + 1
                hero.setPositionSmooth(getObjectFromGUID(heroDeckZoneGUID).getPosition())
                getObjectFromGUID(o).Call('click_draw_hero')
            end
        end
        broadcastToAll("Master Strike! Weak heroes in HQ replaced with new ones. Discard cards with the same cost as the heroes replaced in the HQ (Automatically, unless there are ties).")
        demolish(nil,1,costs)
        return strikesresolved
    end
    if mmname == "Authoritarian Iron Man" then
        local mm = nil
        local pos = nil
        if not current_city[#current_city-strikesresolved+1] then
            broadcastToAll("Master Strike: City too small for " .. mmname .. " to move!")
            return strikesresolved
        else
            pos = getObjectFromGUID(current_city[#current_city-strikesresolved+1]).getPosition()
            pos.z = pos.z+2
        end
        if strikesresolved == 1 then
            mm = get_decks_and_cards_from_zone(mmloc)
            if mm[1] then
                for _,o in pairs(mm) do
                    if o.getName() == "Authoritarian Iron Man" and o.tag == "Card" then
                        powerButton(o,"updateTwistPower","+3",{0,22,8})
                        o.setDescription(o.getDescription() .. "\r\nLOCATION: Keyword to indicate he's only fortifying this space.")
                        break
                    end
                end
            else
                broadcastToAll("Master Strike: Authoritarian Iron Man not found?")
                return nil
            end
        elseif strikesresolved < 6 then
            mm = get_decks_and_cards_from_zone(current_city[#current_city-strikesresolved+2])
            --what happens to iron man if his city space is destroyed?
        else
            return strikesresolved
        end
        if not mm[1] then
            broadcastToAll("Master Strike: Authoritarian Iron Man not found?")
            return nil
        else
            for _,o in pairs(mm) do
                if strikesresolved > 1 or (o.getName() == "Authoritarian Iron Man" and o.tag == "Card") then
                    o.setPositionSmooth(pos)
                    broadcastToAll("Master Strike: Authoritarian Iron Man fortifies a new city space!")
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Baron Heinrich Zemo" then
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    local bsguids = {}
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        for _,l in pairs(k.tags) do
                            if l == "Bystander" then
                                bsguids[k.name] = k.guid
                                break
                            end
                        end
                    end
                    if next(bsguids) then
                        local bsnr = math.random(#bsguids)
                        local step = 1
                        for name,guid in pairs(bsguids) do
                            if step == bsnr then
                                if name == "Card" then
                                    name = ""
                                end
                                broadcastToColor("Master Strike: Random bystander " .. name .. " KO'd from your victory pile. If you wish to KO another one, please switch them.",i,i)
                                vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                    smooth = false,
                                    guid = guid})
                                break
                            else
                                step = step + 1
                            end
                        end
                    else
                        click_get_wound(nil,i)
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                    koCard(vpilecontent[1])
                else
                    click_get_wound(nil,i)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Baron Helmut Zemo" then
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    local bsguids = {}
                    local vpmin = 8
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        local vp = 0
                        for _,l in pairs(k.tags) do                            
                            if l == "Villain" then
                                bsguids[k.guid] = vp
                            end
                            if l:find("VP") then
                                vp = tonumber(l:match("%d+"))
                                if bsguids[k.guid] then
                                    bsguids[k.guid] = vp
                                end
                                if vp < vpmin then
                                    vpmin = vp
                                end
                            end
                        end
                    end
                    if next(bsguids) then
                        for guid,vp in pairs(bsguids) do
                            if vp == 0 or vp > vpmin then
                                bsguids.guid = nil
                            end
                        end
                        local bsnr = math.random(#bsguids)
                        local step = 1
                        for guid,vp in pairs(bsguids) do
                            if step == bsnr then
                                broadcastToColor("Master Strike: Random weakest villain KO'd from your victory pile. If you wish to KO another one, please switch them.",i,i)
                                vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                    smooth = false,
                                    guid = guid})
                                break
                            else
                                step = step + 1
                            end
                        end
                    else
                        click_get_wound(nil,i)
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Villain") then
                    koCard(vpilecontent[1])
                else
                    click_get_wound(nil,i)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Belasco, Demon Lord of Limbo" then
        local sunlight = 0
        local moonlight = 0
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                local cost = hasTag2(hero,"Cost:")
                if cost then
                    if cost % 2 == 0 then
                        sunlight = sunlight + 1
                    else
                        moonlight = moonlight + 1
                    end
                end
            end
        end
        local light = sunlight - moonlight
        if light > 0 then
            if epicness == false then
                broadcastToAll("Master Strike: Each player KOs a non-grey Hero from their discard pile.")
            else
                broadcastToAll("Master Strike: Each player KOs two non-grey Heroes from their discard pile.")
            end
        elseif light < 0 then
            if epicness == false then
                broadcastToAll("Master Strike: Each player has a Waking Nightmare. KO Heroes discarded this way.")
            else
                broadcastToAll("Master Strike: Each player has two Waking Nightmares. KO Heroes discarded this way.")
            end
        end
        return strikesresolved
    end
    if mmname == "Carnage" then
        local playercolors = Player.getPlayers()
        broadcastToAll("Master Strike: Carnage feasts on each player!")
        for i=1,#playercolors do
            local color = playercolors[i].color
            local carnageWounds = function(obj)
                local name = obj.getName()
                if name == "" then
                    name = "an unnamed card"
                end
                broadcastToColor("Carnage feasted on " .. name .. "!",color,color)
                if not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0 then
                    click_get_wound(nil,color)
                end
            end
            local feastOn = function()
                local deck = getObjectFromGUID(playerBoards[color]).Call('returnDeck')
                if deck[1] and deck[1].tag == "Deck" then
                local pos = getObjectFromGUID(kopile_guid).getPosition()
                -- adjust pos to ensure the callback is triggered
                pos.y = pos.y + i
                    deck[1].takeObject({position = pos,
                        flip=true,
                        callback_function = carnageWounds})
                    return true
                elseif deck[1] then
                    deck[1].flip()
                    koCard(deck[1])
                    carnageWounds(deck[1])
                    return true
                else
                    return false
                end
            end
            local feasted = feastOn()
            if feasted == false then
                local discard = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
                if discard[1] then
                    getObjectFromGUID(playerBoards[color]).Call('click_refillDeck')
                    Wait.time(feastOn,2)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Charles Xavier, Professor of Crime" then
        msno(mmname)
        return nil
    end
    if mmname == "Dark Phoenix" then
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        local kopilepos = getObjectFromGUID(kopile_guid).getPosition()
        if herodeck[1] and herodeck[1].tag == "Deck" then
            local phoenixDevours = function(obj)
                broadcastToAll("Master Strike: Dark Phoenix purges the whole hero deck of hero class " .. hasTag2(obj,"HC:",4) .. "!")
                local koguids = {}
                for i,o in ipairs(herodeck[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k == "HC:" .. hasTag2(obj,"HC:",4) then
                            table.insert(koguids,i)
                            break
                        end
                    end
                end
                if koguids[1] then
                    local remo = 0
                    for i = 1,#koguids do
                        herodeck[1].takeObject({position = kopilepos,
                            flip=true,
                            smooth=true,
                            index = koguids[i]-1-remo})
                        remo = remo + 1
                        if herodeck[1].remainder then
                            local remains = herodeck[1].remainder
                            remains.flip()
                            if hasTag2(remains,"HC:",4) == hasTag2(obj,"HC:",4) then
                                koCard(remains)
                            end
                            break
                        end
                    end
                end
                --neglect to shuffle as the hero deck was not searched by a player for this
            end
            herodeck[1].takeObject({position = kopilepos,
                flip=true,
                smooth=true,
                callback_function = phoenixDevours})
        elseif herodeck[1] then
            herodeck[1].flip()
            koCard(herodeck[1])
            broadcastToAll("Master Strike: Dark Phoenix purges the whole hero deck!")
        else
            broadcastToAll("Master Strike: The hero deck ran out so Dark Phoenix wins!")
        end
        if epicness == true then
            playHorror()
            broadcastToAll("Each player must play a Hellfire Club villain from their Victory Pile!")       
        end
        return strikesresolved
    end
    if mmname == "Deathbird" then
        if cards[1] then
            cards[1].setName("Shi'ar Battlecruiser")
            local attack = 0
            if epicness == true then
                cards[1].addTag("VP6")
                attack = 9
            else
                cards[1].addTag("VP5")
                attack = 7
            end
            cards[1].addTag("Power:" .. attack)
            powerButton(cards[1],"updateTwistPower",attack)
            push_all(current_city)
        end
        for _,o in pairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,p in pairs(citycontent) do
                    if p.name:find("Shi'ar") or p.hasTag("Shi'ar") then
                        if epicness == true then
                            playHorror()
                        else
                            dealWounds()
                        end
                        return strikesresolved
                    end
                end  
            end
        end
        return nil
    end
    if mmname == "Dr. Doom" then
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if hand[1] and #hand == 6 then
                broadcastToAll("Master Strike: Player " .. o.color .. " puts two cards from their hand on top of their deck.")
                local pos = getObjectFromGUID(playerBoards[o.color]).positionToWorld({0.957, 1, 0.222})
                promptDiscard(o.color,nil,2,pos,true)
            end
        end
        return strikesresolved
    end
    if mmname == "Dr. Strange" then
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        if vildeck and vildeck.tag == "Deck" then
            local pos = self.getPosition()
            local strangeguids = {}
            pos.x = pos.x - 6
            pos.y = pos.y + 3
            local insertGuid = function(obj)
                local objname = obj.getName()
                if objname == "" then
                    objname = "an unnamed card"
                end
                broadcastToAll("Master Strike: Dr. Strange revealed " .. objname .. " from the villain deck!")
                table.insert(strangeguids,obj.guid)
            end
            for i=1,3 do
                pos.x = pos.x + 2
                vildeck.takeObject({position = pos,
                    flip=true,
                    smooth=true,
                    callback_function = insertGuid})
            end
            local strangeguidsEntered = function()
                if strangeguids and #strangeguids == 3 then
                    return true
                else
                    return false
                end
            end
            local strangeProcess = function()
                local twistfound = false
                local powerguid = nil
                local power = 0
                for i,o in pairs(strangeguids) do
                    local object = getObjectFromGUID(o)
                    if twistfound == false and object.getName() == "Scheme Twist" then
                        twistfound = true
                        local moveTwist = function()
                            object.setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                        end
                        Wait.time(moveTwist,1)
                        strangeguids[i] = nil
                    elseif object.hasTag("Villain") then
                        if not powerguid then
                            powerguid = i
                            if hasTag2(object,"Power:") then
                                power = hasTag2(object,"Power:")
                            end
                        elseif hasTag2(object,"Power:") and hasTag2(object,"Power:") > power then
                            powerguid = i
                            power = hasTag2(object,"Power:")
                        end
                    end
                end
                bump(vildeck,4)
                if powerguid then
                    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                    pos.y = pos.y + 6
                    local object = getObjectFromGUID(strangeguids[powerguid])
                    object.flip()
                    object.setPositionSmooth(pos)
                    strangeguids[powerguid] = nil
                end
                for _,o in pairs(strangeguids) do
                    local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                    local object = getObjectFromGUID(o)
                    object.flip()
                    object.setPositionSmooth(pos)
                end
            end
            Wait.condition(strangeProcess,strangeguidsEntered)
        end
        return strikesresolved
    end
    if mmname == "Emma Frost, The White Queen" then
        if cards[1] then
            cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
            strikesstacked = strikesstacked + 1
        end
        if epicness == false then
            broadcastToAll("Master Strike: Each player has " .. strikesresolved .. " Waking Nightmares.")
        else
            broadcastToAll("Master Strike: Each player has " .. strikesresolved+1 .. " Waking Nightmares.")
        end
        return nil
    end
    if mmname == "Emperor Vulcan of the Shi'ar" then
        msno(mmname)
        return nil
    end
    if mmname == "Evil Deadpool" then
        for _,o in pairs(Player.getPlayers()) do
            promptDiscard(o.color)
            broadcastToAll("Master Strike: Each player simultaneously discards a card. Whoever discards the lowest-costing card (or tied for lowest) gains a Wound (manually).")
        end
        return strikesresolved
    end
    if mmname == "Fin Fang Foom" then
        local foomcount = 0
        for _,o in pairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,k in pairs(citycontent) do
                    if k.hasTag("Group:Monsters Unleashed") then
                        foomcount = foomcount + 1
                        break
                    end
                end
            end
        end
        local escapedcards = get_decks_and_cards_from_zone(escape_zone_guid)
        if escapedcards[1] and escapedcards[1].tag == "Deck" then
            for _,o in pairs(escapedcards[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k == "Group:Monsters Unleashed" then
                        foomcount = foomcount + 1
                        break
                    end
                end
            end
        elseif escapedcards[1] and escapedcards[1].tag == "Card" then
            if escapedcards[1].hasTag("Group:Monsters Unleashed") then
                foomcount = foomcount + 1
            end
        end
        demolish(nil,foomcount+1,nil,epicness)
        broadcastToAll("Master Strike: Each player is demolished " .. foomcount+1 .. " times!")
        if epicness then
            broadcastToAll("KO all heroes demolished this way!")
        end
        return strikesresolved
    end
    if mmname == "Galactus" then
        local destroyed = table.remove(current_city)
        local escapees = get_decks_and_cards_from_zone(destroyed)
        if escapees[1] then
            shift_to_next(escapees,getObjectFromGUID(escape_zone_guid),0)
            for _,o in pairs(escapees) do
                if o.getDescription():find("LOCATION") then
                    koCard(o)
                end
            end
        end
        local setStrike = function()
            if cards[1] then
                cards[1].setPositionSmooth(getObjectFromGUID(destroyed).getPosition())
            else
                getObjectFromGUID(mmPileGUID).takeObject({position = getObjectFromGUID(destroyed).getPosition(),
                    smooth = false})
            end
        end
        Wait.time(setStrike,1)
        return nil
    end
    if mmname == "General Ross" then
        local transformedPV = getObjectFromGUID("912967").Call('externalTransformMM',mmLocations["General Ross"])
        if transformedPV["General Ross"] == true then
            crossDimensionalRampage("hulk")
        elseif transformedPV["General Ross"] == false then
            for i,o in pairs(vpileguids) do
                if Player[i].seated == true then
                    local vpilecontent = get_decks_and_cards_from_zone(o)
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        local bsguids = {}
                        for _,k in pairs(vpilecontent[1].getObjects()) do
                            for _,l in pairs(k.tags) do
                                if l == "Bystander" then
                                    bsguids[k.name] = k.guid
                                    break
                                end
                            end
                        end
                        if next(bsguids) then
                            local bsnr = math.random(#bsguids)
                            local step = 1
                            for name,guid in pairs(bsguids) do
                                if step == bsnr then
                                    if name == "Card" then
                                        name = ""
                                    end
                                    broadcastToColor("Master Strike: Random bystander " .. name .. " piloted one of General Ross's helicopters.",i,i)
                                    vpilecontent[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                                        smooth = false,
                                        flip = true,
                                        guid = guid})
                                    break
                                else
                                    step = step + 1
                                end
                            end
                        else
                            click_get_wound(nil,i)
                        end
                    elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                        vpilecontent[1].flip()
                        vpilecontent[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                    else
                        click_get_wound(nil,i)
                    end
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Grim Reaper" then
        if cards[1] then
            reaperbonus = 0
            if epicness then
                reaperbonus = 1
                for _,o in pairs(city) do
                    local locationcount = 0
                    local citycontent = get_decks_and_cards_from_zone(o)
                    if citycontent[1] then
                        for _,p in pairs(citycontent) do
                            if p.getDescription():find("LOCATION") then
                                locationcount = locationcount + 1
                            end
                        end
                    end
                end
                if locationcount > 1 then
                    dealWounds()
                end
            end
            cards[1].setName("Graveyard")
            cards[1].setDescription("LOCATION: Put this above the City Space closest to the Villain Deck and without a Location already. Can be fought, but does not count as a Villain. KO the weakest Location if the City is already full of Locations.")
            cards[1].addTag("VP" .. 5 + reaperbonus)
            cards[1].addTag("Attack:" .. 7 + reaperbonus)
            cards[1].addTag("Location")
            powerButton(cards[1],"updateTwistPower",7 + reaperbonus)
            push_all(table.clone(current_city))
        else
            broadcastToAll("No Master Strike found, so Grim Reaper failed to manifest a Graveyard.")
        end
        return nil
    end
    if mmname == "Hela, Goddess of Death" then
        if cards[1] then
            helabonus = 0
            if epicness then
                helabonus = 1
            end
            cards[1].setName("Army of the Dead")
            cards[1].addTag("VP" .. 3 + helabonus)
            cards[1].addTag("Attack:" .. 5 + helabonus)
            cards[1].addTag("Villain")
            powerButton(cards[1],"updateTwistPower",5 + helabonus)
            push_all(table.clone(current_city))
        else
            broadcastToAll("No Master Strike found, so Hela failed to muster an Army of the Dead.")
        end
        local pcolor = Turns.turn_color
        local vpilecontent = get_decks_and_cards_from_zone(vpileguids[pcolor])
        local carddropped = 0
        local posPlay = offerCards(pcolor)
        if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
            local vpilestrong = {}
            for _,o in pairs(vpilecontent[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k:find("VP") and tonumber(k:match("%d+")) > 2 + helabonus then
                        table.insert(vpilestrong,o)
                        break
                    end
                end
            end
            if vpilestrong[1] and not vpilestrong[2] then
                vpilecontent[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth = true,
                    callback_function = click_push_villain_into_city})
                return nil
            elseif vpilestrong[1] and vpilestrong[2] then
                for _,o in pairs(vpilestrong) do
                    posPlay = offerCards(pcolor,posPlay)
                    vpilecontent[1].takeObject({position = posPlay,
                        guid = o.guid})
                    carddropped = carddropped + 1
                    if vpilecontent[1].remainder and carddropped < #vpilestrong then
                        vpilecontent[1] = vpilecontent[1].remainder
                        break
                    end  
                end
                broadcastToColor("Push 1 of the " .. #vpilestrong .. " villain cards that were put into play from your victory pile into the city. Return the rest to your victory pile.",pcolor,pcolor)
                if #vpilestrong == carddropped then
                    return nil
                end
            end
        end
        if vpilecontent[1] and vpilecontent[1].tag == "Card" then
            if carddropped > 0 then
                posPlay = offerCards(pcolor,posPlay)
                vpilecontent[1].setPosition(posPlay)
                carddropped = carddropped + 1
                return nil
            else
                if hasTag2(vpilecontent[1],"VP") and hasTag2(vpilecontent[1],"VP") > 2 + helabonus then
                    vpilecontent[1].setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
                    Wait.time(click_push_villain_into_city,2)
                    return nil
                end
            end
        end
        dealWounds()
        return nil
    end
    if mmname == "Hybrid" or mmname == "Hydra High Council" or mmname == "Hydra Super-Adaptoid" then
        msno(mmname)
        return nil
    end
    if mmname == "Illuminati, Secret Society" then
        local transformedPV = getObjectFromGUID("912967").Call('externalTransformMM',mmLocations["Illuminati, Secret Society"])
        if transformedPV["Illuminati, Secret Society"] == true then
            broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 1 and 4.")
        elseif transformedPV["Illuminati, Secret Society"] == false then
            broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 5 and 8.")
        end
        return strikesresolved
    end
    if mmname == "Immortal Emperor Zheng-Zhu" then
        local players = revealCardTrait(6,"Cost:",nil,"Cost")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if #hand > 3 then
                promptDiscard(o.color,hand,#hand-3)
                broadcastToColor("Master Strike: Discard down to three cards.",o.color,o.color)
            end
        end
        return strikesresolved
    end
    if mmname == "J. Jonah Jameson" then
        msno(mmname)
        return nil
    end
    if mmname == "King Hulk, Sakaarson" then
        local transformedPV = getObjectFromGUID("912967").Call('externalTransformMM',mmLocations["King Hulk, Sakaarson"])
        if transformedPV["King Hulk, Sakaarson"] == true then
            for i,o in pairs(vpileguids) do
                if Player[i].seated == true then
                    local vpilecontent = get_decks_and_cards_from_zone(o)
                    local vpilewarbound = {}
                    local posPlay = offerCards(i)
                    local carddropped = 0
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        for _,k in pairs(vpilecontent[1].getObjects()) do
                            for _,tag in pairs(k.tags) do
                                if tag == "Group:Warbound" then 
                                    table.insert(vpilewarbound,k)
                                    break
                                end
                            end
                        end
                        if vpilewarbound[1] and not vpilewarbound[2] then
                            vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                smooth = true})
                        elseif vpilewarbound[1] and vpilewarbound[2] then
                            for _,k in pairs(vpilewarbound) do
                                posPlay = offerCards(i,posPlay)
                                vpilecontent[1].takeObject({position = posPlay,
                                    guid = k.guid})
                                carddropped = carddropped + 1
                                if vpilecontent[1].remainder and carddropped < #vpilewarbound then
                                    vpilecontent[1] = vpilecontent[1].remainder
                                    break
                                end  
                            end
                            broadcastToColor("KO 1 of the " .. #vpilewarbound .. " villain cards that were put into play from your victory pile. Return the rest to your victory pile.",i,i)
                        else
                            click_get_wound(nil,i)
                        end
                    end
                    if vpilecontent[1] and vpilecontent[1].tag == "Card" then
                        if carddropped > 0 then
                            posPlay = offerCards(i,posPlay)
                            vpilecontent[1].setPosition(posPlay)
                            carddropped = carddropped + 1
                        else
                            if vpilecontent[1].hasTag("Group:Warbound") then
                                vpilecontent[1].setPosition(getObjectFromGUID(kopile_guid).getPosition())
                            end
                        end
                    else
                        click_get_wound(nil,i)
                    end
                end
            end
        elseif transformedPV["King Hulk, Sakaarson"] == false then
            broadcastToAll("Master Strike: Each player reveals their hand, then KO's a card from their hand or discard pile that has the same card name as a card in the HQ.")
        end
        return strikesresolved
    end
    if mmname == "King Hyperion" then
        local mm = get_decks_and_cards_from_zone(mmloc)
        local kinghyperion = nil
        if mm[1] then
            for _,o in pairs(mm) do
                if o.getName() == "King Hyperion" and o.tag == "Card" then
                    kinghyperion = o
                    break
                end
            end
        end
        if not kinghyperion then   
            for index,o in pairs(city) do
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if obj.getName() == "King Hyperion" then
                            local kingscity = table.clone(city)
                            if index > 2 then
                                for i = 1,index-2 do
                                    table.remove(kingscity,1)
                                end
                            end
                            local stop = math.min(#kingscity-1,3)
                            local pushKing = function()
                                table.remove(kingscity,1)
                                push_all(table.clone(kingscity))
                            end
                            broadcastToAll("Charging...",{1,0,0})
                            for i=1,stop do
                                Wait.time(pushKing,i*2)
                                Wait.time(function() broadcastToAll("Still charging...",{1,0,0}) end,i*2)
                            end
                            return strikesresolved
                        end
                    end
                end
            end
        end
        if not kinghyperion then
            broadcastToAll("King Hyperion not found?")
            return nil
        end
        koCard(cards[1],true)
        kinghyperion.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
        broadcastToAll("Charging...",{1,0,0})
        for i=1,4 do
            Wait.time(click_push_villain_into_city,i*2)
            Wait.time(function() broadcastToAll("Still charging...",{1,0,0}) end,i*2)
        end
        return nil
    end
    if mmname == "Kingpin" then
        local players = revealCardTrait("Marvel Knights","Team:")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            promptDiscard(o.color,hand,#hand)
            local drawfive = function()
                getObjectFromGUID(playerBoards[o.color]).Call('click_draw_cards',5)
            end
            Wait.time(drawfive,1)
        end
        return strikesresolved
    end
    if mmname == "Loki" then
        local towound = revealCardTrait("Green")
        if towound[1] then
            for _,o in pairs(towound) do
                click_get_wound(nil,o.color)
                broadcastToAll("Master Strike: Player " .. o.color .. " had no green heroes and was wounded.")
            end
        end
        return strikesresolved
    end
    if mmname == "Macho Gomez" then
        msno(mmname)
        return nil
    end
    if mmname == "Madelyne Pryor, Goblin Queen" then
        local madsbs = get_decks_and_cards_from_zone(strikeloc)
        if madsbs[1] then
            dealWounds()
        end
        addBystanders(strikeloc,nil,true)
        addBystanders(strikeloc,nil,true)
        addBystanders(strikeloc,nil,true)
        addBystanders(strikeloc,nil,true)
        return strikesresolved
    end
    if mmname == "Magneto" then
        local players = revealCardTrait("X-Men","Team:")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if #hand > 4 then
                broadcastToAll("Master Strike: Player " .. o.color .. " discards down to 4 cards.")
                promptDiscard(o.color,hand,#hand-4)
            end
        end
        return strikesresolved
    end
    if mmname == "Magus" then
        local shardfound = false
        for _,o in pairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.getName() == "Shard" then
                        shardfound = true
                        break
                    end
                end
                if shardfound == true then
                    dealWounds()
                    if epicness then
                        broadcastToAll("Master Strike: Each player received a wound. Put the wound on top of your deck!")
                    end
                    break
                end
            end
        end
        if cards[1] then
            local boost = 4
            if epicness then
                boost = 6
            end
            cards[1].setName("Cosmic Wraith")
            cards[1].addTag("VP" .. boost)
            cards[1].addTag("Power:" .. boost)
            cards[1].addTag("Villain")
            powerButton(cards[1],"updateTwistPower",boost)
            local addshard = function()
                for _,o in pairs(city) do
                    local citycontent = get_decks_and_cards_from_zone(o)
                    if citycontent[1] then
                        for _,obj in pairs(citycontent) do
                            if obj.hasTag("Villain") then
                                gainShard(nil,o)
                                break
                            end
                        end
                    end
                end
            end
            Wait.time(addshard,2)
            click_push_villain_into_city()
            return nil
        end
        return strikesresolved
    end
    if mmname == "Malekith the Accursed" or mmname == "Mandarin" or mmname == "Maria Hill, Director of S.H.I.E.L.D." or mmname == "Maximus the Mad" then
        msno(mmname)
        return nil
    end
    if mmname == "Mephisto" then
        local players = revealCardTrait("Marvel Knights","Team:")
        for _,o in pairs(players) do
            click_get_wound(nil,o.color)
            broadcastToAll("Master Strike: Player " .. o.color .. " had no MK hero and was wounded.")
        end
        return strikesresolved
    end
    if mmname == "Misty Knight" then
        msno(mmname)
        return nil
    end
    if mmname == "M.O.D.O.K." then
        local transformedPV = getObjectFromGUID("912967").Call('externalTransformMM',mmLocations["M.O.D.O.K."])
        if transformedPV["M.O.D.O.K."] == true then
            local players = Player.getPlayers()
            for _,o in pairs(players) do
                local hand = o.getHandObjects()
                if hand[1] then
                    local outwitcount = table.clone(herocosts)
                    for _,p in pairs(hand) do
                        --breaks with bystander-heroes, some villain-heroes
                        if hasTag2(p,"Cost:") then
                            outwitcount[hasTag2(p,"Cost:")+1] = outwitcount[hasTag2(p,"Cost:")+1] + 1
                        elseif p.hasTag("Officer") then
                            outwitcount[4] = outwitcount[4] + 1
                        elseif p.hasTag("Sidekick") then
                            outwitcount[3] = outwitcount[3] + 1
                        else
                            outwitcount[1] = outwitcount[1] + 1
                        end
                    end
                    local totaloutwitcount = 0
                    for _,p in pairs(outwitcount) do
                        if p > 0 then
                            totaloutwitcount = totaloutwitcount + 1
                        end
                    end
                    if totaloutwitcount < 4 then
                        click_get_wound(nil,o.color)
                    end
                else
                    click_get_wound(nil,o.color)
                end
            end
        elseif transformedPV["M.O.D.O.K."] == false then
            local players = Player.getPlayers()
            for _,o in pairs(players) do
                local hand = o.getHandObjects()
                if hand[1] then
                    local outwitcount = table.clone(herocosts)
                    for _,p in pairs(hand) do
                        --breaks with bystander-heroes, some villain-heroes
                        if hasTag2(p,"Cost:") then
                            outwitcount[hasTag2(p,"Cost:")+1] = outwitcount[hasTag2(p,"Cost:")+1] + 1
                        elseif p.hasTag("Officer") then
                            outwitcount[4] = outwitcount[4] + 1
                        elseif p.hasTag("Sidekick") then
                            outwitcount[3] = outwitcount[3] + 1
                        else
                            outwitcount[1] = outwitcount[1] + 1
                        end
                    end
                    local totaloutwitcount = 0
                    for _,p in pairs(outwitcount) do
                        if p > 0 then
                            totaloutwitcount = totaloutwitcount + 1
                        end
                    end
                    if totaloutwitcount < 3 then
                        broadcastToColor("Master Strike: KO a nongrey hero from your discard pile.",o.color,o.color)
                    end
                else
                    broadcastToColor("Master Strike: KO a nongrey hero from your discard pile.",o.color,o.color)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Mojo" then
        addBystanders(strikeloc,false,true)
        if epicness then
            for _,o in pairs(city) do
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,p in pairs(citycontent) do
                        if hasTag2(p,"Group:",6) and hasTag2(p,"Group:",6) == "Mojoverse" then
                            addBystanders(o,false)
                            break
                        end
                    end
                end
            end
        end
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if epicness and #hand > 4 then
                promptDiscard(o.color,nil,#hand-4)
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
    if mmname == "Mole Man" then
        local subescaped = false
        for _,o in pairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,p in pairs(citycontent) do
                    if hasTag2(p,"Group:",7) and hasTag2(p,"Group:",7) == "Subterranea" then
                        subescaped = true
                        shift_to_next(citycontent,getObjectFromGUID(escape_zone_guid),0)
                        break
                    end
                end
            end
        end
        if subescaped == true then
            dealWounds()
        end
        broadcastToAll("Master Strike: All Subterranea Villains in the city escape. If any Villains escaped this way, each player gains a Wound.")
        return strikesresolved
    end
    if mmname == "Morgan Le Fay" then
        msno(mmname)
        return nil
    end
    if mmname == "Mr. Sinister" then
        local players = revealCardTrait("Red")
        addBystanders(strikeloc,nil,false)
        local bs = get_decks_and_cards_from_zone(strikeloc)
        local sinisterbs = 1
        if bs[1] then
            sinisterbs = math.abs(bs[1].getQuantity()) + 1
        end
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if #hand == 6 then
                promptDiscard(o.color,nil,sinisterbs)
                broadcastToColor("Master Strike: Discard " .. sinisterbs .. " cards.",o.color,o.color)
            end
        end
        return strikesresolved
    end
    if mmname == "Mysterio" then
        if cards[1] then
            cards[1].setName("Mysterio Tactic")
            cards[1].addTag("Tactic:Mysterio")
            cards[1].addTag("VP6")
            cards[1].flip()
            local mm = get_decks_and_cards_from_zone(mmloc)
            if not mm[1] then
                broadcastToAll("Mysterio not found?")
                return nil
            end
            for _,o in pairs(mm) do
                if o.is_face_down == false then
                    bump(o,4)
                end
            end
            cards[1].setPositionSmooth(getObjectFromGUID(mmloc).getPosition())
            local mysterioShuffle = function()
                for _,o in pairs(mm) do
                    if o.is_face_down == true and o.tag == "Deck" then
                        o.randomize()
                    end
                end
            end
            Wait.time(mysterioShuffle,2)
        end
        return nil
    end
    if mmname == "Nick Fury" then
        if cards[1] then
            cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
            strikesstacked = strikesstacked + 1
        end
        demolish(nil,strikesstacked)
        return nil
    end
    if mmname == "Onslaught" then
        local dominated = get_decks_and_cards_from_zone(mmLocations[mmname])
        if dominated[1] then
            koCard(dominated[1])
        end
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            for i,obj in ipairs(handi) do
                if not hasTag2(obj,"HC:",4) then
                    table.remove(hand,i-iter)
                    iter = iter + 1
                end
            end
            if hand[1] then
                if epicness then
                    promptDiscard(o.color,hand,2,getObjectFromGUID(mmLocations[mmname]).getPosition())
                    broadcastToColor("Master Strike: Two nongrey heroes from your hand become dominated by Onslaught.",o.color,o.color)
                else
                    promptDiscard(o.color,hand,1,getObjectFromGUID(mmLocations[mmname]).getPosition())
                    broadcastToColor("Master Strike: A nongrey hero from your hand becomes dominated by Onslaught.",o.color,o.color)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Pagliacci" then
        if cards[1] then
            if strikesresolved == 1 or strikesresolved == 5 or (strikesresolved == 3 and epicness == true) then
                cards[1].setName("Scheme Twist")
                click_push_villain_into_city()
                return nil
            end
        end
        if strikesresolved == 2 or strikesresolved == 4 or (strikesresolved == 3 and not epicness) then
            demolish()
        end
        return strikesresolved
    end
    if mmname == "Poison Thanos" then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            for i,obj in ipairs(handi) do
                if not hasTag2(obj,"HC:",4) then
                    table.remove(hand,i-iter)
                    iter = iter + 1
                end
            end
            if hand[1] then
                if epicness then
                    promptDiscard(o.color,hand,#hand/2 + 0.5*(#hand % 2),getObjectFromGUID(mmLocations[mmname]).getPosition())
                    broadcastToColor("Master Strike: " .. #hand/2 + 0.5*(#hand % 2) .. " nongrey heroes from your hand become souls poisoned by Thanos.",o.color,o.color)
                else
                    promptDiscard(o.color,hand,1,getObjectFromGUID(mmLocations[mmname]).getPosition())
                    broadcastToColor("Master Strike: A nongrey hero from your hand becomes a soul poisoned by Thanos.",o.color,o.color)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Professor X" then
        msno(mmname)
        return nil
    end
    if mmname == "Ragnarok" then
        broadcastToAll("Master Strike: Each player says \"zero\" or \"not zero.\" Then, each player discards all their cards with that cost.")
        -- could be done more automatically by spawning buttons for each player's hand?
        return strikesresolved
    end
    if mmname == "Red Skull" then
        for _,o in pairs(Player.getPlayers()) do
            promptDiscard(o.color,nil,1,getObjectFromGUID(kopile_guid).getPosition())
        end
        broadcastToAll("Master Strike: Each player KOs a Hero from their hand.")
        return strikesresolved
    end
    if mmname == "Shadow King" then
        msno(mmname)
        return nil
    end
    if mmname == "Shiklah, the Demon Bride" then
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        if vildeck and vildeck.tag == "Deck" then
            local pos = self.getPosition()
            local strangeguids = {}
            pos.x = pos.x - 6
            pos.y = pos.y + 3
            local insertGuid = function(obj)
                local objname = obj.getName()
                if objname == "" then
                    objname = "an unnamed card"
                end
                broadcastToAll("Master Strike: Dr. Strange revealed " .. objname .. " from the villain deck!")
                table.insert(strangeguids,obj.guid)
            end
            for i=1,3 do
                pos.x = pos.x + 2
                vildeck.takeObject({position = pos,
                    flip=true,
                    smooth=true,
                    callback_function = insertGuid})
            end
            local strangeguidsEntered = function()
                if strangeguids and #strangeguids == 3 then
                    return true
                else
                    return false
                end
            end
            local strangeProcess = function()
                bump(vildeck,4)
                for _,o in pairs(strangeguids) do
                    local object = getObjectFromGUID(o)
                    if object.getName() == "Scheme Twist" then
                        local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                        pos.y = pos.y + 6
                        object.flip()
                        object.setPositionSmooth(pos)
                    else
                        local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
                        object.flip()
                        object.setPositionSmooth(pos)
                    end
                end
            end
            Wait.condition(strangeProcess,strangeguidsEntered)
        end
        return strikesresolved
    end
    if mmname == "Stryfe" then
        if cards[1] then
            strikesstacked = strikesstacked + 1
            cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
            if strikesstacked == 1 then
                getObjectFromGUID(mmloc).createButton({click_function='updatetwistpower',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="+" .. strikesstacked,
                    tooltip="Stryfe gets +1 for each Master Strike stacked next to him.",
                    font_size=250,
                    font_color="Red",
                    width=0})
            else
                getObjectFromGUID(mmloc).editButton({label = "+" .. strikesstacked})
            end
        end
        local todiscard= revealCardTrait("X-Force","Team:")
        if todiscard[1] then
                for _,o in pairs(todiscard) do
                    local hand = o.getHandObjects()
                    if hand[1] then
                        local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
                        hand[math.random(#hand)].setPosition(posdiscard)
                        broadcastToAll("Master Strike: Player " .. o.color .. " had no X-Force heroes and discarded a card at random.")
                    end
                end
            end
        return nil
    end
    if mmname == "The Red King" then
        local transformedPV = getObjectFromGUID("912967").Call('externalTransformMM',mmLocations["The Red King"])
        if transformedPV["The Red King"] == true then
            local towound = revealCardTrait("Silver")
            if towound[1] then
                for _,o in pairs(towound) do
                    click_get_wound(nil,o.color)
                    broadcastToAll("Master Strike: Player " .. o.color .. " had no silver heroes and was wounded.")
                end
            end
        elseif transformedPV["The Red King"] == false then
            playVillains()
        end
        return strikesresolved 
    end
    if mmname == "The Sentry" then
        local transformedPV = getObjectFromGUID("912967").Call('externalTransformMM',mmLocations["The Sentry"])
        if transformedPV["The Sentry"] == true then
            crossDimensionalRampage("void")
        elseif transformedPV["The Sentry"] == false then
            local playercolors = Player.getPlayers()
            broadcastToAll("Master Strike: The Void feasts on each player!")
            for i=1,#playercolors do
                local color = playercolors[i].color
                local carnageWounds = function(obj)
                    local name = obj.getName()
                    if name == "" then
                        name = "an unnamed card"
                    end
                    broadcastToColor("The Void feasted on " .. name .. "!",color,color)
                    if not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0 then
                        click_get_wound(nil,color)
                    end
                end
                local feastOn = function()
                    local deck = getObjectFromGUID(playerBoards[color]).Call('returnDeck')
                    if deck[1] and deck[1].tag == "Deck" then
                    local pos = getObjectFromGUID(kopile_guid).getPosition()
                    -- adjust pos to ensure the callback is triggered
                    pos.y = pos.y + i
                        deck[1].takeObject({position = pos,
                            flip=true,
                            callback_function = carnageWounds})
                        return true
                    elseif deck[1] then
                        deck[1].flip()
                        koCard(deck[1])
                        carnageWounds(deck[1])
                        return true
                    else
                        return false
                    end
                end
                local feasted = feastOn()
                if feasted == false then
                    local discard = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
                    if discard[1] then
                        getObjectFromGUID(playerBoards[color]).Call('click_refillDeck')
                        Wait.time(feastOn,2)
                    end
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Wasteland Hulk" then
        crossDimensionalRampage("hulk")
        return strikesresolved
    end
    if mmname == "Uru-Enchanted Iron Man" then
        if cards[1] then
            cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
        end
        demolish()
        return nil
    end
    if mmname == "Zombie Green Goblin" then
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero and hasTag2(hero,"Cost:") > 6  then
                hero.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                getObjectFromGUID(o).Call('click_draw_hero')
            end
        end
        function goblinDiscards()
            local kopile = get_decks_and_cards_from_zone(kopile_guid)
            local todiscard = 0
            if kopile[1] and kopile[2] then
                broadcastToAll("Please merge the KO pile into a single stack.")
                return nil
            end
            if kopile[1] and kopile[1].tag == "Deck" then
                for _,o in pairs(kopile[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("Cost:") and tonumber(k:match("%d+")) > 6 then
                            todiscard = todiscard + 1
                            break
                        end
                    end
                end
            elseif kopile[1] then
                if hasTag2(kopile[1],"Cost:") and hasTag2(kopile[1],"Cost:") > 6 then
                    todiscard = todiscard + 1
                end
            end
            broadcastToAll("Master Strike! Each player discards " .. todiscard .. " cards.")
        end
        Wait.time(goblinDiscards,2)
        return strikesresolved
    end
    return nil
end

function revealCardTrait(trait,prefix,playercolors,what)
    -- trait is the card tag to look for, by default a color
    -- specify the tag prefix if another trait is needed
    -- specify players if not all are affected
    if not prefix then
        prefix = "HC:"
    end
    if not what then
        what = "Prefix"
    end
    local players = nil
    if not playercolors then
        players = Player.getPlayers()
    else
        players = {}
        for _,o in pairs(playercolors) do
            table.insert(players,Player[o])
        end
    end
    for i,o in ipairs(players) do
        local hand = o.getHandObjects()
        if hand[1] then
            for _,h in pairs(hand) do
                if what == "Prefix" then
                    if hasTag2(h,prefix,#prefix+1) and hasTag2(h,prefix,#prefix+1) == trait then
                        players[i] = nil
                        break
                    end
                elseif what == "Tag" then
                    if h.hasTag(trait) then
                        players[i] = nil
                        break
                    end
                elseif what == "Namepart" then
                    if h.getName():find(trait) then
                        players[i] = nil
                        break
                    end
                elseif what == "Name" then
                    if h.getName() == trait then
                        players[i] = nil
                        break
                    end
                elseif what == "Cost" then
                    if hasTag2(h,prefix) and hasTag2(h,prefix) > trait then
                        players[i] = nil
                        break
                    end
                end
            end
        end
    end
    return players
end

function bump(obj,y)
    if not y then
        y = 2
    end
    local pos = obj.getPosition()
    pos.y = pos.y + y
    obj.setPositionSmooth(pos)
end

function crossDimensionalRampage(name)
    local players = Player.getPlayers()
    --add pseudonyms for wolverine,hulk still
    for i,o in pairs(players) do
        if o.seated == true then
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    if string.lower(k.name):find(name) then
                        table.remove(players,i)
                    end
                end
            elseif vpilecontent[1] and string.lower(vpilecontent[1].getName()):find(name) then
                table.remove(players,i)
            end
        end
    end
    for i,o in pairs(players) do
        local hand = o.getHandObjects()
        if hand[1] then
            for _,h in pairs(hand) do
                if string.lower(h.getName()):find(name) then
                    table.remove(players,i)
                end
            end
        end
    end
    --does not check heroes in play yet
    for _,o in pairs(players) do
        click_get_wound(nil,o.color)
    end
end

function nonTwistspecials(cards,city,schemeParts)
    if schemeParts[1] == "Annihilation: Conquest" and cityEntering == 1 then
        local cost = hasTag2(cards[1],"Cost:")
        if cost then
            cards[1].addTag("Phalanx-Infected")
            powerButton(cards[1],"updateTwistPower",twistsresolved+cost)
        end
    end
    if schemeParts[1] == "Brainwash the Military" and cityEntering == 1 then
        basestrength = 3
        if cards[1].getName() == "S.H.I.E.L.D. Officer" or cards[1].getName() == "Madame Hydra" then
            cards[1].addTag("Brainwashed")
            powerButton(cards[1],"updateTwistPower",twistsstacked+basestrength)
        end
    end
    
    if schemeParts[1] == "Deadpool Wants A Chimichanga" and cityEntering == 1 then
        if cards[1].hasTag("Bystander") then
            Wait.time(click_draw_villain,1)
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
    if schemeParts[1] == "Everybody Hates Deadpool" and cityEntering == 1 then
        if cards[1].hasTag("Villain") then
            if cards[1].getDescription() == "" then
                cards[1].setDescription("REVENGE: This villain gets +1 Power for each card of the listed group in the attacking player's Victory Pile.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nREVENGE: This villain gets +1 Power for each card of the listed group in the attacking player's Victory Pile.")
            end
        end
    end
    if schemeParts[1] == "House of M" and cityEntering == 1 then
        if basestrength == 0 then
            basestrength = 3
        end
        if cards[1].getName() == "Scarlet Witch (R)" then
            powerButton(cards[1],"updateTwistPower",basestrength + hasTag2(cards[1],"Cost:"))
        end
    end
    if schemeParts[1] == "Master of Tyrants" and cityEntering == 1 then
        if cards[1].getName() == "Dark Power" then
            broadcastToAll("Scheme Twist: Put this twist under a tyrant as a Dark Power!")
            return nil
        end
    end
    if schemeParts[1] == "Mass Produce War Machine Armor" and cityEntering == 1 then
        if cards[1].getName() == "S.H.I.E.L.D. Assault Squad" then
            powerButton(cards[1],"updateTwistPower","+" .. twistsresolved)
        end
    end
    if schemeParts[1] == "Organized Crime Wave" and cityEntering == 1 then
        if cards[1].getName() == "Maggia Goons" then
            playVillains(1)
        end
    end
    if schemeParts[1] == "Replace Earth's Leaders with Killbots" and cityEntering == 1 then
        if twistsstacked == 0 then
            twistsstacked = 3
        end
        if cards[1].hasTag("Bystander") then
            cards[1].addTag("Villain")
            cards[1].addTag("Killbot")
            powerButton(cards[1],"updateTwistPower",twistsstacked)
        end
    end
    if schemeParts[1] == "Scavenge Alien Weaponry" and cityEntering == 1 then
        if cards[1].getName() == schemeParts[9] then
            cards[1].setName("Smugglers")
            if cards[1].getDescription() == "" then
                cards[1].setDescription("STRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nSTRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
            end
            powerButton(cards[1],"updateTwistPower","+" .. strikesresolved)
        end
    end
    if schemeParts[1] == "Secret Invasion of the Skrull Shapeshifters" and cityEntering == 1 then
        if hasTag2(cards[1],"Cost:") then
            powerButton(cards[1],"updateTwistPower",hasTag2(cards[1],"Cost:")+2)
            cards[1].addTag("Villain")
        end
    end
    if schemeParts[1] == "Sinister Ambitions" and cityEntering == 1 then
        if cards[1].hasTag("Ambition") then
            powerButton(cards[1],"updateTwistPower","+" .. twistsstacked)
        end
    end
    if schemeParts[1] == "Splice Humans with Spider DNA" and cityEntering == 1 then
        if cards[1].hasTag("Group:Sinister Six") then
            powerButton(cards[1],"updateTwistPower","+3")
        end
    end
    if schemeParts[1] == "The Dark Phoenix Saga" and cityEntering == 1 then
        if cards[1].getName() == "Jean Grey (DC)" then
            powerButton(cards[1],"updateTwistPower",hasTag2(cards[1],"Cost:"))
            cards[1].addTag("Villain")
            playVillains(1)
        end
    end
    if schemeParts[1] == "The Fountain of Eternal Life" and cityEntering == 1 then
        if cards[1].hasTag("Villain") and not cards[1].getDescription():find("FATEFUL RESURRECTION") then
            if cards[1].getDescription() == "" then
                cards[1].setDescription("FATEFUL RESURRECTION: Reveal the top card of the Villain Deck. If it's a Scheme Twist or Master Strike, this card goes back to where it was when fought.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nFATEFUL RESURRECTION: Reveal the top card of the Villain Deck. If it's a Scheme Twist or Master Strike, this card goes back to where it was when fought.")
            end
        end
    end
    if schemeParts[1] == "The Mark of Khonshu" and cityEntering == 1 then
        if hasTag2(cards[1],"Cost:") then
            cards[1].addTag("Villain")
            cards[1].addTag("Khonshu Guardian")
            powerButton(cards[1],"updateTwistPower",hasTag2(cards[1],"Cost:")*2)
        end
    end
    if schemeParts[1] == "Transform Citizens Into Demons" and cityEntering == 1 then
        if cards[1].getName() == "Jean Grey (DC)" then
            powerButton(cards[1],"updateTwistPower",hasTag2(cards[1],"Cost:")+goblincount)
            cards[1].addTag("Villain")
            cards[1].addTag("VP4")
        end
    end
    return twistsresolved
end

function demolish(colors,n,altsource,ko)
    if not colors then
        colors = {}
        for _,o in pairs(Player.getPlayers()) do
            table.insert(colors,o.color)
        end
    end
    if not n then
        n = 1
    end
    local name1 = "Discarded"
    local name2 = "Discard"
    if ko then
       name1 = "KO'd"
       name2 = "KO"    
    end
    local callbacksresolved = 0
    local demolishEffect = function()
        for _,o in pairs(colors) do
            local hand = Player[o].getHandObjects()
            local costfound = 0
            if hand[1] then
                local handcosts = table.clone(herocosts)
                for _,h in pairs(hand) do
                    if handcosts[hasTag2(h,"Cost:")] then
                        handcosts[hasTag2(h,"Cost:")] = handcosts[hasTag2(h,"Cost:")] + 1
                    end
                end
                local posPlay = offerCards(o)
                local posdiscard = nil
                if ko == true then
                    posdiscard = getObjectFromGUID(kopile_guid).getPosition()
                else
                    posdiscard = getObjectFromGUID(playerBoards[o]).positionToWorld(pos_discard)
                end
                for i=1,10 do
                    if costs[i] > 0 and handcosts[i] > 0 then
                        local carddropped = 0
                        for _,h in pairs(hand) do
                            if hasTag2(h,"Cost:") == i then
                                if costs[i] >= handcosts[i] then
                                    h.setPosition(posdiscard)
                                    broadcastToColor(name1 .. " " .. h.getName() .. " after getting demolished.",o,o)
                                    break
                                else
                                    posPlay = offerCards(o.color,posPlay)
                                    h.setPosition(posPlay)
                                    carddropped = carddropped + 1
                                end
                            end
                        end
                        if carddropped > 0 then
                            broadcastToColor(name2 .. " " .. costs[i] .. " of the " .. carddropped .. " cards with cost " .. i .. " that were put into play from your hand. Return the rest to hand.",o,o)
                        end
                    end
                end
            end
        end
    end
    local logDemolish = function(obj)
        costs[hasTag2(obj,"Cost:")] = costs[hasTag2(obj,"Cost:")] + 1
        broadcastToAll("Demolish effect with " .. obj.getName() .. " with cost " .. hasTag2(obj,"Cost:") .. "!")
        callbacksresolved = callbacksresolved + 1
        if callbacksresolved == n then
            demolishEffect()
        end
    end
    if not altsource then
        costs = table.clone(herocosts)
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        if herodeck[1].tag == "Deck" then
            bump(herodeck[1],n+1)
        end
        local pos = herodeck[1].getPosition()
        for i = 0,n-1 do
            if herodeck[1] and herodeck[1].tag == "Deck" then
                pos.y = pos.y + i
                herodeck[1].takeObject({position = pos,
                    callback_function = logDemolish})
                if herodeck[1].remainder then
                   herodeck[1] = herodeck[1].remainder
                end
            elseif herodeck[1] and herodeck[1].tag == "Card" then
                pos.y = pos.y + i
                logDemolish(herodeck[1])
                herodeck[1].setPosition(pos)
            else
                return nil
            end
        end
    else
        costs = altsource
        demolishEffect()
    end
end

function offerCards(color,position)
    if not position then
        local position = getObjectFromGUID(playerBoards[color]).getPosition()
        if color == "White" then
            position.x = position.x + 15
        elseif color == "Blue" then
            position.x = position.x - 15
        else
            position.z = position.z - 15
        end
        return position
    end
    if color == "White" then
        position.z = position.z + 4
    elseif color == "Blue" then
        position.z = position.z - 4
    else
        position.x = position.x + 7
    end
    return position
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
                return tonumber(o:match("%d+"))
            end
        end
    end
    return nil
end

function promptDiscard(color,handobjects,n,pos,flip)
    if not handobjects then
        handobjects = Player[color].getHandObjects()
    end
    if not n then
        n = 1
    else
        n = math.min(n,#handobjects)
    end
    if n < 1 then
        return nil
    end
    if not pos then
        pos = getObjectFromGUID(playerBoards[color]).positionToWorld(pos_discard)
    end
    if #handobjects == n then
        for i = 1,n do
            handobjects[i].setPosition(pos)
        end
    else
        for i,o in pairs(handobjects) do
            _G["discardCard" .. color .. i] = function()
                n = n-1
                if n == 0 then
                    for _,p in pairs(handobjects) do
                        p.clearButtons()
                    end
                end
                if flip then
                    handobjects[i].flip()
                end
                handobjects[i].setPosition(pos)
            end
            o.createButton({click_function="discardCard" .. color .. i,
                function_owner=self,
                position={0,22,0},
                label="Discard",
                tooltip="Discard this card.",
                font_size=250,
                font_color="Black",
                color={1,1,1},
                width=750,height=450})
        end
    end
end

function gainShard(color,zone)
    local shard = getObjectFromGUID("eff5ba")
    if not shard then
        broadcastToColor("Shard was not found. Please take one manually.")
        return nil
    end
    local shardpos = nil
    if not zone then
        shardpos = getObjectFromGUID(playerBoards[color]).positionToWorld({-1.5,4,4})
    else
        shardpos = getObjectFromGUID(zone).getPosition()
    end
    shard.clone({position = shardpos})
end

function playHorror()
    local horrorPile = getObjectFromGUID(horrorPileGUID)
    local horrorZone = getObjectFromGUID(topBoardGUIDs[1])
    horrorPile.randomize()
    horrorPile.takeObject({position=horrorZone.getPosition(),
            flip=false,
            smooth=false})
    broadcastToAll("Random horror added to the game, above the board.")
end