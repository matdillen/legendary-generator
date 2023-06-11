function onLoad()
    createButtons()
    setupText = ""
    horrors = {}
    loadGUIDs()
    
    autoplay = true
    finalblow = true
    finalblowfixed = false
    
    thronesfavor = "none"
end

function loadGUIDs()
    local guids3 = {
        "playerBoards",
        "vpileguids",
        "cityguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
    
    local guids2 = {
       "allTopBoardGUIDS",
       "city_zones_guids",
       "topBoardGUIDs",
       "allTopBoardGUIDS",
       "hqguids",
       "pos_discard"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
        
    local guids1 = {
        "woundsDeckGUID",
        "mmZoneGUID",
        "strikePileGUID",
        "twistPileGUID",
        "twistZoneGUID",
        "strikeZoneGUID",
        "mmPileGUID",
        "sidekickDeckGUID",
        "bystandersPileGUID",
        "officerDeckGUID",
        "heroDeckZoneGUID",
        "hmPileGUID",
        "heroPileGUID",
        "villainDeckZoneGUID",
        "villainPileGUID",
        "pushvillainsguid",
        "schemePileGUID",
        "schemeZoneGUID",
        "ambPileGUID",
        "kopile_guid",
        "horrorPileGUID",
        "bszoneguid"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function returnVar(var)
    return _G[var]
end

function createButtons()
    self.createButton({
        click_function="click_shuffle", function_owner=self,
        position={-65,0.1,1}, height=500, width=1500,
        label = "Shuffle!", color={r=0, g=0, b=1},tooltip="Shuffle: heroes, villains, bystanders, wounds, sidekicks, player decks."
    })
    
    self.createButton({
        click_function="import_setup", function_owner=self,
        position={-65,0.1,0}, height=500, width=1500, color={1,1,1,1},
        label = "Import Setup",tooltip="Import a setup. Paste text in proper format in textbox below first."
    })
    
    self.createButton({
        click_function="random_setup", function_owner=self,
        position={-65,0.1,-11}, height=500, width=1500, color={1,1,0,1},
        label = "Random Setup",tooltip="Fetch a random setup. Requires web access!"
    })
    
    self.createButton({
        click_function="toggle_autoplay", function_owner=self,
        position={-65,0.1,2},
        width=1500, height=500, label="Autoplay from villain deck", tooltip="Set autoplay from villain deck when player draws new hand!", 
        color={0,1,0}
    })
    
    self.createButton({
        click_function="toggle_finalblow", function_owner=self,
        position={-65,0.1,3},
        width=1500, height=500, label="Final Blow", tooltip="Final Blow enabled", 
        color={0,1,0}
    })
    
    thronesfavorpos = {-65,0.1,4}
    
    self.createButton({
        click_function="thrones_favor", function_owner=self,
        position=thronesfavorpos,
        width=750, height=500, label="Throne's Favor", tooltip="Gain the Throne's Favor.", 
        color={0.62,0.16,0.16}
    })
    
    inputpos = {-65.5,0.1,-5}
    -- create text input to paste setup parameters
    self.createInput({
        input_function = "input_print",
        function_owner = self,
        label          = "CTRL + V the Setup here",
        font_size      = 223,
        validation     = 1,
        position=inputpos,
        width=2000,
        height=3000
    })
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

function toggle_autoplay()
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

function toggle_finalblow()
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

function invertCity()
    local step = 0
    for i,o in pairs(cityguids) do
        cityguids[i] = city_zones_guids[6-step]
        step = step + 1
    end
    for i,o in pairs(cityguids) do
        getObjectFromGUID(cityguids[i]).Call('updateCityZone')
    end
end

function thrones_favor(obj,player_clicker_color,notspend)
    if obj.locked == nil and obj[1] then
        player_clicker_color = obj[2]
        notspend = obj[3]
        obj = obj[1]
    end
    if obj == "any" then
        if thronesfavor == "none" then
            obj = self
        elseif thronesfavor:find("mm") then
            local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
            obj = getObjectFromGUID(mmLocations[thronesfavor:gsub("mm","")])
        else
            obj = getObjectFromGUID(playerBoards[thronesfavor])
        end
    end
    local color = nil
    for i,o in pairs(playerBoards) do
        if o == obj.guid then
            color = i
            break
        end
    end
    local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
    for i,o in pairs(mmLocations) do
        if o == obj.guid then
            color = "mm" .. i
            break
        end
    end
    if notspend and (color and color:find("mm") and player_clicker_color == color) then
        return nil
    end
    local butt = obj.getButtons()
    for i,o in pairs(butt) do
        if o.click_function == "thrones_favor" then
            obj.removeButton(i-1)
            break
        end
    end
    if color and (player_clicker_color == color or (color:find("mm") and player_clicker_color == color)) then
        self.createButton({
            click_function="thrones_favor", function_owner=self,
            position=thronesfavorpos,
            width=750, height=500, label="Throne's Favor", tooltip="Gain the Throne's Favor.", 
            color={0.62,0.16,0.16}
        })
        thronesfavor = "none"
        if color:find("Emperor Vulcan of the Shi'ar") then
            local zone = getObjectFromGUID(mmZoneGUID).Call('getStrikeloc',"Emperor Vulcan of the Shi'ar")
            getObjectFromGUID(zone).Call('updateMMEmperorVulcan')
        end
        return nil
    end
    if player_clicker_color:find("mm") then
        getObjectFromGUID(mmLocations[player_clicker_color:gsub("mm","")]).createButton({
            click_function="thrones_favor", function_owner=self,
            position={0.5,0,1},
            rotation = {0,180,0},
            width=250, height=170, label="TF", tooltip="Gain the Throne's Favor.", 
            color={0.62,0.16,0.16}
        })
        if player_clicker_color:find("Emperor Vulcan of the Shi'ar") then
            local zone = getObjectFromGUID(mmZoneGUID).Call('getStrikeloc',"Emperor Vulcan of the Shi'ar")
            getObjectFromGUID(zone).Call('updateMMEmperorVulcan')
        end
        thronesfavor = player_clicker_color
    elseif player_clicker_color then
        getObjectFromGUID(playerBoards[player_clicker_color]).createButton({
            click_function="thrones_favor", function_owner=self,
            position={-2,0.178,2.1},
            width=750, height=500, label="Throne's Favor", tooltip="Gain or spend the Throne's Favor.", 
            color={0.62,0.16,0.16}
        })
        thronesfavor = player_clicker_color
        if color and color:find("Emperor Vulcan of the Shi'ar") then
            local zone = getObjectFromGUID(mmZoneGUID).Call('getStrikeloc',"Emperor Vulcan of the Shi'ar")
            getObjectFromGUID(zone).Call('updateMMEmperorVulcan')
        end
    end
end

function input_print(obj, color, input, stillEditing)
    if not stillEditing then
        setupText = input
    end
end

function random_setup()
    local k = getObjectFromGUID("2aa883").Call('returnRandom')
    local id = math.random(10000)
    setupText = k[id]:gsub("\n","\r\n")
    import_setup()
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

    local heroDeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
    if heroDeck then
        heroDeck.randomize()
        log("Shuffling the hero deck!")
    else
        log("No Hero deck to shuffle")
        broadcastToAll("No Hero deck to shuffle")
    end

    local villainDeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
    if villainDeck then
        villainDeck.randomize()
        log("Shuffling the villain deck!")
    else
        log("No Villain deck to shuffle")
        broadcastToAll("No Villain deck to shuffle")
    end
    
    for _,o in pairs(Player.getPlayers()) do
        local playerBoard = getObjectFromGUID(playerBoards[o.color])
        local playerdeck = playerBoard.Call('returnDeck')
        if playerdeck[1] then 
            playerdeck[1].randomize()
            log("Shuffling " .. o.color .. " Player's deck!")
            playerBoard.Call('click_deal_cards')
            --print("Shuffling " .. Player.getPlayers()[i].color .. " Player's deck!")
        else
            log("No player deck found for player " .. o.color)
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
            local dividedDeck = get_decks_and_cards_from_zone(o)[1]
            if dividedDeck then
                dividedDeck.randomize()
            end
        end
    elseif setupParts and setupParts[1] == "Fear Itself" then
        for _,o in pairs(extrahq) do
            getObjectFromGUID(o).Call('click_draw_hero')
        end
    end
    
    for _,o in pairs(hqguids) do
        getObjectFromGUID(o).Call('click_draw_hero')
    end
    
    local butt = self.getButtons()
    for i,o in pairs(butt) do
        if o.click_function == "click_shuffle" then
            self.removeButton(i-1)
        end
    end
end

function reduceStack(count,stackGUID)
    local stack = getObjectFromGUID(stackGUID)
    --change this zone to move them somewhere else
    --currently we keep this one so players can still get cards back if needed
    local destzone = "2aa883"
    local outOfGameZone = getObjectFromGUID(destzone)
    stack.randomize()
    local stackObjects = stack.getObjects()
    local stackCount = #stackObjects
    while stackCount > count do
        stack.takeObject({
            position = outOfGameZone.getPosition(),
            smooth = false
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

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return Global.Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end

function get_decks_and_cards_from_zone2(params) --should be deprecated
    return get_decks_and_cards_from_zone(params.zoneGUID,params.shardinc,params.bsinc)
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

function unveiledScheme(newscheme)
    scheme = newscheme
    setupParts[1] = scheme.getName()
end

function returnColor()
    --print("this is a dummy function for button clicks")
end

function lockCard(obj,delay)
    if not delay then
        delay = 1
    end
    Wait.time(function() obj.locked = true end,delay)
end

function import_setup()
    log("Generating imported setup...")
    playercount = #Player.getPlayers()
    local vildeck_done = {}
    setupParts = {}
    for s in string.gmatch(setupText,"[^\r\n]+") do
        table.insert(setupParts, s)
    end
    
    --remove buttons to avoid disrupting the game
    local butt = self.getButtons()
    local rand = nil
    local imp = nil
    for i,o in pairs(butt) do
        if o.click_function == "random_setup" then
            rand = i-1
        end
        if o.click_function == "import_setup" then
            imp = i-1
        end
    end
    self.removeButton(rand)
    self.removeButton(imp)
    self.removeInput(0)
    
    local statevars = {
        ["twistsresolved"] = 0,
        ["twistsstacked"] = 0,
        ["strikesresolved"] = 0,
        ["strikesstacked"] = 0,
        --["masterminds"] = "{}",
    }
    
    local label = ""
    local step = 0
    for i,o in pairs(statevars) do
        step = step + 1
        label = label .. i .. "=" .. o
        if step ~= #statevars then
            label = label .. "\n"
        end
    end
    
    statevars_text = ""
    
    input_statevars = function(obj, color, input, stillEditing)
        if not stillEditing then
            statevars_text = input
        end
    end
    
    update_statevars = function()
        local statevar_parts = {}
        for s in string.gmatch(statevars_text,"[^\n]+") do
            table.insert(statevar_parts, s)
        end
        for _,o in pairs(statevar_parts) do
            getObjectFromGUID(pushvillainsguid).Call('updateVar',{varname = (o:gsub("=.*","")),varvalue = (o:gsub(".*=",""))})
        end
        broadcastToAll("State variables were updated! Check logs if inappropriate.")
    end
    
    self.createInput({
        input_function = "input_statevars",
        function_owner = self,
        label          = label,
        value = label,
        font_size      = 150,
        validation     = 1,
        position=inputpos,
        width=2000,
        height=3000
    })
    
    self.createButton({
        click_function="update_statevars", function_owner=self,
        position={-65,0.1,-1}, height=300, width=500, color={0,0,0,1}, font_color = {1,0,0},
        label = "Update",tooltip="Change the state variables. Only in case of emergency or testing!"
    })

    -- SCHEME
    log("Scheme: " .. setupParts[1])
    print("Scheme: " .. setupParts[1])
    print("\n")
    local schemePile = getObjectFromGUID(schemePileGUID)
    local schemeZone = getObjectFromGUID(schemeZoneGUID)
    for _,o in pairs(schemePile.getObjects()) do
        if string.lower(o.name) == string.lower(setupParts[1]) then
            log ("Found scheme: " .. o.name)
            scheme = schemePile.takeObject({position=schemeZone.getPosition(),
                guid=o.guid,
                smooth=false,
                flip=true,
                callback_function = lockCard})
        end
    end
    
    -- WOUNDS
    
    if setupParts[4] ~= "0" then
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
    mmZone.Call('updateMasterminds',mmname)
    if mmname:find(" %- epic") then
        log("Epic mastermind!")
        mmname = mmname:gsub(" %- epic","")
        epicness = true
    end
    mmZone.Call('updateMastermindsLocation',{mmname,mmZoneGUID})
    local mmcardnumber = mmZone.Call('mmGetCards',mmname) 
    local mmShuffle = function(obj)
        local mm = obj
        if mmcardnumber == 4 then
            mm.randomize()
            log("Mastermind tactics shuffled")
            if setupParts[1] == "World War Hulk" then
                mm.takeObject().destruct()
                mm.takeObject().destruct()
            end
            mmZone.Call('setupMasterminds',{obj = obj,epicness=epicness})
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
            mmZone.Call('setupMasterminds',{obj = obj,epicness = epicness})
            if epicness then
                Wait.time(function() mm.flip() end,0.5)
            end
            return mm
        end
        
        local mmSepShuffle = function(obj)
            if epicness == true then
                obj.hide_when_face_down = false
            end
            Wait.time(function() mmZone.Call('setupMasterminds',{obj = mm,epicness = epicness}) end,0.2)
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
        for _,o in pairs(Player.getPlayers()) do
            local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
            woundstack.takeObject({position = playerdeck.getPosition()})
            woundstack.takeObject({position = playerdeck.getPosition()})
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
        schemeSpecials()
    end
    
    if setupParts[1] == "The Demon Bear Saga" then
        log("Taking the demon bear out.")
        setupParts[6] = setupParts[6]:gsub("Demons of Limbo|","")
        local extractBear = function(obj)
            for _,o in pairs(obj.getObjects()) do
                if o.name == "Demon Bear" then
                    obj.takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
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
            pos.y = pos.y + i/7
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
        local test = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        if test and test.getQuantity() == vildeckc then
            return true
        else
            return false
        end
    end   
    
    local vilDeckFlip = function()
        local vildeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
        vildeck.flip()
        if setupParts[1] == "Smash Two Dimensions Together" then
            for i = 7,9 do
                mmZone.Call('lockTopZone',allTopBoardGUIDS[i])
            end
            vildeck.randomize()
            vildeck.setPositionSmooth(getObjectFromGUID(city_zones_guids[3]).getPosition())
            getObjectFromGUID(pushvillainsguid).Call('smashTwoDimensions')
        end
    end
    
    if setupParts[1] == "Five Families of Crime" then 
        local vilDeckSplit = function() 
            log("Splitting villain deck in five")
            local vilDeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
            vilDeck.randomize()
            local subcount = vilDeck.getQuantity()
            subcount = subcount / 5
            local topCityZones = table.clone(allTopBoardGUIDS)
            for i = 1,6 do
                table.remove(topCityZones)
                table.remove(topCityZones,1)
            end
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
            for i,o in pairs(topCityZones) do
                getObjectFromGUID(o).createButton({click_function='click_draw_villain_call',
                    function_owner=self,
                    position={0,0,-0.5},
                    rotation={0,180,0},
                    label="Draw",
                    tooltip="Draw a card from this villain deck dimension.",
                    font_size=100,
                    font_color="Black",
                    color="White",
                    width=375})
            end
            print("Villain deck split in piles above the board!")
        end
        click_draw_villain_call = function(obj)
            fiveFamiliesTargetZone = nil
            for i,o in pairs(allTopBoardGUIDS) do
                if o == obj.guid then
                    fiveFamiliesTargetZone = city_zones_guids[-i+13]
                    break
                end
            end
            if not fiveFamiliesTargetZone then
                log("city zone not found.")
                return nil
            end
            getObjectFromGUID(pushvillainsguid).Call('playVillains',{vildeckguid = obj.guid})
        end
        for i = 3,7 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
        Wait.condition(vilDeckSplit,vilDeckComplete)
        autoplay = false
    elseif setupParts[1] == "Fragmented Realities" then
        local topCityZones = table.clone(topBoardGUIDs)
        table.remove(topCityZones)
        table.remove(topCityZones,1)
        table.remove(topCityZones,1)
        for i = 3,7 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
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
        nonCityZone = function(obj,player_clicker_color)
            broadcastToColor("This city zone does not currently exist!",player_clicker_color)
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
    elseif setupParts[1] == "Breach Parallel Dimensions" then
        local topCityZones = table.clone(allTopBoardGUIDS)
        for i = 1,4 do
            table.remove(topCityZones)
        end
        local vilDeckSplit = function() 
            local vilDeck = get_decks_and_cards_from_zone(villainDeckZoneGUID)[1]
            vilDeck.randomize()
            local subcount = 1
            while subcount > 0 do
                local hqZoneGUID = table.remove(topCityZones)
                mmZone.Call('lockTopZone',hqZoneGUID)
                local hqZone = getObjectFromGUID(hqZoneGUID)
                for j = 1,subcount do
                    if vilDeck.remainder then
                        vilDeck = vilDeck.remainder
                        vilDeck.flip()
                        vilDeck.setPosition({x=hqZone.getPosition().x,y=hqZone.getPosition().y+2,z=hqZone.getPosition().z})
                        subcount = 0
                        break
                    end
                    vilDeck.takeObject({
                        position = {x=hqZone.getPosition().x,y=hqZone.getPosition().y+2,z=hqZone.getPosition().z},
                        flip=true})
                end
                if subcount > 0 then
                    subcount = subcount + 1
                end
            end
            print("Villain deck split in piles above the board!")
        end
        local decksShuffle = function()
            for i=1,#allTopBoardGUIDS do
                local deck = get_decks_and_cards_from_zone(allTopBoardGUIDS[i])[1]
                if deck then
                    deck.randomize()
                    getObjectFromGUID(allTopBoardGUIDS[i]).createButton({click_function='click_draw_villain_call',
                        function_owner=self,
                        position={0,0,-0.5},
                        rotation={0,180,0},
                        label="Draw",
                        tooltip="Draw a card from this villain deck dimension.",
                        font_size=100,
                        font_color="Black",
                        color="White",
                        width=375})
                end
            end
        end
        click_draw_villain_call = function(obj)
            getObjectFromGUID(pushvillainsguid).Call('playVillains',{vildeckguid = obj.guid})
        end
        Wait.condition(vilDeckSplit,vilDeckComplete)
        Wait.time(decksShuffle,2)
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
    local herodeckextracards = 0
    
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
        for i,o in pairs(dividedDeckGUIDs) do
            local zone = getObjectFromGUID(o)
            local col = i:sub(4,-1)
            if col == "Silver" then
                col = "White"
            end
            zone.createButton({click_function='updatePower',
                function_owner=getObjectFromGUID(pushvillainsguid),
                position={0,0,0},
                rotation={0,180,0},
                label=i:sub(4,4),
                tooltip="This is the hero deck for all " .. i:sub(4,-1) .. " heroes.",
                font_size=250,
                font_color=col,
                color={0,0,0,0.75},
                width=10,height=10})
        end
        for i = 3,7 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
        local divideSort = function(obj)
            --log(obj)
            local remo = 0
            for i,o in ipairs(obj.getObjects()) do
                local colors = {}
                for _,tag in pairs(o.tags) do
                    if tag:find("HC1:") or tag:find("HC2") then
                        table.insert(colors,"HC:" .. tag:sub(5,-1))
                    end
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
                        if tag:find("HC1:") or tag:find("HC2") then
                            table.insert(colors,"HC:" .. tag:sub(5,-1))
                        end
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
            herodeckextracards = 6
            findInPile(setupParts[9],hmPileGUID,twistZoneGUID,bugleInvader)
        end
        local heroDeckComplete = function()
            local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
            if herodeck and herodeck.getQuantity() == #heroParts*14 + herodeckextracards then
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

function schemeSpecials ()
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

    if setupParts[1] == "Alien Brood Encounters" then
        for i,guid in pairs(cityguids) do
            getObjectFromGUID(guid).editButton({index = 0,
                label = "Scan",
                click_function = 'scan_villain',
                tooltip = "Scan the face down card in this city space for 1 attack."})
        end 
    end
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
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
        print("Annihilation group " .. setupParts[9] .. " moved next to the scheme.")
    end
    if setupParts[1] == "Build an Underground MegaVault Prison" or setupParts[1] == "Crown Thor King of Asgard" or setupParts[1] == "Mass Produce War Machine Armor" then
        invertCity()
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
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
    end
    if setupParts[1] == "Dark Reign of H.A.M.M.E.R. Officers" then
        mmZone.Call('lockTopZone',topBoardGUIDs[2])
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
                local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
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
    if setupParts[1] == "Drain Mutants' Powers to..." or setupParts[1] == "Hack Cerebro Servers to..." or setupParts[1] == "Hire Singularity Investigations to..." or setupParts[1] == "Raid Gene Banks to..." then
        mmZone.Call('lockTopZone',topBoardGUIDs[1])
        mmZone.Call('lockTopZone',topBoardGUIDs[2])
    end
    if setupParts[1] == "Earthquake Drains the Ocean" then
        getObjectFromGUID(pushvillainsguid).Call('cityLowTides')
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
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
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
        extrahq = {}
        local zone = getObjectFromGUID(hqguids[1])
        local pos = skPile.getPosition()
        pos.z = pos.z + 8
        local zone1 = zone.clone({position = pos})
        table.insert(extrahq,zone1.guid)
        local pos2 = sopile.getPosition()
        pos2.z = pos2.z + 8
        local zone2 = zone.clone({position = pos2})
        table.insert(extrahq,zone2.guid)
        local pos3 = getObjectFromGUID(heroDeckZoneGUID).getPosition()
        pos3.x = pos3.x + 4.4
        local zone3 = zone.clone({position = pos3})
        table.insert(extrahq,zone3.guid)
        getObjectFromGUID(pushvillainsguid).Call('fetchHQ')
        getObjectFromGUID(mmZoneGUID).Call('updateHQ',pushvillainsguid)
        print("Fear itself! Three extra HQ zones, two above the sidekick/officer decks, one next to the hero deck.")
    end
    if setupParts[1] == "Ferry Disaster" then
        getObjectFromGUID(bystandersPileGUID).setPositionSmooth(getObjectFromGUID(topBoardGUIDs[7]).getPosition())
        print("Bystander stack moved above the Sewers.")
        for i = 3,7 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
    end
    if setupParts[1] == "Graduation at Xavier's X-Academy" then
        log("8 bystanders next to scheme")
        for i=1,8 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Hypnotize Every Human" then
        for i = 3,7 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Bystander") then
                for i = 3,7 do
                    local content = get_decks_and_cards_from_zone(topBoardGUIDs[i])
                    local zone = getObjectFromGUID(topBoardGUIDs[i])
                    if content[1] and not zone.getButtons() then
                        zone.createButton({click_function='returnColor',
                            function_owner=self,
                            position={0,0,0},
                            rotation={0,180,0},
                            label="2",
                            tooltip="Fight this hypnotized bystander for 2 to rescue it.",
                            font_size=350,
                            font_color={1,0,0},
                            color={0,0,0,0.75},
                            width=250,height=250})
                    elseif not content[1] and zone.getButtons() then
                        zone.clearButtons()
                    end
                end
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Bystander") then
                for i = 3,7 do
                    local content = get_decks_and_cards_from_zone(topBoardGUIDs[i])
                    local zone = getObjectFromGUID(topBoardGUIDs[i])
                    if content[1] and not zone.getButtons() then
                        zone.createButton({click_function='returnColor',
                            function_owner=self,
                            position={0,0,0},
                            rotation={0,180,0},
                            label="2",
                            tooltip="Fight this hypnotized bystander for 2 to rescue it.",
                            font_size=350,
                            font_color={1,0,0},
                            color={0,0,0,0.75},
                            width=250,height=250})
                    elseif not content[1] and zone.getButtons() then
                        zone.clearButtons()
                    end
                end
            end
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
    if setupParts[1] == "Mutating Gamma Rays" then
        log("Extra Hulk hero in mutation pile.")
        local hulkshuffle = function(obj)
            --obj.flip()
            --obj.randomize()
            local pos = obj.getPosition()
            pos.y = pos.y + 0.1
            for i=1,obj.getQuantity() do
                obj.takeObject({position = pos})
                pos.y = pos.y + 0.1*i
            end
        end
        findInPile(setupParts[9],heroPileGUID,twistZoneGUID,hulkshuffle)
    end
    if setupParts[1] == "Put Humanity on Trial" then
        log("11 bystanders next to scheme")
        for i=1,11 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Ruin the Perfect Wedding" then
        local tobewed = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tobewed, string.lower(s))
        end
        for i = 1,8 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
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
        printToAll(setupParts[9] .. " is the Smugglers/experiments group.")
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
        mmZone.Call('lockTopZone',topBoardGUIDs[5])
        findInPile(setupParts[9],heroPileGUID,topBoardGUIDs[5],betrayalDeck)
    end
    if setupParts[1] == "Secret HYDRA Corruption" then
        log("Only 30 shield officers.")
        reduceStack(30,officerDeckGUID)
    end
    if setupParts[1] == "Secret Wars" then
        for i = 3,8 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
    end
    if setupParts[1] == "Shoot Hulk into Space" then
        log("Extra Hulk hero in mutation pile.")
        local hulkshuffle = function(obj)
            obj.randomize()
            local pos = obj.getPosition()
            pos.y = pos.y + 0.1
            for i=1,obj.getQuantity() do
                obj.takeObject({position = pos, flip = true})
                pos.y = pos.y + 0.1*i
            end
        end
        findInPile(setupParts[9],heroPileGUID,twistZoneGUID,hulkshuffle)
    end
    if setupParts[1] == "Sneak Attack the Heroes' Homes" then
        broadcastToAll("Add one hero of your choice to the hero deck! Take three different non-rare cards from that hero and add them to your starting deck.")
        wndPile.randomize()
        log("Moving wounds to starter decks.")
        for _,o in pairs(Player.getPlayers()) do
            local playerdeck = getObjectFromGUID(playerBoards[o.color]).Call('returnDeck')[1]
            for j = 1,3 do
                wndPile.takeObject({position=playerdeck.getPosition(),
                    flip=false,
                    smooth=false})
            end
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
        obedienceDisk = function(obj,player_clicker_color)
            printToColor("Heroes in the HQ zone below this one cost 1 more for each Obedience Disk (twist) here.",player_clicker_color)
            return nil
        end
        for i = 3,7 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
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
    if setupParts[1] == "Superhuman Baseball Game" then
        print("Not scripted yet!")
    end
    if setupParts[1] == "Symbiotic Absorption" then
        log("Add extra drained mastermind.")
        local mmshuffle = function(obj)
            local mm = obj
            local mmcardnumber = getObjectFromGUID(mmZoneGUID).Call('mmGetCards',mm.getName())
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
        mmZone.Call('lockTopZone',topBoardGUIDs[1])
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
                mmZone.Call('lockTopZone',topBoardGUIDs[i])
            end
            mmZone.Call('lockTopZone',"f394e1")
            mmZone.Call('lockTopZone',"0559f8")
            mmZone.Call('lockTopZone',"39e3d7")
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
        mmZone.Call('lockTopZone',topBoardGUIDs[2])
        mmZone.Call('lockTopZone',topBoardGUIDs[4])
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
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
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
        mmZone.Call('lockTopZone',topBoardGUIDs[1])
    end
    if setupParts[1] == "Unite the Shards" then
        setNotes(getNotes() .. "\r\n\r\n[9D02F9][b]Shards in use:[/b][-] 0")
        shards = {}
        shardlimit = 30
    end
    if setupParts[1] == "United States Split by Civil War" then
        for i = 1,2 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
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
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
        local tacticsKill = function(obj)
            for i=1,3 do
                if lurkingMasterminds[i] == obj.getName() then
                    local zonetokill = getObjectFromGUID(topBoardGUIDs[i*2])
                    mmZone.Call('updateMastermindsLocation',{obj.getName(),topBoardGUIDs[i*2]})
                    mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 2,lurking = true})
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

function updateShards(guid)
    if setupParts and setupParts[1] == "Unite the Shards" then
        if guid then
            local newshard = true
            for i,o in pairs(shards) do
                if o == guid then
                    newshard = false
                    break
                end
            end
            if newshard == true then
                table.insert(shards,guid)
            end
        end
        local shardcount = 0
        for _,o in pairs(shards) do
            local shard = getObjectFromGUID(o)
            if shard then
                shardcount = shardcount + shard.Call('returnVal')
            end
        end
        setNotes(getNotes():gsub("Shards in use:%[/b%]%[%-%] %d+","Shards in use:[/b][-] " .. shardcount))
        return shardcount
    end
end

function returnShardLimit()
    if shardlimit then
        return shardlimit - updateShards()
    else
        return nil
    end
end

function playHorror()
    local horrorPile = getObjectFromGUID(horrorPileGUID)
    local horrorpos = getObjectFromGUID(getObjectFromGUID(mmZoneGUID).Call('getNextMMLoc')).getPosition()
    horrorpos.y = horrorpos.y + 3
    horrorPile.randomize()
    horrorPile.takeObject({position=horrorpos,
            flip=false,
            smooth=false,
            callback_function = resolveHorror})
    --broadcastToAll("Random horror added to the game, above the board.")
end

function resolveHorror(obj)
    table.insert(horrors,obj.getName())
    if obj.getName() == "Army of Evil" then
        broadcastToAll("The Horror! All non-henchmen villains get +1.")
        for i,o in pairs(city_zones_guids) do
            if i > 1 then
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if obj.hasTag("Villain") and not obj.hasTag("Henchmen") then
                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,label = "+1",tooltip = "All non-henchmen villains get +1",id = "ArmyofEvilHorror"})
                            break
                        end
                    end
                end
            end
        end
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
        broadcastToAll("The Horror! Through the Mastermind's endless hatred, scheme twists will now also trigger master strikes from the main Mastermind.")
        return nil
    end
    if obj.getName() == "Enraged Mastermind" then
        local mmname = nil
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID then
                mmname = i
                broadcastToAll("The Horror! The Mastermind becomes enraged and gets +2.")
                break
            end
        end
        if not mmname then
            broadcastToAll("Mastermind defeated? Horror does not apply.")
            return nil
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',
            {mmname = mmname,
            checkvalue = 2,
            label = "+2",
            tooltip = "The Mastermind is enraged and gets +2.",
            f = "mm",
            id = "enragedmm"})
        return nil
    end
    if obj.getName() == "Fight to the End" then
        if finalblow == false then
            broadcastToAll("The Horror! Final blow was enabled, so you have to defeat the Mastermind one more time after you've taken all of his tactics.")
            finalblow = true
            finalblowfixed = true
        else
            log("Final Blow was already active, so this horror doesn't do anything and is skipped.")
            obj.destruct()
            table.remove(horrors)
            playHorror()
        end
        return nil
    end
    if obj.getName() == "Growing Threat" then
        broadcastToAll("The Horror! The mastermind gets +1 for each tactic in all victory piles.")
        function growingThreat()
            local tacticsfound = 0
            for _,o in pairs(Player.getPlayers()) do
                local vpilecontent = get_decks_and_cards_from_zone(vpileguids[o.color])
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,o in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(o.tags) do
                            if k:find("Tactic:") then
                                tacticsfound = tacticsfound + 1
                                break
                            end
                        end
                    end
                elseif vpilecontent[1] and hasTag2({obj=vpilecontent[1],tag="Tactic:"}) then
                    tacticsfound = tacticsfound + 1
                end
            end
            local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
            local mmname = nil
            for i,o in pairs(mmLocations) do
                if o == mmZoneGUID then
                    mmname = i
                    break
                end
            end
            if mmname then
                Wait.time(
                    function() 
                    getObjectFromGUID(mmZoneGUID).Call('mmButtons',
                        {mmname = mmname,
                        checkvalue = tacticsfound,
                        label = "+" .. tacticsfound,
                        tooltip = "The mastermind gets +1 for each tactic in all victory piles.",
                        f = "mm",
                        id = "growingthreat"})
                    end,
                    1)
            end
        end
        function onObjectEnterZone(zone,object)
            if hasTag2({obj=object,tag="Tactic:"}) then
                growingThreat()
            end
        end
        function onObjectLeaveZone(zone,object)
            if hasTag2({obj = object,tag="Tactic:"}) then
                growingThreat()
            end
        end
        return nil
    end
    if obj.getName() == "Legions Upon Legions" then
        broadcastToAll("Legions Upon Legions! Whenever you play a henchman villain from the villain deck, another card will be played.")
        return nil
    end
    if obj.getName() == "Maniacal Mastermind" then
        local mmname = nil
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID then
                mmname = i
                broadcastToAll("The Horror! The Mastermind becomes maniacal and gets +1.")
                break
            end
        end
        if not mmname then
            broadcastToAll("Mastermind defeated? Horror does not apply.")
            return nil
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',
            {mmname = mmname,
            checkvalue = 1,
            label = "+1",
            tooltip = "The Mastermind becomes maniacal and gets +1.",
            f = "mm",
            id = "maniacalmm"})
        return nil
    end
    if obj.getName() == "Misery Upon Misery" then
        broadcastToAll("Misery Upon Misery! Whenever you play a bystander from the villain deck, another card will be played.")
        return nil
    end
    if obj.getName() == "Opening Salvo" then
        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
        broadcastToAll("The Horror! in an opening salvo, each player is wounded.")
        return nil
    end
    if obj.getName() == "Pain Upon Pain" then
        broadcastToAll("Pain Upon Pain! Whenever you complete a master strike, another card will be played.")
        return nil
    end
    if obj.getName() == "Plots Upon Plots" then
        broadcastToAll("Plots Upon Plots! Whenever you complete a scheme twist, another card will be played.")
        return nil
    end
    if obj.getName() == "Psychic Infection" then
        local color = Turns.turn_color
        local playerBoard = getObjectFromGUID(playerBoards[color])
        local dest = playerBoard.positionToWorld(pos_discard)
        dest.y = dest.y + 3
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
                        obj.setPosition(dest)
                        for _,o in pairs(Player.getPlayers()) do
                            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',o.color)
                        end
                        break
                    end
                end
            end
        end
        return nil
    end
    if obj.getName() == "Shadow of the Disciple" then
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local mmloc = mmZone.Call('getNextMMLoc')
        obj.setPosition(getObjectFromGUID(mmloc).getPosition())
        obj.setName("Master Plan")
        obj.addTag("VP5")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,label = "9",tooltip = "Master Plan",id = "masterplan"})
        mmZone.Call('updateMasterminds',obj.getName())
        mmZone.Call('updateMastermindsLocation',{obj.getName(),mmloc})
        mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 0})
        broadcastToAll("The Horror! A master plan was added to the game as an extra mastermind.")
        return nil
    end
    if obj.getName() == "Surprise Assault" then
        getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
        broadcastToAll("The Horror! Two more cards are played from the villain deck in a surprise assault.")
        return nil
    end
    if obj.getName() == "The Apprentice Rises" then
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local mmPile = getObjectFromGUID(mmPileGUID)
        mmPile.randomize()
        local mmloc = mmZone.Call('getNextMMLoc')
        local stripTactics = function(obj)
            obj.flip()
            broadcastToAll("The Horror! " .. obj.getName() .. " was added to the game as an apprentice mastermind with one tactic.")
            mmZone.Call('updateMasterminds',obj.getName())
            mmZone.Call('updateMastermindsLocation',{obj.getName(),mmloc})
            mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 1})
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
        msPile.takeObject({position=getObjectFromGUID(villainDeckZoneGUID).getPosition(),
            flip=true,
            smooth=false})   
        Wait.time(function() get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].randomize() end,1)
        getObjectFromGUID(pushvillainsguid).Call('playVillains')        
        broadcastToAll("The Horror! The blood thickens and a master strike was shuffled into the villain deck! Another villain deck card is even played!")
        return nil
    end
    if obj.getName() == "The Plot Thickens" then
        local twistPile = getObjectFromGUID(twistPileGUID)
        twistPile.takeObject({position=getObjectFromGUID(villainDeckZoneGUID).getPosition(),
            flip=true,
            smooth=false})   
        Wait.time(function() get_decks_and_cards_from_zone(villainDeckZoneGUID)[1].randomize() end,1)    
        broadcastToAll("The Horror! The plot thickens and a scheme twist was shuffled into the villain deck!")
        return nil
    end
    if obj.getName() == "Tyrant Mastermind" then
        local mmname = nil
        local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        for i,o in pairs(mmLocations) do
            if o == mmZoneGUID then
                mmname = i
                broadcastToAll("The Horror! The Mastermind becomes a merciless tyrant and gets +3.")
                break
            end
        end
        if not mmname then
            broadcastToAll("Mastermind defeated? Horror does not apply.")
            return nil
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',
            {mmname = mmname,
            checkvalue = 3,
            label = "+3",
            tooltip = "The Mastermind is a merciless tyrant and gets +3.",
            f = "mm",
            id = "tyrantmm"})
        return nil
    end
    if obj.getName() == "Viral Infection" then
        local color = Turns.turn_color
        local playerBoard = getObjectFromGUID(playerBoards[color])
        local dest = playerBoard.positionToWorld(pos_discard)
        dest.y = dest.y + 3
        obj.addTag("Horror")
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
                        obj.setPosition(dest)
                        getObjectFromGUID(pushvillainsguid).Call('getWound',previous_player.color)
                        break
                    end
                end
            end
        end
        return nil
    end
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
    local bsflip = true
    for i=1,bspilecount do
        if i <= bsCount then
            mojopos = getObjectFromGUID(villainDeckZoneGUID).getPosition()
            bsflip = true
        elseif i <= mojo + bsCount then
            mojopos = getObjectFromGUID(getObjectFromGUID(mmZoneGUID).Call('getStrikeloc',"Mojo")).getPosition()
            bsflip = false
        else 
            mojopos = bsPile.getPosition()
            mojopos.y = mojopos.y +2
            bsflip = false
        end
        bsPile.takeObject({position = mojopos,
            smooth = false,
            flip = bsflip,
            callback_function = mojotagf})
        if bsPile.remainder then
            mojotagf(bsPile.remainder)
            break
        end
    end
    local bsTagged = function()
        local bsdeck = get_decks_and_cards_from_zone(bszoneguid)
        if bsdeck[1] and bsdeck[1].getQuantity() == bspilecount - bsCount - mojo then
            return true
        else
            return false
        end
    end
    local setNewBSGUID = function()
        local bsDeck = get_decks_and_cards_from_zone(bszoneguid)
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