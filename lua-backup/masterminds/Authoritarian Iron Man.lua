function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local city = params.city
    local mmname = params.mmname
    local mmloc = params.mmloc

    local mm = nil
    local pos = nil
    if not city[#current_city-strikesresolved] then
        broadcastToAll("Master Strike: City too small for " .. mmname .. " to move!")
        return strikesresolved
    else
        pos = getObjectFromGUID(city[#city-strikesresolved]).getPosition()
        pos.z = pos.z+2
    end
    if strikesresolved == 1 then
        mm = Global.Call('get_decks_and_cards_from_zone',mmloc)
        if mm[1] then
            for _,o in pairs(mm) do
                if o.getName() == "Authoritarian Iron Man" and o.tag == "Card" then
                    getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = o,
                        label = "+3",
                        tooltip = "Villains in the fortified city space get +3.",
                        id = "fortifying",
                        otherposition = {0,22,1.8}})
                    o.setDescription(o.getDescription() .. "\r\nLOCATION: Keyword to indicate he's only fortifying this space.")
                    break
                end
            end
        else
            broadcastToAll("Master Strike: Authoritarian Iron Man not found?")
            return nil
        end
    elseif strikesresolved < 6 then
        mm = Global.Call('get_decks_and_cards_from_zone',current_city[#current_city-strikesresolved+2])
        --what happens to iron man if his city space is destroyed? nothing?
    else
        return strikesresolved
    end
    if not mm[1] then
        broadcastToAll("Master Strike: Authoritarian Iron Man not found?")
        return nil
    else
        for _,o in pairs(mm) do
            if strikesresolved > 1 or (o.getName() == "Authoritarian Iron Man" and o.tag == "Card") then
                o.setPositionSmooth(pos)
                broadcastToAll("Master Strike: Authoritarian Iron Man fortifies a new city space!")
            end
        end
    end
    return strikesresolved
end
