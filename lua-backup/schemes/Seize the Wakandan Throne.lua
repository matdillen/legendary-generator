function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "mmZoneGUID"
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

function fightEffect(params)
    if params.mm then
        getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
           player_clicker_color = params.color})
        broadcastToColor("You fought a mastermind and gained the Throne's Favor!", params.color, params.color)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    
    local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
    if thronesfavor:find("mm") then
        getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",dospend = true})
        getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
        return nil
    else
        local mmloc = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
        local theloc = nil
        for i,o in pairs(mmloc) do
            theloc = i
            if o == mmZoneGUID then
                break
            end
        end
        if theloc then
            getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",player_clicker_color = "mm" .. theloc})
            cards[1].flip()
            local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
            local q = math.abs(vildeck[1].getQuantity())
            local pos = getObjectFromGUID(villainDeckZoneGUID)
            pos.y = pos.y + 2
            cards[1].setPosition(pos)
            Wait.condition(
                function() 
                    vildeck[1].randomize()
                    getObjectFromGUID(pushvillainsguid).Call('playVillains')
                end,
                function()
                    local vildeck2 = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
                    if math.abs(vildeck2[1].getQuantity()) == q + 1 then
                        return true
                    else
                        return false
                    end
                end)
                return nil
        else
            broadcastToAll("No Mastermind found?????")
            return nil
        end
    end
end