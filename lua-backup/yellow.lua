--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    setupGUID = "912967"
    global_deal = 0
    global_discarded = 0
    drawqueue = 0
    
    handsize_init = 6
    handsize = handsize_init
    handsizef = false
    
    
    boardcolor = self.getName()
    vpileguid = callGUID("vpileguids",3)[boardcolor]
    playguid = callGUID("playguids",3)[boardcolor]
    addguid = callGUID("addguids",3)[boardcolor]
    attackguid = callGUID("attackguids",3)[boardcolor]
    resourceguid = callGUID("resourceguids",3)[boardcolor]
    drawguid = callGUID("drawguids",3)[boardcolor]
    discardguid = callGUID("discardguids",3)[boardcolor]
    handguid = callGUID("handguids",3)[boardcolor]
    
    sidekickDeckGUID = callGUID("sidekickDeckGUID",1)
    pushvillainsguid = callGUID("pushvillainsguid",1)
    
    objectsentering_recruit = {}
    objectsentering_attack = {}
    
    playpos = {
        ["Red"]={-0.7,2,7.3},
        ["Green"]={0,2,7.3},
        ["Yellow"]={1.15 , 2, 7.3},
        ["Blue"]={1.15,2,7.45},
        ["White"]={1.35,2,7.8}
        }
    
    createButtons()
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
                                getObjectFromGUID(resourceguid).Call('addValue',hasTag2(object,"Recruit:"))
                                log("Player " .. boardcolor .. "'s recruit increased by " .. hasTag2(object,"Recruit:") .. ".")
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
                                getObjectFromGUID(attackguid).Call('addValue',hasTag2(object,"Attack:"))
                                log("Player " .. boardcolor .. "'s attack increased by " .. hasTag2(object,"Attack:") .. ".")
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
    
    self.createButton({
        click_function="play_hand", function_owner=self,
        position=playpos[boardcolor], height=350,
        width=400, label="Play", tooltip="Play all cards from your hand.", color=boardcolor
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

function play_hand()
    local hand = Player[boardcolor].getHandObjects()
    local zshift = 0
    if boardcolor == "White" or boardcolor == "Blue" then
        zshift = -0.5
    end
    if hand[1] then
        local xshift = 0
        for _,o in pairs(hand) do
            o.setPosition(self.positionToWorld({xshift-3+zshift,0.1,6}))
            xshift = xshift + 1
        end
    end
end

function click_refillDeck()
    global_deal = 0
    refillDeck()
end

function refillDeck()
    local discardItemList = get_decks_and_cards_from_zone(discardguid)
    --log("discardpile:")
    --log(discardItemList)
    local pos = getObjectFromGUID(drawguid).getPosition()
    local rot = self.getRotation()
    rot.z = rot.z+180
    for _, obj in pairs(discardItemList) do
        obj.setPosition(pos)
        obj.setRotation(rot)
    end
    hardstop = nil
    if discardItemList[1] then
        Wait.condition(timer_shuffle,
            function()
                local found = get_decks_and_cards_from_zone(drawguid)
                if found[1] and found[1].getQuantity() == discardItemList[1].getQuantity() then
                    return true
                else
                    return false
                end
            end)
    end
end

--Activated by a timer to shuffle deck
function timer_shuffle(hardstop)
    local deck = get_decks_and_cards_from_zone(drawguid)
    if not deck[1] then
        printToAll("deck not found")
        return nil
    end
    if deck[2] and not hardstop then
        hardstop = true
        Wait.time(timer_shuffle,0.5)
        return nil
    end
    deck[1].randomize()
    local count=math.abs(deck[1].getQuantity())
    if count > 0 then
        click_draw_cards(global_deal)
        global_deal=0
    end
end

function bump(obj,y)
    if not y then
        y = 2
    end
    local pos = obj.getPosition()
    pos.y = pos.y + y
    obj.setPositionSmooth(pos)
end

function tuckSidekicks(cardtable)
    local newcardtable = {}
    getObjectFromGUID(pushvillainsguid).Call('bump',getObjectFromGUID(sidekickDeckGUID))
    for _,o in pairs(cardtable) do
        if o.hasTag("Sidekick") then
            o.flip()
            o.setPositionSmooth(getObjectFromGUID(sidekickDeckGUID).getPosition())
        else
            table.insert(newcardtable,o)
        end
    end
    return newcardtable
end

-- discard all card in hand and played
function click_discard_hand()
    local cards = Player[boardcolor].getHandObjects()
    if not cards then 
        cards = {} 
    end
    local played_cards = get_decks_and_cards_from_zone(playguid,true)
    local discard = get_decks_and_cards_from_zone(discardguid)
    local discardcount = 0
    if discard[1] then
        discardcount = math.abs(discard[1].getQuantity())
    end
    --log(played_cards)
    if played_cards then
        played_cards = tuckSidekicks(played_cards)
        cards_all = merge(cards,played_cards)
    end
    local pos = getObjectFromGUID(discardguid).getPosition()
    
    global_discarded = #cards_all + discardcount
    for _, card in pairs(cards_all) do
        card.setPosition(pos)
    end
end

function click_deal_cards()
    local toadd = get_decks_and_cards_from_zone(addguid)[1]
    local todraw = handsize
    local pos = getObjectFromGUID(handguid).getPosition()
    if toadd and toadd.tag == "Deck" then
        for i = 1,toadd.getQuantity()-1 do
            toadd[1].takeObject({position = pos,
                smooth = true})
        end
        toadd[1].remainder.setPositionSmooth(pos)
    elseif toadd then
        toadd[1].setPositionSmooth(pos)
    end
    if handsizef == false then
        if handsize ~= handsize_init then
            printToAll(boardcolor .. "'s hand size set back to " .. handsize_init .. " after extra draws!")
            handsize = handsize_init
        end
    end
    click_draw_cards(todraw)
end

function isDiscardDone()
    local discarded = get_decks_and_cards_from_zone(discardguid)[1]
    if global_discarded == 0 or (discarded and math.abs(discarded.getQuantity()) == global_discarded) then
        return true
    else
        return false
    end
end

function click_end_turn()
    global_deal=0
    click_discard_hand()
    Wait.condition(click_deal_cards,isDiscardDone)
    local autoplay = callGUID("autoplay",1)
    if boardcolor == Turns.turn_color then
        if autoplay == true then
            getObjectFromGUID("8280ca").Call('click_draw_villain')
            broadcastToAll("Next Turn! Villain card played from villain deck.",{1,0,0})
            Turns.turn_color = Turns.getNextTurnColor()
        end
    getObjectFromGUID(resourceguid).Call('reset_val')
    getObjectFromGUID(attackguid).Call('reset_val')
    end
end

function click_draw_card()
    drawqueue = drawqueue + 1
    if drawqueue > 1 then
        Wait.time(click_draw_card,drawqueue/5)
        drawqueue = drawqueue - 1
        return nil
    else
        Wait.time(function() drawqueue = drawqueue - 1 end,0.2)
    end
    click_draw_cards(1)
end

function click_draw_cards(n)
    if not n or n < 1 then
        return nil
    end
    local decks = get_decks_and_cards_from_zone(drawguid)
    if not decks[1] then
        global_deal = n
        refillDeck()
        return nil
    end
    local count = math.abs(decks[1].getQuantity())
    local pos = getObjectFromGUID(handguid).getPosition()
    if decks[1].tag == "Deck" then
        for i = 1,math.min(n,count-1) do
            decks[1].takeObject({position = pos,
                flip = true,
                smooth = true})
        end
        if decks[1].remainder then
            decks[1] = decks[1].remainder
        end
        if count <= n then
            decks[1].flip()
            decks[1].setPositionSmooth(pos)
            if count < n then
                global_deal = n-count
                refillDeck()
            end
        end
    else
        decks[1].flip()
        decks[1].setPositionSmooth(pos)
        if n > 1 then
            global_deal = n-count
            refillDeck()
        end
    end
end

function merge(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end
   return t1
end

function returnDiscardPile()
    local discard = get_decks_and_cards_from_zone(discardguid)
    return discard
end

function returnDeck()
    local deck = get_decks_and_cards_from_zone(drawguid)
    return deck
end

function get_decks_and_cards_from_zone(zoneGUID,exclArtifact)
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
                if not exclArtifact or not desc:find("ARTIFACT") then
                    table.insert(result, deck)
                end
            end
        end
    end
    return result
end