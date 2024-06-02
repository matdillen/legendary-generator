function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end

    local guids3 = {
        "resourceguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
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

function villainDeckSpecial(params)
    local topCityZones = table.clone(allTopBoardGUIDS)
    for i = 1,4 do
        table.remove(topCityZones)
    end
    local vilDeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    vilDeck.randomize()
    parallel_dimensions = {}
    local subcount = 1
    while subcount > 0 do
        local hqZoneGUID = table.remove(topCityZones)
        table.insert(parallel_dimensions,hqZoneGUID)
        getObjectFromGUID(mmZoneGUID).Call('lockTopZone',hqZoneGUID)
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
    log("Villain deck split in piles above the board!")
    local decksShuffle = function()
        for i=1,#allTopBoardGUIDS do
            local deck = Global.Call('get_decks_and_cards_from_zone',allTopBoardGUIDS[i])[1]
            if deck then
                deck.randomize()
                toggleButtons(allTopBoardGUIDS[i])
            end
        end
    end
    Wait.time(decksShuffle,2)
    getObjectFromGUID(setupGUID).Call('disable_autoplay')
end

function toggleButtons(zoneguid)
    local zone = getObjectFromGUID(zoneguid)
    local butt = zone.getButtons()
    local buttonfound = false
    if butt then
        for i,o in pairs(butt) do
            if o.click_function == "click_draw_villainBPD" or o.click_function == "click_focus" then
                zone.removeButton(i-1)
                buttonfound = true
            end
        end
    end
    if buttonfound == false then
        zone.createButton({click_function='click_draw_villainBPD',
            function_owner=self,
            position={0,0,0.3},
            rotation={0,180,0},
            label="Draw",
            tooltip="Draw a card from this villain deck dimension.",
            font_size=100,
            font_color="Black",
            color="White",
            width=375})
        zone.createButton({click_function='click_focus',
            function_owner=self,
            position={0,0,0.7},
            rotation={0,180,0},
            label="Focus",
            tooltip="Look at the top card of this villain deck and put it back on top or bottom.",
            font_size=100,
            font_color="Black",
            color="Yellow",
            width=375})   
    end
end

function lockFocusedCard(object)
    focusedcard = object
    object.locked = true
end

function resolveFocus(params)
    focusedcard.locked = false
    focusedcard.flip()
    local villaindeck = Global.Call('get_decks_and_cards_from_zone',focusedzone.guid)[1]
    if villaindeck and params.id == "top" then
        focusedcard.putObject(villaindeck)
    elseif villaindeck then
        Global.Call('bump',{obj = villaindeck})
        local card = focusedcard
        local pos = focusedzone.getPosition()
        Wait.time(
            function()
                card.setPosition(pos)
            end,
            0.5)
    end
    toggleButtons(focusedzone.guid)
    focusedcard = nil
    focusedzone = nil
end

function click_focus(object,player_clicker_color)
    if focusedcard or focusedzone then
        broadcastToColor("Focus already in progress. Resolve it first!",player_clicker_color,player_clicker_color)
        return nil
    end
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < 1 then
        broadcastToColor("You don't have enough recruit to focus on this villain deck!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-1)
    local villaindeck = Global.Call('get_decks_and_cards_from_zone',object.guid)[1]
    local pos = object.getPosition()
    pos.y = pos.y + 3
    if not villaindeck then
        broadcastToColor("No villain deck found here.",player_clicker_color,player_clicker_color)
        return nil
    end
    focusedzone = object
    toggleButtons(object.guid)
    getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = player_clicker_color,
        choices = {["top"] = "Top",
            ["bottom"] = "Bottom"},
        fsourceguid = self.guid,
        resolve_function = "resolveFocus",
        otherzoneguid = object.guid})
    if villaindeck.tag == "Deck" then
        villaindeck.takeObject({position = pos,
            flip = true,
            callback_function = lockFocusedCard})
    else
        villaindeck.flip()
        villaindeck.setPositionSmooth(pos)
        lockFocusedCard(villaindeck)  
    end
end

function click_draw_villainBPD(obj,player_clicker_color)
    local vildeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not vildeck then
        broadcastToColor("No villain deck found here.",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{vildeckguid = obj.guid})
end

function playTwoFamily(params)
    local obj = params.obj
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,vildeckguid = obj.guid})
    for _,o in pairs(allTopBoardGUIDS) do
        local deck = Global.Call('get_decks_and_cards_from_zone',o)
        if deck[1] then
            toggleButtons(o)
        end
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Remaining dimensions: __/" .. #parallel_dimensions .. "."}
    else
        local counter = 0
        for _,o in pairs(parallel_dimensions) do
            local content = Global.Call('get_decks_and_cards_from_zone',o)[1]
            if content then
                counter = counter + 1
            end
        end
        return counter
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    broadcastToAll("Scheme Twist: Choose a villain deck to draw two cards from.")
    local decks = {}
    for _,o in pairs(allTopBoardGUIDS) do
        local deck = Global.Call('get_decks_and_cards_from_zone',o)
        if deck[1] then
            for _,b in pairs(getObjectFromGUID(o).getButtons()) do
                if b.click_function == "click_draw_villainBPD" then
                    table.insert(decks,getObjectFromGUID(o))
                    toggleButtons(o)
                    break
                end
            end
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = decks,
        pos = "Stay",
        label = "Play",
        tooltip = "Play two cards from this villain deck.",
        trigger_function = 'playTwoFamily',
        args = "self",
        buttoncolor = "Red",
        isZone = true,
        fsourceguid = self.guid})
    return twistsresolved
end