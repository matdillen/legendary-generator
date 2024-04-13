function onLoad()
    vildeckcount = 0
    wwiiInvasion = false
    
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "twistPileGUID",
        "twistZoneGUID"
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

function cityShift(params)
    if not wwiiInvasion or wwiiInvasion == false then
        wwiiInvasion = true
        getObjectFromGUID(twistPileGUID).takeObject({position=getObjectFromGUID(twistZoneGUID).getPosition(),
            smooth=false,
            callback_function = function(obj)
                obj.setName("Conquered Capital")
            end})
        broadcastToAll("The Axis successfully conquered this country!")
    end
    return params.obj
end

function nonCityZoneShade(guid)
    getObjectFromGUID(guid).createButton({
        click_function="nonCityZone",
        function_owner=self,
        position={0,-0.5,0},
        height=470,
        width=700,
        color={1,0,0,0.9}})
end

function nonCityZone(obj,player_clicker_color)
    broadcastToColor("This city zone does not currently exist!",player_clicker_color,player_clicker_color)
end

function vildeckLanded()
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    if vildeck and vildeck.getQuantity() == vildeckcount then
        return true
    else 
        return false
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local city = params.city
    getObjectFromGUID(pushvillainsguid).Call('koCard',cards[1])
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    vildeckcount = math.abs(vildeck.getQuantity())
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
        if citycontent[1] then
            for _,card in pairs(citycontent) do
                if card.hasTag("Villain") or card.hasTag("Bystander") or card.getDescription():find("VILLAINOUS WEAPON") then
                    card.flip()
                    card.setPosition(vildeck.getPosition())
                    vildeckcount = vildeckcount + 1
                end
            end
        end
    end
    if vildeckcount ~= math.abs(vildeck.getQuantity()) then
        local vildeckpos = vildeck.getPosition()
        vildeckpos.y = vildeckpos.y + 3
        vildeck.setPositionSmooth(vildeckpos)
    end
    if twistsresolved < 8 then
        local wwcountries = {4,3,6,3,5,2,1}
        broadcastToAll("Scheme Twist: The axis invade another country and the city is now " .. wwcountries[twistsresolved] .. " spaces!")
        for i,o in pairs(city_zones_guids) do
            local zone = getObjectFromGUID(o)
            if zone.getButtons() then
                for j,b in pairs(zone.getButtons()) do
                    if b.click_function == "nonCityZone" then
                        zone.removeButton(j-1)
                        break
                    end
                end
            end
        end
        if not getObjectFromGUID("bd3ef1").getButtons() then
            nonCityZoneShade("bd3ef1")
        end
        if not getObjectFromGUID("d30aa1").getButtons() then
            nonCityZoneShade("d30aa1")
        end
        if getObjectFromGUID("d30aa1").getButtons() and twistsresolved == 3 then
            getObjectFromGUID("d30aa1").removeButton(0)
        end
        local current_city = table.clone(city_zones_guids)
        table.remove(current_city,1)
        if wwcountries[twistsresolved] < 5 then
            for i=1,#current_city - wwcountries[twistsresolved] do
                table.remove(current_city)
            end
            table.insert(current_city,1,city_zones_guids[1])
        elseif wwcountries[twistsresolved] > 5 then
            table.insert(current_city,"d30aa1")
            table.insert(current_city,1,city_zones_guids[1])
        else
            table.insert(current_city,1,city_zones_guids[1])
        end
        for i,o in pairs(city_zones_guids) do
            if not current_city[i] then
                nonCityZoneShade(o)
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('updateCity',{newcity = current_city})
    end
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,
        condition_f="vildeckLanded",
        fsourceguid = self.guid})
    wwiiInvasion = false
    return nil
end