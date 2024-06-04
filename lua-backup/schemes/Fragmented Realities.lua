function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistPileGUID",
        "villainDeckZoneGUID",
        "setupGUID",
        "kopile_guid"
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

function nonCityZone(obj,player_clicker_color)
    broadcastToColor("This city zone does not currently exist!",player_clicker_color)
end

function customCity(params)
    for i,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
        local zone = getObjectFromGUID(o)
        if zone.hasTag(params.player_clicker_color) then
            villain_deck_zone = i
            break
        end
    end
    return {city_zones_guids[1],city_zones_guids[6-villain_deck_zone+1]}
end

function villainDeckSpecial(params)
    local topCityZones = table.clone(topBoardGUIDs)
    table.remove(topCityZones)
    table.remove(topCityZones,1)
    table.remove(topCityZones,1)
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,7 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    local playercount = #Player.getPlayers()
    local vildeckc2 = params.vildeckc + playercount*2
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
    local vilDeckComplete = function()
        local test = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
        if test and test.getQuantity() == vildeckc2 then
            return true
        else
            return false
        end
    end   
    local vilDeckSplit = function() 
        log("Splitting villain deck in deck for each player")
        local vilDeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
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
        log("Villain deck split in piles above the board!")
    end
    local decksShuffle = function()
        for i=1,5 do
            if i > 5 - playercount then
                local deck = Global.Call('get_decks_and_cards_from_zone',topCityZones[i])[1]
                local zone = getObjectFromGUID(topCityZones[i])
                deck.randomize()
                local color = Player.getPlayers()[6-i].color
                deck.addTag(color)
                zone.addTag(color)
                zone.createButton({click_function='returnColor',
                    function_owner=getObjectFromGUID(setupGUID),
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
            local deck = Global.Call('get_decks_and_cards_from_zone',topCityZones[i])[1]
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
end

function setupCounter(init)
    if init then
        local playercounter = 5*#Player.getPlayers()
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd nongrey heroes: __/" .. playercounter .. "."}
    else 
        local escaped = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if escaped[1] then
            local counter = 0
            for _,o in pairs(escaped) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "HC:",find=true})
                    if escapees then
                        counter = counter + #escapees
                    end
                elseif hasTag2(o,"HC:") then
                    counter = counter + 1
                end
            end
            return counter
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    
    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    local villain_deck_zone = nil
    for _,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
        local zone = getObjectFromGUID(o)
        if zone.hasTag(Turns.turn_color) then
            villain_deck_zone = o
            break
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,vildeckguid=villain_deck_zone})
    return nil
end