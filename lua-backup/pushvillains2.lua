function onLoad()
    --starting values
    twistsresolved = 0
    twistsstacked = 0
    strikesresolved = 0
    strikesstacked = 0
    
    villainstoplay = 0
    cityPushDelay = 0
    
    loadGUIDs()
    
    createButtons()
    
    setNotes("[FF0000][b]Scheme Twists resolved:[/b][-] 0\r\n\r\n[ffd700][b]Master Strikes resolved:[/b][-] 0")
end

function loadGUIDs()    
    --import guids
    setupGUID = "912967"
    
    local guids3 = {
        "playerBoards",
        "vpileguids",
        "playguids",
        "shardguids",
        "discardguids",
        "handguids",
        "cityguids",
        "drawguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
    
    local guids2 = {
       "city_zones_guids",
       "topBoardGUIDs",
       "allTopBoardGUIDS",
       "pos_vp2",
       "pos_discard",
       "pos_draw",
       "hqguids",
       "hqscriptguids",
       "herocosts"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
        
    local guids1 = {
        "escape_zone_guid",
        "kopile_guid",
        "bszoneguid",
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
        "shardGUID",
        "sidekickZoneGUID",
        "officerZoneGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end    
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

function fetchHQ()
    hqguids_ori = table.clone(hqguids)
    hqguids = merge(hqguids,table.clone(extrahq))
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

function returnVar(var)
    return _G[var]
end

function updateVar(params)
    --log(params.varname)
    --log(params.varvalue)
    _G[params.varname] = params.varvalue
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

function getBystander(color)
    click_rescue_bystander(nil,color)
end

function click_get_wound2(params)
    click_get_wound(params.obj,
        params.color,
        params.alt_click,
        params.top)
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

function gainBystander(color)
    click_rescue_bystander(nil,color)
end

function dealWounds(top)
    for i,_ in pairs(playerBoards) do
        if Player[i].seated == true then
            click_get_wound(getObjectFromGUID(woundsDeckGUID),i,nil,top)
        end
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
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
            --log("#")
            --log(i .. o)
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

function updateCity(params)
    local name = params.name or "current_city"
    _G[name] = table.clone(params.newcity)
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
        if targetZone.guid == escape_zone_guid and schemeParts and schemeParts[1] == "Alien Brood Encounters" and obj.hasTag("Alien Brood") then
            obj.removeTag("Alien Brood")
            obj.flip()
            local result = resolve_alien_brood_scan(obj,true)
            if not result then
                obj = nil
            end
        end
        if obj then
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
                    gainShard(nil,mmZoneGUID)
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
                    mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 0})
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
                    if schemeParts and schemeParts[1] == "Change the Outcome of WWII" then
                        local scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
                        local wwiiInvasion = scheme.Call('getInvasion')
                        if not wwiiInvasion or wwiiInvasion == false then
                            scheme.Call('setInvasion',true)
                            getObjectFromGUID(twistPileGUID).takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
                                smooth=false,
                                callback_function = function(obj)
                                    obj.setName("Conquered Capital")
                                end})
                            broadcastToAll("The Axis successfully conquered this country!")
                        end
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
    Wait.time(updatePower,1.5)
end

function shift_to_next2(params)
    shift_to_next(params.objects,params.targetZone,params.enterscity,params.schemeParts)
end

function click_draw_villain(obj,vildeckguid)
    local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
    pos.y = pos.y + 5
    if not vildeckguid then
        vildeckguid = villainDeckZoneGUID
    end
    local schemeParts = getObjectFromGUID(setupGUID).Call('returnSetupParts')
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

function addBystanders2(params)
    addBystanders(params.cityspace,params.face,params.posabsolute,params.pos)
end

function push_all2(newcity)
    push_all(table.clone(newcity))
end

function push_all(city)
    --if all guids are still there, cards will be entering the city
    --this will cause issues if multiple cards enter at the same time
    --that should therefore never happen!
    if not city then
        city = table.clone(current_city)
    end
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
        local schemeParts = getObjectFromGUID(setupGUID).Call('returnSetupParts')
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
            if cityEntering then
                cards[1].addTag("Alien Brood")
            end
            if city then
                push_all(city)
            end
            for _,o in pairs(cards) do
                if o.hasTag("Alien Brood") and targetZone.guid ~= escape_zone_guid then
                    targetZone.editButton({index = 0,
                        label = "Scan",
                        click_function = 'scan_villain',
                        tooltip = "Scan the face down card in this city space for 1 attack."})
                end
            end
            return shift_to_next(cards,targetZone,cityEntering,schemeParts)
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
            if bs == true or vw == true then
                local villainfound = false
                while villainfound == false do
                    local citycontent = get_decks_and_cards_from_zone(city[1])
                    if citycontent[1] then
                        for _,o in pairs(citycontent) do
                            if o.hasTag("Villain") or o.hasTag("Mastermind") then
                                villainfound = true
                                targetZone = getObjectFromGUID(city[1])
                                break
                            end
                        end
                    end
                    if villainfound == false then
                        table.remove(city,1)
                    end
                    if not city[1] then
                        --if the city is empty:
                        villainfound = true
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

function click_push_villain_into_city(obj,player_clicker_color)
-- when moving the villain deck buttons, change the first guid to a new scripting zone
    cityPushDelay = cityPushDelay + 1
    checkCityContent(player_clicker_color)
end

