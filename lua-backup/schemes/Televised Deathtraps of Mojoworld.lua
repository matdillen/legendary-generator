function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function resolveDeathtraps(obj,player_clicker_color)
    broadcastToAll("Deathtraps averted by player " .. player_clicker_color)
    obj.clearButtons()
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    broadcastToAll("Scheme Twist: Fight the deathtraps (click the value hovering the scheme card) before end of turn or every player gets a wound!")
    getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = scheme[1],
        label = twistsstacked,
        tooltip = "Resolve the deathtraps by spending this much Attack.",
        click_f = "resolveDeathtraps",
        zoneguid = self.guid})
    local pcolor = Turns.turn_color
    local turnChanged = function()
        if Turns.turn_color == pcolor then
            return false
        else
            return true
        end
    end
    local deathTrapsActivated = function()
        if self.getButtons() then
            self.clearButtons()
            broadcastToAll("Death traps activated. Each player gains a wound.")
            getObjectFromGUID(pushvillainsguid).Call('dealWounds')
        end
    end
    Wait.condition(deathTrapsActivated,turnChanged)
    return nil
end
