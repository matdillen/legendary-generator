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

function dodgeSniper(params)
    local color = params.player_clicker_color
    local hand = Player[color].getHandObjects()
    getObjectFromGUID(playerBoards[color]).Call('click_draw_card')
    Wait.condition(
        function()
            local hand2 = Player[color].getHandObjects()
            if hasTag2(hand2[1],"HC:") then
                getObjectFromGUID(pushvillainsguid).Call('koCard',hand2[1])
            end
        end,
        function()
            local hand2 = Player[color].getHandObjects()
            if #hand == #hand2 then
                return true
            else
                return false
            end
        end)
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    for _,o in pairs(Player.getPlayers()) do
        promptDiscard({color = o.color,
            trigger_function = 'dodgeSniper',
            args = "self",
            fsourceguid = self.guid})
        broadcastToColor("Scheme Twist: Discard a card, then you'll draw a card but it will be KO'd if it's a nongrey hero!",o.color,o.color)
    end
    return twistsresolved
end