function checkCityContent(player_clicker_color,altcity)
    if cityPushDelay > 1 then
        Wait.time(checkCityContent,cityPushDelay)
        cityPushDelay = cityPushDelay - 1
        return nil
    else
        Wait.time(function() cityPushDelay = cityPushDelay - 1 end,1)
    end
    if not current_city then
        current_city = table.clone(city_zones_guids)
    end
    local city_topush = table.clone(current_city)
    local schemeParts = getObjectFromGUID(setupGUID).Call('returnSetupParts')
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
        if schemeParts[1] == "Five Families of Crime" then
            local targetguid = callGUID("fiveFamiliesTargetZone",1)
            if not targetguid then
                return nil
            else
                city_topush = {city_zones_guids[1],targetguid}
            end
        end
        if schemeParts[1] == "Smash Two Dimensions Together" then
            if altcity and altcity == "Top" then
                city_topush = table.clone(current_city2)
            elseif altcity and altcity == "Bottom" then
                city_topush = table.clone(current_city)
            else
                printToAll("Error with scripting the two dimensions")
            end
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
    for i,o in pairs(city_zones_guids) do
        local cityobjects = get_decks_and_cards_from_zone(o)
        for _,object in pairs(cityobjects) do
            local index = nil
            if object.getButtons() then
                for i2,b in pairs(object.getButtons()) do
                    if b.click_function == "updatePower" then
                        index = i2
                        break
                    end
                end
            elseif getObjectFromGUID(o).getButtons() then
                for i2,b in pairs(getObjectFromGUID(o).getButtons()) do
                    if b.click_function == "updatePower" then
                        index = i2
                        break
                    end
                end
            end
            if index then
                if object.hasTag("Corrupted") then
                    powerButton({obj= object, label = twistsstacked+2,zoneguid = o})
                elseif object.hasTag("Possessed") or object.hasTag("Killbot") then    
                    powerButton({obj= object, label = twistsstacked,zoneguid = o, tooltip = "This bystander is a Killbot and has power equal to the number of twists stacked next to the scheme."})
                elseif object.hasTag("Brainwashed") then
                    powerButton({obj= object, label = twistsstacked+3,zoneguid = o})
                elseif object.hasTag("Phalanx-Infected") then
                    powerButton({obj= object, label = math.floor(twistsstacked/2)+hasTag2(object,"Cost:"),zoneguid = o})
                elseif object.getName() == "Smugglers" then
                    powerButton({obj= object, label = "+" .. strikesresolved,id="striker",zoneguid = o})
                elseif object.hasTag("Khonshu Guardian") then
                    if i % 2 == 0 then
                        powerButton({obj= object, label = hasTag2(object,"Cost:")*2,zoneguid = o})
                    else
                        powerButton({obj= object, label = hasTag2(object,"Cost:"),zoneguid = o})
                    end
                elseif noMoreMutants and object.getName() == "Scarlet Witch (R)" then
                    powerButton({obj= object, label = hasTag2(object,"Cost:") + 4,zoneguid = o})
                elseif object.getName() == "Jean Grey (DC)" and object.hasTag("VP4") then
                    if not goblincount then
                        goblincount = 0
                    end
                    powerButton({obj= object, label = hasTag2(object,"Cost:") + goblincount,zoneguid = o})
                elseif object.getName() == "S.H.I.E.L.D. Assault Squad" or object.hasTag("Ambition") or object.hasTag("Super Sentinel") then
                    powerButton({obj= object, label = "+" .. twistsstacked,id="twistsStacked",zoneguid = o})
                elseif object.getName() == "Graveyard" and object.hasTag("Location") then
                    for _,obj in pairs(cityobjects) do
                        if obj.hasTag("Villain") then
                            powerButton({obj= object, label = "+" .. 2, id = "villainPresent",tooltip = "Graveyard gets +2 if there's a villain there.",zoneguid = o})
                            return nil
                        end
                    end
                    powerButton({obj= object, label = "",id = "villainPresent",tooltip = "Graveyard gets +2 if there's a villain there.",zoneguid = o})
                elseif object.getName() == "Evolved Ultron" then
                    local ultronpower = 0
                    local evolutionPile = get_decks_and_cards_from_zone(twistZoneGUID)
                    local evolutionPileSize = 0
                    if evolutionPile[1] then
                        if evolutionPile[1].tag == "Deck" then
                            evolutionPileSize = #evolutionPile[1].getObjects()
                        elseif evolutionPile[1] then
                            evolutionPileSize = 1
                        end
                    else
                        return nil
                    end
                    local evolutionColors = {
                            ["HC:Red"] = false,
                            ["HC:Green"] = false,
                            ["HC:Yellow"] = false,
                            ["HC:Blue"] = false,
                            ["HC:Silver"] = false
                    }
                    if evolutionPileSize > 1 then
                        for _,o2 in pairs(evolutionPile[1].getObjects()) do
                            for _,k in pairs(o2.tags) do
                                if k:find("HC:") then
                                    evolutionColors[k] = true
                                end
                                if k:find("HC1:") or k:find("HC2:") then
                                    evolutionColors["HC:".. k:sub(5)] = true
                                end
                            end
                        end
                    else
                        for _,o2 in pairs(evolutionPile[1].getTags()) do
                            if o2:find("HC:") then
                                evolutionColors[o2] = true
                            end
                            if o2:find("HC1:") or o2:find("HC2:") then
                                evolutionColors["HC:".. o2:sub(5)] = true
                            end
                        end
                    end
                    for i2,o2 in pairs(hqguids) do
                        local herocard = getObjectFromGUID(o2).Call('getHeroUp')
                        if herocard then
                            for _,tag in pairs(herocard.getTags()) do
                                if tag:find("HC:") then
                                    if evolutionColors[tag] == true then
                                        ultronpower = ultronpower + 1
                                        break
                                    end
                                end
                                if tag:find("HC1:") or tag:find("HC2:") then
                                    if evolutionColors["HC:".. tag:sub(5)] == true then
                                        ultronpower = ultronpower + 1
                                        break
                                    end
                                end
                            end
                        else
                            broadcastToAll("Hero in hq space " .. i2 .. " is missing?")
                        end
                    end
                    powerButton({obj= object, 
                        label = ultronpower,
                        zoneguid = o,
                        id = "empowered",
                        tooltip = "Empowered for colors of heroes in the Evolution pile."})
                end
            end
        end
    end
end

