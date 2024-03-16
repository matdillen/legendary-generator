function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "sidekickZoneGUID",
        "officerZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
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

function fightEffect(params)
    if not params.mm then
        local pos = getObjectFromGUID(vpileguids[params.color]).getPosition()
        local zoneobjects = Global.Call('get_decks_and_cards_from_zone',params.zoneguid)
        for i,o in pairs(zoneobjects) do
            if o.tag == "Deck" then
                local heroes = {}
                for _,c in pairs(o.getObjects()) do
                    for _,tag in pairs(c.tags) do
                        if tag == "Hero" then
                            table.insert(heroes,c.guid)
                            break
                        end
                    end
                end
                if #heroes == o.getQuantity() then
                    o.setPosition(pos)
                else
                    for _,h in pairs(heroes) do
                        o.takeObject({position = pos,
                            guid = h})
                    end
                end
            elseif o.hasTag("Hero") then
                o.setPosition(pos)
            end
        end
    end
end

function bonusInCity(params)
    local zoneobjects = Global.Call('get_decks_and_cards_from_zone',params.zoneguid)
    local heroes = 0
    for i,o in pairs(zoneobjects) do
        if o.tag == "Deck" then
            for _,c in pairs(o.getObjects()) do
                for _,tag in pairs(c.tags) do
                    if tag == "Hero" then
                        heroes = heroes + 1
                        break
                    end
                end
            end
        elseif o.hasTag("Hero") then
            heroes = heroes + 1
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('powerButton',{
        obj = params.object, 
        label = "+" .. heroes,
        zoneguid = params.zoneguid,
        tooltip = "This villain is Crushing HYDRA and gets +1 for each hero it captured.",
        id = "crushhydra"})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city
    if twistsresolved < 8 then
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,k in pairs(citycontent) do
                    if k.hasTag("Villain") then
                        local pos = k.getPosition()
                        pos.z = pos.z - 2
                        local skpile = Global.Call('get_decks_and_cards_from_zone',sidekickZoneGUID)
                        if skpile[1] and skpile[1].tag == "Deck" then
                            skpile.takeObject({position=pos,flip=true})
                        elseif skpile[1] then
                            skpile[1].flip()
                            skpile[1].setPosition(pos)
                        else
                            local sopile = Global.Call('get_decks_and_cards_from_zone',officerZoneGUID)
                            if sopile[1] and sopile[1].tag == "Deck" then
                                sopile.takeObject({position=pos,flip=true})
                            elseif sopile[1] then
                                sopile[1].flip()
                                sopile[1].setPosition(pos)
                            else
                                broadcastToAll("No sidekicks or officers found to be captured by villains in the city?")
                                return nil
                            end
                        end
                        break
                    end
                end
            end
        end
    elseif twistsresolved == 8 then
        broadcastToAll("Scheme Twist 8: All heroes in the city escape (don't KO anything)!")
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,k in pairs(citycontent) do
                    if k.hasTag("Sidekick") or k.hasTag("Officer") or hasTag2(k,"Cost:") then
                        k.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                    end
                end
            end
        end
    end
    return twistsresolved
end