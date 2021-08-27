function onLoad()
    --create buttons for importing and autoshuffle

    self.createButton({
        click_function="click_shuffle", function_owner=self,
        position={-60,0.1,12}, height=500, width=1500, color={1,1,1,1},
        label = "Shuffle!", color={r=0, g=0, b=1},tooltip="Shuffle: heroes, villains, bystanders, wounds, sidekicks, player decks."
    })
    
    self.createButton({
        click_function="import_setup", function_owner=self,
        position={-60,0.1,11}, height=500, width=1500, color={1,1,1,1},
        label = "Import Setup",tooltip="Import a setup. Paste text in proper format in textbox below first."
    })
    
    self.createButton({
        click_function="toggle_autoplay", function_owner=self,
        position={-60,0.1,16}, height=125,
        width=1500, height=500, label="Autoplay from villain deck", tooltip="Set autoplay from villain deck when player draws new hand!", 
        color={0,1,0}
    })
    
    self.createButton({
        click_function="toggle_finalblow", function_owner=self,
        position={-60,0.1,15}, height=125,
        width=1500, height=500, label="Final Blow", tooltip="Final Blow enabled", 
        color={0,1,0}
    })
    
    -- create text input to paste setup parameters
    self.createInput({
        input_function = "input_print",
        function_owner = self,
        label          = "CTRL + V the Setup here",
        font_size      = 223,
        validation     = 1,
        position={-60.5,0.1,7},
        width=2000,
        height=3000
    })
    
    setupText = ""
    
    herocosts = {}
    for i=0,9 do
        table.insert(herocosts,0)
    end
    
    --following can be combined and integrated with the boards
    playercolors = {
        "Yellow",
        "Green",
        "Red",
        "White",
        "Blue"
    }
    
    playerBoards = {
        ["Red"]="8a35bd",
        ["Green"]="d7ee3e",
        ["Yellow"]="ed0d43",
        ["Blue"]="9d82f3",
        ["White"]="206c9c"
    }
    
    city_zones_guids = {"e6b0bc",
        "40b47d",
        "5a74e7",
        "07423f",
        "5bc848",
        "82ccd7"
    }
    
    playguids = {
        ["Red"]="157bfe",
        ["Green"]="0818c2",
        ["Yellow"]="7149d2",
        ["Blue"]="2b36c3",
        ["White"]="558e75"
    }
        
    hqguids = {
        "aabe45",
        "bf3815",
        "11b14c",
        "b8a776",
        "75241e"
    }
    
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
    
    allTopBoardGUIDS = {
        "7f622a",
        "000e0c",
        "3e45a0",
        "705f8c",
        "1fa829",
        "bf7e87",
        "4c1868",
        "8656c3",
        "533311",
        "3d3ba7",
        "725c5d",
        "4e3b7e",
        "f394e1",
        "0559f8",
        "39e3d7",
        "6b1c18",
        "57df40"
    }
    
    addMMGUIDS = {}
    
    for _,o in pairs(allTopBoardGUIDS) do
        addMMGUIDS[o] = false
    end
    
    vpileguids = {
        ["Red"]="fac743",
        ["Green"]="a42b83",
        ["Yellow"]="7f3bcd",
        ["Blue"]="f6396a",
        ["White"]="7732c7"
    }
    
    masterminds = {}
        
    bystandersPileGUID = "0b48dd"
    woundsDeckGUID = "653663"
    sidekickDeckGUID = "d40734"
    officerDeckGUID = "aed7cd"
    
    schemePileGUID = "0716a4"
    mmPileGUID = "c7e1d5"
    strikePileGUID = "aff2e5"
    horrorPileGUID = "82f3dc"
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
    horrorZoneGUID = strikeZoneGUID
    twistZoneGUID = "4f53f9"
    
    escape_zone_guid = "de2016"
    
    kopile_guid = "79d60b"
    
    transformed = {}
    
    --Local positions for each pile of cards
    pos_vp2 = {-5, 0.178, 0.222}
    pos_discard = {-0.957, 0.178, 0.222}
    
    autoplay = true
    finalblow = true
    finalblowfixed = false
    Turns.enable = true
    
    
end

function returnAutoplay()
    return autoplay
end

function returnFinalblow()
    return finalblow
end

function returnMM()
    return masterminds
end

function returnMMLocation()
    return mmLocations
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

function toggle_autoplay(obj,player_clicker_color)
    local butt = self.getButtons()
    for _,o in pairs(butt) do
        if o.click_function == "toggle_autoplay" then
            buttonindex = o.index
        end
    end
    if autoplay == false then
        autoplay = true
        self.editButton({index=buttonindex,color = {0,1,0}})
        broadcastToAll("Cards will be played from villain deck at each player's turn end, when clicking New Hand.")
    else
        autoplay = false
        self.editButton({index=buttonindex,color = {1,0,0}})
        broadcastToAll("Cards will NOT be played from villain deck at each player's turn end.")
    end
end

function toggle_finalblow(obj,player_clicker_color)
    if finalblowfixed then
        return nil
    end
    local butt = self.getButtons()
    for _,o in pairs(butt) do
        if o.click_function == "toggle_finalblow" then
            buttonindex = o.index
        end
    end
    if finalblow == false then
        finalblow = true
        self.editButton({index=buttonindex,color = {0,1,0},
            tooltip="Final Blow enabled"})
        broadcastToAll("Final blow enabled.")
    else
        finalblow = false
        self.editButton({index=buttonindex,color = {1,0,0},
            tooltip="Final Blow disabled"})
        broadcastToAll("Final blow disabled.")
    end
end

function input_print(obj, color, input, stillEditing)
    if not stillEditing then
        setupText = input
    end
end

function obedienceDisk(obj,player_clicker_color)
    printToColor("Heroes in the HQ zone below this one cost 1 more for each Obedience Disk (twist) here.",player_clicker_color)
    return nil
end

function click_shuffle()

    log("Shuffle: heroes, villains, bystanders, wounds, sidekicks, shield officers, player decks")
    print("Shuffling decks! Only before startup!")
    local woundsDeck = getObjectFromGUID(woundsDeckGUID)
    if woundsDeck  then woundsDeck.randomize() end
    log("Shuffling wounds stack!")

    local sidekickDeck = getObjectFromGUID(sidekickDeckGUID)
    if sidekickDeck  then sidekickDeck.randomize() end
    log ("shuffling sidekick stack!")

    local bystanderDeck = getObjectFromGUID(bystandersPileGUID)
    if bystanderDeck  then bystanderDeck.randomize() end
    log("Shuffling bystander deck!")
    
    local officerDeck = getObjectFromGUID(officerDeckGUID)
    if officerDeck  then officerDeck.randomize() end
    log("Shuffling SHIELD officer stack!")

    local heroDeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
    if heroDeck[1] then
        heroDeck[1].randomize()
        log("Shuffling the hero deck!")
    else
        log("No Hero deck to shuffle")
        broadcastToAll("No Hero deck to shuffle")
    end

    local villainDeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)
    if villainDeck[1] then
        villainDeck[1].randomize()
        log("Shuffling the villain deck!")
    else
        log("No Villain deck to shuffle")
        broadcastToAll("No Villain deck to shuffle")
    end
    
    for i=1,5 do
        if Player[playercolors[i]].seated == true then
            local playerdeck = getObjectFromGUID(playerBoards[playercolors[i]]).Call('returnDeck')
            if playerdeck[1] then 
                playerdeck[1].randomize()
                log("Shuffling " .. playercolors[i] .. " Player's deck!")
                --print("Shuffling " .. Player.getPlayers()[i].color .. " Player's deck!")
            else
                log("No player deck found for player " .. playercolors[i])
            end
        end
    end
    --add exceptions here for some schemes
    
    if setupParts and setupParts[1] == "Divide and Conquer" then
        local dividedDeckGUIDs = {
            ["HC:Red"]="4c1868",
            ["HC:Green"]="8656c3",
            ["HC:Yellow"]="533311",
            ["HC:Blue"]="3d3ba7",
            ["HC:Silver"]="725c5d"
        }
        for _,o in pairs(dividedDeckGUIDs) do
            local dividedDeck = get_decks_and_cards_from_zone(o)
            if dividedDeck[1] then
                dividedDeck[1].randomize()
            end
        end
    end
    
    for _,o in pairs(hqguids) do
        getObjectFromGUID(o).Call('click_draw_hero')
    end

end

function findObjectsAtPosition(pos,where)
    --set where to something to make pos global, otherwise its local to the setup object
    local globalPos = pos
    if not where then
        globalPos = self.positionToWorld(pos)
    end
    local objList = Physics.cast({
        origin=globalPos,
        direction={0,1,0},
        type=2,
        size={2,2,2},
        max_distance=1,
        debug=false
    })

    local decksAndCards = {}
    for _,obj in ipairs(objList) do
        if obj.hit_object.tag == "Deck" or obj.hit_object.tag == "Card" then
            table.insert(decksAndCards, obj.hit_object)
        end
    end
    return decksAndCards
end

function reduceStack(count,stackGUID)
    local stack = getObjectFromGUID(stackGUID)
    --change this zone to move them somewhere else
    --currently we keep this one so players can still get cards back if needed
    local destzone = "4e3b7e"
    local outOfGameZone = getObjectFromGUID(destzone)
    if randomize then stack.randomize() end
    local stackObjects = stack.getObjects()
    local stackCount = #stackObjects
    while stackCount > count do
        stack.takeObject({
            position = outOfGameZone.getPosition(),
            callback_function = function (obj) obj.destruct() end,
        })
        stackObjects = stack.getObjects()
        stackCount = #stackObjects
    end
end

function findInPile(deckName,pileGUID,destGUID,callbackf)
    callbackf_tocall = callbackf or nil
    local pile = getObjectFromGUID(pileGUID)
    local targetDeckZone = nil
    if destGUID then
        targetDeckZone= getObjectFromGUID(destGUID)
    else
        targetDeckZone= getObjectFromGUID(villainDeckZoneGUID)
    end
    for index,object in pairs(pile.getObjects()) do
        if string.lower(object.name) == string.lower(deckName) then
            log ("found " .. deckName .. "!")
            local deckGUID= object.guid
            deck = pile.takeObject({guid=deckGUID,
                position=targetDeckZone.getPosition(),
                smooth=false,
                flip=true,
                callback_function = callbackf_tocall})
            return deck
        end
    end
    return nil
end

function mmGetCards(mmname,transformed)
    mmcardnumber = 5
    if mmname == "Hydra High Council" or mmname == "Hydra Super-Adaptoid" then
            mmcardnumber = 4
    end
    if transformed and (mmname == "General Ross" or mmname == "Illuminati, Secret Society" or mmname == "King Hulk, Sakaarson" or mmname == "M.O.D.O.K." or mmname == "The Red King" or mmname == "The Sentry") then
        return true
    elseif transformed then
        return false
    else
        return(mmcardnumber)
    end
end

function isTransformed(mmname)
    return mmGetCards(mmname,true)
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

function returnSetupParts()
    -- setupElements = {
        -- ["Scheme"]=1,
        -- ["#Twists"]=2,
        -- ["#Bystanders"]=3,
        -- ["#Wounds"]=4, (0 if no restriction)
        -- ["Mastermind"]=5,
        -- ["Villains"]=6,
        -- ["Henchmen"]=7,
        -- ["Heroes"]=8,
        -- ["Extra"]=9
    -- }
    return setupParts
end

function returnColor(obj)
    --print("this is a dummy function for button clicks")
end

function nonCityZone(obj,player_clicker_color)
    broadcastToColor("This city zone does not currently exist!",player_clicker_color)
end

function returnbsGUID()
    -- if the guid changes, e.g. because of Mojo
    return bystandersPileGUID
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

function woundedFury(obj,color)
    local discardpile = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
    local wounds = 0
    local buttonindex = nil
    for i,o in pairs(obj.getButtons()) do
        if o.click_function == "Wounded Fury" then
            buttonindex = i-1
            break
        end
    end
    if discardpile[1] and discardpile[1].tag == "Deck" then
        for _,o in pairs(discardpile[1].getObjects()) do
            if o.tags[1] == "Wound" then
                wounds = wounds + 1
            end
        end
    elseif discardpile[1] then
        if discardpile[1].hasTag("Wound") then
            wounds = wounds + 1
        end
    end
    local mmname = nil
    for i,o in pairs(mmLocations) do
        if o == obj.guid then
            mmname = i
            break
        end
    end
    if mmname then
        mmButtons(mmname,wounds,"+" .. wounds,"Wounded fury.","mm","woundedfury")
    elseif wounds > 0 then
        if buttonindex then
            obj.editButton({index=buttonindex,label="+" .. wounds,
                tooltip="Wounded Fury."})
        else
            obj.createButton({click_function='woundedFury',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label="+" .. wounds,
                tooltip="Wounded Fury.",
                font_size=250,
                font_color="Red",
                width=0})
        end
    elseif buttonindex then
        obj.removeButton(buttonindex)
    end
end

function transformMM(obj, player_clicker_color, alt_click)
    local content = get_decks_and_cards_from_zone(obj.guid)
    if content[1] then
        for _,o in pairs(content) do
            if o.tag == "Card" and not hasTag2(o,"Tactic:",8) then
                o.flip()
                transformed[o.getName()] = not transformed[o.getName()]
                --log(transformed)
                transformChanges(o.getName())
                return transformed[o.getName()]
            elseif o.tag == "Deck" then
                for _,k in pairs(o.getObjects()) do
                    local istactic = false
                    for _,tag in pairs(k.tags) do
                        if tag:find("Tactic:") then
                            istactic = true
                            break
                        end
                    end
                    if istactic == false then
                        local pos = content[1].getPosition()
                        pos.y = pos.y + 1
                        o.takeObject({position = pos,
                            flip=true})
                        transformed[k.name] = not transformed[k.name]
                        --log(transformed)
                        transformChanges(k.name)
                        return transformed[k.name]
                    end
                end
            end
        end
    end
end

function externalTransformMM(zone)
    if not zone then
        zone = getObjectFromGUID(mmZoneGUID)
    end
    transformMM(getObjectFromGUID(zone))
    return table.clone(transformed,true)
end

function transformChanges(name)
    if name == "General Ross" then
        updateMMRoss()
    elseif name == "Illuminati, Secret Society" then
        updateMMIlluminatiSS()
    elseif name == "King Hulk, Sakaarson" then
        updateMMHulk()
    elseif name == "M.O.D.O.K." then
        updateMMMODOK()
    elseif name == "The Red King" then
        updateMMRedKing()
    elseif name == "The Sentry" then
        updateMMSentry()
    end
