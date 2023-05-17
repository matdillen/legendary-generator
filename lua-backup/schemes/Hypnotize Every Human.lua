function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bszoneguid",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS"
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

function moveToEscape(params)
    params.obj.setPosition(getObjectFromGUID(escape_zone_guid).getPosition())
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    if twistsresolved < 7 then
        local bspile = Global.Call('get_decks_and_cards_from_zone',bszoneguid)[1]
        for i,o in pairs({table.unpack(allTopBoardGUIDS,7,11)}) do
            local topzone = getObjectFromGUID(o)
            bspile.takeObject({position = topzone.getPosition(),
                flip=false})
        end
    elseif twistsresolved < 9 then
        for _,o in pairs(Player.getPlayers()) do
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
            local vpilevillains = {}
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                for _,obj in pairs(vpilecontent[1].getObjects()) do
                    for _,k in pairs(obj.tags) do
                        if k == "Villain" then
                            table.insert(vpilevillains,obj.guid)
                            break
                        end
                    end
                end
                if vpilevillains[1] and vpilevillains[2] then
                    
                    --log(o.color)
                    --log(vpilevillains)
                    getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                        pile = vpilecontent[1],
                        guids = vpilevillains,
                        resolve_function = 'moveToEscape',
                        args = "self",
                        tooltip = "Put this villain in the escape pile.",
                        label = "Escape",
                        fsourceguid = self.guid})
                elseif vpilevillains[1] then
                    vpilecontent[1].takeObject({position = getObjectFromGUID(escape_zone_guid).getPosition(),
                        guid = vpilevillains[1]})
                end
            elseif vpilecontent[1] and vpilecontent[1].hasTag("Villain") then
                vpilecontent[1].setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
            end
        end
        broadcastToAll("Scheme Twist: Each player puts a villain from their victory pile into the escape pile.",{1,0,0})
    end
    return twistsresolved
end
