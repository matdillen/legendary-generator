function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "schemeZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
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

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    if twistsresolved == 1 then
        local scheme = Global.Call('get_decks_and_cards_from_zone',schemeZoneGUID)
        if scheme[1] then
            broadcastToAll("Scheme Twist: The scheme ascended to be a Mastermind!")
            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = scheme[1],
                label = 9,
                tooltip = "This scheme is now a mastermind named God-Emperor."})
            scheme[1].addTag("Mastermind")
            scheme[1].addTag("VP9")
            scheme[1].setName("God-Emperor")
            local mmZone = getObjectFromGUID(mmZoneGUID)
            mmZone.Call('updateMasterminds',"God-Emperor")
            mmZone.Call('updateMastermindsLocation',{"God-Emperor",schemeZoneGUID})
            mmZone.Call('setupMasterminds',{obj = self,epicness = false,tactics = 0})
        else
            broadcastToAll("Missing scheme card?")
            return nil    
        end
    elseif twistsresolved < 7 then
        twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
        local scheme = Global.Call('get_decks_and_cards_from_zone',schemeZoneGUID)
        if scheme[1] then 
            scheme[1].editButton({label = 9 + 2*twistsstacked})
        end
        broadcastToAll("Scheme Twist: The God-Emperor gets +2")
        return nil
    elseif twistsresolved == 7 then
        broadcastToAll("Scheme Twist: The God-Emperor KO's all other masterminds!")
        local iter = 0
        local mmZone = getObjectFromGUID(mmZoneGUID)
        local masterminds = table.clone(mmZone.Call('returnVar',"masterminds"))
        local mmLocations = table.clone(mmZone.Call('returnVar',"mmLocations"),true)
        for i,o in ipairs(masterminds) do
            if o ~= "God-Emperor" then
                local mm = Global.Call('get_decks_and_cards_from_zone',mmLocations[o])
                if mm[1] then
                    for _,o in pairs(mm) do
                        if o.is_face_down then
                            o.flip()
                        end
                        getObjectFromGUID(pushvillainsguid).Call('koCard',o)
                    end
                end
                getObjectFromGUID(mmLocations[o]).clearButtons()
                mmZone.Call('removeMasterminds',i-iter)
                iter = iter + 1
            end
        end
    elseif twistsresolved == 8 then
        broadcastToAll("Scheme Twist: Evil Wins!")
    end
    return twistsresolved
end
