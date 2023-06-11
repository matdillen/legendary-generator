function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "officerDeckGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "pos_discard"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    local guids3 = {
        "playerBoards",
        "attackguids"
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

function gainShieldChoice(params)
    local obj = params.obj
    local player_clicker_color = params.player_clicker_color
    
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local dest = playerBoard.positionToWorld(pos_discard)
    dest.y = dest.y + 3
    local angle = 0
    if player_clicker_color == "White" then
        angle = 90
    elseif player_clicker_color == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    obj.setPositionSmooth(dest)
    obj.setRotationSmooth(brot)
end

function gainShield(params)
    local obj = params.obj
    local player_clicker_color = params.player_clicker_color
    
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])[1]
    if hulkdeck.tag == "Card" then
        gainShieldChoice({obj = hulkdeck,player_clicker_color = player_clicker_color})
    else
        broadcastToColor("Choose an Officer to gain.",player_clicker_color,player_clicker_color)
        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = player_clicker_color,
            pile = hulkdeck,
            resolve_function = "gainShieldChoice",
            args = "self",
            label = "Gain",
            tooltip = "Gain this Officer.",
            fsourceguid = self.guid})
    end
end

function click_buy_hammer(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 3 then
        broadcastToColor("You don't have enough attack to fight this villain!",player_clicker_color,player_clicker_color)
        return nil
    end
    local hand = Player[player_clicker_color].getHandObjects()
    local shield = {}
    for _,h in pairs(hand) do
        if h.hasTag("Starter") or h.hasTag("Team:SHIELD") or h.hasTag("Team:HYDRA") then
            table.insert(shield,h)
        end
    end
    if shield[1] then
        getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-3)
        broadcastToColor("Discard a SHIELD or HYDRA hero to get SHIELD clearance!",player_clicker_color,player_clicker_color)
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = player_clicker_color,
            hand = shield,
            trigger_function = "gainShield",
            args = "self",
            fsourceguid = self.guid})
    else
        broadcastToColor("You need a SHIELD or HYDRA hero to discard for SHIELD clearance!",player_clicker_color,player_clicker_color)
        return nil
    end
end

function updatePower()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function updateButtons()
    local officers = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])[1]
    if not officers then
        getObjectFromGUID(topBoardGUIDs[2]).clearButtons()
    elseif not getObjectFromGUID(topBoardGUIDs[2]).getButtons() then
        getObjectFromGUID(topBoardGUIDs[2]).createButton({
             click_function="click_buy_hammer", 
             function_owner=self,
             position={0,0,0.5},
             rotation={0,180,0},
             label="Fight",
             tooltip="Fight one of the officers to gain it as a hero.",
             color={0,0,0,1},
             font_color = {1,0,0},
             width=500,
             height=200,
             font_size = 100
        })
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{label = 3,
            tooltip = "Fight these officers for 3 to gain them as heroes.",
            id = "hammer",
            zoneguid = topBoardGUIDs[2],
            ignore_f = "click_buy_hammer"})
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        function onObjectEnterZone(zone,object)
            if zone.guid == topBoardGUIDs[2] then
                updateButtons()
            end
        end

        function onObjectLeaveZone(zone,object)
            if zone.guid == topBoardGUIDs[2] then
                updateButtons()
            end
        end
    end
    local sostack = getObjectFromGUID(officerDeckGUID)
    for i = 1,twistsresolved do
        sostack.takeObject({position=getObjectFromGUID(topBoardGUIDs[2]).getPosition(),
            flip=true,smooth=false})
    end
    return nil
end