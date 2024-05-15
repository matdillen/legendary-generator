function onLoad()
    local guids = {
        "playerBoards"
        }
        
    for _,o in pairs(guids) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect()
    getObjectFromGUID(playerBoards[Turns.turn_color]).Call('updateVar',{name = "extraturn",value = true})
    getObjectFromGUID("Secrets of Time Travel tactic defeated. You take an extra turn.",Turns.turn_color,Turns.turn_color)
end