end

function addTransformButton(zone)
    zone.createButton({click_function='transformMM',
        function_owner=self,
        position={0,0,1.2},
        rotation={0,180,0},
        label="Transform",
        tooltip="Transform the Mastermind.",
        font_size=100,
        font_color={0,0,0},
        color="Green",
        width=600,
        height=350})
end

function setupTransformingMM(mmname,mmZone,lurking)
    if not mmZone then
        mmZone = getObjectFromGUID(mmZoneGUID)
    end
    if not lurking then
        addTransformButton(mmZone)
    end
    transformed[mmname] = false
    if mmname == "General Ross" then
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        for i=1,8 do
            bsPile.takeObject({position=getObjectFromGUID(getStrikeloc(mmname)).getPosition(),
                flip=false,
                smooth=true})
        end
        function updateMMRoss()
            if not mmActive(mmname) then
                return nil
            end
            local mmZone = getObjectFromGUID(mmLocations[mmname])
            local buttonindex = nil
            for i,o in pairs(mmZone.getButtons()) do
                if o.click_function == "updateMMRoss" then
                    buttonindex = i-1
                    break
                end
            end
            local strikeloc = getStrikeloc(mmname)
            local checkvalue = 1
            if transformed[mmname] == false then
                if not get_decks_and_cards_from_zone(strikeloc)[1] then
                    getObjectFromGUID(strikeloc).clearButtons()
                    checkvalue = 0
                else
                    if not getObjectFromGUID(strikeloc).getButtons() then
                        getObjectFromGUID(strikeloc).createButton({click_function='updateMMRoss',
                            function_owner=self,
                            position={0,0,0},
                            rotation={0,180,0},
                            label="2",
                            tooltip="You can fight these Helicopter Villains for 2 to rescue them as Bystanders.",
                            font_size=250,
                            font_color="Red",
                            width=0})
                    else
                        getObjectFromGUID(strikeloc).editButton({label="2",
                            tooltip="You can fight these Helicopter Villains for 2 to rescue them as Bystanders."})
                    end
                end
                mmButtons(mmname,
                    checkvalue,
                    "X",
                    "You can't fight General Ross while he has any Helicopters.",
                    'updateMMRoss')
            elseif transformed[mmname] == true then
                if getObjectFromGUID(strikeloc).getButtons() then
                    getObjectFromGUID(strikeloc).editButton({label="X",
                        tooltip="You can't fight Helicopters, and they don't stop you from fighting Red Hulk."})
                else
                    getObjectFromGUID(strikeloc).createButton({click_function='updateMMRoss',
                            function_owner=self,
                            position={0,0,0},
                            rotation={0,180,0},
                            label="X",
                            tooltip="You can't fight Helicopters, and they don't stop you from fighting Red Hulk.",
                            font_size=250,
                            font_color="Red",
                            width=0})
                end
                woundedFury(mmZone,Turns.turn_color)
            end
        end
        function onPlayerTurn(player,previous_player)
            if transformed["General Ross"] == true then
                updateMMRoss()
            end
        end
        function onObjectEnterZone(zone,object)
            if transformed["General Ross"] ~= nil then
                updateMMRoss()
            end
        end
        function onObjectLeaveZone(zone,object)
            if transformed["General Ross"] ~= nil then
                updateMMRoss()
            end
        end
    end
    if mmname == "Illuminati, Secret Society" then
        function updateMMIlluminatiSS()
            if not mmActive(mmname) then
                return nil
            end
            if transformed["Illuminati, Secret Society"] == true then
                local notes = getNotes()
                setNotes(notes .. "\r\n\r\nWhenever a card effect causes a player to draw any number of cards, that player must then also discard a card.")
            elseif transformed["Illuminati, Secret Society"] == false then   
                local notes = getNotes()
                setNotes(notes:gsub("\r\n\r\nWhenever a card effect causes a player to draw any number of cards, that player must then also discard a card.",""))
            end
        end
    end
    if mmname == "King Hulk, Sakaarson" then
        function updateMMHulk()
            if not mmActive(mmname) then
                return nil
            end
            local mmZone = getObjectFromGUID(mmLocations[mmname])
            local buttonindex = nil
            for i,o in pairs(mmZone.getButtons()) do
                if o.click_function == "updateMMHulk" then
                    buttonindex = i-1
                    break
                end
            end
            if transformed[mmname] == false then
                local warbound = 0
                for _,o in pairs(city_zones_guids) do
                    if o ~= city_zones_guids[1] then
                        local citycontent = get_decks_and_cards_from_zone(o)
                        if citycontent[1] then
                            for _,k in pairs(citycontent) do
                                if k.hasTag("Group:Warbound") then
                                    warbound = warbound + 1
                                    break
                                end
                            end
                        end
                    end
                end
                local escapedcards = get_decks_and_cards_from_zone(escape_zone_guid)
                if escapedcards[1] and escapedcards[1].tag == "Deck" then
                    for _,o in pairs(escapedcards[1].getObjects()) do
                        for _,k in pairs(o.tags) do
                            if k == "Group:Warbound" then
                                warbound = warbound + 1
                                break
                            end
                        end
                    end
                elseif escapedcards[1] and escapedcards[1].tag == "Card" then
                    if escapedcards[1].hasTag("Group:Warbound") then
                        warbound = warbound + 1
                    end
                end
                mmButtons(mmname,
                    warbound,
                    "+" .. warbound,
                    "King Hulk gets +1 for each Warbound Villain in the city and in the Escape Pile.",
                    "updateMMHulk")
            elseif transformed["King Hulk, Sakaarson"] == true then
                woundedFury(mmZone,Turns.turn_color)
            end
        end
        function onPlayerTurn(player,previous_player)
            if transformed["King Hulk, Sakaarson"] == true then
                updateMMHulk()
            end
        end
        function onObjectEnterZone(zone,object)
            if transformed["King Hulk, Sakaarson"] ~= nil then
                updateMMHulk()
            end
        end
        function onObjectLeaveZone(zone,object)
            if transformed["King Hulk, Sakaarson"] ~= nil then
                updateMMHulk()
            end
        end
    end
    if mmname == "M.O.D.O.K." then
        local notes = getNotes()
        setNotes(notes .. "\r\n\r\n[b]Outwit[/b] requires 4 different costs instead of 3.")
        function updateMMMODOK()
            if not mmActive(mmname) then
                return nil
            end
            local buttonindex = nil
            for i,o in pairs(mmzone.getButtons()) do
                if o.click_function == "updateMMMODOK" then
                    buttonindex = i-1
                    break
                end
            end
            local mmZone = getObjectFromGUID(mmLocations[mmname])
            if transformed["M.O.D.O.K."] == false then
                if buttonindex then
                    mmZone.removeButton(buttonindex)
                end
                local notes = getNotes()
                setNotes(notes .. "\r\n\r\n[b]Outwit[/b] requires 4 different costs instead of 3.")
            elseif transformed["M.O.D.O.K."] == true then   
                local notes = getNotes()
                setNotes(notes:gsub("\r\n\r\n%[b%]Outwit%[/b%] requires 4 different costs instead of 3.",""))
                mmZone.createButton({click_function='updateMMMODOK',
                    function_owner=self,
                    position={0,0,1},
                    rotation={0,180,0},
                    label="*",
                    tooltip="You can only fight M.O.D.O.K with Recruit, not Attack.",
                    font_size=250,
                    font_color="Yellow",
                    width=0})
            end
        end
    end
    if mmname == "The Red King" then
        function updateMMRedKing()
            if not mmActive(mmname) then
                return nil
            end
            local buttonindex = nil
            local mmZone = getObjectFromGUID(mmLocations[mmname])
            for i,o in pairs(mmZone.getButtons()) do
                if o.click_function == "updateMMRedKing" then
                    buttonindex = i-1
                    break
                end
            end
            local villainfound = 0
            if transformed["The Red King"] == false then
                for _,o in pairs(city_zones_guids) do
                    if o ~= city_zones_guids[1] then
                        local citycontent = get_decks_and_cards_from_zone(o)
                        if citycontent[1] then
                            for _,p in pairs(citycontent) do
                                if p.hasTag("Villain") then
                                   villainfound = villainfound + 1
                                   break
                                end
                            end
                            if villainfound > 0 then
                                break
                            end
                        end
                    end
                end
            end
            mmButtons(mmname,
                villainfound,
                "X",
                "You can't fight the Red King while any Villains are in the city.",
                'updateMMRedKing')
        end
        function onObjectEnterZone(zone,object)
            if transformed["The Red King"] == false then
                updateMMRedKing()
            end
        end
        function onObjectLeaveZone(zone,object)
            if transformed["The Red King"] == false then
                updateMMRedKing()
            end
        end
    end
    if mmname == "The Sentry" then
        function updateMMSentry()
            if not mmActive(mmname) then
                return nil
            end
            local buttonindex = nil
            local mmZone = getObjectFromGUID(mmLocations[mmname])
            for i,o in pairs(mmZone.getButtons()) do
                if o.click_function == "updateMMSentry" then
                    buttonindex = i-1
                    break
                end
            end
            if transformed["The Sentry"] == true then
                woundedFury(mmZone,Turns.turn_color)
            elseif transformed["The Sentry"] == false then
                mmButtons(mmname,
                    0,
                    "",
                    "",
                    'updateMMSentry',
                    "woundedfury")
            end
        end
        function onPlayerTurn(player,previous_player)
            if transformed["The Sentry"] == true then
                updateMMSentry()
            end
        end
        function onObjectEnterZone(zone,object)
            if transformed["The Sentry"] == true then
                updateMMSentry()
            end
        end
        function onObjectLeaveZone(zone,object)
            if transformed["The Sentry"] == true then
                updateMMSentry()
            end
        end
    end
end

