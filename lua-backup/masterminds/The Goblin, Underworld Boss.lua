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
    local strikeloc = params.strikeloc

    local shieldspresent = Global.Call('get_decks_and_cards_from_zone',strikeloc)
    local shieldcount = 0
    if shieldspresent[1] then
        shieldcount = math.abs(shieldspresent[1].getQuantity())
    end
    local bsadded = 0
    for _,o in pairs(Player.getPlayers()) do
        local vpile = Global.Call('get_decks_and_cards_from_zone',vpileguids[o.color])
        if vpile[1] and vpile[1].tag == "Deck" then
            local bsguids = {}
            for _,obj in pairs(vpile[1].getObjects()) do
                for _,k in pairs(obj.tags) do
                    if k == "Bystander" then
                        table.insert(bsguids,obj.guid)
                        break
                    end
                end
            end
            local guid = nil
            if #bsguids > 1 then
                bsadded = bsadded + 2
                guid = table.remove(bsguids,math.random(#bsguids))
                vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                    flip=true,
                    guid=guid,
                    smooth=true})
                if not vpile[1].remainder then
                    guid = table.remove(bsguids,math.random(#bsguids))
                    vpile[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                        flip=true,
                        guid=guid,
                        smooth=true})
                else
                    vpile[1].remainder.flip()
                    vpile[1].remainder.setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                end
            else
                getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
            end
        else
            getObjectFromGUID(pushvillainsguid).Call('getWound',o.color)
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
