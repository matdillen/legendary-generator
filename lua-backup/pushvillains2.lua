--Creates invisible button onload, hidden under the "REFILL" on the deck pad
twistsresolved = 0
playerBoards = {
	["Red"]="8a35bd",
	["Green"]="d7ee3e",
	["Yellow"]="ed0d43",
	["Blue"]="9d82f3",
	["White"]="206c9c"
}

vpileguids = {
	["Red"]="fac743",
	["Green"]="a42b83",
	["Yellow"]="7f3bcd",
	["Blue"]="f6396a",
	["White"]="7732c7"
}
function onLoad()
    --city_zones_guids = {"5ed32f","2a6ac6","b2f04b","acdea9", "91e12a"}
    escape_zone_guid  =  "de2016"
    city_start_zone_guid = "40b47d"

	self.createButton({
        click_function="click_push_vilain_into_city", function_owner=self,
        position={0,0,0}, label="Push villain into city", color={1,1,1,0}, width=2000, height=3000,
        tooltip = "push villain into city"
    })
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
            if deck.tag == "Deck" or deck.tag == "Card" or deck.getName() == "Shard" then
                table.insert(result, deck)
            end
        end
    end
    return result
end


function shift_to_next(objects,targetZone)
	for k, obj in pairs(objects) do
		local zPos = obj.getPosition().z
		local bs = false
		if targetZone.guid == escape_zone_guid or targetZone.guid == city_start_zone_guid then
			zPos = targetZone.getPosition().z
		end
		if targetZone.guid == escape_zone_guid then
			broadcastToAll("Villain Escaped", {r=1,g=0,b=0})
		end
		for i,o in pairs(obj.getTags()) do
			if o == "Bystander" then
				bs = true
			end
		end
		if targetZone.guid == city_start_zone_guid and bs == true then
			zPos = zPos - 1
		end
		obj.setPositionSmooth({targetZone.getPosition().x, targetZone.getPosition().y+3,
			zPos},false,false)
	end
end




