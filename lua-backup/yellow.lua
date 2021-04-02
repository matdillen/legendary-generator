handsize = 6
boardcolor = self.getName()
--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    global_refill_done=false
    global_deal=0
    countEnd=0
    countStart=0
    pos_discard = {-0.957, 0.178, 0.222}
    pos_draw = {0.957, 0.178, 0.222}
	pos_vp = {3.828, 0.178, 0.222}
	pos_vp2 = {-4.8, 0.178, 0.222}
	pos_add = {2.871, 0.178, 0.222}
	pos_add2 = {-2.871, 0.178, 0.222}
	createButtons()
    --This is which way is face down for a card or deck relative to the tool
    rot_offset = {x=0, y=0, z=180}
end

function createButtons()
    self.createButton({
        click_function="click_refillDeck", function_owner=self,
        position={0,0.1,-1.12}, height=200, width=620, color={1,1,1,0}
    })

    self.createButton({
        click_function="click_draw_card", function_owner=self,
        position={5, 0.178, 2.3}, height=500,
        width=500, label="Draw", color={0,0,1,1},
    })

    self.createButton({
        click_function="click_end_turn", function_owner=self,
        position={3.5 , 0.178, 2.3}, height=500,
        width=800, label="New Hand", tooltip="discard hand, and played cards,and draw 6 cards to current player", color={0,1,0,1}
    })

    self.createButton({
        click_function="handsizeplus", function_owner=self,
        position={-1 , 0.178, 2.3}, height=250,
        width=660, label="Hand Size +1", tooltip="Set hand size to 1 extra card.", 
        color={1,0,0}
    })
    self.createButton({
        click_function="handsizemin", function_owner=self,
        position={1 , 0.178, 2.3}, height=250,
        width=660, label="Hand Size -1", tooltip="Set hand size to 1 card less.", 
        color={1,0,0}
    })
	self.createButton({
        click_function="calculate_vp", function_owner=self,
        position={6.5 , 0.178, 0.4}, height=500,
        width=500, label="VP", tooltip="Calculate victory points in victory pile", color={1,1,0,1}
    })
	-- self.createButton({
        -- click_function="donutting", function_owner=self,
        -- position=pos_add, height=1250,
        -- width=660, label="add", tooltip="add", 
        -- color={1,0,0}
    -- })

end

function donutting()
end

function calculate_vp()
	vpraw = findObjectsAtPosition(pos_vp2)
	local vpcards = nil
	--log(pos_add)
	--log(adds.tag)
	if vpraw.tag=="Deck" or vpraw.tag=="Card" then
		vpcards = vpraw
	elseif vpraw[1] and (vpraw[1].tag=="Deck" or vpraw[1].tag=="Card") then
			vpcards = vpraw[1]
	end
	if vpcards then
	totalvp = 0
		if vpcards.getQuantity() > 1 then
			for i = 1,vpcards.getQuantity() do
				tags = vpcards.getObjects()[i].tags
				for j,o in pairs(tags) do
					if o:match("VP%d+") then
						totalvp = totalvp + o:match("%d+")
					end
				end
			end
			print(self.getName() .. " player's current victory points: " .. totalvp)
		elseif vpcards.getQuantity() == -1 then
			tags = vpcards.getTags()
			for j,o in pairs(tags) do
				if o:match("VP%d+") then
					totalvp = totalvp + o:match("%d+")
				end
			end
			print(self.getName() .. " player's current victory points: " .. totalvp)
		end
	end
end

function handsizeplus()
    handsize = handsize + 1
    print("Player " .. boardcolor .. "'s Hand size set to " .. handsize .. " (+1)")
end

function handsizemin()
    handsize = handsize - 1
    print("Player " .. boardcolor .. "'s Hand size set to " .. handsize .. " (-1)")
end

function click_refillDeck()
    global_deal = 0
    refillDeck()
end

function refillDeck()
    global_refill_done=false

    local discardItemList = findObjectsAtPosition(pos_discard)
    local pos = self.positionToWorld(pos_draw)
    local rot = self.getRotation()
    rot = {rot.x+rot_offset.x, rot.y+rot_offset.y, rot.z+rot_offset.z}

    for _, obj in ipairs(discardItemList) do
        obj.setPosition(pos, false, true)
        obj.setRotation(rot)
    end

    if #discardItemList > 0 then
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
    else
        global_refill_done=true
    end
end

function findObjectsAtPosition(localPos)
    local globalPos = self.positionToWorld(localPos)
	--log(globalPos)
    local objList = Physics.cast({
        origin=globalPos, --Where the cast takes place
        direction={0,1,0}, --Which direction it moves (up is shown)
        type=2, --Type. 2 is "sphere"
        size={2,2,2}, --How large that sphere is
        max_distance=1, --How far it moves. Just a little bit
        debug=false --If it displays the sphere when casting.
    })

    --Now we have objList which contains any and all objects in that area.
    --But we only want decks and cards. So we will create a new list
    local decksAndCards = {}
    --Then go through objList adding any decks/cards to our new list
    for _, obj in ipairs(objList) do
        if obj.hit_object.tag == "Deck" or obj.hit_object.tag == "Card" then
            --log("findObjectsAtPosition: found")
            --log(obj.hit_object)
            --log(obj.hit_object.tag)
            table.insert(decksAndCards, obj.hit_object)
        end
    end

    --Now we return this to where it was called with the information
    ---- log ("findObjectsAtPosition end")
    return decksAndCards
