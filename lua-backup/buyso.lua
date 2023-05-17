function onLoad()
    self.createButton({
         click_function="click_buy_hero", function_owner=self,
         position={0,0.01,4}, label="Buy SHIELD Officer", color={1,1,1,1}, width=2000, height=1000,
         font_size = 250, tooltip = "Buy a S.HI.E.L.D. Officer (or Madame HYDRA)"
     })
     
    setupGUID = "912967" 
    
    local guids3 = {
        "playerBoards",
        "resourceguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "pos_discard",
       "pos_draw"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = callGUID(o,2)
    end
    
    local guids1 = {
        "officerZoneGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = callGUID(o,1)
    end

    rot_offset = {x=0, y=0, z=180}
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

function click_buy_hero(obj, player_clicker_color, alt_click,free)
    local objects = get_decks_and_cards_from_zone(officerZoneGUID)
    if not objects[1] then
        return nil
    end
    if not free then
        local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
        if recruit < 3 then
            broadcastToColor("You don't have enough recruit to buy this hero!",player_clicker_color,player_clicker_color)
            return nil
        end
        getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-3)
    end
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
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
	local schemeParts = getObjectFromGUID(setupGUID).Call('returnSetupParts')
    if not schemeParts then
        printToAll("No scheme specified!")
        schemeParts = {"no scheme"}
    end
	local toflip = deck.is_face_down
	if schemeParts[1] == "Splice Humans with Spider DNA" then
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
    dest.y = dest.y + 3
    if card then
        card.setPositionSmooth(dest)
    elseif deck then
        deck.takeObject({position = dest,
            smooth = true,
            flip = toflip})
    end
end

function gainOfficer(color)
    click_buy_hero(nil,color,nil,true)
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return getObjectFromGUID(setupGUID).Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end