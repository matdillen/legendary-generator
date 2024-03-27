function onLoad()
    mmname = "Immortal Emperor Zheng-Zhu"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function updateMMImmortalEmperor()
    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait = "6",
        what = "Cost",
        prefix = "Cost:",
        players = {Player[Turns.turn_color]}})
    local boost = 0
    if players[1] then
        boost = 7
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = "Immortal Emperor Zheng-Zhu is in the 7th Circle of Kung Fu and gets +7 unless you have a hero with at least that cost.",
        f = 'updateMMImmortalEmperor',
        id = "seventhcircleofkungfu",
        f_owner = self})
end

function setupMM()
    updateMMImmortalEmperor()
    function onObjectEnterZone(zone,object)
        updateMMImmortalEmperor()
    end
    function onObjectLeaveZone(zone,object)
        updateMMImmortalEmperor()
    end
    function onPlayerTurn(player,previous_player)
        updateMMImmortalEmperor()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait=6,
        prefix="Cost:",
        what="Cost"})
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        if #hand > 3 then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = #hand-3})
            broadcastToColor("Master Strike: Discard down to three cards.",o.color,o.color)
        end
    end
    return strikesresolved
end