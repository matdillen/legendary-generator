function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bystandersPileGUID"
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

function singularityInvestigatorEnters(params)
    local obj = params.obj
    obj.removeTag("Bystander")
    obj.addTag("Power:6")
    obj.addTag("Singularity Investigator")
    obj.setPosition(getObjectFromGUID(pushvillainsguid).getPosition())
    Wait.time(function() getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city'),1)
    broadcastToColor("KO one of your heroes and investigate for a card with Recruit.",Turns.turn_color,Turns.turn_color)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    local bsdeck = getObjectFromGUID(bystandersPileGUID)
    if twistsresolved < 5 then
        local bystanders = bsdeck.getObjects()
        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = Turns.turn_color,
            pile = bsdeck,
            guids = {bystanders[1].guid,bystanders[2].guid},
            resolve_function = 'singularityInvestigatorEnters',
            tooltip = "This bystander will enter the city as a Singularity Investigator Villain.",
            label = "Push",
            flip = true,
            fsourceguid = self.guid})
        for _,o in pairs(city) do
            local citycontent = Global.Call('get_decks_and_cards_from_zone',o)
            for _,c in pairs(citycontent) do
                if c.hasTag("Singularity Investigator") then
                    cards[1].setPositionSmooth(getObjectFromGUID(topBoardGUIDs[1]).getPosition())
                    return nil
                end
            end
        end
    elseif twistsresolved == 5 then
        getObjectFromGUID(pushvillainsguid).Call('unveilScheme')
        return nil
    end
    return twistsresolved
end
