function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "kopile_guid",
        "bystandersPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
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
    log("6 bystanders next to scheme")
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    local pos = getObjectFromGUID(twistZoneGUID).getPosition()
    for i=1,6 do
        bsPile.takeObject({position = pos,
            flip=false,smooth=false})
    end
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = kopile_guid,
                ["tooltip"] = "KO'd nongrey heroes: __/16."}
    else 
        local escaped = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if escaped[1] then
            local counter = 0
            for _,o in pairs(escaped) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "HC:",find=true})
                    if escapees then
                        counter = counter + #escapees
                    end
                elseif hasTag2(o,"HC:") then
                    counter = counter + 1
                end
            end
            return counter
        else
            return 0
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    local negabomb = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    cards[1].flip()
    cards[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
    local twistMoved = function()
        local negabomb_check = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
        if negabomb_check[1] and negabomb_check[1].getQuantity() == 7 then
            return true
        else
            return false
        end
    end
    local triggerBomb = function()
        local negabomb = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)[1]
        negabomb.randomize()
        local negabombcontent = negabomb.getObjects()
        if negabombcontent[1].name == "Scheme Twist" then
            broadcastToAll("Scheme Twist: Nega Bomb detonated. All heroes in HQ KO'd and every player wounded.")
            negabomb.takeObject({position=getObjectFromGUID(kopile_guid).getPosition(),
                flip=true})
            getObjectFromGUID(pushvillainsguid).Call('dealWounds')
            for _,o in pairs(hqguids) do
                local hero = getObjectFromGUID(o).Call('getHeroUp')
                if hero then
                    hero.setPositionSmooth(getObjectFromGUID(kopile_guid).getPosition())
                    getObjectFromGUID(o).Call('click_draw_hero')
                end
            end
        else
            broadcastToAll("Scheme Twist: Nega Bomb detonation averted (for now) and bystander rescued.")
            local dest = getObjectFromGUID(vpileguids[Turns.turn_color]).getPosition()
            dest.y = dest.y + 2
            negabomb.takeObject({position=dest,
                flip=true})
        end
    end
    Wait.condition(triggerBomb,twistMoved)
    return nil
end
