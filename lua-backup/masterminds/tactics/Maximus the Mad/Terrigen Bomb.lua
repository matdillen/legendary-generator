function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "heroDeckZoneGUID",
        "setupGUID",
        "kopile_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function tacticEffect(params)
    local herodeck = Global.Call('get_decks_and_cards_from_zone',heroDeckZoneGUID)[1]
    if herodeck then
        Global.Call('bump',{obj = herodeck})
    end
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if not hero then 
            return nil 
        end
        local heroattack = hasTag2(hero,"Attack:")
        if heroattack and type(heroattack) ~= "number" and heroattack[1] then
            local isstrong = false
            for _,p in pairs(heroattack) do
                if p >= 2 then
                    isstrong = true
                    break
                end
            end
            if not isstrong then
                getObjectFromGUID(o).Call('tuckHero')
            end
        elseif not heroattack or heroattack < 2 then
            getObjectFromGUID(o).Call('tuckHero')
        end
    end
    local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
    if thronesfavor == "mmMaximus the Mad" then
        for _,o in pairs(Player.getPlayers()) do
            local hand = o.getHandObjects()
            local toKO = {}
            for _,obj in pairs(hand) do
                if hasTag2(obj,"Attack:") and hasTag2(obj,"HC:") then
                    table.insert(toKO,obj)
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = toKO,
                pos = getObjectFromGUID(kopile_guid).getPosition(),
                label = "KO",
                tooltip = "KO this card."})
        end
        broadcastToAll("Maximus Fight effect: Maximus deploys the Terrigen Bomb! Weak heroes with attack less than 2 are blown away from the HQ. As he had the Throne's Favor, each player KO's a non-grey hero with an attack symbol.")
    else
        broadcastToAll("Maximus Fight effect: Maximus deploys the Terrigen Bomb! Weak heroes with attack less than 2 are blown away from the HQ.")
    end
    getObjectFromGUID(setupGUID).Call('thrones_favor',{obj = "any",
        player_clicker_color = "mmMaximus the Mad"})
end