function onLoad()
    --starting values
    twistsresolved = 0
    twistsstacked = 0
    strikesresolved = 0
    strikesstacked = 0
    
    villainstoplay = 0
    cityPushDelay = 0
    
    createButtons()
    
    setNotes("[FF0000][b]Scheme Twists resolved:[/b][-] 0\r\n\r\n[ffd700][b]Master Strikes resolved:[/b][-] 0")
    
    --import guids
    setupGUID = "912967"
    
    local guids3 = {
        "playerBoards",
        "vpileguids",
        "hqguids",
        "playguids",
        "shardguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "city_zones_guids",
       "topBoardGUIDs",
       "allTopBoardGUIDS",
       "pos_vp2",
       "pos_discard"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = callGUID(o,2)
    end
        
    local guids1 = {
        "escape_zone_guid",
        "kopile_guid",
        "bystandersPileGUID",
        "woundsDeckGUID",
        "sidekickDeckGUID",
        "officerDeckGUID",
        "schemePileGUID",
        "mmPileGUID",
        "strikePileGUID",
        "horrorPileGUID",
        "twistPileGUID",
        "villainPileGUID",
        "hmPileGUID",
        "ambPileGUID",
        "heroPileGUID",
        "heroDeckZoneGUID",
        "villainDeckZoneGUID",
        "schemeZoneGUID",
        "mmZoneGUID",
        "strikeZoneGUID",
        "horrorZoneGUID",
        "twistZoneGUID",
        "shardGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = callGUID(o,1)
    end
    
    --the guids don't change, the current_city might
    current_city = table.clone(city_zones_guids)
    
    
end

function createButtons()
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

function getNextColor(color)
    local nextcolor = nil
    for i,o in pairs(Player.getPlayers()) do
        if o.color == color then
            if i == 1 then
                nextcolor = Player.getPlayers()[#Player.getPlayers()].color
            else
                nextcolor = Player.getPlayers()[i-1].color
            end
            break
        end
    end
    return nextcolor
end

function merge(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end
   return t1
end

function click_rescue_bystander(obj, player_clicker_color) 
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local bspile = getObjectFromGUID(bystandersPileGUID)
    --following is a fix if mojo changes the bspile guid
    if not bspile then
        bystandersPileGUID = callGUID("bystandersPileGUID",1)
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

function click_get_wound(obj, player_clicker_color, alt_click,top)
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local woundsDeck=getObjectFromGUID(woundsDeckGUID)
    local dest = playerBoard.positionToWorld(pos_discard)
    dest.y = dest.y + 3
    local toflip = nil
    if top then
        dest = playerBoard.positionToWorld({0.957, 3.178, 0.222})
        toflip = function(obj)
            obj.flip()
        end
    else
        local masterminds = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))
        if masterminds[1] then
            for _,o in pairs(masterminds) do
                if o == "Mephisto" then
                    dest = playerBoard.positionToWorld({0.957, 3.178, 0.222})
                    toflip = function(obj)
                        obj.flip()
                    end
                    break
                end
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

function getWound(color)
    click_get_wound(nil,color)
end

function dealWounds(top)
    for i,_ in pairs(playerBoards) do
        if Player[i].seated == true then
            click_get_wound(getObjectFromGUID(woundsDeckGUID),i,nil,top)
        end
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

function ascendVillain(name,group,ambush)
    local ascendants = {
        ["The Deadlands"] = "Zombie Loki",
        ["The Deadlands2"] = "Zombie Mr. Sinister",
        ["The Deadlands3"] = "Zombie Thanos",
        ["Domain of Apocalypse"] = "Apocalyptic Magneto",
        ["Wasteland"] = "Wasteland Kingpin",
        ["Deadpool's Secret Secret Wars"] = "Deadpool",
        ["Guardians of Knowhere"] = "Angela",
        ["Utopolis"] = "Warrior Woman",
        ["X-Men '92"] = "'92 Professor X",
    }
    local ambushAscendants = {
        ["Hellfire Club"] = "Mastermind",
        ["Sisterhood of Mutants"] = "Lady Mastermind"
    }
    if not ambush then
        for i,o in pairs(ascendants) do
            log("#")
            log(i .. o)
            if o == name and i:find(group) then
                return true
            end
        end
    else
        for i,o in pairs(ambushAscendants) do
            if o == name and i == group then
                return true
            end
        end
    end
    return false
end

function shift_to_next(objects,targetZone,enterscity,schemeParts)
    --all found cards, decks and shards (objects) in a city space will be moved to the next space (targetzone)
    --enterscity is equal to 1 if this shift is a single card moving into the city
    local isEnteringCity = enterscity or 0
    for _,obj in pairs(objects) do
        local targetZone_final = targetZone
        local shard = false
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
                gainShard(nil,getObjectFromGUID(mmZoneGUID))
                broadcastToAll("A Shard from an escaping villain was moved to the mastermind!",{r=1,g=0,b=0})
                obj.Call('resetVal')
                obj.destruct()
                shard = true
            elseif desc:find("VILLAINOUS WEAPON") and not hasTag2(obj,"Cost:") then
                -- weapons move to mastermind upon escaping
                -- extra cost tag condition if it's not a true villainous weapon, just a captured hero
                broadcastToAll("Villainous Weapon Escaped", {r=1,g=0,b=0})
                targetZone_final = getObjectFromGUID(mmZoneGUID)
                zPos = targetZone_final.getPosition().z - 1.5
            elseif bs == true then
                broadcastToAll("Bystander(s) Escaped", {r=1,g=0,b=0})
                for _,o in pairs(Player.getPlayers()) do
                    promptDiscard(o.color)
                end
                --if multiple bystanders escape, they're often stacked as a deck
                --only one notice will be given
            elseif hasTag2(obj,"Group:") and ascendVillain(obj.getName(),hasTag2(obj,"Group:")) then
                local mmZone = getObjectFromGUID(mmZoneGUID)
                targetZone_final = getObjectFromGUID(mmZone.Call('getNextMMLoc'))
                zPos = targetZone_final.getPosition().z
                mmZone.Call('updateMasterminds',obj.getName())
                mmZone.Call('updateMastermindsLocation',{obj.getName(),targetZone_final.guid})
                mmZone.Call('setupMasterminds',obj.getName())
            elseif obj.getName() == "Baby Hope Token" and schemeParts and schemeParts[1] == "Capture Baby Hope" then
                broadcastToAll("Baby Hope was taken away by a villain!", {r=1,g=0,b=0})
                getObjectFromGUID(twistPileGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition()})
                targetZone_final = getObjectFromGUID(schemeZoneGUID)
            else
                broadcastToAll("Villain Escaped", {r=1,g=0,b=0})
                if obj.getName() == "King Hyperion" then
                    targetZone_final = getObjectFromGUID(mmZoneGUID)
                    dealWounds()
                    broadcastToAll("King Hyperion escaped! Everyone gains a wound!")
                elseif obj.getName() == "Thor" and schemeParts and schemeParts[1] == "Crown Thor King of Asgard" then
                    getObjectFromGUID(twistPileGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                        smooth=false})
                        --this should be from the KO pile, but that is still a mess to sort out
                        --take them from the scheme twist pile for now
                    broadcastToAll("Thor escaped! Triumph of Asgard!")
                elseif obj.getName() == "Demon Bear" and schemeParts and schemeParts[1] == "The Demon Bear Saga" then
                    getObjectFromGUID(twistPileGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                        smooth=false})
                        --this should be from the KO pile, but that is still a mess to sort out
                        --take them from the scheme twist pile for now
                    broadcastToAll("The Demon Bear escaped! Dream Horror!")
                end
                if schemeParts and schemeParts[1] == "Change the Outcome of WWII" and (not wwiiInvasion or wwiiInvasion == false) then
                    wwiiInvasion = true
                    getObjectFromGUID(twistPileGUID).takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
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
        if not shard and (isEnteringCity == 1 or not desc:find("LOCATION")) then
            --locations don't move unless they are entering
            obj.setPositionSmooth({targetZone_final.getPosition().x+xshift,
                targetZone_final.getPosition().y + 3,
                zPos})
        end
    end
end

function click_draw_villain(obj)
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
            for _,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
                local zone = getObjectFromGUID(o)
                if zone.hasTag(Turns.turn_color) then
                    vildeckguid = zone.guid
                    break
                end
            end
        end
        if schemeParts[1] == "Breach Parallel Dimensions" then
            vildeckguid = obj.guid
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

function addBystanders(cityspace,face,posabsolute,pos)
    if face == nil then
        face = true
    end
    local targetZone = getObjectFromGUID(cityspace).getPosition()
    if posabsolute == nil then
        targetZone.z = targetZone.z - 2
    end
    if pos then
        targetZone = pos
    end
    local bspile = getObjectFromGUID(bystandersPileGUID)
    if not bspile then
        bystandersPileGUID = callGUID("bystandersPileGUID",1)
        bspile = getObjectFromGUID(bystandersPileGUID)
    end
    bspile.takeObject({position=targetZone,
        smooth=smooth,
        flip=face})
end

function push_all(city)
    --if all guids are still there, cards will be entering the city
    --this will cause issues if multiple cards enter at the same time
    --that should therefore never happen!
    if city[1] and city[1] == city_zones_guids[1] then
        cityEntering = 1
    else
        cityEntering = 0
    end
    --does the city table exist and does it have any elements in it
    if city[1] then
        --the zone which will be checked with this push
        local zoneGUID = table.remove(city,1)
        --the zone cards should be moved to
        local targetZoneGUID = city[1]
        if not targetZoneGUID then
            targetZoneGUID = escape_zone_guid
        end
        updatePower()
        local targetZone = getObjectFromGUID(targetZoneGUID)
        --find all cards, decks and shards in a zone
        local cards = get_decks_and_cards_from_zone(zoneGUID)
        if cards[1] and cards[1].tag == "Deck" and cityEntering == 1 then
            local pos = cards[1].getPosition()
            pos.y = pos.y + 3
            local moveFirstCardFromEnterStack = function(obj)
                --log(obj)
                moveCityZoneContent({obj},targetZone,city,cityEntering) 
            end
            cards[1].takeObject({position = pos,
                smooth = true,
                flip = false,
                index = 1,
                callback_function = moveFirstCardFromEnterStack})
        elseif cards[1] then
            moveCityZoneContent(cards,targetZone,city,cityEntering)  
        end
    end
end