function import_setup()
    log("Generating imported setup...")
    playercount = #Player.getPlayers()
    local vildeck_done = {}
    setupParts = {}
    for s in string.gmatch(setupText,"[^\r\n]+") do
        table.insert(setupParts, s)
    end

    -- SCHEME
    log("Scheme: " .. setupParts[1])
    print("Scheme: " .. setupParts[1])
    print("\n")
    local schemePile = getObjectFromGUID(schemePileGUID)
    local schemeZone = getObjectFromGUID(schemeZoneGUID)
    for _,o in pairs(schemePile.getObjects()) do
        if string.lower(o.name) == string.lower(setupParts[1]) then
            log ("Found scheme: " .. o.name)
            schemePile.takeObject({position=schemeZone.getPosition(),
                guid=o.guid,
                smooth=false,
                flip=true})
        end
    end
    
    -- WOUNDS
    
    if setupParts[4] != "0" then
        log("Wound stack reduced to " .. setupParts[4])
        reduceStack(tonumber(setupParts[4]),woundsDeckGUID)
    end
    
    -- MASTERMIND
    
    log("Mastermind: " .. setupParts[5])
    print("Mastermind: " .. setupParts[5])
    print("\n")
    local mmPile=getObjectFromGUID(mmPileGUID)
    local mmZone=getObjectFromGUID(mmZoneGUID)
    local mmname = setupParts[5]
    local strikeZone = getObjectFromGUID(strikeZoneGUID)
    local epicness = false
    table.insert(masterminds,mmname)
    if mmname:find(" %- epic") then
        log("Epic mastermind!")
        mmname = mmname:gsub(" %- epic","")
        epicness = true
    end
    mmLocations = {[mmname] = mmZoneGUID}
    getObjectFromGUID("f3c7e3").Call('retrieveMM')
    local mmcardnumber = mmGetCards(mmname) 
    
    local mmShuffle = function(obj)
        local mm = obj
        if mmcardnumber == 4 then
            mm.randomize()
            log("Mastermind tactics shuffled")
            if setupParts[1] == "World War Hulk" then
                mm.takeObject().destruct()
                mm.takeObject().destruct()
            end
            return mm
        end
        
        if setupParts[1] == "Hidden Heart of Darkness" then
            local vilDeckZone = getObjectFromGUID(villainDeckZoneGUID)
            for i=1,4 do
                log("Mastermind Tactics Into Villain Deck")
                mm.takeObject({position=vilDeckZone.getPosition(),
                    smooth=false,
                    flip=false,
                    index=0})
            end
            return mm
        end
        
        local mmSepShuffle = function(obj)
            if epicness == true then
                obj.hide_when_face_down = false
            end
            setupMasterminds(obj.getName(),epicness)
            mm.flip()
            mm.randomize()
            log("Mastermind tactics shuffled")
            if setupParts[1] == "World War Hulk" then
                mm.takeObject().destruct()
                mm.takeObject().destruct()
            end
        end
        if mmcardnumber == 5 then
            mm.takeObject({
                position={x=mm.getPosition().x,
                    y=mm.getPosition().y+2,
                    z=mm.getPosition().z},
                    flip = epicness,
                    callback_function = mmSepShuffle
                })
            return mm
        end
    end
    
    for _,o in pairs(mmPile.getObjects()) do
        if string.lower(o.name) == string.lower(mmname) then
            log ("Found mastermind: " .. setupParts[5])
            mmPile.takeObject({guid=o.guid,
                position=mmZone.getPosition(),
                smooth=false,
                flip=true,
                callback_function = mmShuffle})
        end
    end
    
    -- Master Strike
    
    log("Master strikes: 5")
    local msPile = getObjectFromGUID(strikePileGUID)
    local vilDeckZone = getObjectFromGUID(villainDeckZoneGUID)
    table.insert(vildeck_done,5)
    for i = 1,5 do
        msPile.takeObject({position = vilDeckZone.getPosition(),
            flip = false,
            smooth = false})
    end
    log("5 Master strikes added to villain deck.")
    
    -- Bystanders
    
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    bsPile.randomize()
    local bsCount = tonumber(setupParts[3])
    log("Bystanders: " .. bsCount)
    table.insert(vildeck_done,bsCount)
    if mmname ~= "Mojo" then
        for i=1,bsCount do
            bsPile.takeObject({position = vilDeckZone.getPosition(),
                flip = true,
                smooth = false})
            log(bsCount .. " bystanders added to villain deck.")
        end
    else
        mojoVPUpdate(bsCount,epicness)
    end
    
    if mmname == "The Sentry" then
        local woundstack = getObjectFromGUID(woundsDeckGUID)
        for i=1,5 do
            if Player[playercolors[i]].seated == true then
                local playerdeck = getObjectFromGUID(playerBoards[playercolors[i]]).Call('returnDeck')
                woundstack.takeObject({position = playerdeck.getPosition()})
                woundstack.takeObject({position = playerdeck.getPosition()})
            end
        end
        log("Wounds added to player starter decks. Still shuffle!")
        broadcastToAll("2 wounds in starter deck because of The Sentry. Bastard.")
    end

    -- Scheme twists
    
    if setupParts[1] ~= "Fragmented Realities" then        
        local twistcount = tonumber(setupParts[2])
        log("Scheme twists: " .. twistcount)
        table.insert(vildeck_done,twistcount)
        local twistPile = getObjectFromGUID(twistPileGUID)
        for i=1,twistcount do
            twistPile.takeObject({position=vilDeckZone.getPosition(),
                flip=false,
                smooth=false})    
        end
        log(twistcount .. " scheme twists added to villain deck.")
        schemeSpecials(setupParts,mmGUID)
    end
    
    if setupParts[1] == "The Demon Bear Saga" then
        log("Taking the demon bear out.")
        setupParts[6] = setupParts[6]:gsub("Demons of Limbo|","")
        local extractBear = function(obj)
            for _,o in pairs(obj.getObjects()) do
                if o.name == "Demon Bear" then
                    obj.takeObject({position=twistpile.getPosition(),
                        flip=false,smooth=false,guid=o.guid})
                    obj.setPositionSmooth(vilDeckZone.getPosition())
                    break
                end
            end
            log("Demon Bear moved to twists pile. Other demons to villain deck.")
        end
        findInPile("Demons of Limbo",villainPileGUID,topBoardGUIDs[1],extractBear)
        table.insert(vildeck_done,7)
    end
    
    -- Villain groups
    
    log(setupParts[6])
    local vilgroups = setupParts[6]:gsub("%|","\n")
    print("Villain Groups:\n" .. vilgroups)
    print("\n")
    local villainPile = getObjectFromGUID(villainPileGUID)
    local vilParts = {}
    for s in string.gmatch(setupParts[6],"[^|]+") do
        table.insert(vilParts, string.lower(s))
    end
    table.insert(vildeck_done,#vilParts*8)
    
    for _,object in pairs(villainPile.getObjects()) do
        for _,o in pairs(vilParts) do
            if o == string.lower(object.name) then
                log ("Found villain group: " .. object.name)
                villainPile.takeObject({guid=object.guid,
                    position=vilDeckZone.getPosition(),
                    smooth=false,
                    flip=true})
            end
        end
    end
    
    -- Henchmen groups
    
    log(setupParts[7])
    local hengroups = setupParts[7]:gsub("%|","\n")
    print("Henchmen Groups:\n" .. hengroups)
    print("\n")
    local hmPile=getObjectFromGUID(hmPileGUID)
    local hmParts = {}
    for s in string.gmatch(setupParts[7],"[^|]+") do
        table.insert(hmParts, string.lower(s))
    end
    table.insert(vildeck_done,#hmParts*10)
    for _,object in pairs(hmPile.getObjects()) do
        for _,o in pairs(hmParts) do
            if o == string.lower(object.name) then
                log ("Found henchmen group: " .. object.name)
                hmPile.takeObject({guid=object.guid,
                    position=vilDeckZone.getPosition(),
                    smooth=false,
                    flip=true})
            end
        end
    end
    
    if setupParts[1] == "Brainwash the Military" then
        log("12 officers in villain deck.")
        local sopile = getObjectFromGUID(officerDeckGUID)
        sopile.randomize()
        for i=1,12 do
            sopile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,
                smooth=false})
        end
        table.insert(vildeck_done,12)
    end
    
    if setupParts[1] == "Corrupt the Next Generation of Heroes" then
        log("Add 10 sidekicks to villain deck.")
        local skPile = getObjectFromGUID(sidekickDeckGUID)
        skPile.randomize()
        for i=1,10 do
            skPile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,
                smooth=false})
        end
        table.insert(vildeck_done,10)
    end
    
    if setupParts[1] == "Hidden Heart of Darkness" then  
        table.insert(vildeck_done,4)
    end
    
    if setupParts[1] == "House of M" then
        log("Scarlet Witch in villain deck.")
        findInPile("Scarlet Witch (R)",heroPileGUID,villainDeckZoneGUID)
        table.insert(vildeck_done,14)
    end
    
    if setupParts[1] == "Master of Tyrants" then
        log("Moving extra masterminds outside the board.")
        local tyrants = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tyrants, string.lower(s))
        end
        local shuffleTyrantTactics = function(obj)
              local annotateTyrant = function(obj)
                obj.setDescription("No abilities!")
                obj.addTag("Tyrant")
              end
              for i=1,4 do
                log("Mastermind Tactics Into Villain Deck")
                obj.takeObject({position=vilDeckZone.getPosition(),
                    smooth=false,
                    flip=false,
                    index=0,
                    callback_function = annotateTyrant})
              end
              local clearMMFronts = function()
                for i=1,3 do
                    local card = get_decks_and_cards_from_zone(topBoardGUIDs[i+5])
                    card[1].destruct()
                end
              end
              Wait.time(clearMMFronts,2)
        end
        for i=1,3 do
            findInPile(tyrants[i],
                mmPileGUID,
                topBoardGUIDs[i+5],
                shuffleTyrantTactics)
        end
        table.insert(vildeck_done,12)
        print("Extra mastermind tactics shuffled into villain deck! Their front cards can still be seen above the board.")
        -- still remove remaining mm cards then
        -- can stay there to show what is in the deck
    end
    
    if setupParts[1] == "Sinister Ambitions" then
        log("Add ambitions to villain deck.")
        local ambPile = getObjectFromGUID(ambPileGUID)
        ambPile.randomize()
        local pos = vilDeckZone.getPosition()
        pos.y = pos.y + 2
        local annotateAmbition = function(obj)
            obj.setName("Ambition")
            obj.addTag("Ambition")
            obj.addTag("VP4")
            obj.setDescription("When this Ambition villain escapes, do its Ambition effect.")
        end
        for i=1,10 do
            pos.y = pos.y + i/2
            ambPile.takeObject({position=pos,
                flip=false,
                smooth=false,
                callback_function=annotateAmbition})
        end
        table.insert(vildeck_done,10)
    end
    
    if setupParts[1] == "The Dark Phoenix Saga" or setupParts[1] == "Transform Citizens Into Demons" then
        log("Jean Grey in villain deck.")
        findInPile("Jean Grey (DC)",heroPileGUID,villainDeckZoneGUID)
        table.insert(vildeck_done,14)
    end
    
    if setupParts[1] == "The Mark of Khonshu" or setupParts[1] == "Trap Heroes in the Microverse" or setupParts[1] == "X-Cutioner's Song" then
        log("Extra hero " .. setupParts[9] .." in villain deck.")
        findInPile(setupParts[9],heroPileGUID,villainDeckZoneGUID)
        table.insert(vildeck_done,14)
    end
    
    local vildeckc = 0
    for _,o in pairs(vildeck_done) do
        vildeckc = vildeckc + o
    end  
    
    local vilDeckComplete = function()
        local test = vilDeckZone.getObjects()[2]
        if test ~= nil then 
            if test.getQuantity() == vildeckc then
                return true
            else
                return false
            end
        else
            return false
        end
    end   
    
    local vilDeckFlip = function()
        vildeck = vilDeckZone.getObjects()[2]
        vildeck.flip()
    end
    
    if setupParts[1] == "Five Families of Crime" then 
        local vilDeckSplit = function() 
            log("Splitting villain deck in five")
            local vilDeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
            vilDeck.randomize()
            local subcount = vilDeck.getQuantity()
            subcount = subcount / 5
            local topCityZones = table.clone(topBoardGUIDs)
            table.remove(topCityZones)
            table.remove(topCityZones,1)
            table.remove(topCityZones,1)
            for i=1,4 do
                local hqZone = getObjectFromGUID(topCityZones[i])
                for j=1,subcount do
                    vilDeck.takeObject({
                        position = {x=hqZone.getPosition().x,y=hqZone.getPosition().y+2,z=hqZone.getPosition().z},
                        flip=true})
                end
            end
            local hqZone = getObjectFromGUID(topCityZones[5])
            vilDeck.flip()
            vilDeck.setPosition(hqZone.getPosition())
            print("Villain deck split in piles above the board!")
        end
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        Wait.condition(vilDeckSplit,vilDeckComplete)
    elseif setupParts[1] == "Fragmented Realities" then
        local topCityZones = table.clone(topBoardGUIDs)
        table.remove(topCityZones)
        table.remove(topCityZones,1)
        table.remove(topCityZones,1)
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        local vildeckc2 = vildeckc + playercount*2
        log(vildeckc2)
        log("Adding scheme twists to the separate villain decks")
        for i = 6 - playercount,5 do
            local stPile = getObjectFromGUID(twistPileGUID)
            local deckZone = getObjectFromGUID(topCityZones[i])
            stPile.takeObject({position=deckZone.getPosition(),
                flip=true,smooth=false})
            stPile.takeObject({position=deckZone.getPosition(),
                flip=true,smooth=false})
        end 
        local vilDeckSplit = function() 
            log("Splitting villain deck in deck for each player")
            local vilDeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
            vilDeck.randomize()
            local subcount = vilDeck.getQuantity()
            subcount = subcount / playercount
            for i = 6 - playercount,4 do
                for j = 1,subcount do
                    local hqZone = getObjectFromGUID(topCityZones[i])
                    vilDeck.takeObject({
                        position = {x=hqZone.getPosition().x,y=hqZone.getPosition().y+2,z=hqZone.getPosition().z},
                        flip=true})
                end
            end
            local hqZone = getObjectFromGUID(topCityZones[5])
            vilDeck.flip()
            vilDeck.setPosition(hqZone.getPosition())
            print("Villain deck split in piles above the board!")
        end
        local decksShuffle = function()
            for i=1,5 do
                if i > 5 - playercount then
                    local deck = get_decks_and_cards_from_zone(topCityZones[i])[1]
                    local zone = getObjectFromGUID(topCityZones[i])
                    deck.randomize()
                    local color = Player.getPlayers()[6-i].color
                    deck.addTag(color)
                    zone.addTag(color)
                    zone.createButton({click_function='returnColor',
                        function_owner=self,
                        position={0,0,0},
                        rotation={0,180,0},
                        label="Deck",
                        tooltip=color .. " player's deck",
                        font_size=250,
                        font_color=color,
                        color=color,
                        width=0})
                else
                    getObjectFromGUID(city_zones_guids[i+3]).createButton({
                        click_function="nonCityZone",
                        function_owner=self,
                        position={0,-0.5,0},
                        height=470,
                        width=700,
                        color={1,0,0,0.9}})
                end
            end
            
        end
        local decksMade = function()
            local test2 = 0
            for i=6-playercount,5 do
                local deck = get_decks_and_cards_from_zone(topCityZones[i])[1]
                if deck then
                    test2 = test2 + deck.getQuantity()
                end
            end
            if test2 == vildeckc2 then
                return true
            else
                return false
            end
        end
        Wait.condition(vilDeckSplit,vilDeckComplete)
        Wait.condition(decksShuffle,decksMade)
    else
        log("villain deck size = " .. vildeckc)
        Wait.condition(vilDeckFlip,vilDeckComplete)
    end
    
    -- Heroes
    
    log(setupParts[8])
    local herogroups = setupParts[8]:gsub("%|","\n")
    print("Heroes:\n" .. herogroups)
    local heroPile = getObjectFromGUID(heroPileGUID)
    local heroZone = getObjectFromGUID(heroDeckZoneGUID)
    local heroParts = {}
    for s in string.gmatch(setupParts[8],"[^|]+") do
        table.insert(heroParts, string.lower(s))
    end
    
    if setupParts[1] == "Divide and Conquer" then
        local dividedDeckGUIDs = {
            ["HC:Red"]="4c1868",
            ["HC:Green"]="8656c3",
            ["HC:Yellow"]="533311",
            ["HC:Blue"]="3d3ba7",
            ["HC:Silver"]="725c5d"
        }
        local tempDeckGUIDs ={
        "1fa829",
        "bf7e87",
        "82ccd7",
        "5bc848",
        "07423f",
        "5a74e7",
        "40b47d"
        }
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        local divideSort = function(obj)
            --log(obj)
            local remo = 0
            for i,o in ipairs(obj.getObjects()) do
                local colors = {}
                for _,tag in pairs(o.tags) do
                    if tag:find("HC:") then
                        table.insert(colors,tag)
                    end
                end
                if #colors > 1 then
                    table.remove(colors,math.random(2))
                end
                local dividedDeckZone = getObjectFromGUID(dividedDeckGUIDs[colors[1]])
                if not obj.remainder then
                    obj.takeObject({index = i-1-remo,
                        position=dividedDeckZone.getPosition(),
                        smooth=false,
                        flip=true})
                    remo = remo + 1
                else
                    local temp = obj.remainder
                    temp.flip()
                    colors = {}
                    for _,tag in pairs(temp.getTags()) do
                        if tag:find("HC:") then
                            table.insert(colors,tag)
                        end
                    end
                    if #colors > 1 then
                        table.remove(colors,math.random(2))
                    end
                    dividedDeckZone = getObjectFromGUID(dividedDeckGUIDs[colors[1]])
                    temp.setPosition(dividedDeckZone.getPosition())
                end
            end
        end
        for i,o in pairs(heroParts) do
            for _,object in pairs(heroPile.getObjects()) do
                if o == string.lower(object.name) then
                    log ("Found hero: " .. object.name)
                    local heroGUID = object.guid
                    local tempZone = getObjectFromGUID(tempDeckGUIDs[i])
                    heroPile.takeObject({guid=heroGUID,
                        position=tempZone.getPosition(),
                        smooth=false,flip=true,
                        callback_function=divideSort})
                end
            end
        end
    else
        for _,o in pairs(heroParts) do
            for _,object in pairs(heroPile.getObjects()) do
                if o == string.lower(object.name) then
                    log ("Found hero: " .. object.name)
                    local heroGUID = object.guid
                    heroPile.takeObject({guid=heroGUID,
                        position=heroZone.getPosition(),
                        smooth=false,flip=true})
                end
            end
        end
        local heroDeckComplete = function()
            local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
            if herodeck and herodeck.getQuantity() == #heroParts*14 then
                return true
            else
                return false
            end
        end
        local heroDeckFlip = function()
            local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
            herodeck.flip()
        end
        if setupParts[1] == "Secret Invasion of the Skrull Shapeshifters" then
            local skrullShuffle = function() 
                log("Shuffle 12 hero cards in villain deck.")
                print("12 random hero cards shuffled into villain deck.")
                local heroDeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
                heroDeck.randomize()
                heroDeck.flip()
                for i=1,12 do
                    heroDeck.takeObject({position=vilDeckZone.getPosition(),
                        flip=true,smooth=false})
                end
            end
            Wait.condition(skrullShuffle,heroDeckComplete)
        else
            Wait.condition(heroDeckFlip,heroDeckComplete)
        end
    end
    return nil
