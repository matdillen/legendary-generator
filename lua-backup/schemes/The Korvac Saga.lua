function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "schemeZoneGUID",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function killKoBystanderButton(color)
    local vpile= getObjectFromGUID(vpileguids[color])
    local vpbuttons = vpile.getButtons()
    if vpbuttons then
        for i,b in pairs(vpbuttons) do
            if b.click_function:find("koBystander") then
                vpile.removeButton(i-1)
                break
            end
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved % 2 == 1 and twistsresolved < 9 then
        local scheme = Global.Call('get_decks_and_cards_from_zone',schemeZoneGUID)
        scheme[1].flip()
        scheme[1].addTag("VP9")
        scheme[1].addTag("Villain")
        getObjectFromGUID(schemeZoneGUID).createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={0,0,0},
            rotation={0,180,0},
            label="19",
            tooltip="The Korvac entity",
            font_size=350,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=250})
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            if # hand > 4 then
                promptDiscard({color = o.color,
                    hand = hand,
                    n = #hand-4,
                    trigger_function = 'killKoBystanderButton',
                    args = o.color,
                    fsourceguid = self.guid})
                local vpile = getObjectFromGUID(vpileguids[o.color])
                _G["koBystander" .. o.color] = function(obj)
                    local vpilecontent = Global.Call('get_decks_and_cards_from_zone',obj.guid)
                    local bsguids = {}
                    if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                        for _,c in pairs(vpilecontent[1].getObjects()) do
                            for _,t in pairs(c.tags) do
                                if t == "Bystander" then
                                    table.insert(bsguids,c.guid)
                                    break
                                end
                            end
                        end
                    elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                        getObjectFromGUID(pushvillainsguid).Call('koCard',vpilecontent[1])
                        table.insert(bsguids,"ko")
                    end
                    local color = nil
                    for c,g in pairs(vpileguids) do
                        if g == obj.guid then
                            color = c
                            break
                        end
                    end
                    if bsguids[1] then
                        killKoBystanderButton(color)
                        local hand = Player[color].getHandObjects()
                        for _,h in pairs(hand) do
                            h.clearButtons()
                        end
                        if bsguids[1] ~= "ko" and bsguids[2] then
                            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = color,
                                pile = vpilecontent[1],
                                guids = bsguids,
                                resolve_function = koCard,
                                tooltip = "KO this Bystander.",
                                label = "KO"})
                        elseif bsguids[1] ~= "ko" then
                            vpilecontent[1].takeObject({position = getObjectFromGUID(kopile_guid).getPosition(),
                                smooth = true,
                                guid = bsguids[1]})
                        end
                    else
                        broadcastToColor("Can't KO a bystander, none found!",color,color)
                    end
                end
                vpile.createButton({click_function="koBystander" .. o.color,
                    function_owner=self,
                    position={0,0,0},
                    rotation={0,180,0},
                    label="KO",
                    tooltip="KO a bystander.",
                    font_size=200,
                    font_color="Black",
                    color={1,1,1},
                    width=650,height=400})
            else
                broadcastToColor("Scheme Twist: But you have 4 or less cards in hand, so you don't need to discard. You may KO a bystander if you really hate it.",o.color,o.color)
            end
        end
    elseif twistsresolved < 8 then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            if hand[1] then
                local hand = o.getHandObjects()
                local avengers = {}
                for _,obj in pairs(hand) do
                    if hasTag2(obj,"Team:") and hasTag2(obj,"Team:") == "Avengers" then
                        table.insert(avengers,obj)
                    end
                end
                if avengers[1] then
                    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,hand = avengers})
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
                end
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        end
        local scheme = Global.Call('get_decks_and_cards_from_zone',schemeZoneGUID)
        scheme[1].flip()
        scheme[1].removeTag("VP9")
        scheme[1].removeTag("Villain")
        getObjectFromGUID(schemeZoneGUID).clearButtons()
    elseif twistsresolved == 8 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end