function moveCityZoneContent(cards,targetZone,city,cityEntering)      
    --any cards found:
    if cards[1] and targetZone then
        --retrieve setup information
        local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
        local bspile = getObjectFromGUID(bystandersPileGUID)
        if not bspile then
            bystandersPileGUID = callGUID("bystandersPileGUID",1)
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
            local proceed = nonTwistspecials(cards,schemeParts,city)
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
                if schemeParts[1] ~= "Age of Ultron" and schemeParts[1] ~= "Steal the Weaponized Plutonium" and schemeParts[1] ~= "War of the Frost Giants" then
                    return cards[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                end
            end
        
            --master strikes always go to the master strike zone
            --maybe later on they can be scripted, but this requires knowing all masterminds that are present
            if cards[1].getName() == "Masterstrike" then
                strikesresolved = strikesresolved + 1
                updatePower()
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
                    local citycontent = get_decks_and_cards_from_zone(cityspaces[1])
                    --locations don't count as villains, so they get skipped
                    --locations may rarely capture bystanders. place these OUTSIDE the city or this will break
                    local locationfound = false
                    if citycontent[1] and not citycontent[2] then
                        if citycontent[1].getDescription():find("LOCATION") then
                            locationfound = true
                        end
                    end
                    
                    --if no cards or only a location, check next city space
                    if not next(citycontent) or locationfound == true then
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
                        elseif vw == true and not hasTag2(cards[1],"Cost:") then
                            --weapons get KO'd
                            targetZone = getObjectFromGUID(kopile_guid)
                            broadcastToAll("Villainous Weapon KO'd as city is empty!",{r=1,g=0,b=0})
                        elseif vw == true then
                            targetZone = getObjectFromGUID(mmZoneGUID)
                            broadcastToAll("Captured hero moved to Mastermind as city is empty!",{r=1,g=0,b=0})
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
end

function click_push_villain_into_city()
-- when moving the villain deck buttons, change the first guid to a new scripting zone
    cityPushDelay = cityPushDelay + 1
    checkCityContent()
end

function checkCityContent()
    if cityPushDelay > 1 then
        Wait.time(checkCityContent,cityPushDelay)
        cityPushDelay = cityPushDelay - 1
        return nil
    else
        Wait.time(function() cityPushDelay = cityPushDelay - 1 end,1)
    end
    local city_topush = table.clone(current_city)
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    if schemeParts then
        if schemeParts[1] == "Fragmented Realities" then
            for i,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
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

function updatePower()
    for _,o in pairs(city_zones_guids) do
        local cityobjects = get_decks_and_cards_from_zone(o)
        for _,object in pairs(cityobjects) do
            if object.getButtons() then
                local index = nil
                for i,b in pairs(object.getButtons()) do
                    if b.click_function == "updatePower" then
                        index = i
                        break
                    end
                end
                if index then
                    if object.hasTag("Corrupted") then
                        object.editButton({index = index-1,label=twistsstacked+2})
                    elseif object.hasTag("Possessed") or object.hasTag("Killbot") then    
                        object.editButton({index = index-1,label=twistsstacked})
                    elseif object.hasTag("Brainwashed") then
                        object.editButton({index = index-1,label=twistsstacked+3})
                    elseif object.hasTag("Phalanx-Infected") then
                        object.editButton({index = index-1,label=math.floor(twistsstacked/2)+hasTag2(object,"Cost:")})
                    elseif object.getName() == "Smugglers" then
                        object.editButton({index = index-1,label = "+" .. strikesresolved})
                    elseif object.hasTag("Khonshu Guardian") then
                        if i % 2 == 0 then
                            object.editButton({index = index-1,label = hasTag2(object,"Cost:")*2})
                        else
                            object.editButton({index = index-1,label = hasTag2(object,"Cost:")})
                        end
                    elseif noMoreMutants and object.getName() == "Scarlet Witch (R)" then
                        object.editButton({index = index-1,label = hasTag2(object,"Cost:") + 4})
                    elseif object.getName() == "Jean Grey (DC)" and object.hasTag("VP4") then
                        if not goblincount then
                            goblincount = 0
                        end
                        object.editButton({index = index-1,label = hasTag2(object,"Cost:") + goblincount})
                    elseif object.getName() == "S.H.I.E.L.D. Assault Squad" or object.hasTag("Ambition") then
                        object.editButton({index = index-1,label = "+" .. twistsstacked})
                    elseif object.getName() == "Graveyard" and object.hasTag("Location") then
                        for _,obj in pairs(cityobjects) do
                            if obj.hasTag("Villain") then
                                object.editButton({index = index-1,label = 7 + 2*reaperbonus + 2})
                                return nil
                            end
                        end
                        object.editButton({index = index-1,label = 7 + 2*reaperbonus})
                    elseif object.getName() == "Evolved Ultron" then
                        local ultronpower = 4
                        local evolutionPile = get_decks_and_cards_from_zone(twistZoneGUID)
                        local evolutionPileSize = 0
                        if evolutionPile[1] then
                            if evolutionPile[1].tag == "Deck" then
                                evolutionPileSize = #evolutionPile[1].getObjects()
                            elseif evolutionPile[1] then
                                evolutionPileSize = 1
                            end
                        else
                            broadcastToAll("Evolution deck missing???")
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
                            for i,o in pairs(evolutionPile[1].getObjects()) do
                                for _,k in pairs(o.tags) do
                                    if k:find("HC:") then
                                        evolutionColors[k] = true
                                    end
                                end
                            end
                        else
                            for i,o in pairs(evolutionPile[1].getTags()) do
                                if o:find("HC:") then
                                    evolutionColors[o] = true
                                end
                            end
                        end
                        for i,o in pairs(hqguids) do
                            local herocard = getObjectFromGUID(o).Call('getHeroUp')
                            if herocard then
                                for _,tag in pairs(herocard.getTags()) do
                                    if tag:find("HC:") then
                                        if evolutionColors[tag] == true then
                                            ultronpower = ultronpower + 1
                                            break
                                        end
                                    end
                                end
                            else
                                broadcastToAll("Hero in hq space " .. i .. " is missing?")
                            end
                        end
                        object.editButton({index = index-1,label=ultronpower})
                    end
                end
            end
        end
    end
end

function updateHQTags()
    for i,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
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

function obedienceDisk(obj,player_clicker_color)
    printToColor("Heroes in the HQ zone below this one cost 1 more for each Obedience Disk (twist) here.",player_clicker_color)
    return nil
end

function powerButton(obj,label,toolt,id,click_f,otherposition)
    if obj.locked == nil then
        label = obj[2]
        toolt = obj[3]
        id = obj[4]
        click_f = obj[5]
        otherposition = obj[6]
        obj = obj[1]
    end
    if not obj or not label then
        broadcastToAll("Error: Missing argument to card boost.")
        return nil
    end
    local pos = otherposition
    if not otherposition then
        pos = {0,22,0}
    end
    if not click_f then
        click_f = 'updatePower'
    end
    if not id then
        id = "base"
    end
    local index = nil
    local toolt_orig = nil
    if obj.getButtons() then
        for i,o in pairs(obj.getButtons()) do
            if o.click_function == click_f then
                index = i
                toolt_orig = o.tooltip
                break
            end
        end
    end
    if not toolt_orig then
        toolt = "Click to update villain's power!\n - Base power boost of this card [" .. id .. ":" .. label .. "]"
    elseif not toolt_orig:find("%[" .. id .. ":") then
        if toolt then
            toolt = toolt_orig .. "\n - " .. toolt .. " [" .. id .. ":" .. label .. "]"
        else
            toolt = toolt_orig .. "\n - Unidentified bonus [" .. id .. ":" .. label .. "]"
        end
    end
    if otherposition or not index then
        obj.createButton({click_function=click_f,
            function_owner=self,
            position=pos,
            label=label,
            tooltip=toolt,
            font_size=500,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    else
        local lab,tool = getObjectFromGUID(mmZoneGUID).Call('updateLabel',{obj,index,label,id,toolt})
        obj.editButton({index = index - 1,
            label = lab,
            tooltip = tool})
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
        getObjectFromGUID(vildeckguid).createButton({click_function="updatePower",
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
        function ultronCallback(obj)
            Wait.time(updatePower,1)
        end
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        if herodeck[1] then
            if herodeck[1].tag == "Deck" then
                herodeck[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                    flip=true,
                    callback_function=ultronCallback})
            else
                herodeck[1].flip()
                herodeck[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
                Wait.time(updatePower,1)
            end
        end
        cards[1].setName("Evolved Ultron")
        cards[1].setTags({"VP6"})
        cards[1].setDescription("EMPOWERED: This card gets extra Power for each Hero with the listed Hero Class in the Evolution Pile.")
        powerButton(cards[1],ultronpower)
        return twistsresolved
    end
    if schemeParts[1] == "Annihilation: Conquest" then
        stackTwist(cards[1])
        local candidate = {}
        local cost = 0
        for i,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                if hasTag2(hero,"Cost:") and hasTag2(hero,"Cost:") > cost then
                    candidate = {}
                    cost = hasTag2(hero,"Cost:")
                    candidate[i] = hero
                elseif hasTag2(hero,"Cost:") and hasTag2(hero,"Cost:") == cost then
                    candidate[i] = hero
                end
            else
                printToAll("Missing hero in HQ!!")
                return nil
            end
        end
        local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
        pos.y = pos.y + 3
        local candn = 0
        for _,o in pairs(candidate) do
            candn = candn + 1
        end
        if candn > 1 then
            broadcastToAll("Scheme Twist: Choose one of the tied highest cost heroes in the HQ to enter the city as a villain.")
            local processPhalanxInfected = function(obj,index) 
                obj.setPositionSmooth(pos)
                powerButton(obj,hasTag2(obj,"Cost:")+math.floor(twistsstacked/2))
                obj.addTag("Villain")
                obj.addTag("Phalanx-Infected")
                getObjectFromGUID(hqguids[index]).Call('click_draw_hero')
                Wait.time(click_push_villain_into_city,1)
            end
            promptDiscard(Turns.turn_color,
                candidate,
                1,
                pos,
                nil,
                "Push",
                "Push this hero into the city as a Phalanx-Infected villain.",
                processPhalanxInfected,
                "self")
        elseif candn == 1 then
            local zoneguid = nil
            local hero = nil
            for i,o in pairs(candidate) do
                zoneguid = i
                hero = o
            end
            hero.setPositionSmooth(pos)
            powerButton(hero,hasTag2(hero,"Cost:")+math.floor(twistsstacked/2))
            hero.addTag("Villain")
            hero.addTag("Phalanx-Infected")
            Wait.time(click_push_villain_into_city,1.5)
            getObjectFromGUID(hqguids[zoneguid]).Call('click_draw_hero')
        else
            broadcastToAll("No heroes found?")
            return nil
        end
        return nil
    end
    if schemeParts[1] == "Anti-Mutant Hatred" then
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
        broadcastToAll("Scheme Twist: Angry Mob moved to " .. pcolor .. " player's discard pile!")
        cards[1].setName("Angry Mob")
        cards[1].addTag("Angry Mob")
        cards[1].setRotationSmooth(brot)
        cards[1].setPositionSmooth(dest)
        function onPlayerTurn(player,previous_player)
            local hand = player.getHandObjects()
            if hand[1] then
                for _,o in pairs(hand) do
                    if o.getName() == "Angry Mob" and o.hasTag("Angry Mob") then
                        broadcastToAll("Angry Mob! " .. previous_player.color .. " player was assaulted by an angry mob from " .. player.color .. " and wounded.")
                        local playerBoard = getObjectFromGUID(playerBoards[previous_player.color])
                        local dest = playerBoard.positionToWorld(pos_discard)
                        dest.y = dest.y + 3
                        if previous_player.color == "White" then
                            angle = 90
                        elseif previous_player.color == "Blue" then
                            angle = -90
                        else
                            angle = 180
                        end
                        local brot = {x=0, y=angle, z=0}
                        o.use_hands = false
                        o.setRotationSmooth(brot)
                        o.setPositionSmooth(dest)
                        Wait.time(function() o.use_hands = true end,1)
                        click_get_wound(nil,previous_player.color)
                    end
                end
            end
        end
        return nil
    end
    if schemeParts[1] == "Asgardian Test of Worth" then
        if twistsresolved < 8 then
            local worthy = 0
            local iter = 0
            local players = Player.getPlayers()
            for i,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                if hand[1] then
                    for _,obj in pairs(hand) do
                        if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 4 then
                            worthy = worthy + 1
                            table.remove(players,i-iter)
                            iter = iter + 1
                            break
                        end
                    end
                end
            end
            for _,o in pairs(players) do
                promptDiscard(o.color)
                broadcastToColor("Scheme Twist: You are not Worthy, so discard a card.",o.color,o.color)
            end
            if worthy/#Player.getPlayers() <= 0.5 then
                stackTwist(cards[1])
                broadcastToAll("Moral Failing! Not enough players were worthy.")
            else
                koCard(cards[1])
            end
        elseif twistsresolved < 12 then
            stackTwist(cards[1])
            broadcastToAll("Moral Failing!")
        end
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
    if schemeParts[1] == "Bathe Earth In Cosmic Rays" then
        function batheNextPlayer(obj,index,color)
            if index then
                getObjectFromGUID(hqguids[index]).Call('click_draw_hero')
            end
            local nextcolor = getNextColor(color)
            if nextcolor ~= Turns.turn_color then
                batheTheEarth(nextcolor)
            end
        end
        function pickNewHero(obj,index,color)
            local cost = hasTag2(obj,"Cost:")
            local heroes = {}
            for i,h in pairs(hqguids) do
                local hero = getObjectFromGUID(h).Call('getHeroUp')
                if hasTag2(hero,"Cost:") <= cost then
                    heroes[i] = hero
                end
            end
            local playerBoard = getObjectFromGUID(playerBoards[color])
            local dest = playerBoard.positionToWorld(pos_discard)
            dest.y = dest.y + 3
            local candn = 0
            for _,o in pairs(heroes) do
                candn = candn + 1
            end
            if candn > 1 then
                promptDiscard(color,heroes,1,dest,nil,"Gain","Gain this hero.",batheNextPlayer,"self",color)
                broadcastToColor("Choose a hero in the HQ to gain.",color,color)
            elseif candn == 1 then
                local zoneguid = nil
                local hero = nil
                for i,o in pairs(heroes) do
                    zoneguid = i
                    hero = o
                end
                hero.setPositionSmooth(dest)
                broadcastToColor("You gained the only eligible hero from the HQ (" .. hero.getName() .. ").",color,color)
                batheNextPlayer(hero,zoneguid,color)
            else
                broadcastToColor("No eligible hero in the HQ to gain.",color,color)
                batheNextPlayer(nil,nil,color)
            end
        end
        function batheTheEarth(color)
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
                broadcastToColor("KO a non-grey hero from your hand.",color,color)
                promptDiscard(color,hand,1,getObjectFromGUID(kopile_guid).getPosition(),nil,"KO","KO this card.",pickNewHero,"self")
            else
                broadcastToColor("No non-grey heroes in your hand to KO.",color,color)
                batheNextPlayer(nil,nil,color)
            end
        end
        batheTheEarth(Turns.turn_color)
        broadcastToAll("Master Strike: Each player in turn KOs a non-grey Hero, then selects one from the HQ with equal cost or less and gains it.")
        return twistsresolved
    end
    if schemeParts[1] == "Brainwash the Military" then
        if twistsresolved < 7 then
            stackTwist(cards[1])
            playVillains()
            Wait.time(updatePower,1)
            broadcastToAll("Scheme Twist: Another card was played from the villain deck!")
            return nil
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
        return twistsresolved
    end
    if schemeParts[1] == "Break the Planet Asunder" then
        stackTwist(cards[1])
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            local attack = 0
            if hero then
                if not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < twistsstacked then
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
        local annihilationZone = getObjectFromGUID(topBoardGUIDs[2])
        local annihilationdeck = get_decks_and_cards_from_zone(topBoardGUIDs[2])
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
        local annihilationMMzone = getObjectFromGUID(topBoardGUIDs[1])
        local refeedMM = function()
            local deck = get_decks_and_cards_from_zone(topBoardGUIDs[2])
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
            local deck = get_decks_and_cards_from_zone(topBoardGUIDs[2])
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
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = get_decks_and_cards_from_zone(o)
                local annipile = getObjectFromGUID(topBoardGUIDs[4])
                local copguids = {}
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
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
                elseif vpilecontent[1] and vpilecontent[1].getName() == "Cops" then
                    vpilecontent[1].setPositionSmooth(annipile.getPosition())
                end
            end
        end
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local handi = table.clone(hand)
            local iter = 0
            for i,obj in ipairs(handi) do
                if not hasTag2(obj,"HC:") then
                    table.remove(hand,i-iter)
                    iter = iter + 1
                end
            end
            if hand[1] then
                local lockUp = function(obj)
                    obj.setDescription(obj.getDescription() .. "\nARTIFACT: Ensures this card is not removed during clean-up.")
                    --obj.locked = true
                    local heroguid = obj.guid
                    local cops = get_decks_and_cards_from_zone(topBoardGUIDs[4])
                    local objpos = obj.getPosition()
                    objpos.y = objpos.y + 3
                    objpos.z = objpos.z -1
                    local lockCop = function(obj)
                        --obj.locked = true
                        obj.setDescription(obj.getDescription() .. "\nARTIFACT: Ensures this card is not removed during clean-up.")
                        _G["unlock" .. o.color .. obj.guid .. heroguid] = function(obj)
                            obj.setDescription(obj.getDescription():gsub("\nARTIFACT: Ensures this card is not removed during clean%-up.",""))
                            local hero = getObjectFromGUID(heroguid)
                            hero.setDescription(hero.getDescription():gsub("\nARTIFACT: Ensures this card is not removed during clean%-up.",""))
                            --hero.locked = false
                            obj.setPosition(getObjectFromGUID(vpileguids[o.color]).getPosition())
                            obj.clearButtons()
                            --obj.locked = false
                        end
                        obj.createButton({click_function="unlock" .. o.color .. obj.guid .. heroguid,
                            function_owner=self,
                            position={0,22,0},
                            label="Fight",
                            tooltip="Fight this cop to rescue the hero",
                            font_size=250,
                            font_color="Black",
                            color={1,1,1},
                            width=750,height=450})
                    end
                    if cops[1] and cops[1].tag == "Deck" then
                        cops[1].takeObject({position = objpos,
                            callback_function = lockCop,
                            smooth = true})
                    elseif cops[1] then
                        cops[1].setPositionSmooth(objpos)
                        lockCop(cops[1])
                    end
                end
                local playcontent = get_decks_and_cards_from_zone(playguids[o.color])
                local copcount = 0
                if playcontent[1] then
                    for _,card in pairs(playcontent) do
                        if card.getName() == "Cops" then
                            copcount = copcount + 1
                        end
                    end
                end
                promptDiscard(o.color,hand,1,getObjectFromGUID(playerBoards[o.color]).positionToWorld({2-2*copcount,4,3.7}),nil,"Lock","Lock up this card.",lockUp,"self")
            end
        end
        broadcastToAll("Scheme Twist: Choose a non-grey hero from your hand to be locked up.")
        return twistsresolved
    end
    if schemeParts[1] == "Capture Baby Hope" then
        local babyfound = false
        for _,o in pairs(city) do
            local cityobjects = getObjectFromGUID(o).getObjects()
            if cityobjects[1] then
                for _,object in pairs(cityobjects) do
                    if object.getName() == "Baby Hope Token" then
                        babyfound = true
                        object.setPositionSmooth(getObjectFromGUID(schemeZoneGUID).getPosition())
                    end
                end
                if babyfound == true then
                    broadcastToAll("Villain with Baby Hope escaped!",{r=1,g=0,b=0})
                    cityobjects = get_decks_and_cards_from_zone(o)
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
                    babyHope.setPositionSmooth(getObjectFromGUID(schemeZoneGUID).getPosition())
                end
            end
            koCard(cards[1])
        end
        return nil
    end
    if schemeParts[1] == "Change the Outcome of WWII" then
        koCard(cards[1])
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
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
                table.insert(current_city,1,city_zones_guids[1])
            elseif wwcountries[twistsresolved] > 5 then
                table.insert(city,"d30aa1")
                current_city = table.clone(city)
                table.insert(current_city,1,city_zones_guids[1])
            else
                current_city = table.clone(city)
                table.insert(current_city,1,city_zones_guids[1])
            end
            for i,o in pairs(city_zones_guids) do
                if not current_city[i] then
                    nonCityZoneShade(o)
                end
            end
        end
        local vildeckLanded = function()
            local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
            if vildeck and vildeck.getQuantity() == vildeckcount then
                return true
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
        local monsterpit = get_decks_and_cards_from_zone(twistZoneGUID)
        local monsterpower = 0
        if monsterpit[1] then
            if monsterpit[1].tag == "Deck" then
                local monsterToEnter = monsterpit[1].getObjects()[1]
                for _,i in pairs(monsterToEnter.tags) do
                    if i:find("Power:") then
                        monsterpower = tonumber(i:match("%d+"))
                    end
                end
                monsterpit[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    flip=true,
                    callback_function = click_push_villain_into_city})
            else
                monsterpower = hasTag2(monsterpit[1],"Power:")
                monsterpit[1].flip()
                monsterpit[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
                local lastMonsterSpawned = function()
                    local monster = get_decks_and_cards_from_zone(city_zones_guids[1])
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
        local skpile = getObjectFromGUID(sidekickDeckGUID)
        broadcastToAll("Scheme Twist!",{1,0,0})
        local pushSidekick = function(obj)
            obj.addTag("Corrupted")
            powerButton(obj,twistsstacked+2)
            obj.setDescription("WALL-CRAWL: When fighting this card, gain it to top of your deck as a hero instead of your victory pile.")
            local sidekickLanded = function()
                local landed = get_decks_and_cards_from_zone(city_zones_guids[1])
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
            skpile.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                smooth = false,
                flip = true,
                callback_function = pushSidekick})
        end
        local twistMoved = function()
            local twist = get_decks_and_cards_from_zone(city_zones_guids[1])
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
                cards[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
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
        local cityobjects = get_decks_and_cards_from_zone(twistZoneGUID)
        if cityobjects[1] and cityobjects[1].tag == "Card" and cityobjects[1].getName() == "Thor" then
            local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
            if bridgeobjects[1] then
                shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
            end
            cityobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[6]).getPosition())
            addBystanders(city_zones_guids[6])
            addBystanders(city_zones_guids[6])
            addBystanders(city_zones_guids[6])
            broadcastToAll("Scheme Twist! Thor entered the city.",{1,0,0})
            return twistsresolved
        elseif cityobjects[1] and cityobjects[1].tag == "Deck" then
            for _,o in pairs(cityobjects[1].getObjects()) do
                if o.name == "Thor" then
                    local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                    if bridgeobjects[1] then
                        shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                    end
                    cityobjects[1].takeObject({position = getObjectFromGUID(city_zones_guids[6]).getPosition(),
                        guid = o.guid,
                        smooth = true})
                    addBystanders(city_zones_guids[6])
                    addBystanders(city_zones_guids[6])
                    addBystanders(city_zones_guids[6])
                    broadcastToAll("Scheme Twist! Thor entered the city.",{1,0,0})
                    return twistsresolved
                end
            end
        end
        --or the escape pile
        local escapedobjects = get_decks_and_cards_from_zone(escape_zone_guid)
        if escapedobjects[1] and escapedobjects[1].tag == "Deck" then
            for _,object in pairs(escapedobjects[1].getObjects()) do
                if object.name == "Thor" then
                    local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                    if bridgeobjects[1] then
                        shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                    end
                    escapedobjects[1].takeObject({guid=object.guid,
                        position=getObjectFromGUID(city_zones_guids[6]).getPosition(),
                        smooth=true})
                    addBystanders(city_zones_guids[6])
                    addBystanders(city_zones_guids[6])
                    addBystanders(city_zones_guids[6])
                    broadcastToAll("Scheme Twist! Thor re-entered the city from the escape pile.",{1,0,0})
                    return twistsresolved
                end
            end
        elseif escapedobjects[1] and escapedobjects[1].tag == "Card" then
            if escapedobjects[1].getName() == "Thor" then
                local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                if bridgeobjects[1] then
                    shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                end
                escapedobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[6]).getPosition())
                addBystanders(city_zones_guids[6])
                addBystanders(city_zones_guids[6])
                addBystanders(city_zones_guids[6])
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
                            local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                            if bridgeobjects[1] then
                                shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                            end
                            vpobjects[1].takeObject({guid=object.guid,
                                position=getObjectFromGUID(city_zones_guids[6]).getPosition(),
                                smooth=true})
                            addBystanders(city_zones_guids[6])
                            addBystanders(city_zones_guids[6])
                            addBystanders(city_zones_guids[6])
                            broadcastToAll("Scheme Twist! Thor re-entered the city from ".. i .. " player's victory pile.",{1,0,0})
                            return twistsresolved
                        end
                    end
                elseif vpobjects[1] and vpobjects[1].tag == "Card" then
                    if vpobjects[1].getName() == "Thor" then
                        local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                        if bridgeobjects[1] then
                            shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                        end
                        vpobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[6]).getPosition())
                        addBystanders(city_zones_guids[6])
                        addBystanders(city_zones_guids[6])
                        addBystanders(city_zones_guids[6])
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
                    local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                    if bridgeobjects[1] then
                        shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                    end
                    kodobjects[1].takeObject({guid=object.guid,
                        position=getObjectFromGUID(city_zones_guids[6]).getPosition(),
                        smooth=true})
                    addBystanders(city_zones_guids[6])
                    addBystanders(city_zones_guids[6])
                    addBystanders(city_zones_guids[6])
                    broadcastToAll("Scheme Twist! Thor re-entered the city from the KO pile.",{1,0,0})
                    return twistsresolved
                end
            end
        elseif kodobjects[1] and kodobjects[1].tag == "Card" then
            if kodobjects[1].getName() == "Thor" then
                local bridgeobjects = get_decks_and_cards_from_zone(city_zones_guids[6])
                if bridgeobjects[1] then
                    shift_to_next(bridgeobjects,getObjectFromGUID(escape_zone_guid),0,schemeParts)
                end
                kodobjects[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[6]).getPosition())
                addBystanders(city_zones_guids[6])
                addBystanders(city_zones_guids[6])
                addBystanders(city_zones_guids[6])
                broadcastToAll("Scheme Twist! Thor re-entered the city from the KO pile.",{1,0,0})
                return twistsresolved
            end
        end
        --thor not found
        broadcastToAll("Thor not found? Where is he?")
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
                            local skpile = getObjectFromGUID(sidekickDeckGUID)
                            if skpile then
                                skpile.takeObject({position=pos,flip=true})
                                --if not, check if one card left
                                --otherwise give an officer
                            end
                            --still annotate villain's power boost
                            --also goes in updatePower
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
        cards[1].setName("Masterstrike")
        broadcastToAll("This Scheme Twist is a Master Strike!")
        click_push_villain_into_city()
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
            local spikedeck =  get_decks_and_cards_from_zone(twistZoneGUID)
            if spikedeck[1] then
                if spikedeck[1].tag == "Deck" then
                    spikedeck[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                        callback_function = spikepush, flip = true, smooth = true})
                elseif spikedeck[1].tag == "Card" then
                    spikedeck[1].flip()
                    if spikedeck[1].hasTag("Bystander") then
                        koCard(spikedeck[1])
                    else
                        spikedeck[1].setPositionSmooth(getObjectFromGUID(city_zones_guids[1]).getPosition())
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
                local mmZone = getObjectFromGUID(mmZoneGUID)
                mmZone.Call('updateMasterminds',obj.getName())
                mmZone.Call('updateMastermindsLocation',{obj.getName(),topBoardGUIDs[4]})
                mmZone.Call('setupMasterminds',obj.getName())
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
                    for _,k in pairs(table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))) do
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
            local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
            for _,o in pairs(table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))) do
                addBystanders(mmLocations[o])
            end
        elseif twistsresolved == 7 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Dark Reign of H.A.M.M.E.R. Officers" then
        stackTwist(cards[1])
        local sostack = getObjectFromGUID(officerDeckGUID)
        for i = 1,twistsresolved do
            sostack.takeObject({position=getObjectFromGUID(topBoardGUIDs[2]).getPosition(),
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
                local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
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
            local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
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
                scheme[1].setPositionSmooth(getObjectFromGUID(schemeZoneGUID).getPosition())
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
        local mmpos = getObjectFromGUID(mmZoneGUID).Call('getNextMMLoc')
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
                        local mmZone = getObjectFromGUID(mmZoneGUID)
                        obj.addTag("Ascended")
                        powerButton(obj,hasTag2(obj,"Power:")+2)
                        mmZone.Call('fightButton',mmpos)
                        local vp = hasTag2(obj,"VP") or 0
                        mmZone.Call('updateMasterminds',"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")")
                        mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")",mmpos})
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
                    local mmZone = getObjectFromGUID(mmZoneGUID)
                    powerButton(ascendCard,power+2)
                    mmZone.Call('fightButton',mmpos)
                    local vp = hasTag2(ascendCard,"VP") or 0
                    mmZone.Call('updateMasterminds',"Ascended Baron " .. ascendCard.getName() .. "(" .. vp .. ")")
                    mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. ascendCard.getName() .. "(" .. vp .. ")",mmpos})
                    shift_to_next(vilgroup,getObjectFromGUID(mmpos),1)
                    broadcastToAll("Scheme Twist: Villain in city ascended to become a mastermind!")
                end
            else
                broadcastToAll("Scheme Twist: No villains found.")
            end
        elseif twistsresolved == 8 then
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
                        local mmpos = getObjectFromGUID(mmZoneGUID).Call('getNextMMLoc')
                        if toAscend and mmpos then
                            broadcastToAll("Scheme Twist: Villain from " .. i .. "'s victory pile ascends!",i)
                            if vpilecontent[1].tag == "Deck" then
                                local annotateNewMM = function(obj)
                                    local mmZone = getObjectFromGUID(mmZoneGUID)
                                    obj.addTag("Ascended")
                                    powerButton(obj,hasTag2(obj,"Power:")+2)
                                    mmZone.Call('fightButton',mmpos)
                                    local vp = hasTag2(obj,"VP") or 0
                                    mmZone.Call('updateMasterminds',"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")")
                                    mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. obj.getName() .. "(" .. vp .. ")",mmpos})
                                end
                                vpilecontent[1].takeObject({position = getObjectFromGUID(mmpos).getPosition(),
                                    guid=toAscend,
                                    callback_function = annotateNewMM})
                            else
                                vpilecontent[1].addTag("Ascended")
                                powerButton(vpilecontent[1],hasTag2(vpilecontent[1],"Power:")+2)
                                vpilecontent[1].setPositionSmooth(getObjectFromGUID(mmpos).getPosition())
                                local mmZone = getObjectFromGUID(mmZoneGUID)
                                mmZone.Call('fightButton',mmpos)
                                local vp = hasTag2(ascendCard,"VP") or 0
                                mmZone.Call('updateMasterminds',"Ascended Baron " .. vpilecontent[1].getName() .. "(" .. vp .. ")")
                                mmZone.Call('updateMastermindsLocation',{"Ascended Baron " .. vpilecontent[1].getName() .. "(" .. vp .. ")",mmpos})
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
        getObjectFromGUID(heroDeckZoneGUID).createButton({click_function="updatePower",
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
        if not floorcontent then
            printToAll("ERROR: guids not found")
            return nil
        end
        if floorcontent[1] then
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
                floorcontent = get_decks_and_cards_from_zone(floorboom)
                if floorcontent[1] then
                    floorcontent[1].flip()
                    floorcontent[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                end
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
        if twistsresolved < 8 then
            local extrahq = callGUID("extrahq",2)
            local newhq = merge(table.clone(hqguids),extrahq)
            local candidate = {}
            for i,o in ipairs(newhq) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    table.insert(candidate,hero)
                else
                    printToAll("Missing hero in HQ!!")
                    return nil
                end
            end
            broadcastToAll("Scheme Twist: KO a hero from the HQ and the fear level goes down by 1, removing one HQ space")
            local purgeHero = function(obj,index) 
                koCard(obj)
                local ishq = false
                for i,o in pairs(hqguids) do
                    if o == newhq[index] then
                        ishq = i
                    end
                end
                if ishq ~= false and #newhq > 5 then
                    local removezone = table.remove(extrahq)
                    local pos = getObjectFromGUID(hqguids[ishq]).getPosition()
                    pos.y = pos.y + 2
                    getObjectFromGUID(removezone).Call('getHeroUp').setPosition(pos)
                    getObjectFromGUID(setupGUID).Call('removeExtraFearZone',removezone)
                    getObjectFromGUID(removezone).destruct()
                else
                    if extrahq[1] then
                        getObjectFromGUID(setupGUID).Call('removeExtraFearZone',newhq[index])
                        getObjectFromGUID(newhq[index]).destruct()
                    else
                        table.remove(hqguids,index)
                        getObjectFromGUID(newhq[index]).destruct()
                    end
                end
            end
            promptDiscard(Turns.turn_color,
                candidate,
                1,
                getObjectFromGUID(kopile_guid).getPosition(),
                nil,
                "KO",
                "KO this hero.",
                purgeHero,
                "self")
        else
            broadcastToAll("Scheme Twist: The Fear level is 0. Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Ferry Disaster" then
        if twistsresolved == 1 or twistsresolved == 5 then
            ferryzones = {table.unpack(allTopBoardGUIDS,7,11)}
        end
        if twistsresolved < 5 then
            table.remove(ferryzones)
            local bspile = getObjectFromGUID(bystandersPileGUID)
            bspile.setPositionSmooth(getObjectFromGUID(ferryzones[#ferryzones]).getPosition())
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
            table.remove(ferryzones,1)
            local bspile = getObjectFromGUID(bystandersPileGUID)
            bspile.setPositionSmooth(getObjectFromGUID(ferryzones[1]).getPosition())
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
        local gemfound = false
        local color = Turns.turn_color
        function killInfinityGemButton(obj)
            obj.clearButtons()
            obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
            Wait.time(click_push_villain_into_city,2)
            local shardAllGems = function()
                broadcastToAll("Scheme Twist: Shards added to all Infinity Gems in the city.")
                for _,o in pairs(city) do
                    local citycontent = get_decks_and_cards_from_zone(o)
                    if citycontent[1] then
                        for _,obj in pairs(citycontent) do
                            if obj.hasTag("Group:Infinity Gems") then
                                gainShard(nil,o)
                                break
                            end
                        end
                    end
                end
            end
            Wait.time(shardAllGems,4)
            for _,b in pairs(discardGemguids) do
                if b ~= obj.guid then
                    local card = getObjectFromGUID(b)
                    if card then
                        card.clearButtons()
                        card.locked = false
                        card.setPosition(getObjectFromGUID(playerBoards[latestGemColor]).positionToWorld(pos_discard))
                    end
                end
            end
            local playcontent = get_decks_and_cards_from_zone(playguids[latestGemColor])
            if playcontent[1] then
                for _,o in pairs(playcontent) do
                    if o.hasTag("Group:Infinity Gems") and o.guid ~= obj.guid then
                        o.clearButtons()
                    end
                end
            end
        end
        latestGemColor = nil
        while gemfound == false do
            color = getNextColor(color)
            if color == Turns.turn_color then
                gemfound = true
            end
            latestGemColor = color
            local playcontent = get_decks_and_cards_from_zone(playguids[color])
            if playcontent[1] then
                for _,o in pairs(playcontent) do
                    if o.hasTag("Group:Infinity Gems") then
                        o.createButton({click_function = 'killInfinityGemButton',
                            function_owner=self,
                            position={0,22,0},
                            label="Pick",
                            tooltip="Pick this Infinity Gem to re-enter the city.",
                            font_size=250,
                            font_color="Black",
                            color={1,1,1},
                            width=750,height=450})
                        gemfound = true
                    end
                end
            end
            local discarded = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
            discardGemguids = {}
            if discarded[1] and discarded[1].tag == "Deck" then
                for _,o in pairs(discarded[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k == "Group:Infinity Gems" then
                            gemfound = true
                            table.insert(discardGemguids,o.guid)
                            break
                        end
                    end
                end
                if discardGemguids[1] then
                    offerCards(color,discarded[1],discardGemguids,killInfinityGemButton,"Pick this Infinity Gem to re-enter the city.")
                end
            elseif discarded[1] then
                if discarded[1].hasTag("Group:Infinity Gems") then
                    gemfound = true
                    table.insert(discardGemguids,discarded[1].guid)
                    discarded[1].createButton({click_function = 'killInfinityGemButton',
                            function_owner=self,
                            position={0,22,0},
                            label="Pick",
                            tooltip="Pick this Infinity Gem to re-enter the city.",
                            font_size=250,
                            font_color="Black",
                            color={1,1,1},
                            width=750,height=450})
                end
            end
        end
        broadcastToAll("Scheme Twist: The first player with an Infinity Gem Artifact card in play or in their discard pile chooses on of those Infinity Gems to enter the city.")
        return twistsresolved
    end
    if schemeParts[1] == "Fragmented Realities" then
        koCard(cards[1])
        local villain_deck_zone = nil
        for _,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
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
        local color = Turns.turn_color
        for _,o in pairs(Player.getPlayers()) do
            local rot = 180
            if o.color == "White" then
                rot = 0
            else
                rot = 180
            end
            local playzone = getObjectFromGUID(playguids[o.color])
            playzone.createButton({click_function='updatePower',
                function_owner=self,
                position={0,0,0},
                rotation={0,rot,0},
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
            for _,o in pairs(Player.getPlayers()) do
                local playzone = getObjectFromGUID(playguids[o])
                playzone.removeButton(0)
            end
        end
        local killButtonCallback = function()
            Wait.condition(killButton,turnAgain)
        end
        Wait.condition(killButtonCallback,turnHasPassed)
        return twistsresolved
    end
    if schemeParts[1] == "Go Back in Time to Slay Heroes' Ancestors" then
        broadcastToAll("Scheme Twist: Purge a hero from the timestream!")
        local candidate = {}
        for i,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if hero then
                table.insert(candidate,hero)
            else
                printToAll("Missing hero in HQ!!")
                return nil
            end
        end
        local purgeHero = function(obj,index) 
            for i,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero and hero.getName() == obj.getName() then
                    koCard(hero)
                    getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
                end
            end
            getObjectFromGUID(hqguids[index]).Call('click_draw_hero')
        end
        promptDiscard(Turns.turn_color,
            candidate,
            1,
            getObjectFromGUID(twistZoneGUID).getPosition(),
            nil,
            "Purge",
            "Push this hero from the timestream!",
            purgeHero,
            "self")
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
        local villain_deck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
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
                                if k:find("Tactic:") then
                                    table.insert(tacticFound,vpileCards[j].guid)
                                    break
                                end
                            end
                        end
                        if tacticFound[1] and not tacticFound[2] then
                            vpilecontent[1].takeObject({position = getObjectFromGUID(villainDeckZoneGUID).getPosition(),
                                flip=true,guid=tacticFound[1]})
                            villaindeckcount = villaindeckcount + 1
                        elseif tacticFound[1] then
                            local moveToVilDeck = function(obj)
                                obj.flip()
                                obj.setPosition(getObjectFromGUID(villainDeckZoneGUID).getPosition())
                            end
                            offerCards(i,vpilecontent[1],tacticFound,moveToVilDeck,"Shuffle this tactic back into the Villain deck.","Shuffle")
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
                        printToAll(playerBoards[i] .. " player's tactic was shuffled back in the Villain deck and so they drew two cards.")
                    end
                end
            end
        end
        local tacticsAdded = function()
            local villain_deck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
            if villain_deck[1] and math.abs(villain_deck[1].getQuantity()) == villaindeckcount then
                return true
            else
                return false
            end
        end
        local tacticsFollowup = function()
            local villain_deck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
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
            getObjectFromGUID(setupGUID).Call('playHorror')
            broadcastToAll("Scheme Twist: Random Horror was played!")
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
                local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
                if scheme[1] then
                    scheme[1].flip()
                    noMoreMutants = true
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
            broadcastToAll("Scheme Twist: Choose " .. twistsresolved .. " different Hero Classes and each hero in the HQ that is any of them will be KO'd.",{1,1,1})
            local mmpromptzone = getObjectFromGUID(city_zones_guids[4])
            local zshift = 0
            local colorspicked = {}
            local buttonindices = {}
            local colors = {"Green","Yellow","Red","Silver","Blue"}
            local colorlabs = {"Green","Yellow","Red","White","Blue"}
            for i,o in ipairs(colors) do
                buttonindices[i] = i-1
                _G["helicarrierColor" .. i] = function()
                    mmpromptzone.removeButton(buttonindices[i])
                    for i2,o2 in pairs(buttonindices) do
                        if i2 > i then
                            buttonindices[i2] = o2-1
                        end
                    end
                    table.insert(colorspicked,o)
                    if #colorspicked > twistsresolved - 1 then
                        mmpromptzone.clearButtons()
                        for _,o3 in pairs(hqguids) do
                            local hero = getObjectFromGUID(o3).Call('getHeroUp')
                            if hero then 
                                for _,color in pairs(colorspicked) do
                                    if hero.hasTag("HC:" .. color) then
                                        koCard(hero)
                                        getObjectFromGUID(o3).Call('click_draw_hero')
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                mmpromptzone.createButton({click_function="helicarrierColor" .. i,
                    function_owner=self,
                    position={0,0,zshift},
                    rotation={0,180,0},
                    label=o,
                    tooltip="Heroes with this hero color will be KO'd: " .. o,
                    font_size=100,
                    font_color="Black",
                    color=colorlabs[i],
                    width=1500,height=50})
                zshift = zshift + 0.5
            end
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
            for i,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
                local topzone = getObjectFromGUID(o)
                bspile.takeObject({position = topzone.getPosition(),
                    flip=false})
            end
        elseif twistsresolved < 9 then
            for _,o in pairs(Player.getPlayers()) do
                local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
                local vpilevillains = {}
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,obj in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(obj.tags) do
                            if k == "Villain" then
                                table.insert(vpilevillains,obj.guid)
                                break
                            end
                        end
                    end
                    if vpilevillains[1] and vpilevillains[2] then
                        local moveToEscape = function(obj)
                            obj.setPosition(getObjectFromGUID(escape_zone_guid).getPosition())
                        end
                        log(o.color)
                        log(vpilevillains)
                        offerCards(o.color,vpilecontent[1],vpilevillains,moveToEscape,"Put this villain in the escape pile.","Escape")
                    elseif vpilevillains[1] then
                        vpilecontent[1].takeObject({position = getObjectFromGUID(escape_zone_guid).getPosition(),
                            guid = vpilevillains[1]})
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Villain") then
                    vpilecontent[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                end
            end
            broadcastToAll("Scheme Twist: Each player puts a villain from their victory pile into the escape pile.",{1,0,0})
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
            fortifiedCityZone.createButton({click_function="updatePower",
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
        stackTwist(cards[1])
        if twistsresolved == 1 then
            local mmzone = getObjectFromGUID(mmZoneGUID)
            mmzone.createButton({click_function="updatePower",
                function_owner=self,
                position={0.5,0,0},
                rotation={0,180,0},
                label="+1",
                tooltip="Spend this much Recruit (or Attack) to fight the Mastermind.",
                font_size=350,
                font_color="Yellow",
                color={0,0,0,0.75},
                width=250,height=250})
            mmzone.createButton({click_function="updatePower",
                function_owner=self,
                position={-0.5,0,0},
                rotation={0,180,0},
                label="+1",
                tooltip="Spend this much Attack (or Recruit) to fight the Mastermind.",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        elseif twistsresolved < 7 then
            local mmzone = getObjectFromGUID(mmZoneGUID)
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
            getObjectFromGUID(city_zones_guids[4]).createButton({click_function="updatePower",
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
        Wait.condition(updatePower,twistMoved)
        local vpile = get_decks_and_cards_from_zone(vpileguids[Turns.turn_color])
        if vpile[1] then
            local updateAndPush = function()
                updatePower()
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
            powerButton(cards[1],"+2","This tyrant gets +2 because of a Dark Power.","darkpower" .. twistsresolved)
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
        local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)[1]
        if twistsresolved == 1 then
            powerButton(scheme,"Kung Fu: " .. twistsstacked)
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
                    Wait.time(updatePower,2)
                    return nil
                end
            end
        end
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        local possessedPsychotic = function(obj)
            obj.addTag("Possessed")
            obj.addTag("Villain")
            obj.removeTag("Bystander") -- complicates vp count!!
            local twistsstack = get_decks_and_cards_from_zone(twistZoneGUID)
            if twistsstack[1] then
                twistsstacked = math.abs(twistsstack[1].getQuantity())
            else
                twistsstacked = 0
            end
            powerButton(obj,twistsstacked)
            updatePower()
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
        local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
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
        local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
        local vildeckcurrentcount = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].getQuantity()
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
            local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
            if vildeck[1] and vildeck[1].getQuantity() == test then
                return true
            else
                return false
            end
        end
        local goonsShuffle = function()
            if goonsfound > 0 then
                local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
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
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            if #hand > 4 then
                local bsguids = {}
                local killBSButton = function(obj)
                    for _,b in pairs(bsguids) do
                        local obj = getObjectFromGUID(b)
                        if obj then
                            obj.clearButtons()
                            obj.locked = false
                            obj.setPosition(getObjectFromGUID(vpileguids[o.color]).getPosition())
                        end
                    end
                end
                promptDiscard(o.color,hand,#hand-4,nil,nil,nil,nil,killBSButton)
                local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
                local killHandButtons = function(obj)
                    obj.clearButtons()
                    koCard(obj)
                    local hand = Player[o.color].getHandObjects()
                    for _,h in pairs(hand) do
                        h.clearButtons()
                    end
                end
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,p in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(p.tags) do
                            if k == "Bystander" then
                                table.insert(bsguids,p.guid)
                                break
                            end
                        end
                    end
                    offerCards(o.color,vpilecontent[1],bsguids,killHandButtons,"KO this bystander.","KO")
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                    _G['killHandButtons' .. o.color] = function(obj)
                        local color = nil
                        for _,b in pairs(obj.getButtons()) do
                            if b.click_function:find("killHandButtons") then
                                color = b.click_function:gsub("killHandButtons","")
                            end
                        end
                        obj.clearButtons()
                        koCard(obj)
                        local hand = Player[color].getHandObjects()
                        for _,h in pairs(hand) do
                            h.clearButtons()
                        end
                    end
                    vpilecontent[1].createButton({click_function = 'killHandButtons' .. o.color,
                        function_owner=self,
                        position={0,22,0},
                        label="KO",
                        tooltip="KO this bystander.",
                        font_size=250,
                        font_color="Black",
                        color={1,1,1},
                        width=750,height=450})
                    table.insert(bsguids,vpilecontent[1].guid)
                end
            else
                broadcastToColor("Scheme Twist: Your hand has less than 5 cards, but you may still KO a bystander from your victory pile if you really hate it.",o.color,o.color)
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Portals to the Dark Dimension" then
        if twistsresolved == 1 then
            local mmZone = getObjectFromGUID(mmZoneGUID)
            local mmpos = mmZone.getPosition()
            mmpos.z = mmpos.z + 2
            mmpos.y = mmpos.y + 2
            cards[1].setPositionSmooth(mmpos)
            cards[1].setName("Dark Portal")
            local mmname = nil
            for i,o in pairs(table.clone(mmZone.Call('returnVar',"mmLocations"),true)) do
                if o == mmZoneGUID then
                    mmname = i
                    break
                end
            end
            getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname,1,"+1","A dark portal gives the mastermind + 1.","mm","darkportal" .. twistsresolved})
            broadcastToAll("Scheme Twist: A dark portal reinforces the mastermind!")
        elseif twistsresolved < 7 then
            if city[7-twistsresolved] then
                cards[1].setName("Dark Portal")
                powerButton(cards[1],"+1")
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
            vildeckzone.createButton({click_function='updatePower',
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
            herodeckzone.createButton({click_function='updatePower',
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
            vildeckzone.createButton({click_function='updatePower',
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
    if schemeParts[1] == "Pulse Waves from the Negative Zone" then
        if twistsresolved < 9 and twistsresolved % 2 == 1 then
            broadcastToColor("Scheme Twist: NEGATIVE PULSE This turn heroes in the HQ cost 1 less and villains/masterminds get -1!",Turns.turn_color,Turns.turn_color)
        elseif twistsresolved < 9 and twistsresolved % 2 == 0 then
            broadcastToColor("Scheme Twist: POSITIVE PULSE This turn heroes in the HQ cost 1 more and villains/masterminds get +1!",Turns.turn_color,Turns.turn_color) 
        elseif twistsresolved == 9 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Put Humanity on Trial" then
        broadcastToColor("Scheme Twist: Fulfill this challenge or a juror condemns humanity!",Turns.turn_color,Turns.turn_color)
        if twistsresolved < 3 then
            broadcastToColor("Challenge: Discard three cards with different names!",Turns.turn_color,Turns.turn_color)
        elseif twistsresolved < 9 and twistsresolved % 2 == 1 then
            broadcastToColor("Challenge: Recruit a hero that costs 5 or more!",Turns.turn_color,Turns.turn_color)
        elseif twistsresolved < 9 and twistsresolved % 2 == 0 then
            broadcastToColor("Challenge: Defeat villains worth a total of 3VP or more!",Turns.turn_color,Turns.turn_color)  
        elseif twistsresolved < 12 then
            broadcastToColor("Challenge: Defeat (not just fight) the mastermind!",Turns.turn_color,Turns.turn_color)
        else
            broadcastToColor("No more challenges!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "Ragnarok, Twilight of the Gods" then
        broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Replace Earth's Leaders with Killbots" then
        stackTwist(cards[1])
        updatePower()
        return nil
    end
    if schemeParts[1] == "Reveal Heroes' Secret Identities" then
        if twistsresolved == 1 then
            unmasked = {}
        end
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            local isUnmasked = false
            if hero then
                for _,p in pairs(unmasked) do
                    if hero.getName() == p then
                        isUnmasked = true
                        break
                    end
                end
                if not isUnmasked then
                    _G["unmaskHero" .. hero.guid] = function(obj)
                        local hero = obj.Call('getHeroUp')
                        if not hero then
                            return nil
                        else
                            for _,k in pairs(hqguids) do
                                local butt = getObjectFromGUID(k).getButtons()
                                for i,b in pairs(butt) do
                                    if b.click_function:find("unmaskHero") then
                                        getObjectFromGUID(k).removeButton(i-1)
                                    end
                                end
                            end
                            table.insert(unmasked,hero.getName())
                            hero.setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
                            obj.Call('click_draw_hero')
                        end
                    end
                    getObjectFromGUID(o).createButton({click_function="unmaskHero" .. hero.guid,
                        function_owner=self,
                        position={0,2,0},
                        label="Unmask",
                        tooltip="Unmask this hero",
                        font_size=250,
                        font_color="Black",
                        color={1,1,1},
                        width=750,height=450})
                end
            end
        end
        function checkUnmasked()
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    local isUnmasked = false
                    for _,k in pairs(unmasked) do
                        if hero.getName() == k then
                            updateUnmasked(o,true)
                            isUnmasked = true
                            break
                        end
                    end
                    if isUnmasked == false then
                        updateUnmasked(o,false)
                    end
                end
            end
        end
        function updateUnmasked(guid,isUnmasked)
            local butt = getObjectFromGUID(guid).getButtons()
            for i,o in pairs(butt) do
                if o.label == "+1*" then
                    if isUnmasked == false then
                        getObjectFromGUID(guid).removeButton(i-1)
                    end
                    return nil
                end
            end
            if isUnmasked == true then
                getObjectFromGUID(guid).createButton({click_function='updatePower',
                    function_owner=self,
                    position={0,2,-2},
                    label="+1*",
                    tooltip="All cards with Unmasked Hero Names cost +1 to recruit.",
                    font_size=500,
                    font_color="Yellow",
                    color={1,1,1,0.85},
                    width=0})
            end
        end
        function onObjectEnterZone(zone,object)
            Wait.time(checkUnmasked,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(checkUnmasked,1)
        end
        return twistsresolved
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
            twistpile.createButton({click_function="updatePower",
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
                local mmZone = getObjectFromGUID(mmZoneGUID)
                mmZone.Call('updateMasterminds',obj.getName())
                mmZone.Call('updateMastermindsLocation',{obj.getName(),topBoardGUIDs[4+2*(twistsresolved-1)]})
                mmZone.Call('setupMasterminds',obj.getName())
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
            getObjectFromGUID(twistZoneGUID).createButton({click_function="updatePower",
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
    if schemeParts[1] == "Shoot Hulk into Space" then
        if twistsresolved == 1 then
            function click_buy_hulk(obj,player_clicker_color)
                local hulkdeck = get_decks_and_cards_from_zone(obj.guid)[1]
                if not hulkdeck then
                    return nil
                end
                local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
                local dest = playerBoard.positionToWorld(pos_discard)
                dest.y = dest.y + 3
                if player_clicker_color == "White" then
                    angle = 90
                elseif player_clicker_color == "Blue" then
                    angle = -90
                else
                    angle = 180
                end
                local brot = {x=0, y=angle, z=0}
                if hulkdeck.tag == "Card" then
                    hulkdeck.setRotationSmooth(brot)
                    hulkdeck.setPositionSmooth(dest)
                else
                    hulkdeck.takeObject({position=dest,rotation=brot,flip=false,smooth=true})
                end
            end
            getObjectFromGUID("bd3ef1").createButton({
                 click_function="click_buy_hulk", 
                 function_owner=self,
                 position={0,0,-0.5},
                 rotation={0,180,0},
                 label="Buy hero",
                 tooltip="Buy the top card of the Prison Ship.",
                 color={1,1,1,1},
                 width=800,
                 height=200,
                 font_size = 100
            })
        end
        local hulkdeck = get_decks_and_cards_from_zone(twistZoneGUID)
        if hulkdeck[1] and hulkdeck[1].getQuantity() > 2 then
            hulkdeck[1].takeObject({position = getObjectFromGUID("bd3ef1").getPosition(),
                flip = true,
                smooth = true})
            hulkdeck[1].takeObject({position = getObjectFromGUID("bd3ef1").getPosition(),
                flip = true,
                smooth = true})
        elseif hulkdeck[1] then
            hulkdeck[1].flip()
            hulkdeck[1].setPositionSmooth(getObjectFromGUID("bd3ef1").getPosition())
        else
            broadcastToAll("Scheme Twist: No Hulk deck found, so Evil Wins!")
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
            updatePower()
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
        powerButton(cards[1],"+1")
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
            powerButton(scheme[1],twistsstacked,"Resolve the deathtraps by spending this much Attack.",nil,"resolveDeathtraps")
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
    if schemeParts[1] == "The Clone Saga" then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local cardids = {}
            local clonecheck = false
            for _,k in pairs(hand) do
                if hasTag2(k,"HC:",4) then
                    local json = k.getJSON()
                    local id = json:match("\"CardID\": %d+"):gsub("\"CardID\": ","")
                    --log(id)
                    for _,l in pairs(cardids) do
                        if id == l then
                            clonecheck = true
                            break
                        end
                    end
                    if clonecheck == true then
                        break
                    else
                        table.insert(cardids,id)
                    end
                end
            end
            if clonecheck == false and #hand > 3 then
                promptDiscard(o.color,nil,#hand-3)
                broadcastToColor("Scheme Twist: Discard down to 3 cards!",o.color,o.color)
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "The Contest of Champions" then
        if twistsresolved == 1 then
            contestantsPV = table.clone(getObjectFromGUID("912967").Call('returnContestants'))
        end
        local contestant = getObjectFromGUID(table.remove(contestantsPV,1))
        local color = hasTag2(contestant,"HC:",4)
        koCard(contestant)
        local championContest = function(obj)
            for i,o in pairs(obj) do
                if i == "Evil" and o == true then
                    local woundsdeck = getObjectFromGUID(woundsDeckGUID)
                    if woundsdeck.tag == "Deck" then
                        woundsdeck.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                            flip=true,
                            smooth=true})
                    else
                        woundsdeck.flip()
                        woundsdeck.setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
                    end
                    broadcastToAll("Scheme Twist: Evil won the contest, so a wound was stacked next to the scheme as an Evil Triumph!")
                elseif o == false and i ~= "Evil" then
                    promptDiscard(i)
                    broadcastToColor("You lost the contest, so discard a card",i,i)
                end
            end
        end
        local contestn = 0
        local epicgrandmaster = false
        if schemeParts[4] == "The Grandmaster - epic" then
            epicgrandmaster = true
        end
        if twistsresolved < 5 then
            contestn = 2
        elseif twistsresolved < 9 then
            contestn = 4
        elseif twistsresolved < 12 then 
            contestn = 6
        end
        contestOfChampions(color,contestn,championContest,epicgrandmaster)
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
                powerButton(scheme[1],9)
                scheme[1].addTag("Mastermind")
                scheme[1].addTag("VP9")
                scheme[1].setName("God-Emperor")
                local mmZone = getObjectFromGUID(mmZoneGUID)
                mmZone.Call('updateMasterminds',"God-Emperor")
                mmZone.Call('updateMastermindsLocation',{"God-Emperor",schemeZoneGUID})
                mmZone.Call('setupMasterminds',"God-Emperor")
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
            broadcastToAll("Scheme Twist: The God-Emperor gets +2")
            return nil
        elseif twistsresolved == 7 then
            broadcastToAll("Scheme Twist: The God-Emperor KO's all other masterminds!")
            local iter = 0
            local mmZone = getObjectFromGUID(mmZoneGUID)
            local masterminds = table.clone(mmZone.Call('returnVar',"masterminds"))
            local mmLocations = table.clone(mmZone.Call('returnVar',"mmLocations"),true)
            for i,o in ipairs(masterminds) do
                if o ~= "God-Emperor" then
                    local mm = get_decks_and_cards_from_zone(mmLocations[o])
                    if mm[1] then
                        for _,o in pairs(mm) do
                            if o.is_face_down then
                                o.flip()
                            end
                            koCard(o)
                        end
                    end
                    getObjectFromGUID(mmLocations[o]).clearButtons()
                    mmZone.Call('removeMasterminds',i-iter)
                    iter = iter + 1
                end
            end
        elseif twistsresolved == 8 then
            broadcastToAll("Scheme Twist: Evil Wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "The Korvac Saga" then
        if twistsresolved % 2 == 1 and twistsresolved < 9 then
            local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
            scheme[1].flip()
            scheme[1].addTag("VP9")
            scheme[1].addTag("Villain")
            getObjectFromGUID(schemeZoneGUID).createButton({click_function='updatePower',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="19",
                tooltip="The Korvac entity",
                font_size=350,
                font_color={1,0,0},
                color={0,0,0,0.75},
                width=250,height=250})
            killKoBystanderButton = function(color)
                local vpile= getObjectFromGUID(vpileguids[color])
                local vpbuttons = vpile.getButtons()
                if vpbuttons then
                    for i,b in pairs(vpbuttons) do
                        if b.click_function:find("koBystander") then
                            vpile.removeButton(i-1)
                            break
                        end
                    end
                end
            end
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                if # hand > 4 then
                    promptDiscard(o.color,hand,#hand-4,nil,nil,nil,nil,killKoBystanderButton,o.color)
                    local vpile = getObjectFromGUID(vpileguids[o.color])
                    _G["koBystander" .. o.color] = function(obj)
                        local vpilecontent = get_decks_and_cards_from_zone(obj.guid)
                        if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                            for _,c in pairs(vpilecontent[1].getObjects()) do
                                for _,t in pairs(c.tags) do
                                    if t == "Bystander" then
                                        bsfound = true
                                        vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                            guid = c.guid})
                                        break
                                    end
                                end
                                if bsfound == true then
                                    break
                                end
                            end
                        elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                            vpilecontent[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                            bsfound = true
                        end
                        if bsfound then
                            local color = nil
                            for c,g in pairs(vpileguids) do
                                if g == obj.guid then
                                    color = c
                                    break
                                end
                            end
                            killKoBystanderButton(color)
                            local hand = Player[color].getHandObjects()
                            for _,h in pairs(hand) do
                                h.clearButtons()
                            end
                        else
                            broadcastToAll("Can't KO a bystander, none found!")
                        end
                    end
                    vpile.createButton({click_function="koBystander" .. o.color,
                        function_owner=self,
                        position={0,0,0},
                        rotation={0,180,0},
                        label="KO",
                        tooltip="KO a bystander.",
                        font_size=200,
                        font_color="Black",
                        color={1,1,1},
                        width=650,height=400})
                else
                    broadcastToColor("Scheme Twist: But you have 4 or less cards in hand, so you don't need to discard. You may KO a bystander if you really hate it.",o.color,o.color)
                end
            end
        elseif twistsresolved < 8 then
            local players = revealCardTrait("Avengers","Team:")
            for _,o in pairs(players) do
                click_get_wound(nil,o.color)
            end
            local scheme = get_decks_and_cards_from_zone(schemeZoneGUID)
            scheme[1].flip()
            scheme[1].removeTag("VP9")
            scheme[1].removeTag("Villain")
            getObjectFromGUID(schemeZoneGUID).clearButtons()
        elseif twistsresolved == 8 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "The Kree-Skrull War" then
        if twistsresolved < 8 then
            for _,o in pairs(city) do
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if hasTag2(obj,"Group:",7) and (hasTag2(obj,"Group:",7) == "Kree Starforce" or hasTag2(obj,"Group:",7) == "Skrulls") then
                            shift_to_next(citycontent,getObjectFromGUID(escape_zone_guid),0)
                            break
                        end
                    end
                end
            end
            local kreeskrull = function()
                local escaped = get_decks_and_cards_from_zone(escape_zone_guid)
                local skree = 0
                if escaped[1] and escaped[1].tag == "Deck" then
                    for _,o in pairs(escaped[1].getObjects()) do
                        for _,tag in pairs(o.tags) do
                            if tag == "Group:Kree Starforce" then
                                skree = skree - 1
                                break
                            elseif tag == "Group:Skrulls" then
                                skree = skree + 1
                                break
                            end
                        end
                    end
                elseif escaped[1] and hasTag2(escaped[1],"Group:",7) then
                    if hasTag2(escaped[1],"Group:",7) == "Kree Starforce" then
                        skree = -1
                    elseif hasTag2(escaped[1],"Group:",7) == "Skrulls" then
                        skree = 1
                    end
                end
                if skree < 0 then
                    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
                    broadcastToAll("Scheme Twist: All Kree and Skrull villains escape! Kree Conquest!")
                elseif skree > 0 then
                    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[4]).getPosition())
                    broadcastToAll("Scheme Twist: All Kree and Skrull villains escape! Skrull Conquest!")
                else
                    broadcastToAll("Scheme Twist: All Kree and Skrull villains escape! Stalemate, no conquest!")
                    koCard(cards[1])
                end
            end
            Wait.time(kreeskrull,2)
        elseif twistsresolved == 8 then
            local skree = get_decks_and_cards_from_zone(topBoardGUIDs[2])
            local skrull = get_decks_and_cards_from_zone(topBoardGUIDs[4])
            local score = math.abs(skrull[1].getQuantity()) - math.abs(skree[1].getQuantity())
            if score < 0 then
                cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
                broadcastToAll("Scheme Twist: Kree Conquest!")
            elseif score > 0 then
                cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[4]).getPosition())
                broadcastToAll("Scheme Twist: Skrull Conquest!")
            else
                broadcastToAll("Scheme Twist: Stalemate, no conquest!")
                koCard(cards[1])
            end
        end
        return nil
    end
    if schemeParts[1] == "The Legacy Virus" then
        local players =revealCardTrait("Silver")
        for _,o in pairs(players) do
            click_get_wound(nil,o.color)
            broadcastToAll("Scheme Twist. Player " .. o.color .. " got a wound!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "The Mark of Khonshu" then
        playVillains(2)
        return twistsresolved
    end
    if schemeParts[1] == "The Unbreakable Enigma Code" then
        if twistsresolved < 6 then
            local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
            if herodeck[1] and herodeck[1].tag == "Deck" then
                herodeck[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                    smooth = true})
            elseif herodeck[1] then
                herodeck[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
            else
                broadcastToAll("Hero deck ran out!")
                return twistsresolved
            end
            local shufflethecode = function()
                local code = get_decks_and_cards_from_zone(twistZoneGUID)
                code[1].randomize()
                broadcastToAll("Scheme Twist: Card from the hero deck added to the Enigma Code!")
            end
            Wait.time(shufflethecode,2)
        elseif twistsresolved == 6 then
            broadcastToAll("Scheme Twist: Evil Wins!")
        end
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
                scheme[1].setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[11]).getPosition())
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
            local scheme = get_decks_and_cards_from_zone(allTopBoardGUIDS[13-twistsresolved])[1]
            scheme.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[12-twistsresolved]).getPosition())
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
            local scheme = get_decks_and_cards_from_zone(allTopBoardGUIDS[twistsresolved+1])[1]
            scheme.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[twistsresolved+2]).getPosition())
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
        elseif twistsresolved == 10 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return nil
    end
    if schemeParts[1] == "Transform Citizens Into Demons" then
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        if twistsresolved == 1 then
            getObjectFromGUID(twistZoneGUID).createButton({click_function="updatePower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="2",
                tooltip="Fight for 2 to rescue one of these bystanders.",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
            getObjectFromGUID(twistZoneGUID).createButton({click_function="updatePower",
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
                updatePower()
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
                updatePower()
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Transform Commuters into Giant Ants" then
        stackTwist(cards[1])
        if twistsresolved == 1 then
            getObjectFromGUID(topBoardGUIDs[1]).createButton({click_function="updatePower",
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="2",
                tooltip="Fight for 2 to rescue one of these Giant Ant bystanders.",
                font_size=350,
                font_color="Red",
                color={0,0,0,0.75},
                width=250,height=250})
        end
        for i=1,twistsstacked do
            addBystanders(topBoardGUIDs[1],false,true)
        end
        return nil
    end
    if schemeParts[1] == "Trap Heroes in the Microverse" then
        playVillains(2)
        return twistsresolved
    end
    if schemeParts[1] == "Trapped in the Insane Asylum" then
        cards[1].setName("Psychotic Break")
        cards[1].setDescription("ARTIFACT: Not really, but this ensures it sticks during cleanup.")
        cards[1].setPositionSmooth(getObjectFromGUID(playerBoards[Turns.turn_color]).positionToWorld({-1.5,4,4}))
        currentPsychoticBreak = cards[1]
        broadcastToAll("Scheme Twist: Discard a card and pass the break to the next player, or keep it!")
        promptPsychoticBreakChoice = function(color)
            promptDiscard(color,nil,nil,nil,nil,nil,nil,shiftPsychoticBreak,color)
            keepPsychoticBreak = function(obj)
                obj.clearButtons()
                local color = nil
                for _,o in pairs(Player.getPlayers()) do
                    local playcontent = get_decks_and_cards_from_zone(playguids[o.color])
                    if playcontent[1] then
                        for _,k in pairs(playcontent) do
                            if k.guid == obj.guid then
                                color = o.color
                                break
                            end
                        end
                        if color then
                            break
                        end
                    end
                end
                local pos = obj.getPosition()
                if color == "White" then
                    pos.z = pos.z + 14
                elseif color == "Blue" then
                    pos.z = pos.z - 14
                else
                    pos.x = pos.x + 14
                end
                obj.setPositionSmooth(pos)
                obj.locked = true
                local hand = Player[color].getHandObjects()
                for _,h in pairs(hand) do
                    h.clearButtons()
                end
            end
            currentPsychoticBreak.createButton({click_function="keepPsychoticBreak",
                function_owner=self,
                position={0,22,0},
                label="Keep",
                tooltip="Keep this psychotic break.",
                font_size=250,
                font_color="Black",
                color={1,1,1},
                width=750,height=450})
        end
        shiftPsychoticBreak = function(color)
            local nextcolor = getNextColor(color)
            currentPsychoticBreak.setPositionSmooth(getObjectFromGUID(playerBoards[nextcolor]).positionToWorld({-1.5,4,4}))
            promptPsychoticBreakChoice(nextcolor)
        end
        promptPsychoticBreakChoice(Turns.turn_color)
        function onPlayerTurn(player)
            local playcontent = get_decks_and_cards_from_zone(playguids[player.color])
            if playcontent[1] then
                local breakcount = 0
                for _,o in pairs(playcontent) do
                    if o.tag == "Deck" then
                        for _,k in pairs(o.getObjects()) do
                            if k.name == "Psychotic Break" then
                                breakcount = breakcount + 1
                            end
                        end
                    elseif o.tag == "Card" then
                        if o.getName() == "Psychotic Break" then
                            breakcount = breakcount + 1
                        end
                    end
                end
                if breakcount > 0 then
                    local hand = player.getHandObjects()
                    local pos = getObjectFromGUID(playerBoards[player.color]).positionToWorld({-3.5,4,4})
                    if #hand >= breakcount*2 then
                        for i=1,breakcount*2 do
                            local card = table.remove(hand,math.random(#hand))
                            card.setPosition(pos)
                            pos.x = pos.x + 1
                            pos.y = pos.y + 1
                        end
                    else
                        for i=1,#hand do
                            local card = table.remove(hand,math.random(#hand))
                            card.setPosition(pos)
                            pos.x = pos.x + 1
                            pos.y = pos.y + 1
                        end
                    end
                    broadcastToColor("Psychotic Break! Play and activate cards from hand in random order, from left to right!",player.color,player.color)
                end
            end
        end
        return nil
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
    if schemeParts[1] == "Unite the Shards" then
        stackTwist(cards[1])
        gainShard(nil,mmZoneGUID,twistsstacked)
        broadcastToAll("Scheme Twist: The Mastermind gains " .. twistsstacked .. " shards.")
        return nil
    end
    if schemeParts[1] == "United States Split by Civil War" then
        for i=4,5 do
            local cardz = get_decks_and_cards_from_zone(city[i])
            if cardz[1] then
                for _,o in pairs(cardz) do
                    if o.hasTag("Villain") then
                        cards[1].setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[10]).getPosition())
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
                    cards[1].setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[11]).getPosition())
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
    if schemeParts[1] == "War of the Frost Giants" then
        cards[1].setName("Frost Giant Invader")
        cards[1].addTag("VP6")
        cards[1].addTag("Villain")
        cards[1].setDescription("If you are not Worthy (reveal a Hero that costs 5 or more), Frost Giant Invader gets +4.")
        powerButton(cards[1],"6+")
        broadcastToAll("Scheme Twist: The twist cards enters the city as a Frost Giant Invader!")
        if twistsresolved == 8 or twistsresolved == 9 then
            local pos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
            pos.y = pos.y + 2
            local giantsfound = 0
            for _,o in pairs(Player.getPlayers()) do
                local vpile = get_decks_and_cards_from_zone(vpileguids[o.color])
                if vpile[1] and vpile[1].tag == "Deck" then
                    for _,obj in pairs(vpile[1].getObjects()) do
                        if obj.name == "Frost Giant Invader" then
                            vpile[1].takeObject({position = pos,
                                guid = obj.guid,
                                flip = true})
                            giantsfound = giantsfound + 1
                            break
                        end
                    end
                elseif vpile[1] and vpile[1].getName() == "Frost Giant Invader" then
                    vpile[1].flip()
                    vpile[1].setPositionSmooth(pos)
                    giantsfound = giantsfound + 1
                end
            end
            if giantsfound > 0 then
                Wait.time(function() playVillains(giantsfound) end,2.5)
                broadcastToAll("Scheme Twist: " .. giantsfound .. " Frost Giant Invaders put on top of villain deck from player's victory piles. Please play them all!")
            end
        end
        return twistsresolved
    end
    if schemeParts[1] == "Weave a Web of Lies" then
        stackTwist(cards[1])
        return nil
    end
    if schemeParts[1] == "World War Hulk" then
        if twistsresolved < 9 then
            local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
            for i,o in pairs(mmLocations) do
                if o == mmZoneGUID and getObjectFromGUID(mmZoneGUID).Call('mmActive',i) then
                    addNewLurkingMM(i)
                    break
                end
            end
        elseif twistsresolved == 9 then
            broadcastToAll("Scheme Twist: Evil wins!")
        end
        return twistsresolved
    end
    if schemeParts[1] == "X-Cutioner's Song" then
        koCard(cards[1])
        for _,o in pairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if hasTag2(obj,"Cost:") then
                        koCard(obj)
                    end
                end
            end
        end
        broadcastToAll("Scheme Twist: all Heroes captured by enemies KO'd. Play another card from the Villain Deck.") 
        playVillains()
        return nil
    end
    if schemeParts[1] == "X-Men Danger Room Goes Berserk" then
        broadcastToAll("Scheme Twist: Trap! By End of Turn: You may pay 2*. If you do, shuffle this Twist back into the Villain Deck, then play a card from the Villain Deck.") 
        moveToxin = function(obj)
            obj.flip()
            obj.setPositionSmooth(getObjectFromGUID(villainDeckZoneGUID).getPosition())
            local shuffleToxin = function()
                get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].randomize()
                playVillains()
            end
            Wait.time(shuffleToxin,1.5)
        end
        powerButton(cards[1],"2*","Pay two Recruit by end of turn to shuffle this toxin back.",nil,"moveToxin")
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
                cards[1].clearButtons()
                stackTwist(card[1])
                broadcastToAll("Last turn's twist stacked next to the Scheme as an Airborne Neurotoxin.")
            end
        end
        Wait.condition(villainousInterruption,turnChanged)
        return nil
    end
    return twistsresolved
end

function addNewLurkingMM(currentmm)
    if not lurking then
        lurking = table.clone(getObjectFromGUID(setupGUID).Call('returnLurking'))
        lurkingLocations = {}
        for i = 1,3 do
            lurkingLocations[lurking[i]] = topBoardGUIDs[2*i]
        end
    end
    if lurking[1] then
        local newmm = table.remove(lurking,math.random(#lurking))
        local mmZone = getObjectFromGUID(mmZoneGUID)
        mmZone.Call('updateMasterminds',newmm)
        mmZone.Call('updateMastermindsLocation',{newmm,mmZoneGUID})
        if currentmm then
            table.insert(lurking,currentmm)
            lurkingLocations[currentmm] = lurkingLocations[newmm]
            mmZone.Call('removeMastermindsLocation',currentmm)
            local lurkingpos = getObjectFromGUID(lurkingLocations[currentmm]).getPosition()
            local strikelurkingpos = getObjectFromGUID(getStrikeloc(currentmm,lurkingLocations)).getPosition()
            for i,o in pairs(table.clone(mmZone.Call('returnVar',"masterminds"))) do
                if o == currentmm then
                    mmZone.Call('removeMasterminds',i)
                    break
                end
            end
            local mmcontent = get_decks_and_cards_from_zone(mmZoneGUID)
            for _,o in pairs(mmcontent) do
                if o.is_face_down == false then
                    lurkingpos.y = lurkingpos.y + 4
                else
                    lurkingpos.y = getObjectFromGUID(lurkingLocations[currentmm]).getPosition().y
                end
                o.setPositionSmooth(lurkingpos)
            end
            local strikecontent = get_decks_and_cards_from_zone(strikeZoneGUID)
            if strikecontent[1] then
                for _,o in pairs(strikecontent) do
                    o.setPositionSmooth(strikelurkingpos)
                    strikelurkingpos.y = strikelurkingpos.y + 4
                end
            end
            local strikeZone = getObjectFromGUID(strikeZoneGUID)
            local strikebutt = strikeZone.getButtons()
            local iter2 = 0
            if strikebutt then
                for i,o in ipairs(strikebutt) do
                    if o.click_function:find("update") and not o.click_function:find("Power") then
                        strikeZone.removeButton(i-1-iter2)
                        iter2 = iter2 + 1
                    end
                end
            end
        end
        local newmmposition = getObjectFromGUID(mmZoneGUID).getPosition()
        local newmmcontent = get_decks_and_cards_from_zone(lurkingLocations[newmm])
        for _,o in pairs(newmmcontent) do
            if o.is_face_down == false then
                newmmposition.y = newmmposition.y + 4
            else
                newmmposition.y = getObjectFromGUID(mmZoneGUID).getPosition().y
            end
            o.setPositionSmooth(newmmposition)
        end
        local newstrikeposition = getObjectFromGUID(strikeZoneGUID).getPosition()
        local newstrikecontent = get_decks_and_cards_from_zone(getStrikeloc(newmm,lurkingLocations))
        if newstrikecontent[1] then
            for _,o in pairs(newstrikecontent) do
                o.setPositionSmooth(newstrikeposition)
                newstrikeposition.y = newstrikeposition.y + 4
            end
        end
        getObjectFromGUID(mmZoneGUID).Call('fightButton',mmZoneGUID)
        if getObjectFromGUID(mmZoneGUID).Call('isTransformed',newmm) == true then
            getObjectFromGUID(mmZoneGUID).Call('addTransformButton',getObjectFromGUID(mmZoneGUID))
        else
            local butt = getObjectFromGUID(mmZoneGUID).getButtons()
            for _,o in pairs(butt) do
                if o.click_function == "transformMM" then
                    getObjectFromGUID(mmZoneGUID).removeButton(o.index)
                    break
                end
            end
        end
        broadcastToAll("Scheme Twist: Mastermind was switched with a random lurking mastermind!")
    elseif not table.clone(mmZone.Call('returnVar',"masterminds"))[1] then
        broadcastToAll("No More masterminds found, so you WIN!")
    else
        broadcastToAll("No More lurking masterminds found.")
    end
end

function strikeSpecials(cards,city)
    local masterminds = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))
    if not masterminds[1] then
        broadcastToAll("No mastermind specified!")
        return nil
    elseif masterminds[2] then
        broadcastToAll("Multiple masterminds. Resolve effects manually in the order of your choice.")
        local mmpromptzone = getObjectFromGUID(city_zones_guids[4])
        local zshift = 0
        local resolvingStrikes = {}
        for i,o in ipairs(masterminds) do
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
        mmname = masterminds[1]
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
    local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
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
    if mmname == "Angela" then
        msno(mmname)
        return nil
    end
    if mmname == "Annihilus" then
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        local tags = nil
        local cardtype = nil
        if vildeck.tag == "Deck" then
            tags = vildeck.getObjects()[1].tags
            cardtype = vildeck.getObjects()[1].name
        else
            tags = vildeck.getTags()
            cardtype = vildeck.getName()
        end
        for _,o in pairs(tags) do
            if o == "Villain" then
                cardtype = "Villain"
                break
            elseif o == "Bystander" then
                cardtype = "Bystander"
                break
            end
        end
        if epicness == true then
            if cardtype == "Villain" then
                playVillains(2)
                broadcastToAll("Master Strike: Epic Annihilus plays a villain and therefore another card from the villain deck as well!")
            else
                playVillains()
                broadcastToAll("Master Strike: Epic Annihilus plays a villain card, but it's not a villain.")
            end
        else
            if cardtype == "Villain" then
                playVillains()
                Wait.time(click_push_villain_into_city,2)
                Wait.time(function() addBystanders(city_zones_guids[2]) end,2.5)
                Wait.time(click_push_villain_into_city,4)
                broadcastToAll("Master Strike: Annihilus plays a villain, it captures a bystander and pushes the city forward!")
            elseif cardtype == "Bystander" then
                local pos = getObjectFromGUID(mmLocations[mmname]).getPosition()
                pos.z = pos.z - 2
                vildeck.takeObject({position = pos, 
                    flip = true, 
                    smooth = true})
                broadcastToAll("Master Strike: Annihilus captures a bystander from the villain deck!")
            else
                broadcastToAll("Master Strike: " .. cardtype .. " was revealed from the villain deck!")
            end
        end
        return strikesresolved
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
        local costs = callGUID("herocosts",3)
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
                        powerButton(o,"+3","Villains in the fortified city space get +3.","fortifying",nil,{0,22,8})
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
            for _,o in pairs(Player.getPlayers()) do
                local discardguids = {}
                local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
                --log("discard:")
                --log(discarded)
                if discarded[1] and discarded[1].tag == "Deck" then
                    for _,c in pairs(discarded[1].getObjects()) do
                        for _,tag in pairs(c.tags) do
                            if tag:find("HC:") then
                                table.insert(discardguids,c.guid)
                                break
                            end
                        end
                    end
                    log("discardguids " .. o.color)
                    log(discardguids)
                    if discardguids[1] and discardguids[2] then
                        if epicness == true then
                            offerCards(o.color,discarded[1],discardguids,koCard,"KO this card.","KO",nil,2)
                            broadcastToColor("Master Strike: Each player KOs two non-grey Heroes from their discard pile.",o.color,o.color)
                        else
                            offerCards(o.color,discarded[1],discardguids,koCard,"KO this card.","KO")
                            broadcastToColor("Master Strike: Choose a card from your discard pile to be KO'd.",o.color,o.color)
                        end
                    elseif discardguids[1] then
                        discarded[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                            guid = discardguids[1],
                            smooth = true})
                        broadcastToColor("Master Strike: The only non-grey hero from your discard pile was KO'd.",o.color,o.color)
                    end
                elseif discarded[1] then
                    if hasTag2(discarded[1],"HC:",4) then
                        koCard(discarded[1])
                        broadcastToColor("Master Strike: The only non-grey hero from your discard pile was KO'd.",o.color,o.color)
                    end
                end
            end
        elseif light < 0 then
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
                    local drawCard = function()
                        getObjectFromGUID(playerBoards[o.color]).Call('click_draw_card')
                    end
                    local c = 1
                    if epicness then
                        c = 2
                    end
                    promptDiscard(o.color,hand,c,getObjectFromGUID(kopile_guid).getPosition(),nil,"KO","Waking Nightmare, but this card will be KO'd by Belasco.",drawCard)
                end
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
                local discarded = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
                if discarded[1] then
                    getObjectFromGUID(playerBoards[color]).Call('click_refillDeck')
                    Wait.time(feastOn,2)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Charles Xavier, Professor of Crime" then
        function noWitness(obj)
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                local pos = hero.getPosition()
                pos.y = pos.y + 3
                pos.z = pos.z - 2
                if hero.guid ~= obj.guid then
                    addBystanders(o,false,nil,pos)
                end
                hero.clearButtons()
            end
        end
        broadcastToAll("Master Strike: Choose a HQ zone to which NO hidden witness will be added!")
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if not hero then
                broadcastToAll("Missing hero. Script failed.")
                return nil
            end
            hero.createButton({click_function="noWitness",
                function_owner=self,
                position={0,22,0},
                label="Exclude",
                tooltip="Don't put a hidden witness here.",
                font_size=250,
                font_color="Black",
                color={1,1,1},
                width=750,height=450})
        end
        return strikesresolved
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
            getObjectFromGUID(setupGUID).Call('playHorror')
            broadcastToAll("Each player must play a Hellfire Club villain from their Victory Pile!")       
        end
        return strikesresolved
    end
    if mmname == "Deadpool" then
        local towound = revealCardTrait(nil,"HC:",nil,"Odd")
        for _,o in pairs(towound) do
            click_get_wound(nil,o.color)
            broadcastToAll("Master Strike: Player " .. o.color .. " had no odd heroes and was wounded.")
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
            powerButton(cards[1],attack)
            push_all(current_city)
        end
        for _,o in pairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,p in pairs(citycontent) do
                    if p.name:find("Shi'ar") or p.hasTag("Shi'ar") then
                        if epicness == true then
                            getObjectFromGUID(setupGUID).Call('playHorror')
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
    if mmname == "Dr. Doom" or mmname == "God-Emperor" then
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if hand[1] and #hand == 6 then
                broadcastToAll("Master Strike: Player " .. o.color .. " puts two cards from their hand on top of their deck.")
                local pos = getObjectFromGUID(playerBoards[o.color]).positionToWorld({0.957, 1, 0.222})
                promptDiscard(o.color,nil,2,pos,true,"Top","Put on top of deck.")
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
        local c = strikesstacked
        if epicness then
            c = strikesstacked + 1
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
                local drawCard = function()
                    getObjectFromGUID(playerBoards[o.color]).Call('click_draw_card')
                end
                promptDiscard(o.color,hand,c,nil,nil,nil,nil,drawCard)
            end
        end
        broadcastToAll("Master Strike: Each player has " .. c .. " Waking Nightmares.")
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
        local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmLocations["General Ross"]))
        if transformedPV == true then
            crossDimensionalRampage("hulk")
        elseif transformedPV == false then
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
            local reaperbonus = 0
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
            powerButton(cards[1],7 + reaperbonus)
            push_all(table.clone(current_city))
        else
            broadcastToAll("No Master Strike found, so Grim Reaper failed to manifest a Graveyard.")
        end
        return nil
    end
    if mmname == "Hela, Goddess of Death" then
        if cards[1] then
            local helabonus = 0
            if epicness then
                helabonus = 1
            end
            cards[1].setName("Army of the Dead")
            cards[1].addTag("VP" .. 3 + helabonus)
            cards[1].addTag("Attack:" .. 5 + helabonus)
            cards[1].addTag("Villain")
            powerButton(cards[1],5 + helabonus)
            push_all(table.clone(current_city))
        else
            broadcastToAll("No Master Strike found, so Hela failed to muster an Army of the Dead.")
        end
        local pcolor = Turns.turn_color
        local vpilecontent = get_decks_and_cards_from_zone(vpileguids[pcolor])
        local moveToCity = function(obj)
            obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
            Wait.time(click_push_villain_into_city,2)
        end
        if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
            local vpilestrong = {}
            for _,o in pairs(vpilecontent[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k:find("VP") and tonumber(k:match("%d+")) > 2 + helabonus then
                        table.insert(vpilestrong,o.guid)
                        break
                    end
                end
            end
            log(vpilestrong)
            if vpilestrong[1] and not vpilestrong[2] then
                local pushDelayed = function()
                    Wait.time(click_push_villain_into_city,2)
                end
                vpilecontent[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                    smooth = true,
                    callback_function = pushDelayed})
                return nil
            elseif vpilestrong[1] and vpilestrong[2] then
                offerCards(pcolor,vpilecontent[1],vpilestrong,moveToCity)
                return nil
            end
        end
        if vpilecontent[1] and vpilecontent[1].tag == "Card" then
            if hasTag2(vpilecontent[1],"VP") and hasTag2(vpilecontent[1],"VP") > 2 + helabonus then
                moveToCity(vpilecontent[1])
                return nil
            end
        end
        dealWounds()
        return nil
    end
    if mmname == "Hybrid" then
        msno(mmname)
        return nil
    end
    if mmname == "Hydra High Council" then
        local mmcontent = get_decks_and_cards_from_zone(mmLocations[mmname])
        local name = nil
        if mmcontent[1] and mmcontent[1].tag == "Deck" then
            name = mmcontent[1].getObjects()[mmcontent[1].getQuantity()].name
        elseif mmcontent[1] then
            name = mmcontent[1].getName()
        else
            broadcastToAll("Mastermind not found!")
            return nil
        end
        if name == "Viper" then
            broadcastToAll("Master Strike: If there are any Hydra Villains in the city, each player gains a Wound.")
            for _,o in pairs(city) do
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if string.lower(obj.getName()):find("hydra") or (hasTag2(obj,"Group:",7) and string.lower(hasTag2(obj,"Group:",7)):find("hydra")) then
                            dealWounds()
                            mmcontent[1].randomize()
                            return strikesresolved
                        end
                    end
                end
            end
        elseif name == "Red Skull" then
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
                promptDiscard(o.color,hand,1,getObjectFromGUID(kopile_guid).getPosition(),nil,"KO","KO this card.")
            end
            broadcastToAll("Master Strike: Each player KOs a non-grey Hero. Select one from your hand or you may also exchange it with one you have in play.")
        elseif name == "Baron Helmut Zemo" then
            broadcastToAll("Each player KOs a Hydra Villain from their Victory Pile or gains a Wound.")
            for i,o in pairs(vpileguids) do
                if Player[i].seated == true then
                    local vpilecontent = get_decks_and_cards_from_zone(o)
                    local vpilewarbound = {}
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        for _,k in pairs(vpilecontent[1].getObjects()) do
                            if string.lower(k.name):find("hydra") then
                                table.insert(vpilewarbound,k.guid)
                            else
                                for _,tag in pairs(k.tags) do
                                    if string.lower(tag):find("hydra") then 
                                        table.insert(vpilewarbound,k.guid)
                                        break
                                    end
                                end
                            end
                        end
                        if vpilewarbound[1] and not vpilewarbound[2] then
                            vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                smooth = true,
                                guid = vpilewarbound[1]})
                        elseif vpilewarbound[1] and vpilewarbound[2] then
                            offerCards(i,vpilecontent[1],vpilewarbound,koCard,"KO this villain.","KO")
                            broadcastToColor("Master Strike: KO 1 of the " .. #vpilewarbound .. " villain cards that were put into play from your victory pile.",i,i)
                        else
                            click_get_wound(nil,i)
                        end
                    elseif vpilecontent[1] then
                        log(hasTag2(vpilecontent[1],"Group:",7,true))
                        if string.lower(vpilecontent[1].getName()):find("hydra") or (hasTag2(vpilecontent[1],"Group:") and string.lower(hasTag2(vpilecontent[1],"Group:")):find("hydra")) then
                            vpilecontent[1].setPosition(getObjectFromGUID(kopile_guid).getPosition())
                        else
                            click_get_wound(nil,i)
                        end
                    else
                        click_get_wound(nil,i)
                    end
                end
            end
        elseif name == "Arnim Zola" then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if not hasTag2(obj,"Attack:") then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                promptDiscard(o.color,hand,2)
            end
            broadcastToAll("Master Strike: Each player discards two heroes with Fight icons.")
        end
        mmcontent[1].randomize()
        return strikesresolved      
    end
    if mmname == "Hydra Super-Adaptoid" then
        local mmcontent = get_decks_and_cards_from_zone(mmLocations[mmname])
        local name = nil
        if mmcontent[1] and mmcontent[1].tag == "Deck" then
            name = mmcontent[1].getObjects()[mmcontent[1].getQuantity()].name
        elseif mmcontent[1] then
            name = mmcontent[1].getName()
        else
            broadcastToAll("Mastermind not found!")
            return nil
        end
        if name == "Captain America's Shield" then
            broadcastToAll("Master Strike: Each player reveals a Yellow Hero or discards their hand and draws four cards.")
            local players = revealCardTrait("Yellow")
            for _,o in pairs(players) do
                local hand = o.getHandObjects()
                promptDiscard(o.color,hand,#hand)
                local drawfour = function()
                    getObjectFromGUID(playerBoards[o.color]).Call('click_draw_cards',4)
                end
                Wait.time(drawfour,1)
            end
        elseif name == "Black Widow's Bite" then
            broadcastToAll("Master Strike: Each player KOs two Bystanders from their Victory Pile or gains a Wound.")
            for i,o in pairs(vpileguids) do
                if Player[i].seated == true then
                    local vpilecontent = get_decks_and_cards_from_zone(o)
                    local vpilewarbound = {}
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        for _,k in pairs(vpilecontent[1].getObjects()) do
                            for _,tag in pairs(k.tags) do
                                if tag == "Bystander" then 
                                    table.insert(vpilewarbound,k.guid)
                                    break
                                end
                            end
                        end
                        if  #vpilewarbound > 2 then
                            offerCards(i,vpilecontent[1],vpilewarbound,koCard,"KO this bystander.","KO",nil,2)
                            broadcastToColor("Master Strike: KO 2 of the " .. #vpilewarbound .. " bystanders that were put into play from your victory pile.",i,i)
                        else
                            click_get_wound(nil,i)
                        end
                    else
                        click_get_wound(nil,i)
                    end
                end
            end
        elseif name == "Thor's Hammer" then
            broadcastToAll("Master Strike: Each player reveals a Blue Hero or gains a Wound")
            local players = revealCardTrait("Blue")
            for _,o in pairs(players) do
                click_get_wound(nil,o.color)
            end
        elseif name == "Iron Man's Armor" then
            broadcastToAll("Master Strike: Each player reveals a Silver Hero or discards down to 3 cards")
            local players = revealCardTrait("Silver")
            for _,o in pairs(players) do
                local hand = o.getHandObjects()
                promptDiscard(o.color,hand,#hand-3)
            end
        end
        mmcontent[1].randomize()
        return strikesresolved      
    end
    if mmname == "Illuminati, Secret Society" then
        local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmLocations["Illuminati, Secret Society"]))
        if transformedPV == true then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if not hasTag2(obj,"COST:") or hasTag2(obj,"COST:") < 1 or hasTag2(obj,"COST:") > 4 then
                        if not obj.hasTag("Officer") and not obj.hasTag("Sidekick") then
                            table.remove(hand,i-iter)
                            iter = iter + 1
                        end
                    end
                end
                if hand[1] then
                    promptDiscard(o.color,hand,2)
                end
            end
            broadcastToAll("Master Strike: Each player reveals their hand and discards two cards that each cost between 1 and 4.")
        elseif transformedPV == false then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if not hasTag2(obj,"COST:") or hasTag2(obj,"COST:") < 5 or hasTag2(obj,"COST:") > 8 then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                if hand[1] then
                    promptDiscard(o.color,hand,2)
                end
            end
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
        for _,o in pairs(Player.getPlayers()) do
            local investigateMobs = function()
                local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
                local deckcontent = deck.getObjects()
                local investiguids = {deckcontent[1].guid,deckcontent[2].guid}
                local shuffleIntoMobs = function(obj)
                    obj.setPosition(getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                    obj.flip()
                    if epicness and (not hasTag2(obj,"Cost:") or hasTag2(obj,"Cost:") == 0) then
                        click_get_wound(nil,o.color)
                    end
                end
                offerCards(o.color,deck,investiguids,shuffleIntoMobs,"Shuffle this card into the Angry Mobs stack.","Shuffle",true)
            end
            local deck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
            if not deck[1] or deck[1].getQuantity() < 2 then
                getObjectFromGUID(playerBoards[o.color]).Call('refillDeck')
                Wait.time(investigateMobs,1)
            else
                investigateMobs()
            end
        end
        return strikesresolved
    end
    if mmname == "Kang the Conqueror" then
        local kanglabel = "⌛+2"
        if epicness == true then
            kanglabel = "⌛+3"
        end
        if strikesresolved == 1 then
            timeIncursions = {current_city[2]}
            getObjectFromGUID(timeIncursions[1]).createButton({click_function='updatePower',
                        function_owner=self,
                        position={0,0,0.5},
                        rotation={0,180,0},
                        label=kanglabel,
                        tooltip="This city space is under a Time Incursion.",
                        font_size=150,
                        font_color="Blue",
                        color={0,0,0,0.75},
                        width=250,height=250})
        else
            for i=2,#current_city do
                local guidfound = false
                for _,o in pairs(timeIncursions) do
                    if o == current_city[i] then
                        guidfound = true
                        break
                    end
                end
                if guidfound == false then
                    table.insert(timeIncursions,current_city[i])
                    getObjectFromGUID(current_city[i]).createButton({click_function='updatePower',
                        function_owner=self,
                        position={0,0,0.5},
                        rotation={0,180,0},
                        label=kanglabel,
                        tooltip="This city space is under a Time Incursion.",
                        font_size=150,
                        font_color="Blue",
                        color={0,0,0,0.75},
                        width=250,height=250})
                    break
                end
                if i == #current_city then
                    broadcastToAll("Master Strike: But the whole city is under time incursions already!")
                end
            end
        end
        if epicness == true then
            for _,o in pairs(timeIncursions) do
                local content = get_decks_and_cards_from_zone(o)
                if content[1] then
                    for _,p in pairs(content) do
                        if p.hasTag("Villain") then
                            dealWounds()
                            broadcastToAll("Master Strike: There were villains under time incursion so Epic Kang wounds everyone!")
                            return strikesresolved
                        end
                    end
                end
            end
        end
        return strikesresolved
    end
    if mmname == "King Hulk, Sakaarson" then
        local transformedPV = getObjectFromGUID(mmmZoneGUID).Call('transformMM',getObjectFromGUID(mmLocations["King Hulk, Sakaarson"]))
        if transformedPV == true then
            for i,o in pairs(vpileguids) do
                if Player[i].seated == true then
                    local vpilecontent = get_decks_and_cards_from_zone(o)
                    local vpilewarbound = {}
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        for _,k in pairs(vpilecontent[1].getObjects()) do
                            for _,tag in pairs(k.tags) do
                                if tag == "Group:Warbound" then 
                                    table.insert(vpilewarbound,k.guid)
                                    break
                                end
                            end
                        end
                        if vpilewarbound[1] and not vpilewarbound[2] then
                            vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                smooth = true,
                                guid = vpilewarbound[1]})
                        elseif vpilewarbound[1] and vpilewarbound[2] then
                            offerCards(i,vpilecontent[1],vpilewarbound,koCard,"KO this villain.","KO")
                            broadcastToColor("KO 1 of the " .. #vpilewarbound .. " villain cards that were put into play from your victory pile.",i,i)
                        else
                            click_get_wound(nil,i)
                        end
                    elseif vpilecontent[1] then
                        if vpilecontent[1].hasTag("Group:Warbound") then
                            vpilecontent[1].setPosition(getObjectFromGUID(kopile_guid).getPosition())
                        else
                            click_get_wound(nil,i)
                        end
                    else
                        click_get_wound(nil,i)
                    end
                end
            end
        elseif transformedPV == false then
            broadcastToAll("Master Strike: Each player reveals their hand, then KO's a card from their hand or discard pile that has the same card name as a card in the HQ.")
            --could be scripted, but tricky with both hand and discard pile zones
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
    if mmname == "Loki" or mmname == "Zombie Loki" then
        local towound = revealCardTrait("Green")
        for _,o in pairs(towound) do
            click_get_wound(nil,o.color)
            broadcastToAll("Master Strike: Player " .. o.color .. " had no green heroes and was wounded.")
        end
        return strikesresolved
    end
    if mmname == "Macho Gomez" then
        cards[1].setName("Bounty on your head")
        cards[1].setDescription("ARTIFACT: This is a bounty on your head. Macho will wound you with his master strikes for each bounty you have. Pay 1 recruit during your turn to pass this bounty to the player on your left.")
        cards[1].setPositionSmooth(getObjectFromGUID(playerBoards[Turns.turn_color]).positionToWorld({-1.5,4,4}))
        broadcastToAll("Master Strike: Each player gains a Wound for each Bounty on them.")
        for _,o in pairs(Player.getPlayers()) do
            local playcontent = get_decks_and_cards_from_zone(playguids[o.color])
            local bounties = 0
            if o.color == Turns.turn_color then
                bounties = 1
            end
            if playcontent[1] then
                for _,o in pairs(playcontent) do
                    if o.tag == "Card" and o.getName() == "Bounty on your head" then
                        bounties = bounties + 1
                    elseif o.tag == "Deck" then
                        for _,k in pairs(o.getObjects()) do
                            if k.name == "Bounty on your head" then
                                bounties = bounties + 1
                            end
                        end
                    end
                end
            end
            if bounties > 0 then
                for i = 1,bounties do
                    click_get_wound(nil,o.color)
                end
            end
        end
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
    if mmname == "Magneto" or mmname == "Apocalyptic Magneto" then
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
                    local top = nil
                    if epicness then
                        top = true
                    end
                    dealWounds(top)
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
            powerButton(cards[1],boost)
            click_push_villain_into_city()
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
            Wait.time(addshard,3)
            return nil
        end
        return strikesresolved
    end
    if mmname == "Malekith the Accursed" or mmname == "Maximus the Mad" then
        msno(mmname)
        return nil
    end
    if mmname == "Mandarin" then
        local top = nil
        if epicness then
            top = true
        end
        for _,o in pairs(Player.getPlayers()) do
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
            local moveToCity = function(obj)
                obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
                Wait.time(click_push_villain_into_city,2)
            end
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                local vpilestrong = {}
                for _,o in pairs(vpilecontent[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k == "Group:Mandarin's Rings" then
                            table.insert(vpilestrong,o.guid)
                            break
                        end
                    end
                end
                --log(vpilestrong)
                if vpilestrong[1] and not vpilestrong[2] then
                    local pushDelayed = function()
                        Wait.time(click_push_villain_into_city,2)
                    end
                    vpilecontent[1].takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                        smooth = true,
                        guid = vpilestrong[1],
                        callback_function = pushDelayed})
                elseif vpilestrong[1] and vpilestrong[2] then
                    offerCards(o.color,vpilecontent[1],vpilestrong,moveToCity,"Push this Mandarin's Ring into the city.","Push")
                else
                    click_get_wound(nil,o.color,nil,top)
                end
            elseif vpilecontent[1] and vpilecontent[1].tag == "Card" then
                if vpilecontent[1].hasTag("Group:Mandarin's Rings") then
                    moveToCity(vpilecontent[1])
                else
                    click_get_wound(nil,o.color,nil,top)
                end
            else
                click_get_wound(nil,o.color,nil,top)
            end
        end
        return strikesresolved
    end
    if mmname == "Maria Hill, Director of S.H.I.E.L.D." then
        local officerdeck = getObjectFromGUID(officerDeckGUID)
        local pushOfficer = function(obj)
            powerButton(obj,3)
            click_push_villain_into_city()
        end
        local takeOfficer = function()
            officerdeck.takeObject({position = getObjectFromGUID(city_zones_guids[1]).getPosition(),
                flip = true,
                smooth = true,
                callback_function = pushOfficer})
        end
        takeOfficer()
        Wait.time(takeOfficer,2)
        return strikesresolved
    end
    if mmname == "Mastermind" or mmname =="Lady Mastermind" then
        msno(mmname)
        return nil
    end
    if mmname == "Master Plan" then
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            click_get_wound(nil,o.color)
        end
        return strikesresolved
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
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local recruitcount = 0
            if hand[1] and hand[4] then
                for _,h in pairs(hand) do
                    if hasTag2(h,"Recruit:") then
                        recruitcount = recruitcount + 1
                    end
                end
                if recruitcount < 4 then
                    click_get_wound(nil,o.color)
                end
            else
                click_get_wound(nil,o.color)
            end
        end
        broadcastToAll("Master Strike: Each player reveals 4 cards with Recruit icons or gains a Wound.")
        return strikesresolved
    end
    if mmname == "M.O.D.O.K." then
        local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmLocations["M.O.D.O.K."]))
        if transformedPV == true then
            local players = Player.getPlayers()
            for _,o in pairs(players) do
                local hand = o.getHandObjects()
                if hand[1] then
                    local outwitcount = callGUID("herocosts",3)
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
        elseif transformedPV == false then
            local players = Player.getPlayers()
            for _,o in pairs(players) do
                local hand = o.getHandObjects()
                if hand[1] then
                    local outwitcount = callGUID("herocosts",3)
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
                        if hasTag2(p,"Group:",7) and hasTag2(p,"Group:",7) == "Mojoverse" then
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
        local players = nil
        if epicness then
            broadcastToAll("Master Strike: Each player in turn gains a Wound, then gains a 0-cost Hero from the KO pile.")
            players = Player.getPlayers()
            dealWounds()
        else
            players = revealCardTrait("Red")
            broadcastToAll("Master Strike: Each player in turn reveals a Red Hero or gains a 0-cost Hero or Wound from the KO pile.")
        end
        morganWounds = function(color,players)
            local playerBoard = getObjectFromGUID(playerBoards[color])
            local dest = playerBoard.positionToWorld(pos_discard)
            if color == "White" then
                angle = 90
            elseif color == "Blue" then
                angle = -90
            else
                angle = 180
            end
            local brot = {x=0, y=angle, z=0}
            dest.y = dest.y + 3
            local kopilecontent = get_decks_and_cards_from_zone(kopile_guid)
            local kodguids = {}
            if kopilecontent[1] and kopilecontent[1].tag == "Deck" then
                for _,c in pairs(kopilecontent[1].getObjects()) do
                    for _,tag in pairs(c.tags) do
                        if tag == "Starter" or (tag == "Wound" and epicness == false) then
                            table.insert(kodguids,c.guid)
                            break
                        end
                    end
                end
                if kodguids[1] and not kodguids[2] then
                    kopilecontent[1].takeObject({position = dest,
                        flip = false,
                        smooth = true,
                        guid = kodguids[1]})
                elseif kodguids[1] and kodguids[2] then
                    local gainCrapCard = function(obj)
                        obj.setPositionSmooth(dest)
                        local nextcolor = getNextColor(color)
                        if nextcolor and nextcolor ~= players[1].color then
                            Wait.time(
                                function() 
                                    morganWounds(nextcolor,players)
                                    broadcastToColor("Choose a starter hero or wound to gain from the KO pile.",nextcolor,nextcolor)
                                end,1)
                        end
                    end
                    offerCards(color,kopilecontent[1],kodguids,gainCrapCard,"Gain this card.","Gain")
                end
            elseif kopilecontent[1] then
                if kopilecontent[1].hasTag("Starter") or (kopilecontent[1].hasTag("Wound") and epicness == false) then
                    kopilecontent[1].setPositionSmooth(dest)
                end
            end
        end
        if players[1] then
            morganWounds(players[1].color,players)
            broadcastToColor("Choose a starter hero or wound to gain from the KO pile.",players[1].color,players[1].color)
        end
        return strikesresolved
    end
    if mmname == "Mr. Sinister" or mmname == "Zombie Mr. Sinister" then
        local players = revealCardTrait("Red")
        addBystanders(strikeloc,nil,false)
        --sadly, zombie mr sinister has no strikeloc...
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
    if mmname == "Nimrod, Super Sentinel" then
        -- local players = revealCardTrait("Silver")
        -- for _,o in pairs(players) do
            -- --make offercards function for generic choices (not reliant on cards)
        -- end
        -- return strikesresolved
        msno(mmname)
        return nil
    end
    if mmname == "Onslaught" then
        local dominated = get_decks_and_cards_from_zone(getStrikeloc(mmname))
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
                    promptDiscard(o.color,hand,2,getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                    broadcastToColor("Master Strike: Two nongrey heroes from your hand become dominated by Onslaught.",o.color,o.color)
                else
                    promptDiscard(o.color,hand,1,getObjectFromGUID(getStrikeloc(mmname)).getPosition())
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
                    promptDiscard(o.color,hand,#hand/2 + 0.5*(#hand % 2),getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                    broadcastToColor("Master Strike: " .. #hand/2 + 0.5*(#hand % 2) .. " nongrey heroes from your hand become souls poisoned by Thanos.",o.color,o.color)
                else
                    promptDiscard(o.color,hand,1,getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                    broadcastToColor("Master Strike: A nongrey hero from your hand becomes a soul poisoned by Thanos.",o.color,o.color)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Professor X" or mmname == "'92 Professor X" then
        local costs = {}
        local strikeZone = getObjectFromGUID(getStrikeloc(mmname))
        for i,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            if not hero then
                broadcastToAll("Hero not found in HQ. Abort script")
                return nil
            end
            costs[i] = hasTag2(hero,"Cost:") or 0
        end
        local costs2 = table.sort(table.clone(costs))
        local maxv = {costs2[#costs2],costs2[#costs2-1]}
        broadcastToAll("Master Strike: Choose the two highest-cost Allies in the Lair. Stack them next to Professor X as \"Telepathic Pawns.\".")
        if costs2[#costs2-2] < maxv[2] then
            for i,o in pairs(costs) do
                if o >= maxv[2] then
                    local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
                    hero.setPositionSmooth(strikeZone.getPosition())
                    getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
                end
            end
        elseif maxv[1] > maxv[2] then
            local otherguids = {}
            for i,o in pairs(costs) do
                local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
                if o == maxv[1] then
                    hero.setPositionSmooth(strikeZone.getPosition())
                    getObjectFromGUID(hqguids[i]).Call('click_draw_hero')
                elseif o == maxv[2] then
                    table.insert(otherguids,hero)
                end
            end
            promptDiscard(Turns.turn_color,otherguids,1,strikeZone.getPosition(),nil,"Dom","Professor X dominates this hero as a telepathic pawn.")
        elseif maxv[1] == maxv[2] then
            local otherguids = {}
            for i,o in pairs(costs) do
                local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
                if o == maxv[1] then
                    table.insert(otherguids,hero)
                end
            end
            promptDiscard(Turns.turn_color,otherguids,2,strikeZone.getPosition(),nil,"Dom","Professor X dominates this hero as a telepathic pawn.")
        end
        return strikesresolved
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
        local strikezoneguid = getStrikeloc(mmname)
        local strikezonecontent = get_decks_and_cards_from_zone(strikezoneguid)
        if strikezonecontent[1] then
            koCard(strikezonecontent[1])
        end
        local dominate = function(obj)
            obj.setPositionSmooth(getObjectFromGUID(strikezoneguid).getPosition())
        end
        for _,o in pairs(Player.getPlayers()) do
            local discardguids = {}
            local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
            if discarded[1] and discarded[1].tag == "Deck" then
                for _,c in pairs(discarded[1].getObjects()) do
                    for _,tag in pairs(c.tags) do
                        if tag:find("HC:") then
                            table.insert(discardguids,c.guid)
                            break
                        end
                    end
                end
                if discardguids[1] and discardguids[2] then
                    if epicness == true then
                        offerCards(o.color,discarded[1],discardguids,dominate,"Shadow King dominates this hero.","Dom",nil,2)
                        broadcastToColor("Master Strike: Shadow King dominates two non-grey Heroes from your discard pile.",o.color,o.color)
                    else
                        offerCards(o.color,discarded[1],discardguids,dominate,"Shadow King dominates this hero.","Dom")
                        broadcastToColor("Master Strike: Shadow King dominates a non-grey hero from your discard pile.",o.color,o.color)
                    end
                elseif discardguids[1] then
                    discarded[1].takeObject({position = getObjectFromGUID(strikezoneguid).getPosition(),
                        guid = discardguids[1],
                        smooth = true})
                    broadcastToColor("Master Strike: Shadow King dominates the only non-grey hero from your discard pile.",o.color,o.color)
                end
            elseif discarded[1] then
                if hasTag2(discarded[1],"HC:",4) then
                    dominate(discarded[1])
                    broadcastToColor("Master Strike: Shadow King dominates the only non-grey hero from your discard pile.",o.color,o.color)
                end
            end
        end
        return strikesresolved
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
                broadcastToAll("Master Strike: Shiklah revealed " .. objname .. " from the villain deck!")
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
    if mmname == "Spider-Queen" then
        local emptycity = table.clone(city)
        local iter = 0
        for i,o in ipairs(city) do
            local citycontent = get_decks_and_cards_from_zone(o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.hasTag("Villain") then
                        table.remove(emptycity,i-iter)
                        iter = iter + 1
                        break
                    end
                end
            end
        end
        if emptycity[1] then
            for _,o in pairs(Player.getPlayers()) do
                if not emptycity[1] then
                    click_get_wound(nil,o.color)
                else
                    local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        local spiderinfound = false
                        for _,obj in pairs(vpilecontent[1].getObjects()) do
                            if obj.name == "Spider-Infected" then
                                local pos = getObjectFromGUID(table.remove(emptycity,1)).getPosition()
                                vpilecontent[1].takeObject({position = pos,
                                    guid = obj.guid,
                                    smooth = true})
                                spiderinfound = true
                                broadcastToColor("Master Strike: Spider-infected henchmen added to first empty city space. You may move it to another empty one.",o.color,o.color)
                                break
                            end
                        end
                        if spiderinfound == false then
                            click_get_wound(nil,o.color)
                        end
                    elseif vpilecontent[1] then
                        if vpilecontent[1].getName() == "Spider-Infected" then
                            local pos = getObjectFromGUID(table.remove(emptycity,1)).getPosition()
                            vpilecontent[1].setPositionSmooth(pos)
                            broadcastToColor("Master Strike: Spider-infected henchmen added to first empty city space. You may move it to another empty one.",o.color,o.color)
                        else
                            click_get_wound(nil,o.color)
                        end
                    else
                        click_get_wound(nil,o.color)
                    end
                end
            end
        else
            dealWounds()
        end
        return strikesresolved
    end
    if mmname == "Stryfe" then
        if cards[1] then
            strikesstacked = strikesstacked + 1
            cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
            if strikesstacked == 1 then
                getObjectFromGUID(mmloc).createButton({click_function='updatePower',
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
    if mmname == "Supreme Intelligence of the Kree" then
        local mmcontent = get_decks_and_cards_from_zone(mmLocations[mmname])
        local shards = 0
        for _,o in pairs(mmcontent) do
            if o.getName() == "Shard" then
                shards = o.Call('returnVal')
                break
            end
        end
        shards = shards + 1
        gainShard(nil,mmLocations[mmname])
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
            if hand[1] then
                for _,obj in pairs(hand) do
                    local cost = hasTag2(obj,"Cost:")
                    if cost and (cost == shards or cost == shards + 1) then
                        obj.setPosition(posdiscard)
                        broadcastToColor("Master Strike: " .. obj.getName() .. " discarded.",o.color,o.color)
                    end
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Thanos" then
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
                promptDiscard(o.color,hand,1,getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                broadcastToColor("Master Strike: A nongrey hero from your hand becomes a soul bound by Thanos.",o.color,o.color)
            end
        end
        return strikesresolved
    end
    if mmname == "The Beyonder" then
        if not pocketdimensions then
            pocketdimensions = {}
            updatePocketDimensions = function()
                for _,o in pairs(pocketdimensions) do
                    local buttonfound = false
                    for i,b in pairs(getObjectFromGUID(o).getButtons()) do
                        if b.click_function == "updatePocketDimensions" then
                            getObjectFromGUID(o).editButton({index=i-1,label=#pocketdimensions})
                            buttonfound = true
                            break
                        end
                    end
                    if not buttonfound then
                        getObjectFromGUID(o).createButton({click_function='updatePocketDimensions',
                            function_owner=self,
                            position={0,2,-2},
                            label=#pocketdimensions,
                            tooltip="To recruit a card from a Pocket Dimension, you must pay 1 for each Pocket Dimension in play.",
                            font_size=500,
                            font_color={1,0,0},
                            color={1,1,1,0.85},
                            width=650,height=450})
                    end
                end
            end
        end
        local beyond = 5
        if epicness then
            beyond = 6
        end
        local players = revealCardTrait(beyond,"Cost:",nil,"Cost")
        for _,o in pairs(players) do
            click_get_wound(nil,o.color)
        end
        pocketDimensionize = function(obj)
            table.insert(pocketdimensions,obj.guid)
            updatePocketDimensions()
            for _,o in pairs(hqguids) do
                for i,b in pairs(getObjectFromGUID(o).getButtons()) do
                    if b.click_function == "pocketDimensionize" then
                        getObjectFromGUID(o).removeButton(i-1)
                        break
                    end
                end
            end
        end
        for _,o in pairs(hqguids) do
            if #pocketdimensions ~= #hqguids then
                local already = false
                for _,k in pairs(pocketdimensions) do
                    if k == o then
                        already = true
                        break
                    end
                end
                if not already then
                    getObjectFromGUID(o).createButton({click_function='pocketDimensionize',
                        function_owner=self,
                        position={0,2,0},
                        label="Pull",
                        tooltip="Pull this space into a Pocket Dimension",
                        font_size=350,
                        font_color={1,0,0},
                        color={0,0,0},
                        width=1000,height=600})
                end
            end
        end
        return strikesresolved
    end
    if mmname == "The Goblin, Underworld Boss" then
        local shieldspresent = get_decks_and_cards_from_zone(strikeloc)
        local shieldcount = 0
        if shieldspresent[1] then
            shieldcount = math.abs(shieldspresent[1].getQuantity())
        end
        local bsadded = 0
        for _,o in pairs(Player.getPlayers()) do
            local vpile = get_decks_and_cards_from_zone(vpileguids[o.color])
            if vpile[1] and vpile[1].tag == "Deck" then
                local bsguids = {}
                for _,obj in pairs(vpile[1].getObjects()) do
                    for _,k in pairs(obj.tags) do
                        if k == "Bystander" then
                            table.insert(bsguids,obj.guid)
                            break
                        end
                    end
                end
                local guid = nil
                if #bsguids > 1 then
                    bsadded = bsadded + 2
                    guid = table.remove(bsguids,math.random(#bsguids))
                    vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                        flip=true,
                        guid=guid,
                        smooth=true})
                    if not vpile[1].remainder then
                        guid = table.remove(bsguids,math.random(#bsguids))
                        vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                            flip=true,
                            guid=guid,
                            smooth=true})
                    else
                        vpile[1].remainder.flip()
                        vpile[1].remainder.setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                    end
                else
                    click_get_wound(nil,o.color)
                end
            else
                click_get_wound(nil,o.color)
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
    if mmname == "The Grandmaster" then
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        local color = nil
        if not herodeck[1] then
            broadcastToAll("No hero deck found")
            return nil
        elseif herodeck[1].tag == "Deck" then
            for _,o in pairs(herodeck[1].getObjects()[1].tags) do
                if o:find("HC:") then
                    color = o:gsub("HC:","")
                    break
                end
            end
        else
            color = hasTag2(herodeck[1],"HC:",4)
        end
        local grandmasterContest = function(obj)
            for i,o in pairs(obj) do
                if i == "Evil" and o == true then
                    local shardn = 1
                    if epicness then
                        shardn = 2
                        broadcastToAll("Master Strike: Evil won, so the mastermind gains two shards!")
                    else
                        broadcastToAll("Master Strike: Evil won, so the mastermind gains a shard!")
                    end
                    gainShard(nil,mmLocations["The Grandmaster"],shardn)
                elseif not o and i ~= "Evil" then
                    click_get_wound(nil,i)
                end
            end
        end
        contestOfChampions(color,2,grandmasterContest,epicness)
        return strikesresolved
    end
    if mmname == "The Hood" then
        if epicness then
            for _,o in pairs(Player.getPlayers()) do
                local playerBoard = getObjectFromGUID(playerBoards[o.color])
                local deck = playerBoard.Call('returnDeck')[1]
                local posdiscard = playerBoard.positionToWorld(pos_discard)
                local posdraw = playerBoard.positionToWorld({0.957, 0.178, 0.222})
                if deck then
                    deck.flip()
                    deck.setPosition(posdiscard)
                end
                local hoodResets = function()
                    local discard = playerBoard.Call('returnDiscardPile')[1]
                    local greyguids = {}
                    for _,obj in pairs(discard.getObjects()) do
                        local colored = false
                        for _,k in pairs(obj.tags) do
                            if k:find("HC:") then
                                colored = true
                                break
                            end
                        end
                        if not colored then
                            table.insert(greyguids,obj.guid)
                        end
                    end
                    while #greyguids > 6 do
                        table.remove(greyguids,math.random(#greyguids))
                    end
                    for _,k in pairs(greyguids) do
                        discard.takeObject({position = posdraw,
                            flip = true,
                            smooth = true})
                    end
                end
                Wait.time(hoodResets,1)
            end
        else
           for _,o in pairs(Player.getPlayers()) do
                local playerBoard = getObjectFromGUID(playerBoards[o.color])
                local posdiscard = playerBoard.positionToWorld(pos_discard)
                local deck = playerBoard.Call('returnDeck')[1]
                local hoodDiscards = function()
                    if not deck then
                        deck = playerBoard.Call('returnDeck')[1]
                    end
                    local deckcards = deck.getObjects()
                    local todiscard = {}
                    for i=1,6 do
                        for _,k in pairs(deckcards[i].tags) do
                            if k:find("HC:") then
                                table.insert(todiscard,deckcards[i].guid)
                                break
                            end
                        end
                    end
                    if todiscard[1] then
                        for i=1,#todiscard do
                            deck.takeObject({position = posdiscard,
                                flip = true,
                                smooth = true,
                                guid = todiscard[i]})
                            if deck.remainder and i < #todiscard then
                                deck.remainder.flip()
                                deck.remainder.setPositionSmooth(posdiscard)
                            end
                        end
                    end
                end
                if deck and deck.getQuantity() > 5 then
                    hoodDiscards()
                else
                    playerBoard.Call('click_refillDeck')
                    deck = nil
                    Wait.time(hoodDiscards,2)
                end
           end
        end
        return strikesresolved
    end
    if mmname == "The Red King" then
        local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmLocations["The Red King"]))
        if transformedPV == true then
            local towound = revealCardTrait("Silver")
            if towound[1] then
                for _,o in pairs(towound) do
                    click_get_wound(nil,o.color)
                    broadcastToAll("Master Strike: Player " .. o.color .. " had no silver heroes and was wounded.")
                end
            end
        elseif transformedPV == false then
            playVillains()
        end
        return strikesresolved 
    end
    if mmname == "The Sentry" then
        local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmLocations["The Sentry"]))
        if transformedPV == true then
            crossDimensionalRampage("void")
        elseif transformedPV == false then
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
    if mmname == "Ultron" then
        for _,o in pairs(Player.getPlayers()) do
            if epicness then
                local hand = o.getHandObjects()
                local handi = table.clone(hand)
                local iter = 0
                if hand[1] then
                    for i,h in pairs(handi) do
                        if not hasTag2(h,"HC:",4) then
                            table.remove(hand,i-iter)
                            iter = iter + 1
                        end
                    end
                    promptDiscard(o.color,hand,1,getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                    broadcastToColor("Master Strike: Put a non-grey Hero from your hand into a Threat Analysis pile next to Ultron.",o.color,o.color)
                end
            else
                --local players = revealCardTrait("Silver")
                broadcastToColor("Master Strike: Put a non-grey Hero from your discard pile into a Threat Analysis pile next to Ultron.",o.color,o.color)
            end
        end
        return strikesresolved
    end
    if mmname == "Warrior Woman" then
        local citycontent = get_decks_and_cards_from_zone(current_city[2])
        if citycontent[1] then
            for _,oc in pairs(citycontent) do
                if oc.hasTag("Villain") then
                    for _,o in pairs(Player.getPlayers()) do
                        local hand = o.getHandObjects()
                        local handi = table.clone(hand)
                        local iter = 0
                        if hand[1] then
                            for i,h in pairs(handi) do
                                if not hasTag2(h,"Recruit:",8) then
                                    table.remove(hand,i-iter)
                                    iter = iter + 1
                                end
                            end
                            promptDiscard(o.color,hand,1)
                            broadcastToColor("Master Strike: Discard a card with a Recruit icon.",o.color,o.color)
                        end
                    end
                    break
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Wasteland Hulk" then
        crossDimensionalRampage("hulk")
        return strikesresolved
    end
    if mmname == "Wasteland Kingpin" then
        local players = revealCardTrait("Yellow")
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
    if mmname == "Zombie Thanos" then
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
                promptDiscard(o.color,hand,1,getObjectFromGUID(kopile_guid).getPosition())
                broadcastToColor("Master Strike: KO a nongrey hero from your hand.",o.color,o.color)
            end
        end
        broadcastToAll("Master Strike: Each player must KO a nongrey hero from their hand, if any.")
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
                elseif what == "Odd" then
                    if hasTag2(h,prefix) and hasTag2(h,prefix) % 2 ~= 0 then
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

function nonTwistspecials(cards,schemeParts,city)
    if schemeParts[1] == "Brainwash the Military" then
        if cards[1].getName() == "S.H.I.E.L.D. Officer" or cards[1].getName() == "Madame Hydra" then
            cards[1].addTag("Brainwashed")
            powerButton(cards[1],twistsstacked+3)
        end
    end
    if schemeParts[1] == "Deadpool Wants A Chimichanga" then
        if cards[1].hasTag("Bystander") then
            playVillains()
        end
    end
    if schemeParts[1] == "Devolve with Xerogen Crystals" then
        if cards[1].getName() == schemeParts[9] then
            cards[1].setName("Xerogen Experiments")
            if cards[1].getDescription() == "" then
                cards[1].setDescription("ABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nABOMINATION: Villain gets extra printed Power from hero below it in the HQ.")
            end
        end
    end
    if schemeParts[1] == "Everybody Hates Deadpool" then
        if cards[1].hasTag("Villain") then
            if cards[1].getDescription() == "" then
                cards[1].setDescription("REVENGE: This villain gets +1 Power for each card of the listed group in the attacking player's Victory Pile.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nREVENGE: This villain gets +1 Power for each card of the listed group in the attacking player's Victory Pile.")
            end
        end
    end
    if schemeParts[1] == "House of M" then
        if cards[1].getName() == "Scarlet Witch (R)" then
            local boost = 3
            if noMoreMutants then
                boost = 4
            end
            powerButton(cards[1],boost + hasTag2(cards[1],"Cost:"))
        end
    end
    if schemeParts[1] == "Master of Tyrants" then
        if cards[1].getName() == "Dark Power" then
            broadcastToAll("Scheme Twist: Put this twist under a tyrant as a Dark Power!")
            return nil
        end
    end
    if schemeParts[1] == "Mass Produce War Machine Armor" then
        if cards[1].getName() == "S.H.I.E.L.D. Assault Squad" then
            powerButton(cards[1],"+" .. twistsresolved)
        end
    end
    if schemeParts[1] == "Organized Crime Wave" then
        if cards[1].getName() == "Maggia Goons" then
            playVillains(1)
        end
    end
    if schemeParts[1] == "Replace Earth's Leaders with Killbots" then
        if twistsstacked == 0 then
            twistsstacked = 3
        end
        if cards[1].hasTag("Bystander") then
            cards[1].addTag("Villain")
            cards[1].addTag("Killbot")
            powerButton(cards[1],twistsstacked)
        end
    end
    if schemeParts[1] == "Scavenge Alien Weaponry" then
        if cards[1].getName() == schemeParts[9] then
            cards[1].setName("Smugglers")
            if cards[1].getDescription() == "" then
                cards[1].setDescription("STRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nSTRIKER: Get 1 extra Power for each Master Strike in the KO pile or placed face-up in any zone.")
            end
            powerButton(cards[1],"+" .. strikesresolved)
        end
    end
    if schemeParts[1] == "Secret Invasion of the Skrull Shapeshifters" then
        if hasTag2(cards[1],"Cost:") then
            powerButton(cards[1],hasTag2(cards[1],"Cost:")+2)
            cards[1].addTag("Villain")
        end
    end
    if schemeParts[1] == "Sinister Ambitions" then
        if cards[1].hasTag("Ambition") then
            powerButton(cards[1],"+" .. twistsstacked)
        end
    end
    if schemeParts[1] == "Splice Humans with Spider DNA" then
        if cards[1].hasTag("Group:Sinister Six") then
            powerButton(cards[1],"+3")
        end
    end
    if schemeParts[1] == "The Dark Phoenix Saga" then
        if cards[1].getName() == "Jean Grey (DC)" then
            powerButton(cards[1],hasTag2(cards[1],"Cost:"))
            cards[1].addTag("Villain")
            playVillains(1)
        end
    end
    if schemeParts[1] == "The Fountain of Eternal Life" then
        if cards[1].hasTag("Villain") and not cards[1].getDescription():find("FATEFUL RESURRECTION") then
            if cards[1].getDescription() == "" then
                cards[1].setDescription("FATEFUL RESURRECTION: Reveal the top card of the Villain Deck. If it's a Scheme Twist or Master Strike, this card goes back to where it was when fought.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nFATEFUL RESURRECTION: Reveal the top card of the Villain Deck. If it's a Scheme Twist or Master Strike, this card goes back to where it was when fought.")
            end
        end
    end
    if schemeParts[1] == "The Mark of Khonshu" then
        if hasTag2(cards[1],"Cost:") then
            cards[1].addTag("Villain")
            cards[1].addTag("Khonshu Guardian")
            powerButton(cards[1],hasTag2(cards[1],"Cost:")*2)
        end
    end
    if schemeParts[1] == "Transform Citizens Into Demons" then
        if cards[1].getName() == "Jean Grey (DC)" then
            if not goblincount then
                goblincount = 0
            end
            powerButton(cards[1],hasTag2(cards[1],"Cost:")+goblincount)
            cards[1].addTag("Villain")
            cards[1].addTag("VP4")
        end
    end
    if schemeParts[1] == "Trap Heroes in the Microverse" then
        if hasTag2(cards[1],"Team:",6) then
            powerButton(cards[1],hasTag2(cards[1],"Cost:") .. "*")
            if cards[1].getDescription() == "" then
                cards[1].setDescription("SIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nSIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
            end
        end
    end
    if schemeParts[1] == "War of the Frost Giants" then
        if cards[1].getName() == "Frost Giant Invader" then
            powerButton(cards[1],"6+")
        end
    end
    if schemeParts[1] == "X-Cutioner's Song" then
        if hasTag2(cards[1],"Cost:") then
            if cards[1].getDescription() == "" then
                cards[1].setDescription("VILLAINOUS WEAPON: Of sorts. These are captured by the enemy (including mastermind) closest to the Villain deck. The Villain gets +2 for each captured hero. When fighting an enemy with captured heroes, gain those heroes.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nVILLAINOUS WEAPON: Of sorts. These are captured by the enemy (including mastermind) closest to the Villain deck. The Villain gets +2 for each captured hero. When fighting an enemy with captured heroes, gain those heroes.")
            end
        end
    end
    local horrors = callGUID("horrors",2)
    for _,o in pairs(horrors) do
        if o == "Army of Evil" and cards[1].hasTag("Villain") and not cards[1].hasTag("Henchmen") then
            powerButton(cards[1],"+1","All non-henchmen villains get +1","Army of Evil Horror")
        end
        if o == "Endless Hatred" and cards[1].getName() == "Scheme Twist" then
            local masterminds = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))
            local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
            for i,o in pairs(mmLocations) do
                if o == mmZoneGUID then
                    Wait.condition(
                        function() 
                            resolveStrike(i:gsub(" - epic",""),i:find(" - epic"),city,{}) 
                        end,
                        function() 
                            local content = get_decks_and_cards_from_zone(city_zones_guids[1])
                            if content[1] and content[1].guid == cards[1].guid then
                                return false
                            else
                                return true
                            end
                        end)
                    broadcastToAll("Through the Horror of Endless Hatred, this Scheme Twist will also trigger a Master Strike from the main Mastermind as soon as the twist effect is completed.")
                    break
                end
            end
        end
        if o == "Legions Upon Legions" and cards[1].hasTag("Henchmen") and cards[1].hasTag("Villain") then
            playVillains()
        end
        if o == "Misery Upon Misery" and cards[1].hasTag("Bystander") then
            playVillains()
        end
        if o == "Pain Upon Pain" and cards[1].getName() == "Masterstrike" then
            playVillains()
        end
        if o == "Plots Upon Plots" and cards[1].getName() == "Scheme Twist" then
            playVillains()
        end
    end
    --resolveVillainEffect(cards,"Ambush")
    --needs much more work in setting up functions
    if hasTag2(cards[1],"Group:") and ascendVillain(cards[1].getName(),hasTag2(cards[1],"Group:"),true) then
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local zone = mmZone.Call('getNextMMLoc')
        cards[1].setPositionSmooth(getObjectFromGUID(zone).getPosition())
        mmZone.Call('updateMasterminds',cards[1].getName())
        mmZone.Call('updateMastermindsLocation',{cards[1].getName(),zone})
        mmZone.Call('setupMasterminds',cards[1].getName())
        return nil
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
    local name = "Discard "
    if ko then
       name = "KO "    
    end
    local callbacksresolved = 0
    local demolishEffect = function()
        for _,o in pairs(colors) do
            for i=1,10 do
                if costs[i] > 0 then
                    local hand = Player[o].getHandObjects()
                    if hand[1] then
                        local handcost = 0
                        local handi = table.clone(hand)
                        local iter = 0
                        for j,h in ipairs(handi) do
                            if not hasTag2(h,"Cost:") or hasTag2(h,"Cost:") == i then
                                table.remove(hand,j-iter)
                                iter = iter + 1
                            end
                        end
                        local posdiscard = nil
                        if ko == true then
                            posdiscard = getObjectFromGUID(kopile_guid).getPosition()
                        else
                            posdiscard = getObjectFromGUID(playerBoards[o]).positionToWorld(pos_discard)
                        end
                        promptDiscard(o,hand,costs[i],posdiscard)
                        broadcastToColor(name .. math.min(#hand,costs[i]) .. " cards from your hand with cost " .. i,o,o)
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
        costs = callGUID("herocosts",3)
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

function offerCards(color,pile,guids,resolvef,toolt,label,flip,n)
    if not toolt then
        toolt = "Pick this card for the scheme twist, master strike or other effect."
    end
    if not label then
        label = "Pick"
    end
    if not n then
        n = 1
    else
        n = math.min(n,#guids)
    end
    if not flip then
        flip = false
    end
    if not guids then
        guids = {}
        for _,o in pairs(pile.getObjects()) do
            table.insert(guids,o.guid)
        end
    end
    local pos = getObjectFromGUID(playerBoards[color]).getPosition()
    pos.y = pos.y + 8
    local posini = nil
    local angle = 180
    if color == "White" then
        pos.z = pos.z - 6
        posini = pos.z
        angle = 90
    elseif color == "Blue" then
        pos.z = pos.z + 6
        posini = pos.z
        angle = -90
    else
        pos.x = pos.x - 6
        posini = pos.x
    end
	local brot = {x=0, y=angle, z=0}
    if not cardsoffered then 
        cardsoffered = {}
        for _,o in pairs(Player.getPlayers()) do
            cardsoffered[o.color] = {nil}
        end
    end
    local pilepos = pile.getPosition()
    pilepos.y = pilepos.y + 4
    _G['resolveOfferCardsEffect' .. color] = function(obj,player_clicker_color)
        --can use player color to disable other players from clicking
        --messes up solo two-handed play though
        local color = nil
        for _,b in pairs(obj.getButtons()) do
            if b.click_function:find("resolveOfferCardsEffect") then
                color = b.click_function:gsub("resolveOfferCardsEffect","")
                break
            end
        end
        --log(cardsoffered)
        n = n - 1
        if n == 0 then
            for _,o in pairs(cardsoffered[color]) do
                if o ~= obj.guid then
                    local card = getObjectFromGUID(o)
                    if card then
                        card.locked = false
                        card.clearButtons()
                        card.setPosition(pilepos)
                        if flip then
                            card.flip()
                        end
                    end
                end
            end
            cardsoffered[color] = {nil}
        end
        obj.locked = false
        obj.clearButtons()
        obj.setRotation(brot)
        resolvef(obj)
    end
    function lockAndButton(obj)
        obj.locked = true
        obj.createButton({click_function='resolveOfferCardsEffect' .. color,
            function_owner=self,
            position={0,20,0},
            label=label,
            tooltip=toolt,
            font_size=300,
            font_color={0,0,0},
            color={1,1,1},
            width=650,height=650})
    end
    local stepPos = function(step,pos,color,posini)
        if color == "White" then
            pos.z = pos.z + 4
        elseif color == "Blue" then
            pos.z = pos.z - 4
        else
            pos.x = pos.x + 4
        end
        step = step + 1
        if step > 6 then
            step = 0
            if color == "White" then
                pos.z = posini
                pos.x = pos.x + 6
            elseif color == "Blue" then
                pos.z = posini
                pos.x = pos.x - 6
            else
                pos.x = posini
                pos.z = pos.z - 6
            end
        end
        return step,pos
    end
    local step = 0
    for _,o in pairs(pile.getObjects()) do
        if not guids or #guids == pile.getQuantity() then
            table.insert(cardsoffered[color],o.guid)
            pile.takeObject({position = pos,
                guid = o.guid,
                flip = flip,
                smooth = true,
                callback_function = lockAndButton})
            step,pos = stepPos(step,pos,color,posini)
            if pile.remainder and #guids ~= #cardsoffered[color] then
                table.insert(cardsoffered[color],pile.remainder.guid)
                pile.remainder.setPositionSmooth(pos)
                if flip then
                    pile.remainder.flip()
                end
                lockAndButton(pile.remainder)
                break
            end
        else
            for _,p in pairs(guids) do
                if p == o.guid then
                    table.insert(cardsoffered[color],o.guid)
                    pile.takeObject({position = pos,
                        guid = o.guid,
                        flip = flip,
                        smooth = true,
                        callback_function = lockAndButton})
                    step,pos = stepPos(step,pos,color,posini)
                    break
                end
            end
        end
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

function promptDiscard(color,handobjects,n,pos,flip,label,tooltip,triggerf,args,buttoncolor)
    if not handobjects then
        handobjects = Player[color].getHandObjects()
    end
    if not n then
        n = 1
    elseif #handobjects > 0 then
        n = math.min(n,#handobjects)
    end
    if n < 1 then
        return nil
    end
    if not pos then
        pos = getObjectFromGUID(playerBoards[color]).positionToWorld(pos_discard)
    end
    if not label then
        label = "Discard"
    end
    if not tooltip then
        tooltip = "Discard this card."
    end
    if #handobjects == n then
        for i = 1,n do
            handobjects[i].setPosition(pos)
            if triggerf and args and args == "self" then
                triggerf(handobjects[i],i,color)
            elseif triggerf and args then
                triggerf(args)
            elseif triggerf then
                triggerf()
            end
        end
    else
        for i,o in pairs(handobjects) do
            _G["discardCard" .. color .. o.guid] = function(obj)
                n = n-1
                obj.clearButtons()
                if n == 0 then
                    for _,p in pairs(handobjects) do
                        p.clearButtons()
                    end
                end
                if flip then
                    obj.flip()
                end
                if pos ~= "Stay" then
                    obj.setPosition(pos)
                elseif pos then
                    responses[color] = obj
                    --log(responses)
                end
                if triggerf and args and args == "self" then
                    triggerf(obj,i,color)
                elseif triggerf and args then
                    triggerf(args)
                elseif triggerf then
                    triggerf()
                end
            end
            o.createButton({click_function="discardCard" .. color .. o.guid,
                function_owner=self,
                position={0,22,0},
                label=label,
                tooltip=tooltip,
                font_size=250,
                font_color="Black",
                color=buttoncolor or {1,1,1},
                width=750,height=450})
        end
    end
end

function gainShard(color,zoneGUID,n)
    if not n then
        n = 1
    end
    if color then
        for i=1,n do
            getObjectFromGUID(shardguids[color]).Call('add_subtract')
            log("Player " .. color .. " gained a shard.")
            printToColor("You gained a shard!",color,color)
        end
    else
        local shard = getObjectFromGUID(shardGUID)
        if not shard then
            broadcastToAll("ERRROR: Shard was not found.")
            return nil
        elseif not zoneGUID then
            broadcastToAll("ERRROR: Zone to put shard was not found.")
            return nil
        end
        local content = get_decks_and_cards_from_zone(zoneGUID)
        if content[1] then
            for _,o in pairs(content) do
                if o.getName() == "Shard" then
                    for i=1,n do
                        o.Call('add_subtract')
                        log("Shard added to zone that already had shards, with guid " .. zoneGUID)
                    end
                    return nil
                end
            end
        end
        local newshard = shard.clone({position = getObjectFromGUID(zoneGUID).getPosition()})
        Wait.time(function() for i=1,n do newshard.Call('add_subtract') end end,0.2)
        log("First shard added to zone with guid " .. zoneGUID)
    end
end

function contestOfChampions(color,n,winf,epicness)
    broadcastToAll("Contest of Champions for " .. color .. "!")
    if not n then
        n = 2
    end
    local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
    local highscore = 0
    if not herodeck[1] then
        broadcastToAll("No hero deck found.")
        return nil
    elseif herodeck[1].tag == "Deck" then
        local herodeckcards = herodeck[1].getObjects()
        n = math.min(n,#herodeckcards)
        for i=1,n do
            local score = 0
            local doubled = false
            for _,k in pairs(herodeckcards[i].tags) do
                if k:find("HC:") and k:gsub("HC:","") == color then
                    doubled = true
                end
                if k:find("Cost:") then
                    score = k:gsub("Cost:","")
                    score = tonumber(score)
                end
            end
            if doubled then
                score = score*2
            end
            if score > highscore then
                highscore = score
            end
        end
    else
        highscore = hasTag2(herodeck[1],"Cost:") or 0
        if hasTag2(herodeck[1],"HC:") and hasTag2(herodeck[1],"HC:") == color then
            highscore = highscore*2
        end
    end
    local contestResult = {}
    for _,o in pairs(Player.getPlayers()) do
        contestResult[o.color] = false
    end
    contestResult["Evil"] = false
    responses = {["Evil"] = highscore}
    if table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))["The Grandmaster"] and epicness then
        responses["Evil"] = responses["Evil"] + 2
    end
    for _,o in pairs(Player.getPlayers()) do
        promptDiscard(o.color,nil,1,"Stay",nil,"Choose","Choose for Contest of Champions.")
        _G["pickTopCard" .. o.color] = function(obj)
            local deck = obj.Call('returnDeck')
            if not deck[1] then
                broadcastToColor("No top card found!",obj.getName(),obj.getName())
                return nil
            elseif deck[1].tag == "Deck" then
                local doubled = false
                for _,k in pairs(deck[1].getObjects()[1].tags) do
                    if k:find("Cost:") then
                       responses[obj.getName()] = tonumber(k:match("%d+"))
                       break
                    end
                    if k:find("HC:") and k:gsub("HC:","") == color then
                        doubled = true
                    end
                end
                if responses[obj.getName()] and doubled == true then
                    responses[obj.getName()] = responses[obj.getName()]*2
                elseif not responses[obj.getName()] then
                    responses[obj.getName()] = 0
                end
            else
                if hasTag2(deck[1],"Cost:") then
                    responses[obj.getName()] = hasTag2(deck[1],"Cost:")
                    if hasTag2(deck[1],"HC:",4) and hasTag2(deck[1],"HC:",4)  == color then
                        responses[obj.getName()] = responses[obj.getName()]*2
                    end
                else
                    responses[obj.getName()] = 0
                end
            end
            local hand = Player[obj.getName()].getHandObjects()
            for _,p in pairs(hand) do
                p.clearButtons()
            end
            for i,b in pairs(obj.getButtons()) do
                if b.click_function == "pickTopCard" .. obj.getName() then
                    obj.removeButton(i-1)
                end
            end
        end
        getObjectFromGUID(playerBoards[o.color]).createButton({click_function="pickTopCard" .. o.color,
            function_owner=self,
            position={-0.957, 1.178, 0.222},
            label="Choose",
            tooltip="Choose for Contest of Champions.",
            font_size=250,
            font_color={0,0,0},
            color={1,1,1},
            width=750,height=450}) 
    end
    local contestFulfilled = function()
        local c = 0
        for _,o in pairs(responses) do
            c = c + 1
        end
        if c == #Player.getPlayers() + 1 then
            return true
        else
            return false
        end
    end
    local resolveContest = function()
        log("resolving contest")
        log(responses)
        local maxscore = 0
        for i,o in pairs(responses) do
            if not tonumber(o) then
                local score = hasTag2(o,"Cost:") or 0
                if hasTag2(o,"HC:",4) and hasTag2(o,"HC:",4) == color then
                    score = score*2
                end
                responses[i] = score
                if score > maxscore then
                    maxscore = score
                end
            elseif o > maxscore then
                maxscore = o
            end
        end
        for i,o in pairs(contestResult) do
            if responses[i] == maxscore then
                contestResult[i] = true
            end
        end
        for _,o in pairs(Player.getPlayers()) do
            local playerBoard = getObjectFromGUID(playerBoards[o.color])
            for i,b in pairs(playerBoard.getButtons()) do
                if b.click_function == "pickTopCard" .. o.color then
                    playerBoard.removeButton(i-1)
                    break
                end
            end
        end
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        if herodeck[1].tag == "Deck" then
            bump(herodeck[1],n+2)
            local pos = herodeck[1].getPosition()
            local logCard = function(obj)
                local cost = hasTag2(obj,"Cost:") or 0
                local col = hasTag2(obj,"HC:",4) or "Grey"
                printToAll(obj.getName() .. " with cost of " .. cost .. " and color " .. col .. " was revealed from the hero deck.")
            end
            for i=1,n do
                herodeck[1].takeObject({position = pos,
                    smooth = true,
                    callback_function = logCard})
                pos.y = pos.y + 1
            end
        end
        log(contestResult)
        winf(contestResult)
    end
    Wait.condition(resolveContest,contestFulfilled)
end

function getStrikeloc(mmname,alttable)
    if not alttable then
        alttable = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',mmLocations),true)
    end
    local strikeloc = nil
    if alttable[mmname] == mmZoneGUID then
        strikeloc = strikeZoneGUID
    else
        for i,o in pairs(allTopBoardGUIDS) do
            if o == alttable[mmname] then
                strikeloc = allTopBoardGUIDS[i-1]
                break
            end
        end
    end
    return strikeloc
end

function getVillainsCityZone(obj)
    for _,o in pairs(current_city) do
        local citycontent = get_decks_and_cards_from_zone(o)
        if citycontent[1] then
            for _,p in pairs(citycontent) do
                if p.guid == obj.guid then
                    return o
                end
            end
        end
    end
    broadcastToAll("Villain " .. obj.getName() .. " not found in city?")
    return nil
end

function returnTimeIncursions()
    if timeIncursions then
        return timeIncursions
    else
        return {}
    end
end

function resolveVillainEffect(cards,move,player_clicker_color)
    local name = cards[1].getName()
    local group = hasTag2(cards[1],"Group:")
    --for henchmen, check for Henchmen tag
    if group then
        if group == "A.I.M., Hydra Offshoot" then
            if name == "Mentallo" then
                if move == "Ambush" then
                    getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(escape_zone_guid).getPosition(),
                        flip = true,
                        smooth = true})
                    broadcastToAll("Mentallo captures an officer for each two HYDRA levels. Unscripted yet.")
                    --script hydra levels properly, somewhere else
                elseif move == "Fight" then
                    local citycontent = get_decks_and_cards_from_zone(getVillainsCityZone(cards[1]))
                    local officers = {}
                    for _,o in pairs(citycontent) do
                        if o.hasTag("Officer") then
                            table.insert(officers,o)
                        end
                    end
                    promptDiscard(player_clicker_color,officers,1,nil,nil,"Gain","Gain this officer.")
                    --officers need to move from city to be clearly distinguishable
                    --not chosen officers need to be KO'd
                end
            elseif name == "Graviton" then
                if move == "Ambush" then
                    getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(escape_zone_guid).getPosition(),
                        flip = true,
                        smooth = true})
                    --hero cost increase for hydra levels
                end
            elseif name == "Superia" then
                if move == "Ambush" then
                    getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(escape_zone_guid).getPosition(),
                        flip = true,
                        smooth = true})
                    local hydralevel = twistsresolved --wrong, dummy value for now
                    for _,o in pairs(Player.getPlayers()) do
                        local hand = o.getHandObjects()
                        if hand[2] then
                            local rand = math.random(#hand)
                            if not hasTag2(rand,"Cost:") or hasTag2(rand,"Cost:") < hydralevel then
                                rand.setPosition(getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard))
                            end
                        elseif hand[1] and (not hasTag2(hand[1],"Cost:") or hasTag2(hand[1],"Cost:") < hydralevel) then
                            hand[1].setPosition(getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard))
                        end
                    end
                end
            elseif name == "Taskmaster" then
                if move == "Ambush" then
                    getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(escape_zone_guid).getPosition(),
                        flip = true,
                        smooth = true})
                elseif move == "Fight" or move == "Escape" then
                    broadcastToAll("Each player must reveal as many colors (incl grey) as the hydra level or gain a wound. Unscripted.")
                end
            end
        end
        if group == "Army of Evil" then
            if name == "Blackout" then
                if move == "Ambush" then
                    for _,o in pairs(revealCardTrait("Blue")) do
                        promptDiscard(o.color)
                    end
                elseif move == "Fight" then
                    getObjectFromGUID(playerBoards[player_clicker_color]).Call('click_draw_cards',2)
                end
            elseif name == "Klaw" then
                if move == "Ambush" then
                    --capture hero
                elseif move == "Fight" then
                    --gain hero
                end
            elseif name == "Mister Hyde" then
                if move == "Fight" then
                    --ko one of your heroes (incl in play, but only heroes)
                end
            elseif name == "Count Nefaria" then
                if move == "Ambush" or move == "Escape" then
                    local hccolors = {
                        ["Red"] = 0,
                        ["Yellow"] = 0,
                        ["Green"] = 0,
                        ["Silver"] = 0,
                        ["Blue"] = 0
                    }
                    for _,o in pairs(Player.getPlayers()) do
                        local hand = o.getHandObjects()
                        if hand[1] then
                            for _,obj in pairs(hand) do
                                if hasTag2(obj,"HC:") then
                                    hccolors[hasTag2(obj,"HC:")] = 1
                                end
                            end
                        end
                    end
                    local spectrum = 0
                    for _,o in pairs(hccolors) do
                        spectrum = spectrum + o
                    end
                    if spectrum < 5 then
                        dealWounds()
                    end
                end
            elseif name == "Dome of Darkforce" then
                if move == "Fight" then
                    getObjectFromGUID(playerBoards[player_clicker_color]).Call('click_draw_cards',2)
                end
            end
        end
    end
end