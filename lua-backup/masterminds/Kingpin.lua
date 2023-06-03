function onLoad()
    mmname = "Kingpin"
    
    local guids1 = {
        "pushvillainsguid",
        "villainDeckZoneGUID",
        "mmZoneGUID"
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

function setupMM()
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = 1,
        label = "*",
        tooltip="Kingpin can be fought using Recruit as well as Attack.",
        f = 'updatePower',
        id = "bribe"})
end
function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{trait="Marvel Knights",prefix="Team:"})
    for _,o in pairs(players) do
        local hand = o.getHandObjects()
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
            n = #hand})
        local drawfive = function()
            getObjectFromGUID(playerBoards[o.color]).Call('click_draw_cards',5)
        end
        Wait.time(drawfive,1)
    end
    return strikesresolved
end