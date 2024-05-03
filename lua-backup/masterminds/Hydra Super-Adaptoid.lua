function onLoad()
    mmname = "Hydra Super-Adaptoid"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "playerBoards",
        "vpileguids"
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

function updateMMHydraSA()
    local mm = Global.Call('get_decks_and_cards_from_zone',mmloc.guid)
    local name = nil
    local power = 0
    if mm[1] and mm[1].tag == "Deck" then
        local mmdata = mm[1].getObjects()[mm[1].getQuantity()]
        name = mmdata.name
        for _,t in pairs(mmdata.tags) do
            if t:find("Power:") then
                power = tonumber(t:match("%d+"))
                break
            end
        end
    elseif mm[1] then
        name = mm[1].getName()
        power = hasTag2(mm[1],"Power:")
    end
    if not name then
        return nil
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = name,
        checkvalue = 1,
        label = power,
        tooltip = "Base power as written on the card.",
        f = 'updatePower',
        id = 'card'})
end

function fightEffect(params)
    if params.mm then
        Wait.time(updateMMHydraSA,1)
    end
end

function setupMM()
    mmloc = getObjectFromGUID(getObjectFromGUID(mmZoneGUID).Call('returnMMLocation',mmname))
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local mmloc = params.mmloc

    local mmcontent = Global.Call('get_decks_and_cards_from_zone',mmloc)
    local name = nil
    if mmcontent[1] and mmcontent[1].tag == "Deck" then
        name = mmcontent[1].getObjects()[mmcontent[1].getQuantity()].name
    elseif mmcontent[1] then
        name = mmcontent[1].getName()
    else
        broadcastToAll("Mastermind not found!")
        return nil
    end
    if name == "Captain America's Shield" then
        broadcastToAll("Master Strike: Each player reveals a Yellow Hero or discards their hand and draws four cards.")
        local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Yellow")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = hand,
                n = #hand})
            local drawfour = function()
                getObjectFromGUID(playerBoards[o.color]).Call('click_draw_cards',4)
            end
            Wait.time(drawfour,1)
        end
    elseif name == "Black Widow's Bite" then
        broadcastToAll("Master Strike: Each player KOs two Bystanders from their Victory Pile or gains a Wound.")
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                local vpilewarbound = {}
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        for _,tag in pairs(k.tags) do
                            if tag == "Bystander" then 
                                table.insert(vpilewarbound,k.guid)
                                break
                            end
                        end
                    end
                    if  #vpilewarbound > 2 then
                        getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = i,
                            pile = vpilecontent[1],
                            guids = vpilewarbound,
                            resolve_function = 'koCard',
                            tooltip = "KO this bystander.",
                            label = "KO",
                            n = 2})
                        broadcastToColor("Master Strike: KO 2 of the " .. #vpilewarbound .. " bystanders that were put into play from your victory pile.",i,i)
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            end
        end
    elseif name == "Thor's Hammer" then
        broadcastToAll("Master Strike: Each player reveals a Blue Hero or gains a Wound")
        local players = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',"Blue")
        for _,o in pairs(players) do
            getObjectFromGUID(pushvillainsguid).Call('getWound',i)
        end
    elseif name == "Iron Man's Armor" then
        broadcastToAll("Master Strike: Each player reveals a Silver Hero or discards down to 3 cards")
        local players = revealCardTrait("Silver")
        for _,o in pairs(players) do
            local hand = o.getHandObjects()
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                n = #hand-3})
        end
    end
    mmcontent[1].randomize()
    Wait.time(updateMMHydraSA,1)
    return strikesresolved      
end