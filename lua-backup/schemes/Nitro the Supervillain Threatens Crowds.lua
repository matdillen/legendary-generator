function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "escape_zone_guid",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Bystanders KO'd or escaped: __/15."}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Bystander"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Bystander") then
            counter = counter + 1
        end
        local kopilecontent = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
        if kopilecontent[1] then
            for _,o in pairs(kopilecontent) do
                if o.tag == "Deck" then
                    local escapees = Global.Call('hasTagD',{deck = o,tag = "Bystander"})
                    if escapees then
                        counter = counter + #escapees
                    end
                elseif o.hasTag("Bystander") then
                    counter = counter + 1
                end
            end
        end
        return counter
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local city = params.city

    local powerspace = nil
    local power = 0
    for _,o in pairs(city) do
        local citycards = Global.Call('get_decks_and_cards_from_zone',o)
        if citycards[1] then
            for _,object in pairs(citycards) do
                if object.hasTag("Bystander") then
                    getObjectFromGUID(pushvillainsguid).Call('koCard',object)
                    broadcastToAll("Scheme Twist: Bystander KO'd from city!")
                elseif object.hasTag("Villain") then
                    for i,b in pairs(getObjectFromGUID(o).getButtons()) do
                        if b.click_function == "updatePower" then
                            if b.label > power then
                                power = b.label
                                powerspace = o
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    if powerspace then
        for i =1,3 do
            getObjectFromGUID(pushvillainsguid).Call('addBystanders',powerspace)
        end
    end
    return twistsresolved
end