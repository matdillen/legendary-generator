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
    
    for i=1,#Player.getPlayers() do
        playerdeck = getObjectFromGUID(playerdeckIDs[i])
        if playerdeck then playerdeck.randomize() end
		log("Shuffling " .. Player.getPlayers()[i].color .. " Player's deck!")
    end

end

function reduceStack(count,stackGUID)

    local stack = getObjectFromGUID(stackGUID)
    local outOfGameZoneGUID = "9afacf"
    local outOfGameZone = getObjectFromGUID(outOfGameZoneGUID)
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

function findInPile(deckName,pileGUID,destGUID)
    --log("Find " .. deckName .." in pile...")
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
            smooth=false,flip=true})
            return deck
        end
    end
    return nil
end

function mmGetCards(mmname)
	mmcardnumber = 5
	-- fix mastermind number of cards
	-- adapting mm
	if mmname == "Hydra High Council" or mmname == "Hydra Super-Adaptoid" then
			mmcardnumber = 4
	end
		
	-- mm for which the epic/trans version is a separate card
	-- should all be fixed now!
	falseepicmm = {
		-- "Poison Thanos",
		-- "J. Jonah Jameson",
		-- "Ultron",
		-- "The Red King",
		-- "The Sentry",
		-- "Hybrid",
		-- "Illuminati, Secret Society",
		-- "Morgan Le Fay",
		-- "General Ross",
		-- "M.O.D.O.K.",
		-- "King Hulk, Sakaarson"
		}
	for i,o in pairs(falseepicmm) do
		if mmname == o then
			mmcardnumber = 6
		end
	end
	return(mmcardnumber)
end

