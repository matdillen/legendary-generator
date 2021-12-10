function onLoad()
    self.createButton({
        click_function="click_update_tactics", function_owner=self,
        position={0,0,1}, rotation={0,180,0}, height=250, color={0,0,0,0.75},
        label = "(4)",font_color = {1,0.1,0,1}, tooltip="Remaining tactics. Click to force update."
    })
    setupGUID = "912967"
    
    local guids3 = {
        "playerBoards",
        "vpileguids",
        "playguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "allTopBoardGUIDS",
       "topBoardGUIDs",
       "city_zones_guids",
       "hqguids",
       "pos_vp2",
       "pos_discard"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = callGUID(o,2)
    end
    
    local guids1 = {
       "bystandersPileGUID",
       "kopile_guid",
       "escape_zone_guid",
       "officerDeckGUID",
       "strikeZoneGUID",
       "pushvillainsguid",
       "heroDeckZoneGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = callGUID(o,1)
    end
    
    mmZoneGUID = self.guid
    
    addMMGUIDS = {}
    
    for _,o in pairs(allTopBoardGUIDS) do
        addMMGUIDS[o] = false
    end
    
    masterminds = {}
    transformed = {}
    mmLocations = {}
end

function returnVar(var)
    return _G[var]
end

function returnColor()
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

function click_update_tactics()
    local mmdeck = getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone',self.guid)
    if mmdeck[1] and mmdeck[2] then
        for _,o in pairs(mmdeck) do
            if o.is_face_down and (not o.hasTag("Mastermind") or hasTag2(o,"Tactic:")) then
                local c = math.abs(o.getQuantity())
                self.editButton({index=0,label="(" .. c .. ")"})
                return nil
            end
        end
    elseif mmdeck[1] then
        self.editButton({index=0,label="(" .. math.abs(mmdeck[1].getQuantity())-1 .. ")"})
    else
        self.editButton({index=0,label="(" .. 0 .. ")"})
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

function updateHQ(guid)
    hqguids = table.clone(getObjectFromGUID(guid).Call('returnVar',"hqguids"))
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

function updateMasterminds(mmname)
    table.insert(masterminds,mmname)
end

function removeMasterminds(index)
    table.remove(masterminds,index)
end

function updateMastermindsLocation(mmname,location)
    if mmname[1] then
        location = mmname[2]
        mmname = mmname[1]
    end
    if not mmLocations then
        mmLocations = {[mmname] = location}
    else
        mmLocations[mmname] = location
    end
    if addMMGUIDS[location] then
        addMMGUIDS[location] = true
    end
end

function removeMastermindsLocation(mmname)
    local iter = 1
    for i,o in ipairs(mmLocations) do
        if i == mmname then
            table.remove(mmLocations,iter)
            if addMMGUIDS[o] then
                addMMGUIDS[o] = false
            end
            break
        end
        iter = iter + 1
    end
end

function lockTopZone(guid)
    addMMGUIDS[guid] = true
end

function mmActive(mmname)
    for _,o in pairs(masterminds) do
        if o == mmname or o == mmname .. " - epic" then
            return true
        end
    end
    return false
end

function mmGetCards(mmname,transf)
    if transf and (mmname == "General Ross" or mmname == "Illuminati, Secret Society" or mmname == "King Hulk, Sakaarson" or mmname == "M.O.D.O.K." or mmname == "The Red King" or mmname == "The Sentry") then
        return true
    elseif transf then
        return false
    else
        mmcardnumber = 5
        if mmname == "Hydra High Council" or mmname == "Hydra Super-Adaptoid" then
            mmcardnumber = 4
        end
        return(mmcardnumber)
    end
end

function isTransformed(mmname)
    return mmGetCards(mmname,true)
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
        mmButtons({mmname,wounds,"+" .. wounds,"Wounded fury.","mm","woundedfury"})
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

function transformMM(obj)
    local content = get_decks_and_cards_from_zone(obj.guid,true)
    for i,o in pairs(content) do
        if o.getName() == "Shard" then
            bump(o)
            table.remove(content,i)
        end
    end
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
        if not bsPile then
            bystandersPileGUID = callGUID("bystandersPileGUID",1)
            bsPile = getObjectFromGUID(bystandersPileGUID)
        end
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
            local mmZone = getObjectFromGUID(mmLocations[mmname])
            for i,o in pairs(mmZone.getButtons()) do
                if o.click_function == "updateMMMODOK" then
                    buttonindex = i-1
                    break
                end
            end
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

function setupMasterminds(objname,epicness,lurking)
    if objname[1] then
        epicness = objname[2]
        lurking = objname[3]
        objname = objname[1]
    end
    if not lurking then
        fightButton(mmLocations[objname])
    end
    if mmGetCards(objname,true) == true then
        setupTransformingMM(objname,getObjectFromGUID(mmLocations[objname]),lurking)
    end
    if objname == "Apocalypse" then
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                local content = get_decks_and_cards_from_zone(o)
                if content[1] then
                    for _,obj in pairs(content) do
                        if obj.hasTag("Group:Four Horsemen") then
                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj,"+2","Bonus of Apocalypse","apocalypse"})
                            break
                        end
                    end
                end
            end
        end
    end
    if objname == "Annihilus" or objname == "Annihilus - epic" then
        annihilusmomentumcounter = 0
        annihilusmomentumboost = 2
        annihilusmomentumvillains = {}
        if epicness then
            annihilusmomentumboost = 4
        end
        updateMMAnnihilus = function()
            if not mmActive(objname) then
                return nil
            end
            mmButtons(objname,
                annihilusmomentumcounter,
                "+" .. annihilusmomentumcounter,
                "Annihilus has Mass Momentum and gets +" .. annihilusmomentumboost .. " for each villain that entered a new city space this turn.",
                'updateMMAnnihilus')
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Villain") then
                for _,o in pairs(annihilusmomentumvillains) do
                    if o == object.guid then
                        return nil
                    end
                end
                for i,o in ipairs(city_zones_guids) do
                    if i > 1 and zone.guid == o then
                        table.insert(annihilusmomentumvillains,object.guid)
                        annihilusmomentumcounter = annihilusmomentumcounter + annihilusmomentumboost
                    end
                end
                updateMMAnnihilus()
            end
        end
        function onPlayerTurn(player,previous_player)
            annihilusmomentumcounter = 0
            annihilusmomentumvillains = {}
            updateMMAnnihilus()
        end
    end
    if objname == "Arcade" or objname == "Arcade - epic" then
        local arc = 5
        if epicness == true then
            arc = 8
            getObjectFromGUID(setupGUID).Call('playHorror')
        end
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        if not bsPile then
            bystandersPileGUID = callGUID("bystandersPileGUID",1)
            bsPile = getObjectFromGUID(bystandersPileGUID)
        end
        for i=1,arc do
            bsPile.takeObject({position=getObjectFromGUID(mmLocations[objname]).getPosition(),
                flip=false,
                smooth=false})
        end
    end
    if objname == "Arnim Zola" then
        updateMMArnimZola = function()
            local power = 0
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    for _,k in pairs(hero.getTags()) do
                        if k:find("Attack:") then
                            power = power + tonumber(k:match("%d+"))
                        end
                    end
                end
            end
            Wait.time(function() mmButtons(objname,
                power,
                "+" .. power,
                "Arnim Zola gets extra Attack equal to the total printed Attack of all heroes in the HQ.",
                'updateMMArnimZola') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMArnimZola,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMArnimZola,1)
        end
    end
    if objname == "Baron Heinrich Zemo" then
        updateMMBaronHein = function()
            if not mmActive(objname) then
                return nil
            end
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
                math.max(2-savior,0),
                "+9",
                "The Baron gets +9 as long as you're not a Savior of at least 3 bystanders.",
                'updateMMBaronHein') end,1)
        end
        updateMMBaronHein()
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
    if objname == "Emperor Vulcan of the Shi'ar" or objname == "Emperor Vulcan of the Shi'ar  - epic" then
        updateMMEmperorVulcan = function()
            if not mmActive(objname) then
                return nil
            end
            local thronesfavor = callGUID("thronesfavor",1)
            local power = 0
            if thronesfavor == "mmEmperor Vulcan of the Shi'ar" then
                power = 3
                if epicness then
                    power = 5
                end
            end
            mmButtons(objname,
                power,
                "+" .. power,
                "Emperor Vulcan gets +" .. power .. " if he has the Throne's Favor.",
                'updateMMEmperorVulcan')
        end
        if epicness then
            getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmEmperor Vulcan of the Shi'ar"})
            updateMMEmperorVulcan()
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
    if objname == "Hydra High Council" then
        updateMMHydraHigh = function()
            if not mmActive(objname) then
                return nil
            end
            local mm = get_decks_and_cards_from_zone(mmLocations[objname])
            local name = nil
            if mm[1] and mm[1].tag == "Deck" then
                name = mm[1].getObjects()[mm[1].getQuantity()].name
            elseif mm[1] then
                name = mm[1].getName()
            end
            if not name then
                return nil
            end
            if name == "Baron Helmut Zemo" then
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
                    'updateMMHydraHigh') end,1)
            elseif name == "Viper" then
                local shiarfound = 0
                for i=2,#city_zones_guids do
                    local citycontent = get_decks_and_cards_from_zone(city_zones_guids[i])
                    if citycontent[1] then
                        for _,o in pairs(citycontent) do
                            if o.getName():upper():find("HYDRA") or (hasTag2(o,"Group:") and hasTag2(o,"Group:"):upper():find("HYDRA")) then
                                shiarfound = shiarfound + 1
                                break
                            end
                        end
                    end
                end
                Wait.time(function() mmButtons(objname,
                    shiarfound,
                    "+" .. shiarfound,
                    "Viper gets +1 for each HYDRA Villain in the city.",
                    'updateMMHydraHigh') end,1)
            elseif name == "Red Skull" then
                local shiarfound = 0
                local escapezonecontent = get_decks_and_cards_from_zone(escape_zone_guid)
                if escapezonecontent[1] and escapezonecontent[1].tag == "Deck" then
                    for _,o in pairs(escapezonecontent[1].getObjects()) do
                        if o.name:upper():find("HYDRA") then
                            shiarfound = shiarfound + 1
                        elseif next(o.tags) then
                            for _,tag in pairs(o.tags) do
                                if tag:upper():find("HYDRA") or tag == "Starter" or tag == "Officer" then
                                    shiarfound = shiarfound + 1
                                    break
                                end
                            end
                        end
                    end
                elseif escapezonecontent[1] then
                    if escapezonecontent[1].getName():upper():find("HYDRA") or 
                        (hasTag2(escapezonecontent[1],"Group:") and hasTag2(escapezonecontent[1],"Group:"):upper():find("HYDRA")) or 
                        escapezonecontent[1].hasTag("Starter") or 
                        escapezonecontent[1].hasTag("Officer") then
                        shiarfound = shiarfound + 1
                    end
                end
                shiarfound = shiarfound/2 - 0.5*(shiarfound % 2)
                Wait.time(function() mmButtons(objname,
                    shiarfound,
                    "+" .. shiarfound,
                    "Red Skull gets +1 for each two HYDRA levels.",
                    'updateMMHydraHigh') end,1)
            elseif name == "Arnim Zola" then
                local power = 0
                for _,o in pairs(hqguids) do
                    local hero = getObjectFromGUID(o).Call('getHeroUp')
                    if hero then
                        for _,k in pairs(hero.getTags()) do
                            if k:find("Attack:") then
                                power = power + tonumber(k:match("%d+"))
                            end
                        end
                    end
                end
                Wait.time(function() mmButtons(objname,
                    power,
                    "+" .. power,
                    "Arnim Zola gets extra Attack equal to the total printed Attack of all heroes in the HQ.",
                    'updateMMHydraHigh') end,1)
            end
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMHydraHigh,2)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMHydraHigh,2)
        end
        function onPlayerTurn(player,previous_player)
            updateMMHydraHigh()
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
    if objname == "Kang the Conqueror" or objname == "Kang the Conqueror - epic" then
        updateMMKang = function()
            if not mmActive(objname) then
                return nil
            end
            local kangcitycheck = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnTimeIncursions'))
            local villaincount = 0
            for _,o in pairs(kangcitycheck) do
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
                "+" .. villaincount*(2+boost),
                "Kang gets +" .. 2+boost .. " for each Villain in the city zones under a time incursion.",
                'updateMMKang') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMKang,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMKang,1)
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
        local boost = "+1"
        if epicness then
            boost = "+2"
        end
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                local content = get_decks_and_cards_from_zone(o)
                if content[1] then
                    for _,obj in pairs(content) do
                        if obj.hasTag("Group:Mandarin's Rings") then
                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj,boost,"Bonus of the Mandarin","mandarin"})
                            break
                        end
                    end
                end
            end
        end
        updateMMMandarin = function()
            if not mmActive(objname) then
                return nil
            end
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
    if objname == "Maximus the Mad" or objname == "Maximus the Mad - epic" then
        updateMMMaximus = function()
            if not mmActive(objname) then
                return nil
            end
            local power = 0
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    for _,k in pairs(hero.getTags()) do
                        if k:find("Attack:") then
                            power = math.max(power,tonumber(k:match("%d+")))
                        end
                    end
                end
            end
            local boost = ""
            if epicness then
                power = power*2
                boost = " twice "
            end
            Wait.time(function() mmButtons(objname,
                power,
                "+" .. power,
                "Maximus gets extra Attack equal to" .. boost .. "the highest printed Attack of all heroes in the HQ.",
                'updateMMMaximus') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMaximus,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMaximus,1)
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
            getObjectFromGUID(setupGUID).Call('playHorror')
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
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
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
    if objname == "Odin" then
        updateMMOdin = function()
            if not mmActive(objname) then
                return nil
            end
            local shiarfound = 0
            for i=2,#city_zones_guids do
                local citycontent = get_decks_and_cards_from_zone(city_zones_guids[i])
                if citycontent[1] then
                    for _,o in pairs(citycontent) do
                        if o.getName():find("Asgardian Warriors") then
                            shiarfound = shiarfound + 1
                            break
                        end
                    end
                end
            end
            local escapezonecontent = get_decks_and_cards_from_zone(escape_zone_guid)
            if escapezonecontent[1] and escapezonecontent[1].tag == "Deck" then
                for _,o in pairs(escapezonecontent[1].getObjects()) do
                    if o.name == "Asgardian Warriors" then
                        shiarfound = shiarfound + 1
                    end
                end
            elseif escapezonecontent[1] then
                if escapezonecontent[1].getName() == "Asgardian Warriors" then
                    shiarfound = shiarfound + 1
                end
            end
            Wait.time(function() mmButtons(objname,
                shiarfound,
                "+" .. shiarfound,
                "Odin gets +1 for each Asgardian Warrior in the city and Escape Pile.",
                'updateMMOdin') end,1)
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMOdin,1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMOdin,1)
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
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
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
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
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
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
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
            getObjectFromGUID(setupGUID).Call('playHorror')
            getObjectFromGUID(setupGUID).Call('playHorror')
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
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
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
        if not bsPile then
            bystandersPileGUID = callGUID("bystandersPileGUID",1)
            bsPile = getObjectFromGUID(bystandersPileGUID)
        end
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
                for i,o in pairs(allTopBoardGUIDS) do
                    if o == mmLocations[objname] then
                        strikeloc = allTopBoardGUIDS[i-1]
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

