--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()

    self.createButton({
        click_function="click_draw_hero", function_owner=self,
        position={0,0,0}, label="Draw hero", color={1,1,1,0}, width=2000, height=3000
    })

    toggleButton()
    
    local guids3 = {
        "playerBoards",
        "resourceguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
        
    local guids1 = {
        "heroDeckZoneGUID",
        "kopile_guid",
        "twistZoneGUID",
        "pushvillainsguid",
        "setupGUID",
        "shardspaceguid",
        "madamehydrazoneguid",
        "recruitszoneguid"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    for i,o in pairs(hqguids) do
        if o == self.guid then
            divided_deck_guid = allTopBoardGUIDS[i+6]
            scriptguid = hqscriptguids[i]
        end
    end
    if not scriptguid then
        local pos = self.getPosition()
        if pos.z < 5 then
            scriptguid = shardspaceguid
        elseif pos.x < -16 then
            scriptguid = madamehydrazoneguid
        else
            scriptguid = recruitszoneguid
        end
    end
end

function toggleButton()
    for i,b in pairs(self.getButtons()) do
        if b.click_function == "click_buy_hero" then
            self.removeButton(i - 1)
            return nil
        end
    end
    self.createButton({
         click_function="click_buy_hero", function_owner=self,
         position={0,0.01,4}, label="Buy hero", color={1,1,1,1}, width=2000, height=1000,
         font_size = 250
    })
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function click_buy_hero(obj, player_clicker_color)
    local card = getHero(false,nil,true)
    if not card then
        return nil
    end
    
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    local cost = hasTag2(card,"Cost:") or 0
    if recruit < cost then
        broadcastToColor("You don't have enough recruit to buy this hero!",player_clicker_color,player_clicker_color)
        return nil
    else
        getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-cost)
        local desc = card.getDescription()
        local schemeParts = getObjectFromGUID(setupGUID).Call('returnSetupParts')
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
        card.setPositionSmooth({x=dest.x,y=dest.y+3,z=dest.z})
        
        click_draw_hero()
    end
end

function getHero(face,bs,hero)
    local objects = get_decks_and_cards_from_zone(scriptguid)
    local card = nil
    for _,item in pairs(objects) do
        if hero and hasTag2(item,"HC:") then
            card = item
            break
        end
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
    return getHero(false,nil,true)
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
    if not scheme then
        scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
    end
    if scheme.getName() == "Divide and Conquer" then
        deckToDrawGUID = divided_deck_guid
    else
        deckToDrawGUID = heroDeckZoneGUID
    end
    hero_deck = get_decks_and_cards_from_zone(deckToDrawGUID)
    if not hero_deck[1] then
        return nil
    end
    local flip = hero_deck[1].is_face_down
    if scheme.getName() == "Inescapable \"Kyln\" Space Prison" then
        flip = not flip
    end
    if scheme.getName() == "Go Back in Time to Slay Heroes' Ancestors" then
        purge = function(obj)
            local purgedheroes = get_decks_and_cards_from_zone(twistZoneGUID)
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
    elseif scheme.getName() == "Inescapable \"Kyln\" Space Prison" then
        purge = function()
            scheme.Call('imprison')
        end
    else
        purge = nil
    end
    local pos = {self.getPosition().x,self.getPosition().y+5,self.getPosition().z}
    if hero_deck[1] then
        if hero_deck[1].tag == "Deck" then
            takeParams = {
                position = pos,
                flip = flip,
                callback_function = purge
            }
            hero_deck[1].takeObject(takeParams)
        else
            if flip then
                hero_deck[1].flip()
            end
            hero_deck[1].setPositionSmooth(pos)
        end
    else
        printToAll("No hero deck found")
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return Global.Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end