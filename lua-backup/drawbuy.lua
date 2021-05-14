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
    pos_discard = {-0.957, 0.178, 0.222}
    pos_draw = {0.957, 0.178, 0.222}
	pos_add2 = {-3.15, 0.178, 0.222}

    --This is which way is face down for a card or deck relative to the tool
    rot_offset = {x=0, y=0, z=180}
	
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
    for i,o in pairs(drawbuyguids) do
        if o == self.guid then
            divided_deck_guid = dividedDeckGUIDs[i]
        end
    end
	
end

function click_buy_hero(obj, player_clicker_color, alt_click)
    local card = getHero()
    if not card then
        return nil
    end
    local playerBoards = {
        ["Red"]="8a35bd",
        ["Green"]="d7ee3e",
        ["Yellow"]="ed0d43",
        ["Blue"]="9d82f3",
        ["White"]="206c9c"
    }
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
    click_draw_hero(obj, player_clicker_color, alt_click)
end

function getHero()
    local objects = findObjectsAtPosition({0,0,0})
    if not objects then 
        return nil 
    end
    local card = nil
    for _,item in pairs(objects) do
        if item.tag == "Card" and item.is_face_down == false then
            card = item
        end
    end
    --log (card)
    if not card then 
        return nil
    end
    return card
end

function click_draw_hero(obj, player_clicker_color, alt_click)
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
    
    local pos = {self.getPosition().x,self.getPosition().y+5,self.getPosition().z}
    if hero_deck[1] then
        if hero_deck[1].tag == "Deck" then
            takeParams = {
                position = pos,
                flip = hero_deck[1].is_face_down
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

--This is used by another function to locate information on what is in an area
function findObjectsAtPosition(localPos)
    --log ("findObjectsAtPosition start")
    --We convert that local position to a global table position
    local globalPos = self.positionToWorld(localPos)
    --We then do a raycast of a sphere on that position to find objects there
    --It returns a list of hits which includes references to what it hit
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
    --log ("findObjectsAtPosition end")
    return decksAndCards
end

function get_decks_and_cards_from_zone(zoneGUID)
    --this function returns cards, decks and shards in a city space (or the start zone)
    --returns a table of objects
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