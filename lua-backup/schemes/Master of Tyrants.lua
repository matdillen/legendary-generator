function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "setupGUID",
        "mmPileGUID",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function setupSpecial(params)
    log("Moving extra masterminds outside the board.")
    local tyrants = {}
    for s in string.gmatch(params.setupParts[9],"[^|]+") do
        table.insert(tyrants, string.lower(s))
    end
    for i=1,3 do
        getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = tyrants[i],
            pileGUID = mmPileGUID,
            destGUID = topBoardGUIDs[i+5],
            callbackf = "shuffleTyrantTactics",
            fsourceguid = self.guid})
    end
    log("Extra mastermind tactics shuffled into villain deck! Their front cards can still be seen above the board.")
    -- still remove remaining mm cards then
    -- can stay there to show what is in the deck
    return {["villdeckc"] = 12}
end

function shuffleTyrantTactics(obj)
    local annotateTyrant = function(obj)
      obj.setDescription("No abilities!")
      obj.addTag("Tyrant")
    end
    local vilDeckZone = getObjectFromGUID(villainDeckZoneGUID)
    for i=1,4 do
      log("Mastermind Tactics Into Villain Deck")
      obj.takeObject({position=vilDeckZone.getPosition(),
          smooth=false,
          flip=false,
          index=0,
          callback_function = annotateTyrant})
    end
    local clearMMFronts = function()
      for i=1,3 do
          local card = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[i+5])
          card[1].destruct()
      end
    end
    Wait.time(clearMMFronts,2)
end

function nonTwist(params)
    if params.obj.getName() == "Dark Power" then
        broadcastToAll("Scheme Twist: Put this twist under a tyrant as a Dark Power!")
        return nil
    end
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Tyrants escaped: __/5.",
                ["zoneguid"] = escape_zone_guid}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Tyrant"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Tyrant") then
            counter = counter + 1
        end
        return counter
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    if twistsresolved < 8 then
        broadcastToAll("Scheme Twist: Put this twist under a tyrant as a Dark Power!")
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
            label = "+2",
            tooltip = "This tyrant gets +2 because of a Dark Power.",
            id = "darkpower" .. twistsresolved})
        cards[1].setName("Dark Power")
        return nil
    elseif twistsresolved == 8 then
        for _,o in pairs(city) do
            local citycards = Global.Call('get_decks_and_cards_from_zone',o)
            if citycards[1] then
                for _,object in pairs(citycards) do
                    if object.hasTag("Tyrant") then
                        getObjectFromGUID(pushvillainsguid).Call('shift_to_next2',{objects = citycards,
                            currentZone = getObjectFromGUID(o),
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0})
                        broadcastToAll("Scheme Twist: A tyrant escaped!")
                        break
                    end
                end
            end
        end
    end
    return twistsresolved
end