--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    setupGUID = "912967"
    global_deal=0
    createButtons()

    handsize_init = 6
    handsize = handsize_init
    handsizef = false
    
    boardcolor = self.getName()
    vpileguid = callGUID("vpileguids",3)[boardcolor]
    playguid = callGUID("playguids",3)[boardcolor]
    addguid = callGUID("addguids",3)[boardcolor]
    attackguid = callGUID("attackguids",3)[boardcolor]
    resourceguid = callGUID("resourceguids",3)[boardcolor]
    
    pos_vp2 = callGUID("pos_vp2",2)
    pos_discard = callGUID("pos_discard",2)
    pos_draw = callGUID("pos_draw",2)
    pos_add2 = callGUID("pos_add2",2)
    
    sidekickDeckGUID = callGUID("sidekickDeckGUID",1)
    
    objectsentering_recruit = {}
    objectsentering_attack = {}
end

function colorDummy()
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

function onObjectEnterZone(zone,object)
    --log(object.held_by_color)
    if zone.guid == playguid and not object.isSmoothMoving() and (not object.held_by_color or object.held_by_color == boardcolor) then
        if hasTag2(object,"Recruit:") then
            if not objectsentering_recruit[object.guid] then
                objectsentering_recruit[object.guid] = true
                local addRecruit = function()
                    local content = get_decks_and_cards_from_zone(playguid)
                    if content[1] then
                        for _,o in pairs(content) do
                            if o.guid == object.guid then
                                local value = getObjectFromGUID(resourceguid).getButtons()[1].label
                                value = value + hasTag2(object,"Recruit:")
                                getObjectFromGUID(resourceguid).editButton({index=0,label=value})
                                log("Player " .. boardcolor .. "'s recruit increased by " .. value .. ".")
                                objectsentering_recruit[object.guid] = false
                                break
                            end
                        end  
                    end
                end
                local cardLoose = function()
                    if not object.held_by_color then
                        return true
                    else
                        return false
                    end
                end
                Wait.condition(addRecruit,cardLoose)
            end
        end
        if hasTag2(object,"Attack:") then
            if not objectsentering_attack[object.guid] then
                objectsentering_attack[object.guid] = true
                local addRecruit = function()
                    local content = get_decks_and_cards_from_zone(playguid)
                    if content[1] then
                        for _,o in pairs(content) do
                            if o.guid == object.guid then
                                local value = getObjectFromGUID(attackguid).getButtons()[1].label
                                value = value + hasTag2(object,"Attack:")
                                getObjectFromGUID(attackguid).editButton({index=0,label=value})
                                log("Player " .. boardcolor .. "'s attack increased by " .. value .. ".")
                                objectsentering_attack[object.guid] = false
                                break
                            end
                        end  
                    end
                    
                end
                local cardLoose = function()
                    if not object.held_by_color then
                        return true
                    else
                        return false
                    end
                end
                Wait.condition(addRecruit,cardLoose)
            end
        end
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

function createButtons()
    self.createButton({
        click_function="click_refillDeck", function_owner=self,
        position={0,0.1,-1.12}, height=200, width=620, color={1,1,1,0},
        tooltip="Shuffle discard pile back into deck"
    })

    self.createButton({
        click_function="click_draw_card", function_owner=self,
        position={5, 0.178, 2.1}, height=500,
        width=500, label="Draw", tooltip = "Draw a card", color={0,0.5,1,1},
    })

    self.createButton({
        click_function="click_end_turn", function_owner=self,
        position={0 , 0.178, 2.1}, height=500,
        width=800, label="New Hand", tooltip="Discard hand and cards in play, then draw 6 cards and play card from villain deck", color={1,1,1,1}
    })

    self.createButton({
        click_function="handsizeplus", function_owner=self,
        position={3 , 0.178, 1.9}, height=250,
        width=660, label="Hand Size +1", tooltip="Set hand size to 1 extra card next turn.", 
        color={1,1,1}
    })
    self.createButton({
        click_function="handsizefixed", function_owner=self,
        position={6.5 , 0.178, -0.5}, height=125,
        width=125, label="V", tooltip="Set hand size changes fixed!", 
        color={1,0,0}
    })
    
    self.createButton({
        click_function="handsizemin", function_owner=self,
        position={3 , 0.178, 2.5}, height=250,
        width=660, label="Hand Size -1", tooltip="Set hand size to 1 card less next turn.", 
        color={1,1,1}
    })
    
    self.createButton({
        click_function="calculate_vp", function_owner=self,
        position={6.5 , 0.178, 0.4}, height=500,
        width=500, label="VP", tooltip="Calculate victory points in victory pile", color={1,1,0,1}
    })

