function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "villainDeckZoneGUID"
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

function shuffleBS(obj)
    obj.flip()
    obj.setPositionSmooth(Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1].getPosition())
    chimichangafound = chimichangafound + 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city
    broadcastToAll("Scheme Twist: Each player shuffles a bystander from their victory pile into the villain deck or gains a wound. All bystanders in the city escape.")
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,object in pairs(citycontent) do
                if object.hasTag("Bystander") then
                    object.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                    --broadcastToAll("Bystander moved to escape pile (do not discard).")
                end
            end
        end
    end
    local vildeckshuffle = function()
        local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
        Wait.time(function() vildeck.randomize() end,1)
    end
    chimichangafound = 0
    local chimichangasAdded = function()
        if chimichangafound == #Player.getPlayers() then 
            return true 
        else 
            return false 
        end
    end
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
            local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                local bystanderguids = {}
                for _,object in pairs(vpilecontent[1].getObjects()) do
                    for _,k in pairs(object.tags) do
                        if k == "Bystander" then
                            table.insert(bystanderguids,object.guid)
                        end
                    end
                end
                if bystanderguids[2] then
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                        pile = vpilecontent[1],
                        guids = bystanderguids,
                        resolve_function = 'shuffleBS',
                        tooltip = "Shuffle this bystander into the villain deck.",
                        label = "Shuffle",
                        fsourceguid = self.guid})
                elseif bystanderguids[1] then
                    vpilecontent[1].takeObject({position = vildeck.getPosition(),
                        guid = bystanderguids[1],flip=true})
                    chimichangafound = chimichangafound + 1
                else
                    click_get_wound(nil,i)
                    chimichangafound = chimichangafound + 1
                end
            elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                vpilecontent[1].flip()
                vpilecontent[1].setPositionSmooth(vildeck.getPosition())
                chimichangafound = chimichangafound + 1
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                chimichangafound = chimichangafound + 1
            end
        end
    end
    Wait.condition(vildeckshuffle,chimichangasAdded)
    return twistsresolved
end