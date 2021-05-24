--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()

    self.createButton({
        click_function="click_draw_hero", function_owner=self,
        position={0,0,0}, label="Draw hero", color={1,1,1,0}, width=2000, height=3000
    })

    self.createButton({
         click_function="click_buy_hero", function_owner=self,
         position={0,0.01,4}, label="Buy hero", color={1,1,1,1}, width=2000, height=1000,
         font_size = 250
     })

    --Local positions for each pile of cards
    
    playerBoards = {
        ["Red"]="8a35bd",
        ["Green"]="d7ee3e",
        ["Yellow"]="ed0d43",
        ["Blue"]="9d82f3",
        ["White"]="206c9c"
    }
    
    pos_discard = {-0.957, 0.178, 0.222}
    pos_draw = {0.957, 0.178, 0.222}
    pos_add2 = {-3.15, 0.178, 0.222}
    
    --drawbuyguids
    drawbuyguids = {
        ["Red"]="aabe45",
        ["Green"]="bf3815",
        ["Yellow"]="11b14c",
        ["Blue"]="b8a776",
        ["Silver"]="75241e"
    }
    
    dividedDeckGUIDs = {
        ["Red"]="4c1868",
        ["Green"]="8656c3",
        ["Yellow"]="533311",
        ["Blue"]="3d3ba7",
        ["Silver"]="725c5d"
    }
    hero_deck_zone_guid = "0cd6a9"
    twistpileGUID = "4f53f9"
    kopile_guid = "79d60b"
    for i,o in pairs(drawbuyguids) do
        if o == self.guid then
            divided_deck_guid = dividedDeckGUIDs[i]
        end
    end
    
end

function click_buy_hero(obj, player_clicker_color)
    local card = getHero(false)
    if not card then
        return nil
    end
    
    local desc = card.getDescription()
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    if not schemeParts then
        printToAll("No scheme specified!")
        schemeParts = {"no scheme"}
    end
    
    if desc:find("WALL%-CRAWL") or schemeParts[1] == "Splice Humans With Spider DNA" then
        pos = pos_draw
        card.flip()
    elseif desc:find("SOARING FLIGHT") then
        pos = pos_add2
    else 
        pos = pos_discard
    end
    
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local dest = playerBoard.positionToWorld(pos)
    
    if player_clicker_color == "White" then
        angle = 90
    elseif player_clicker_color == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    
    card.setRotationSmooth(brot)
    card.setPositionSmooth({x=dest.x,y=dest.y+3,z=dest.z})
    
    click_draw_hero()
end

function getHero(face,bs)
    local objects = findObjectsAtPosition({0,0,0})
    if not objects then 
        return nil 
    end
    if not bs then
        bs = false
    end
    local card = nil
    for _,item in pairs(objects) do
        if item.tag == "Card" and item.is_face_down == face and item.hasTag("Bystander") == bs then
            card = item
        elseif item.tag == "Deck" and item.is_face_down == true and face == true then
            card = item
        end
    end
    --log (card)
    if not card then 
        return nil
    end
    return card
end

function getHeroUp()
    return getHero(false)
end

function getHeroDown()
    return getHero(true)
end

function getBystander()
    return getHero(false,true)
end

function click_draw_hero()
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    if not schemeParts then
        printToAll("No scheme specified!")
        schemeParts = {"no scheme"}
    end
    if schemeParts[1] == "Divide and Conquer" then
        deckToDrawGUID = divided_deck_guid
    else
        deckToDrawGUID = hero_deck_zone_guid
    end
    hero_deck = get_decks_and_cards_from_zone(deckToDrawGUID)
    if schemeParts[1] == "Go Back in Time to Slay Heroes' Ancestors" then
        purge = function(obj)
            local purgedheroes = get_decks_and_cards_from_zone(twistpileGUID)
            if purgedheroes[1] then
                if purgedheroes[1].tag == "Deck" then
                    for _,o in pairs(purgedheroes[1].getObjects()) do
                        if o.name == obj.getName() then
                            broadcastToAll("Purged hero " .. obj.getName() .. " KO'd from HQ")
                            obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                            click_draw_hero()
                            break
                        end
                    end
                else
                    if purgedheroes[1].getName() == obj.getName() then
                        broadcastToAll("Purged hero " .. obj.getName() .. " KO'd from HQ")
                        obj.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                        click_draw_hero()
                    end
                end
            end
        end
    else
        purge = nil
    end
    local pos = {self.getPosition().x,self.getPosition().y+5,self.getPosition().z}
    if hero_deck[1] then
        if hero_deck[1].tag == "Deck" then
            takeParams = {
                position = pos,
                flip = hero_deck[1].is_face_down,
                callback_function = purge
            }
            hero_deck[1].takeObject(takeParams)
        else
            hero_deck[1].flip()
            hero_deck[1].setPositionSmooth(pos)
        end
    else
        printToAll("No hero deck found")
    end

end

function findObjectsAtPosition(localPos)
    local globalPos = self.positionToWorld(localPos)
    local objList = Physics.cast({
        origin=globalPos,
        direction={0,1,0},
        type=2,
        size={2,2,2},
        max_distance=1,
        debug=false
    })

    local decksAndCards = {}
    for _, obj in ipairs(objList) do
        if obj.hit_object.tag == "Deck" or obj.hit_object.tag == "Card" then
            table.insert(decksAndCards, obj.hit_object)
        end
    end
    return decksAndCards
end

function get_decks_and_cards_from_zone(zoneGUID)
    local zone = getObjectFromGUID(zoneGUID)
    if zone then
        decks = zone.getObjects()
    else
        return nil
    end
    local result = {}
    if decks then
        for k, deck in pairs(decks) do
            local desc = deck.getDescription()
            if deck.tag == "Deck" or deck.tag == "Card" or deck.getName() == "Shard" then
                table.insert(result, deck)
            end
        end
    end
    return result
end