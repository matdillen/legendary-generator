function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID"
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
    local subcount = 1
    while subcount > 0 do
        local hqZoneGUID = table.remove(topCityZones)
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
                getObjectFromGUID(allTopBoardGUIDS[i]).createButton({click_function='click_draw_villain',
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
    Wait.time(decksShuffle,2)
end

function click_draw_villain(obj)
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{vildeckguid = obj.guid})
end

function playTwoFamily(params)
    local obj = params.obj
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,vildeckguid = obj.guid})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    broadcastToAll("Scheme Twist: Choose a villain deck to draw two cards from.")
    local decks = {}
    for _,o in pairs(allTopBoardGUIDS) do
        local deck = Global.Call('get_decks_and_cards_from_zone',o)
        if deck[1] then
            for _,b in pairs(getObjectFromGUID(o).getButtons()) do
                if b.click_function == "click_draw_villain" then
                    table.insert(decks,getObjectFromGUID(o))
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