end

function onslaughtpain(defeated)
    if defeated then
        handsize_init = handsize_init + 1
    else
        handsize_init = handsize_init - 1
    end
    handsize = handsize_init
    broadcastToAll("Handsize permanently reduced by 1!",{1,0,0})
end

function calculate_vp()
    local vpcontent = get_decks_and_cards_from_zone(vpileguid)
    if vpcontent[2] then
        printToColor("Victory pile is not a single deck!",boardcolor,boardcolor)
        return nil
    end
    if vpcontent[1] then
        local totalvp = 0
        local totalbs = 0
        local totalother = 0
        if math.abs(vpcontent[1].getQuantity()) > 1 then
            for _,o in pairs(vpcontent[1].getObjects()) do
                local vpfound = false
                for _,k in pairs(o.tags) do
                    if k:match("VP%d+") then
                        totalvp = totalvp + k:match("%d+")
                        vpfound = true
                    end
                    if k == "Bystander" then
                        totalbs = totalbs + 1
                    end
                end
                if vpfound == false then
                    totalother = totalother + 1
                end
            end
        else 
            local vpfound = false
            for _,o in pairs(vpcontent[1].getTags()) do
                if o:match("VP%d+") then
                    totalvp = totalvp + o:match("%d+")
                    vpfound = true
                end
                if o == "Bystander" then
                    totalbs = totalbs + 1
                end
            end
            if vpfound == false then
                totalother = totalother + 1
            end
        end
        printToAll("##Victory Points##",boardcolor)
        printToAll(boardcolor .. " player's current victory points: " .. totalvp,boardcolor)
        if totalbs > 0 then
            printToAll("##",boardcolor)
            printToAll(boardcolor .. " player's current bystander count: " .. totalbs,boardcolor)
        end
        if totalother > 0 then
            printToAll("##",boardcolor)
            printToAll(boardcolor .. " player's other cards in VP: " .. totalother,boardcolor)
        end
        printToAll("##",boardcolor)
        return totalvp,totalbs,totalother
    else
        printToAll(boardcolor .. " player's victory pile is empty!",boardcolor)
        return nil
    end
end

function handsizeplus()
    handsize = handsize + 1
    printToAll("Player " .. boardcolor .. "'s Hand size set to " .. handsize .. " (+1)",boardcolor)
end

function handsizemin()
    handsize = handsize - 1
    printToAll("Player " .. boardcolor .. "'s Hand size set to " .. handsize .. " (-1)",boardcolor)
end

function handsizefixed(obj,player_clicker_color)
    local butt = self.getButtons()
    for _,o in pairs(butt) do
        if o.click_function == "handsizefixed" then
            buttonindex = o.index
        end
    end
    if handsizef == false then
        handsizef = true
        self.editButton({index=buttonindex,color = {0,1,0}})
        printToAll(player_clicker_color .. "'s hand size change set to fixed (" .. handsize .. ")!",boardcolor)
    else
        handsizef = false
        self.editButton({index=buttonindex,color = {1,0,0}})
        printToAll(player_clicker_color .. "'s hand size change no longer set to fixed (" .. handsize .. ")!",boardcolor)
    end
end

function click_refillDeck()
    global_deal = 0
    refillDeck()
end

function refillDeck()
    local discardItemList = findObjectsAtPosition(pos_discard)
    local pos = self.positionToWorld(pos_draw)
    local rot = self.getRotation()
    rot.z = rot.z+180
    for _, obj in ipairs(discardItemList) do
        obj.setPosition(pos, false, true)
        obj.setRotation(rot)
    end

    if discardItemList[1] then
        Wait.condition(timer_shuffle,
            function()
                local found = findObjectsAtPosition(pos_draw)
                return #found == 1
            end ,
            5.0,
            function()
                print("auto-refill timeout")
            end
        )
    end
end

--Activated by a timer to shuffle deck
function timer_shuffle()
    local deck = findObjectsAtPosition(pos_draw)
    if not deck[1] then
        printToAll("deck not found")
        return nil
    end
    if deck[2] then
        printToAll("More than one deck found?")
        return nil
    end
    deck[1].randomize()
    local count=math.abs(deck[1].getQuantity())
    if count > 0 then
        deck[1].deal(global_deal,boardcolor)
        global_deal=0
    end
end

