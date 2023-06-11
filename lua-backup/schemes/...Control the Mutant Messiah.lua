function onLoad()   
    manipulations_stacked = 0
    currentmessiah = nil
    
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "heroPileGUID"
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
        "resourceguids",
        "drawguids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function juggle(obj)
    obj.flip()
    local content = obj.getObjects()
    local up = 0.1
    local pos = obj.getPosition()
    for i=1,#content-1 do
        pos.y = pos.y + up
        up = up + 0.1
        obj.takeObject({position = pos})
    end
end

function revealScheme()
    local heropile = getObjectFromGUID(heroPileGUID)
    heropile.randomize()
    heropile.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
        smooth = false,
        callback_function = juggle})
    local manipulations = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[1])[1]
    if manipulations then
        manipulations_stacked = math.abs(manipulations.getQuantity())
    end
end

function buyMessiah(obj,player_clicker_color)
    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    local cost = hasTag2(obj,"Cost:")
    cost = cost + manipulations_stacked
    if recruit < cost then
        broadcastToColor("You don't have enough Recruit to gain this sidekick!",player_clicker_color,player_clicker_color)
        return nil
    else
        getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-cost)
        currentmessiah = nil
        local pos = getObjectFromGUID(drawguids[player_clicker_color]).getPosition()
        pos.y = pos.y + 2
        obj.clearButtons()
        obj.locked = false
        obj.flip()
        obj.setPosition(pos)
    end
end

function gainMessiah(params)
    local obj = params.obj
    
    currentmessiah = obj
    obj.locked = true
    local cost = hasTag2(obj,"Cost:")
    cost = cost + manipulations_stacked
    obj.createButton({click_function='buyMessiah',
        function_owner=self,
        position={0,20,0},
        rotation={0,0,0},
        scale = {1,1,1},
        label=cost,
        tooltip="Spend " .. cost .. " Recruit to gain this hero card to the top of your deck before your turn ends.",
        font_size=300,
        font_color={0,0,0},
        color="Yellow",
        width=650,height=650})
    local nextcolor = getObjectFromGUID(pushvillainsguid).Call('getNextColor',Turns.turn_color)
    local turnshift = function()
        if Turns.turn_color == nextcolor then
            return true
        else
            return false
        end
    end
    Wait.condition(reckonMessiah,turnshift)
end

function reckonMessiah()
    if currentmessiah then
        currentmessiah.clearButtons()
        currentmessiah.locked = false
        currentmessiah.setPosition(getObjectFromGUID(topBoardGUIDs[2]).getPosition())
    end
end

function resolveTwist(params) 
    local cards = params.cards

    manipulations_stacked = manipulations_stacked + 1
    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
    
    Wait.condition(
        function()
            local messiah = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
            if messiah and messiah.tag == "Deck" then
                return true
            else
                return false
            end
        end,
        function()
            local messiah = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
            local messiahcontent = messiah.getObjects()
            local guids = {messiahcontent[1].guid,messiahcontent[2].guid}
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
                pile = messiah,
                guids = guids,
                label = "Pick",
                tooltip = "Pick this card to be bought for its cost + " .. manipulations_stacked .. ".",
                flip = true,
                resolve_function = 'gainMessiah',
                args = "self",
                fsourceguid = self.guid})
        end)
    return nil
end