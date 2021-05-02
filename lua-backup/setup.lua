setupText = ""
playerdeckIDs = {
        "e3db1b",
        "504f36",
        "6869d3",
        "098082",
        "dedfc6"
        }
playercolors = {
    "Yellow",
    "Green",
    "Red",
    "White",
    "Blue"}
    
playerBoards = {
    ["Red"]="8a35bd",
    ["Green"]="d7ee3e",
    ["Yellow"]="ed0d43",
    ["Blue"]="9d82f3",
    ["White"]="206c9c"
}
    
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

    Turns.enable = true
end

function input_print(obj, color, input, stillEditing)
    if not stillEditing then
        setupText = input
        --log("Imported setup is...")
        --for token in string.gmatch(input, "[^;]+") do
        --    print(token)
        --end
    end
end

function click_shuffle()

    log("Shuffle: heroes, villains, bystanders, wounds, sidekicks, shield officers, player decks")
    print("Shuffling decks! Only before startup!")
    local woundsDeckGUID="653663"
    woundsDeck=getObjectFromGUID(woundsDeckGUID)
    if woundsDeck  then woundsDeck.randomize() end
    log("Shuffling wounds stack!")

    local sidekickDeckGUID="959976"
    local sidekickDeck=getObjectFromGUID(sidekickDeckGUID)
    if sidekickDeck  then sidekickDeck.randomize() end
    log ("shuffling sidekick stack!")

    local bystandersPileGUID="0b48dd"
    local bystanderDeck=getObjectFromGUID(bystandersPileGUID)
    if bystanderDeck  then bystanderDeck.randomize() end
    log("Shuffling bystander deck!")
    
    local officerDeckGUID="9c9649"
    local officerDeck=getObjectFromGUID(officerDeckGUID)
    if officerDeck  then officerDeck.randomize() end
    log("Shuffling SHIELD officer stack!")

    local heroDeckZoneGUID="0cd6a9"
    local heroDeckZone=getObjectFromGUID(heroDeckZoneGUID)
    local heroDeck = heroDeckZone.getObjects()
    if heroDeck and heroDeck[2] and  heroDeck[2].tag=="Deck" then
        heroDeck[2].randomize()
        log("Shuffling the hero deck!")
    else
        log("No Hero deck to shuffle")
        print("No Hero deck to shuffle")
    end

    local villainDeckZoneGUID =  "4bc134"
    local villainDeckZone=getObjectFromGUID(villainDeckZoneGUID)
    local villainDeck = villainDeckZone.getObjects()
    if villainDeck and villainDeck[2] and villainDeck[2].tag=="Deck" then
        villainDeck[2].randomize()
        log("Shuffling the villain deck!")
    else
        log("No Villain deck to shuffle")
        print("No Villain deck to shuffle")
    end
    
    for i=1,5 do
        if Player[playercolors[i]].seated == true then
            playerdeck = getObjectFromGUID(playerdeckIDs[i])
            if playerdeck then 
                playerdeck.randomize()
                log("Shuffling " .. Player.getPlayers()[i].color .. " Player's deck!")
                print("Shuffling " .. Player.getPlayers()[i].color .. " Player's deck!")
            else
                log("No player deck found for player " .. playercolors[i])
            end
        end
    end

end

function reduceStack(count,stackGUID)

    local stack = getObjectFromGUID(stackGUID)
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
        targetDeckZone= getObjectFromGUID("4bc134")
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

function mmGetCards(mmname)
    mmcardnumber = 5
    if mmname == "Hydra High Council" or mmname == "Hydra Super-Adaptoid" then
            mmcardnumber = 4
    end
    return(mmcardnumber)
end

