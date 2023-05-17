function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
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
    local mmloc = params.mmloc
    local strikeloc = params.strikeloc

    local transformedPV = getObjectFromGUID(mmZoneGUID).Call('transformMM',getObjectFromGUID(mmloc))
    if transformedPV == true then
        getObjectFromGUID(pushvillainsguid).Call('crossDimensionalRampage',"hulk")
    elseif transformedPV == false then
        for i,o in pairs(vpileguids) do
            if Player[i].seated == true then
                local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
                if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                    local bsguids = {}
                    for _,k in pairs(vpilecontent[1].getObjects()) do
                        for _,l in pairs(k.tags) do
                            if l == "Bystander" then
                                bsguids[k.name] = k.guid
                                break
                            end
                        end
                    end
                    if next(bsguids) then
                        local bsnr = math.random(#bsguids)
                        local step = 1
                        for name,guid in pairs(bsguids) do
                            if step == bsnr then
                                if name == "Card" then
                                    name = ""
                                end
                                broadcastToColor("Master Strike: Random bystander " .. name .. " piloted one of General Ross's helicopters.",i,i)
                                vpilecontent[1].takeObject({position = getObjectFromGUID(strikeloc).getPosition(),
                                    smooth = false,
                                    flip = true,
                                    guid = guid})
                                break
                            else
                                step = step + 1
                            end
                        end
                    else
                        getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                    end
                elseif vpilecontent[1] and vpilecontent[1].hasTag("Bystander") then
                    vpilecontent[1].flip()
                    vpilecontent[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
                else
                    getObjectFromGUID(pushvillainsguid).Call('getWound',i)
                end
            end
        end
    end
    return strikesresolved
end