function updatePower()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function mmButtons(objname,checkvalue,label,tooltip,f,id)
    if objname[1] then
        checkvalue = objname[2]
        label = objname[3]
        tooltip = objname[4]
        f = objname[5]
        id = objname[6]
        objname = objname[1]
    end
    local mmzone = getObjectFromGUID(mmLocations[objname])
    if not mmzone then
        return nil
    end
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
    if obj.locked == nil and obj[1] then
        index = obj[2]
        label = obj[3]
        id = obj[4]
        tooltip = obj[5]
        obj = obj[1]
    end
    --log(obj)
    --log(index)
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
        Wait.time(click_update_tactics,1)
        --log("name:")
        --log(name)
        if name then
            local killFightButton = function()
                local content = get_decks_and_cards_from_zone(obj.guid,false,false)
                local finalblow = callGUID("finalblow",1)
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
                    elseif name == "Mandarin" then
                        for i,o in pairs(city_zones_guids) do
                            if i ~= 1 then
                                local content = get_decks_and_cards_from_zone(o)
                                if content[1] then
                                    for _,c in pairs(content) do
                                        if c.hasTag("Group:Mandarin's Rings") then
                                            getObjectFromGUID(pushvillainsguid).Call('killBonus',{c,"mandarin"})
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    elseif name == "Apocalypse" then
                        for i,o in pairs(city_zones_guids) do
                            if i ~= 1 then
                                local content = get_decks_and_cards_from_zone(o)
                                if content[1] then
                                    for _,c in pairs(content) do
                                        if c.hasTag("Group:Four Horsemen") then
                                            getObjectFromGUID(pushvillainsguid).Call('killBonus',{c,"apocalypse"})
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if callGUID("setupParts",2)[1] == "World War Hulk" then
                        getObjectFromGUID(pushvillainsguid).Call('addNewLurkingMM') 
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

