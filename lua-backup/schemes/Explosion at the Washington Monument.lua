function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "bystandersPileGUID",
        "woundsDeckGUID",
        "mmZoneGUID"
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
        "playerBoards",
        "vpileguids"
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

function setupSpecial(params)
    log("Set up the Washington Monument stacks...")
    local topzone = getObjectFromGUID(topBoardGUIDs[1])
    log("Gathering wounds and bystanders...")
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    for i=1,18 do
        bsPile.takeObject({position=topzone.getPosition(),
            flip=false,smooth=false})
    end
    local wndPile = getObjectFromGUID(woundsDeckGUID)
    for i=1,14 do
        wndPile.takeObject({position=topzone.getPosition(),
            flip=false,smooth=false})
    end
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 1,8 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
    log("Shuffle..")
    local stack_created = function() 
        local test = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
        if test and test.getQuantity() == 32 then
            return true
        else
            return false
        end
    end
    local stack_floors = function()
        local floorstack = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
        floorstack.randomize()
        for i = 2,8 do
            log("Creating floor " .. i)
            local floorZone = getObjectFromGUID(topBoardGUIDs[i]).getPosition()
            floorZone.y = floorZone.y + 2
            for j=1,4 do
                floorstack.takeObject({
                    position = floorZone,
                    flip=false})
            end
        end
    end
    Wait.condition(stack_floors,stack_created)
    log("Washington monument stacks created!")
end

function showFloor(params)
    local content = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[params.index])
    local pos = getObjectFromGUID(topBoardGUIDs[params.index]).getPosition()
    pos.y = pos.y + 2
    local boombust = function(obj)
        if obj.hasTag("Bystander") then
            local vpos = getObjectFromGUID(vpileguids[params.player_clicker_color]).getPosition()
            vpos.y = vpos.y + 1
            obj.setPosition(vpos)
            broadcastToColor("You rescued a bystander from the Monument's " .. params.index .. "th floor!",params.player_clicker_color,params.player_clicker_color)
        end
    end
    for _,o in pairs(content) do
        if o.is_face_down == true then
            if o.tag == "Deck" then
                o.takeObject({position = pos,
                    flip = true,
                    callback_function = boombust})
            else
                o.flip()
                boombust(o)
            end
        end
    end
end

function fightEffect(params)
    local monument = {}
    for i,o in pairs(topBoardGUIDs) do
        monument[i] = getObjectFromGUID(o)
        local facedownfound = false
        local content = Global.Call('get_decks_and_cards_from_zone',o)
        if content[1] then
            for _,p in pairs(content) do
                if p.is_face_down == true then
                    facedownfound = true
                    break
                end
            end
        end
        if not facedownfound then
            monument[i] = nil
        end
    end
    broadcastToColor("You fought a villain, so you can reveal a face-down card from any floor of the monument.",params.color,params.color)
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{
        color = params.color,
        hand = monument,
        pos = "Stay",
        label = "Reveal",
        tooltip = "Reveal a face-down card from this floor.",
        isZone = true,
        fsourceguid = self.guid,
        trigger_function = 'showFloor',
        args = "self"})
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