end

function schemeSpecials (setupParts,mmGUID)
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    bsPile.randomize()
    local sopile = getObjectFromGUID(officerDeckGUID)
    sopile.randomize()
    local vilDeckZone = getObjectFromGUID(villainDeckZoneGUID)
    local schemZone = getObjectFromGUID(schemeZoneGUID)
    local skPile = getObjectFromGUID(sidekickDeckGUID)
    skPile.randomize()
    local twistpile = getObjectFromGUID(twistZoneGUID)
    local wndPile = getObjectFromGUID(woundsDeckGUID)
    wndPile.randomize()
    local mmZone = getObjectFromGUID(mmZoneGUID)
    local stPile = getObjectFromGUID(twistPileGUID)
    local heroZone = getObjectFromGUID(heroDeckZoneGUID)

    if setupParts[1] == "Build an Army of Annihilation" then
        log("Add extra annihilation group.")
        local renameHenchmen = function(obj)
            for i=1,10 do
                local cardTaken = obj.takeObject({position=getObjectFromGUID(topBoardGUIDs[2]).getPosition()})
                cardTaken.setName("Annihilation Wave Henchmen")
            end
        end
        findInPile(setupParts[9],hmPileGUID,topBoardGUIDs[1],renameHenchmen)
        for i = 1,2 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        print("Annihilation group " .. setupParts[9] .. " moved next to the scheme.")
    end
    if setupParts[1] == "Cage Villains in Power-Suppressing Cells" then
        log("Add extra cops henchmen.")
        local ditchCops = function(obj)
            local copstoditch = 10-playercount*2
            local henchpos = getObjectFromGUID(hmPileGUID).getPosition()
            henchpos.y = henchpos.y + 5
            for i = 1,copstoditch do
                obj.takeObject({position=henchpos,smooth=false})
            end
        end
        findInPile("Cops",hmPileGUID,topBoardGUIDs[4],ditchCops)
        print("Cops moved next to scheme.")
    end
    if setupParts[1] == "Capture Baby Hope" then
        log("Baby hope token moved to scheme.")
        local babyHope = getObjectFromGUID("e27f77")
        babyHope.locked = false
        babyHope.setTags({"VP6"})
        babyHope.setPosition(schemZone.getPosition())
    end
    if setupParts[1] == "Clash of the Monsters Unleashed" then
        log("Add extra Monsters Unleashed villains.")
        local monsterPitRandomize = function(obj)
            obj.flip()
            obj.randomize()
        end
        findInPile("Monsters Unleashed",villainPileGUID,twistZoneGUID,monsterPitRandomize)
        print("Monsters Unleashed moved to twists pile.")
    end
    if setupParts[1] == "Crown Thor King of Asgard" then
        log("Add extra Avengers villain group.")
        local onlyThor = function(obj)
            for _,o in pairs(obj.getObjects()) do
                if o.name == "Thor" then
                    obj.takeObject({position=twistpile.getPosition(),
                        flip=false,
                        smooth=false,
                        guid=o.guid})
                    obj.destruct()
                    break
                end
            end
            print("Thor moved to twists pile.")
        end
        findInPile("Avengers",villainPileGUID,topBoardGUIDs[1],onlyThor)
    end
    if setupParts[1] == "Cytoplasm Spike Invasion" then
        log("Make a cytoplasm and bystander infected deck.")
        findInPile("Cytoplasm Spikes",hmPileGUID,twistZoneGUID)
        for i=1,20 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=true,smooth=false})
        end
        local infectedDeckReady = function()
            local infectedDeck = get_decks_and_cards_from_zone(twistZoneGUID)[1]
            if infectedDeck and infectedDeck.getQuantity() == 30 then
                return true
            else
                return false
            end
        end
        local infectedDeckShuffle = function()
            local infectedDeck = get_decks_and_cards_from_zone(twistZoneGUID)[1]
            infectedDeck.flip()
            infectedDeck.randomize()
        end
        Wait.condition(infectedDeckShuffle,infectedDeckReady)
        print("Infected deck moved to twists pile.")
    end
    if setupParts[1] == "Dark Alliance" then
        for i = 2,4 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "Dark Reign of H.A.M.M.E.R. Officers" then
        addMMGUIDS[topBoardGUIDs[2]] = true
    end
    if setupParts[1] == "Destroy the Nova Corps" then
        sopile.randomize()
        wndPile.randomize()
        local novaDist = function(obj)
            log("Moving additional cards to starter decks.")
            local novaguids = {}
            for _,o in pairs(obj.getObjects()) do
                for _,p in pairs(o.tags) do
                    if p == "Cost:2" then
                        table.insert(novaguids,o.guid)
                    end
                end
            end
            for i,o in pairs(Player.getPlayers()) do
                local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')
                wndPile.takeObject({position=playerdeck.getPosition(),
                    flip=false,
                    smooth=false})
                wndPile.takeObject({position=playerdeck.getPosition(),
                    flip=false,
                    smooth=false})    
                sopile.takeObject({position=playerdeck.getPosition(),
                    flip=false,
                    smooth=false})
                obj.takeObject({position=playerdeck.getPosition(),
                    flip=true,
                    smooth=false,
                    guid=novaguids[i]})
            end
        end
        findInPile(setupParts[9],heroPileGUID,topBoardGUIDs[1],novaDist)
        local novaMoved = function()
            local novaloc = get_decks_and_cards_from_zone(topBoardGUIDs[1])
            local q = 14 - playercount
            if novaloc[1] and novaloc[1].getQuantity() == q then
                return true
            else
                return false
            end
        end
        local novaShuffle = function()
            log("Moving remaining Nova cards to hero deck.")
            local novaloc = get_decks_and_cards_from_zone(topBoardGUIDs[1])
            local q = 14 - playercount
            for i=1,q do
                novaloc[1].takeObject({position=heroZone.getPosition(),
                    flip=true,smooth=false})
            end
        end
        Wait.condition(novaShuffle,novaMoved)
    end
    if setupParts[1] == "Earthquake Drains the Ocean" then
        getObjectFromGUID("f3c7e3").Call('cityLowTides')
    end
    if setupParts[1] == "Enthrone the Barons of Battleworld" then
        for i = 3,8 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "Explosion at the Washington Monument" then
        log("Set up the Washington Monument stacks...")
        local topzone = getObjectFromGUID(topBoardGUIDs[1])
        log("Gathering wounds and bystanders...")
        for i=1,18 do
            bsPile.takeObject({position=topzone.getPosition(),
                flip=false,smooth=false})
        end
        for i=1,14 do
            wndPile.takeObject({position=topzone.getPosition(),
                flip=false,smooth=false})
        end
        for i = 1,8 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        log("Shuffle..")
        local stack_created = function() 
            local test = get_decks_and_cards_from_zone(topBoardGUIDs[1])[1]
            if test and test.getQuantity() == 32 then
                return true
            else
                return false
            end
        end
        local stack_floors = function()
            local floorstack = get_decks_and_cards_from_zone(topBoardGUIDs[1])[1]
            floorstack.randomize()
            for i = 2,8 do
                log("Creating floor " .. i)
                local floorZone = getObjectFromGUID(topBoardGUIDs[i]).getPosition()
                floorZone.y = floorZone.y + 2
                for j=1,4 do
                    floorstack.takeObject({
                        position = floorZone,
                        flip=false})
                end
            end
        end
        Wait.condition(stack_floors,stack_created)
        print("Washington monument stacks created!")
    end
    if setupParts[1] == "Fear Itself" then
        print("HQ has size of 8 minus resolved twists. Not scripted.")
    end
    if setupParts[1] == "Ferry Disaster" then
        getObjectFromGUID(bystandersPileGUID).setPositionSmooth(getObjectFromGUID(topBoardGUIDs[7]).getPosition())
        print("Bystander stack moved above the Sewers.")
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "Go Back in Time to Slay Heroes' Ancestors" then
        local twistzone = getObjectFromGUID(twistZoneGUID)
        twistzone.createButton({click_function='returnColor',
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            label="Purged",
            tooltip="Put purged heroes here",
            font_size=250,
            font_color={1,0,0},
            width=0})
    end
    if setupParts[1] == "Graduation at Xavier's X-Academy" then
        log("8 bystanders next to scheme")
        for i=1,8 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Horror of Horrors" then
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "Hypnotize Every Human" then
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "Infiltrate the Lair with Spies" then
        log("21 bystanders next to scheme")
        for i=1,21 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Intergalactic Kree Nega-Bomb" then
        log("6 bystanders next to scheme")
        for i=1,6 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Invade the Daily Bugle News HQ" then
        log("6 extra henchmen in hero deck.")
        local bugleInvader = function(obj)
            for i=1,6 do
                obj.takeObject({position=heroZone.getPosition(),
                    flip=false,smooth=false})
            end
            local hmPile = getObjectFromGUID(hmPileGUID)
            for i=1,4 do
                obj.takeObject({position=hmPile.getPosition(),
                    flip=false,smooth=false})
            end
        end
        findInPile(setupParts[9],hmPileGUID,twistZoneGUID,bugleInvader)
    end
    if setupParts[1] == "Mutating Gamma Rays" or setupParts[1] == "Shoot Hulk into Space" then
        log("Extra Hulk hero in mutation pile.")
        local hulkshuffle = function(obj)
            obj.flip()
            obj.randomize()
        end
        findInPile(setupParts[9],heroPileGUID,twistZoneGUID,hulkshuffle)
    end
    if setupParts[1] == "Ruin the Perfect Wedding" then
        local tobewed = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tobewed, string.lower(s))
        end
        for i = 1,8 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        log("Extra heroes to be wed in separate piles.")
        local orderAdam = function(obj)
            for _,o in pairs(obj.getObjects()) do
                local pos = obj.getPosition()
                for _,k in pairs(o.tags) do
                    if k:find("Cost:") then
                        pos.y = pos.y + 12 - k:match("%d+")
                        break
                    end
                end
                if obj.getQuantity() > 1 then
                    obj.takeObject({position=pos,
                        guid = o.guid})
                    if obj.remainder then
                        obj = obj.remainder
                    end
                else
                    obj.setPositionSmooth(pos)
                end
            end
        end
        findInPile(tobewed[1],heroPileGUID,topBoardGUIDs[1],orderAdam)
        findInPile(tobewed[2],heroPileGUID,topBoardGUIDs[8],orderAdam)
    end
    if setupParts[1] == "Replace Earth's Leaders with Killbots" then
        log("Set up 3 twists next to scheme already.")
        for i=1,3 do
            stPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Save Humanity" then
        local saveHumanity = function()
            local bsPile = getObjectFromGUID(bystandersPileGUID)
            for i=1,24 do
                bsPile.takeObject({position = heroZone.getPosition(),
                    smooth=false})
            end
        end
        broadcastToAll("Save Humanity: Adding bystanders to the hero deck, please wait...")
        Wait.time(saveHumanity,2.5)
    end
    if setupParts[1] == "Scavenge Alien Weaponry" or setupParts[1] == "Devolve with Xerogen Crystals" then
        log("Identify the smugglers/experiments group.")
        --annotation done in the push villain zone
        print(setupParts[9] .. " is the Smugglers/experiments group.")
    end
    if setupParts[1] == "Secret Empire of Betrayal" then
        log("Extra hero in dark betrayal pile.")
        local betrayalDeck = function(obj)
            obj.randomize()
            obj.flip()
            local keepguids= {}
            local objcontent = obj.getObjects()
            for _,o in pairs(objcontent) do
                for _,k in pairs(o.tags) do
                    if k:find("Cost:") and tonumber(k:match("%d+")) < 6 then
                        table.insert(keepguids,o.guid)
                        break
                    end
                end
                if #keepguids == 5 then
                    break
                end
            end
            local falsepos = getObjectFromGUID(heroPileGUID).getPosition()
            falsepos.x = falsepos.x + 15
            for i=1,14 do
                local tonext = false
                for j=1,5 do
                    if keepguids[j] and objcontent[i].guid == keepguids[j] then
                       tonext = true 
                       --duplicate guids can occur, so remove found ones from table
                       table.remove(keepguids,j)
                       break
                    end
                end
                if tonext == false then
                    obj.takeObject({position=falsepos,
                        guid = objcontent[i].guid,
                        smooth=false})
                end
            end
        end
        addMMGUIDS[topBoardGUIDs[5]] = true
        findInPile(setupParts[9],heroPileGUID,topBoardGUIDs[5],betrayalDeck)
    end
    if setupParts[1] == "Secret HYDRA Corruption" then
        log("Only 30 shield officers.")
        reduceStack(30,officerDeckGUID)
    end
    if setupParts[1] == "Secret Wars" then
        for i = 3,8 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "Steal All Oxygen on Earth" then
        setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Oxygen Level:[/b][-] 8")
    end
    if setupParts[1] == "Subjugate with Obedience Disks" then
        local dividedDeckGUIDs = {
            ["HC:Red"]="4c1868",
            ["HC:Green"]="8656c3",
            ["HC:Yellow"]="533311",
            ["HC:Blue"]="3d3ba7",
            ["HC:Silver"]="725c5d"
        }
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        for i,o in pairs(dividedDeckGUIDs) do
            getObjectFromGUID(o).createButton({
                click_function="obedienceDisk",
                function_owner=self,
                tooltip="Put the Obedience Disks (Scheme Twists) here.",
                position={0,-0.4,0},
                height=550,
                width=500,
                color={0,1,0,0.6}})
        end
    end
    if setupParts[1] == "Superhuman Baseball Game" or setupParts[1] == "Smash Two Dimensions Together" then
        print("Not scripted yet!")
    end
    if setupParts[1] == "Symbiotic Absorption" then
        log("Add extra drained mastermind.")
        local mmshuffle = function(obj)
            local mm = obj
            local mmcardnumber = mmGetCards(mm.getName())
            if mmcardnumber == 4 then
                mm.randomize()
                log("Mastermind tactics shuffled")
            end
            local mmSepShuffle = function(obj)
                mm.flip()
                mm.randomize()
                log("Mastermind tactics shuffled")
            end
            if mmcardnumber == 5 then
                mm.takeObject({
                    position={x=mm.getPosition().x,
                        y=mm.getPosition().y+2,
                        z=mm.getPosition().z},
                        flip = false,
                        callback_function = mmSepShuffle
                    })
            end
        end
        addMMGUIDS[topBoardGUIDs[1]] = true
        findInPile(setupParts[9],mmPileGUID,topBoardGUIDs[1],mmshuffle)
    end
    if setupParts[1] == "The Contest of Champions" then
        local heroParts = {}
        for s in string.gmatch(setupParts[8],"[^|]+") do
            table.insert(heroParts, string.lower(s))
        end
        local heroDeckComplete = function()
            local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
            if herodeck and herodeck.getQuantity() == #heroParts*14 then
                return true
            else
                return false
            end
        end
        local makeChampions = function()
            local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
            herodeck.randomize()
            if not herodeck.is_face_down then
                herodeck.flip()
            end
            for i = 1,8 do
                addMMGUIDS[topBoardGUIDs[i]] = true
            end
            addMMGUIDS["f394e1"] = true
            addMMGUIDS["0559f8"] = true
            addMMGUIDS["39e3d7"] = true
            local posi = getObjectFromGUID(topBoardGUIDs[1])
            print("Putting 11 contestants above the board!")
            contestants = {}
            logContestant = function(obj)
                table.insert(contestants,obj.guid)
            end
            returnContestants = function()
                return contestants
            end
            for i=1,11 do
                Wait.time(function() herodeck.takeObject({
                    position = {x=posi.getPosition().x+4*i,y=posi.getPosition().y,z=posi.getPosition().z},
                    flip = true,
                    callback_function = logContestant
                }) end,i/3)
            end
        end
        Wait.condition(makeChampions,heroDeckComplete)
    end
    if setupParts[1] == "The Kree-Skrull War" then
        addMMGUIDS[topBoardGUIDs[2]] = true
        addMMGUIDS[topBoardGUIDs[4]] = true
    end
    if setupParts[1] == "Tornado of Terrigen Mists" then
        log("Add player tokens.")
        local sewers = getObjectFromGUID(city_zones_guids[2])
        playcolors = {}
        local annotateTokens = function(obj)
            --log(playcolors)
            local color = table.remove(playcolors,1)
            obj.setColorTint(color)
            obj.setName(color .. " Player")
            obj.mass = 0
            obj.drag = 10000
            obj.angular_drag = 10000
        end
        for i = 3,7 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        for i=1,playercount do
            if i < 4 then
                newtoken = spawnObject({type="PlayerPawn",
                    position = {x=sewers.getPosition().x,y=sewers.getPosition().y,z=sewers.getPosition().z+i*0.5},
                    callback_function = annotateTokens
                })
                table.insert(playcolors,Player.getPlayers()[i].color)
            elseif i == 4 then
                newtoken = spawnObject({type="PlayerPawn",
                    position = {x=sewers.getPosition().x+i*0.5,y=sewers.getPosition().y,z=sewers.getPosition().z},
                    callback_function = annotateTokens
                })
                table.insert(playcolors,Player.getPlayers()[i].color)
            else
                newtoken = spawnObject({type="PlayerPawn",
                    position = {x=sewers.getPosition().x+i*0.5,y=sewers.getPosition().y,z=sewers.getPosition().z+1},
                    callback_function = annotateTokens
                })
                table.insert(playcolors,Player.getPlayers()[i].color)
            end
        end
    end
    if setupParts[1] == "Turn the Soul of Adam Warlock" then
        log("Set up Adam Warlock pile.")
        local orderAdam = function(obj)
            for _,o in pairs(obj.getObjects()) do
                local pos = obj.getPosition()
                for _,k in pairs(o.tags) do
                    if k:find("Cost:") then
                        pos.y = pos.y + 12 - k:match("%d+")
                        break
                    end
                end
                if obj.getQuantity() > 1 then
                    obj.takeObject({position=pos,
                        guid = o.guid})
                    if obj.remainder then
                        obj = obj.remainder
                    end
                else
                    obj.setPositionSmooth(pos)
                end
            end
        end
        findInPile("Adam Warlock (ITC)",heroPileGUID,topBoardGUIDs[1],orderAdam)
        addMMGUIDS[topBoardGUIDs[1]] = true
    end
    if setupParts[1] == "United States Split by Civil War" then
        for i = 1,2 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
    end
    if setupParts[1] == "World War Hulk" then
        finalblow = false
        finalblowfixed = true
        log("Moving extra masterminds outside game.")
        lurkingMasterminds = {}
        function returnLurking()
            return lurkingMasterminds
        end
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(lurkingMasterminds, s)
        end
        log("lurkers = ")
        log(lurkingMasterminds)
        for i = 1,6 do
            addMMGUIDS[topBoardGUIDs[i]] = true
        end
        local tacticsKill = function(obj)
            for i=1,3 do
                if lurkingMasterminds[i] == obj.getName() then
                    local zonetokill = getObjectFromGUID(topBoardGUIDs[i*2])
                    mmLocations[obj.getName()] = topBoardGUIDs[i*2]
                    setupMasterminds(obj.getName(),false,true)
                    for j,o in pairs(zonetokill.getObjects()) do
                        if o.name == "Deck" then
                            decktokill = zonetokill.getObjects()[j]
                            decktokill.flip()
                        end
                    end
                end
            end
            decktokill.randomize()
            decktokill.takeObject({index=0}).destruct()
            decktokill.takeObject({index=0}).destruct()
        end
        local tyrantShuffleHulk = function(obj)
            if obj.getQuantity() == 4 then
                obj.randomize()
                obj.takeObject.destruct()
                obj.takeObject.destruct()
            end
            if obj.getQuantity() == 5 then
                local posabove = obj.getPosition()
                posabove.y = posabove.y +2
                obj.takeObject({position=posabove,
                    smooth=true,
                    index=4,
                    callback_function = tacticsKill})
            end
        end
        for i=1,3 do
            findInPile(lurkingMasterminds[i],mmPileGUID,topBoardGUIDs[i*2],tyrantShuffleHulk)
        end
    end
    return nil
