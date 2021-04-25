--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
   self.createButton({
        click_function="click_draw_villain", function_owner=self,
        position={0,10,0}, label="Draw villain", color={1,1,1,0}, width=2000, height=3000,
		tooltip = "Draw card from villain deck."
    })
end

function click_draw_villain()
    obj=self
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