function tuckSidekicks(cardtable)
    for i,o in pairs(cardtable) do
        if o.hasTag("Sidekick") then
            o.flip()
            o.setPositionSmooth(getObjectFromGUID(sidekickDeckGUID).getPosition())
            table.remove(cardtable,i)
        end
    end
    return cardtable
end

-- discard all card in hand and played
function click_discard_hand()
    local cards = Player[boardcolor].getHandObjects()
    if not cards then 
        cards = {} 
    end
    local played_cards = get_decks_and_cards_from_zone(playguid)
    log(played_cards)
    if played_cards then
        played_cards = tuckSidekicks(played_cards)
        cards_all = merge(cards,played_cards)
    end
    local pos = self.positionToWorld(pos_discard)
    for _, card in ipairs(cards_all) do
        card.setPosition(pos, false, true)
    end
end

function click_deal_cards()
    local decks = findObjectsAtPosition(pos_draw)
    local toadd = get_decks_and_cards_from_zone(addguid)
    local todraw = handsize
    if toadd[1] then
        local count = math.abs(toadd[1].getQuantity())
        toadd[1].deal(count,boardcolor)
    end
    if handsizef == false then
        if handsize ~= handsize_init then
            printToAll(boardcolor .. "'s hand size set back to " .. handsize_init .. " after extra draws!")
            handsize = handsize_init
        end
    end
    if not decks[1] then
        global_deal = todraw
        refillDeck()
        return nil
    end
    local count = math.abs(decks[1].getQuantity())
    decks[1].deal(math.min(todraw,count),boardcolor)
    if count < todraw then
        global_deal=todraw-count
        refillDeck()
    end
end

function click_draw_cards(n)
    local cards = Player[boardcolor].getHandObjects()
    local decks = findObjectsAtPosition(pos_draw)
    if not decks[1] then
        global_deal = n
        refillDeck()
        return nil
    end
    local count = math.abs(decks[1].getQuantity())
    decks[1].deal(math.min(n,count),boardcolor)
    if count < n then
        global_deal = n-count
        refillDeck()
    end
end

function isDiscardDone()
    local cards = Player[boardcolor].getHandObjects()
    if not cards then cards = {} end
    local played_cards = get_decks_and_cards_from_zone(playguid)
    if played_cards then
        played_cards = tuckSidekicks(played_cards)
    end
    return ((cards and #cards == 0) or (cards == nil)) and
        ((played_cards and #played_cards == 0) or (played_cards == nil))
end

function isHandFull()
    local cards = Player[boardcolor].getHandObjects()
    return cards and ( #cards == handsize )
end

function click_end_turn()
    global_deal=0
    click_discard_hand()
    Wait.condition(click_deal_cards,isDiscardDone,3,function() print("discard timeout") end)
    local autoplay = callGUID("autoplay",1)
    if boardcolor == Turns.turn_color then
        if autoplay == true then
            getObjectFromGUID("8280ca").Call('click_draw_villain')
            broadcastToAll("Next Turn! Villain card played from villain deck.",{1,0,0})
        end
    getObjectFromGUID(resourceguid).editButton({index=0,label=0})
    getObjectFromGUID(attackguid).editButton({index=0,label=0})
    end
end

function click_draw_card()
    local cards = Player[boardcolor].getHandObjects()
    local decks = findObjectsAtPosition(pos_draw)
    if not decks[1] then
        global_deal = 1
        refillDeck()
        return nil
    end
    decks[1].deal(1,boardcolor)
end

function findObjectsAtPosition(localPos)
    local globalPos = self.positionToWorld(localPos)
    local objList = Physics.cast({
        origin=globalPos, --Where the cast takes place
        direction={0,1,0}, --Which direction it moves (up is shown)
        type=2, --Type. 2 is "sphere"
        size={2,2,2}, --How large that sphere is
        max_distance=1, --How far it moves. Just a little bit
        debug=false --If it displays the sphere when casting.
    })
    local decksAndCards = {}
    for _, obj in ipairs(objList) do
        if obj.hit_object.tag == "Deck" or obj.hit_object.tag == "Card" then
            table.insert(decksAndCards, obj.hit_object)
        end
    end
    return decksAndCards
end

function merge(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end
   return t1
end

function returnDiscardPile()
    local discard = findObjectsAtPosition(pos_discard)
    return discard
end

function returnDeck()
    local deck = findObjectsAtPosition(pos_draw)
    return deck
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
            if deck.type == "Deck" or deck.type == "Card" then
                local desc = deck.getDescription()
                if not desc:find("ARTIFACT") then
                    table.insert(result, deck)
                end
            end
        end
    end
    return result
end