function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "vpileguids",
        "handguids"
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

function unleashFromUndercover(params)
    local cost = hasTag2(params.obj,"Cost:")
    local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[params.color])
    local pos = getObjectFromGUID(handguids[params.color]).getPosition()
    
    local candidates = {}
    if vpile[1] and vpile[1].tag == "Deck" then
        for _,o in pairs(vpile[1].getObjects()) do
            for _,tag in pairs(o.tags) do
                if tag:find("Cost:") and tonumber((tag:gsub("Cost:",""))) < cost then
                    table.insert(candidates,o.guid)
                    break
                end
            end
        end
        if candidates[1] and candidates[2] then
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = params.color,
                pile = vpile[1],
                guids = candidates,
                resolve_function = 'unLeashThisHero',
                tooltip = "Unleash this hero from your victory pile to your hand.",
                label = "Unleash",
                fsourceguid = self.guid})
        elseif candidates[1] then
            vpile[1].takeObject({position = pos,
                smooth = true,
                guid = candidates[1]})
        else
            broadcastToColor("No hero with lower cost could be found to be unleashed.",params.color,params.color)
        end
    elseif vpile[1] and hasTag2(vpile[1],"Cost:") and hasTag2(vpile[1],"Cost:") < cost then
        vpile[1].setPositionSmooth(pos)
    end
end

function unLeashThisHero(params)
    local pos = getObjectFromGUID(handguids[params.player_clicker_color]).getPosition()
    params.obj.setPositionSmooth(pos)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city
    
    if twistsresolved < 7 then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local nongrey = {}
            for _,h in pairs(hand) do
                if hasTag2(h,"HC:") then
                    table.insert(nongrey,h)
                end
            end
            local pos = getObjectFromGUID(vpileguids[o.color]).getPosition()
            pos.y = pos.y + 2
            if nongrey[1] then
                getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                    hand = nongrey,
                    pos = pos,
                    label = "Send",
                    tooltip = "Send this hero Undercover to your victory pile.",
                    trigger_function = 'unleashFromUndercover',
                    args = "self",
                    fsourceguid = self.guid})
            end
        end
    elseif twistsresolved == 7 then
        broadcastToAll("Scheme Twist: Evil wins!")
    end
    return twistsresolved
end