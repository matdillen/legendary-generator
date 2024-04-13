function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids2 = {
        "allTopBoardGUIDS",
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

function customCity(params)
    local altcity = params.altcity

    if altcity and altcity == "Top" then
        return current_city2
    elseif altcity and altcity == "Bottom" then
        return current_city
    else
        return city_zones_guids
    end
end

function villainDeckSpecial(params)
    local vildeck = Global.Call('get_decks_and_cards_from_zone',villainDeckZoneGUID)[1]
    vildeck.flip()
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 7,9 do
        mmZone.Call('lockTopZone',allTopBoardGUIDS[i])
    end
    vildeck.randomize()
    vildeck.setPositionSmooth(getObjectFromGUID(city_zones_guids[3]).getPosition())
    current_city = table.clone(city_zones_guids)
    table.remove(current_city,2)
    table.remove(current_city,2)
    current_city2 = {city_zones_guids[1]}
    for i = 1,3 do
        table.insert(current_city2,allTopBoardGUIDS[10-i])
    end
    local pushvillain = getObjectFromGUID(pushvillainsguid)
    pushvillain.Call('updateCity',{newcity = curent_city})
    pushvillain.Call('updateCity',{name = "current_city2",
        newcity = current_city2})
    pushvillain.Call('updateVar',{varname = "villainDeckZoneGUID",
        varvalue = city_zones_guids[3]})
    local butt = pushvillain.getButtons()
    for i,o in pairs(butt) do
        if o.click_function == "click_push_villain_into_city" then
            pushvillain.removeButton(i-1)
            break
        end
    end
    pushvillain.createButton({
        click_function="pushTopDimension", function_owner=self,
        position={0,1,-1.2}, label="Top City", color={0.8,1,0.8,1}, width=2000, height=1000,
        tooltip = "Push villains into the top city dimension or charge once",
        font_size = 250
    })
    pushvillain.createButton({
        click_function="pushBottomDimension", function_owner=self,
        position={0,1,1.2}, label="Bottom City", color={1,0.8,1,1}, width=2000, height=1000,
        tooltip = "Push villains into the bottom city dimension or charge once",
        font_size = 250
    })
end

function pushTopDimension()
    local pushvillain = getObjectFromGUID(pushvillainsguid)
    pushvillain.Call('delayCityPush')
    pushvillain.Call('checkCityContent2',{altcity = "Top"})
end
function pushBottomDimension()
    local pushvillain = getObjectFromGUID(pushvillainsguid)
    pushvillain.Call('delayCityPush')
    pushvillain.Call('checkCityContent2',{altcity = "Bottom"})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    broadcastToAll("Scheme Twist: Two cards are played from the villain deck!")
    return twistsresolved
end