function push_all (city,init)
    if city and city[1] then
        local zoneGUID=table.remove(city,1)
        local targetZoneGUID=city[1]
        if not targetZoneGUID then
            targetZoneGUID=escape_zone_guid
        end
        local cards=get_decks_and_cards_from_zone(zoneGUID)
        local targetZone=getObjectFromGUID(targetZoneGUID)
        if cards then
            if cards[1] and targetZone then
				local schemeZone=getObjectFromGUID("c39f60")
				if schemeZone.getObjects()[2] then
					schemename = schemeZone.getObjects()[2].getName()
				else
					schemename = "missing"
				end
				if schemename == "Alien Brood Encounters" then
					if city then
						push_all(city,0)
					end
					return shift_to_next(cards,targetZone)
				end
				if cards[1].getName() == "Scheme Twist" and init == 1 then
					if schemename == "Age of Ultron" then
						posi = getObjectFromGUID("1fa829")
						actuposi = {x=posi.getPosition().x+4*twistsresolved,y=posi.getPosition().y,z=posi.getPosition().z}
						heroZone=getObjectFromGUID("0cd6a9")
						herodeck = heroZone.getObjects()[2]
						--will not work if hero deck contains 1 or less cards
						herodeck.takeObject({position = actuposi,flip=true})
						twistsresolved = twistsresolved + 1	
					end
					--if schemename == "Annihilation: Conquest" then
						--not automatable: players choose if tie
					--end
					if schemename == "Anti-Mutant Hatred" then
						pcolor = Turns.turn_color
						if pcolor == "White" then
							angle = 90
						elseif pcolor == "Blue" then
							angle = -90
						else
							angle = 0
						end
						brot = {x=0, y=angle, z=0}
						local playerBoard = getObjectFromGUID(playerBoards[pcolor])
						local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
						print("Angry Mob moved to player's discard pile!")
						cards[1].setRotationSmooth(brot)
						return cards[1].setPositionSmooth({x=dest.x,y=dest.y+3,z=dest.z})
					end
					if schemename == "Brainwash The Military" then
						if twistsresolved < 7 then
							click_draw_villain()
							print("Scheme Twist: Play another card of the villain deck!")
						elseif twistsresolved == 7 then
							print("Scheme Twist: All SHIELD Officers in the city escape!")
						end
						twistsresolved = twistsresolved + 1	
					end
					-- if schemename == "Break The Planet Asunder" then
						-- KO heroes from HQ if they're weaker than twistsresolved
						-- requires hero tags with their base power
						-- twistsresolved = twistsresolved + 1	
					-- end
					if schemename == "Build an Army of Annihilation" then
						local twistpile = getObjectFromGUID("4f53f9")
						annipile = getObjectFromGUID("8656c3")
						cards[1].setPositionSmooth(twistpile.getPosition())
						twistsresolved = twistsresolved + 1
						if annipile.getObjects()[2] then
							henchpresent = annipile.getObjects()[2].getQuantity()
						else
							henchpresent = 0
						end
						henchcaught = 0
						for i,o in pairs(vpileguids) do
							if Player[i].seated == true then
								vpilecontent = getObjectFromGUID(o).getObjects()[1]
								copguids = {}
								if vpilecontent then
									if vpilecontent.getQuantity() > 1  then
										local vpileCards = vpilecontent.getObjects()
										for j = 1, vpilecontent.getQuantity() do
											if vpileCards[j].name == "Annihilation Wave Henchmen" then
												table.insert(copguids,vpileCards[j].guid)
											end
										end
										henchcaught = henchcaught + #copguids
										if vpilecontent.getQuantity() ~= #copguids then
											for j = 1,#copguids do
												vpilecontent.takeObject({position=annipile.getPosition(),
													guid=copguids[j]})
											end
										else
											vpilecontent.setPositionSmooth(annipile.getPosition())
										end
									elseif vpilecontent.getQuantity() == -1 then
										if vpilecontent.getName() == "Annihilation Wave Henchmen" then
											awh = vpilecontent.setPositionSmooth(annipile.getPosition())
											henchcaught = henchcaught + 1
										end
									end
								end
							end
						end
						annimmpile = getObjectFromGUID("bf7e87")
						local refeedMM = function()
							--twist card's setPosition may be too slow, so use a variable
							--twistsstacked = twistpile.getObjects()[2].getQuantity()
							--if twistsstacked == -1 then twistsstacked = 1 end
							annicount = annipile.getObjects()[2].getQuantity()
							for i=1,twistsresolved do
								if i < annicount then
									annipile.getObjects()[2].takeObject({position=annimmpile.getPosition()})
								elseif i == annicount then
									annipile.setPositionSmooth(annimmpile.getPosition())
								else
									printToAll("Not enough annihilation wave henchmen left! Evil wins?")
									return nil
								end
							end
							printToAll(twistsresolved .. " annihilation henchmen moved to the mastermind!")
						end
						local anniGathered = function()
							annicards = annipile.getObjects()[2]
							if annicards then
								if annicards.getQuantity() == henchpresent + henchcaught then
									return true
								else
									return false
								end
							else
								return false
							end
						end
						Wait.condition(refeedMM,anniGathered)
						return nil
					end
					if schemename == "Build an Underground MegaVault Prison" then
						--check sewers for villain, if so, deal wounds
						--can do, but potentially complicated with locations or mm specials
						
						--check top card and play if villain
						--requires villain tag, or could check for VP and exclude bystanders
						--still tricky with locations and weapons
					end
					if schemename == "Cage Villains in Power-Suppressing Cells" then
						local twistpile = getObjectFromGUID("4f53f9")
						cards[1].setPositionSmooth(twistpile.getPosition())
						for i,o in pairs(vpileguids) do
							if Player[i].seated == true then
								vpilecontent = getObjectFromGUID(o).getObjects()[1]
								annipile = getObjectFromGUID("8656c3")
								copguids = {}
								if vpilecontent then
									if vpilecontent.getQuantity() > 1  then
										local vpileCards = vpilecontent.getObjects()
										for j = 1, vpilecontent.getQuantity() do
											if vpileCards[j].name == "Cops" then
												table.insert(copguids,vpileCards[j].guid)
											end
										end
										if vpilecontent.getQuantity() ~= #copguids then
											for j = 1,#copguids do
												vpilecontent.takeObject({position=annipile.getPosition(),
													guid=copguids[j]})
											end
										else
											vpilecontent.setPositionSmooth(annipile.getPosition())
										end
									end
									if vpilecontent.getQuantity() == -1 then
										if vpilecontent.getName() == "Cops" then
											vpilecontent.setPositionSmooth(annipile.getPosition())
										end
									end
								end
							end
						end
						printToAll("TWIST: Put a non-grey hero from your hand in front of you and put a cop on top of it.")
						return nil
					end
					if schemename == "Dark Alliance" then
						if twistsresolved == 0 then
							mmPile=getObjectFromGUID("c7e1d5")
							annipile = getObjectFromGUID("8656c3")
							mmPile.randomize()
							local stripTactics = function(obj)
								keep = math.random(4)
								tacguids = {}
								for i = 1,4 do
									table.insert(tacguids,obj.getObjects()[i].guid)
								end
								annimmpile = getObjectFromGUID("bf7e87")
								for i = 1,4 do
									if i ~= keep then
										obj.takeObject({position = annimmpile.getPosition(),
											guid = tacguids[i],
											flip = true})
									end
								end
							end
							mmPile.takeObject({position = annipile.getPosition(),callback_function = stripTactics})
						elseif twistsresolved < 4 then
							annipile = getObjectFromGUID("8656c3")
							if annipile.getObjects()[2] then
								postop = annipile.getPosition()
								postop.y = postop.y + 4
								tacticShuffle = function(obj)
									annipile.getObjects()[2].randomize()
								end
								addTactic = function(obj)
									if annimmpile.getObjects()[2].getQuantity() > 1 then
										annimmpile.getObjects()[2].takeObject({position = annipile.getPosition(),
											flip=true,
											smooth=false,
											callback_function = tacticShuffle})
									elseif annimmpile.getObjects()[2].getQuantity() == -1 then
										annimmpile.getObjects()[2].flip()
										ann = annimmpile.getObjects()[2].setPosition(annipile.getPosition())
										tacticShuffle(ann)
									end
								end
								if annipile.getObjects()[2].getQuantity() > 1 then
									annipile.getObjects()[2].takeObject({position =postop,
										callback_function = addTactic})
								elseif annipile.getObjects()[2].getQuantity() == -1 then
									ann = annipile.getObjects()[2].setPosition(postop)
									addTactic(ann)
								end
							end
						end
						twistsresolved = twistsresolved + 1
						--log(twistsresolved)
					end
				end
				
				if cards[1].getName() == "Masterstrike" then
					return cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
				end

				if cards[1].getName() == "Scheme Twist" then
					if schemename == "Crush Them With My Bare Hands" then
						return cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
					end
					if schemename ~= "Age of Ultron" then
						return cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
					end
				end
				bs = false
				for i,o in pairs(cards[1].getTags()) do
					if o == "Bystander" then
						bs = true
					end
				end
				if bs == true  then
					return shift_to_next(cards,targetZone)
				end
				if city then
					push_all(city,0)
				end
				shift_to_next(cards,targetZone)
            end
        end
    end
