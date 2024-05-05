function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "hmPileGUID",
        "mmZoneGUID",
        "setupGUID",
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
        "playerBoards",
        "vpileguids",
        "attackguids"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function table.clone(val)
    local new = {}
    for i,o in pairs(val) do
        new[i] = o
    end
    return new
end

function renameHenchmen(obj)
    for i=1,10 do
        local cardTaken = obj.takeObject({position=getObjectFromGUID(topBoardGUIDs[2]).getPosition()})
        cardTaken.setName("Annihilation Wave Henchmen")
        if not henchpower then
            henchpower = hasTag2(cardTaken,"Power:")
        end
    end
end

function setupSpecial(params)
    log("Add extra annihilation group." .. params.setupParts[9])
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = params.setupParts[9],
        pileGUID = hmPileGUID,
        destGUID = topBoardGUIDs[1],
        callbackf = "renameHenchmen",
        fsourceguid = self.guid})
    for i = 1,2 do
        getObjectFromGUID(mmZoneGUID).Call('lockTopZone',topBoardGUIDs[i])
    end
    log("Annihilation group " .. params.setupParts[9] .. " moved next to the scheme.")
end

function click_buy_annihilation(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < henchpower then
        broadcastToColor("You don't have enough attack to fight this villain!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-henchpower)
    local dest = getObjectFromGUID(vpileguids[player_clicker_color]).getPosition()
    dest.y = dest.y + 3
    if hulkdeck.tag == "Card" then
        hulkdeck.setPositionSmooth(dest)
    else
        hulkdeck.takeObject({position=dest,flip=false,smooth=true})
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
        getObjectFromGUID(topBoardGUIDs[1]).createButton({
            click_function="updatePower", 
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label=henchpower,
            tooltip="You can fight this Annihilation Wave henchmen for " .. henchpower .. ".",
            font_color="Red",
            width=0,
            font_size = 250
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
    henchcaught = henchcaught + Global.Call('findInPiles',{
        guid = kopile_guid,
        name = "Annihilation Wave Henchmen",
        targetGUID = topBoardGUIDs[2]
    })
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