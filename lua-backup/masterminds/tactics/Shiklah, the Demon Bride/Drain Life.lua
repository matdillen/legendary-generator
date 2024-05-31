function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function tacticEffect(params)
    local resurrects = getObjectFromGUID(pushvillainsguid).Call('fatefulRessurection')
    if resurrects then
        local mmcontent = Global.Call('get_decks_and_cards_from_zone',params.zoneGUID)
        for _,o in pairs(mmcontent) do
            Global.Call('bump',{obj = o})
            if Global.Call('hasTag2',{obj = o,tag = "Tactic:"}) or Global.Call('hasTagD',{deck = o,tag = "Tactic:",find = true}) then
                local deck = self.putObject(o)
                Wait.time(function() deck.randomize() end,0.5)
            end
        end
        local city = Global.Call('returnVar',"current_city")
        local opts = {}
        for _,o in pairs(city) do
            local citycontent = getObjectFromGUID(o).getObjects()
            if citycontent[1] then
                for _,obj in pairs(citycontent) do
                    if obj.hasTag("Villain") then
                        table.insert(opts,o)
                        break
                    end
                end
            end
        end
        if opts[1] then
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{
                color = params.player_clicker_color,
                hand = opts,
                isZone = true,
                label = "Defeat",
                tooltip = "Defeat this villain for free!",
                pos = "Stay",
                fsourceguid = "zone",
                trigger_function = "defeatForFree",
                args = "self"
            })
        end
    end
end