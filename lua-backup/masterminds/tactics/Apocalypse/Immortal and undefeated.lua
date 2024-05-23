function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function tacticEffect(params)
    local zoneGUID = params.zoneGUID

    local mmcontent = Global.Call('get_decks_and_cards_from_zone',zoneGUID)
    local tacticdeck = nil
    if mmcontent[1] then
        for _,o in pairs(mmcontent) do
            if Global.Call('hasTag2',{obj = o,tag = "Tactic:"}) then
                tacticdeck = o
                break
            elseif o.tag == "Deck" and Global.Call('hasTagD',{deck = o,tag = "Tactic:",find = true}) then
                tacticdeck = o
                break
            end
        end
    end
    if not tacticdeck then
        return nil
    end
    for i = 1,6 do
        getObjectFromGUID(pushvillainsguid).Call('getBystander',Turns.turn_color)
    end
    tacticdeck.putObject(self)
    Wait.time(function() tacticdeck.randomize() end,1)
end