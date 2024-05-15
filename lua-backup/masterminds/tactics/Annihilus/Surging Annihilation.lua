function onLoad()
    local guids = {
        "vpileguids",
        "city_zones_guids",
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
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

function tacticEffect()
    local candidates = {}
    for _,p in pairs(Player.getPlayers()) do
        if p.color ~= Turns.turn_color then
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[p.color])[1]
            if vpilecontent and vpilecontent.tag == "Deck" then
                for _,c in pairs(vpilecontent.getObjects()) do
                    local vp = 0
                    local isAW = false
                    for _,tag in pairs(c.tags) do
                        if tag:find("VP") then
                            vp = tonumber(tag:match("%d+"))
                        elseif tag == "Group:Annihilation Wave" then
                            isAW = true
                        end
                    end
                    if isAW then
                        table.insert(candidates,p.color .. "_" .. c.guid .. "_" .. vp)
                    end
                end
            elseif vpilecontent and vpilecontent.hasTag("Group:Annihilation Wave") then
                table.insert(candidates,p.color .. "_" .. vpilecontent.guid .. "_" .. Global.Call('hasTag2',{obj = vpilecontent,tag = "VP"}))
            end
        end
    end
    if candidates[1] then
        local count = 0
        local highestid = nil
        for _,o in pairs(candidates) do
            for i,s in o:gmatch("[^_]+") do
                if i == 3 and tonumber(s) > count then
                    count = tonumber(s)
                    highestid = o
                end
            end
        end
        local result = highestid:gmatch("[^_]+")
        for i = 1,tonumber(result[3]) do
            getObjectFromGUID(pushvillainsguid).Call('getBystander',result[1])
        end
        local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[result[1]])[1]
        local pos = getObjectFromGUID(city_zones_guids[1]).getPosition()
        pos.y = pos.y + 2
        if vpilecontent.tag == "Deck" then  
            vpilecontent.takeObject({position = pos,
                smooth = true,
                guid = result[2],
                callback_function = pushGalactus})
        else
            vpilecontent.setPositionSmooth(pos)
            pushGalactus(vpilecontent)
        end
    end
end