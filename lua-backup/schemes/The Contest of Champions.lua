function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "woundsDeckGUID",
        "setupGUID"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function championContest(params)
    for i,o in pairs(params) do
        if i == "Evil" and o == true then
            local woundsdeck = getObjectFromGUID(woundsDeckGUID)
            if woundsdeck.tag == "Deck" then
                woundsdeck.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
                    flip=true,
                    smooth=true})
            else
                woundsdeck.flip()
                woundsdeck.setPositionSmooth(getObjectFromGUID(twistZoneGUID).getPosition())
            end
            broadcastToAll("Scheme Twist: Evil won the contest, so a wound was stacked next to the scheme as an Evil Triumph!")
        elseif o == false and i ~= "Evil" then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',i)
            broadcastToColor("You lost the contest, so discard a card",i,i)
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local schemeParts = table.clone(params.schemeParts)

    if twistsresolved == 1 then
        contestantsPV = table.clone(getObjectFromGUID(setupGUID).Call('returnContestants'))
    end
    local contestant = getObjectFromGUID(table.remove(contestantsPV,1))
    local color = hasTag2(contestant,"HC:",4)
    getObjectFromGUID(pushvillainsguid).Call('koCard',contestant)
    
    local contestn = 0
    local epicgrandmaster = false
    if schemeParts[4] == "The Grandmaster - epic" then
        epicgrandmaster = true
    end
    if twistsresolved < 5 then
        contestn = 2
    elseif twistsresolved < 9 then
        contestn = 4
    elseif twistsresolved < 12 then 
        contestn = 6
    end
    getObjectFromGUID(pushvillainsguid).Call('contestOfChampions',{color = color,
        n = contestn,
        winf = 'championContest',
        epicness = epicgrandmaster,
        fsourceguid = self.guid})
    return twistsresolved
end