function import_setup()
    log("Generating imported setup...")
	playercount = #Player.getPlayers()
    local vildeck_done = {}
    setupParts = {}
    for s in string.gmatch(setupText,"[^\n]+") do
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
    for index,object in pairs(mmPile.getObjects()) do
        if string.lower(object.name) == string.lower(mmname) then
            log ("Found mastermind: " .. setupParts[5])
            mmGUID = object.guid
            mmPush = mmPile.takeObject({guid=mmGUID,
            position=mmZone.getPosition(),
            smooth=false,flip=true})
        end
    end
	
    mmGenerated = function()
            mm = mmZone.getObjects()[2]
            if mm ~= nil then
                if mm.getQuantity() == mmcardnumber then
                    return true
                else
                    return false
                end
            else
                return false
            end
    end
	
	mmshuffle = function()
		mm = mmZone.getObjects()[2]
		if mmcardnumber == 4 then
			mm.randomize()
			log("Mastermind tactics shuffled")
		end
		if mmcardnumber == 5 then
			mm.takeObject({
				position={x=mm.getPosition().x,y=mm.getPosition().y+2,z=mm.getPosition().z}
				})
			local mmtopcardMoved = function()
				if mm ~= nil then
					if mm.getQuantity() == mmcardnumber-1 then
						return true
					else
						return false
					end
				else
					return false
				end
            end
			local mmSepShuffle = function()
				mm.randomize()
				log("Mastermind tactics shuffled")
			end
			Wait.condition(mmSepShuffle,mmtopcardMoved)
		end
		-- following should be obsolete now
		if mmcardnumber == 6 then
			mm.takeObject({
				position={x=mm.getPosition().x,y=mm.getPosition().y+2,z=mm.getPosition().z}
				})
			mm.takeObject({
				position={x=mm.getPosition().x,y=mm.getPosition().y+2,z=mm.getPosition().z}
			})
			local mmtopcardMoved = function()
				if mm ~= nil then
					if mm.getQuantity() == mmcardnumber-2 then
						return true
					else
						return false
					end
				else
					return false
				end
			end
			local mmSepShuffle = function()
				mm.randomize()
				log("Mastermind tactics shuffled")
			end
			Wait.condition(mmSepShuffle,mmtopcardMoved)
		end
	end
	
	Wait.condition(mmshuffle,mmGenerated)
	
	
    if epicness then
        local mmFlip = function()
			mm = mmZone.getObjects()[2]
			log("Double-faced epic mastermind flipped!")
			mm.takeObject().flip()
        end
        Wait.condition(mmFlip,mmGenerated)
    end
	
	if mmname == "J. Jonah Jameson" then
		sopile = getObjectFromGUID("9c9649")
		sopile.randomize()
		strikepile = getObjectFromGUID("be6070")
		if epicness then
			for i=1,3*playercount do
				sopile.takeObject({position = strikepile.getPosition(),
					flip=false,smooth=false})
			end
			log("Six random SHIELD officers moved to master strike zone.")
		else 
			for i=1,2*playercount do
				sopile.takeObject({position = strikepile.getPosition(),
					flip=false,smooth=false})
			end
			log("Four random SHIELD officers moved to master strike zone.")
		end
	end
	
    -- Master Strike
    
    log("Master strikes: 5")
    local msPile = getObjectFromGUID("aff2e5")
    vilDeckZone=getObjectFromGUID("4bc134")
    table.insert(vildeck_done,5)
    for i=1,5 do
        msPile.takeObject({position=vilDeckZone.getPosition(),
            flip=false,smooth=false})
    end
	log("5 Master strikes added to villain deck.")
    
    -- Bystanders
    
    bsPile = getObjectFromGUID("0b48dd")
    bsPile.randomize()
    bs = tonumber(setupParts[3])
    log("Bystanders: " .. bs)
    table.insert(vildeck_done,bs)
    for i=1,bs do
        bsPile.takeObject({position=vilDeckZone.getPosition(),
            flip=true,smooth=false})
		log(bs .. " bystanders added to villain deck.")
    end
	
	horrorpile = getObjectFromGUID("b119a8")
	horrorspot = getObjectFromGUID("ef2805")
	
	if mmname == "Arcade" then
		if epicness then
			for i=1,8 do
				bsPile.takeObject({position=strikepile.getPosition(),
					flip=false,smooth=false})
			end
			log("Eight Human Shields moved to master strike zone.")
			horrorpile.randomize()
			horrorpile.takeObject({position=horrorspot.getPosition(),
					flip=false,smooth=false})	
			log("Random horror added to the game (New Recruits zone)")
			
		else
			for i=1,5 do
				bsPile.takeObject({position=strikepile.getPosition(),
					flip=false,smooth=false})
			end
			log("Five Human Shields moved to master strike zone.")
		end
	end
	
	if mmname == "General Ross" then
		for i=1,8 do
			bsPile.takeObject({position=strikepile.getPosition(),
				flip=false,smooth=false})
		end
		log("Eight Helicopter bystanders moved to master strike zone.")
	end
	
	if mmname == "Mojo" then
		strikepile = getObjectFromGUID("be6070")
		if epicness then
			for i=1,6 do
				bsPile.takeObject({position=strikepile.getPosition(),
					flip=false,smooth=false})
			end
			log("Six Human Shields moved to master strike zone.")
			horrorpile.randomize()
			horrorpile.takeObject({position=horrorspot.getPosition(),
					flip=false,smooth=false})	
			log("Random horror added to the game (New Recruits zone)")
			broadcastToAll("Mojo! Bystanders net 4 victory points each!")
		else
			for i=1,3 do
				bsPile.takeObject({position=strikepile.getPosition(),
					flip=false,smooth=false})
			end
			log("Three Human Shields moved to master strike zone.")
			broadcastToAll("Mojo! Bystanders net 3 victory points each!")
		end
	end
	
	if mmname == "The Sentry" then
		woundstack = getObjectFromGUID("653663")
		for i=1,5 do
			playerdeck = getObjectFromGUID(playerdeckIDs[i])
			woundstack.takeObject({position = playerdeck.getPosition()})
			woundstack.takeObject({position = playerdeck.getPosition()})
		end
		log("Wounds added to player starter decks. Still shuffle!")
		broadcastToAll("2 wounds in starter deck because of The Sentry. Bastard.")
	end
	
	if mmname == "Onslaught" then
		broadcastToAll("Please use the button to set your hand size -1!")
		--broadcastToAll("Also good luck!")
	end
	
	if mmname == "Shadow King" then
		if epicness then
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
				flip=false,smooth=false})	
		end
		log(st .. " scheme twists added to villain deck.")
		schemeSpecials(setupParts,mmGUID)
	end
    
	if setupParts[1] == "The Demon Bear Saga" then
		log("Taking the demon bear out.")
		setupParts[6] = setupParts[6]:gsub("Demons of Limbo|","")
        findInPile("Demons of Limbo","375566","1fa829")
		avpile = getObjectFromGUID("1fa829")
		local teamReady = function()
			thorstack = avpile.getObjects()[1]
			if thorstack ~= nil then
				if thorstack.getQuantity() == 8 then
					return true
				else	
					return false
				end
			else
				return false
			end
		end
		local onlyThor = function()
			thorstack = avpile.getObjects()[1]
			for i,o in pairs(thorstack.getObjects()) do
				if o.name == "Demon Bear" then
					thorstack.takeObject({position=twistpile.getPosition(),
						flip=false,smooth=false,index=i-1})
					thorstack.setPositionSmooth(vilDeckZone.getPosition())
					break
				end
			end
			log("Demon Bear moved to twists pile. Other demons to villain deck.")
		end
		Wait.condition(onlyThor,teamReady)
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
                smooth=false,flip=true})
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
                smooth=false,flip=true})
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
    
    if setupParts[1] == "Secret Invasion of the Skrull Shapeshifters" then
        local skrullShuffle = function() 
            log("Shuffle 12 hero cards in villain deck.")
			print("12 random hero cards shuffled into villain deck.")
            heroDeck = heroZone.getObjects()[2]
            heroDeck.randomize()
            for i=1,12 do
                heroDeck.takeObject({position=vilDeck.getPosition(),
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
    local outOfGameZoneGUID = "9afacf"
    local outOfGameZone = getObjectFromGUID(outOfGameZoneGUID)
	
	
    if setupParts[1] == "Brainwash the Military" then
        log("12 officers in villain deck.")
        for i=1,12 do
            sopile.takeObject({position=vilDeckZone.getPosition(),
                flip=true,smooth=false})
        end
    end
    if setupParts[1] == "Build an Army of Annihilation" then
        log("Add extra annihilation group.")
		local target = twistpile.getObjects()[2]
        findInPile(setupParts[9],"de8160","4f53f9")
        print("Annihilation group " .. setupParts[9] .. " moved to twists pile.")
    end
    if setupParts[1] == "Cage Villains in Power-Suppressing Cells" then
        log("Add extra cops henchmen.")
        findInPile("Cops","de8160","4f53f9")
        print("Cops moved to twists pile. Remove some to keep only 2 per player.")
    end
    if setupParts[1] == "Capture Baby Hope" then
        log("Baby hope token moved to scheme.")
        local babyHope = getObjectFromGUID("e27f77")
        babyHope.setPositionSmooth(schemZone.getPosition())
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
        findInPile("Avengers","375566","1fa829")
		avpile = getObjectFromGUID("1fa829")
		local teamReady = function()
			thorstack = avpile.getObjects()[1]
			if thorstack ~= nil then
				if thorstack.getQuantity() == 8 then
					return true
				else	
					return false
				end
			else
				return false
			end
		end
		local onlyThor = function()
			thorstack = avpile.getObjects()[1]
			for i,o in pairs(thorstack.getObjects()) do
				if o.name == "Thor" then
					thorstack.takeObject({position=twistpile.getPosition(),
						flip=false,smooth=false,index=i-1})
					thorstack.destruct()
					break
				end
			end
			print("Thor moved to twists pile.")
		end
		Wait.condition(onlyThor,teamReady)
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
		findInPile(setupParts[9],"16594d","1fa829")
		local novaFound = function()
			local novaloc = getObjectFromGUID("1fa829").getObjects()[1]
            if novaloc ~= nil then
                if novaloc.getQuantity() == 14 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
		local novaDist = function()
			local novaloc = getObjectFromGUID("1fa829").getObjects()[1]
			log("Moving additional cards to starter decks.")
			for i=1,playercount do
				local color = Player.getPlayers()[i].color
				for j=1,#playercolors do
					if playercolors[j] == color then
						deckid = playerdeckIDs[j]
					end
				end
				playerdeck = getObjectFromGUID(deckid)
				wndPile.takeObject({position=playerdeck.getPosition(),
					flip=false,smooth=false})
				wndPile.takeObject({position=playerdeck.getPosition(),
					flip=false,smooth=false})	
				sopile.takeObject({position=playerdeck.getPosition(),
					flip=false,smooth=false})
				novaloc.takeObject({position=playerdeck.getPosition(),
					flip=false,smooth=false})
			end
		end
		Wait.condition(novaDist,novaFound)
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
        log("Set up the Washington Monument stacks...")
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
            if test ~= nil then 
                return true
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
    if setupParts[1] == "Hidden Heart of Darkness" then
        local mmGenerated = function()
            mm = mmZone.getObjects()[2]
            if mm ~= nil then
                if mm.getQuantity() == mmcardnumber then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        local shuffleTactics = function()
            mm = mmZone.getObjects()[2]
            for i=1,4 do
                log("Mastermind Tactics Into Villain Deck")
                mm.takeObject({position=vilDeckZone.getPosition(),
                    smooth=false,flip=false,index=0})
            end
        end
        Wait.condition(shuffleTactics,mmGenerated)
        print("Shuffle all tactics into the villain deck!")
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
        findInPile(setupParts[9],"de8160","4f53f9")
        local bugleInvadersFound = function()
            bugle = twistpile.getObjects()[2]
            if bugle ~= nil then
                if bugle.getQuantity() == 10 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        local bugleInvader = function()
            local buglezone = twistpile.getObjects()[2]
            for i=1,6 do
                buglezone.takeObject({position=heroZone.getPosition(),
                    flip=false,smooth=false})
            end
            for i=1,4 do
                buglezone.takeObject({position=outOfGameZone.getPosition(),
                    flip=false,smooth=false})
            end
        end
        Wait.condition(bugleInvader,bugleInvadersFound)
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
        local tyrantsGenerated = function()
            mm1 = getObjectFromGUID(tyrantzones[1])
            mm2 = getObjectFromGUID(tyrantzones[2])
            mm3 = getObjectFromGUID(tyrantzones[3])
            -- not sure why the nr of objects increases here...
            tyrantgen1 = mm1.getObjects()[1]
            tyrantgen2 = mm2.getObjects()[2]
            tyrantgen3 = mm3.getObjects()[3]
			tyrantsize1 = tyrantgen1.getQuantity()
			tyrantsize2 = tyrantgen2.getQuantity()
			tyrantsize3 = tyrantgen3.getQuantity()
            if tyrantgen1 ~= nil and tyrantgen2 ~= nil and tyrantgen3 ~= nil then
                if tyrantsize1 == tyrantsnumber[1] and tyrantsize2 == tyrantsnumber[2] and tyrantsize3 == tyrantsnumber[3] then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end
        local shuffleTyrantTactics = function()
			for j=1,3 do
                local zoneid = getObjectFromGUID(tyrantzones[j])
                local tyrantshuf = zoneid.getObjects()[j]
                for i=1,4 do
                    log("Mastermind Tactics Into Villain Deck")
                    tyrantshuf.takeObject({position=vilDeckZone.getPosition(),
                        smooth=false,flip=false,index=0})
                end
            end
        end
        for i=1,3 do
            findInPile(tyrants[i],"c7e1d5",tyrantzones[i])
        end
        Wait.condition(shuffleTyrantTactics,tyrantsGenerated)
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
		tyrgent = false
		tactmov = false
        tyrants = {}
        for s in string.gmatch(setupParts[9],"[^|]+") do
            table.insert(tyrants, s)
        end
        tyrantzones = {
            "1fa829",
            "bf7e87",
            "4c1868"}
        tyranttempzones = {
            "8656c3",
            "533311",
            "3d3ba7"}
		tyrantsnumber = {}
		for i=1,3 do
			tyrantsnumber[i] = mmGetCards(tyrants[i])
		end
		lims = {}
				for i=1,3 do
					lims[i] = tyrantsnumber[i] - 4
				end
		lims[4] = mmcardnumber - 4
		local tacticsFiltered = function()
			if tyrgent == true and tactmov == true then
				mm1 = getObjectFromGUID(tyranttempzones[1])
				mm2 = getObjectFromGUID(tyranttempzones[2])
				mm3 = getObjectFromGUID(tyranttempzones[3])
				-- not sure why the nr of objects increases here...
				tyrantgen1 = mm1.getObjects()[2]
				tyrantgen2 = mm2.getObjects()[2]
				tyrantgen3 = mm3.getObjects()[2]
				mm = twistpile.getObjects()[2]
				if tyrantgen1 ~= nil and tyrantgen2 ~= nil and tyrantgen3 ~= nil and mm ~= nil then
					tyrantquans = {
					math.abs(tyrantgen1.getQuantity()),
					math.abs(tyrantgen2.getQuantity()),
					math.abs(tyrantgen3.getQuantity()),
					math.abs(mm.getQuantity())
					}
					if tyrantquans[1] == lims[1] and tyrantquans[2] == lims[2] and tyrantquans[3] == lims[3] and tyrantquans[4] == lims[4] then
						return true
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
        end
        local tacticsPush = function()
            for j=1,3 do
                zoneid = getObjectFromGUID(tyrantzones[j])
                tempzone = getObjectFromGUID(tyranttempzones[j])
				tyrantshuf = tempzone.getObjects()[2]
				if tyrantsnumber[j] == 5 then
					tyrantshuf.setPositionSmooth(zoneid.getPosition())
				end
				if tyrantsnumber[j] == 6 then
					for i=1,2 do
						pos = zoneid.getPosition()
						pos.y = pos.y +2
						tyrantshuf.takeObject({position=pos,
							smooth=false,flip=false})
					end
				end
            end
            mm = twistpile.getObjects()[2]
			if mmcardnumber == 5 then
				mm.setPositionSmooth(mmZone.getPosition())
			end
			if mmcardnumber == 6 then
				for i=1,2 do
					pos = mmZone.getPosition()
					pos.y = pos.y +2
					mm.takeObject({position=pos,
						smooth=false,flip=false})
				end
			end
        end
		local tacticsMoved = function()
			if tyrgent == true then
				mm1 = getObjectFromGUID(tyrantzones[1])
				mm2 = getObjectFromGUID(tyrantzones[2])
				mm3 = getObjectFromGUID(tyrantzones[3])
				-- not sure why the nr of objects increases here...
				tyrantgen1 = mm1.getObjects()[1]
				tyrantgen2 = mm2.getObjects()[2]
				tyrantgen3 = mm3.getObjects()[3]
				mm = mmZone.getObjects()[2]
				if tyrantgen1 ~= nil and tyrantgen2 ~= nil and tyrantgen3 ~= nil and mm ~= nil then
					if tyrantgen1.getQuantity() == 4 and tyrantgen2.getQuantity() == 4 and tyrantgen3.getQuantity() == 4 and mm.getQuantity() == 4 then
						tactmov = true
						return true
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
        end
        local tacticsFilter = function()
			for j=1,3 do
                local zoneid = getObjectFromGUID(tyrantzones[j])
                local tyrantshuf = zoneid.getObjects()[j]
                tyrantshuf.randomize()
                for i=1,2 do
                    log("Remove two tactics")
                    tyrantshuf.takeObject({index=0}).destruct()
                end
            end
            mm = mmZone.getObjects()[2]
            mm.randomize()
            for i=1,2 do
                mm.takeObject({index=0}).destruct()
            end
        end
        local tyrantsGenerated = function()
            mm1 = getObjectFromGUID(tyrantzones[1])
            mm2 = getObjectFromGUID(tyrantzones[2])
            mm3 = getObjectFromGUID(tyrantzones[3])
            -- not sure why the nr of objects increases here...
            tyrantgen1 = mm1.getObjects()[1]
            tyrantgen2 = mm2.getObjects()[2]
            tyrantgen3 = mm3.getObjects()[3]
			mm = mmZone.getObjects()[2]
            if tyrantgen1 ~= nil and tyrantgen2 ~= nil and tyrantgen3 ~= nil and mm ~= nil then
                if tyrantgen1.getQuantity() == tyrantsnumber[1] and tyrantgen2.getQuantity() == tyrantsnumber[2] and tyrantgen3.getQuantity() == tyrantsnumber[3] and mm.getQuantity() == mmcardnumber then
					tyrgent = true
					return true
                else
                    return false
                end
            else
                return false
            end
        end
        local removeTyrantTactics = function()
            for j=1,3 do
                local zoneid = getObjectFromGUID(tyrantzones[j])
                local tyrantshuf = zoneid.getObjects()[j]
                local tempzone = getObjectFromGUID(tyranttempzones[j])
                log("Move tactics temporarily")
                tyrantshuf.takeObject({position=tempzone.getPosition(),
                    smooth=false,flip=false,top=true})
				if tyrantsnumber[j] > 5 then
					pos = tempzone.getPosition()
					pos.y = pos.y + 2
					tyrantshuf.takeObject({position=pos,
                    smooth=false,flip=false,top=true})
				end
            end
            mm = mmZone.getObjects()[2]
			log("Move main mastermind tactics temporarily")
            mm.takeObject({position=twistpile.getPosition(),
                smooth=false,flip=false,top=true})
			if mmcardnumber > 5 then
				pos = twistpile.getPosition()
				pos.y = pos.y + 2
				mm.takeObject({position=pos,
					smooth=false,flip=false,top=true})
            end
        end

        for i=1,3 do
            findInPile(tyrants[i],"c7e1d5",tyrantzones[i])
        end
        Wait.condition(removeTyrantTactics,tyrantsGenerated)
		Wait.condition(tacticsFilter,tacticsMoved)
		Wait.condition(tacticsPush,tacticsFiltered)
		print("Still select the right mastermind front if separate cards for epic/transform.")
		-- fixing this requires structuring all double-faced cards as actual double-faced cards
		-- this probably requires separate scans for the special backs, as e.g. done for Emma Frost's mastermind card
    end
    return nil
end