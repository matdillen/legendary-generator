function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
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

function bonusInCity(params)
    if params.object.hasTag("Villain") then
        local cards = Global.Call('get_decks_and_cards_from_zone',params.zoneguid)
        local bonus = 0
        for _,o in pairs(cards) do
            if o.tag == "Deck" then
                for _,c in pairs(o.getObjects()) do
                    for _,t in pairs(c.tags) do
                        if t == "Bystander" then
                            bonus = bonus + 1
                            break
                        end
                    end
                end
            elseif o.hasTag("Bystander") then
                bonus = bonus + 1
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
                label = bonus,
                zoneguid = params.zoneguid,
                tooltip = "This villain gets +1 for each bystander it captured.",
                id="bankrobbery"})
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Bystanders escaped: __/8.",
                ["zoneguid"] = escape_zone_guid}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Bystander"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Bystander") then
            counter = counter + 1
        end
        return counter
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local bankz = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[3])
    if bankz[1] then
        for _,o in pairs(bankz) do
            if o.hasTag("Villain") then
                getObjectFromGUID(pushvillainsguid).Call('addBystanders',city_zones_guids[3])
                getObjectFromGUID(pushvillainsguid).Call('addBystanders',city_zones_guids[3])
                Wait.time(function()
                    getObjectFromGUID(pushvillainsguid).Call('updatePower')
                end,0.5)
                break
            end
        end
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains')
    return twistsresolved
end