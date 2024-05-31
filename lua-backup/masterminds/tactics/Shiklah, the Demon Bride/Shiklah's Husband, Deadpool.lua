function onLoad()
    local guids1 = {
        "discardguids"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect(params)
    local pos = getObjectFromGUID(discardguids[params.player_clicker_color]).getPosition()
    pos.y = pos.y + 2
    self.setTags("Hero","Attack:5+","HC:Red","Cost:0")
    self.setPosition(pos)
end