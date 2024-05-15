function onLoad()
    local guids = {
        "playerBoards"
        }
        
    for _,o in pairs(guids) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect()
    for i = 1,3 do
        getObjectFromGUID(playerBoards[Turns.turn_color]).Call('handsizeplus')
    end
end