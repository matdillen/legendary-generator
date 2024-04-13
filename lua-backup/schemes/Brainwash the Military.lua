function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "officerDeckGUID",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupSpecial(params)
    log("12 officers in villain deck.")
    local sopile = getObjectFromGUID(officerDeckGUID)
    local vilDeckZone = getObjectFromGUID(villainDeckZoneGUID)
    sopile.randomize()
    for i=1,12 do
        sopile.takeObject({position=vilDeckZone.getPosition(),
            flip=true,
            smooth=false})
    end
    return {["villdeckc"] = 12}
end

function bonusInCity(params)
    if params.object.hasTag("Brainwashed") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object,
            label = "+" .. params.twistsstacked,
            zoneguid = params.zoneguid,
            tooltip = "This brainwashed SHIELD Officer gets +1 for each twist stacked next to the scheme.",
            id = "brainwashed"})
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Officer") then
        obj.addTag("Brainwashed")
        obj.addTag("Villain")
        obj.addTag("Power:3")
    end
    return 1
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local city = params.city
    if twistsresolved < 7 then
        getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
        getObjectFromGUID(pushvillainsguid).Call('playVillains')
        Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('updatePower') end,1)
        broadcastToAll("Scheme Twist: Another card was played from the villain deck!")
        return nil
    elseif twistsresolved == 7 then
        broadcastToAll("Scheme Twist: All SHIELD Officers in the city escape!")
        for _,o in pairs(city) do
            local cardsincity = Global.Call('get_decks_and_cards_from_zone',o) 
            if cardsincity[1] then
                for _,object in pairs(cardsincity) do
                    if object.hasTag("Officer") == true then
                        object.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
                        broadcastToAll("S.H.I.E.L.D. Officer escaped!",{r=1,g=0,b=0})
                    end
                end
            end
        end
    end
    return twistsresolved
end