function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids3 = {
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    local playercolors = Player.getPlayers()
    local shieldspresent = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    local shieldcount = 0
    if shieldspresent[1] then
        shieldcount = math.abs(shieldspresent[1].getQuantity())
    end
    local bsadded = 0
    for i=1,#playercolors do
        local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[playercolors[i].color])
        if vpile[1] and vpile[1].tag == "Deck" then
            local bsguids = {}
            for _,o in pairs(vpile[1].getObjects()) do
                for _,k in pairs(o.tags) do
                    if k == ("Bystander") then
                        table.insert(bsguids,o.guid)
                        break
                    end
                end
            end
            if bsguids[1] and epicness == false then
                bsadded = bsadded + 1
                vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                    flip=true,
                    guid=bsguids[math.random(#bsguids)],
                    smooth=true})
            elseif epicness == true and bsguids[2] then
                bsadded = bsadded + 2
                for i=1,2 do
                    local guid = table.remove(bsguids,math.random(#bsguids))
                    vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                        flip=true,
                        guid=guid,
                        smooth=true})
                    if vpile[1].remainder then
                        local temp = vpile[1].remainder
                        temp.flip()
                        temp.setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                        break
                    end
                end
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',playercolors[i].color)
            end
        elseif vpile[1] and vpile[1].tag == "Card" and epicness == false then
            if vpile[1].hasTag("Bystander") then
                bsadded = bsadded + 1
                vpile[1].flip()
                vpile[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',playercolors[i].color)
            end
        else
            getObjectFromGUID(pushvillainsguid).Call('getWound',playercolors[i].color)
        end
    end
    if bsadded > 0 then
        local shuffleShields = function()
            Global.Call('get_decks_and_cards_from_zone',strikeloc)[1].randomize()
        end
        local shieldsAdded = function()
            local shields = Global.Call('get_decks_and_cards_from_zone',strikeloc)
            if shields[1] and math.abs(shields[1].getQuantity()) == bsadded + shieldcount then
                return true
            else
                return false
            end
        end
        Wait.condition(shuffleShields,shieldsAdded)
    end
    return strikesresolved
end
