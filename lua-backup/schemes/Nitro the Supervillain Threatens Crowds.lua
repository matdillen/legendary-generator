function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
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
                    if powerspace == o then
                        power = power + hasTag2(object,"Power:")
                    elseif hasTag2(object,"Power:") > power then
                        powerspace = o
                        power = hasTag2(object,"Power:")
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
