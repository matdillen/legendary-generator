function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

    if twistsresolved == 1 then
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local mmname = nil
        for i,o in pairs(table.clone(mmZone.Call('returnVar',"mmLocations"),true)) do
            if o == mmZoneGUID then
                mmname = i
                break
            end
        end
        getObjectFromGUID(mmZoneGUID).Call('mmButtons',
            {mmname = mmname,
            checkvalue = 1,
            label = "+1",
            tooltip = "A dark portal gives the mastermind + 1.",
            f = "mm",
            id = "darkportal" .. twistsresolved})
        broadcastToAll("Scheme Twist: A dark portal reinforces the mastermind!")
    elseif twistsresolved < 7 then
        if city[7-twistsresolved] then
            getObjectFromGUID(city[7-twistsresolved]).Call('updateZonePower',{label = "+1",
                tooltip = "The Dark Portal gives the villain in this city space +1.",
                id = "darkportal"})
            broadcastToAll("Scheme Twist: A dark portal reinforces a city space!")
        else
            koCard(cards[1])
            broadcastToAll("Scheme Twist: But the city zone does not exist? KO'ing the dark portal.")
        end
    elseif twistsresolved == 7 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end
