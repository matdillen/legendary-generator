function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "woundsDeckGUID",
        "setupGUID",
        "heroDeckZoneGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "topBoardGUIDs"
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

function setupSpecial(params)
    local heroParts = {}
    for s in string.gmatch(params.setupParts[8],"[^|]+") do
        table.insert(heroParts, string.lower(s))
    end
    local heroDeckComplete = function()
        local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1]
        if herodeck and herodeck.getQuantity() == #heroParts*14 then
            return true
        else
            return false
        end
    end
    local makeChampions = function()
        local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1]
        herodeck.randomize()
        if not herodeck.is_face_down then
            herodeck.flip()
        end
        local mmZone = getObjectFromGUID(mmZoneGUID)
        for i = 1,8 do
            mmZone.Call('lockTopZone',topBoardGUIDs[i])
        end
        mmZone.Call('lockTopZone',"f394e1")
        mmZone.Call('lockTopZone',"0559f8")
        mmZone.Call('lockTopZone',"39e3d7")
        local posi = getObjectFromGUID(topBoardGUIDs[1])
        log("Putting 11 contestants above the board!")
        contestants = {}
        logContestant = function(obj)
            table.insert(contestants,obj.guid)
        end
        for i=1,11 do
            Wait.time(function() herodeck.takeObject({
                position = {x=posi.getPosition().x+4*i,y=posi.getPosition().y,z=posi.getPosition().z},
                flip = true,
                callback_function = logContestant
            }) end,i/3)
        end
    end
    Wait.condition(makeChampions,heroDeckComplete)
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

    local contestant = getObjectFromGUID(table.remove(contestants,1))
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
