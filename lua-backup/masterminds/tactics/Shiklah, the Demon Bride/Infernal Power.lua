function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "playerBoards"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function tacticEffect(params)
    local resurrects = getObjectFromGUID(pushvillainsguid).Call('fatefulRessurection')
    if resurrects then
        local mmcontent = Global.Call('get_decks_and_cards_from_zone',params.zoneGUID)
        for _,o in pairs(mmcontent) do
            Global.Call('bump',{obj = o})
            if Global.Call('hasTag2',{obj = o,tag = "Tactic:"}) or (o.tag == "Deck" and Global.Call('hasTagD',{deck = o,tag = "Tactic:",find = true})) then
                local deck = o.putObject(self)
                Wait.time(function() deck.randomize() end,0.5)
            end
        end
        local playerboard = getObjectFromGUID(playerBoards[params.player_clicker_color])
        playerboard.Call('click_draw_cards',2)
    end
end