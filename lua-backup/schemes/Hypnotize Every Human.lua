function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "bszoneguid",
        "escape_zone_guid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "allTopBoardGUIDS",
        "topBoardGUIDs",
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "vpileguids",
        "attackguids"
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
    local mmZone = getObjectFromGUID(mmZoneGUID)
    for i = 3,7 do
        mmZone.Call('lockTopZone',topBoardGUIDs[i])
    end
end

function moveToEscape(params)
    params.obj.setPosition(getObjectFromGUID(escape_zone_guid).getPosition())
end

function stopHypno(obj,player_clicker_color)
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 2 then
        broadcastToColor("You don't have enough attack to fight this villain!",player_clicker_color,player_clicker_color)
        return nil
    end
    local content = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not content then
        return nil
    end
    getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-2)
    local dest = getObjectFromGUID(vpileguids[player_clicker_color]).getPosition()
    dest.y = dest.y + 3
    if content.tag == "Deck" then
        content.takeObject({position = dest,
            flip = true})
    else
        content.flip()
        content.setPosition(dest)
    end
end

function hypnobuttons(zone,object)
    if object.hasTag("Bystander") then
        for i = 3,7 do
            local content = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[i])
            local zone = getObjectFromGUID(topBoardGUIDs[i])
            if content[1] and not zone.getButtons() then
                zone.createButton({click_function='updatePower',
                    function_owner=getObjectFromGUID(pushvillainsguid),
                    position={0,0,0},
                    rotation={0,180,0},
                    label="2",
                    tooltip="Fight this hypnotized bystander for 2 to rescue it.",
                    font_size=200,
                    font_color={1,0,0},
                    color={0,0,0,0.75},
                    width=250,height=250})
                zone.createButton({
                    click_function="stopHypno", function_owner=self,
                    position={0,0,-0.4}, rotation = {0,180,0}, label="Fight", 
                    tooltip = "Rescue the hypnotized bystander by fighting them for 2.", color={1,0,0,0.9}, 
                    font_color = {0,0,0}, width=600, height=150,
                    font_size = 75
                })
                getObjectFromGUID(city_zones_guids[9-i]).Call('updateZonePower',{label = "X",
                    tooltip = "A hypnotized bystander prevents you from fighting this villain.",
                    id = "hypnotized"})
            elseif not content[1] and zone.getButtons() then
                zone.clearButtons()
                getObjectFromGUID(city_zones_guids[9-i]).Call('updateZonePower',{label = "+0",
                    tooltip = "All hypnotized bystanders are cleared.",
                    id = "hypnotized"})
            end
            getObjectFromGUID(city_zones_guids[9-i]).Call('updatePower')
        end
    end
end

function onObjectEnterZone(zone,object)
    hypnobuttons(zone,object)
end

function onObjectLeaveZone(zone,object)
    hypnobuttons(zone,object)
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