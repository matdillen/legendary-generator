--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    --[[
   self.createButton({
        click_function="click_draw_hero", function_owner=self,
        position={0,0,0}, label="draw hero", color={1,1,1,0}, width=2000, height=3000
    })
    ]]

    self.createButton({
         click_function="click_buy_hero", function_owner=self,
         position={0,0.01,4}, label="Buy SHIELD Officer", color={1,1,1,1}, width=2000, height=1000,
         font_size = 250, tooltip = "Buy a S.HI.E.L.D. Officer (or Madame HYDRA)"
     })

    --This is how I found the positions to check for cards
    --That GUID was a card I put on it
    --local pos = self.positionToLocal(getObjectFromGUID("61b186").getPosition())
    --log(pos.x)
    --log(pos.y)
    --log(pos.z)

    --Local positions for each pile of cards
    pos_discard = {-0.957, 0.178, 0.222}
    pos_draw = {0.957, 0.178, 0.222}

    --This is which way is face down for a card or deck relative to the tool
    rot_offset = {x=0, y=0, z=180}
	
	schemeZone=getObjectFromGUID("c39f60")
end

function click_buy_hero(obj, player_clicker_color, alt_click)
    local objects =findObjectsAtPosition({0,0,0})
    log(objects)
    if not objects then return nil end
    local card = nil
    local deck = nil
    for _,item in pairs(objects) do
        if item.tag == "Card" then
            card = item
        end
        if item.tag == "Deck" then
            deck = item
        end
    end
    log (card)
    log (deck)
    if not card and not deck then return nil end

    log("Turns.turn_color")
    log(Turns.turn_color )
    local playerBoards = {
        ["Red"]="8a35bd",
        ["Green"]="d7ee3e",
        ["Yellow"]="ed0d43",
        ["Blue"]="9d82f3",
        ["White"]="206c9c"

    }
    pos_discard = {-0.957, 0.178, 0.222}
    log(card)
    log("boardGUID")
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    log("playerBoard")
    log(playerBoard)
	if schemeZone.getObjects()[2] then
		schemename = schemeZone.getObjects()[2].getName()
	else
		schemename = ""
	end
	toflip = deck.is_face_down
	if schemename == "Splice Humans With Spider DNA" then
		pos = pos_draw
		if card then
			card.flip()
		end
		if deck then
			toflip = false
		end
	else 
		pos = pos_discard
	end
    local dest = playerBoard.positionToWorld(pos)
    if card then
    card.setPositionSmooth({x=dest.x,y=dest.y+3,z=dest.z})
    elseif deck then
        deck.takeObject({
            position          = {x=dest.x,y=dest.y+3,z=dest.z},
            smooth            = true,
            flip              = toflip
        })
    end
    --click_draw_hero(obj, player_clicker_color, alt_click)

end

function click_draw_hero(obj, player_clicker_color, alt_click)
    --log("start")
    hero_deck_zone = getObjectFromGUID("0cd6a9")
    --log("hero_deck_zone:")
    --log(hero_deck_zone.guid)
    hero_decks   = hero_deck_zone.getObjects()
    --log("hero_decks")
    --log(hero_decks)
    --log("hero_decks[1]")
    --log(hero_decks[1])
    if hero_decks then
        for k, deck in pairs(hero_decks) do
          --log(deck)
          if deck.tag == "Deck" then
            hero_deck=deck
          end
        end

    end

    if hero_deck then
        --log("hero_deck")
        --log(hero_deck)
        takeParams = {
            position = {self.getPosition().x,self.getPosition().y+5,self.getPosition().z},
            flip = hero_deck.is_face_down
        }
        hero_deck.takeObject(takeParams)
    else
        --log("no hero deck found")
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