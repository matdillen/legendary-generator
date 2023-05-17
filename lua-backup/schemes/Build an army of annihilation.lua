function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs",
        "pos_vp2"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "playerBoards",
        "vpileguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
end

function table.clone(val)
    local new = {}
    for i,o in pairs(val) do
        new[i] = o
    end
    return new
end

function click_buy_annihilation(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local dest = playerBoard.positionToWorld(pos_vp2)
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved == 1 then
        getObjectFromGUID(topBoardGUIDs[1]).createButton({
             click_function="click_buy_annihilation", 
             function_owner=self,
             position={0,0,0.5},
             rotation={0,180,0},
             label="Fight",
             tooltip="Fight one of the Annihilation Wave henchmen.",
             color={0,0,0,1},
             font_color = {1,0,0},
             width=500,
             height=200,
             font_size = 100
        })
    end
    local annihilationZone = getObjectFromGUID(topBoardGUIDs[2])
    local annihilationdeck = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])
    local henchpresent = 0
    if annihilationdeck[1] then
        henchpresent = annihilationdeck[1].getQuantity()
    end
    local henchcaught = 0
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
            local annihilationguids = {}
            if vpilecontent[1] then
                if vpilecontent[1].getQuantity() > 1  then
                    for _,j in pairs(vpilecontent[1].getObjects()) do
                        if j.name == "Annihilation Wave Henchmen" then
                            table.insert(annihilationguids,j.guid)
                        end
                    end
                    henchcaught = henchcaught + #annihilationguids
                    if vpilecontent[1].getQuantity() ~= #annihilationguids then
                        for j = 1,#annihilationguids do
                            vpilecontent[1].takeObject({position=annihilationZone.getPosition(),
                                guid=annihilationguids[j]})
                        end
                    else
                        vpilecontent[1].setPositionSmooth(annihilationZone.getPosition())
                    end
                else
                    if vpilecontent[1].getName() == "Annihilation Wave Henchmen" then
                        vpilecontent[1].setPositionSmooth(annihilationZone.getPosition())
                        henchcaught = henchcaught + 1
                    end
                end
            end
        end
    end
    local annihilationMMzone = getObjectFromGUID(topBoardGUIDs[1])
    local refeedMM = function()
        local deck = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])
        local annihilationcount = 0
        if deck[1] then
            annihilationcount = math.abs(deck[1].getQuantity())
        end
        for i=1,twistsresolved do
            if i < annihilationcount then
                deck[1].takeObject({position=annihilationMMzone.getPosition()})
                if deck[1].remainder then
                    deck[1] = deck[1].remainder
                end
            elseif i == annihilationcount then
                deck[1].setPositionSmooth(annihilationMMzone.getPosition())
            else
                broadcastToAll("Not enough annihilation wave henchmen left! Evil wins?")
                return nil
            end
        end
        broadcastToAll(twistsresolved .. " annihilation henchmen moved to the mastermind!")
    end
    local anniGathered = function()
        local deck = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[2])
        if deck[1] and deck[1].getQuantity() == henchpresent + henchcaught then
            return true
        else
            return false
        end
    end
    Wait.condition(refeedMM,anniGathered)
    return nil
end