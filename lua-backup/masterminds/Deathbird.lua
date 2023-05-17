function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "setupGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local epicness = params.epicness

    local shiarfound = false
    for _,o in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',(o)
        if citycontent[1] then
            for _,p in pairs(citycontent) do
                if p.getName():find("Shi'ar") or hasTag2(p,"Group:Shi'ar") then
                    if epicness == true then
                        getObjectFromGUID(setupGUID).Call('playHorror')
                    else
                        getObjectFromGUID(pushvillainsguid).Call('dealWounds')
                    end
                    shiarfound = true
                    break
                end
            end                 
        end
        if shiarfound then
            break
        end
    end
    if cards[1] then
        cards[1].setName("Shi'ar Battlecruiser")
        local attack = 0
        cards[1].addTag("Villain")
        if epicness == true then
            cards[1].addTag("VP6")
            attack = 9
        else
            cards[1].addTag("VP5")
            attack = 7
        end
        cards[1].addTag("Power:" .. attack)
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
            label = attack,
            tooltip = "This strike is a Shi'ar Battlecruiser villain."})
        getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
    end
    return nil
end
