function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local mmname = params.mmname
    local epicness = params.epicness
    local mmloc = params.mmloc
    local strikeloc = params.strikeloc
    
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    local tags = nil
    local cardtype = nil
    if vildeck.tag == "Deck" then
        tags = vildeck.getObjects()[1].tags
        cardtype = vildeck.getObjects()[1].name
    else
        tags = vildeck.getTags()
        cardtype = vildeck.getName()
    end
    for _,o in pairs(tags) do
        if o == "Villain" then
            cardtype = "Villain"
            break
        elseif o == "Bystander" then
            cardtype = "Bystander"
            break
        end
    end
    if epicness == true then
        if cardtype == "Villain" then
            getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
            broadcastToAll("Master Strike: Epic Annihilus plays a villain and therefore another card from the villain deck as well!")
        else
            getObjectFromGUID(pushvillainsguid).Call('playVillains')
            broadcastToAll("Master Strike: Epic Annihilus plays a villain card, but it's not a villain.")
        end
    else
        if cardtype == "Villain" then
            getObjectFromGUID(pushvillainsguid).Call('playVillains')
            Wait.time(click_push_villain_into_city,2)
            Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('addBystanders',city_zones_guids[2]) end,2.5)
            Wait.time(click_push_villain_into_city,4)
            broadcastToAll("Master Strike: Annihilus plays a villain, it captures a bystander and pushes the city forward!")
        elseif cardtype == "Bystander" then
            local pos = getObjectFromGUID(mmloc).getPosition()
            pos.z = pos.z - 2
            vildeck.takeObject({position = pos, 
                flip = true, 
                smooth = true})
            broadcastToAll("Master Strike: Annihilus captures a bystander from the villain deck!")
        else
            broadcastToAll("Master Strike: " .. cardtype .. " was revealed from the villain deck!")
        end
    end
    return strikesresolved
end
