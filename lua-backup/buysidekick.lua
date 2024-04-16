function onLoad()
    self.createButton({
         click_function="click_buy_hero", function_owner=self,
         position={0,0.01,4}, label="Buy sidekick", color={1,1,1,1}, width=2000, height=1000,
         tooltip="Buy a sidekick", font_size = 250
     })
     
    local guids3 = {
        "playerBoards",
        "resourceguids",
        "discardguids",
        "drawguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
    
    local guids1 = {
        "sidekickZoneGUID",
        "setupGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    rot_offset = {x=0, y=0, z=180}
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

function click_buy_hero(obj, player_clicker_color, alt_click)
    local objects = get_decks_and_cards_from_zone(sidekickZoneGUID)
    if not objects[1] then
        return nil
    end
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < 2 then
        broadcastToColor("You don't have enough recruit to buy this hero!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-2)
    local card = nil
    local deck = nil
    for _,item in pairs(objects) do
        if item.tag == "Card" then
            card = item
            break
        end
        if item.tag == "Deck" then
            deck = item
            break
        end
    end
	local scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
	local toflip = deck.is_face_down
	local dest = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
	if scheme and scheme.getName() == "Splice Humans with Spider DNA" then
		dest = getObjectFromGUID(drawguids[player_clicker_color]).getPosition()
		if card then
			card.flip()
		end
		if deck then
			toflip = false
		end
	end
    dest.y = dest.y + 3
    if card then
        card.setPositionSmooth(dest)
    elseif deck then
        deck.takeObject({position = dest,
            smooth = true,
            flip = toflip})
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return Global.Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end