end

function recursion_test(city)
    if city and city[1] then
        table.remove(city,1)
        recursion_test(city)
    end
end

function click_push_vilain_into_city(obj, player_clicker_color, alt_click)
-- when moving the villain deck buttons, change the first guid to a new scripting zone
    local city_zones_guids = {"e6b0bc","40b47d","5a74e7","07423f","5bc848","82ccd7"}
    push_all(city_zones_guids,1)
end

function click_draw_villain()
    obj=getObjectFromGUID("e6b0bc")
    villain_deck_zone = getObjectFromGUID("4bc134")
    villain_decks   = villain_deck_zone.getObjects()
    if villain_decks then
        for k, deck in pairs(villain_decks) do
          if deck.tag == "Deck" then
            villain_deck=deck
          end
          if deck.tag == "Card" then
            villain_deck=deck
          end
        end
    end
    local schemeZone=getObjectFromGUID("c39f60")
    flip_villains = true
    if schemeZone.getObjects()[2] then
        if schemeZone.getObjects()[2].getName() == "Alien Brood Encounters" then
            flip_villains = false
        end
    end
    if villain_deck then
        takeParams = {
            position = {obj.getPosition().x,obj.getPosition().y+5,obj.getPosition().z},
            flip = flip_villains
        }
        takeParams_single = {obj.getPosition().x,obj.getPosition().y+5,obj.getPosition().z}
        if villain_deck.tag == "Deck" then
            villain_deck.takeObject(takeParams)
        end
        if villain_deck.tag == "Card" then
            villain_deck.flip()
            villain_deck.setPositionSmooth(takeParams_single)
			villain_deck = nil
        end
    else
		print("Villain deck is empty!")
    end
end