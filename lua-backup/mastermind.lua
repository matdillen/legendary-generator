function onLoad()
    setupGUID = "912967"
    
    local guids3 = {
        "playerBoards",
        "vpileguids",
        "playguids",
        "resourceguids",
        "attackguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "allTopBoardGUIDS",
       "topBoardGUIDs",
       "city_zones_guids",
       "hqguids",
       "hqscriptguids",
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
    return getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end

function click_update_tactics(obj)
    local mmdeck = getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone',obj.guid)
    local butt = obj.getButtons()
    local index = 0
    for i,o in pairs(butt) do
        if o.click_function == "click_update_tactics" then
            index = i-1
            break
        end
    end
    if mmdeck[1] and mmdeck[2] then
        for _,o in pairs(mmdeck) do
            if o.is_face_down and not o.hasTag("Bystander") and (hasTag2(o,"Tactic:") or o.tag == "Deck") then
                local c = math.abs(o.getQuantity())
                obj.editButton({index=index,label="(" .. c .. ")"})
                return nil
            end
        end
    elseif mmdeck[1] then
        if mmGetCards(mmdeck[1].getName()) == 4 or 
            (hasTag2(mmdeck[1],"Tactic:") and mmGetCards(hasTag2(mmdeck[1],"Tactic:")) == 4) or
            mmGetCards(mmdeck[1].getName(),nil,true) or
            (hasTag2(mmdeck[1],"Tactic:") and mmGetCards(hasTag2(mmdeck[1],"Tactic:"),nil,true)) then
            obj.editButton({index=index,label="(" .. math.abs(mmdeck[1].getQuantity()) .. ")"})
        else
            obj.editButton({index=index,label="(" .. math.abs(mmdeck[1].getQuantity())-1 .. ")"})
        end
    else
        obj.editButton({index=index,label="(" .. 0 .. ")"})
    end
end

function hasTag2(obj,tag,index)
    return getObjectFromGUID(setupGUID).Call('hasTag2',{obj = obj,tag = tag,index = index})
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

function mmGetCards(mmname,transf,movingmm)
    if movingmm and (mmname == "Authoritarian Iron Man" or mmname == "King Hyperion") then
        return true
    elseif movingmm then
        return false
    end
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

function woundedFury(color)
    local discardpile = getObjectFromGUID(playerBoards[color]).Call('returnDiscardPile')
    local wounds = 0
    local buttonindex = nil
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
    return wounds
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
        height=150})
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
                mmButtons({mmname = mmname,
                    checkvalue = 0,
                    label = 0,
                    tooltip = "Red Hulk no longer gets +1 for each Wound in your discard pile.",
                    f = 'updateMMRoss',
                    id = "woundedFury"})
                mmButtons({mmname = mmname,
                    checkvalue = checkvalue,
                    label = "X",
                    tooltip = "You can't fight General Ross while he has any Helicopters.",
                    f = 'updateMMRoss',
                    id = "fightRoss"})
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
                mmButtons({mmname = mmname,
                    checkvalue = 0,
                    label = "",
                    tooltip = "You can fight Red Hulk while he has any Helicopters.",
                    f = 'updateMMRoss',
                    id = "fightRoss"})
                local wounds = woundedFury(Turns.turn_color)
                mmButtons({mmname = mmname,
                    checkvalue = wounds,
                    label = "+" .. wounds,
                    tooltip = "Red Hulk gets +1 for each Wound in your discard pile.",
                    f = 'updateMMRoss',
                    id = "woundedFury"})
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
            local boost = 0
            local tooltip = "The Illuminati no longer get +4 unless you Outwit them."
            if transformed["Illuminati, Secret Society"] == false then
                local notes = getNotes()
                setNotes(notes:gsub("\r\n\r\nWhenever a card effect causes a player to draw any number of cards, that player must then also discard a card.",""))
                boost = 4
                tooltip = "The Illuminati get +4 unless you Outwit them."
                if getObjectFromGUID(pushvillainsguid).Call('outwitPlayer',{color = Turns.turn_color}) then
                    boost = 0
                end
            elseif transformed["Illuminati, Secret Society"] == true then
                local notes = getNotes()
                setNotes(notes .. "\r\n\r\nWhenever a card effect causes a player to draw any number of cards, that player must then also discard a card.")
            end
            mmButtons({mmname = mmname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = tooltip,
                f = 'updateMMIlluminatiSS'})
        end
        updateMMIlluminatiSS()
        function onObjectEnterZone(zone,object)
            if transformed["Illuminati, Secret Society"] == false then
                updateMMIlluminatiSS()
            end
        end
        function onObjectLeaveZone(zone,object)
            if transformed["Illuminati, Secret Society"] == false then
                updateMMIlluminatiSS()
            end
        end
    end
    if mmname == "King Hulk, Sakaarson" then
        function updateMMHulk()
            if not mmActive(mmname) then
                return nil
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
                mmButtons({mmname = mmname,
                    checkvalue = 0,
                    label = 0,
                    tooltip = "King Hulk no longer gets +1 for each Wound in your discard pile.",
                    f = 'updateMMHulk',
                    id = "woundedFury"})
                mmButtons({mmname = mmname,
                    checkvalue = warbound,
                    label = "+" .. warbound,
                    tooltip = "King Hulk gets +1 for each Warbound Villain in the city and in the Escape Pile.",
                    f = 'updateMMHulk'})
            elseif transformed["King Hulk, Sakaarson"] == true then
                mmButtons({mmname = mmname,
                    checkvalue = 0,
                    label = 0,
                    tooltip = "King Hulk no longer gets +1 for each Warbound Villain in the city and in the Escape Pile.",
                    f = 'updateMMHulk'})
                local wounds = woundedFury(Turns.turn_color)
                mmButtons({mmname = mmname,
                    checkvalue = wounds,
                    label = "+" .. wounds,
                    tooltip = "King Hulk gets +1 for each Wound in your discard pile.",
                    f = 'updateMMHulk',
                    id = "woundedFury"})
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
            if transformed["M.O.D.O.K."] == false then
                mmButtons({mmname = mmname,
                    checkvalue = 0,
                    label = "*",
                    tooltip = "You can fight M.O.D.O.K normally.",
                    f = 'updateMMMODOK'})
                local notes = getNotes()
                setNotes(notes .. "\r\n\r\n[b]Outwit[/b] requires 4 different costs instead of 3.")
            elseif transformed["M.O.D.O.K."] == true then   
                local notes = getNotes()
                setNotes(notes:gsub("\r\n\r\n%[b%]Outwit%[/b%] requires 4 different costs instead of 3.",""))
                mmButtons({mmname = mmname,
                    checkvalue = 1,
                    label = "*",
                    tooltip = "You can only fight M.O.D.O.K with Recruit, not Attack.",
                    f = 'updateMMMODOK'})
            end
        end
    end
    if mmname == "The Red King" then
        function updateMMRedKing()
            if not mmActive(mmname) then
                return nil
            end
            local villainfound = 0
            local tooltip = "You can fight the Red King normally even if there any Villains are in the city."
            if transformed["The Red King"] == false then
                tooltip = "You can't fight the Red King while any Villains are in the city."
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
            mmButtons({mmname = mmname,
                checkvalue = villainfound,
                label = "X",
                tooltip = tooltip,
                f = 'updateMMRedKing'})
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
            if transformed["The Sentry"] == true then
                local wounds = woundedFury(Turns.turn_color)
                mmButtons({mmname = mmname,
                    checkvalue = wounds,
                    label = "+" .. wounds,
                    tooltip = "The Sentry gets +1 for each Wound in your discard pile.",
                    f = 'updateMMSentry',
                    id = "woundedfury"})
            elseif transformed["The Sentry"] == false then
                mmButtons({mmname = mmname,
                    checkvalue = 0,
                    label = "",
                    tooltip = "The Sentry no longer gets +1 for each Wound in your discard pile.",
                    f = 'updateMMSentry',
                    id = "woundedfury"})
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