function powerButton(params)
    local obj = params.obj
    local label = tostring(params.label)
    local tooltip = params.tooltip or "Unidentified bonus."
    local id = params.id or "base"
    local click_f = params.click_f or 'updatePower'
    local otherposition = params.otherposition
    local color = params.color or "Red"
    local zoneguid = params.zoneguid
    if zoneguid and zoneguid == city_zones_guids[1] then
        zoneguid = nil
    end
    if not obj or not label then
        broadcastToAll("Error: Missing argument to card boost.")
        return nil
    end
    
    local pos = otherposition
    if not otherposition then
        pos = {0,22,0}
    end
    local buttonindex = nil
    local toolt_orig = {}
    if obj.getButtons() then
        for i,o in pairs(obj.getButtons()) do
            if o.click_function == click_f then
                buttonindex = i - 1
                if o.tooltip:find("\n") then
                    for t in string.gmatch(o.tooltip,"[^\n]+") do
                        local tip = (t:gsub("%[.*",""))
                        local box = (t:gsub(".*%[",""))
                        box = (box:gsub("%]",""))
                        toolt_orig[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                    end
                else
                    local tip = (o.tooltip:gsub("%[.*",""))
                    local box = (o.tooltip:gsub(".*%[",""))
                    box = (box:gsub("%]",""))
                    toolt_orig[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                end
                break
            end
        end
    elseif zoneguid then
        local butt = getObjectFromGUID(zoneguid).getButtons()
        for i,o in pairs(butt) do
            if o.click_function ~= "click_fight_villain" and o.click_function ~= "scan_villain" then
                buttonindex = i - 1
                if o.tooltip:find("\n") then
                    for t in string.gmatch(o.tooltip,"[^\n]+") do
                        local tip = (t:gsub("%[.*",""))
                        local box = (t:gsub(".*%[",""))
                        box = (box:gsub("%]",""))
                        toolt_orig[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                    end
                else
                    local tip = (o.tooltip:gsub("%[.*",""))
                    local box = (o.tooltip:gsub(".*%[",""))
                    box = (box:gsub("%]",""))
                    toolt_orig[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                end
                break
            end
        end
    end
    --log(toolt_orig)
    if not toolt_orig then
        toolt_orig = {[id] = {label,tooltip}}
    else
        if toolt_orig[id] and tooltip == "Unidentified bonus." then
            tooltip = toolt_orig[id][2]
        end
        toolt_orig[id] = {label,tooltip}
    end
    local lab,tool = getObjectFromGUID(mmZoneGUID).Call('updateLabel',toolt_orig)
    if zoneguid then
        getObjectFromGUID(zoneguid).Call('updateZoneBonuses',toolt_orig)
        if lab == "" and buttonindex then
            getObjectFromGUID(zoneguid).removeButton(buttonindex)
        elseif buttonindex then
            getObjectFromGUID(zoneguid).editButton({index = buttonindex, label = lab, tooltip = tool})
        else
            getObjectFromGUID(zoneguid).createButton({click_function='updatePower',
                function_owner=getObjectFromGUID(zoneguid),
                position={0,0,0},
                rotation={0,180,0},
                scale = {1,1,0.5},
                label=lab,
                tooltip=tool,
                font_size=300,
                font_color=color,
                color={0,0,0,0.75},
                width=250,height=150})
        end
    elseif otherposition or not buttonindex then
        obj.createButton({click_function=click_f,
            function_owner=self,
            position=pos,
            label=lab,
            tooltip=tool,
            font_size=500,
            font_color=color,
            color={0,0,0,0.75},
            width=250,height=250})
    else
        obj.editButton({index = buttonindex,
            label = lab,
            tooltip = tool})
    end
end

function cityLowTides()
    lowtideguids = {"d30aa1","bd3ef1"}
    for i = 1,2 do
        table.insert(current_city,lowtideguids[i])
        _G["click_fight_lowtide" .. i] = function(obj,color)
            getObjectFromGUID(city_zones_guids[2]).Call('click_fight_villain_call',{obj = obj, color = color, otherguid = lowtideguids[i]})
        end
        getObjectFromGUID(lowtideguids[i]).createButton({
            click_function="click_fight_lowtide1", function_owner=self,
            position={0,-0.4,-0.4}, rotation = {0,180,0}, label="Low Tide", 
            tooltip = "Fight the villain in this city space!", color={1,0,0,0.9}, 
            font_color = {0,0,0}, width=750, height=150,
            font_size = 75
        })
    end
end

function smashTwoDimensions()
    table.remove(current_city,2)
    table.remove(current_city,2)
    current_city2 = {city_zones_guids[1]}
    for i = 1,3 do
        table.insert(current_city2,allTopBoardGUIDS[10-i])
    end
    villainDeckZoneGUID = city_zones_guids[3]
    local butt = self.getButtons()
    for i,o in pairs(butt) do
        if o.click_function == "click_push_villain_into_city" then
            self.removeButton(i-1)
            break
        end
    end
    pushTopDimension = function()
        cityPushDelay = cityPushDelay + 1
        checkCityContent(nil,"Top")
    end
    pushBottomDimension = function()
        cityPushDelay = cityPushDelay + 1
        checkCityContent(nil,"Bottom")
    end
    self.createButton({
        click_function="pushTopDimension", function_owner=self,
        position={0,1,-1.2}, label="Top City", color={0.8,1,0.8,1}, width=2000, height=1000,
        tooltip = "Push villains into the top city dimension or charge once",
        font_size = 250
    })
    self.createButton({
        click_function="pushBottomDimension", function_owner=self,
        position={0,1,1.2}, label="Bottom City", color={1,0.8,1,1}, width=2000, height=1000,
        tooltip = "Push villains into the bottom city dimension or charge once",
        font_size = 250
    })
end

function playVillains(options)
    --plays n cards from the villain deck (default n=1)
    --the first only if condition_f is met (optional)
    if options then
        n = options.n
        vildeckguid = options.vildeckguid
        condition_f = options.condition_f
        fsourceguid = options.fsourceguid
    end
    if not n then
        n = 1
    end
    if not vildeckguid then
        vildeckguid = villainDeckZoneGUID
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
            click_draw_villain(nil,vildeckguid)
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
            elseif vildeck then
                if villainstoplay > 1 then
                    broadcastToAll("Villain deck ran out, so " .. villainstoplay-1 .. " cards could not be played.")
                    villainstoplay = 1
                end
                Wait.condition(drawVillain,villainGone)
            else
                broadcastToAll("Villain deck ran out!!")
                return nil
            end
        end
        if condition_f and fsourceguid then
            Wait.condition(playVillain,
                function()
                    return getObjectFromGUID(fsourceguid).Call(condition_f) 
                end)
        elseif condition_f then
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

function unveilScheme()
    --broadcastToAll("Unveiling a random scheme is not scripted yet!!!")
    local unveiledschemes = {
        "...Control the Mutant Messiah",
        "...Open Rifts to Future Timelines",
        "...Reveal the Heroes' Evil Clones",
        "...Unleash an Anti-Mutant Bioweapon"}
    local unveiled = table.remove(unveiledschemes,math.random(#unveiledschemes))
    local schemePile = getObjectFromGUID(schemePileGUID)
    local schemeZone = getObjectFromGUID(schemeZoneGUID)
    local pos = schemeZone.getPosition()
    pos.y = pos.y + 2
    for _,o in pairs(schemePile.getObjects()) do
        if string.lower(o.name) == string.lower(unveiled) then
            schemePile.takeObject({position=pos,
                guid=o.guid,
                smooth=false,
                flip=true})
        end
    end
    getObjectFromGUID(setupGUID).Call('unveiledScheme',unveiled)
    if unveiled == "...Control the Mutant Messiah" then
        local heroPile = getObjectFromGUID(heroPileGUID)
        heroPile.randomize()
        heroPile.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            flip = true,
            smooth = false,
            callback_function = function(obj) obj.randomize() end})
            broadcastToAll("Random hero shuffled into a Mutant Messiah stack!")
    end
    if unveiled == "...Open Rifts to Future Timelines" then
        local villainPile = getObjectFromGUID(villainPileGUID)
        villainPile.randomize()
        villainPile.takeObject({position = getObjectFromGUID(villainDeckZoneGUID).getPosition(),
            flip = true,
            smooth = false})
        Wait.time(function() get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].randomize() end,1)
        broadcastToAll("Random villain group shuffled into the Villain deck!")
    end
    twistsresolved = twistsresolved - 1
    Wait.time(click_push_villain_into_city,1)
end

function koCard(obj,smooth)
    if smooth then
        obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
    else
        obj.setPosition(getObjectFromGUID(kopile_guid).getPosition())
    end
end

function stackTwist(obj)
    obj.setPosition(getObjectFromGUID(twistZoneGUID).getPosition())
    twistsstacked = twistsstacked + 1
    return twistsstacked
end

function scriptedSchemes(name)
    local scripted = {"Age of Ultron",
        "Annihilation: Conquest",
        "Anti-Mutant Hatred",
        "Asgardian Test of Worth",
        "Avengers vs. X-Men",
        "Bathe Earth In Cosmic Rays",
        "Brainwash the Military",
        "Break the Planet Asunder",
        "Breach Parallel Dimensions",
        "Build an Army of Annihilation",
        "Build an Underground MegaVault Prison",
        "Cage Villains in Power-Suppressing Cells",
        "Capture Baby Hope",
        "Change the Outcome of WWII",
        "Claim Souls for Demons",
        "Clash of the Monsters Unleashed",
        "Corrupt the Next Generation of Heroes",
        "Crash the Moon into the Sun",
        "Crown Thor King of Asgard",
        "Crush HYDRA",
        "Cytoplasm Spike Invasion",
        "Crush Them With My Bare Hands",
        "Dark Alliance",
        "Dark Reign of H.A.M.M.E.R. Officers"}
    for _,o in pairs(scripted) do
        if name == o then
            return true
        end
    end
    return false
end

function twistSpecials(cards,city,schemeParts)
    local resp = callGUID("scheme",1).Call('resolveTwist',{twistsresolved = twistsresolved,
        cards = table.clone(cards),
        city = table.clone(city),
        schemeParts = table.clone(schemeParts)})
    return resp
end

function schemeUnfinished()
    if schemeParts[1] == "...Control the Mutant Messiah" then
        cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
        -- local messiahstack = get_decks_and_cards_from_zone(twistZoneGUID)[1]
        -- local toptwo = {
            -- messiahstack.getObjects()[1].guid,
            -- messiahstack.getObjects()[2].guid
            -- }
        -- offerCards({color = Turns.turn_color,
            -- pile = get_decks_and_cards_from_zone(twistZoneGUID)[1],
            -- guids = toptwo,
            -- })
        broadcastToAll("Unscripted scheme twist!")
        return nil
    end
    if schemeParts[1] == "...Open Rifts to Future Timelines" then
        --local rifts = math.abs(get_decks_and_cards_from_zone(topBoardGUIDs[1])[1].getQuantity()) + 1
        cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
        -- local villaindeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        -- if villaindeck.tag == "Card" then
        
        -- else
            -- local villaindeckcontent = villaindeck.getObjects()
            -- local vp = 0
            -- local villains = {}
            -- local hench = {}
            -- local localvp = 0
            -- local localvillain = nil
            -- for i = 1,rifts do
                -- localvp = 0
                -- localvillain = nil
                -- for _,tag in pairs(villaindeckcontent[i].tags) do
                    -- if tag == "Henchmen" then
                        -- table.insert(hench,villaindeckcontent[i].guid)
                    -- end
                    -- if tag == "Villain" then
                        -- localvillain = villaindeckcontent[i].guid
                    -- end
                    -- if tag:find("VP") then
                        -- localvp = tonumber(tag:match("%d+"))
                    -- end
                -- end
                -- if localvillain and localvp == vp then
                    -- table.insert(villains,localvillain)
                -- elseif localvillain and localvp > vp then
                    -- villains = {localvillain}
                    -- vp = localvp
                -- end
                -- if i == #villaindeckcontent then
                    -- break
                -- end
            -- end
        -- end
        broadcastToAll("Unscripted scheme twist!")
        return nil
    end
    if schemeParts[1] == "...Reveal the Heroes' Evil Clones" then
        cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
        broadcastToAll("Unscripted scheme twist!")
        return nil
    end
    if schemeParts[1] == "...Unleash an Anti-Mutant Bioweapon" then
        cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
        broadcastToAll("Unscripted scheme twist!")
        return nil
    end
    if schemeParts[1] == "Cursed Pages of the Darkhold Tome" then
        broadcastToAll("This scheme twist is not scripted yet.")
        return nil
    end
    if schemeParts[1] == "Find the Split Personality Killer" then
        broadcastToAll("Scheme Twist: This Scheme is not scripted yet.")
        return nil
    end
end

function strikeSpecials(cards,city)
    local masterminds = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))
    if not masterminds[1] then
        broadcastToAll("No mastermind specified!")
        return nil
    elseif masterminds[2] then
        broadcastToAll("Multiple masterminds. Resolve effects manually in the order of your choice.")
        local mmpromptzone = getObjectFromGUID(hqscriptguids[3])
        local zshift = 0
        local resolvingStrikes = {}
        for i,o in ipairs(masterminds) do
            resolvingStrikes[i] = i-1
            _G["resolveStrike" .. i] = function()
                mmpromptzone.removeButton(resolvingStrikes[i])
                for i2,o2 in pairs(resolvingStrikes) do
                    if i2 > i then
                        resolvingStrikes[i2] = o2-1
                    end
                end
                local epicness = false
                local mmname = o
                if mmname:find(" %- epic") then
                    mmname = mmname:gsub(" %- epic","")
                    epicness = true
                end
                local proceed = resolveStrike(mmname,epicness,city,cards)
                local butt = mmpromptzone.getButtons()
                if not proceed then
                    cards[1] = nil
                elseif cards[1] and (not butt or (not butt[2] and butt[1].label == o)) then
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

function resolveStrike2(params)
    resolveStrike(params.mmname,params.epicness,params.city,params.cards,params.mmoverride)
end

function resolveStrike(mmname,epicness,city,cards,mmoverride)
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
                promptDiscard({color = o.color,hand = hand})
                broadcastToColor("Master Strike: Discard a hero with cost " .. vp,o.color,o.color)
            end
        end
        return strikesresolved
    end
    local mmloc = nil
    local strikeloc = nil
    if mmoverride then
        mmloc = mmZoneGUID
        strikeloc = strikeZoneGUID 
    else
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        if not mmLocations[mmname] then
            broadcastToAll("Mastermind " .. mmname .. " not found?")
            return nil
        elseif mmLocations[mmname] == mmZoneGUID then
            mmloc = mmZoneGUID
            strikeloc = strikeZoneGUID
        else
            mmloc = mmLocations[mmname]
            for i,o in pairs(allTopBoardGUIDS) do
                if o == mmloc then
                    strikeloc = allTopBoardGUIDS[i-1]
                    break
                end
            end
        end
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
                promptDiscard({color = o.color,
                    hand = hand,
                    pos = getObjectFromGUID(kopile_guid).getPosition(),
                    label = "KO",
                    tooltip = "KO this hero."})
                broadcastToColor("Master Strike: KO a nongrey hero from your hand.",o.color,o.color)
            end
        end
        broadcastToAll("Master Strike: Each player must KO a nongrey hero from their hand, if any.")
        return strikesresolved
    end
    if mmname == "Wasteland Kingpin" then
        local players = revealCardTrait("Yellow")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            promptDiscard({color = o.color,n = #hand})
            local drawfive = function()
                getObjectFromGUID(playerBoards[o.color]).Call('click_draw_cards',5)
            end
            Wait.time(drawfive,1)
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
                            promptDiscard({color = o.color,hand = hand})
                            broadcastToColor("Master Strike: Discard a card with a Recruit icon.",o.color,o.color)
                        end
                    end
                    break
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Template, Infected Sentinel" then
        local players = revealCardTrait("Red")
        broadcastToAll("Master Strike: Each player reveals a red hero or discards a non-grey hero.")
        for i,o in pairs(players) do
            local hand = o.getHandObjects()
            local toTop = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 0 then
                    table.insert(toTop,obj)
                end
            end
            if toTop[1] then
                promptDiscard({color = o.color,
                    hand = toTop})
                broadcastToColor("You had no red heroes so discard a non-grey Hero card.",o.color,o.color)
            end
        end
        return strikesresolved
    end
    if mmname == "'92 Professor X" then
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
            promptDiscard({color = Turns.turn_color,
                hand = otherguids,
                pos = strikeZone.getPosition(),
                label = "Dom",
                tooltip = "Professor X dominates this hero as a telepathic pawn."})
        elseif maxv[1] == maxv[2] then
            local otherguids = {}
            for i,o in pairs(costs) do
                local hero = getObjectFromGUID(hqguids[i]).Call('getHeroUp')
                if o == maxv[1] then
                    table.insert(otherguids,hero)
                end
            end
            promptDiscard({color = Turns.turn_color,
                hand = otherguids,
                n = 2,
                pos = strikeZone.getPosition(),
                label = "Dom",
                tooltip = "Professor X dominates this hero as a telepathic pawn."})
        end
        return strikesresolved
    end
    if mmname:find("Prime Sentinel") then
        for _,p in pairs(Player.getPlayers()) do
            local playerBoard = getObjectFromGUID(playerBoards[p.color])
            local posdiscard = playerBoard.positionToWorld(pos_discard)
            if callGUID("setupParts",2)[5] == "Bastion, Fused Sentinel - epic" then
                posdiscard = getObjectFromGUID(kopile_guid).getPosition()
            end
            local deck = playerBoard.Call('returnDeck')[1]
            local primeSentinelDiscard = function()
                if not deck then
                    deck = playerBoard.Call('returnDeck')[1]
                end
                if deck and deck.tag == "Deck" then
                    for _,tag in pairs(deck.getObjects()[1].tags) do
                        if tag:find("Cost:") and tonumber(tag:match("%d+")) > 0 then
                            deck.takeObject({position = posdiscard,
                                flip = true,
                                smooth = true})
                            break
                        end
                    end
                elseif deck then
                    if hasTag2(deck,"Cost:") and hasTag2(deck,"Cost:") > 0 then
                        deck.setPosition(posdiscard)
                    end
                end
            end
            if deck then
                primeSentinelDiscard()
            else
                playerBoard.Call('click_refillDeck')
                deck = nil
                Wait.time(primeSentinelDiscard,1)
            end
        end
        return strikesresolved
    end
    if mmname == "Nimrod, Future Sentinel" then
        msno(mmname)
        return nil
    end
    if mmname == "Zombie Mr. Sinister" then
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
                promptDiscard({color = o.color,
                    n = sinisterbs})
                broadcastToColor("Master Strike: Discard " .. sinisterbs .. " cards.",o.color,o.color)
            end
        end
        return strikesresolved
    end
    if mmname == "Master Plan" then
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            click_get_wound(nil,o.color)
        end
        return strikesresolved
    end
    if mmname == "Master Mold, Sentinel Factory" then
        msno(mmname)
        return nil
    end
    if mmname == "Mastermind" then
        jasonmastermindStrike = {}
        jasonmastermindCounter = 0
        jasonmastermindValue = 0
        broadcastToAll("Master Strike: Each player simultaneously reveals a non-grey hero. " .. mmname .. " dominates the highest-costing hero (or tied for highest) revealed this way.")
        for _,o in pairs(Player.getPlayers()) do
            function jasonmastermind(card,index,color)
                jasonmastermindStrike[color] = card
                jasonmastermindCounter = jasonmastermindCounter + 1
                jasonmastermindValue = math.max(jasonmastermindValue,hasTag2(card,"Cost:"))
                if jasonmastermindCounter == #Player.getPlayers() then
                    for _,p in pairs(jasonmastermindStrike) do
                        if hasTag2(p,"Cost:") == jasonmastermindValue then
                            p.setPosition(getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                        end
                    end
                end
            end
            local hand = o.getHandObjects()
            if hand[1] then
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if not hasTag2(obj,"HC:") then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                if hand[1] then
                    promptDiscard({color = o.color,
                        hand = hand,
                        pos = "Stay",
                        label = "Reveal",
                        tooltip = "Reveal this card for Mastermind's master strike.",
                        trigger_function = jasonmastermind,
                        args = "self"})
                else
                    jasonmastermindCounter = jasonmastermindCounter +1
                end
            else
                jasonmastermindCounter = jasonmastermindCounter +1
            end
        end
        return strikesresolved
    end
    if mmname == "Machine Man, Sentinel Supreme" then
        local towound = revealCardTrait("Silver")
        for _,o in pairs(towound) do
            click_get_wound(nil,o.color)
            broadcastToAll("Master Strike: Player " .. o.color .. " had no silver heroes and was wounded.")
        end
        return strikesresolved
    end
    if mmname == "Zombie Loki" then
        local towound = revealCardTrait("Green")
        for _,o in pairs(towound) do
            click_get_wound(nil,o.color)
            broadcastToAll("Master Strike: Player " .. o.color .. " had no green heroes and was wounded.")
        end
        return strikesresolved
    end
    if mmname =="Lady Mastermind" then
        ladymastermindStrike = {}
        ladymastermindCounter = 0
        ladymastermindValue = 0
        broadcastToAll("Master Strike: Each player simultaneously reveals a non-grey hero. " .. mmname .. " dominates the highest-costing hero (or tied for highest) revealed this way.")
        for _,o in pairs(Player.getPlayers()) do
            function ladymastermind(card,index,color)
                ladymastermindStrike[color] = card
                ladymastermindCounter = ladymastermindCounter + 1
                ladymastermindValue = math.max(ladymastermindValue,hasTag2(card,"Cost:"))
                if ladymastermindCounter == #Player.getPlayers() then
                    for _,p in pairs(ladymastermindStrike) do
                        if hasTag2(p,"Cost:") == ladymastermindValue then
                            p.setPosition(getObjectFromGUID(getStrikeloc(mmname)).getPosition())
                        end
                    end
                end
            end
            local hand = o.getHandObjects()
            if hand[1] then
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if not hasTag2(obj,"HC:") then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                if hand[1] then
                    promptDiscard({color = o.color,
                        hand = hand,
                        pos = "Stay",
                        label = "Reveal",
                        tooltip = "Reveal this card for Mastermind's master strike.",
                        triggerf = ladymastermind,
                        args = "self"})
                else
                    ladymastermindCounter = ladymastermindCounter +1
                end
            else
                ladymastermindCounter = ladymastermindCounter +1
            end
        end
        return strikesresolved
    end
    if mmname == "God-Emperor" then
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if hand[1] and #hand == 6 then
                broadcastToAll("Master Strike: Player " .. o.color .. " puts two cards from their hand on top of their deck.")
                local pos = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_draw)
                pos.y = pos.y + 2
                promptDiscard({color = o.color,
                    n = 2,
                    pos = pos,
                    flip = true,
                    label = "Top",
                    tooltip = "Put on top of deck."})
            end
        end
        return strikesresolved
    end
    if mmname == "Deadpool" then
        local towound = revealCardTrait({prefix="Cost:",what="Odd"})
        for _,o in pairs(towound) do
            click_get_wound(nil,o.color)
            broadcastToAll("Master Strike: Player " .. o.color .. " had no odd heroes and was wounded.")
        end
        return strikesresolved
    end
    if mmname == "Angela" then
        for _,o in pairs(Player.getPlayers()) do
            local discardguids = {}
            local discarded = getObjectFromGUID(playerBoards[o.color]).Call('returnDiscardPile')
            if discarded[1] and discarded[1].tag == "Deck" then
                for _,c in pairs(discarded[1].getObjects()) do
                    for _,tag in pairs(c.tags) do
                        if tag:find("Cost:") and tonumber(tag:gsub("Cost:","")) > 0 then
                            table.insert(discardguids,c.guid)
                            break
                        end
                    end
                end
                if discardguids[1] and discardguids[2] then
                    offerCards({color = o.color,
                        pile = discarded[1],
                        guids = discardguids,
                        resolve_function = koCard,
                        tooltip = "KO this hero from your discard pile.",
                        label = "KO"})
                    broadcastToColor("Master Strike: Angela KOs a hero that costs 1 or more from your discard pile.",o.color,o.color)
                elseif discardguids[1] then
                    discarded[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                        guid = discardguids[1],
                        smooth = true})
                    broadcastToColor("Master Strike: Angela KOs the only hero that costs 1 or more from your discard pile.",o.color,o.color)
                end
            elseif discarded[1] then
                if hasTag2(discarded[1],"Cost:") and hasTag2(discarded[1],"Cost:") > 0 then
                    koCard(discarded[1])
                    broadcastToColor("Master Strike: Angela KOs the only hero that costs 1 or more from your discard pile.",o.color,o.color)
                end
            end
        end
        return strikesresolved
    end
    if mmname == "Apocalyptic Magneto" then
        local players = revealCardTrait({trait="X-Men",prefix="Team:"})
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            if #hand > 4 then
                broadcastToAll("Master Strike: Player " .. o.color .. " discards down to 4 cards.")
                promptDiscard({color = o.color,
                    n = #hand-4})
            end
        end
        return strikesresolved
    end
    local resp = getObjectFromGUID(strikeloc).Call('resolveStrike',{mmname = mmname,
        epicness = epicness,
        cards = cards,
        city = city,
        strikesresolved = strikesresolved,
        mmloc = mmloc,
        strikeloc = strikeloc})
    return resp
end

function revealCardTrait(params)
    local trait = params.trait -- card tag to look for
    local prefix = params.prefix -- prefix of the tag
    local what = params.what -- other card properties to look for, cf. vocabulary
    local players = params.players -- if not all players are affected
    local excludePlay = params.excludePlay -- exclude cards in play
    if not trait and not prefix then
        trait = params
    end
    if not prefix then
        prefix = "HC:"
    end
    if not what then
        what = "Prefix"
    end
    if not players then
        players = Player.getPlayers()
    end
    if trait:find("|") then
        local traitlist = {}
        for s in string.gmatch(trait,"[^|]+") do
            table.insert(traitlist, s)
        end
        trait = traitlist
    else
        trait = {trait}
    end
    for i,o in ipairs(players) do
        local hand = o.getHandObjects()
        if not excludePlay then
            local content = get_decks_and_cards_from_zone(playguids[o.color])
            if content[1] then
                hand = merge(hand,content)
            end
        end
        if hand[1] then
            for _,h in pairs(hand) do
                for _,value in pairs(trait) do
                    if what == "Prefix" then
                        if hasTag2(h,prefix) and hasTag2(h,prefix) == value then
                            players[i] = nil
                            break
                        end
                    elseif what == "Tag" then
                        if h.hasTag(value) then
                            players[i] = nil
                            break
                        end
                    elseif what == "Namepart" then
                        if h.getName():find(value) then
                            players[i] = nil
                            break
                        end
                    elseif what == "Name" then
                        if h.getName() == value then
                            players[i] = nil
                            break
                        end
                    elseif what == "Cost" then
                        if hasTag2(h,prefix) and hasTag2(h,prefix) > value then
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
    end
    local result = {}
    for _,p in pairs(players) do
        if p then
            table.insert(result,p)
        end
    end
    return result
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
    --rampages found so far:
    --wolverine, colossus, hulk, void, thor, deadpool, illuminati
    local players = Player.getPlayers()
    local names = {name}
    if name == "wolverine" then
        table.insert(names,"old man logan")
    elseif name == "hulk" then
        table.insert(names,"nul, breaker of worlds")
        table.insert(names,"maestro")
    elseif name == "deadpool" then
        table.insert(names,"venompool")
    end
    for i,o in pairs(players) do
        local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
        for _,p in pairs(names) do
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    if string.lower(k.name):find(p) then
                        players[i] = nil
                        break
                    end
                    for _,tag in pairs(k.tags) do
                        if string.lower(tag):find(p) then
                            table.remove(players,i)
                            break
                        end
                    end
                end
            elseif vpilecontent[1] and string.lower(vpilecontent[1].getName()):find(p) then
                table.remove(players,i)
            elseif vpilecontent[1] and vpilecontent[1].getTags() then
                for _,tag in pairs(vpilecontent[1].getTags()) do
                    if string.lower(tag):find(p) then
                        players[i] = nil
                        break
                    end
                end
            end
        end
    end
    for i,o in pairs(players) do
        local hand = o.getHandObjects()
        for _,p in pairs(names) do
            if hand[1] then
                for _,h in pairs(hand) do
                    if string.lower(h.getName()):find(p) then
                        players[i] = nil
                        break
                    end
                    if h.getTags() then
                        for _,tag in pairs(h.getTags()) do
                            if string.lower(tag):find(p) then
                                players[i] = nil
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    for i,o in pairs(players) do
        local playcontent = get_decks_and_cards_from_zone(playguids[o.color])
        for _,p in pairs(names) do
            if playcontent[1] then
                for _,h in pairs(playcontent) do
                    if string.lower(h.getName()):find(p) then
                        players[i] = nil
                        break
                    end
                    if h.getTags() then
                        for _,tag in pairs(h.getTags()) do
                            if string.lower(tag):find(p) then
                                players[i] = nil
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    local result = {}
    for _,p in pairs(players) do
        if p then
            table.insert(result,p)
        end
    end
    for _,o in pairs(result) do
        click_get_wound(nil,o.color)
    end
end

function nonTwistspecials(cards,schemeParts,city)
    if schemeParts[1] == "Brainwash the Military" then
        if cards[1].hasTag("Officer") then
            cards[1].addTag("Brainwashed")
            cards[1].addTag("Villain")
            powerButton({obj = cards[1],
                label = twistsstacked+3,
                tooltip = "This Officer is Brainwashed and therefore a villain. Gain it if you fight it."})
        end
    end
    if schemeParts[1] == "Corrupt the Next Generation of Heroes" then
        if cards[1].hasTag("Sidekick") then
            cards[1].addTag("Corrupted")
            cards[1].addTag("Villain")
            if cards[1].getDescription() == "" then
                cards[1].setDescription("WALL-CRAWL: When fighting this card, gain it to top of your deck as a hero instead of your victory pile.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\nWALL-CRAWL: When fighting this card, gain it to top of your deck as a hero instead of your victory pile.")
            end
            powerButton({obj = cards[1],
                label = twistsstacked+2,
                tooltip = "This sidekick is corrupted and therefore a villain. If you fight it, gain it to the top of your deck."})
        end
    end
    if schemeParts[1] == "Deadpool Wants A Chimichanga" then
        if cards[1].hasTag("Bystander") then
            playVillains()
        end
    end
    if schemeParts[1] == "Devolve with Xerogen Crystals" then
        if cards[1].getName() == schemeParts[9] or (hasTag2(cards[1],"Group:") and hasTag2(cards[1],"Group:") == schemeParts[9]) then
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
            powerButton({obj = cards[1],
                label = boost + hasTag2(cards[1],"Cost:"),
                tooltip = "This Scarlet Witch card is a villain."})
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
            powerButton({obj = cards[1],
                label = "+" .. twistsstacked,
                tooltip = "Assault squads have War Machine Armor and get +1 for each twist that has been played.",
                id = "twistsStacked"})
        end
    end
    if schemeParts[1] == "Mutant-Hunting Super Sentinels" then
        if cards[1].getName() == "Sentinel" then
            cards[1].addTag("Super Sentinel")
            powerButton({obj = cards[1],
                label = "+" .. twistsstacked,
                tooltip = "Super Sentinels get +1 for each twist stacked next to the scheme.",
                id = "twistsStacked"})
        end
    end
    if schemeParts[1] == "Organized Crime Wave" then
        if cards[1].getName() == "Maggia Goons" then
            playVillains()
        end
    end
    if schemeParts[1] == "Replace Earth's Leaders with Killbots" then
        if twistsstacked == 0 then
            twistsstacked = 3
        end
        if cards[1].hasTag("Bystander") then
            cards[1].addTag("Villain")
            cards[1].addTag("Killbot")
            cards[1].removeTag("Bystander")
            powerButton({obj = cards[1],
                label = twistsstacked,
                tooltip = "This bystander is a Killbot and has power equal to the number of twists stacked next to the scheme."})
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
            powerButton({obj = cards[1],
                label = "+" .. strikesresolved,
                tooltip = "Smuggler villains have striker and thus get +1 for each master strike resolved.",
                id = "striker"})
        end
    end
    if schemeParts[1] == "Secret Invasion of the Skrull Shapeshifters" then
        if hasTag2(cards[1],"Cost:") then
            powerButton({obj = cards[1],
                label = hasTag2(cards[1],"Cost:")+2,
                tooltip = "This hero is a Skrull Shapeshifter and has power equal to its cost +2. Gain it if you fight it."})
            cards[1].addTag("Villain")
        end
    end
    if schemeParts[1] == "Sinister Ambitions" then
        if cards[1].hasTag("Ambition") then
            cards[1].addTag("Villain")
            cards[1].addTag("VP4")
            powerButton({obj = cards[1],
                label = "+" .. twistsstacked,
                tooltip = "This ambition card is a villain with power equal to its ambition value + the number of twists stacked next to the scheme. Resolve its ambition effect if it escapes.",
                id = "twistsStacked"})
        end
    end
    if schemeParts[1] == "Splice Humans with Spider DNA" then
        if cards[1].hasTag("Group:Sinister Six") then
            powerButton({obj = cards[1],
                label = "+3",
                tooltip = "Sinister Six villains get +3."})
        end
    end
    if schemeParts[1] == "The Dark Phoenix Saga" then
        if cards[1].getName() == "Jean Grey (DC)" then
            powerButton({obj = cards[1],
                label = hasTag2(cards[1],"Cost:"),
                tooltip = "Jean Grey heroes are villains with power equal to their cost. Gain them if you fight them."})
            cards[1].addTag("Villain")
            playVillains()
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
            powerButton({obj = cards[1],
                label = hasTag2(cards[1],"Cost:")*2,
                tooltip = "This hero is a Khonshu Guardian villain. Its power is equal to its cost, or twice its cost when in Wolf form."})
        end
    end
    if schemeParts[1] == "Transform Citizens Into Demons" then
        if cards[1].getName() == "Jean Grey (DC)" then
            if not goblincount then
                goblincount = 0
            end
            powerButton({obj = cards[1],
                label = hasTag2(cards[1],"Cost:")+goblincount,
                tooltip = "Jean Grey heroes are villains with power equal to their cost + the number of goblin villains next to the scheme. They are worth VP, not gained as heroes when fought."})
            cards[1].addTag("Villain")
            cards[1].addTag("VP4")
        end
    end
    if schemeParts[1] == "Trap Heroes in the Microverse" then
        if hasTag2(cards[1],"Team:",6) then
            powerButton({obj = cards[1],
                label = hasTag2(cards[1],"Cost:") .. "*",
                tooltip = "This hero is a villain with power equal to its cost and Size-Changing for its colors. Gain it if you fight it."})
            if cards[1].getDescription() == "" then
                cards[1].setDescription("SIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
            else
                cards[1].setDescription(cards[1].getDescription() .. "\r\nSIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
            end
        end
    end
    if schemeParts[1] == "War of the Frost Giants" then
        if cards[1].getName() == "Frost Giant Invader" then
            powerButton({obj = cards[1],
                label = "6+",
                tooltip = "This twist is a Frost Giant Invader villain that gets +4 if you are not Worthy."})
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
            powerButton({obj = cards[1],
                label = "+1",
                tooltip = "All non-henchmen villains get +1",
                id = "ArmyofEvilHorror"})
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
    if cards[1].hasTag("Group:Mandarin's Rings") then
        local masterminds = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))
        for _,o in pairs(masterminds) do
            if o == "Mandarin" then
                powerButton({obj = cards[1],
                    label = "+1",
                    tooltip = "Bonus of the Mandarin",
                    id = "mandarin"})
            elseif o == "Mandarin - epic" then
                powerButton({obj = cards[1],
                    label = "+2",
                    tooltip = "Bonus of the Mandarin",
                    id = "mandarin"})
            end
        end
    end
    if cards[1].hasTag("Group:Four Horsemen") then
        local masterminds = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"masterminds"))
        for _,o in pairs(masterminds) do
            if o == "Apocalypse" then
                powerButton({obj = cards[1],
                    label = "+2",
                    tooltip = "Bonus of Apocalypse",
                    id = "apocalypse"})
            end
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
        mmZone.Call('setupMasterminds',{obj = cards[1],epicness = false,tactics = 0})
        return nil
    end
    return twistsresolved
end

function demolish(params)
    if not params then
        params = "empty"
    end
    local players = params.players or Player.getPlayers()
    local n = params.n or 1
    if n < 1 then
        return nil
    end
    local altsource = params.altsource
    local ko = params.ko
    local name = "Discard "
    if ko then
       name = "KO "    
    end
    local callbacksresolved = 0
    local demolishEffect = function()
        for _,o in pairs(players) do
            local posdiscard = nil
            if ko == true then
                posdiscard = getObjectFromGUID(kopile_guid).getPosition()
            else
                posdiscard = getObjectFromGUID(playerBoards[o.color]).positionToWorld(pos_discard)
            end
            for i=1,10 do
                if costs[i] > 0 then
                    local hand = o.getHandObjects()
                    if hand[1] then
                        local toDiscard = {}
                        for _,h in pairs(hand) do
                            if hasTag2(h,"Cost:") and hasTag2(h,"Cost:") == i then
                                table.insert(toDiscard,h)
                            end
                        end
                        promptDiscard({color = o.color,
                            hand = toDiscard,
                            n = costs[i],
                            pos = posdiscard})
                        broadcastToColor(name .. math.min(#hand,costs[i]) .. " cards from your hand with cost " .. i,o.color,o.color)
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
        costs = table.clone(herocosts,3)
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
        if herodeck[1].tag == "Deck" then
            bump(herodeck[1],n+2)
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

function wakingNightmare(params)
    local n = params.n or 1
    local color = params.color
    if n < 1 or not color then
        return nil
    end
    if not waking_nightmares then
        waking_nightmares = {}
    end
    waking_nightmares[color] = n
    haveanightmare = function(obj,index,color)
        broadcastToColor("Waking Nightmare " .. params.n - waking_nightmares[color] + 1 .. " out of " .. params.n .. ".",color,color)
        local hand = Player[color].getHandObjects()
        local nongrey = {}
        for _,h in pairs(hand) do
            if hasTag2(h,"HC:") then
                table.insert(nongrey,h)
            end
        end
        if nongrey[1] then
            local drawCard = function()
                getObjectFromGUID(playerBoards[color]).Call('click_draw_card')
                waking_nightmares[color] = waking_nightmares[color] - 1
                if waking_nightmares[color] > 0 then
                    Wait.time(function() haveanightmare(nil,nil,color) end,0.5)
                end
            end
            promptDiscard({color = color,
                hand = nongrey,
                trigger_function = drawCard,
                args = "self"})
        end
    end
    haveanightmare(nil,nil,color)
end

function dealCard(params)
    local obj = params.obj
    local options = params.options
    local color = params.color or Turns.turn_color
    --local targetpos = params.targetpos
    if not options then
        options = {}
        for _,p in pairs(Player.getPlayers()) do
            table.insert(options,p.color)
        end
    end
    local pos = getObjectFromGUID(playerBoards[color]).getPosition()
    pos.y = pos.y + 8
    local angle = 180
    if color == "White" then
        pos.z = pos.z - 6
        angle = 90
    elseif color == "Blue" then
        pos.z = pos.z + 6
        angle = -90
    else
        pos.x = pos.x - 6
    end
	local brot = {x=0, y=angle, z=0}
    obj.clearButtons()
    obj.setPositionSmooth(pos)
    obj.locked = true
    local objpos = {x=0, y=2, z=-1.5} 
    for _,opt in pairs(options) do
        _G['dealTheCard' .. color .. "to" .. opt] = function(object)
            object.locked = false
            object.clearButtons()
            local targetpos = getObjectFromGUID(discardguids[opt]).getPosition()
            object.setPosition(targetpos)
        end
        obj.createButton({position = objpos,
            click_function = 'dealTheCard' .. color .. "to" .. opt,
            function_owner=self,
            label=opt,
            tooltip="Choose " .. opt .. " for the card to be dealt to.",
            font_size=200,
            font_color={0,0,0},
            color=opt,
            width=650,height=650})
        objpos.z = objpos.z + 1.5
    end
end

function offerCards(params)
    --log(params)
    local color = params.color
    local pile = params.pile
    local guids = params.guids
    local resolve_function = params.resolve_function
    local tooltip = params.tooltip
    local label = params.label
    local flip = params.flip
    local n = params.n
    local args = params.args
    local targetpos = params.targetpos
    local fsourceguid = params.fsourceguid
    if not tooltip then
        tooltip = "Pick this card for the scheme twist, master strike or other effect."
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
                local card = getObjectFromGUID(o)
                if card and card.guid ~= obj.guid then
                    card.locked = false
                    card.clearButtons()
                    card.setPosition(pilepos)
                    if flip then
                        card.flip()
                    end
                end
            end
            cardsoffered[color] = {nil}
        end
        obj.locked = false
        obj.clearButtons()
        obj.setRotation(brot)
        if resolve_function and fsourceguid and args and args == "self" then
            getObjectFromGUID(fsourceguid).Call(resolve_function,{obj = obj,
                player_clicker_color = color})
        elseif resolve_function and fsourceguid then
            getObjectFromGUID(fsourceguid).Call(resolve_function,obj)
        elseif resolve_function then
            resolve_function(obj)
        elseif targetpos then
            local playerBoard = getObjectFromGUID(playerBoards[color])
            local dest = playerBoard.positionToWorld(targetpos)
            obj.setPosition(dest)
        end
    end
    function lockAndButton(obj)
        obj.locked = true
        obj.createButton({click_function='resolveOfferCardsEffect' .. color,
            function_owner=self,
            position={0,20,0},
            label=label,
            tooltip=tooltip,
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
    local tot = pile.getQuantity()
    for _,o in pairs(pile.getObjects()) do
        if not guids or #guids == tot then
            table.insert(cardsoffered[color],o.guid)
            pile.takeObject({position = pos,
                guid = o.guid,
                flip = flip,
                smooth = true,
                callback_function = lockAndButton})
            local rema = pile.remainder
            step,pos = stepPos(step,pos,color,posini)
            if rema and #guids ~= #cardsoffered[color] then
                table.insert(cardsoffered[color],rema.guid)
                rema.setPositionSmooth(pos)
                if flip then
                    rema.flip()
                end
                lockAndButton(rema)
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
    return getObjectFromGUID(setupGUID).Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function demonicBargain(params)
    local color = params.color
    local triggerf = params.triggerf
    local giveWound = params.giveWound or true
    local fsourceguid = params.fsourceguid
    
    local playerBoard = getObjectFromGUID(playerBoards[color])
    local posdiscard = playerBoard.positionToWorld(pos_discard)
    local deck = playerBoard.Call('returnDeck')[1]
    local performDemonicBargain = function()
        local demonicBargainFulfilled = function(obj)
            if hasTag2(obj,"Cost:") and hasTag2(obj,"Cost:") > 0 then
                if fsourceguid then
                    getObjectFromGUID(fsourceguid).Call(triggerf,{color = color,
                        wounds = true})
                else
                    triggerf(color,true)
                end
                if giveWound then
                    click_get_wound(nil,color)
                    broadcastToColor("You failed the Demonic Bargain and got a wound!",color,color)
                end
            else
                if fsourceguid then
                    getObjectFromGUID(fsourceguid).Call(triggerf,{color = color,
                        wounds = false})
                else
                    triggerf(color,false)
                end
            end
        end
        if not deck then
            deck = playerBoard.Call('returnDeck')[1]
        end
        posdiscard.y = posdiscard.y + 2
        if deck and deck.tag == "Deck" then
            deck.takeObject({position = posdiscard,
                flip = true,
                smooth = true,
                callback_function = demonicBargainFulfilled})
        elseif deck then
            deck.setPosition(posdiscard)
            demonicBargainFulfilled(deck)
        end
    end
    if deck and deck.getQuantity() > 1 then
        performDemonicBargain()
    else
        playerBoard.Call('click_refillDeck')
        deck = nil
        Wait.time(performDemonicBargain,2)
    end
end

function promptDiscard(params)
    if not params.color then
        params = {["color"] = params}
    end
    
    local color = params.color
    if not color then
        return nil
    end
    
    local handobjects = params.hand or Player[color].getHandObjects()
    local n = params.n or 1
    local pos = params.pos or getObjectFromGUID(discardguids[color]).getPosition()
    local flip = params.flip
    local label = params.label or "Discard"
    local tooltip = params.tooltip or "Discard this card."
    local triggerf = params.trigger_function
    local args = params.args
    local buttoncolor = params.buttoncolor
    local isZone = params.isZone
    local buttonheight = params.buttonheight or 22
    local fsourceguid = params.fsourceguid
    if #handobjects > 0 then
        n = math.min(n,#handobjects)
    end
    if n < 1 then
        return nil
    end
    if #handobjects == n then
        for i = 1,n do
            if flip then
                handobjects[i].flip()
            end
            if pos ~= "Stay" then
                handobjects[i].setPosition(pos)
            else
                if responses then
                    responses[color] = handobjects[i]
                end
            end
            if fsourceguid then
                if triggerf and args and args == "self" then
                    getObjectFromGUID(fsourceguid).Call(triggerf,{obj = handobjects[i],
                            index = i,
                            player_clicker_color = color})
                elseif triggerf and args then
                    getObjectFromGUID(fsourceguid).Call(triggerf,args)
                elseif triggerf then
                    getObjectFromGUID(fsourceguid).Call(triggerf)
                end
            else
                if triggerf and args and args == "self" then
                    triggerf(handobjects[i],i,color)
                elseif triggerf and args then
                    triggerf(args)
                elseif triggerf then
                    triggerf()
                end
            end
        end
    else
        for i,o in pairs(handobjects) do
            _G["discardCard" .. color .. o.guid] = function(obj)
                n = n-1
                for index,button in pairs(obj.getButtons()) do
                    if button.click_function:find("discardCard") then
                        obj.removeButton(index-1)
                    end
                end
                if n == 0 then
                    for _,p in pairs(handobjects) do
                        if p and p.getButtons() then
                            for index,button in pairs(p.getButtons()) do
                                if button.click_function:find("discardCard") then
                                    p.removeButton(index-1)
                                end
                            end
                        end
                    end
                end
                if flip then
                    obj.flip()
                end
                if pos ~= "Stay" then
                    obj.setPosition(pos)
                else
                    if responses then
                        responses[color] = obj
                    end
                end
                if fsourceguid then
                    if triggerf and args and args == "self" then
                        getObjectFromGUID(fsourceguid).Call(triggerf,{obj = handobjects[i],
                            index = i,
                            player_clicker_color = color})
                    elseif triggerf and args then
                        getObjectFromGUID(fsourceguid).Call(triggerf,args)
                    elseif triggerf then
                        getObjectFromGUID(fsourceguid).Call(triggerf)
                    end
                else
                    if triggerf and args and args == "self" then
                        triggerf(obj,i,color)
                    elseif triggerf and args then
                        triggerf(args)
                    elseif triggerf then
                        triggerf()
                    end
                end
            end
            if not isZone then
                o.createButton({click_function="discardCard" .. color .. o.guid,
                    function_owner=self,
                    position={0,buttonheight,0},
                    label=label,
                    tooltip=tooltip,
                    font_size=250,
                    font_color="Black",
                    color=buttoncolor or {1,1,1},
                    width=750,height=450})
            else
                o.createButton({click_function="discardCard" .. color .. o.guid,
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label=label,
                    tooltip=tooltip,
                    font_size=100,
                    font_color="Black",
                    color=buttoncolor or {1,1,1},
                    width=375})
            end
        end
    end
end

function gainShard2(params)
    gainShard(params.color,params.zoneGUID,params.n)
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
        newshard.locked = false
        Wait.time(function() 
                newshard.Call('resetVal')                
                for i=1,n-1 do 
                    newshard.Call('add_subtract') 
                end 
            end,0.2)
        log("First shard added to zone with guid " .. zoneGUID)
    end
end

function contestOfChampions(params)
    local color = params.color
    local n = params.n or 2
    local winf = params.winf
    local epicness = params.epicness
    local fsourceguid = params.fsourceguid
    
    if color[1] then
        broadcastToAll("Contest of Champions for " .. color[1] .. " and " .. color[2] .. "!")
    elseif color then
        broadcastToAll("Contest of Champions for " .. color .. "!")
        color = {color}
    else
        printToAll("No color found for the contest.")
        return nil
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
                if k:find("HC:") and (k:gsub("HC:","") == color[1] or (color[2] and k:gsub("HC:","") == color[2])) then
                    doubled = true
                end
                if k:find("HC1:") and (k:gsub("HC1:","") == color[1] or (color[2] and k:gsub("HC1:","") == color[2])) then
                    doubled = true
                end
                if k:find("HC2:") and (k:gsub("HC2:","") == color[1] or (color[2] and k:gsub("HC2:","") == color[2])) then
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
        if hasTag2(herodeck[1],"HC:") and (hasTag2(herodeck[1],"HC:") == color[1] or (color[2] and hasTag2(herodeck[1],"HC:") == color[2])) then
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
        local killTopCardbutton = function(obj,index,color)
            local playerBoard = getObjectFromGUID(playerBoards[color])
            local butt = playerBoard.getButtons()
            for i,b in pairs(butt) do
                if b.click_function:find("pickTopCard") then
                    playerBoard.removeButton(i-1)
                    break
                end
            end
        end
        promptDiscard({color = o.color,
            pos = "Stay",
            label = "Choose",
            tooltip = "Choose for Contest of Champions.",
            trigger_function = killTopCardbutton,
            args = "self"})
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
                    end
                    if k:find("HC:") and (k:gsub("HC:","") == color[1] or (color[2] and k:gsub("HC:","") == color[2])) then
                        doubled = true
                    end
                    if k:find("HC1:") and (k:gsub("HC1:","") == color[1] or (color[2] and k:gsub("HC1:","") == color[2])) then
                        doubled = true
                    end
                    if k:find("HC2:") and (k:gsub("HC2:","") == color[1] or (color[2] and k:gsub("HC2:","") == color[2])) then
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
                    if hasTag2(deck[1],"HC:") and (hasTag2(deck[1],"HC:") == color[1] or (color[2] and hasTag2(deck[1],"HC:") == color[2])) then
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
                if hasTag2(o,"HC:") and (hasTag2(o,"HC:") == color[1] or (color[2] and hasTag2(o,"HC:") == color[2])) then
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
            local printcolor = nil
            if i == "Evil" then
                printcolor = "Black"
            else
                printcolor = i
            end
            printToAll(i .. " revealed a hero with Contest Score " .. responses[i] .. "!",printcolor)
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
        if fsourceguid then
            getObjectFromGUID(fsourceguid).Call(winf,contestResult)
        else
            winf(contestResult)
        end
    end
    Wait.condition(resolveContest,contestFulfilled)
end

function getStrikeloc(mmname,alttable)
    if not alttable then
        alttable = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
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

function outwitPlayer(params)
    local color = params.color
    local n = params.n or 3
    
    local tf = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"transformed"),true)
    if not params.n and tf["M.O.D.O.K."] ~= nil and tf["M.O.D.O.K."] == false then
        n = 4
    end
    local costs = table.clone(herocosts)
    
    local playcontent = get_decks_and_cards_from_zone(playguids[color])
    local hand = Player[color].getHandObjects()
    local allcards = merge(playcontent,hand)
    local zerocost = 0
    for _,obj in pairs(allcards) do
        if hasTag2(obj,"Cost:") then
            costs[hasTag2(obj,"Cost:")] = costs[hasTag2(obj,"Cost:")] + 1
        elseif obj.hasTag("Starter") then
            zerocost = 1
        end
    end
    local outwit = zerocost
    for _,o in pairs(costs) do
        if o > 0 then
            outwit = outwit + 1
        end
    end
    if outwit >= n then
        return true
    else
        return false
    end
end

function resolve_alien_brood_scan(obj,escaping)
    if obj.getName() == "Masterstrike" then
        obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
        Wait.time(click_push_villain_into_city,1)
        broadcastToAll("A master strike was scanned in the city!")
        return nil
    elseif obj.getDescription():find("TRAP") then
        obj.setPosition(getObjectFromGUID(city_zones_guids[1]).getPosition())
        broadcastToAll("A Trap was scanned in the city! Resolve it by end of turn or suffer the consequences.")
        return nil
    elseif obj.hasTag("Villain") or obj.hasTag("Villainous Weapon") and escaping then
        nonTwistspecials({obj},{""},{})
        return obj
    elseif obj.hasTag("Location") then
        if escaping then
            koCard(obj)
            broadcastToAll("Locations can't normally escape, so it was KO'd instead.")
            return nil
        else
            pos = obj.getPosition()
            pos.z = pos.z + 1.5
            obj.setPosition(pos)
            return nil
        end
    elseif obj.getName() == "Scheme Twist" then
        local color = getNextColor(Turns.turn_color)
        obj.setName("Brood Infection")
        obj.setPositionSmooth(getObjectFromGUID(discardguids[color]).getPosition())
        broadcastToAll("Player " .. color .. " got a Brood Infection!")
        function onObjectEnterZone(zone,object)
            if object.getName() == "Brood Infection" then
                for i,o in pairs(handguids) do
                    if zone.guid == o then
                        object.setName("Scheme Twist")
                        Wait.time(function() koCard(object) end,0.1)
                        getWound(i)
                        getWound(i)
                        broadcastToColor("You drew a Brood Infection! It was KO'd but gave you two wounds.",i,i)
                    end
                end
            end
        end
        return nil
    end
end

function resolveVillainEffect(params)
    local obj = params.obj
    local move = params.move or "Fight"
    local color = params.color or Turns.turn_color
    local schemeParts = params.schemeParts or getObjectFromGUID(setupGUID).Call('returnSetupParts') or {""}
    
    if schemeParts[1] == "Annihilation: Conquest" and obj.hasTag("Phalanx-Infected") then
        obj.removeTag("Phalanx-Infected")
        obj.removeTag("Villain")
        dealCard({obj = obj})
        return nil
    end
    if schemeParts[1] == "Corrupt the Next Generation of Heroes" and obj.hasTag("Corrupted") then
        obj.removeTag("Corrupted")
        obj.removeTag("Villain")
        obj.setDescription(obj.getDescription():gsub("WALL%-CRAWL.*%.",""))
        obj.clearButtons()
        obj.flip()
        local pos = getObjectFromGUID(drawguids[color]).getPosition()
        pos.y = pos.y + 3
        obj.setPositionSmooth(pos)
        return nil
    end
    local name = obj.getName()
    local group = nil--hasTag2(obj,"Group:")
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
                    promptDiscard({color = player_clicker_color,
                        hand = officers,
                        label = "Gain",
                        tooltip = "Gain this officer."})
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
    return obj
end