function onLoad()   
    twistsstacked = 0
    
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID"
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

function explode_heroes(zone,n)
    local hero = getObjectFromGUID(zone).Call('getHeroUp')
    if hero then
        hero.flip()
    else
        broadcastToAll("Error: hero not found in HQ.",{1,0,0})
        return nil
    end
    if n > 1 then
        local herodeck = Global.Call('get_decks_and_cards_from_zone',"heroDeckZoneGUID")[1]
        for i = 1,n-1 do
            herodeck.takeObject({position = getObjectFromGUID(zone).getPosition(),
                flip = false,
                smooth = false})
        end
    end
end

function resolveTwist(params)
    local cards = params.cards
    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    broadcastToAll("Scheme Twist: " .. twistsstacked .. " heroes will be KO'd from the HQ!")

    local hq_cards = getObjectFromGUID(hqguids[1]).Call('getHeroDown')
    if hq_cards then
        boomstack_count = math.abs(hq_cards.getQuantity())
    else
        boomstack_count = 0
    end
    if boomstack_count < 6 - twistsstacked then
        explode_heroes(hqguids[1],twistsstacked)
    elseif boomstack_count == 6 - twistsstacked then
        explode_heroes(hqguids[1],twistsstacked)
        table.remove(hqguids,1)
    else
        explode_heroes(hqguids[1],6 - boomstack_count)
        table.remove(hqguids,1)
        explode_heroes(hqguids[2],twistsstacked - 6 + boomstack_count)
    end
    return nil
end