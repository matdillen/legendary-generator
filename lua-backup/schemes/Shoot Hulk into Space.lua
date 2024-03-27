function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "setupGUID",
        "heroPileGUID",
        "madamehydrazoneguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "discardguids",
        "resourceguids"
        }
            
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function hulkshuffle(obj)
    obj.randomize()
    local pos = obj.getPosition()
    pos.y = pos.y + 0.1
    for i=1,obj.getQuantity() do
        obj.takeObject({position = pos, flip = true})
        pos.y = pos.y + 0.1*i
    end
end

function setupSpecial(params)
    log("Extra Hulk hero in mutation pile.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = params.setupParts[9],
        pileGUID = heroPileGUID,
        destGUID = twistZoneGUID,
        callbackf = "hulkshuffle",
        fsourceguid = self.guid})
end

function click_buy_hulk(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local cost = 0
    if hulkdeck.tag == "Deck" then
        local hulkdeckobj = hulkdeck.getObjects()
        for _,t in pairs(hulkdeckobj[#hulkdeckobj].tags) do
            if t:find("Cost:") then
                cost = tonumber(t:sub(6))
                break
            end
        end
    else
        cost = hasTag2(huldeck,"Cost:") or 0
    end
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    if recruit < cost then
        broadcastToColor("You don't have enough recruit to liberate this pawn!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-cost)
    local dest = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
    dest.y = dest.y + 3
    if hulkdeck.tag == "Card" then
        hulkdeck.setPositionSmooth(dest)
    else
        hulkdeck.takeObject({position=dest,flip=false,smooth=true})
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved == 1 then
        getObjectFromGUID(madamehydrazoneguid).createButton({
             click_function="click_buy_hulk", 
             function_owner=self,
             position={0,0,-0.75},
             rotation={0,180,0},
             label="Buy Hulk",
             tooltip="Buy the top card of the Prison Ship.",
             color="Yellow",
             width=800,
             height=200,
             font_size = 100
        })
    end
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    local pos = getObjectFromGUID(madamehydrazoneguid).getPosition()
    if hulkdeck[1] and hulkdeck[1].getQuantity() > 2 then
        hulkdeck[1].takeObject({position = pos,
            flip = true,
            smooth = true})
        hulkdeck[1].takeObject({position = pos,
            flip = true,
            smooth = true})
    elseif hulkdeck[1] then
        hulkdeck[1].flip()
        hulkdeck[1].setPositionSmooth(pos)
    else
        broadcastToAll("Scheme Twist: No Hulk deck found, so Evil Wins!")
    end
    return twistsresolved
end