end

--Activated by a timer to shuffle deck
function timer_shuffle()
    -- log("-- time shuffle start --")
    -- log("global_deal")
    -- log(global_deal)
    --This uses our findObjects function to find the deck in in the draw area
    local discardItemList = findObjectsAtPosition(pos_draw)
    local color  = self.getName()
    --We should only have 1 item here, and it should be a deck
    --But just in case, we will go through any and all returns
    local decks = {}
    for _, obj in ipairs(discardItemList) do
        --Final check to make sure its a deck we're trying to shuffle
        if obj.tag == "Deck" or obj.tag == "Card" then
            obj.shuffle()
            table.insert(decks,obj)
        end
    end


    if decks then
        ---- log("timer_shuffle found stuff")
        ---- log(decks)
        ---- log(decks.tag)
        if decks[1] then
            ---- log ("timer_shuffle decks[1] is #123")
            ---- log(decks[1])
            ---- log(decks[1].tag)
        end
        local deck = nil
        if decks.tag=="Deck" or decks.tag=="Card" then
            deck=decks
            deck.shuffle()
        elseif decks[1] and (decks[1].tag=="Deck" or decks[1].tag=="Card") then
           deck = decks[1]
           if deck.tag=="Deck" then deck.shuffle() end
        else
            ---- log("timer_shuffle else grouping decks")
            deck=group(decks)
        end
        ---- log ("timer_shuffle global_deal")
        ---- log (global_deal)
        if deck  then
            ---- log("timer_shuffle shuffle deck")
            ---- log(deck)
            ---- log("timer_shuffle shuffle deck tag")
            ---- log(deck.tag)
            ---- log("timer_shuffle shuffle deck guid")
            ---- log(deck.guid)
            local count=math.abs(deck.getQuantity())
            ---- log("timer_shuffle local count")
            ---- log(count)
            if count > 0 then
                deck.deal(math.min(count,global_deal),color)
                global_deal=0
                ---- log ("timer_shuffle global_deal")
                ---- log (global_deal)
            end
        else
            ---- log("shuffle deal: not deck found to deal from")
        end
    end
    global_refill_done=true
    ---- log("-- time shuffle end --")
end



