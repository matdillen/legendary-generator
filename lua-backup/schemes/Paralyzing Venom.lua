function onLoad()   
    local guids1 = {
        "pushvillainsguid"
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

function killBSButton(params)
    for _,b in pairs(bsguids[params.color]) do
        local obj = getObjectFromGUID(b)
        if obj then
            obj.clearButtons()
            obj.locked = false
            obj.setPosition(getObjectFromGUID(vpileguids[params.color]).getPosition())
        end
    end
end

function killHandButtons(params)
    local obj = params.obj
    obj.clearButtons()
    getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
    local hand = Player[params.color].getHandObjects()
    for _,h in pairs(hand) do
        h.clearButtons()
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 6 then
        bsguids = {}
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            if #hand > 4 then
                bsguids[o.color] = {}
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = hand,
                    n = #hand-4,
                    trigger_function = 'killBSButton',
                    args = "self",
                    fsourceguid = self.guid})
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,p in pairs(vpilecontent[1].getObjects()) do
                        for _,k in pairs(p.tags) do
                            if k == "Bystander" then
                                table.insert(bsguids[o.color],p.guid)
                                break
                            end
                        end
                    end
                    offerCards({color = o.color,
                        pile = vpilecontent[1],
                        guids = bsguids[o.color],
                        resolve_function = 'killHandButtons',
                        args = "self",
                        tooltip = "KO this bystander.",
                        label = "KO",
                        fsourceguid = self.guid})
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                    _G['killHandButtons' .. o.color] = function(obj)
                        local color = nil
                        for _,b in pairs(obj.getButtons()) do
                            if b.click_function:find("killHandButtons") then
                                color = b.click_function:gsub("killHandButtons","")
                            end
                        end
                        obj.clearButtons()
                        getObjectFromGUID(pushvillainsguid).Call('koCard',obj)
                        local hand = Player[color].getHandObjects()
                        for _,h in pairs(hand) do
                            h.clearButtons()
                        end
                    end
                    vpilecontent[1].createButton({click_function = 'killHandButtons' .. o.color,
                        function_owner=self,
                        position={0,22,0},
                        label="KO",
                        tooltip="KO this bystander.",
                        font_size=250,
                        font_color="Black",
                        color={1,1,1},
                        width=750,height=450})
                    table.insert(bsguids[o.color],vpilecontent[1].guid)
                end
            else
                broadcastToColor("Scheme Twist: Your hand has less than 5 cards, but you may still KO a bystander from your victory pile if you really hate it.",o.color,o.color)
            end
        end
    else
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end