end

function mmActive(mmname)
    for _,o in pairs(masterminds) do
        if o == mmname or o == mmname .. " - epic" then
            return true
        end
    end
    return false
end

function updateMM()
    masterminds = table.clone(getObjectFromGUID("f3c7e3").Call('returnMM'))
    mmLocations = table.clone(getObjectFromGUID("f3c7e3").Call('returnMM',{true}),true)
end

function setupMasterminds(objname,epicness,lurking)
    if not lurking then
        fightButton(mmLocations[objname])
    end
    if mmGetCards(objname,true) == true then
        setupTransformingMM(objname,getObjectFromGUID(mmLocations[objname]),lurking)
    end
    if objname == "Arcade" or objname == "Arcade - epic" then
        local arc = 5
        if epicness == true then
            arc = 8
            playHorror()
        end
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        for i=1,arc do
            bsPile.takeObject({position=getObjectFromGUID(mmLocations[objname]).getPosition(),
                flip=false,
                smooth=false})
        end
    end
    if objname == "Baron Heinrich Zemo" then
        if not mmActive(objname) then
            return nil
        end
        local mmzone = getObjectFromGUID(mmLocations[objname])
        mmzone.createButton({click_function='returnColor',
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            label="+9",
            tooltip="The Baron gets +9 as long as you're not a Savior of at least 3 bystanders.",
            font_size=500,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
        updateMMBaronHein = function()
            local color = Turns.turn_color
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[color])
            local savior = 0
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    for _,l in pairs(k.tags) do
                        if l == "Bystander" then
                            savior = savior + 1
                            break
                        end
                    end
                    if savior > 2 then
                        break
                    end
                end
            end
            Wait.time(function() mmButtons(objname,
                math.max(savior-2,0),
                "+9",
                "The Baron gets +9 as long as you're not a Savior of at least 3 bystanders.",
                'updateMMBaronHein') end,1)
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Bystander") then
                Wait.time(updateMMBaronHein,2)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Bystander") then
                Wait.time(updateMMBaronHein,2)
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMBaronHein()
        end
    end
    if objname == "Baron Helmut Zemo" then
        updateMMBaronHelm = function()
            if not mmActive(objname) then
                return nil
            end
            local color = Turns.turn_color
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[color])
            local savior = 0
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    for _,l in pairs(k.tags) do
                        if l == "Villain" then
                            savior = savior + 1
                            break
                        end
                    end
                end
            elseif vpilecontent[1] then
                if vpilecontent[1].hasTag("Villain") then
                    savior = 1
                end
            end
            Wait.time(function() mmButtons(objname,
                savior,
                "-" .. savior,
                "The Baron gets -1 for each villain in your victory pile.",
                'updateMMBaronHelm') end,1)
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMBaronHelm,2)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMBaronHelm,2)
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMBaronHelm()
        end
    end
    if objname == "Belasco, Demon Lord of Limbo" or objname == "Belasco, Demon Lord of Limbo - epic" then
        updateMMBelasco = function()
            if not mmActive(objname) then
                return nil
            end
            local kopilecontent = get_decks_and_cards_from_zone(kopile_guid)
            local nongrey = 0
            if kopilecontent[1] and kopilecontent[1].tag == "Deck" then
                for _,k in pairs(kopilecontent[1].getObjects()) do
                    for _,l in pairs(k.tags) do
                        if l:find("Cost:") then
                            nongrey = nongrey + 1
                            break
                        end
                    end
                end
            end
            nongrey = nongrey/#Player.getPlayers() - 0.5*(nongrey % #Player.getPlayers())
            Wait.time(function() mmButtons(objname,
                nongrey,
                "+" .. nongrey,
                "Belasco gets +1 equal to the number of non-grey Heroes in the KO pile, divided by the number of players (round down).",
                'updateMMBelasco') end,1)
        end
        function onObjectEnterZone(zone,object)
            if zone.guid == kopile_guid then
                Wait.time(updateMMBelasco,2)
            end
        end
        function onObjectLeaveZone(zone,object)
            if zone.guid == kopile_guid then
                Wait.time(updateMMBelasco,2)
            end
        end
    end
    if objname == "Charles Xavier, Professor of Crime" then
        updateMMCharles = function()
            if not mmActive(objname) then
                return nil
            end
            local bsfound = 0
            for i=2,#city_zones_guids do
                local citycontent = get_decks_and_cards_from_zone(city_zones_guids[i])
                if citycontent[1] then
                    for _,o in pairs(citycontent) do
                        if o.hasTag("Bystander") then
                            bsfound = bsfound + 1
                        end
                    end
                end
            end
            for _,o in pairs(hqguids) do
                local hqcontent = getObjectFromGUID(o).Call('getCards')
                if hqcontent[1] then
                    for _,o in pairs(hqcontent) do
                        if o.tag == "Card" and o.hasTag("Bystander") then
                            bsfound = bsfound + 1
                        elseif o.tag == "Deck" then
                            for _,c in pairs(o.getObjects()) do
                                for _,tag in pairs(c.tags) do
                                    if tag == "Bystander" then
                                        bsfound = bsfound + 1
                                        break
                                    end
                                end
                            end
                        end
                    end
                end   
            end
            Wait.time(function() mmButtons(objname,
                bsfound,
                "+" .. bsfound,
                "Charles Xavier gets +1 for each Bystander in the city and HQ.",
                'updateMMCharles') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMCharles,1.5)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMCharles,1.5)
        end
    end
    if objname == "Deathbird" or objname == "Deathbird - epic" then
        updateMMDeathbird = function()
            if not mmActive(objname) then
                return nil
            end
            local shiarfound = 0
            for i=2,#city_zones_guids do
                local citycontent = get_decks_and_cards_from_zone(city_zones_guids[i])
                if citycontent[1] then
                    for _,o in pairs(citycontent) do
                        if o.getName():find("Shi'ar") or o.hasTag("Shi'ar") then
                            shiarfound = shiarfound + 1
                            break
                        end
                    end
                end
            end
            local escapezonecontent = get_decks_and_cards_from_zone(escape_zone_guid)
            if escapezonecontent[1] and escapezonecontent[1].tag == "Deck" then
                for _,o in pairs(escapezonecontent[1].getObjects()) do
                    if o.name:find("Shi'ar") then
                        shiarfound = shiarfound + 1
                    elseif next(o.tags) then
                        for _,tag in pairs(o.tags) do
                            if tag == "Shi'ar" then
                                shiarfound = shiarfound + 1
                                break
                            end
                        end
                    end
                end
            elseif escapezonecontent[1] then
                if escapezonecontent[1].getName():find("Shi'ar") or escapezonecontent[1].hasTag("Shi'ar") then
                    shiarfound = shiarfound + 1
                end
            end
            local modifier = 1
            if epicness == true then
                modifier = 2
            end
            Wait.time(function() mmButtons(objname,
                shiarfound,
                "+" .. shiarfound*modifier,
                "Deathbird gets +" .. modifier .. " for each Shi'ar Villain in the city and Escape Pile.",
                'updateMMDeathbird') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMDeathbird,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMDeathbird,1)
        end
    end
    if objname == "Emma Frost, The White Queen" or objname == "Emma Frost, The White Queen - epic" then
        updateMMEmma = function()
            if not mmActive(objname) then
                return nil
            end
            local playedcards = get_decks_and_cards_from_zone(playguids[Turns.turn_color])
            local power = 0
            local boost = 1
            if epicness == true then
                boost = 2
            end
            if playedcards[1] then
                for _,o in pairs(playedcards) do
                    if o.hasTag("Starter") or o.getName() == "Sidekick" or o.getName() == "New Recruits" or (o.hasTag("Officer") and not hasTag2(o,"HC:")) then
                        power = power + boost
                    end
                end
            end
            Wait.time(function() mmButtons(objname,
                power,
                "+" .. power,
                "Emma Frost gets +" .. boost .. " for each grey hero you have.",
                'updateMMEmma') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMEmma,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMEmma,1)
        end
    end
    if objname == "Evil Deadpool" then
        if not mmActive(objname) then
            return nil
        end
        updateMMDeadpool = function()
            local color = Turns.turn_color
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[color])
            local tacticsfound = 0
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,o in pairs(vpilecontent[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("Tactic:") then
                            tacticsfound = tacticsfound + 1
                            break
                        end
                    end
                end
            elseif vpilecontent[1] and hasTag2(vpilecontent[1],"Tactic:",8) then
                tacticsfound = tacticsfound + 1
            end
            Wait.time(function() mmButtons(objname,
                tacticsfound,
                "+" .. tacticsfound,
                "Evil Deadpool gets +1 for each Mastermind Tactic in your victory pile.",
                'updateMMDeadpool') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMDeadpool,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMDeadpool,1)
        end
        function onPlayerTurn(player,previous_player)
            updateMMDeadpool()
        end
    end
    if objname == "Grim Reaper" or objname == "Grim Reaper - epic" then
        updateMMReaper = function()
            if not mmActive(objname) then
                return nil
            end
            local locationcount = 0
            for _,o in pairs(city_zones_guids) do
                if o ~= city_zones_guids[1] then
                    local citycontent = get_decks_and_cards_from_zone(o)
                    if citycontent[1] then
                        for _,obj in pairs(citycontent) do
                            if obj.getDescription():find("LOCATION") then
                                locationcount = locationcount + 1
                                break
                            end
                        end
                    end
                end
            end
            local locationcount2 = locationcount
            if epicness then
                locationcount2 = locationcount*2
            end
            Wait.time(function() mmButtons(objname,
                locationcount2,
                "+" .. locationcount2,
                "Grim Reaper gets +" .. locationcount2/locationcount .. " for each Location card in the city.",
                'updateMMReaper') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMReaper,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMReaper,1)
        end
    end
    if objname == "Hela, Goddess of Death" or objname == "Hela, Goddess of Death - epic" then
        helacitycheck = table.clone(city_zones_guids)
        table.remove(helacitycheck,1)
        table.remove(helacitycheck,1)
        table.remove(helacitycheck,1)
        if not epicness then
            table.remove(helacitycheck,1)
        end
        updateMMHela = function()
            if not mmActive(objname) then
                return nil
            end
            local villaincount = 0
            for _,o in pairs(helacitycheck) do
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if obj.hasTag("Villain") then
                            villaincount = villaincount + 1
                            break
                        end
                    end
                end
            end
            local boost = 0
            if epicness then
                boost = 1
            end
            Wait.time(function() mmButtons(objname,
                villaincount,
                "+" .. villaincount*(5+boost),
                "Hela gets +" .. 5+boost .. " for each Villain in the city zones she wants to conquer.",
                'updateMMHela') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMHela,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMHela,1)
        end
    end
    if objname == "J. Jonah Jameson" or objname == "J. Jonah Jameson - epic" then
        local soPile = getObjectFromGUID(officerDeckGUID)
        soPile.randomize()
        local jonah = 2
        if epicness == true then
            jonah = 3
        end
        for i=1,jonah*#Player.getPlayers() do
            soPile.takeObject({position = getObjectFromGUID(getStrikeloc(objname)).getPosition(),
                flip=false,
                smooth=false})
        end
    end
    if objname == "Kingpin" then
        local mmzone = getObjectFromGUID(mmLocations[objname])
        mmzone.createButton({click_function='returnColor',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="Bribe",
                    tooltip="Kingpin can be fought using Recruit as well as Attack.",
                    font_size=250,
                    font_color="Yellow",
                    color={0,0,0,0.75},
                    width=250,height=250})
    end
    if objname == "Macho Gomez" then
        updateMMMacho = function()
            if not mmActive(objname) then
                return nil
            end
            local color = Turns.turn_color
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[color])
            local savior = 0
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,k in pairs(vpilecontent[1].getObjects()) do
                    for _,l in pairs(k.tags) do
                        if l == "Group:Deadpool's \"Friends\"" then
                            savior = savior + 1
                            break
                        end
                    end
                end
            elseif vpilecontent[1] then
                if vpilecontent[1].hasTag("Group:Deadpool's \"Friends\"") then
                    savior = 1
                end
            end
            Wait.time(function() mmButtons(objname,
                savior,
                "+" .. savior,
                "Macho Gomez gets +1 in revenge for each Deadpool's \"Friends\" villain in your victory pile.",
                'updateMMMacho') end,1)
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMMacho,2)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMMacho,2)
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMMacho()
        end
    end
    if objname == "Madelyne Pryor, Goblin Queen" then
        function updateMMMadelyne()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            local buttonindex = nil
            for i,o in pairs(mmzone.getButtons()) do
                if o.click_function == "updateMMMadelyne" then
                    buttonindex = i-1
                    break
                end
            end
            local strikeloc = getStrikeloc(objname)
            local checkvalue = 1
            if not get_decks_and_cards_from_zone(strikeloc)[1] then
                getObjectFromGUID(strikeloc).clearButtons()
                checkvalue = 0
            else
                if not getObjectFromGUID(strikeloc).getButtons() then
                    getObjectFromGUID(strikeloc).createButton({click_function='returnColor',
                        function_owner=self,
                        position={0,0,0},
                        rotation={0,180,0},
                        label="2",
                        tooltip="You can fight these Demon Goblins for 2 to rescue them as Bystanders.",
                        font_size=250,
                        font_color="Red",
                        width=0})
                else
                    getObjectFromGUID(strikeloc).editButton({label="2",
                        tooltip="You can fight these Demon Goblins for 2 to rescue them as Bystanders."})
                end
            end
            mmButtons(objname,
                checkvalue,
                "X",
                "You can't fight Madelyne Pryor while she has any Demon Goblins.",
                'updateMMMadelyne')
        end
        function onObjectEnterZone(zone,object)
            updateMMMadelyne()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMadelyne()
        end
    end
    if objname == "Magus" or objname == "Magus - epic" then
        updateMMMagus = function()
            if not mmActive(objname) then
                return nil
            end
            local shardsfound = 0
            for _,o in pairs(city_zones_guids) do
                if o ~= city_zones_guids[1] then
                    local citycontent = get_decks_and_cards_from_zone(o)
                    if citycontent[1] then
                        for _,obj in pairs(citycontent) do
                            if obj.getName() == "Shard" then
                                shardsfound = shardsfound + 1
                                break
                            end
                        end
                    end
                end
            end
            local boost = 1
            if epicness then
                boost = 2
            end
            Wait.time(function() mmButtons(objname,
                shardsfound,
                "+" .. boost*shardsfound,
                "Magus gets + " .. boost .. " for each Villain in the city that has any Shards.",
                'updateMMMagus') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMagus,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMagus,1)
        end
    end
    if objname == "Mandarin" or objname == "Mandarin - epic" then
        if not mmActive(objname) then
            return nil
        end
        updateMMMandarin = function()
            local tacticsfound = 0
            for _,o in pairs(Player.getPlayers()) do
                local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,o in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(o.tags) do
                            if k == "Group:Mandarin's Rings" then
                                tacticsfound = tacticsfound + 1
                                break
                            end
                        end
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Group:Mandarin's Rings") then
                    tacticsfound = tacticsfound + 1
                end
            end
            local modifier = 1
            if epicness then
                modifier = 2
            end
            Wait.time(function() mmButtons(objname,
                tacticsfound,
                "-" .. tacticsfound*modifier,
                "Mandarin gets -" .. modifier .. " for each Mandarin's Rings among all players' Victory Piles.",
                'updateMMMandarin') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMandarin,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMandarin,1)
        end
    end
    if objname == "Maria Hill, Director of S.H.I.E.L.D." then
        updateMMMaria = function()
            if not mmActive(objname) then
                return nil
            end
            local shieldfound = 0
            for _,o in pairs(city_zones_guids) do
                if o ~= city_zones_guids[1] then
                    local citycontent = get_decks_and_cards_from_zone(o)
                    if citycontent[1] then
                        for _,obj in pairs(citycontent) do
                            if obj.hasTag("Officer") or obj.HasTag("Group:S.H.I.E.L.D. Elite") then
                                shieldfound = shieldfound + 1
                                break
                            end
                        end
                    end
                end
            end
            Wait.time(function() mmButtons(objname,
                shieldfound,
                "X",
                "You can't fight Maria Hill while there are any S.H.I.E.L.D. Elite Villains or Officers in the city.",
                'updateMMMaria') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMaria,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMaria,1)
        end
    end
    if objname == "Misty Knight" then
        local mmzone = getObjectFromGUID(mmLocations[objname])
        mmzone.createButton({click_function='returnColor',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="Bribe",
                    tooltip="Misty Knight can be fought using Recruit as well as Attack.",
                    font_size=250,
                    font_color="Yellow",
                    color={0,0,0,0.75},
                    width=250,height=250})
    end
    if objname == "Mojo" or objname == "Mojo - epic" then
        if mmLocations["Mojo"] ~= mmZoneGUID then
            mojoVPUpdate(0)
        end
        mojobasepower = 6
        if epicness then
            playHorror()
            mojobasepower = 7
        end
        function updateMMMojo()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            local buttonindex = nil
            for i,o in pairs(mmzone.getButtons()) do
                if o.click_function == "updateMMMojo" then
                    buttonindex = i-1
                    break
                end
            end
            local strikeloc = getStrikeloc(objname)
            local checkvalue = 1
            if not get_decks_and_cards_from_zone(strikeloc)[1] then
                getObjectFromGUID(strikeloc).clearButtons()
                checkvalue = 0
            else
                if not getObjectFromGUID(strikeloc).getButtons() then
                    getObjectFromGUID(strikeloc).createButton({click_function='returnColor',
                        function_owner=self,
                        position={0,0,0},
                        rotation={0,180,0},
                        label=mojobasepower,
                        tooltip="You can fight these Human Shields for " .. mojobasepower .. " to rescue them as Bystanders.",
                        font_size=250,
                        font_color="Red",
                        width=0})
                else
                    getObjectFromGUID(strikeloc).editButton({label=mojobasepower,
                        tooltip="You can fight these Human Shields for " .. mojobasepower .. " to rescue them as Bystanders."})
                end
            end
            mmButtons(objname,
                    checkvalue,
                    "X",
                    "You can't fight Mojo while he has any Human Shields.",
                    'updateMMMojo')
        end
        function onObjectEnterZone(zone,object)
            updateMMMojo()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMojo()
        end
    end
    if objname == "Mole Man" then
        updateMMMoleMan = function()
            if not mmActive(objname) then
                return nil
            end
            local escaped = get_decks_and_cards_from_zone(escape_zone_guid)
            local bscount = 0
            if escaped[1] and escaped[1].tag == "Deck" then
                for _,o in pairs(escaped[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k == "Group:Subterranea" then
                            bscount = bscount + 1
                            break
                        end
                    end
                end
            elseif escaped[1] and escaped[1].hasTag("Group:Subterranea") then
                bscount = bscount + 1
            end
            Wait.time(function() mmButtons(objname,
                bscount,
                "+" .. bscount,
                "Mole Man gets +1 for each Subterranea Villain that has escaped.",
                'updateMMMoleMan') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMoleMan,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMoleMan,2)
        end
    end
    if objname == "Morgan Le Fay" then
        local mmzone = getObjectFromGUID(mmLocations[objname])
        mmzone.createButton({click_function='returnColor',
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="!",
                    tooltip="Chivalrous Duel: Attack Morgan only with the power of a single hero.",
                    font_size=250,
                    font_color="Blue",
                    color={0,0,0,0.75},
                    width=250,height=250})
    end
    if objname == "Mr. Sinister" then
        function updateMMMrSinister()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(topBoardGUIDs) do
                    if o == mmLocations[objname] then
                        strikeloc = topBoardGUIDs[i-1]
                        break
                    end
                end
            end
            local bs = get_decks_and_cards_from_zone(strikeloc)
            Wait.time(function() mmButtons(objname,
                #bs,
                "+" .. #bs,
                "Mr. Sinister gets +1 for each Bystander he has.",
                'updateMMMrSinister') end,1)
        end
        function onObjectEnterZone(zone,object)
            updateMMMrSinister()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMrSinister()
        end
    end
    if objname == "Onslaught" or objname == "Onslaught - epic" then
        for _,o in pairs(Player.getPlayers()) do
            getObjectFromGUID(playerBoards[o.color]).Call('onslaughtpain')
        end
        broadcastToAll("Hand size reduced by 1 because of Onslaught. Good luck! You're going to need it.")
    end
    if objname == "Poison Thanos" or objname == "Poison Thanos - epic" then
        updateMMPoisonThanos = function()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(topBoardGUIDs) do
                    if o == mmLocations[objname] then
                        strikeloc = topBoardGUIDs[i-1]
                        break
                    end
                end
            end
            local poisoned = get_decks_and_cards_from_zone(strikeloc)
            local poisoncount = 0
            if poisoned[1] and poisoned[1].tag == "Deck" then
                local costs = table.clone(herocosts)
                for _,o in pairs(poisoned[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("Cost:") then
                            herocosts[tonumber(k:match("%d+"))] = herocosts[tonumber(k:match("%d+"))] + 1
                            break
                        end
                    end
                end
                for _,o in pairs(costs) do
                    if o > 0 then
                        poisoncount = poisoncount + 1
                    end
                end
            elseif poisoned[1] then
                poisoncount = 1
            end
            local boost = 1
            if epicness then
                boost = 2
            end
            Wait.time(function() mmButtons(objname,
                poisoncount,
                "+" .. poisoncount*boost,
                "Poison Thanos gets + " .. boost .. " for each different cost among cards in his Poisoned Souls pile.",
                'updateMMPoisonThanos') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMPoisonThanos,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMPoisonThanos,2)
        end
    end
    if objname == "Professor X" then
        function updateMMProfessorX()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(topBoardGUIDs) do
                    if o == mmLocations[objname] then
                        strikeloc = topBoardGUIDs[i-1]
                        break
                    end
                end
            end
            local bs = get_decks_and_cards_from_zone(strikeloc)
            Wait.time(function() mmButtons(objname,
                #bs,
                "+" .. #bs,
                "Professor X gets +1 for each of his telepathic pawns.",
                'updateMMProfessorX') end,1)
        end
        function onObjectEnterZone(zone,object)
            updateMMProfessorX()
        end
        function onObjectLeaveZone(zone,object)
            updateMMProfessorX()
        end
    end
    if objname == "'92 Professor X" then
        function updateMMProfessorX92()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(topBoardGUIDs) do
                    if o == mmLocations[objname] then
                        strikeloc = topBoardGUIDs[i-1]
                        break
                    end
                end
            end
            local bs = get_decks_and_cards_from_zone(strikeloc)
            Wait.time(function() mmButtons(objname,
                #bs,
                "+" .. #bs,
                "'92 Professor X gets +1 for each of his telepathic pawns.",
                'updateMMProfessorX92') end,1)
        end
        function onObjectEnterZone(zone,object)
            updateMMProfessorX92()
        end
        function onObjectLeaveZone(zone,object)
            updateMMProfessorX92()
        end
    end
    if objname == "Ragnarok" then
        updateMMRagnarok = function()
            if not mmActive(objname) then
                return nil
            end
            local hccolors = {
                ["Red"] = 0,
                ["Yellow"] = 0,
                ["Green"] = 0,
                ["Silver"] = 0,
                ["Blue"] = 0
            }
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    for _,k in pairs(hero.getTags()) do
                        if k:find("HC:") then
                            hccolors[k:gsub("HC:","")] = 2
                        end
                    end
                end
            end
            local boost = 0
            for _,o in pairs(hccolors) do
                boost = boost + o
            end
            Wait.time(function() mmButtons(objname,
                boost,
                "+" .. boost,
                "Ragnarok gets +2 for each Hero Class among Heroes in the HQ.",
                'updateMMRagnarok') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMRagnarok,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMRagnarok,2)
        end
    end
    if objname == "Shadow King" or objname == "Shadow King - epic" then
        if epicness then
            playHorror()
            playHorror()
            -- these will stack
            broadcastToAll("Shadow King played two horrors. Please read each of them")
        end
        function updateMMShadowKing()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(topBoardGUIDs) do
                    if o == mmLocations[objname] then
                        strikeloc = topBoardGUIDs[i-1]
                        break
                    end
                end
            end
            local bs = get_decks_and_cards_from_zone(strikeloc)
            Wait.time(function() mmButtons(objname,
                #bs,
                "+" .. #bs,
                "Shadow King gets +1 for each hero he dominates.",
                'updateMMShadowKing') end,1)
        end
        function onObjectEnterZone(zone,object)
            updateMMShadowKing()
        end
        function onObjectLeaveZone(zone,object)
            updateMMShadowKing()
        end
    end
    if objname == "Spider-Queen" then
        updateMMSpiderQueen = function()
            if not mmActive(objname) then
                return nil
            end
            local escaped = get_decks_and_cards_from_zone(escape_zone_guid)
            local bscount = 0
            if escaped[1] and escaped[1].tag == "Deck" then
                for _,o in pairs(escaped[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k == "Bystander" then
                            bscount = bscount + 1
                            break
                        end
                    end
                end
            elseif escaped[1] and escaped[1].hasTag("Bystander") then
                bscount = bscount + 1
            end
            Wait.time(function() mmButtons(objname,
                bscount,
                "+" .. bscount,
                "Spider-Queen gets +1 for each Bystander in the Escape pile.",
                'updateMMSpiderQueen') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMSpiderQueen,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMSpiderQueen,2)
        end
    end
    if objname == "Thanos" then
        updateMMThanos = function()
            if not mmActive(objname) then
                return nil
            end
            local gemfound = 0
            for _,o in pairs(playguids) do
                local playcontent = get_decks_and_cards_from_zone(o)
                if playcontent[1] then
                    for _,k in pairs(playcontent) do
                        if k.hasTag("Group:Infinity Gems") then
                            gemfound = gemfound + 1
                        end
                    end
                end
            end
            Wait.time(function() mmButtons(objname,
                gemfound,
                "-" .. gemfound*2,
                "Thanos gets -2 for each Infinity Gem Artifact card controlled by any player.",
                'updateMMThanos') end,1)
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Group:Infinity Gems") then
                Wait.time(updateMMThanos,2)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Group:Infinity Gems") then
                Wait.time(updateMMThanos,2)
            end
        end
    end
    if objname == "The Goblin, Underworld Boss" then
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        for i=1,2 do
            bsPile.takeObject({position=getObjectFromGUID(getStrikeloc(objname)).getPosition(),
                flip=false,
                smooth=false})
        end
    end
    if objname == "The Hood" or objname == "The Hood - epic" then
        updateMMHood = function()
            if not mmActive(objname) then
                return nil
            end
            local playerBoard = getObjectFromGUID(playerBoards[Turns.turn_color])
            local discard = playerBoard.Call('returnDiscardPile')[1]
            local boost = 1
            if epicness then
                boost = 2
            end
            local darkmemories = 0
            if discard and discard.tag == "Deck" then
                local hccolors = {
                    ["Red"] = 0,
                    ["Yellow"] = 0,
                    ["Green"] = 0,
                    ["Silver"] = 0,
                    ["Blue"] = 0
                }
                for _,o in pairs(discard.getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("HC:") then
                            hccolors[k:gsub("HC:","")] = boost
                        end
                    end
                end
                for _,o in pairs(hccolors) do
                    darkmemories = darkmemories + o
                end
            elseif discard then
                if hasTag2(discard,"HC:",4) then
                    darkmemories = boost
                end
            end
            Wait.time(function() mmButtons(objname,
                darkmemories,
                "+" .. darkmemories,
                "Dark Memories: The Hood gets +1 for each Hero Class among cards in your discard pile.",
                'updateMMHood') end,1)
        end
        function onPlayerTurn(player,previous_player)
            updateMMHood()
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMHood,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMHood,2)
        end
    end
    if objname == "Ultron" or objname == "Ultron - epic" then
        updateMMUltron = function()
            if not mmActive(objname) then
                return nil
            end
            local mmzone = getObjectFromGUID(mmLocations[objname])
            if mmLocations[objname] == mmZoneGUID then
                strikeloc = strikeZoneGUID
            else
                for i,o in pairs(topBoardGUIDs) do
                    if o == mmLocations[objname] then
                        strikeloc = topBoardGUIDs[i-1]
                        break
                    end
                end
            end
            local threatanalysis = get_decks_and_cards_from_zone(strikeloc)
            local hccolors = {
                ["Red"] = false,
                ["Yellow"] = false,
                ["Green"] = false,
                ["Silver"] = false,
                ["Blue"] = false
            }
            local boost = 1
            local epicboost = ""
            if epicness then
                epicboost = "Triple "
                boost = 3
            end
            local empowerment = 0
            if threatanalysis[1] and threatanalysis[1].tag == "Deck" then
                for _,o in pairs(threatanalysis[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("HC:") then
                            hccolors[k:gsub("HC:","")] = true
                            break
                        end
                    end
                end
            elseif threatanalysis[1] then
                hccolors[hasTag2(threatanalysis[1],"HC:",4)] = true
            end
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero and hasTag2(hero,"HC:",4) and hccolors[hasTag2(hero,"HC:",4)] then
                    empowerment = empowerment + boost
                    table.remove(hccolors,hasTag2(hero,"HC:"))
                end
            end
            Wait.time(function() mmButtons(objname,
                empowerment,
                "+" .. empowerment,
                "Ultron is " .. epicboost .. "Empowered by each color in his Threat Analysis pile.",
                'updateMMUltron') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMUltron,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMUltron,2)
        end
    end
    if objname == "Wasteland Hulk" then
        if not mmActive(objname) then
            return nil
        end
        updateMMWastelandHulk = function()
            local tacticsfound = 0
            for _,o in pairs(Player.getPlayers()) do
                local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,o in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(o.tags) do
                            if k == "Tactic:Wasteland Hulk" then
                                tacticsfound = tacticsfound + 1
                                break
                            end
                        end
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Tactic:Wasteland Hulk") then
                    tacticsfound = tacticsfound + 1
                end
            end
            Wait.time(function() mmButtons(objname,
                tacticsfound,
                "+" .. tacticsfound*3,
                "Wasteland Hulk gets +3 for each of his Mastermind Tactics among all players' Victory Piles.",
                'updateMMWastelandHulk') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMWastelandHulk,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMWastelandHulk,1)
        end
    end
end

function mmButtons(objname,checkvalue,label,tooltip,f,id)
    local mmzone = getObjectFromGUID(mmLocations[objname])
    local buttonindex = nil
    local toolt_orig = nil
    if not id then
        id = "base"
    end
    for i,o in pairs(mmzone.getButtons()) do
        if o.click_function == f or (f == "mm" and o.click_function:find("updateMM")) or o.click_function == "updatePower" then
            buttonindex = i-1
            toolt_orig = o.tooltip
            if f == "mm" then
                f = o.click_function
            end
            break
        end
    end
    if f == "mm" then
        f = 'updatePower'
    end
    if not toolt_orig then
        tooltip = "- " .. tooltip ..  " [" .. id .. ":" .. label .. "]"
    elseif not toolt_orig:find("%[" .. id .. ":") then
        if tooltip then
            tooltip = toolt_orig .. "\n - " .. tooltip .. " [" .. id .. ":" .. label .. "]"
        else
            tooltip = toolt_orig .. "\n - Unidentified bonus [" .. id .. ":" .. label .. "]"
        end
    else
        tooltip = toolt_orig
    end
    if checkvalue == 0 then
        label = ""
    end
    if not buttonindex then
        mmzone.createButton({click_function=f,
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            label=label,
            tooltip=tooltip,
            font_size=350,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    else
        local lab,tool = updateLabel(mmzone,buttonindex+1,label,id,tooltip)
        mmzone.editButton({index=buttonindex,label = lab,tooltip = tool})
    end
end

function updateLabel(obj,index,label,id,tooltip)
    local button = obj.getButtons()[index]
    local bonuses = {}
    local step = 1
    for s in string.gmatch(tooltip,"[^%[%]]+") do
        if step % 2 == 0 then
            bonuses[s:gsub(":.*","")] = s:gsub(".*:","")
        end
        step = step + 1
    end
    if step > 3 or not bonuses[id] then
        local sum = 0
        local aster = false
        local plus = true
        for i,o in pairs(bonuses) do
            if i == id then
                tooltip = tooltip:gsub("%[" .. id .. ":.*%]","[" .. id .. ":" .. label .. "]")
            end
            if not o:find("+") then
                plus = false
            end
            if o:find("-") then
                sum = sum - tonumber(o:match("%d+"))
            elseif o:find("X") then
                sum = "X"
                break
            elseif o:find("*") then
                aster = true
            elseif o and o ~= "" then
                sum = sum + tonumber(o:match("%d+"))
            end
        end
        label = sum
        if label == 0 then
            label = ""
        end
        if aster and label ~= "X" then
            label = label .. "*"
        end
        if plus and label ~= "X" then
            label = "+" .. label
        end
    else
        tooltip = tooltip:gsub("%[.*%]","[" .. id .. ":"  .. label .. "]")
    end
    return label,tooltip
end

function koCard(obj,smooth)
    if smooth then
        obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
    else
        obj.setPosition(getObjectFromGUID(kopile_guid).getPosition())
    end
end

function fightButton(zone)
    local butt = getObjectFromGUID(zone).getButtons()
    if butt then
        for _,o in pairs(butt) do
            if o.click_function:find("fightEffect") then
                return nil
            end
        end
    end
    _G["fightEffect" .. zone] = function(obj,player_clicker_color)
        local name = fightMM(obj.guid,player_clicker_color)
        --log("name:")
        --log(name)
        if name then
            local killFightButton = function()
                local content = get_decks_and_cards_from_zone(obj.guid,false,false)
                if not content[1] or (not finalblow and content[1].tag == "Card" and content[1].getName() == name and not content[2]) then
                    broadcastToAll(name .. " was defeated!")
                    local strikeloc = getStrikeloc(name)
                    if content[1] then
                        if content[1].is_face_down then
                            content[1].flip()
                        end
                        koCard(content[1])
                    end
                    for i,o in pairs(masterminds) do
                        if o == name then
                            table.remove(masterminds,i)
                            break
                        end
                    end
                    addMMGUIDS[mmLocations[name]] = false
                    mmLocations[name] = nil
                    local butt = obj.getButtons()
                    local iter = 0
                    for i,o in ipairs(butt) do
                        if o.click_function:find("fightEffect") then
                            obj.removeButton(i-1-iter)
                            iter = iter + 1
                        elseif o.click_function:find("updateMM") and not o.click_function:find("Power") then
                            obj.removeButton(i-1-iter)
                            iter = iter + 1
                        end
                    end
                    local strikecontent = get_decks_and_cards_from_zone(strikeloc)
                    if strikecontent[1] then
                        strikecontent[1].setPosition(getObjectFromGUID(strikePileGUID).getPosition())
                    end
                    local strikeZone = getObjectFromGUID(strikeloc)
                    local strikebutt = strikeZone.getButtons()
                    local iter2 = 0
                    if strikebutt then
                        for i,o in ipairs(strikebutt) do
                            if o.click_function:find("updateMM") and not o.click_function:find("Power") then
                                strikeZone.removeButton(i-1-iter2)
                                iter2 = iter2 + 1
                            end
                        end
                    end
                    --obj.clearButtons()
                    if name == "Onslaught" then
                        for _,o in pairs(Player.getPlayers()) do
                            getObjectFromGUID(playerBoards[o.color]).Call('onslaughtpain',true)
                        end
                        broadcastToAll("Onslaught defeated! Hand size decrease was relieved!")
                    end
                    getObjectFromGUID("f3c7e3").Call('retrieveMM') 
                    if setupParts[1] == "World War Hulk" then
                        getObjectFromGUID("f3c7e3").Call('addNewLurkingMM') 
                    end
                elseif transformed[name] ~= nil then
                    transformMM(getObjectFromGUID(mmLocations[name]))
                end
            end
            Wait.time(killFightButton,1)
        end
    end
    getObjectFromGUID(zone).createButton({click_function="fightEffect" .. zone,
        function_owner=self,
        position={0,0,0.5},
        rotation={0,180,0},
        label="Fight",
        tooltip="Fight this card.",
        font_size=200,
        font_color="Red",
        color={0,0,0},
        width=600,height=375})
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

function playHorror()
    local horrorPile = getObjectFromGUID(horrorPileGUID)
    local horrorpos = getObjectFromGUID(topBoardGUIDs[1]).getPosition()
    horrorpos.y = horrorpos.y + 3
    horrorPile.randomize()
    horrorPile.takeObject({position=horrorpos,
            flip=false,
            smooth=false,
            callback_function = resolveHorror})
    broadcastToAll("Random horror added to the game, above the board.")
end

function resolveHorror(obj)
    if obj.getName() == "Army of Evil" then
        broadcastToAll("All non-henchmen villains get +1. Unscripted!")
        --requires stacking of bonuses
        return nil
    end
    if obj.getName() == "Empire of Oppression" then
        broadcastToAll("The Horror! Oppressed, each player's hand size is permanently reduced by 1.")
        for _,o in pairs(Player.getPlayers()) do
            getObjectFromGUID(playerBoards[o.color]).Call('onslaughtpain')
        end
        return nil
    end
    if obj.getName() == "Endless Hatred" then
        broadcastToAll("Complete scheme twist also triggers master strike. Unscripted!")
        --make a generic function for these in the draw villain (or push villain) scripts
        return nil
    end
    if obj.getName() == "Enraged Mastermind" then
        local mmname = nil
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID then
                mmname = i
                break
            end
        end
        if not mmname then
            broadcastToAll("Mastermind defeated? Horror does not apply.")
            return nil
        end
        mmButtons(mmname,2,"+2","The Mastermind is enraged and gets +2.","mm","enragedmm")
        return nil
    end
    if obj.getName() == "Fight to the End" then
        if finalblow == false then
            broadcastToAll("The Horror! Final blow was enable, so you have to defeat the Mastermind one more time after you've taken all of his tactics.")
            finalblow = true
            finalblowfixed = true
        else
            log("Final Blow was already active, so this horror doesn't do anything and is skipped.")
            obj.destruct()
            playHorror()
        end
        return nil
    end
    if obj.getName() == "Growing Threat" then
        broadcastToAll("The mastermind gets +1 for each tactic in all victory piles. Unscripted!")
        --requires stacking of bonuses
        return nil
    end
    if obj.getName() == "Legions Upon Legions" then
        broadcastToAll("Whenever you play a henchman villain from the villain deck, play another card. Unscripted!")
        --make a generic function for these in the draw villain (or push villain) scripts
        return nil
    end
    if obj.getName() == "Maniacal Mastermind" then
        local mmname = nil
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID then
                mmname = i
                break
            end
        end
        if not mmname then
            broadcastToAll("Mastermind defeated? Horror does not apply.")
            return nil
        end
        mmButtons(mmname,1,"+1","The Mastermind becomes maniacal and gets +1.","mm","maniacalmm")
        return nil
    end
    if obj.getName() == "Misery Upon Misery" then
        broadcastToAll("Whenever you play a bystander from the villain deck, play another card. Unscripted!")
        --make a generic function for these in the draw villain (or push villain) scripts
        return nil
    end
    if obj.getName() == "Opening Salvo" then
        getObjectFromGUID("f3c7e3").Call('dealWounds')
        broadcastToAll("The Horror! in an opening salvo, each player is wounded.")
        return nil
    end
    if obj.getName() == "Pain Upon Pain" then
        broadcastToAll("Whenever you complete a master strike, play another card. Unscripted!")
        --make a generic function for these in the draw villain (or push villain) scripts
        return nil
    end
    if obj.getName() == "Plots Upon Plots" then
        broadcastToAll("Whenever you complete a scheme twist, play another card. Unscripted!")
        --make a generic function for these in the draw villain (or push villain) scripts
        return nil
    end
    if obj.getName() == "Psychic Infection" then
        local color = Turns.turn_color
        local playerBoard = getObjectFromGUID(playerBoards[color])
        local dest = playerBoard.positionToWorld(pos_discard)
        dest.y = dest.y + 3
        if color == "White" then
            angle = 90
        elseif color == "Blue" then
            angle = -90
        else
            angle = 180
        end
        local brot = {x=0, y=angle, z=0}
        obj.addTag("Horror")
        obj.setRotationSmooth(brot)
        obj.setPositionSmooth(dest)
        broadcastToAll("The Horror! " .. color .. " player received a psychic infection!")
        function onPlayerTurn(player)
            local hand = player.getHandObjects()
            if hand[1] then
                for _,obj in pairs(hand) do
                    if obj.getName() == "Psychic Infection" and obj.hasTag("Horror") then
                        broadcastToAll("Psychic Infection! Everyone discards a card and the next player gained the infection.")
                        local nextcolor = nil
                        for i,o in pairs(Player.getPlayers()) do
                            if o.color == player.color then
                                if i == 1 then
                                    nextcolor = Player.getPlayers()[#Player.getPlayers()].color
                                else
                                    nextcolor = Player.getPlayers()[i-1].color
                                end
                                break
                            end
                        end
                        local playerBoard = getObjectFromGUID(playerBoards[nextcolor])
                        local dest = playerBoard.positionToWorld(pos_discard)
                        dest.y = dest.y + 3
                        if nextcolor == "White" then
                            angle = 90
                        elseif nextcolor == "Blue" then
                            angle = -90
                        else
                            angle = 180
                        end
                        local brot = {x=0, y=angle, z=0}
                        obj.setRotationSmooth(brot)
                        obj.setPositionSmooth(dest)
                        for _,o in pairs(Player.getPlayers()) do
                            getObjectFromGUID("f3c7e3").Call('promptDiscard',o.color)
                        end
                        break
                    end
                end
            end
        end
        return nil
    end
    if obj.getName() == "Shadow of the Disciple" then
        local mmloc = getNextMMLoc(true)
        obj.setPosition(getObjectFromGUID(mmloc).getPosition())
        obj.setName("Master Plan")
        obj.addTag("VP5")
        powerButton(obj,"returnColor",9)
        setupMasterminds(obj.getName())
        table.insert(masterminds,obj.getName())
        mmLocations[obj.getName()] = mmloc
        getObjectFromGUID("f3c7e3").Call('retrieveMM')
        broadcastToAll("The Horror! A master plan was added to the game as an extra mastermind.")
        return nil
    end
    if obj.getName() == "Surprise Assault" then
        getObjectFromGUID("f3c7e3").Call('playVillains',2)
        broadcastToAll("The Horror! Two more cards are played from the villain deck in a surprise assault.")
        return nil
    end
    if obj.getName() == "The Apprentice Rises" then
        local mmPile = getObjectFromGUID(mmPileGUID)
        mmPile.randomize()
        local mmloc = getNextMMLoc(true)
        local stripTactics = function(obj)
            obj.flip()
            broadcastToAll("The Horror! " .. obj.getName() .. " was added to the game as an apprentice mastermind with one tactic.")
            table.insert(masterminds,obj.getName())
            mmLocations[obj.getName()] = mmloc
            getObjectFromGUID("f3c7e3").Call('retrieveMM')
            setupMasterminds(obj.getName())
            local keep = math.random(4)
            local tacguids = {}
            for i = 1,4 do
                table.insert(tacguids,obj.getObjects()[i].guid)
            end
            local tacticsPile = getObjectFromGUID(schemePileGUID)
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
        mmPile.takeObject({position = getObjectFromGUID(mmloc).getPosition(),callback_function = stripTactics})
        return nil
    end
    if obj.getName() == "The Blood Thickens" then
        local msPile = getObjectFromGUID(strikePileGUID)
        msPile.takeObject({position=vilDeckZone.getPosition(),
            flip=true,
            smooth=false})   
        Wait.time(function() get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].randomize() end,1)
        getObjectFromGUID("f3c7e3").Call('playVillains')        
        broadcastToAll("The Horror! The blood thickens and a master strike was shuffled into the villain deck! Another villain deck card is even played!")
        return nil
    end
    if obj.getName() == "The Plot Thickens" then
        local twistPile = getObjectFromGUID(twistPileGUID)
        twistPile.takeObject({position=vilDeckZone.getPosition(),
            flip=true,
            smooth=false})   
        Wait.time(function() get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].randomize() end,1)    
        broadcastToAll("The Horror! The plot thickens and a scheme twist was shuffled into the villain deck!")
        return nil
    end
    if obj.getName() == "Tyrant Mastermind" then
        local mmname = nil
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID then
                mmname = i
                break
            end
        end
        if not mmname then
            broadcastToAll("Mastermind defeated? Horror does not apply.")
            return nil
        end
        mmButtons(mmname,3,"+3","The Mastermind is a merciless tyrant and gets +3.","mm","tyrantmm")
        return nil
    end
    if obj.getName() == "Viral Infection" then
        local color = Turns.turn_color
        local playerBoard = getObjectFromGUID(playerBoards[color])
        local dest = playerBoard.positionToWorld(pos_discard)
        dest.y = dest.y + 3
        if color == "White" then
            angle = 90
        elseif color == "Blue" then
            angle = -90
        else
            angle = 180
        end
        local brot = {x=0, y=angle, z=0}
        obj.addTag("Horror")
        obj.setRotationSmooth(brot)
        obj.setPositionSmooth(dest)
        broadcastToAll("The Horror! " .. color .. " player received a viral infection!")
        function onPlayerTurn(player,previous_player)
            local hand = player.getHandObjects()
            if hand[1] then
                for _,obj in pairs(hand) do
                    if obj.getName() == "Viral Infection" and obj.hasTag("Horror") then
                        broadcastToAll("Viral Infection! Previous player is wounded and the next player gained the infection.")
                        local nextcolor = nil
                        for i,o in pairs(Player.getPlayers()) do
                            if o.color == player.color then
                                if i == 1 then
                                    nextcolor = Player.getPlayers()[#Player.getPlayers()].color
                                else
                                    nextcolor = Player.getPlayers()[i-1].color
                                end
                                break
                            end
                        end
                        local playerBoard = getObjectFromGUID(playerBoards[nextcolor])
                        local dest = playerBoard.positionToWorld(pos_discard)
                        dest.y = dest.y + 3
                        if nextcolor == "White" then
                            angle = 90
                        elseif nextcolor == "Blue" then
                            angle = -90
                        else
                            angle = 180
                        end
                        local brot = {x=0, y=angle, z=0}
                        obj.setRotationSmooth(brot)
                        obj.setPositionSmooth(dest)
                        getObjectFromGUID("f3c7e3").Call('getWound',previous_player.color)
                        break
                    end
                end
            end
        end
        return nil
    end
end

function bump(obj,y)
    if not y then
        y = 2
    end
    local pos = obj.getPosition()
    pos.y = pos.y + y
    obj.setPositionSmooth(pos)
end

function fightMM(zoneguid,player_clicker_color)
    local content = get_decks_and_cards_from_zone(zoneguid,false,false)
    local vppos = getObjectFromGUID(playerBoards[player_clicker_color]).positionToWorld(pos_vp2)
    vppos.y = vppos.y + 2
    local name = nil
    for i,o in pairs(mmLocations) do
        if o == zoneguid and mmActive(i) then
            name = i
            break
        end
    end
    if content[1] and content[2] then
        for i,o in pairs(content) do
            if o.tag == "Deck" then
                if i == 1 then
                    bump(content[2])
                else
                    bump(content[1])
                end
                o.takeObject({position = vppos,
                    flip = true,
                    smooth = true})
                return name
            elseif o.tag == "Card" and hasTag2(o,"Tactic:",8) then
                o.setPositionSmooth(vppos)
                if o.is_face_down then
                    Wait.time(function() o.flip() end,0.8)
                end
                return name
            end
        end
    elseif content[1] then
        if content[1].tag == "Deck" then
            for i,o in pairs(content[1].getObjects()) do
                local tacticFound = false
                for _,k in pairs(o.tags) do
                    if k:find("Tactic:") then
                        tacticFound = true
                        break
                    end
                end
                if tacticFound == false then
                    content[1].takeObject({position = vppos,
                        index = i,
                        flip = content[1].is_face_down,
                        smooth = true})
                    if content[1].remainder then
                        content[1] = content[1].remainder
                    end
                    return name
                end
            end
            content[1].takeObject({position = vppos,
                flip = true,
                smooth = true})
            return name
        else
            content[1].setPositionSmooth(vppos)
            if content[1].is_face_down then
                Wait.time(function() content[1].flip() end,0.8)
            end
            return name
        end
    end
    return nil
end

function mojoVPUpdate(bsCount,epicness)
    if not bsCount then
        bsCount = 0
    end
    local mojo = 3
    local mojovp = 3
    if epicness == true then
        mojo = 6
        mojovp = 4
    end
    local mojotagf = function(obj)
        obj.setTags({"Bystander","VP" .. mojovp})
    end
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    local bspilecount = bsPile.getQuantity()
    local mojopos = bsPile.getPosition()
    local mojopos2 = nil
    local bsflip = true
    for i=1,bspilecount do
        if i <= bsCount then
            mojopos2 = getObjectFromGUID(villainDeckZoneGUID).getPosition()
            bsflip = true
        elseif i <= mojo + bsCount then
            mojopos2 = getObjectFromGUID(getStrikeloc("Mojo")).getPosition()
            bsflip = false
        else 
            mojopos2 = bsPile.getPosition()
            mojopos2.y = mojopos2.y +2
            bsflip = false
        end
        bsPile.takeObject({position = mojopos2,
            smooth = false,
            flip = bsflip,
            callback_function = mojotagf})
        if bsPile.remainder then
            mojotagf(bsPile.remainder)
            break
        end
    end
    local bsTagged = function()
        local bsdeck = findObjectsAtPosition(mojopos,true)
        if bsdeck[1] and bsdeck[1].getQuantity() == bspilecount - bsCount - mojo then
            return true
        else
            return false
        end
    end
    local setNewBSGUID = function()
        local bsDeck = findObjectsAtPosition(mojopos,true)
        bystandersPileGUID = bsDeck[1].guid
        log("bs pile guid = ")
        log(bystandersPileGUID)
    end
    local timerSetNewGUID = function()
        Wait.condition(setNewBSGUID,bsTagged)
    end
    Wait.time(timerSetNewGUID,2)
    broadcastToAll("Mojo! Bystanders net " .. mojovp .. " victory points each!")
end

function getStrikeloc(mmname)
    local strikeloc = nil
    if mmLocations[mmname] == mmZoneGUID then
        strikeloc = strikeZoneGUID
    else
        for i,o in pairs(allTopBoardGUIDS) do
            if o == mmLocations[mmname] then
                strikeloc = allTopBoardGUIDS[i-1]
                break
            end
        end
    end
    return strikeloc
end

function getNextMMLoc(truemm)
    for guid,occup in pairs(addMMGUIDS) do
        if occup == false then
            for index,guid2 in pairs(allTopBoardGUIDS) do
                if guid2 == guid and index % 2 == 0 and addMMGUIDS[allTopBoardGUIDS[index-1]] == false then
                    addMMGUIDS[guid] = true
                    addMMGUIDS[allTopBoardGUIDS[index-1]] = true
                    return guid
                end
            end
        end
    end
    broadcastToAll("No location found for an extra mastermind.")
    return nil
end