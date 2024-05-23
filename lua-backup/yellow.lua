--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    global_deal = 0
    global_discarded = 0
    drawqueue = 0
    
    handsize_init = 6
    handsize = handsize_init
    handsizef = false
    
    extraturn = false
    
    boardcolor = self.getName()
    
    vpileguid = nil
    playguid = nil
    addguid = nil
    drawguid = nil
    discardguid = nil
    handguid = nil
    resourceguid = nil
    attackguid = nil

    local guids3 = {
        "vpileguids",
        "playguids",
        "addguids",
        "drawguids",
        "discardguids",
        "handguids",
        "resourceguids",
        "attackguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o:sub(1,-2)] = table.clone(Global.Call('returnVar',o),true)[boardcolor]
    end
    
    local guids1 = {
       "pushvillainsguid",
       "sidekickZoneGUID",
       "setupGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    objectsentering_recruit = {}
    objectsentering_attack = {}
    
    playpos = {1.4 , 2, 7.3}
    
    createButtons()
end

function colorDummy()
end

function updateVar(params)
    _G[params.name] = table_clone(params.value)
end

function onObjectEnterZone(zone,object)
    --log(object.held_by_color)
    if zone.guid == playguid and not object.isSmoothMoving() and (not object.held_by_color or object.held_by_color == boardcolor) then
        if not object.hasTag("Split") and hasTag2(object,"Recruit:") then
            local addRecruit = function()
                local content = get_decks_and_cards_from_zone(playguid)
                if content[1] then
                    for _,o in pairs(content) do
                        if o.guid == object.guid then
                            if not objectsentering_recruit[object.guid] then
                                objectsentering_recruit[object.guid] = true
                                getObjectFromGUID(resourceguid).Call('addValue',hasTag2(object,"Recruit:"))
                                log("Player " .. boardcolor .. "'s recruit increased by " .. hasTag2(object,"Recruit:") .. ".")
                                --objectsentering_recruit[object.guid] = false
                            end
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
        if not object.hasTag("Split") and hasTag2(object,"Attack:") then
            local addRecruit = function()
                local content = get_decks_and_cards_from_zone(playguid)
                if content[1] then
                    for _,o in pairs(content) do
                        if o.guid == object.guid then
                            if not objectsentering_attack[object.guid] then
                                objectsentering_attack[object.guid] = true
                                getObjectFromGUID(attackguid).Call('addValue',hasTag2(object,"Attack:"))
                                log("Player " .. boardcolor .. "'s attack increased by " .. hasTag2(object,"Attack:") .. ".")
                                --objectsentering_attack[object.guid] = false
                            end
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
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
        position={0,0.5,-1.12}, height=200, width=620, color={1,1,1,0},
        tooltip="Shuffle discard pile back into deck"
    })

    self.createButton({
        click_function="click_draw_card", function_owner=self,
        position={5,0.5, 2.1}, height=500,
        width=500, label="Draw", tooltip = "Draw a card", color={0,0.5,1,1},
    })

    self.createButton({
        click_function="click_end_turn", function_owner=self,
        position={0 , 0.5, 2.1}, height=500,
        width=800, label="New Hand", tooltip="Discard hand and cards in play, then draw 6 cards and play card from villain deck", color={1,1,1,1}
    })

    self.createButton({
        click_function="handsizeplus", function_owner=self,
        position={3 , 0.5, 1.9}, height=250,
        width=660, label="Hand Size +1", tooltip="Set hand size to 1 extra card next turn.", 
        color={1,1,1}
    })
    self.createButton({
        click_function="handsizefixed", function_owner=self,
        position={6.5 , 0.5, -0.5}, height=125,
        width=125, label="V", tooltip="Set hand size changes fixed!", 
        color={1,0,0}
    })
    
    self.createButton({
        click_function="handsizemin", function_owner=self,
        position={3 , 0.5, 2.5}, height=250,
        width=660, label="Hand Size -1", tooltip="Set hand size to 1 card less next turn.", 
        color={1,1,1}
    })
    
    self.createButton({
        click_function="calculate_vp", function_owner=self,
        position={6.5 , 0.5, 0.4}, height=500,
        width=500, label="VP", tooltip="Calculate victory points in victory pile", color={1,1,0,1}
    })
    
    self.createButton({
        click_function="play_hand", function_owner=self,
        position=playpos, height=350,
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
    broadcastToColor("Your handsize was permanently reduced by 1!",boardcolor,boardcolor)
end

function calculate_vp_call(params)
    return calculate_vp(params.obj,params.player_clicker_color,params.alt_click,params.warn)
end

function calculate_vp(obj, player_clicker_color, alt_click,warn)
    local vpcontent = get_decks_and_cards_from_zone(vpileguid)
    if vpcontent[2] then
        broadcastToColor("Victory pile is not a single deck!",boardcolor,boardcolor)
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
        if warn == nil then
            broadcastToAll("##Victory Points##",boardcolor)
            broadcastToAll(boardcolor .. " player's current victory points: " .. totalvp,boardcolor)
            if totalbs > 0 then
                broadcastToAll("##",boardcolor)
                broadcastToAll(boardcolor .. " player's current bystander count: " .. totalbs,boardcolor)
            end
            if totalother > 0 then
                broadcastToAll("##",boardcolor)
                broadcastToAll(boardcolor .. " player's other cards in VP: " .. totalother,boardcolor)
            end
            broadcastToAll("##",boardcolor)
        end
        return totalvp,totalbs,totalother
    else
        if warn == nil then
            broadcastToAll(boardcolor .. " player's victory pile is empty!",boardcolor)
        end
        return nil
    end
end

function handsizeplus()
    handsize = handsize + 1
    broadcastToAll("Player " .. boardcolor .. "'s Hand size set to " .. handsize .. " (+1)",boardcolor)
end

function handsizemin()
    handsize = handsize - 1
    broadcastToAll("Player " .. boardcolor .. "'s Hand size set to " .. handsize .. " (-1)",boardcolor)
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
        broadcastToAll(player_clicker_color .. "'s hand size change set to fixed (" .. handsize .. ")!",boardcolor)
    else
        handsizef = false
        self.editButton({index=buttonindex,color = {1,0,0}})
        broadcastToAll(player_clicker_color .. "'s hand size change no longer set to fixed (" .. handsize .. ")!",boardcolor)
    end
end

function play_hand()
    local hand = Player[boardcolor].getHandObjects()
    local xshift = -4

    if hand[1] then
        for _,o in pairs(hand) do
            o.setPosition(self.positionToWorld({xshift-3,0.1,6}))
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
        for _,o in pairs(discardItemList[1].getObjects()) do
            if objectsentering_attack[o.guid] then
                objectsentering_attack[o.guid] = nil
            elseif objectsentering_recruit[o.guid] then
                objectsentering_recruit[o.guid] = nil
            end
        end
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
        broadcastToAll("deck not found")
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

function tuckSidekicks(cardtable)
    local newcardtable = {}
    local sidekickdeck = get_decks_and_cards_from_zone(sidekickZoneGUID)[1]
    local bumped = false
    for _,o in pairs(cardtable) do
        if o.hasTag("Sidekick") then
            if not bumped then
                Global.Call('bump',{obj = sidekickdeck,y = 4})
                bumped = true
            end
            o.flip()
            sidekickdeck.putObject(o)
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
    if discard[2] then
        log(discard[2])
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
            toadd.takeObject({position = pos,
                smooth = true})
        end
        toadd.remainder.setPositionSmooth(pos)
    elseif toadd then
        toadd.setPositionSmooth(pos)
    end
    if handsizef == false then
        if handsize ~= handsize_init then
            broadcastToAll(boardcolor .. "'s hand size set back to " .. handsize_init .. " after extra draws!")
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
    local autoplay = getObjectFromGUID(setupGUID).Call('returnVar',"autoplay")
    if boardcolor == Turns.turn_color then
        if autoplay == true then
            getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
            broadcastToAll("Next Turn! Villain card played from villain deck.",{1,0,0})
            if not extraturn then
                Turns.turn_color = Turns.getNextTurnColor()
            else
                extraturn = false
            end
        end
    getObjectFromGUID(resourceguid).Call('reset_val')
    getObjectFromGUID(attackguid).Call('reset_val')
    objectsentering_attack = {}
    objectsentering_recruit = {}
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