function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "escape_zone_guid"
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

function pushToEscape(params)
    local pos = getObjectFromGUID(escape_zone_guid).getPosition()
    pos.y = pos.y + 2
    params.obj.setPositionSmooth(pos)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    if twistsresolved < 7 then
        local color = Turns.turn_color
        broadcastToAll("All enemies have Chivalrous Duel until " .. color .. "'s next turn!")
        local vildeckzone = getObjectFromGUID(villainDeckZoneGUID)
        vildeckzone.createButton({click_function='updatePower',
            function_owner=getObjectFromGUID(pushvillainsguid),
            position={3.4,0,0.5},
            rotation={0,180,0},
            scale={2.2,0.5,1.5},
            label="All enemies have Chivalrous Duel!",
            tooltip="Play restriction because of Scheme Twist!",
            font_size=100,
            font_color="Red",
            color={0,0,0},
            width=0})
        local turnHasPassed = function()
            if Turns.getPreviousTurnColor() == color then
                return true
            else 
                return false
            end
        end
        local turnAgain = function()
            if Turns.turn_color == color then
                return true
            else 
                return false
            end
        end
        local killButton = function()
            vildeckzone.clearButtons()
        end
        local killButtonCallback = function()
            Wait.condition(killButton,turnAgain)
        end
        Wait.condition(killButtonCallback,turnHasPassed)
    elseif twistsresolved < 10 then
        broadcastToAll("Scheme Twist: Each player puts a Villains from their Victory Pile into the Escape Pile.")
        local pos = getObjectFromGUID(escape_zone_guid).getPosition()
        pos.y = pos.y + 2
        for _,p in pairs(Player.getPlayers()) do
            local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[p.color])[1]
            local villains = {}
            if vpile and vpile.tag == "Deck" then
                for _,o in pairs(vpile.getObjects()) do
                    for _,tag in pairs(o.tags) do
                        if tag == "Villain" then
                            table.insert(villains,o.guid)
                            break
                        end
                    end
                end
                if villains[1] then
                    if villains[2] then
                        offerCards({color = p.color,
                            pile = vpile,
                            guids = villains,
                            resolve_function = 'pushToEscape',
                            tooltip = "This villain is put into the escape pile!",
                            label = "Escape",
                            fsourceguid = self.guid})
                    else
                        vpile.takeObject({position = pos,
                            smooth = true})
                    end
                end
            elseif vpile and vpile.hasTag("Villain") then
                vpile.setPositionSmooth(pos)
            end
        end
    end
    return twistsresolved
end