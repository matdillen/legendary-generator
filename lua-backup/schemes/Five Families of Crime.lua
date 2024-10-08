function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "mmZoneGUID",
        "villainDeckZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "topBoardGUIDs",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function customCity()
    if not fiveFamiliesTargetZone then
        return nil
    else
        return {city_zones_guids[1],fiveFamiliesTargetZone}
    end
end

function villainDeckSpecial(params) 
    log("Splitting villain deck in five")
    local vilDeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
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
        getObjectFromGUID(o).createButton({click_function='click_draw_villain',
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
    log("Villain deck split in piles above the board!")
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,7 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    getObjectFromGUID(setupGUID).Call('disable_autoplay')
    fiveFamiliesTargetZone = nil
end

function click_draw_villain(obj)
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

function playTwoFamily(params)
    click_draw_villain(params.obj)
    click_draw_villain(params.obj)
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Villains escaped: __/8.",
                ["zoneguid"] = escape_zone_guid,
                ["tooltip2"] = "Villain deck count: __.",
                ["zoneguid2"] = villainDeckZoneGUID}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Villain"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Villain") then
            counter = counter + 1
        end
        return counter
    end
end

function setupCounter2()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck then
        return math.abs(vildeck.getQuantity())
    else
        return 0
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    
    broadcastToAll("Scheme Twist: Choose a villain deck to draw two cards from.")
    local decks = {}
    for i,o in pairs(allTopBoardGUIDS) do
        if i > 6 and i < 12 then
            local deck = Global.Call('get_decks_and_cards_from_zone',o)
            if deck[1] then
                table.insert(decks,getObjectFromGUID(o))
            end
        end
    end
    
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = table.clone(decks),
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