function returnSetupParts()
    -- setupElements = {
        -- ["Scheme"]=1,
        -- ["Mastermind"]=5,
        -- ["Villains"]=6,
        -- ["Henchmen"]=7,
        -- ["Heroes"]=8,
        -- ["Extra"]=9
    -- }
    return setupParts
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
    local schemePile=getObjectFromGUID("0716a4")
    local schemeZone=getObjectFromGUID("c39f60")
    for index,object in pairs(schemePile.getObjects()) do
        if string.lower(object.name) == string.lower(setupParts[1]) then
            log ("Found scheme: " .. object.name)
            local schemeGUID = object.guid
            schemePush = schemePile.takeObject({guid=schemeGUID,
            position=schemeZone.getPosition(),
            smooth=false,flip=true})
        end
    end
    
    -- WOUNDS
    
    if setupParts[4] != "0" then
        log("Wound stack reduced to " .. setupParts[4])
        reduceStack(tonumber(setupParts[4]),"653663")
    end
    
    -- MASTERMIND
    
    log("Mastermind: " .. setupParts[5])
    print("Mastermind: " .. setupParts[5])
    print("\n")
    local mmPile=getObjectFromGUID("c7e1d5")
    local mmZone=getObjectFromGUID("a91fe7")
    mmname = setupParts[5]
    epicness = false
    if mmname:find(" %- epic") then
        log("Epic mastermind!")
        epicness = true
    end
    mmname = mmname:gsub(" %- epic","")
    mmcardnumber = mmGetCards(mmname)
    
    mmshuffle = function(obj)
        mm = obj
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
            for i=1,4 do
                log("Mastermind Tactics Into Villain Deck")
                mm.takeObject({position=vilDeckZone.getPosition(),
                    smooth=false,flip=false,index=0})
            end
            return mm
        end
        
        mmSepShuffle = function(obj)
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
    
    for i,o in pairs(mmPile.getObjects()) do
        if string.lower(o.name) == string.lower(mmname) then
            log ("Found mastermind: " .. setupParts[5])
            mmGUID = o.guid
            mmPile.takeObject({guid=mmGUID,
                position=mmZone.getPosition(),
                smooth=false,
                flip=true,
                callback_function = mmshuffle})
        end
    end
    
    strikepile = getObjectFromGUID("be6070")
    
    if mmname == "J. Jonah Jameson" then
        sopile = getObjectFromGUID("9c9649")
        sopile.randomize()
        local jonah = 2
        if epicness == true then
            jonah = 3
        end
        for i=1,jonah*playercount do
            sopile.takeObject({position = strikepile.getPosition(),
                flip=false,
                smooth=false})
        end
        log(jonah .. " random SHIELD officers moved above the Mastermind.")
    end
    
    -- Master Strike
    
    log("Master strikes: 5")
    local msPile = getObjectFromGUID("aff2e5")
    vilDeckZone=getObjectFromGUID("4bc134")
    table.insert(vildeck_done,5)
    for i=1,5 do
        msPile.takeObject({position=vilDeckZone.getPosition(),
            flip=false,
            smooth=false})
    end
    log("5 Master strikes added to villain deck.")
    
    -- Bystanders
    
    bsPile = getObjectFromGUID("0b48dd")
    bsPile.randomize()
    bs = tonumber(setupParts[3])
    log("Bystanders: " .. bs)
    
    if mmname ~= "Mojo" then
        table.insert(vildeck_done,bs)
        for i=1,bs do
            bsPile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,
                smooth=false})
            log(bs .. " bystanders added to villain deck.")
        end
    end
    
    horrorpile = getObjectFromGUID("b119a8")
    horrorspot = getObjectFromGUID("ef2805")
    
    if mmname == "Arcade" then
        local arc = 5
        if epicness == true then
            arc = 8
            horrorpile.randomize()
            horrorpile.takeObject({position=horrorspot.getPosition(),
                    flip=false,
                    smooth=false})    
            log("Random horror added to the game (New Recruits zone)")
        end
        for i=1,arc do
            bsPile.takeObject({position=strikepile.getPosition(),
                flip=false,
                smooth=false})
        end
        log(arc .. " Human Shields moved to master strike zone.")
    end
    
    if mmname == "General Ross" then
        for i=1,8 do
            bsPile.takeObject({position=strikepile.getPosition(),
                flip=false,
                smooth=false})
        end
        log("Eight Helicopter bystanders moved to master strike zone.")
    end
    
    if mmname == "Mojo" then
        local mojo = 3
        local mojovp = 3
        if epicness == true then
            mojo = 6
            mojovp = 4
            horrorpile.randomize()
            horrorpile.takeObject({position=horrorspot.getPosition(),
                    flip=false,
                    smooth=false})    
            log("Random horror added to the game (New Recruits zone)")
        end
        mojotag = "VP" .. mojovp
        mojotagf = function(obj)
            obj.setTags({"Bystander",mojotag})
        end
        for i,o in pairs(bsPile.getObjects()) do
            if i <= bs then
                mojopos = vilDeckZone.getPosition()
                bsflip = true
            elseif i <= mojo + bs then
                mojopos = strikepile.getPosition()
                bsflip = false
            else 
            mojopos = {x=bsPile.getPosition().x,
                y=bsPile.getPosition().y+2,
                z=bsPile.getPosition().z}
            bsflip = false
            end
            bsPile.takeObject({position = mojopos,
                    --guid = o,
                    smooth = false,
                    flip = bsflip,
                    callback_function = mojotagf})
        end
        table.insert(vildeck_done,bs)
        broadcastToAll("Mojo! Bystanders net " .. mojovp .. " victory points each!")
        log(mojo .. " Human Shields moved to master strike zone.")
    end
    
    if mmname == "The Sentry" then
        woundstack = getObjectFromGUID("653663")
        for i=1,5 do
            if Player[playercolors[i]].seated == true then
                playerdeck = getObjectFromGUID(playerdeckIDs[i])
                woundstack.takeObject({position = playerdeck.getPosition()})
                woundstack.takeObject({position = playerdeck.getPosition()})
            end
        end
        log("Wounds added to player starter decks. Still shuffle!")
        broadcastToAll("2 wounds in starter deck because of The Sentry. Bastard.")
    end
    
    if mmname == "Onslaught" then
        for i=1,5 do
            if Player[playercolors[i]].seated == true then
                board = getObjectFromGUID(playerBoards[playercolors[i]])
                board.Call('onslaughtpain')
            end
        end
        broadcastToAll("Good luck! You're going to need it.")
    end
    
    if mmname == "Shadow King" then
        if epicness == true then
            horrorpile.randomize()
            for i = 1,2 do
                horrorpile.takeObject({position=horrorspot.getPosition(),
                    flip=false,smooth=false})
            end
            log("Two random horrors added to the game (New Recruits zone)")
        end
    end
    
    -- Scheme twists
    
    if setupParts[1] ~= "Fragmented Realities" then        
        st = tonumber(setupParts[2])
        log("Scheme twists: " .. st)
        table.insert(vildeck_done,st)
        local stPile = getObjectFromGUID("c82082")
        for i=1,st do
            stPile.takeObject({position=vilDeckZone.getPosition(),
                flip=false,
                smooth=false})    
        end
        log(st .. " scheme twists added to villain deck.")
        schemeSpecials(setupParts,mmGUID)
    end
    
    if setupParts[1] == "The Demon Bear Saga" then
        log("Taking the demon bear out.")
        setupParts[6] = setupParts[6]:gsub("Demons of Limbo|","")
        extractBear = function(obj)
            for i,o in pairs(obj.getObjects()) do
                if o.name == "Demon Bear" then
                    obj.takeObject({position=twistpile.getPosition(),
                        flip=false,smooth=false,guid=o.guid})
                    obj.setPositionSmooth(vilDeckZone.getPosition())
                    break
                end
            end
            log("Demon Bear moved to twists pile. Other demons to villain deck.")
        end
        findInPile("Demons of Limbo","375566","1fa829",extractBear)
    end
    
    -- Villain groups
    
    log(setupParts[6])
    vilgroups = setupParts[6]:gsub("%|","\n")
    print("Villain Groups:\n" .. vilgroups)
    print("\n")
    local vilPile=getObjectFromGUID("375566")
    vilParts = {}
    for s in string.gmatch(setupParts[6],"[^|]+") do
        table.insert(vilParts, string.lower(s))
    end
    table.insert(vildeck_done,#vilParts*8)
    for index,object in pairs(vilPile.getObjects()) do
        for i,o in pairs(vilParts) do
            if o == string.lower(object.name) then
                log ("Found villain group: " .. object.name)
                local vilGUID = object.guid
                vilPush = vilPile.takeObject({guid=vilGUID,
                    position=vilDeckZone.getPosition(),
                    smooth=false,
                    flip=true})
            end
        end
    end
    
    -- Henchmen groups
    
    log(setupParts[7])
    hengroups = setupParts[7]:gsub("%|","\n")
    print("Henchmen Groups:\n" .. hengroups)
    print("\n")
    local hmPile=getObjectFromGUID("de8160")
    hmParts = {}
    for s in string.gmatch(setupParts[7],"[^|]+") do
        table.insert(hmParts, string.lower(s))
    end
    table.insert(vildeck_done,#hmParts*10)
    for index,object in pairs(hmPile.getObjects()) do
        for i,o in pairs(hmParts) do
            if o == string.lower(object.name) then
                log ("Found henchmen group: " .. object.name)
                local hmGUID = object.guid
                hmPush = hmPile.takeObject({guid=hmGUID,
                    position=vilDeckZone.getPosition(),
                    smooth=false,
                    flip=true})
            end
        end
    end
    
    if setupParts[1] == "Five Families of Crime" then
        vildeckc = 0
            for i,o in pairs(vildeck_done) do
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
        local vilDeckSplit = function() 
            log("Splitting villain deck in five")
            vilDeck = vilDeckZone.getObjects()[2]
            vilDeck.randomize()
            local subcount = vilDeck.getQuantity()
            subcount = subcount / 5
            hqZonesGUIDs={
                "4c1868",
                "8656c3",
                "533311",
                "3d3ba7",
                "725c5d"}
            for i=1,4 do
                for j=1,subcount do
                    local hqZone=getObjectFromGUID(hqZonesGUIDs[i])
                    vilDeck.takeObject({
                        position    = {x=hqZone.getPosition().x,y=hqZone.getPosition().y+2,z=hqZone.getPosition().z},
                        flip=true})
                end
            end
            local hqZone=getObjectFromGUID(hqZonesGUIDs[5])
            vilDeck.flip()
            vilDeck.setPosition(hqZone.getPosition())
            print("Villain deck split in piles above the board!")
        end
        Wait.condition(vilDeckSplit,vilDeckComplete)
    end
    
    if setupParts[1] == "Fragmented Realities" then
        hqZonesGUIDs={
                "4c1868",
                "8656c3",
                "533311",
                "3d3ba7",
                "725c5d"}
        vildeckc = 0
            for i,o in pairs(vildeck_done) do
                vildeckc = vildeckc + o
            end
        vildeckc2 = vildeckc + playercount*2
        log("Adding scheme twists to the separate villain decks")
        for i=6-playercount,5 do
            local stPile = getObjectFromGUID("c82082")
            local deckZone = getObjectFromGUID(hqZonesGUIDs[i])
            stPile.takeObject({position=deckZone.getPosition(),
                flip=true,smooth=false})
            stPile.takeObject({position=deckZone.getPosition(),
                flip=true,smooth=false})
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
        local vilDeckSplit = function() 
            log("Splitting villain deck in deck for each player")
            vilDeck = vilDeckZone.getObjects()[2]
            vilDeck.randomize()
            local subcount = vilDeck.getQuantity()
            subcount = subcount / playercount
            for i=6-playercount,4 do
                for j=1,subcount do
                    local hqZone=getObjectFromGUID(hqZonesGUIDs[i])
                    vilDeck.takeObject({
                        position    = {x=hqZone.getPosition().x,y=hqZone.getPosition().y+2,z=hqZone.getPosition().z},
                        flip=true})
                end
            end
            local hqZone=getObjectFromGUID(hqZonesGUIDs[5])
            vilDeck.flip()
            vilDeck.setPosition(hqZone.getPosition())
            print("Villain deck split in piles above the board!")
        end
        local decksShuffle = function()
            for i=6-playercount,5 do
                local deck = getObjectFromGUID(hqZonesGUIDs[i]).getObjects()[2]
                deck.randomize()
            end
        end
        local decksMade = function()
            local test2 = 0
            for i=6-playercount,5 do
                local deck = getObjectFromGUID(hqZonesGUIDs[i]).getObjects()[2]
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
        hopetoken = getObjectFromGUID("e27f77")
        for i=6-playercount,5 do
            deckzone = getObjectFromGUID(hqZonesGUIDs[i])
            newtoken = hopetoken.clone({
                position = {x=deckzone.getPosition().x,y=deckzone.getPosition().y,z=deckzone.getPosition().z+4}
                })
            newtoken.setColorTint(Player.getPlayers()[i-5+playercount].color)
            newtoken.setName(Player.getPlayers()[i-5+playercount].color .. " Player's Villain Deck")
        end
    end
    
    -- Heroes
    
    log(setupParts[8])
    herogroups = setupParts[8]:gsub("%|","\n")
    print("Heroes:\n" .. herogroups)
    local heroPile=getObjectFromGUID("16594d")
    local heroZone=getObjectFromGUID("0cd6a9")
    heroParts = {}
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
        local divideSort = function(obj)
            --log(obj)
            for i,o in pairs(obj.getObjects()) do
                local colors = {}
                for j,tag in pairs(o.tags) do
                    if tag:find("HC:") then
                        table.insert(colors,tag)
                    end
                end
                if #colors > 1 then
                    table.remove(colors,math.random(2))
                end
                local dividedDeckZone = getObjectFromGUID(dividedDeckGUIDs[colors[1]])
                if not obj.remainder then
                    obj.takeObject({guid=o.guid,
                        position=dividedDeckZone.getPosition(),
                        smooth=false})
                else
                    obj.remainder.setPosition(dividedDeckZone.getPosition())
                end
            end
        end
        for i,o in pairs(heroParts) do
            for index,object in pairs(heroPile.getObjects()) do
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
        for i,o in pairs(heroParts) do
            for index,object in pairs(heroPile.getObjects()) do
                if o == string.lower(object.name) then
                    log ("Found hero: " .. object.name)
                    local heroGUID = object.guid
                    heroPush = heroPile.takeObject({guid=heroGUID,
                        position=heroZone.getPosition(),
                        smooth=false,flip=true})
                end
            end
        end
    end
    
    if setupParts[1] == "Secret Invasion of the Skrull Shapeshifters" then
        local skrullShuffle = function() 
            log("Shuffle 12 hero cards in villain deck.")
            print("12 random hero cards shuffled into villain deck.")
            heroDeck = heroZone.getObjects()[2]
            heroDeck.randomize()
            for i=1,12 do
                heroDeck.takeObject({position=vilDeckZone.getPosition(),
                    flip=false,smooth=false})
            end
        end
        local heroDeckComplete = function()
            local test = heroZone.getObjects()[2]
            if test ~= nil then 
                local test2 = #heroParts - 1
                if test.getQuantity() == test2*14 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        Wait.condition(skrullShuffle,heroDeckComplete)
    end
    
    return nil
end

function schemeSpecials (setupParts,mmGUID)
    playercount = #Player.getPlayers()
    local bsPile = getObjectFromGUID("0b48dd")
    bsPile.randomize()
    local sopile = getObjectFromGUID("9c9649")
    sopile.randomize()
    vilDeckZone = getObjectFromGUID("4bc134")
    local schemZone = getObjectFromGUID("c39f60")
    local skPile = getObjectFromGUID("959976")
    skPile.randomize()
    twistpile = getObjectFromGUID("4f53f9")
    local wndPile = getObjectFromGUID("653663")
    wndPile.randomize()
    mmZone=getObjectFromGUID("a91fe7")
    local stPile = getObjectFromGUID("c82082")
    heroZone=getObjectFromGUID("0cd6a9")

    
    if setupParts[1] == "Brainwash the Military" then
        log("12 officers in villain deck.")
        for i=1,12 do
            sopile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,smooth=false})
        end
    end
    if setupParts[1] == "Build an Army of Annihilation" then
        log("Add extra annihilation group.")
        local henchsczone = getObjectFromGUID("8656c3")
        local renameHenchmen = function(obj)
            for i=1,10 do
                cardTaken = obj.takeObject({position=henchsczone.getPosition()})
                cardTaken.setName("Annihilation Wave Henchmen")
            end
        end
        findInPile(setupParts[9],"de8160","bf7e87",renameHenchmen)
        print("Annihilation group " .. setupParts[9] .. " moved next to the scheme.")
    end
    if setupParts[1] == "Cage Villains in Power-Suppressing Cells" then
        log("Add extra cops henchmen.")
        local ditchCops = function(obj)
            copstoditch = 10-playercount*2
            henchpos = getObjectFromGUID("de8160").getPosition()
            henchpos.y = henchpos.y + 5
            for i = 1,copstoditch do
                obj.takeObject({position=henchpos,smooth=false})
            end
        end
        findInPile("Cops","de8160","8656c3",ditchCops)
        print("Cops moved next to scheme.")
    end
    if setupParts[1] == "Capture Baby Hope" then
        log("Baby hope token moved to scheme.")
        local babyHope = getObjectFromGUID("e27f77")
        babyHope.setPosition(schemZone.getPosition())
    end
    if setupParts[1] == "Clash of the Monsters Unleashed" then
        log("Add extra Monsters Unleashed villains.")
        findInPile("Monsters Unleashed","375566","4f53f9")
        print("Monsters Unleashed moved to twists pile.")
    end
    if setupParts[1] == "Corrupt the Next Generation of Heroes" then
        log("Add 10 sidekicks to villain deck.")
        for i=1,10 do
            skPile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,smooth=false})
        end
    end
    if setupParts[1] == "Crown Thor King of Asgard" then
        log("Add extra Avengers villain group.")
        local onlyThor = function(obj)
            for i,o in pairs(obj.getObjects()) do
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
        findInPile("Avengers","375566","1fa829",onlyThor)
    end
    if setupParts[1] == "Cytoplasm Spike Invasion" then
        log("Make a cytoplasm and bystander infected deck.")
        findInPile("Cytoplasm Spikes","de8160","4f53f9")
        for i=1,20 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=true,smooth=false})
        end
        local infectedDeckReady = function()
            infec = twistpile.getObjects()[2]
            if infec ~= nil then
                if infec.getQuantity() == 30 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        local infectedDeckShuffle = function()
            infectedDeck = twistpile.getObjects()[2]
            infectedDeck.flip()
            infectedDeck.randomize()
        end
        Wait.condition(infectedDeckShuffle,infectedDeckReady)
        print("Infected deck moved to twists pile.")
    end
    if setupParts[1] == "Destroy the Nova Corps" then
        playercount = #Player.getPlayers()
        sopile.randomize()
        wndPile.randomize()
        local novaDist = function(obj)
            log("Moving additional cards to starter decks.")
            novaguids = {}
            for i,o in pairs(obj.getObjects()) do
                for k,p in pairs(o.tags) do
                    if p == "Cost:2" then
                        table.insert(novaguids,o.guid)
                    end
                end
            end
            for i=1,playercount do
                local color = Player.getPlayers()[i].color
                for j=1,#playercolors do
                    if playercolors[j] == color then
                        deckid = playerdeckIDs[j]
                    end
                end
                playerdeck = getObjectFromGUID(deckid)
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
        findInPile(setupParts[9],"16594d","1fa829",novaDist)
        local novaMoved = function()
            local novaloc = getObjectFromGUID("1fa829").getObjects()[1]
            q = 14 - playercount
            if novaloc ~= nil then
                if novaloc.getQuantity() == q then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        local novaShuffle = function()
        log("Moving remaining Nova cards to hero deck.")
            local novaloc = getObjectFromGUID("1fa829").getObjects()[1]
            q = 14 - playercount
            for i=1,q do
                novaloc.takeObject({position=heroZone.getPosition(),
                    flip=false,smooth=false})
            end
        end
        Wait.condition(novaShuffle,novaMoved)
    end
    if setupParts[1] == "Explosion at the Washington Monument" then
        washingtonMonumentZonesGUIDs ={
            "1fa829",
            "bf7e87",
            "4c1868",
            "8656c3",
            "533311",
            "3d3ba7",
            "725c5d",
            "4e3b7e"
            }
        log("Set up the Washington Monument stacks...")
        topzone = getObjectFromGUID("1fa829")
        log("Gathering wounds and bystanders...")
        for i=1,18 do
            bsPile.takeObject({position=topzone.getPosition(),
                flip=false,smooth=false})
        end
        for i=1,14 do
            wndPile.takeObject({position=topzone.getPosition(),
                flip=false,smooth=false})
        end
        log("Shuffle..")
        local stack_created = function() 
            local test = topzone.getObjects()[1]
            if test then 
                if test.getQuantity() == 32 then
                    return true
                else
                    return false
                end
            else
                return false
            end 
        end
        local stack_floors = function()
            floorstack = topzone.getObjects()[1]
            floorstack.randomize()
            for i=2,8 do
                log("Creating floor " .. i)
                floorZone = getObjectFromGUID(washingtonMonumentZonesGUIDs[i])
                for j=1,4 do
                    floorstack.takeObject({
                        position    = {x=floorZone.getPosition().x,y=floorZone.getPosition().y+2,z=floorZone.getPosition().z},
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
    if setupParts[1] == "Graduation at Xavier's X-Academy" then
        log("8 bystanders next to scheme")
        for i=1,8 do
            bsPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "House of M" then
        log("Scarlet Witch in villain deck.")
        findInPile("Scarlet Witch (R)","16594d","4bc134")
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
            local hmPile = getObjectFromGUID("de8160")
            for i=1,4 do
                obj.takeObject({position=hmPile.getPosition(),
                    flip=false,smooth=false})
            end
        end
        findInPile(setupParts[9],"de8160","4f53f9",bugleInvader)
    end
    if setupParts[1] == "Master of Tyrants" then
        log("Moving extra masterminds outside the board.")
        tyrants = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tyrants, string.lower(s))
        end
        tyrantzones = {
            "1fa829",
            "bf7e87",
            "4c1868"}
        tyrantsnumber = {}
        for i,o in pairs(tyrants) do
            tyrantsnumber[i] = mmGetCards(o)
        end
        local shuffleTyrantTactics = function(obj)
              for i=1,4 do
                log("Mastermind Tactics Into Villain Deck")
                obj.takeObject({position=vilDeckZone.getPosition(),
                    smooth=false,flip=false,index=0})
              end
        end
        for i=1,3 do
            findInPile(tyrants[i],
                "c7e1d5",
                tyrantzones[i],
                shuffleTyrantTactics)
        end
        print("Extra mastermind tactics shuffled into villain deck! Their front cards can still be seen above the board.")
        -- still remove remaining mm cards then
        -- can stay there to show what is in the deck
    end
    if setupParts[1] == "Mutating Gamma Rays" or setupParts[1] == "Shoot Hulk into Space" then
        log("Extra Hulk hero in mutation pile.")
        findInPile(setupParts[9],"16594d","4f53f9")
    end
    if setupParts[1] == "Ruin the Perfect Wedding" then
        tobewed = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tobewed, string.lower(s))
        end
        log("Extra heroes to be wed in separate piles.")
        findInPile(tobewed[1],"16594d","1fa829")
        findInPile(tobewed[2],"16594d","4e3b7e")
        print("Still sort the two to be wed hero card decks according to cost!")
    end
    if setupParts[1] == "Replace Earth's Leaders with Killbots" then
        log("Set up 3 twists next to scheme already.")
        for i=1,3 do
            stPile.takeObject({position=twistpile.getPosition(),
                flip=false,smooth=false})
        end
    end
    if setupParts[1] == "Scavenge Alien Weaponry" or setupParts[1] == "Devolve with Xerogen Crystals" then
        log("Identify the smugglers/experiments group.")
        print(setupParts[9] .. " is the Smugglers/experiments group.")
    end
    if setupParts[1] == "Secret Empire of Betrayal" then
        log("Extra hero in dark betrayal pile.")
        findInPile(setupParts[9],"16594d","4f53f9")
        print("Select 5 cards of the betrayer hero that cost < 5.")
    end
    if setupParts[1] == "Secret HYDRA Corruption" then
        log("Only 30 shield officers.")
        reduceStack(30,"9c9649")
    end
    if setupParts[1] == "Sinister Ambitions" then
        log("Add ambitions to villain deck.")
        ambPile = getObjectFromGUID("cf8452")
        ambPile.randomize()
        for i=1,10 do
            ambPile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,smooth=false})
        end
    end
    if setupParts[1] == "Superhuman Baseball Game" or setupParts[1] == "Smash Two Dimensions Together" then
        print("Not scripted yet!")
    end
    if setupParts[1] == "Symbiotic Absorption" then
        log("Add extra drained mastermind.")
        findInPile(setupParts[9],"c7e1d5","1fa829")
    end
    if setupParts[1] == "The Contest of Champions" then
        heroParts = {}
        for s in string.gmatch(setupParts[8],"[^|]+") do
            table.insert(heroParts, string.lower(s))
        end
        local heroDeckComplete = function()
            local test = heroZone.getObjects()[2]
            if test ~= nil then 
                local test2 = #heroParts - 1
                if test.getQuantity() == test2*14 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        local makeChampions = function()
            herodeck = heroZone.getObjects()[2]
            herodeck.randomize()
            posi = getObjectFromGUID("1fa829")
            print("Putting 11 contestants above the board!")
            for i=1,11 do
                herodeck.takeObject({
                    position = {x=posi.getPosition().x+4*i,y=posi.getPosition().y,z=posi.getPosition().z}
                    })
            end
        end
        Wait.condition(makeChampions,heroDeckComplete)
    end
    if setupParts[1] == "The Dark Phoenix Saga" or setupParts[1] == "Transform Citizens Into Demons" then
        log("Jean Grey in villain deck.")
        findInPile("Jean Grey (DC)","16594d","4bc134")
    end
    if setupParts[1] == "The Mark of Khonshu" or setupParts[1] == "Trap Heroes in the Microverse" or setupParts[1] == "X-Cutioner's Song" then
        log("Extra hero " .. setupParts[9] .." in villain deck.")
        findInPile(setupParts[9],"16594d","4bc134")
    end
    if setupParts[1] == "Tornado of Terrigen Mists" then
        log("Add player tokens.")
        hopetoken = getObjectFromGUID("e27f77")
        sewers = getObjectFromGUID("40b47d")
        for i=1,playercount do
            if i < 4 then
                newtoken = hopetoken.clone({
                    position = {x=sewers.getPosition().x,y=sewers.getPosition().y,z=sewers.getPosition().z+i*0.5}
                })
            elseif i == 4 then
                newtoken = hopetoken.clone({
                    position = {x=sewers.getPosition().x+i*0.5,y=sewers.getPosition().y,z=sewers.getPosition().z}
                })
            else
                newtoken = hopetoken.clone({
                    position = {x=sewers.getPosition().x+i*0.5,y=sewers.getPosition().y,z=sewers.getPosition().z+1}
                })
            end
            newtoken.setColorTint(Player.getPlayers()[i].color)
            newtoken.setName(Player.getPlayers()[i].color .. " Player")
        end

    end
    if setupParts[1] == "Turn the Soul of Adam Warlock" then
        log("Set up Adam Warlock pile.")
        -- ordering should be done in the card pile itself
        findInPile("Adam Warlock (ITC)","16594d","1fa829")
    end
    
    if setupParts[1] == "World War Hulk" then
        log("Moving extra masterminds outside game.")
        tyrants = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tyrants, s)
        end
        tyrantzones = {
            "1fa829",
            "bf7e87",
            "4c1868"}
        tacticsKill = function(obj)
            for i=1,3 do
                if tyrants[i] == obj.getName() then
                    zonetokill = getObjectFromGUID(tyrantzones[i])
                    for j,o in pairs(zonetokill.getObjects()) do
                        if o.name == "Deck" then
                            decktokill = zonetokill.getObjects()[j]
                        end
                    end
                end
            end
            decktokill.randomize()
            decktokill.takeObject({index=0}).destruct()
            decktokill.takeObject({index=0}).destruct()
        end
        tyrantShuffleHulk = function(obj)
            if obj.getQuantity() == 4 then
                obj.randomize()
                obj.takeObject.destruct()
                obj.takeObject.destruct()
            end
            if obj.getQuantity() == 5 then
                posabove = obj.getPosition()
                posabove.y = posabove.y +2
                obj.takeObject({position=posabove,
                    smooth=true,
                    index=4,
                    callback_function = tacticsKill})
            end
        end
        for i=1,3 do
            findInPile(tyrants[i],"c7e1d5",tyrantzones[i],tyrantShuffleHulk)
        end
    end
    return nil
end