function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID",
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

function table.clone(params)
    if params.key then
        local new = {}
        for i,o in pairs(params.org) do
            new[i] = o
        end
        return new
    else
        return {table.unpack(params.org)}
    end
end

function pushGalactus(obj)
    Wait.condition(
        function()
            getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
        end,
        function()
            local content = Global.Call('get_decks_and_cards_from_zone',city_zones_guids[1])[1]
            if content and content.guid == obj.guid then
                return true
            else
                return false
            end
        end)
end

function tacticEffect(params)
    local zoneGUID = params.zoneGUID

    local mmcontent = Global.Call('get_decks_and_cards_from_zone',zoneGUID)
    local tacticfound = false
    if mmcontent[1] then
        for _,o in pairs(mmcontent) do
            if Global.Call('hasTag2',{obj = o,tag = "Tactic:"}) then
                tacticfound = true
                break
            elseif o.tag == "Deck" and Global.Call('hasTagD',{deck = o,tag = "Tactic:",find = true}) then
                tacticfound = true
                break
            end
        end
    end
    if not tacticfound then
        return nil
    end
    local city = table.clone(getObjectFromGUID(pushvillainsguid).Call('returnVar',"current_city"))
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,c in pairs(citycontent) do
                if c.getName() == "Weaponized Galactus" then
                    getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycontent,
                        currentZone = getObjectFromGUID(o),
                        targetZone = getObjectFromGUID(escape_zone_guid)})
                    return nil
                end
            end
        end
    end
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)
    if vildeck[1] and vildeck[1].tag == "Deck" then
        for _,o in pairs(vildeck[1].getObjects()) do
            if o.name == "Weaponized Galactus" then
                local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
                pos.y = pos.y + 2
                vildeck[1].takeObject({position = pos,
                    smooth = false,
                    guid = o.guid,
                    callback_function = pushGalactus})
            end
        end
    else
        broadcastToAll("Villain deck not found? Check if Weaponized Galactus is in the villain deck as he needs to enter the city.")
    end
end