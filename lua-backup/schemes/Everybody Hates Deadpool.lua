function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
        "playerBoards"
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    local deadpoolinhand = {}
    local deadpoolloser = nil
    for i,o in pairs(playerBoards) do
        if Player[i].seated == true then
            local hand = Player[i].getHandObjects()
            if hand then
                local deadpoolcount = 0
                for _,card in pairs(hand) do
                    local team = hasTag2(card,"Team:",6)
                    if team and team == "Deadpool" or card.getName() == "Deadpool (B)" then
                        deadpoolcount = deadpoolcount + 1
                    end
                end
                deadpoolinhand[i] = deadpoolcount
                if not deadpoolloser then
                    deadpoolloser = deadpoolcount
                else
                    deadpoolloser = math.min(deadpoolloser,deadpoolcount)
                end
            end
        end
    end
    for i,o in pairs(deadpoolinhand) do
        if o == deadpoolloser then
            getObjectFromGUID(pushvillainsguid).Call('getWound',i)
            broadcastToAll("Scheme Twist: Player " .. i .. " fell short on amazing Deadpools and was wounded for it.",i)
        end
    end
    return twistsresolved
end