function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "kopile_guid",
        "heroDeckZoneGUID",
        "bystandersPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
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

function setupSpecial(params)
    local saveHumanity = function()
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        local pos = getObjectFromGUID(heroDeckZoneGUID).getPosition()
        pos.y = pos.y + 1
        for i=1,24 do
            bsPile.takeObject({position = pos,
                smooth=false,
                callback_function = function(obj)
                    obj.addTag("Cost:2")
                    end
                })
            pos.y = pos.y + 0.1
        end
    end
    broadcastToAll("Save Humanity: Adding bystanders to the hero deck, please wait...")
    Wait.time(saveHumanity,2.5)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getBystander')
        if hero and hero.hasTag("Bystander") then
            getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
            getObjectFromGUID(o).Call('click_draw_hero')
            broadcastToAll("Scheme Twist: Bystander KO'd from the HQ!")
        end
    end
    broadcastToAll("Scheme Twist: Each player reveals a Yellow Hero or KOs a Bystander from their Victory Pile.")
    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Yellow")
    local pos = getObjectFromGUID(kopile_guid).getPosition()
    pos.y = pos.y + 2
    for _,o in pairs(players) do
        local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])[1]
        if vpile and vpile.tag == "Deck" then
            local bsguids = {}
            for _,c in pairs(vpile.getObjects()) do
                for _,tag in pairs(c.tags) do
                    if tag == "Bystander" then
                        table.insert(bsguids,c.guid)
                        break
                    end
                end
            end
            if #bsguids > 1 then
                getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                    pile = vpile,
                    guids = bsguids,
                    resolve_function = koCard,
                    tooltip = "KO this bystander.",
                    label = "KO"})
            elseif #bsguids == 1 then
                vpile.takeObject({position = pos,smooth = true, guid = bsguids[1]})
            end
        elseif vpile and vpile.hasTag("Bystander") then
            vpile.setPositionSmooth(pos)
        end
    end
    return twistsresolved
end