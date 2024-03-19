function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "hmPileGUID",
        "twistZoneGUID",
        "heroDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
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

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function bugleInvader(obj)
    local heroZone = getObjectFromGUID(heroDeckZoneGUID)
    for i=1,6 do
        obj.takeObject({position=heroZone.getPosition(),
            flip=false,smooth=false})
    end
    local hmPile = getObjectFromGUID(hmPileGUID)
    for i=1,4 do
        obj.takeObject({position=hmPile.getPosition(),
            flip=false,smooth=false})
    end
end

function setupSpecial(params)
    log("6 extra henchmen in hero deck.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = params.setupParts[9],
        pileGUID = hmPileGUID,
        destGUID = twistZoneGUID,
        callbackf = "bugleInvader",
        fsourceguid = self.guid})
    return {["herodeckextracards"] = 6}
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    broadcastToAll("Scheme Twist: This scheme is not scripted yet.")
    return nil
end