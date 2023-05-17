function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_discard"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "playerBoards"
        }
            
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved == 1 then
        function click_buy_hulk(obj,player_clicker_color)
            local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
            if not hulkdeck then
                return nil
            end
            local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
            local dest = playerBoard.positionToWorld(pos_discard)
            dest.y = dest.y + 3
            if player_clicker_color == "White" then
                angle = 90
            elseif player_clicker_color == "Blue" then
                angle = -90
            else
                angle = 180
            end
            local brot = {x=0, y=angle, z=0}
            if hulkdeck.tag == "Card" then
                hulkdeck.setRotationSmooth(brot)
                hulkdeck.setPositionSmooth(dest)
            else
                hulkdeck.takeObject({position=dest,rotation=brot,flip=false,smooth=true})
            end
        end
        getObjectFromGUID("bd3ef1").createButton({
             click_function="click_buy_hulk", 
             function_owner=self,
             position={0,0,-0.75},
             rotation={0,180,0},
             label="Buy Hulk",
             tooltip="Buy the top card of the Prison Ship.",
             color={1,1,1,1},
             width=800,
             height=200,
             font_size = 100
        })
    end
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    if hulkdeck[1] and hulkdeck[1].getQuantity() > 2 then
        hulkdeck[1].takeObject({position = getObjectFromGUID("bd3ef1").getPosition(),
            flip = true,
            smooth = true})
        hulkdeck[1].takeObject({position = getObjectFromGUID("bd3ef1").getPosition(),
            flip = true,
            smooth = true})
    elseif hulkdeck[1] then
        hulkdeck[1].flip()
        hulkdeck[1].setPositionSmooth(getObjectFromGUID("bd3ef1").getPosition())
    else
        broadcastToAll("Scheme Twist: No Hulk deck found, so Evil Wins!")
    end
    return twistsresolved
end
