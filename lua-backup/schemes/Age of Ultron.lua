function onLoad()
    local guids1 = {
        "heroDeckZoneGUID",
        "twistZoneGUID",
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids2 = {
        "hqguids"
     }
     
     for _,o in pairs(guids2) do
         _G[o] = table.clone(Global.Call('returnVar',o))
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

function bonusInCity(params)
    if params.object.getName() == "Evolved Ultron" then
        local ultronpower = 0
        local evolutionPile = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
        local evolutionPileSize = 0
        if evolutionPile[1] then
            if evolutionPile[1].tag == "Deck" then
                evolutionPileSize = #evolutionPile[1].getObjects()
            elseif evolutionPile[1] then
                evolutionPileSize = 1
            end
        else
            return nil
        end
        local evolutionColors = {
                ["HC:Red"] = false,
                ["HC:Green"] = false,
                ["HC:Yellow"] = false,
                ["HC:Blue"] = false,
                ["HC:Silver"] = false
        }
        if evolutionPileSize > 1 then
            for _,o2 in pairs(evolutionPile[1].getObjects()) do
                for _,k in pairs(o2.tags) do
                    if k:find("HC:") then
                        evolutionColors[k] = true
                    end
                    if k:find("HC1:") or k:find("HC2:") then
                        evolutionColors["HC:".. k:sub(5)] = true
                    end
                end
            end
        else
            for _,o2 in pairs(evolutionPile[1].getTags()) do
                if o2:find("HC:") then
                    evolutionColors[o2] = true
                end
                if o2:find("HC1:") or o2:find("HC2:") then
                    evolutionColors["HC:".. o2:sub(5)] = true
                end
            end
        end
        for i2,o2 in pairs(hqguids) do
            local herocard = getObjectFromGUID(o2).Call('getHeroUp')
            if herocard then
                for _,tag in pairs(herocard.getTags()) do
                    if tag:find("HC:") then
                        if evolutionColors[tag] == true then
                            ultronpower = ultronpower + 1
                            break
                        end
                    end
                    if tag:find("HC1:") or tag:find("HC2:") then
                        if evolutionColors["HC:".. tag:sub(5)] == true then
                            ultronpower = ultronpower + 1
                            break
                        end
                    end
                end
            else
                broadcastToAll("Hero in hq space " .. i2 .. " is missing?")
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
            label = "+" .. ultronpower,
            zoneguid = params.zoneguid,
            id = "empowered",
            tooltip = "Empowered for colors of heroes in the Evolution pile."})
    end
end

function updatePower()
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    log(cards)
    function ultronCallback(obj)
        Wait.time(updatePower,1)
    end
    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)
    if herodeck[1] then
        if herodeck[1].tag == "Deck" then
            herodeck[1].takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                flip=true,
                callback_function = ultronCallback})
        else
            herodeck[1].flip()
            herodeck[1].setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
            Wait.time(updatePower,1)
        end
    end
    cards[1].setName("Evolved Ultron")
    cards[1].setTags({"VP6","Villain","Power:4"})
    cards[1].setDescription("EMPOWERED: This card gets extra Power for each Hero with the listed Hero Class in the Evolution Pile.")
    return twistsresolved
end