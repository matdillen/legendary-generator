--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
   self.createButton({
        click_function="click_draw_villain", function_owner=self,
        position={0,0,0}, label="Draw villain", color={1,1,1,0}, width=2000, height=3000,
		tooltip = "Draw card from villain deck."
    })
    flip_villains = true
    
    hqZonesGUIDs={
        "4c1868",
        "8656c3",
        "533311",
        "3d3ba7",
        "725c5d"}
end

function click_draw_villain(obj,player_clicker_color)
    obj=self
    villain_deck_zone = getObjectFromGUID("4bc134")
    local schemeParts = getObjectFromGUID("912967").Call('returnSetupParts')
    if schemeParts then
        if schemeParts[1] == "Alien Brood Encounters" then
            flip_villains = false
        end
        if schemeParts[1] == "Fragmented Realities" then
            for _,o in pairs(hqZonesGUIDs) do
                local zone = getObjectFromGUID(o)
                if zone.hasTag(player_clicker_color) then
                    villain_deck_zone = zone
                    break
                end
            end
        end
    end
    villain_decks = villain_deck_zone.getObjects()
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