function bump(obj,y)
    if not y then
        y = 2
    end
    local pos = obj.getPosition()
    pos.y = pos.y + y
    obj.setPositionSmooth(pos)
end

function koCard(obj,smooth)
    if smooth then
        obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
    else
        obj.setPosition(getObjectFromGUID(kopile_guid).getPosition())
    end
end

function fightMM(zoneguid,player_clicker_color)
    local content = get_decks_and_cards_from_zone(zoneguid,true,false)
    for i,o in pairs(content) do
        if o.getName() == "Shard" then
            bump(o)
            table.remove(content,i)
        end
    end
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
                    flip = o.is_face_down,
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

function getNextMMLoc()
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

function resolveTactics(mmname,tacticname,color)
    if mmname[1] then
        tacticname = mmname[2]
        color = mmname[3]
        mmname = mmname[1]
    end
    if mmname == "Maximus the Mad" then
        if tacticname == "Seize the inhuman throne" then
            local thronesfavor = callGUID("thronesfavor",1)
            local val = 4
            if thronesfavor == "mmMaximus the Mad" then
                getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","none"})
                val = 3
            else
                getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmMaximus the Mad"})
            end
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                log(o.color)
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{o.color,hand,#hand-val})
            end
        elseif tacticname == "Terrigen bomb" then
            bump(get_decks_and_cards_from_zone(heroDeckZoneGUID)[1])
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero and (not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < 2) then
                    hero.setPosition(getObjectFromGUID(heroDeckZoneGUID).getPosition())
                    getObjectFromGUID(o).Call('click_draw_hero')
                end
            end
            local thronesfavor = callGUID("thronesfavor",1)
            if thronesfavor == "mmMaximus the Mad" then
                getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","none"})
                for _,o in pairs(Player.getPlayers()) do
                    local hand = o.getHandObjects()
                    local handi = table.clone(hand)
                    local iter = 0
                    for i,obj in ipairs(handi) do
                        if not hasTag2(obj,"Attack:") or not hasTag2(obj,"HC:") then
                            table.remove(hand,i-iter)
                            iter = iter + 1
                        end
                    end
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{o.color,hand,1,getObjectFromGUID(kopile_guid).getPosition(),nil,"KO","KO this card"})
                end
            else
                getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmMaximus the Mad"})
            end
        elseif tacticname == "Echo-tech chorus sentries" then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local handi = table.clone(hand)
                local iter = 0
                for i,obj in ipairs(handi) do
                    if (not hasTag2(obj,"HC:") or hasTag2(obj,"HC:") ~= "Silver") and (not hasTag2(obj,"Team:") or hasTag2(obj,"Team:") ~= "Inhumans") then
                        table.remove(hand,i-iter)
                        iter = iter + 1
                    end
                end
                if #hand == 0 then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                else
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{o.color,hand,1,getObjectFromGUID(kopile_guid).getPosition(),nil,"KO","KO this card"})
                end
            end
        elseif tacticname == "Sieve of secrets" then
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
        else
            printToAll("Unknown tactic found? (" .. tacticname[1] .. ").")
        end
        return nil
    end
end