function merge(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end
   return t1
end

function get_decks_and_cards_from_zone(zoneGUID)
    ---- log("-get deck and card from zone start-")
    ---- log(zoneGUID)
    local zone = getObjectFromGUID(zoneGUID)
    if zone then
        ---- log("zone found")
        ---- log(zone)
        decks = zone.getObjects()
    else
        return nil
    end
    local result = {}
    if decks then
        ---- log("decks found")
        ---- log(decks)
        for k, deck in pairs(decks) do
            ---- log("checking deck")
            ---- log(deck)
            ---- log(deck.tag)
            if deck.tag == "Deck" or deck.tag == "Card" then
                ---- log("deck or card found")
                ---- log(deck)
                table.insert(result, deck)
                ---- log("result so far")
                ---- log(result)
            end
        end
    end
    ---- log("result")
    for _, res in pairs(result) do
        ---- log(res)
    end
    return result
end

-- discard all card in hand and played
function click_discard_hand()
    -- log("-- ---- log discard hand start --")
    -- log("global_deal")
    -- log(global_deal)
    local color  = self.getName()
    local player =  Player[color]
    local cards = player.getHandObjects()
    if not cards then cards = {} end
    local zoneGuid = "f49fc9"
    if self.getName() == "White" then zoneGuid = "558e75" end
    if self.getName() == "Blue" then  zoneGuid = "2b36c3" end
    local played_cards = get_decks_and_cards_from_zone(zoneGuid)
    ---- log("played cards")
    ---- log(played_cards)

    --This is how we want bal.the card rotation
    if played_cards then cards_all = merge(cards,played_cards) end
    local rot = self.getRotation()
    rot = {rot.x+rot_offset.x, rot.y+rot_offset.y, rot.z+rot_offset.z}
    --This is where we want to put those discarded cards
    local pos = self.positionToWorld(pos_discard)
    for index, card in ipairs(cards_all) do
        card.setPosition(pos, false, true)

    end
     ---- log("-- ---- log discard hand end --")
end

function click_deal_cards()
    -- log("-- ---- log deal cards start --")
    -- log("global_deal")
    -- log(global_deal)
    local color  = self.getName()
    local player =  Player[color]
    local cards = player.getHandObjects()
    local decks=findObjectsAtPosition(pos_draw)
    -- log("decks")
    -- log(decks)
    local deck = nil

    if not decks or not decks[1] then
        ---- log("deal_cards: no decks found: refill")
            global_deal = handsize
        refillDeck()
        return nil
    end


    if decks then
        ---- log("deal_cards:  decks are")
        ---- log(decks)
        ---- log(decks.tag)
        if decks.tag=="Deck" or decks.tag=="Card" then
            deck=decks
        elseif decks[1] and (decks[1].tag=="Deck" or decks[1].tag=="Card") then
           deck = decks[1]
        else
            deck=group(decks)
        end
        ---- log("deal_cards:  deck is")
        ---- log(deck)
        if deck then
            ---- log("deal_cards:  deck tag is ")
            ---- log(deck.tag)
            local count=math.abs(deck.getQuantity())
            ---- log("deal_cards:  dealing 6 from deck")
            deck.deal(math.min(handsize,count),color)
            ---- log("deal_cards: count")
            ---- log(count)
            ---- log("deal_cards: deck")
            ---- log(deck)
            ---- log("deal_cards:  color")
            ---- log(color)
            if count <handsize then
                ---- log("deal_cards:  count is less then 6")
                global_deal=handsize-count
                ---- log ("deal_cards: global_deal")
                ---- log (global_deal)
                refillDeck()
                --Wait.time(refillDeck,3)
                --[[while not global_refill_done do
                    ---- log("wait shuffle")
                end
                --]]
            end

        end
        ---- log("deal_cards:  deck is null")
    else
        ---- log("no player deck found,decks is null")
    end
	local adds = findObjectsAtPosition(pos_add2)
	local toadd = nil
	--log(pos_add)
	--log(adds.tag)
	if adds.tag=="Deck" or adds.tag=="Card" then
            toadd=adds
        elseif adds[1] and (adds[1].tag=="Deck" or adds[1].tag=="Card") then
           toadd = adds[1]
        -- else
            -- toadd=group(adds)
        end
	if toadd then
		if toadd.getQuantity() > 1 then
			toadd.deal(toadd.getQuantity(),color)
		elseif toadd.getQuantity() == -1 then
			toadd.deal(1,color)
		end
	end
    ---- log("-- ---- log deal cards start --")
end

function isDiscardDone()
    local color  = self.getName()
    local player =  Player[color]
    local cards = player.getHandObjects()
    if not cards then cards = {} end
    local played_cards = get_decks_and_cards_from_zone("558e75")
    return ((cards and #cards == 0) or (cards == nil)) and
        ((played_cards and #played_cards == 0) or (played_cards == nil))
end

function isHandFull()
    ---- log("ishandfull")
    local color  = self.getName()
    local player =  Player[color]
    local cards = player.getHandObjects()
    ---- log(cards)
    ---- log(#cards)
    return cards and ( #cards == handsize )
end

function toggle_button(name,color,color2)
     buttonList = self.getButtons()
     for i,b in ipairs(buttonList) do
         if b.click_function == name then
             b.color=color
         elseif  b.click_function != "click_refillDeck" then
             b.color=color2
         end
          self.editButton(b)
     end
end

function click_end_turn()
    -- log ("--- before discard ---")
   global_deal=0
   click_discard_hand()
   -- log ("--- before deal cards ---")
   Wait.condition(click_deal_cards,isDiscardDone,3,function() print("discard timeout") end)
   -- log ("--- after deal cards ---")
   --Wait.condition(function() print("end turn") Turns. Global.nd,isHandFull, 5, function() print("card draw timeout") end)
end

function click_draw_card()
    -- log("-- ---- log draw card start --")
    -- log("global_deal")
    -- log(global_deal)
    local color  = self.getName()
    local player =  Player[color]
    local cards = player.getHandObjects()
    local decks=findObjectsAtPosition(pos_draw)
    -- log("decks")
    -- log(decks)
    local deck = nil

    if not decks or not decks[1] then
        ---- log("deal_cards: no decks found: refill")
            global_deal = 1
        refillDeck()
        return nil
    end


    if decks then
        ---- log("deal_cards:  decks are")
        ---- log(decks)
        ---- log(decks.tag)
        if decks.tag=="Deck" or decks.tag=="Card" then
            deck=decks
        elseif decks[1] and (decks[1].tag=="Deck" or decks[1].tag=="Card") then
           deck = decks[1]
        else
            deck=group(decks)
        end
        ---- log("deal_cards:  deck is")
        ---- log(deck)
        if deck then
            ---- log("draw_card:  deck tag is ")
            ---- log(deck.tag)

            ---- log("draw card:  drawing card from deck")
            deck.deal(1,color)

            ---- log("draw_card: deck")
            ---- log(deck)
            ---- log("draw_card:  color")
            ---- log(color)


        end
        ---- log("draw_card:  deck is null")
    else
        ---- log("no player deck found,decks is null")
    end

end