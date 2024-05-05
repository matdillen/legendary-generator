function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "sidekickDeckGUID",
        "sidekickZoneGUID",
        "escape_zone_guid",
        "villainDeckZoneGUID"
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
        "playerBoards"
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

function setupSpecial(params)
    log("10 sidekicks in villain deck.")
    local skpile = getObjectFromGUID(sidekickDeckGUID)
    local vilDeckZone = getObjectFromGUID(villainDeckZoneGUID)
    skpile.randomize()
    for i=1,10 do
        skpile.takeObject({position=vilDeckZone.getPosition(),
            flip=true,
            smooth=false})
    end
    return {["villdeckc"] = 10}
end

function fightEffect(params)
    if params.obj.hasTag("Corrupted") then
        params.obj.removeTag("Corrupted")
        params.obj.removeTag("Villain")
        params.obj.removeTag("Power:2")
        params.obj.removeTag("gainAsHero")
        params.obj.setDescription(params.obj.getDescription():gsub("WALL%-CRAWL.*%.",""))
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Sidekick") then
        obj.addTag("Corrupted")
        obj.addTag("Villain")
        obj.addTag("Power:2")
        obj.addTag("gainAsHero")
        if obj.getDescription() == "" then
            obj.setDescription("WALL-CRAWL: When fighting this card, gain it to top of your deck as a hero instead of your victory pile.")
        else
            obj.setDescription(obj.getDescription() .. "\nWALL-CRAWL: When fighting this card, gain it to top of your deck as a hero instead of your victory pile.")
        end
    end
    return 1
end

function bonusInCity(params)
    if params.object.hasTag("Corrupted") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
            label = "+" .. params.twistsstacked,
            zoneguid = params.zoneguid,
            tooltip = "This villain gets +1 for each twist stacked next to the scheme.",
            id="corrupted"})
    end
end

function tuckSidekick(obj)
    obj.flip()
    local skpile = getObjectFromGUID(sidekickDeckGUID)
    Global.Call('bump',{obj = skpile, y = 4})
    Wait.condition(function() skpile.putObject(obj) end,
        function() if skpile.isSmoothMoving() == true then return false else return true end end)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city
    
    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved < 8 then
        local skpile = getObjectFromGUID(sidekickDeckGUID)
        broadcastToAll("Scheme Twist! Return a sidekick from your discard pile to the sidekick deck and two corrupted sidekicks enter the city!",{1,0,0})
        for i,o in pairs(playerBoards) do
            if Player[i].seated == true then
                local discard = getObjectFromGUID(o).Call('returnDiscardPile')
                if discard[1] and discard[1].tag == "Card" then
                    if discard[1].hasTag("Sidekick") == true then
                        discard[1].flip()
                        skpile.putObject(discard[1])
                    end
                elseif discard[1] and discard[1].tag == "Deck" then
                    local skfound = {}
                    for _,object in pairs(discard[1].getObjects()) do
                        for _,tag in pairs(object.tags) do
                            if tag == "Sidekick" then
                                table.insert(skfound,object.guid)
                                break
                            end
                        end
                    end
                    if skfound[1] and skfound[2] then
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                            pile = discard[1],
                            guids = skfound,
                            resolve_function = 'tuckSidekick',
                            tooltip = "Return this sidekick to the bottom of the sidekick deck.",
                            label = "Return",
                            fsourceguid = self.guid})
                    elseif skfound[1] then
                        local pos = getObjectFromGUID(sidekickZoneGUID).getPosition()
                        pos.z = pos.z -2
                        discard[1].takeObject({position = pos,
                            smooth=false,
                            flip=true,
                            guid = skfound[1],
                            callback_function = tuckSidekick})
                    end
                end
            end
        end
        getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2,vildeckguid=sidekickZoneGUID})
    elseif twistsresolved == 8 then
        broadcastToAll("Scheme Twist: All Sidekicks in the city escape!")
        for _,o in pairs(city) do
            local cardsincity = Global.Call('get_decks_and_cards_from_zone',o) 
            if cardsincity[1] then
                for _,object in pairs(cardsincity) do
                    if object.hasTag("Sidekick") == true then
                        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = table.clone(cardsincity),
                                currentZone = getObjectFromGUID(o),
                                targetZone = getObjectFromGUID(escape_zone_guid),
                                enterscity = 0})
                    end
                end
            end
        end
    end
    return nil
end