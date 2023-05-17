function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS"
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    if twistsresolved == 6 then
        invertedcity = {}
        for i=1,5 do
            table.insert(invertedcity,city[6-i])
        end
    end
    if twistsresolved == 1 then
        self.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[11]).getPosition())
    elseif twistsresolved < 6 then
        local citycontent = getObjectFromGUID(city[twistsresolved-1]).getObjects()
        if citycontent then
            for _,o in pairs(citycontent) do
                if o.tag == "Figurine" then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.getName():gsub(" Player",""))
                end
            end
        end
        self.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[12-twistsresolved]).getPosition())
        Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city') end,1)
    elseif twistsresolved < 10 then
        local citycontent = getObjectFromGUID(invertedcity[twistsresolved-5]).getObjects()
        if citycontent then
            for _,o in pairs(citycontent) do
                if o.tag == "Figurine" then
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.getName():gsub(" Player",""))
                end
            end
        end
        self.setPositionSmooth(getObjectFromGUID(allTopBoardGUIDS[twistsresolved+2]).getPosition())
        local inverted_push = function()
            local city_topush = table.clone(invertedcity)
            local cardfound = false
            while cardfound == false do
                local citycontent = Global.Call('get_decks_and_cards_from_zone',city_topush[1])
                local locationfound = false
                if citycontent[1] and not citycontent[2] then
                    if citycontent[1].getDescription():find("LOCATION") then
                        locationfound = true
                    end
                end
                if not next(citycontent) or locationfound == true then
                    table.remove(city_topush,1)
                else
                    cardfound = true
                end
                if not city_topush[1] then
                    cardfound = true
                end
            end
            if city_topush[1] then
                getObjectFromGUID(pushvillainsguid).Call('push_all2',city_topush)
            end
        end
        Wait.time(inverted_push,1)
    elseif twistsresolved == 10 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return nil
end
