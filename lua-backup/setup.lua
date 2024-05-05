function onLoad()
    createButtons()
    setupText = ""
    horrors = {}
    loadGUIDs()
    
    autoplay = true
    autoplayfixed = false
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
        click_function="click_thrones_favor", function_owner=self,
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
    if autoplayfixed then
        return nil
    end
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

function disable_autoplay()
    autoplay = false
    autoplayfixed = true
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

function disable_finalblow()
    finalblow = false
    finalblowfixed = true
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

function click_thrones_favor(obj,player_clicker_color)
    thrones_favor({obj = obj,
        player_clicker_color = player_clicker_color})
end

function thrones_favor(params)
    local obj = params.obj
    local player_clicker_color = params.player_clicker_color
    local notspend = params.notspend
    local dospend = params.dospend

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
    if dospend or (color and (player_clicker_color == color or (color:find("mm") and player_clicker_color == color))) then
        self.createButton({
            click_function="click_thrones_favor", function_owner=self,
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
            click_function="click_thrones_favor", function_owner=self,
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
            click_function="click_thrones_favor", function_owner=self,
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

function reduceStack2(params)
    reduceStack(params.n,params.stackGUID)
end

function findInPile(deckName,pileGUID,destGUID,callbackf,fsourceguid,n)
    local callbackf_tocall = function(obj)
        if fsourceguid and callbackf then
            getObjectFromGUID(fsourceguid).Call(callbackf,obj)
        elseif callbackf then
            callbackf(obj)
        end
    end
    local pile = getObjectFromGUID(pileGUID)
    local targetDeckZone = nil
    if destGUID then
        targetDeckZone= getObjectFromGUID(destGUID)
    else
        targetDeckZone= getObjectFromGUID(villainDeckZoneGUID)
    end
    local count = 0
    for _,object in pairs(pile.getObjects()) do
        if string.lower(object.name) == string.lower(deckName) then
            log ("found " .. deckName .. "!")
            local deckGUID= object.guid
            deck = pile.takeObject({guid=deckGUID,
                position=targetDeckZone.getPosition(),
                smooth=false,
                flip=true,
                callback_function = callbackf_tocall})
            if not n then
                return deck
            end
            count = count + 1
        end
    end
    return count
end

function findInPile2(params)
    return findInPile(params.deckName,params.pileGUID,params.destGUID,params.callbackf,params.fsourceguid,params.n)
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

    setup_scheme()
end

function setup_scheme()
    -- SCHEME
    log("Scheme: " .. setupParts[1])
    print("Scheme: " .. setupParts[1])
    print("\n")
    local schemePile = getObjectFromGUID(schemePileGUID)
    local schemeZone = getObjectFromGUID(schemeZoneGUID)
    local scheme_finished = function(obj)
        lockCard(obj)
        Wait.condition(
            function()
                setup_mm()
            end,
            function()
                if obj.spawning then
                    return false
                else
                    return true
                end
            end)
    end
    for _,o in pairs(schemePile.getObjects()) do
        if string.lower(o.name) == string.lower(setupParts[1]) then
            log ("Found scheme: " .. o.name)
            scheme = schemePile.takeObject({position=schemeZone.getPosition(),
                guid=o.guid,
                smooth=false,
                flip=true,
                callback_function = scheme_finished})
        end
    end
end    

function setup_mm()
    shuffle_setup()
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
        local guid = obj.guid

        Wait.condition(
            function()
                setup_rest(mm)
            end,
            function()
                if obj.remainder then
                    obj = obj.remainder
                end
                if obj == nil then
                    obj = getObjectFromGUID(guid)
                end
                if obj.spawning then
                    return false
                else
                    return true
                end
            end)

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
                    index=0,
                    callback_function = function() 
                        getObjectFromGUID(mmZoneGUID).Call('click_update_tactics',getObjectFromGUID(mmZoneGUID))
                    end})
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

end
   
function setup_rest(mm)
    local vildeck_done = {}
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

    -- Special game setup modifications

    local herodeckextracards = 0
    if scheme.getVar("setupSpecial") then
        local setupModifications = scheme.Call('setupSpecial',{setupParts = table.clone(setupParts)})
        if setupModifications then
            for i,o in pairs(setupModifications) do
                if i == "villdeckc" then
                    table.insert(vildeck_done,o)
                elseif i == "setupParts" then
                    setupParts = table.clone(o)
                elseif i == "herodeckextracards" then
                    herodeckextracards = o
                elseif i == "heroDeckFlip_custom" then
                    heroDeckFlip_custom = o
                end
            end
        end
    end

    if mm.getVar("setupSpecial") then
        local mmModifications = mm.Call('setupSpecial',{setupParts = table.clone(setupParts)})
        if mmModifications then
            for i,o in pairs(mmModifications) do
                if i == "villdeckc" then
                    table.insert(vildeck_done,o)
                elseif i == "setupParts" then
                    setupParts = table.clone(o)
                end
            end
        end
    end
    
    -- Bystanders
    
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    bsPile.randomize()
    local bsCount = tonumber(setupParts[3])
    log("Bystanders: " .. bsCount)
    table.insert(vildeck_done,bsCount)
    for i=1,bsCount do
        bsPile.takeObject({position = vilDeckZone.getPosition(),
            flip = true,
            smooth = false})
        log(bsCount .. " bystanders added to villain deck.")
    end

    -- Scheme twists
          
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

    -- flip villain deck once it's complete, apply any post-finish setup modifications
    
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
    end
    
    if scheme.getVar("villainDeckSpecial") then
        Wait.condition(
            function()
                scheme.Call('villainDeckSpecial',{vildeckc = vildeckc})
            end,
            vilDeckComplete)
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
        if herodeck and herodeck.getQuantity() == #heroParts*14 + herodeckextracards then
            return true
        else
            return false
        end
    end
    local heroDeckFlip = function()
        local herodeck = get_decks_and_cards_from_zone(heroDeckZoneGUID)[1]
        herodeck.flip()
        if heroDeckFlip_custom then
            getObjectFromGUID(heroDeckFlip_custom.guid).Call(heroDeckFlip_custom.f,herodeck)
        end
    end
    Wait.condition(heroDeckFlip,heroDeckComplete)
    return nil
end

function shuffle_setup()
    local sopile = getObjectFromGUID(officerDeckGUID)
    sopile.randomize()
    local skPile = getObjectFromGUID(sidekickDeckGUID)
    skPile.randomize()
    local wndPile = getObjectFromGUID(woundsDeckGUID)
    wndPile.randomize()
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