function setupMasterminds(objname,epicness,tactics,lurking)
    if objname[1] then
        epicness = objname[2]
        tactics = objname[3]
        lurking = objname[4]
        objname = objname[1]
    end
    if not tactics then
        tactics = 4
    end
    if tactics ~= 0 then
        getObjectFromGUID(mmLocations[objname]).createButton({
            click_function="click_update_tactics", function_owner=self,
            position={0,0,1}, rotation={0,180,0}, height=250, color={0,0,0,0.75},
            label = "(" .. tactics .. ")",font_color = {1,0.1,0,1}, tooltip="Remaining tactics. Click to force update."
        })
    end
    if not lurking then
        fightButton(mmLocations[objname])
    end
    local mmzone = get_decks_and_cards_from_zone(mmLocations[objname])
    local baselabel = 0
    for _,o in pairs(mmzone) do
        if o.tag == "Deck" then
            for _,p in pairs(o.getObjects()) do
                local mmfound = false
                local tacticfound = false
                baselabel = 0
                for _,t in pairs(p.tags) do
                    if t == "Mastermind" then
                        mmfound = true
                    end
                    if t:find("Tactic:") then
                        tacticfound = true
                    end
                    if t:find("Power:") then
                        baselabel = tonumber(t:match("%d+")) or ""
                    end
                end
                if mmfound and not tacticfound then
                    break
                end
            end
        else
            if o.hasTag("Mastermind") and not hasTag2(o,"Tactic:") then
                baselabel = hasTag2(o,"Power:") or ""
                break
            end
        end
    end
    mmButtons({mmname = objname,
        checkvalue = 1,
        label = baselabel,
        tooltip = "Base power as written on the card.",
        f = 'updatePower',
        id = 'card'})
    if mmGetCards(objname,true) == true then
        setupTransformingMM(objname,getObjectFromGUID(mmLocations[objname]),lurking)
        return nil
    end
    if objname == "Adrian Toomes" or objname == "Adrian Toomes - epic" then
        updateMMAdrian = function()
            if not mmActive(objname) then
                return nil
            end
            local strikes = getObjectFromGUID(pushvillainsguid).Call('returnVar','strikesresolved')
            local boost = strikes*2
            if epicness then
                boost = strikes*3
            end
            mmButtons({mmname = objname,
                checkvalue = strikes,
                label = "+" .. boost,
                tooltip = "Adrian Toomes is a double (or triple) striker and gets +" .. boost/strikes .. " for each Master Strike that has been played.",
                f = 'updateMMAdrian'})
        end
        updateMMAdrian()
        function onObjectEnterZone(zone,object)
            if object.getName() == "Masterstrike" then
                updateMMAdrian()
            end
        end
        return nil
    end
    if objname == "Apocalypse" then
        for i,o in pairs(city_zones_guids) do
            if i ~= 1 then
                local content = get_decks_and_cards_from_zone(o)
                if content[1] then
                    for _,obj in pairs(content) do
                        if obj.hasTag("Group:Four Horsemen") then
                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,label = "+2",tooltip = "Bonus of Apocalypse",id = "apocalypse"})
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
            mmButtons({mmname = objname,
                checkvalue = annihilusmomentumcounter,
                label = "+" .. annihilusmomentumcounter,
                tooltip = "Annihilus has Mass Momentum and gets +" .. annihilusmomentumboost .. " for each villain that entered a new city space this turn.",
                f = 'updateMMAnnihilus'})
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
        return nil
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
            bsPile.takeObject({position=getObjectFromGUID(getStrikeloc(objname)).getPosition(),
                flip=false,
                smooth=false})
        end
        arcadebasepower = 3
        if epicness then
            arcadebasepower = 4
        end
        function updateMMArcade()
            if not mmActive(objname) then
                return nil
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
                        label=arcadebasepower,
                        tooltip="You can fight these Human Shields for " .. arcadebasepower .. " to rescue them as Bystanders.",
                        font_size=250,
                        font_color="Red",
                        width=0})
                else
                    getObjectFromGUID(strikeloc).editButton({label=arcadebasepower,
                        tooltip="You can fight these Human Shields for " .. arcadebasepower .. " to rescue them as Bystanders."})
                end
            end
            mmButtons({mmname = objname,
                    checkvalue = checkvalue,
                    label = "X",
                    tooltip = "You can't fight Arcade while he has any Human Shields.",
                    f = 'updateMMArcade'})
        end
        updateMMArcade()
        function onObjectEnterZone(zone,object)
            updateMMArcade()
        end
        function onObjectLeaveZone(zone,object)
            updateMMArcade()
        end
        return nil
    end
    if objname == "Arnim Zola" then
        updateMMArnimZola = function()
            local power = 0
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    for _,k in pairs(hero.getTags()) do
                        if k:find("Attack:") or k:find("Attack1:") or k:find("Attack2:") then
                            power = power + tonumber(k:match("%d+"))
                        end
                    end
                end
            end
            mmButtons({mmname = objname,
                checkvalue = power,
                label = "+" .. power,
                tooltip = "Arnim Zola gets extra Attack equal to the total printed Attack of all heroes in the HQ.",
                f = 'updateMMArnimZola'})
        end
        updateMMArnimZola()
        function onObjectEnterZone(zone,object)
            for _,o in pairs(hqscriptguids) do
                if o == zone.guid then
                    updateMMArnimZola()
                end
            end

        end
        function onObjectLeaveZone(zone,object)
            for _,o in pairs(hqscriptguids) do
                if o == zone.guid then
                    updateMMArnimZola()
                end
            end
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = math.max(3-savior,0),
                label = "+9",
                tooltip = "The Baron gets +9 as long as you're not a Savior of at least 3 bystanders.",
                f = 'updateMMBaronHein'})
        end
        updateMMBaronHein()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Bystander") then
                updateMMBaronHein()
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Bystander") then
                updateMMBaronHein()
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMBaronHein()
        end
        return nil
    end
    if objname == "Baron Helmut Zemo" then
        updateMMBaronHelm = function()
            if not mmActive(objname) then
                return nil
            end
            local color = Turns.turn_color
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[color])
            local savior = 0
            for i = 1,2 do
                if vpilecontent[i] and vpilecontent[i].tag == "Deck" then
                    for _,k in pairs(vpilecontent[i].getObjects()) do
                        for _,l in pairs(k.tags) do
                            if l == "Villain" then
                                savior = savior + 1
                                break
                            end
                        end
                    end
                elseif vpilecontent[i] then
                    if vpilecontent[i].hasTag("Villain") then
                        savior = savior + 1
                    end
                end
            end
            mmButtons({mmname = objname,
                checkvalue = savior,
                label = "-" .. savior,
                tooltip = "The Baron gets -1 for each villain in your victory pile.",
                f = 'updateMMBaronHelm'})
        end
        updateMMBaronHelm()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMBaronHelm,0.1)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMBaronHelm,0.1)
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMBaronHelm()
        end
        return nil
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
                        if l:find("HC:") or l:find("Split") then
                            nongrey = nongrey + 1
                            break
                        end
                    end
                end
            end
            nongrey = nongrey/#Player.getPlayers() - 0.5*(nongrey % #Player.getPlayers())
            mmButtons({mmname = objname,
                checkvalue = nongrey,
                label = "+" .. nongrey,
                tooltip = "Belasco gets +1 equal to the number of non-grey Heroes in the KO pile, divided by the number of players (round down).",
                f = 'updateMMBelasco'})
        end
        updateMMBelasco()
        function onObjectEnterZone(zone,object)
            if zone.guid == kopile_guid then
                updateMMBelasco()
            end
        end
        function onObjectLeaveZone(zone,object)
            if zone.guid == kopile_guid then
                updateMMBelasco()
            end
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = bsfound,
                label = "+" .. bsfound,
                tooltip = "Charles Xavier gets +1 for each Bystander in the city and HQ.",
                f = 'updateMMCharles'})
        end
        updateMMCharles()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Bystander") then
                updateMMCharles()
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Bystander") then
                updateMMCharles()
            end
        end
        return nil
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
                        if o.getName():find("Shi'ar") or hasTag2(o,"Group:Shi'ar") then
                            shiarfound = shiarfound + 1
                            break
                        end
                    end
                end
            end
            local escapezonecontent = get_decks_and_cards_from_zone(escape_zone_guid)
            for i = 1,2 do
                if escapezonecontent[i] and escapezonecontent[i].tag == "Deck" then
                    for _,o in pairs(escapezonecontent[i].getObjects()) do
                        if o.name:find("Shi'ar") then
                            shiarfound = shiarfound + 1
                        elseif next(o.tags) then
                            for _,tag in pairs(o.tags) do
                                if tag:find("Shi'ar") then
                                    shiarfound = shiarfound + 1
                                    break
                                end
                            end
                        end
                    end
                elseif escapezonecontent[i] then
                    if escapezonecontent[i].getName():find("Shi'ar") or hasTag2(escapezonecontent[i],"Group:Shi'ar") then
                        shiarfound = shiarfound + 1
                    end
                end
            end
            local modifier = 1
            if epicness == true then
                modifier = 2
            end
            mmButtons({mmname = objname,
                checkvalue = shiarfound,
                label = "+" .. shiarfound*modifier,
                tooltip = "Deathbird gets +" .. modifier .. " for each Shi'ar Villain in the city and Escape Pile.",
                f = 'updateMMDeathbird'})
        end
        updateMMDeathbird()
        function onObjectEnterZone(zone,object)
            if object.getName():find("Shi'ar") or object.hasTag("Group:Shi'ar Imperial Elite") or object.hasTag("Group:Shi'ar Imperial Guard") then
                Wait.time(updateMMDeathbird,0.1)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.getName():find("Shi'ar") or object.hasTag("Group:Shi'ar Imperial Elite") or object.hasTag("Group:Shi'ar Imperial Guard") then
                Wait.time(updateMMDeathbird,0.1)
            end
        end
        return nil
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
            local hand = Player[Turns.turn_color].getHandObjects()
            if hand[1] then
                for _,o in pairs(hand) do
                    if o.hasTag("Starter") or o.getName() == "Sidekick" or o.getName() == "New Recruits" or (o.hasTag("Officer") and not hasTag2(o,"HC:")) then
                        power = power + boost
                    end
                end
            end
            mmButtons({mmname = objname,
                checkvalue = power,
                label = "+" .. power,
                tooltip = "Emma Frost gets +" .. boost .. " for each grey hero you have.",
                f = 'updateMMEmma'})
        end
        updateMMEmma()
        function onObjectEnterZone(zone,object)
            updateMMEmma()
        end
        function onObjectLeaveZone(zone,object)
            updateMMEmma()
        end
        function onPlayerTurn(player,previous_player)
            updateMMEmma()
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = power,
                label = "+" .. power,
                tooltip = "Emperor Vulcan gets +" .. power .. " if he has the Throne's Favor.",
                f = 'updateMMEmperorVulcan'})
        end
        if epicness then
            getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmEmperor Vulcan of the Shi'ar"})
            updateMMEmperorVulcan()
        end
        return nil
    end
    if objname == "Evil Deadpool" then
        if not mmActive(objname) then
            return nil
        end
        updateMMDeadpool = function()
            local color = Turns.turn_color
            local vpilecontent = get_decks_and_cards_from_zone(vpileguids[color])
            local tacticsfound = 0
            for i = 1,2 do
                if vpilecontent[i] and vpilecontent[i].tag == "Deck" then
                    for _,o in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(o.tags) do
                            if k:find("Tactic:") then
                                tacticsfound = tacticsfound + 1
                                break
                            end
                        end
                    end
                elseif vpilecontent[i] and hasTag2(vpilecontent[i],"Tactic:",8) then
                    tacticsfound = tacticsfound + 1
                end
            end
            mmButtons({mmname = objname,
                checkvalue = tacticsfound,
                label = "+" .. tacticsfound,
                tooltip = "Evil Deadpool gets +1 for each Mastermind Tactic in your victory pile.",
                f = 'updateMMDeadpool'})
        end
        updateMMDeadpool()
        function onObjectEnterZone(zone,object)
            if hasTag2(object,"Tactic:") then
                Wait.time(updateMMDeadpool,0.1)
            end
        end
        function onObjectLeaveZone(zone,object)
            if hasTag2(object,"Tactic:") then
                Wait.time(updateMMDeadpool,0.1)
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMDeadpool()
        end
        return nil
    end
    if objname == "Fin Fang Foom" or objname == "Fin Fang Foom - epic" then
        updateMMFinFang = function()
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
            local playedcards = get_decks_and_cards_from_zone(playguids[Turns.turn_color])
            if playedcards[1] then
                for _,o in pairs(playedcards) do
                    local tags = o.getTags()
                    if tags then
                        for _,tag in pairs(tags) do
                            if tag:find("HC:") then
                                hccolors[tag:gsub("HC:","")] = 2
                            end
                            if tag:find("HC1:") then
                                hccolors[tag:gsub("HC1:","")] = 2
                            end
                            if tag:find("HC2:") then
                                hccolors[tag:gsub("HC2:","")] = 2
                            end
                        end
                    end
                end
            end
            local hand = Player[Turns.turn_color].getHandObjects()
            if hand[1] then
                for _,o in pairs(hand) do
                    local tags = o.getTags()
                    if tags then
                        for _,tag in pairs(tags) do
                            if tag:find("HC:") then
                                hccolors[tag:gsub("HC:","")] = 2
                            end
                            if tag:find("HC1:") then
                                hccolors[tag:gsub("HC1:","")] = 2
                            end
                            if tag:find("HC2:") then
                                hccolors[tag:gsub("HC2:","")] = 2
                            end
                        end
                    end
                end
            end
            local boost = 0
            for _,o in pairs(hccolors) do
                boost = boost + o
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "-" .. boost,
                tooltip = "Fin Fang Foom gets -2 for each different Hero Class among heroes you have.",
                f = 'updateMMFinFang'})
        end
        updateMMFinFang()
        function onObjectEnterZone(zone,object)
            updateMMFinFang()
        end
        function onObjectLeaveZone(zone,object)
            updateMMFinFang()
        end
        function onPlayerTurn(player,previous_player)
            updateMMFinFang()
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = locationcount2,
                label = "+" .. locationcount2,
                tooltip = "Grim Reaper gets +" .. locationcount2/locationcount .. " for each Location card in the city.",
                f = 'updateMMReaper'})
        end
        updateMMReaper()
        function onObjectEnterZone(zone,object)
            if object.getDescription():find("LOCATION") then
                updateMMReaper()
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.getDescription():find("LOCATION") then
                updateMMReaper()
            end
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = villaincount,
                label = "+" .. villaincount*(5+boost),
                tooltip = "Hela gets +" .. 5+boost .. " for each Villain in the city zones she wants to conquer.",
                f = 'updateMMHela'})
        end
        updateMMHela()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Villain") then
                updateMMHela()
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Villain") then
                updateMMHela()
            end
        end
        return nil
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
                mmButtons({mmname = objname,
                    checkvalue = savior,
                    label = "-" .. savior,
                    tooltip = "The Baron gets -1 for each villain in your victory pile.",
                    f = 'updateMMHydraHigh'})
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
                mmButtons({mmname = objname,
                    checkvalue = shiarfound,
                    label = "+" .. shiarfound,
                    tooltip = "Viper gets +1 for each HYDRA Villain in the city.",
                    f = 'updateMMHydraHigh'})
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
                mmButtons({mmname = objname,
                    checkvalue = shiarfound,
                    label = "+" .. shiarfound,
                    tooltip = "Red Skull gets +1 for each two HYDRA levels.",
                    f = 'updateMMHydraHigh'})
            elseif name == "Arnim Zola" then
                local power = 0
                for _,o in pairs(hqguids) do
                    local hero = getObjectFromGUID(o).Call('getHeroUp')
                    if hero then
                        for _,k in pairs(hero.getTags()) do
                            if k:find("Attack:") or k:find("Attack1:") or k:find("Attack2:") then
                                power = power + tonumber(k:match("%d+"))
                            end
                        end
                    end
                end
                mmButtons({mmname = objname,
                    checkvalue = power,
                    label = "+" .. power,
                    tooltip = "Arnim Zola gets extra Attack equal to the total printed Attack of all heroes in the HQ.",
                    f = 'updateMMHydraHigh'})
            end
        end
        updateMMHydraHigh()
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMHydraHigh,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMHydraHigh,0.1)
        end
        function onPlayerTurn(player,previous_player)
            updateMMHydraHigh()
        end
        return nil
    end
    if objname == "Immortal Emperor Zheng-Zhu" then
        updateMMImmortalEmperor = function()
            if not mmActive(objname) then
                return nil
            end
            local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait = 6,what = "Cost", prefix = "Cost:", players = {Player[Turns.turn_color]}})
            local boost = 0
            if players[1] then
                boost = 7
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Immortal Emperor Zheng-Zhu is in the 7th Circle of Kung Fu and gets +7 unless you have a hero with at least that cost.",
                f = 'updateMMImmortalEmperor'})
        end
        updateMMImmortalEmperor()
        function onObjectEnterZone(zone,object)
            updateMMImmortalEmperor()
        end
        function onObjectLeaveZone(zone,object)
            updateMMImmortalEmperor()
        end
        function onPlayerTurn(player,previous_player)
            updateMMImmortalEmperor()
        end
        return nil
    end
    if objname == "J. Jonah Jameson" or objname == "J. Jonah Jameson - epic" then
        local soPile = getObjectFromGUID(officerDeckGUID)
        soPile.randomize()
        local jonah = 2
        if epicness == true then
            jonah = 3
        end
        local strikeZone = getObjectFromGUID(getStrikeloc(objname))
        for i=1,jonah*#Player.getPlayers() do
            soPile.takeObject({position = strikeZone.getPosition(),
                flip=false,
                smooth=false})
        end
        function click_pacify_angry_mob(obj,player_clicker_color)
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
                    hulkdeck.flip()
                    hulkdeck.setRotationSmooth(brot)
                    hulkdeck.setPositionSmooth(dest)
                else
                    hulkdeck.takeObject({position = dest,
                        flip = true,
                        smooth = true,
                        index = math.random(hulkdeck.getQuantity())-1})
                end
            end
        strikeZone.createButton({click_function="click_pacify_angry_mob", 
                 function_owner=self,
                 position={0,0,0.5},
                 rotation={0,180,0},
                 label="Pacify",
                 tooltip="Pacify this Angry Mob by fighting it and gain a random hero from it.",
                 color={0,0,0,1},
                 font_color = {1,0,0},
                 width=500,
                 height=200,
                 font_size = 100})
        updateMMJonah = function()
            if not mmActive(objname) then
                return nil
            end
            local angrymob = 4
            if epicness then
                angrymob = 5
            end
            local strikeloc = getStrikeloc(objname)
            local checkvalue = 1
            if not get_decks_and_cards_from_zone(strikeloc)[1] then
                getObjectFromGUID(strikeloc).clearButtons()
                checkvalue = 0
            else
                if not getObjectFromGUID(strikeloc).getButtons() then
                    getObjectFromGUID(strikeloc).createButton({click_function='updateMMJonah',
                        function_owner=self,
                        position={0,0,0},
                        rotation={0,180,0},
                        label=angrymob,
                        tooltip="You can pacify these Angry Mobs for " .. angrymob .. " to have any player gain them.",
                        font_size=250,
                        font_color="Red",
                        width=0})
                    strikeZone.createButton({click_function="click_pacify_angry_mob", 
                         function_owner=self,
                         position={0,0,0.5},
                         rotation={0,180,0},
                         label="Pacify",
                         tooltip="Pacify this Angry Mob by fighting it and gain a random hero from it.",
                         color={0,0,0,1},
                         font_color = {1,0,0},
                         width=500,
                         height=200,
                         font_size = 100})
                end
            end
            mmButtons({mmname = objname,
                checkvalue = checkvalue,
                label = "X",
                tooltip = "You can't fight J. Jonah while he has any Angry Mobs.",
                f = 'updateMMJonah'})
        end
        updateMMJonah()
        function onObjectEnterZone(zone,object)
            if zone.guid == getStrikeloc(objname) then
                updateMMJonah()
            end
        end
        function onObjectLeaveZone(zone,object)
            if zone.guid == getStrikeloc(objname) then
                updateMMJonah()
            end
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = villaincount,
                label = "+" .. villaincount*(2+boost),
                tooltip = "Kang gets +" .. 2+boost .. " for each Villain in the city zones under a time incursion.",
                f = 'updateMMKang'})
        end
        function onObjectEnterZone(zone,object)
            updateMMKang()
        end
        function onObjectLeaveZone(zone,object)
            updateMMKang()
        end
        return nil
    end
    if objname == "Kingpin" then
        mmButtons({mmname = objname,
            checkvalue = 1,
            label = "*",
            tooltip="Kingpin can be fought using Recruit as well as Attack.",
            f = 'updatePower',
            id = "bribe"})
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = savior,
                label = "+" .. savior,
                tooltip = "Macho Gomez gets +1 in revenge for each Deadpool's \"Friends\" villain in your victory pile.",
                f = 'updateMMMacho'})
        end
        updateMMMacho()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMMacho,0.1)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Villain") then
                Wait.time(updateMMMacho,0.1)
            end
        end
        function onPlayerTurn(player,previous_player)
            updateMMMacho()
        end
        return nil
    end
    if objname == "Madelyne Pryor, Goblin Queen" then
        function click_buy_goblin(obj,player_clicker_color)
            local hulkdeck = get_decks_and_cards_from_zone(obj.guid)[1]
            if not hulkdeck then
                return nil
            end
            local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
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
            if hulkdeck.tag == "Card" then
                hulkdeck.setRotationSmooth(brot)
                hulkdeck.setPositionSmooth(dest)
            else
                broadcastToColor("Choose a Bystander to rescue.",player_clicker_color,player_clicker_color)
                getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = player_clicker_color,
                    pile = hulkdeck,
                    targetpos = pos_vp2,
                    label = "Rescue",
                    tooltip = "Rescue this bystander."})
            end
        end
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
                    getObjectFromGUID(strikeloc).createButton({
                        click_function="click_buy_goblin", 
                        function_owner=self,
                        position={0,0,0.5},
                        rotation={0,180,0},
                        label="Fight",
                        tooltip="Fight one of the officers to gain it as a hero.",
                        color={0,0,0,1},
                        font_color = {1,0,0},
                        width=500,
                        height=200,
                        font_size = 100
                    })
                else
                    getObjectFromGUID(strikeloc).editButton({label="2",
                        tooltip="You can fight these Demon Goblins for 2 to rescue them as Bystanders."})
                end
            end
            mmButtons({mmname = objname,
                checkvalue = checkvalue,
                label = "X",
                tooltip = "You can't fight Madelyne Pryor while she has any Demon Goblins.",
                f = 'updateMMMadelyne'})
        end
        updateMMMadelyne()
        function onObjectEnterZone(zone,object)
            updateMMMadelyne()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMadelyne()
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = shardsfound,
                label = "+" .. boost*shardsfound,
                tooltip = "Magus gets + " .. boost .. " for each Villain in the city that has any Shards.",
                f = 'updateMMMagus'})
        end
        updateMMMagus()
        function onObjectEnterZone(zone,object)
            updateMMMagus()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMagus()
        end
        return nil
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
                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = obj,label = boost,tooltip = "Bonus of the Mandarin",id = "mandarin"})
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
            mmButtons({mmname = objname,
                checkvalue = tacticsfound,
                label = "-" .. tacticsfound*modifier,
                tooltip = "Mandarin gets -" .. modifier .. " for each Mandarin's Rings among all players' Victory Piles.",
                f = 'updateMMMandarin'})
        end
        updateMMMandarin()
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMandarin,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMandarin,0.1)
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = shieldfound,
                label = "X",
                tooltip = "You can't fight Maria Hill while there are any S.H.I.E.L.D. Elite Villains or Officers in the city.",
                f = 'updateMMMaria'})
        end
        updateMMMaria()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Officer") or obj.hasTag("Group:S.H.I.E.L.D. Elite") then
                updateMMMaria()
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Officer") or obj.hasTag("Group:S.H.I.E.L.D. Elite") then
                updateMMMaria()
            end
        end
        return nil
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
                        if k:find("Attack1:") then
                            power = math.max(power,tonumber(k:match("%d+")))
                        end
                        if k:find("Attack2:") then
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
            mmButtons({mmname = objname,
                checkvalue = power,
                label = "+" .. power,
                tooltip = "Maximus gets extra Attack equal to" .. boost .. "the highest printed Attack of all heroes in the HQ.",
                f = 'updateMMMaximus'})
        end
        updateMMMaximus()
        function onObjectEnterZone(zone,object)
            updateMMMaximus()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMaximus()
        end
        return nil
    end
    if objname == "Misty Knight" then
        mmButtons({mmname = objname,
            checkvalue = 1,
            label = "*",
            tooltip="Misty Knight can be fought using Recruit as well as Attack.",
            f = 'updatePower',
            id = "bribe"})
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
            mmButtons({mmname = objname,
                    checkvalue = checkvalue,
                    label = "X",
                    tooltip = "You can't fight Mojo while he has any Human Shields.",
                    f = 'updateMMMojo'})
        end
        updateMMMojo()()
        function onObjectEnterZone(zone,object)
            updateMMMojo()
        end
        function onObjectLeaveZone(zone,object)
            updateMMMojo()
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = bscount,
                label = "+" .. bscount,
                tooltip = "Mole Man gets +1 for each Subterranea Villain that has escaped.",
                f = 'updateMMMoleMan'})
        end
        updateMMMoleMan()
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMMoleMan,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMMoleMan,0.1)
        end
        return nil
    end
    if objname == "Morgan Le Fay" then
        mmButtons({mmname = objname,
            checkvalue = 1,
            label = "*",
            tooltip="Chivalrous Duel: Attack Morgan only with the power of a single hero.",
            f = 'updatePower'})
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
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Mr. Sinister gets +1 for each Bystander he has.",
                f = 'updateMMMrSinister'})
        end
        function onObjectEnterZone(zone,object)
            if object.hasTag("Bystander") then
                Wait.time(updateMMMrSinister,0.1)
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Bystander") then
                Wait.time(updateMMMrSinister,0.1)
            end
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = shiarfound,
                label = "+" .. shiarfound,
                tooltip = "Odin gets +1 for each Asgardian Warrior in the city and Escape Pile.",
                f = 'updateMMOdin'})
        end
        updateMMOdin()
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMOdin,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMOdin,0.1)
        end
        return nil
    end
    if objname == "Onslaught" or objname == "Onslaught - epic" then
        for _,o in pairs(Player.getPlayers()) do
            getObjectFromGUID(playerBoards[o.color]).Call('onslaughtpain')
        end
        broadcastToAll("Hand size reduced by 1 because of Onslaught. Good luck! You're going to need it.")
        function updateMMOnslaught()
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
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Onslaught gets +1 for each hero he dominates.",
                f = 'updateMMOnslaught'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMOnslaught,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMOnslaught,0.1)
        end
        return nil
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
                local costs = callGUID("herocosts",2)
                for _,o in pairs(poisoned[1].getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("Cost:") then
                            costs[tonumber(k:match("%d+"))] = costs[tonumber(k:match("%d+"))] + 1
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
            mmButtons({mmname = objname,
                checkvalue = poisoncount,
                label = "+" .. poisoncount*boost,
                tooltip = "Poison Thanos gets + " .. boost .. " for each different cost among cards in his Poisoned Souls pile.",
                f = 'updateMMPoisonThanos'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMPoisonThanos,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMPoisonThanos,0.1)
        end
        return nil
    end
    if objname == "Professor X" then
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
        function click_buy_pawn(obj,player_clicker_color)
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
        getObjectFromGUID(strikeloc).createButton({
             click_function="click_buy_pawn", 
             function_owner=self,
             position={0,0,-0.75},
             rotation={0,180,0},
             label="Buy Pawn",
             tooltip="Buy the top card of Professor X's telepathic pawns.",
             color={1,1,1,1},
             width=800,
             height=200,
             font_size = 100
        })
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
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Professor X gets +1 for each of his telepathic pawns.",
                f = 'updateMMProfessorX'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMProfessorX,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMProfessorX,0.1)
        end
        return nil
    end
    if objname == "'92 Professor X" then
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
        function click_buy_pawn92(obj,player_clicker_color)
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
        getObjectFromGUID(strikeloc).createButton({
             click_function="click_buy_pawn92", 
             function_owner=self,
             position={0,0,-0.75},
             rotation={0,180,0},
             label="Buy Pawn",
             tooltip="Buy the top card of '92 Professor X's telepathic pawns.",
             color={1,1,1,1},
             width=800,
             height=200,
             font_size = 100
        })
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
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "'92 Professor X gets +1 for each of his telepathic pawns.",
                f = 'updateMMProfessorX92'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMProfessorX92,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMProfessorX92,0.1)
        end
        return nil
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
                        if k:find("HC1:") then
                            hccolors[k:gsub("HC1:","")] = 2
                        end
                        if k:find("HC2:") then
                            hccolors[k:gsub("HC2:","")] = 2
                        end
                    end
                end
            end
            local boost = 0
            for _,o in pairs(hccolors) do
                boost = boost + o
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Ragnarok gets +2 for each Hero Class among Heroes in the HQ.",
                f = 'updateMMRagnarok'})
        end
        updateMMRagnarok()
        function onObjectEnterZone(zone,object)
            updateMMRagnarok()
        end
        function onObjectLeaveZone(zone,object)
            updateMMRagnarok()
        end
        return nil
    end
    if objname == "Shadow King" or objname == "Shadow King - epic" then
        if epicness then
            getObjectFromGUID(setupGUID).Call('playHorror')
            getObjectFromGUID(setupGUID).Call('playHorror')
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
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Shadow King gets +1 for each hero he dominates.",
                f = 'updateMMShadowKing'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMShadowKing,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMShadowKing,0.1)
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = bscount,
                label = "+" .. bscount,
                tooltip = "Spider-Queen gets +1 for each Bystander in the Escape pile.",
                f = 'updateMMSpiderQueen'})
        end
        updateMMSpiderQueen()
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMSpiderQueen,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMSpiderQueen,0.1)
        end
        return nil
    end
    if objname == "Stryfe" then
        updateMMStryfe = function()
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
            local boost = 0
            if bs[1] then
                boost = math.abs(bs[1].getQuantity())
            end
            mmButtons({mmname = objname,
                checkvalue = boost,
                label = "+" .. boost,
                tooltip = "Stryfe gets +1 for each Master Strike stacked next to him.",
                f = 'updateMMStryfe'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMStryfe,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMStryfe,0.1)
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = gemfound,
                label = "-" .. gemfound*2,
                tooltip = "Thanos gets -2 for each Infinity Gem Artifact card controlled by any player.",
                f = 'updateMMThanos'})
        end
        updateMMThanos()
        function onObjectEnterZone(zone,object)
            if object.hasTag("Group:Infinity Gems") then
                updateMMThanos()
            end
        end
        function onObjectLeaveZone(zone,object)
            if object.hasTag("Group:Infinity Gems") then
                updateMMThanos()
            end
        end
        return nil
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
        local strikeZone = getObjectFromGUID(getStrikeloc(objname))
        function click_save_goblin_hw(obj,player_clicker_color)
            local hulkdeck = get_decks_and_cards_from_zone(obj.guid)[1]
            if not hulkdeck then
                return nil
            end
            local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
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
            if hulkdeck.tag == "Card" then
                hulkdeck.flip()
                hulkdeck.setRotationSmooth(brot)
                hulkdeck.setPositionSmooth(dest)
            else
                hulkdeck.takeObject({position = dest,
                    flip = true,
                    smooth = true,
                    index = math.random(hulkdeck.getQuantity())-1})
            end
        end
        strikeZone.createButton({click_function='click_save_goblin_hw', 
                 function_owner=self,
                 position={0,0,0.5},
                 rotation={0,180,0},
                 label="Save",
                 tooltip="Save a Hidden Witness by paying 2 recruit and rescue it as a bystander.",
                 color={0,0,0,1},
                 font_color = {1,0,0},
                 width=500,
                 height=200,
                 font_size = 100})
        function updateMMTheGoblin()
            if not mmActive(objname) then
                return nil
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
                        label=2,
                        tooltip="You can save these Hidden Witnesses for 2 Recruit to rescue them as Bystanders.",
                        font_size=250,
                        font_color="Yellow",
                        width=0})
                    getObjectFromGUID(strikeloc).createButton({click_function='click_save_goblin_hw', 
                         function_owner=self,
                         position={0,0,0.5},
                         rotation={0,180,0},
                         label="Save",
                         tooltip="Save a Hidden Witness by paying 2 recruit and rescue it as a bystander.",
                         color={0,0,0,1},
                         font_color = {1,0,0},
                         width=500,
                         height=200,
                         font_size = 100})
                end
            end
            mmButtons({mmname = objname,
                    checkvalue = checkvalue,
                    label = "X",
                    tooltip = "You can't fight The Goblin while he has any Hidden Witnesses.",
                    f = 'updateMMTheGoblin'})
        end
        updateMMTheGoblin()
        function onObjectEnterZone(zone,object)
            updateMMTheGoblin()
        end
        function onObjectLeaveZone(zone,object)
            updateMMTheGoblin()
        end
        return nil
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
            local hccolors = {
                ["Red"] = 0,
                ["Yellow"] = 0,
                ["Green"] = 0,
                ["Silver"] = 0,
                ["Blue"] = 0
            }
            if discard and discard.tag == "Deck" then
                for _,o in pairs(discard.getObjects()) do
                    for _,k in pairs(o.tags) do
                        if k:find("HC:") then
                            hccolors[k:gsub("HC:","")] = boost
                        end
                        if k:find("HC1:") then
                            hccolors[k:gsub("HC1:","")] = boost
                        end
                        if k:find("HC2:") then
                            hccolors[k:gsub("HC2:","")] = boost
                        end
                    end
                end
                
            elseif discard then
                for _,k in pairs(discard.getTags()) do
                    if k:find("HC:") then
                        hccolors[k:gsub("HC:","")] = boost
                    end
                    if k:find("HC1:") then
                        hccolors[k:gsub("HC1:","")] = boost
                    end
                    if k:find("HC2:") then
                        hccolors[k:gsub("HC2:","")] = boost
                    end
                end
            end
            for _,o in pairs(hccolors) do
                darkmemories = darkmemories + o
            end
            mmButtons({mmname = objname,
                checkvalue = darkmemories,
                label = "+" .. darkmemories,
                tooltip = "Dark Memories: The Hood gets +1 for each Hero Class among cards in your discard pile.",
                f = 'updateMMHood'})
        end
        updateMMHood()
        function onPlayerTurn(player,previous_player)
            updateMMHood()
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMHood,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMHood,0.1)
        end
        return nil
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
                        end
                        if k:find("HC1:") then
                            hccolors[k:gsub("HC1:","")] = true
                        end
                        if k:find("HC2:") then
                            hccolors[k:gsub("HC2:","")] = true
                        end
                    end
                end
            elseif threatanalysis[1] then
                hccolors[hasTag2(threatanalysis[1],"HC:",4)] = true
            end
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero and hero.getTags() then
                    for _,tag in pairs(hero.getTags()) do
                        if tag:find("HC:") and hccolors[tag:gsub("HC:","")] then
                            empowerment = empowerment + boost
                        end
                        if tag:find("HC1:") and hccolors[tag:gsub("HC1:","")] then
                            empowerment = empowerment + boost
                        end
                        if tag:find("HC2:") and hccolors[tag:gsub("HC2:","")] then
                            empowerment = empowerment + boost
                        end
                    end
                end
            end
            mmButtons({mmname = objname,
                checkvalue = empowerment,
                label = "+" .. empowerment,
                tooltip = "Ultron is " .. epicboost .. "Empowered by each color in his Threat Analysis pile.",
                f = 'updateMMUltron'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMUltron,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMUltron,0.1)
        end
        return nil
    end
    if objname == "Vulture" or objname == "Vulture - epic" then
        updateMMVulture = function()
            if not mmActive(objname) then
                return nil
            end
            local strikes = getObjectFromGUID(pushvillainsguid).Call('returnVar','strikesresolved')
            mmButtons({mmname = objname,
                checkvalue = strikes,
                label = "+" .. strikes,
                tooltip = "Vulture is a striker and gets +1 for each Master Strike that has been played.",
                f = 'updateMMVulture'})
        end
        updateMMVulture()
        function onObjectEnterZone(zone,object)
            if object.getName() == "Masterstrike" then
                updateMMVulture()
            end
        end
        return nil
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
            mmButtons({mmname = objname,
                checkvalue = tacticsfound,
                label = "+" .. tacticsfound*3,
                tooltip = "Wasteland Hulk gets +3 for each of his Mastermind Tactics among all players' Victory Piles.",
                f = 'updateMMWastelandHulk'})
        end
        function onObjectEnterZone(zone,object)
            Wait.time(updateMMWastelandHulk,0.1)
        end
        function onObjectLeaveZone(zone,object)
            Wait.time(updateMMWastelandHulk,0.1)
        end
        return nil
    end
    if objname == "Zombie Green Goblin" then
        updateMMZombieGoblin = function()
            if not mmActive(objname) then
                return nil
            end
            local kopilecontent = get_decks_and_cards_from_zone(kopile_guid)
            local nongrey = 0
            if kopilecontent[1] and kopilecontent[1].tag == "Deck" then
                for _,k in pairs(kopilecontent[1].getObjects()) do
                    for _,l in pairs(k.tags) do
                        if l:find("Cost:") and tonumber((l:gsub("Cost:",""))) > 6 then
                            nongrey = nongrey + 1
                            break
                        end
                    end
                end
            end
            mmButtons({mmname = objname,
                checkvalue = nongrey,
                label = "+" .. nongrey,
                tooltip = "Zombie Green Goblin gets +1 for each hero that costs 7 or more in the KO pile.",
                f = 'updateMMZombieGoblin'})
        end
        updateMMZombieGoblin()
        function onObjectEnterZone(zone,object)
            if zone.guid == kopile_guid then
                updateMMZombieGoblin()
            end
        end
        function onObjectLeaveZone(zone,object)
            if zone.guid == kopile_guid then
                updateMMZombieGoblin()
            end
        end
        return nil
    end
end

function updatePower()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function mmButtons(params)
    local mmname = params.mmname
    local checkvalue = params.checkvalue
    local label = tostring(params.label)
    local tooltip = params.tooltip
    local f = params.f
    local id = params.id or "base"
    
    local mmzone = getObjectFromGUID(mmLocations[mmname])
    if not mmzone then
        return nil
    end
    local buttonindex = nil
    local toolt_orig = {}
    for i,o in pairs(mmzone.getButtons()) do
        if o.click_function == f or (f == "mm" and o.click_function:find("updateMM")) or o.click_function == "updatePower" then
            buttonindex = i-1
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
            if f == "mm" then
                f = o.click_function
            end
            break
        end
    end
    if f == "mm" then
        f = 'updatePower'
    end
    if checkvalue == 0 then
        label = ""
    end
    if not toolt_orig then
        toolt_orig = {[id] = {label,tooltip}}
    else
        toolt_orig[id] = {label,tooltip}
    end
    local lab,tool = updateLabel(toolt_orig)
    if not buttonindex then
        mmzone.createButton({click_function=f,
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            label=lab,
            tooltip=tool,
            font_size=350,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
    else
        mmzone.editButton({index=buttonindex,label = lab,tooltip = tool})
    end
end

function updateLabel(tooltip)
    local sum = 0
    local aster = false
    local plus = true
    for i,o in pairs(tooltip) do
        if o[1] == "" then
            tooltip[i] = nil
        else
            if not o[1]:find("+") and o[1] ~= "*" then
                plus = false
            end
            if o[1]:find("*") then
                aster = true
            end
            if o[1]:find("-") then
                sum = sum - tonumber(o[1]:match("%d+"))
            elseif o[1]:find("X") then
                sum = "X"
                break
            elseif o[1] and o[1]:match("%d+") then
                sum = sum + tonumber(o[1]:match("%d+"))
            end
        end
    end
    if sum == 0 then
        sum = ""
    end
    if aster and sum ~= "X" then
        sum = sum .. "*"
    end
    if plus and sum ~= "X" and sum ~= "" and sum ~= "*" then
        sum = "+" .. sum
    end
    local newtooltip = ""
    for i,o in pairs(tooltip) do
        if o then
            if newtooltip ~= "" then
                newtooltip = newtooltip .. "\n" .. o[2] .. "[" .. i .. ":" .. o[1] .. "]"
            else
                newtooltip = o[2] .. "[" .. i .. ":" .. o[1] .. "]"
            end
        end
    end
    if not newtooltip then
        newtooltip = ""
    end
    return sum,newtooltip
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
        local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
        local power = 0
        for _,o in pairs(get_decks_and_cards_from_zone(obj.guid)) do
            if o.tag == "Deck" then
                for _,p in pairs(o.getObjects()) do
                    local mmfound = false
                    local tacticfound = false
                    power = 0
                    for _,t in pairs(p.tags) do
                        if t == "Mastermind" then
                            mmfound = true
                        end
                        if t:find("Tactic:") then
                            tacticfound = true
                        end
                        if t:find("Power:") then
                            power = tonumber(t:match("%d+")) or 0
                        end
                    end
                    if mmfound and not tacticfound then
                        break
                    end
                end
            else
                if o.hasTag("Mastermind") and not hasTag2(o,"Tactic:") then
                    power = hasTag2(o,"Power:") or 0
                    break
                end
            end
        end
        if obj.getButtons() then
            for _,b in pairs(obj.getButtons()) do
                if b.click_function == "updatePower" then
                    if b.label:match("%d+") and b.label:find("+") then
                        power = power + tonumber(b.label:match("%d+"))
                    elseif b.label:match("%d+") and not b.label:find("-") then
                        power = tonumber(b.label:match("%d+"))
                    elseif b.label:match("%d+") then
                        power = power - tonumber(b.label:match("%d+"))
                    elseif b.label == "X" then
                        broadcastToColor("You can't fight this villain right now due to some restriction!",player_clicker_color,player_clicker_color)
                        return nil
                    end
                end
            end
        end
        if attack < power then
            broadcastToColor("You don't have enough attack to fight this villain!",player_clicker_color,player_clicker_color)
            return nil
        end
        getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-power)
        local name = fightMM(obj.guid,player_clicker_color)
        Wait.time(function() click_update_tactics(obj) end,1)
        --log("name:")
        --log(name)
        if name then
            local killFightButton = function()
                local content = get_decks_and_cards_from_zone(obj.guid,false,false)
                local finalblow = callGUID("finalblow",1)
                if not content[1] or (not finalblow and content[1].tag == "Card" and content[1].getName() == name and not content[2]) then
                    if name == "Authoritarian Iron Man" and finalblow and getObjectFromGUID("92abf0") then
                        return nil
                    end
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
                    if transformed[name] then
                        transformed[name] = nil
                    end
                    for i,o in ipairs(obj.getButtons()) do
                        if o.click_function:find("fightEffect") or o.click_function == "transformMM" then
                            obj.removeButton(i-1)
                        elseif o.click_function:find("updateMM") then
                            obj.removeButton(i-1)
                        elseif o.click_function == "click_update_tactics" then
                            obj.removeButton(i-1)
                        end
                    end
                    local strikecontent = get_decks_and_cards_from_zone(strikeloc)
                    if strikecontent[1] then
                        strikecontent[1].destruct()
                    end
                    local strikeZone = getObjectFromGUID(strikeloc)
                    local strikebutt = strikeZone.getButtons()
                    local iter2 = 0
                    if strikebutt then
                        for i,o in ipairs(strikebutt) do
                            if o.click_function:find("updateMM") then
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
                                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = c, label = "", id = "mandarin"})
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
                                            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = c, label = "", id = "apocalypse"})
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
                elseif mmGetCards(name) == 4 then
                    content[1].randomize()
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
    local thetacticstays = false
    if name == "King Hyperion" then
        for i,o in pairs(city_zones_guids) do
            if i > 1 then
                local citycontent = get_decks_and_cards_from_zone(o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if obj.getName() == "King Hyperion" then
                            obj.setPositionSmooth(getObjectFromGUID(zoneguid).getPosition())
                            thetacticstays = true
                            for _,obj2 in pairs(citycontent) do
                                if obj2.getName() ~= "King Hyperion" and not obj2.getDescription():find("LOCATION") then
                                    koCard(obj2)
                                end
                            end
                            break
                        end
                    end
                    if thetacticstays == true then
                        break
                    end
                end
            end
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
                if thetacticstays == true then
                    resolveTactics(name,o.getObjects()[1].name,player_clicker_color,true)
                    o.randomize()
                    return nil
                else
                    o.takeObject({position = vppos,
                        flip = o.is_face_down,
                        smooth = true})
                    return name
                end
            elseif o.tag == "Card" and hasTag2(o,"Tactic:",8) then
                if thetacticstays == true then
                    resolveTactics(name,o.getName(),player_clicker_color,true)
                    return nil
                else
                    o.setPositionSmooth(vppos)
                    if o.is_face_down then
                        Wait.time(function() o.flip() end,0.8)
                    end
                    return name
                end
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
                    if thetacticstays == true then
                        resolveTactics(name,content[1].getObjects()[i+1].name,player_clicker_color,true)
                        local pos = content[1].getPosition()
                        pos.y = pos.y + 2
                        local shufflethetactics = function()
                            if content[1] then
                                content[1].randomize()
                            end
                        end
                        content[1].takeObject({position = pos,
                            smooth = true,
                            callback_function = shufflethetactics})
                        return nil
                    else
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
            end
            if thetacticstays == true then
                resolveTactics(name,content[1].getObjects()[1].name,player_clicker_color,true)
                content[1].randomize()
                return nil
            else
                content[1].takeObject({position = vppos,
                    flip = content[1].is_face_down,
                    smooth = true})
                return name
            end
        else
            if thetacticstays == true then
                resolveTactics(name,o.getName(),player_clicker_color,true)
                return nil
            else
                content[1].setPositionSmooth(vppos)
                if content[1].is_face_down then
                    Wait.time(function() content[1].flip() end,0.8)
                end
                return name
            end
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

function resolveTactics(mmname,tacticname,color,stays)
    if mmname[1] then
        tacticname = mmname[2]
        color = mmname[3]
        stays = mmname[4]
        mmname = mmname[1]
    end
    if mmname == "King Hyperion" and stays then
        if tacticname == "Monarch of Utopolis" then
            for i = 1,3 do
                getObjectFromGUID(playerBoards[color]).Call('handsizeplus')
            end
            broadcastToColor("No tactic earned, as the King was in the city, but you'll draw three extra cards next turn.",color,color)
        elseif tacticname == "Rule with an iron fist" then
            broadcastToColor("No tactic earned, as the King was in the city, but you may defeat a villain the city for free (unscripted).",color,color)
        elseif tacticname == "Worshipped by millions" then
            for i = 1,6 do
                getObjectFromGUID(pushvillainsguid).Call('gainBystander',color)
            end
            broadcastToColor("No tactic earned, as the King was in the city, but you rescue six bystanders.",color,color)
        elseif tacticname == "Royal treasury" then
            getObjectFromGUID(resourceguids[color]).Call('addValue',5)
            broadcastToColor("No tactic earned, as the King was in the city, but you gained 5 Recruit.",color,color)
        end
        return nil
    end
    if mmname == "Maximus the Mad" then
        if tacticname == "Seize the inhuman throne" then
            local thronesfavor = callGUID("thronesfavor",1)
            local val = 4
            if thronesfavor == "mmMaximus the Mad" then
                val = 3
            end
            getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmMaximus the Mad"})
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                log(o.color)
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,n = #hand-val})
            end
            broadcastToAll("Maximus Fight effect: Maximus seizes the inhuman throne! Each player discards down to " .. val .. " cards.")
        elseif tacticname == "Terrigen bomb" then
            bump(get_decks_and_cards_from_zone(heroDeckZoneGUID)[1])
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero and (not hasTag2(hero,"Attack:") or hasTag2(hero,"Attack:") < 2) then
                    getObjectFromGUID(o).Call('tuckHero')
                end
            end
            local thronesfavor = callGUID("thronesfavor",1)
            if thronesfavor == "mmMaximus the Mad" then
                for _,o in pairs(Player.getPlayers()) do
                    local hand = o.getHandObjects()
                    local toKO = {}
                    for _,obj in pairs(hand) do
                        if hasTag2(obj,"Attack:") and hasTag2(obj,"HC:") then
                            table.insert(toKO,obj)
                        end
                    end
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                        hand = toKO,
                        pos = getObjectFromGUID(kopile_guid).getPosition(),
                        label = "KO",
                        tooltip = "KO this card."})
                end
                broadcastToAll("Maximus Fight effect: Maximus deploys the Terrigen Bomb! Weak heroes with attack less than 2 are blown away from the HQ. As he had the Throne's Favor, each player KO's a non-grey hero with an attack symbol.")
            else
                broadcastToAll("Maximus Fight effect: Maximus deploys the Terrigen Bomb! Weak heroes with attack less than 2 are blown away from the HQ.")
            end
            getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mmMaximus the Mad"})
            
        elseif tacticname == "Echo-tech chorus sentries" then
            for _,o in pairs(Player.getPlayers()) do
                local hand = o.getHandObjects()
                local toKO = {}
                for _,obj in pairs(hand) do
                    if (hasTag2(obj,"HC:") and hasTag2(obj,"HC:") == "Silver") or (hasTag2(obj,"Team:") and hasTag2(obj,"Team:") == "Inhumans") then
                        table.insert(toKO,obj)
                    end
                end
                local play = get_decks_and_cards_from_zone(playguids[o.color])
                if play[1] then
                    for _,obj in pairs(play) do
                        if (hasTag2(obj,"HC:") and hasTag2(obj,"HC:") == "Silver") or (hasTag2(obj,"Team:") and hasTag2(obj,"Team:") == "Inhumans") then
                            table.insert(toKO,obj)
                        end
                    end
                end
                if #toKO == 0 then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                else
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                        hand = toKO,
                        pos = getObjectFromGUID(kopile_guid).getPosition(),
                        label = "KO",
                        tooltip = "KO this card"})
                end
            end
            broadcastToAll("Maximus Fight effect: Maximus deploys the Echo-Tech Chorus Sentries. Each player KOs a silver or Inhumans hero or gains a wound.")
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
                            if k:find("HC:") or k == "Split" then
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
           broadcastToAll("Maximus Fight effect: Maximus deploys the Sieve of Secrets. Each player discards all non-grey heroes from the top 6 cards of their deck.")
        else
            printToAll("Unknown tactic found? (" .. tacticname[1] .. ").")
        end
        return nil
    end
end