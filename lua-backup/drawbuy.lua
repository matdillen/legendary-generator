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

    setupGUID = "912967"
    
    local guids3 = {
        "playerBoards"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "pos_add2",
       "pos_discard",
       "pos_draw",
       "hqguids",
       "hqscriptguids",
       "allTopBoardGUIDS"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = callGUID(o,2)
    end
        
    local guids1 = {
        "heroDeckZoneGUID",
        "kopile_guid",
        "twistPileGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = callGUID(o,1)
    end
    
    for i,o in pairs(hqguids) do
        if o == self.guid then
            divided_deck_guid = allTopBoardGUIDS[i+6]
            scriptguid = hqscriptguids[i]
        end
    end
    
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
    
    if desc:find("WALL%-CRAWL") or schemeParts[1] == "Splice Humans with Spider DNA" then
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
    local objects = get_decks_and_cards_from_zone(scriptguid)
    local card = nil
    for _,item in pairs(objects) do
        if item.tag == "Card" and item.is_face_down == face and (not bs or item.hasTag(bs)) then
            card = item
        elseif item.tag == "Deck" and item.is_face_down == true and face == true and (not bs or item.hasTag(bs)) then
            card = item
        end
    end
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
    return getHero(false,"Bystander")
end

function getWound()
    return getHero(false,"Wound")
end

function getCards()
    local objects = get_decks_and_cards_from_zone(scriptguid)
    return objects
end

function tuckHero()
    local hero = getHero(false)
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    if not schemeParts then
        printToAll("No scheme specified!")
        schemeParts = {"no scheme"}
    end
    if schemeParts[1] == "Divide and Conquer" then
        deckToDrawGUID = divided_deck_guid
    else
        deckToDrawGUID = heroDeckZoneGUID
    end
    if hero then
        hero.setPosition(getObjectFromGUID(deckToDrawGUID).getPosition())
        click_draw_hero()
    end
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
        deckToDrawGUID = heroDeckZoneGUID
    end
    hero_deck = get_decks_and_cards_from_zone(deckToDrawGUID)
    if schemeParts[1] == "Go Back in Time to Slay Heroes' Ancestors" then
        purge = function(obj)
            local purgedheroes = get_decks_and_cards_from_zone(twistPileGUID)
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