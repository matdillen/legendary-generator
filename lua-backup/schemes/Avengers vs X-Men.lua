function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards"
        }
        
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function table.clone(val)
    local new = {}
    for i,o in pairs(val) do
        new[i] = o
    end
    return new
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Twists resolved: __/8."}
    else
        return getObjectFromGUID(pushvillainsguid).Call('returnVar',"twistsreolved")
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    local cards = params.cards
    local teams = getObjectFromGUID(setupGUID).Call('returnSetupParts')
    local teamchecks = {}
    if teams and teams[9] then
        for s in string.gmatch(teams[9],"[^|]+") do
            table.insert(teamchecks, s)
        end
    else
        broadcastToAll("Missing teams from setup?")
        return nil
    end
    if twistsresolved < 8 then
        for i,o in pairs(playerBoards) do
            if Player[i].seated == true then
                local hand = Player[i].getHandObjects()
                if hand then
                    local teamcount1 = 0
                    local teamcount2 = 0
                    for _,card in pairs(hand) do
                        local team = hasTag2(card,"Team:",6)
                        if team then
                            if team == teamchecks[1] then
                                teamcount1 = teamcount1 + 1
                            elseif team == teamchecks[2] then
                                teamcount2 = teamcount2 + 1
                            end
                        end
                    end
                    if teamcount1 > 0 and teamcount2 > 0 then
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                        broadcastToColor("Scheme Twist: You had heroes of both teams and received a wound with this Scheme Twist.",i,i)
                    end
                end
            end
        end
    else
        broadcastToAll("Twist 8: Evil wins!")
    end
    return twistsresolved
end