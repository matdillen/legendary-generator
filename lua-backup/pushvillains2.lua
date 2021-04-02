--Creates invisible button onload, hidden under the "REFILL" on the deck pad
twistsresolved = 0
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
            if deck.tag == "Deck" or deck.tag == "Card" then
                table.insert(result, deck)
            end
        end
    end
    return result
end


function shift_to_next(objects,targetZone)
    for k, obj in pairs(objects) do
       local zPos = obj.getPosition().z
       if targetZone.guid == escape_zone_guid or targetZone.guid == city_start_zone_guid then
         zPos = targetZone.getPosition().z
       end
       if targetZone.guid == escape_zone_guid then
           broadcastToAll("Villain Escaped", {r=1,g=0,b=0})
       end
       if targetZone.guid == city_start_zone_guid and obj.getDescription() == "bystander" then
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
						--push highest cost hero from hq into city
						--requires hero cost tags
						--player chooses if a tie, so not really to be automatized
					--end
					if schemename == "Anti-Mutant Hatred" then
						local playerBoards = {
							["Red"]="8a35bd",
							["Green"]="d7ee3e",
							["Yellow"]="ed0d43",
							["Blue"]="9d82f3",
							["White"]="206c9c"
						}
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
						-- local playerBoards = {
							-- ["Red"]="8a35bd",
							-- ["Green"]="d7ee3e",
							-- ["Yellow"]="ed0d43",
							-- ["Blue"]="9d82f3",
							-- ["White"]="206c9c"
						-- }
						-- for i,o in pairs(playerBoards) do
							-- local playerBoard = getObjectFromGUID(playerBoards[i])
							-- local vpile = playerBoard.positionToWorld({3.828, 0.178, 0.222})
							-- if vpile.getObjects()[1] then
								-- for j,p in pairs(vpile.getObjects()) do
								-- end
							-- end
						-- end
					end
					
				end
				if cards[1].getName() == "Masterstrike" then
					return cards[1].setPositionSmooth(getObjectFromGUID("be6070").getPosition())
				end

				if cards[1].getName() == "Scheme Twist" then
					if schemename ~= "Age of Ultron" then
						return cards[1].setPositionSmooth(getObjectFromGUID("4f53f9").getPosition())
					end
				end
				if cards[1].getDescription() == "bystander"  then
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