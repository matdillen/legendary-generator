function onLoad()
    mmname = "Magus"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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

function updateMMMagus()
    local shardsfound = 0
    for _,o in pairs(city_zones_guids) do
        if o ~= city_zones_guids[1] then
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.getName() == "Shard" then
                        shardsfound = shardsfound + 1
                        break
                    end
                end
            end
        end
    end
    local boost = 1
    if epicness then
        boost = 2
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = shardsfound,
        label = "+" .. boost*shardsfound,
        tooltip = "Magus gets + " .. boost .. " for each Villain in the city that has any Shards.",
        f = 'updateMMMagus',
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    updateMMMagus()
    function onObjectEnterZone(zone,object)
        updateMMMagus()
    end
    function onObjectLeaveZone(zone,object)
        updateMMMagus()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city

    local shardfound = false
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.getName() == "Shard" then
                    shardfound = true
                    break
                end
            end
            if shardfound == true then
                local top = nil
                if epicness then
                    top = true
                end
                getObjectFromGUID(pushvillainsguid).Call('dealWounds',top)
                break
            end
        end
    end
    if cards[1] then
        local boost = 4
        if epicness then
            boost = 6
        end
        cards[1].setName("Cosmic Wraith")
        cards[1].addTag("VP" .. boost)
        cards[1].addTag("Power:" .. boost)
        cards[1].addTag("Villain")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
            label = boost,
            tooltip = "This strike is a Cosmic Wraith villain."})
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
        local addshard = function()
            for _,o in pairs(city) do
                local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
                if citycontent[1] then
                    for _,obj in pairs(citycontent) do
                        if obj.hasTag("Villain") then
                            getObjectFromGUID(pushvillainsguid).Call('gainShard2',{zoneGUID = o})
                            break
                        end
                    end
                end
            end
        end
        local cardLanded = function()
            local pos = cards[1].getPosition()
            if not cards[1].isSmoothMoving() and pos.z > 0 and pos.y < 2 then
                return true
            else
                return false
            end
        end
        Wait.condition(addshard,cardLanded)
        return nil
    end
    return strikesresolved
end