function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    broadcastToColor("Scheme Twist: Fulfill this challenge or a juror condemns humanity! Challenges are not scripted.",Turns.turn_color,Turns.turn_color)
    if twistsresolved < 3 then
        broadcastToColor("Challenge: Discard three cards with different names!",Turns.turn_color,Turns.turn_color)
    elseif twistsresolved < 9 and twistsresolved % 2 == 1 then
        broadcastToColor("Challenge: Recruit a hero that costs 5 or more!",Turns.turn_color,Turns.turn_color)
    elseif twistsresolved < 9 and twistsresolved % 2 == 0 then
        broadcastToColor("Challenge: Defeat villains worth a total of 3VP or more!",Turns.turn_color,Turns.turn_color)  
    elseif twistsresolved < 12 then
        broadcastToColor("Challenge: Defeat (not just fight) the mastermind!",Turns.turn_color,Turns.turn_color)
    else
        broadcastToColor("No more challenges!")
    end
    return twistsresolved
end