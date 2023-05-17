function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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
                            targetZone = getObjectFromGUID(escape_zone_guid),
                            enterscity = 0,
                            schemeParts = {self.getName()}})
                        broadcastToAll("Scheme Twist: A tyrant escaped!")
                        break
                    end
                end
            end
        end
    end
    return twistsresolved
end
