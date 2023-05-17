function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
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
    local cards = params.cards
    
    local floorboom = table.remove(topBoardGUIDs)
    local floorcontent = Global.Call('get_decks_and_cards_from_zone',floorboom)
    if floorcontent[1] then
        local pcolor = Turns.turn_color
        if pcolor == "White" then
            angle = 90
        elseif pcolor == "Blue" then
            angle = -90
        else
            angle = 180
        end
        local brot = {x=0, y=angle, z=0}
        local playerBoard = getObjectFromGUID(playerBoards[pcolor])
        local dest = playerBoard.positionToWorld({-0.957, 0.178, 0.222})
        dest.y = dest.y + 3
        local floorcount = 0
        for _,o in pairs(floorcontent) do
            if o.is_face_down == false then
                o.flip()
            end
            floorcount = floorcount + math.abs(o.getQuantity())
        end
        local floorSecure = function()
            local floor = Global.Call('get_decks_and_cards_from_zone',floorboom)
            if floor[1] and math.abs(floor[1].getQuantity()) == floorcount then
                for _,o in pairs(floor) do
                    if o.is_face_down == false then
                        return false
                    end
                end
                return true
            else
                return false
            end
        end
        local explodeFloor = function(obj)
            floorcontent = Global.Call('get_decks_and_cards_from_zone',floorboom)
            if floorcontent[1] then
                floorcontent[1].flip()
                floorcontent[1].setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
            end
            broadcastToAll("Scheme Twist: Top floor of the Washington Monument Destroyed!")
        end
        local floorcollapse = function()
            if floorcontent[1].tag == "Deck" then
                local bs = false
                for _,o in pairs(floorcontent[1].getObjects()) do
                    bs = false
                    for _,k in pairs(o.tags) do
                        if k == "Bystander" then
                            bs = true
                            break
                        end
                    end
                    if bs == false then
                        floorcontent[1].takeObject({position = dest,
                            rotation = brot,
                            guid = o.guid,
                            callback_function = explodeFloor})
                        broadcastToAll("Player " .. pcolor .. " got a wound from the destroyed Monument floor.",pcolor)
                        break
                    end
                end
                if bs == true then
                    explodeFloor(floorcontent[1])
                end
            else
                if floorcontent[1].hasTag("Bystander") then
                    explodeFloor()
                else
                    floorcontent[1].flip()
                    floorcontent[1].setRotationSmooth(brot)
                    floorcontent[1].setPositionSmooth(dest)
                    broadcastToAll("Player " .. pcolor .. " got a wound from the destroyed Monument floor.",pcolor)
                end
            end
        end
        Wait.condition(floorcollapse,floorSecure)
    end
    return twistsresolved
end