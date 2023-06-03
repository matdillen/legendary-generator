function onLoad()   
    soulbargain = "tormentedSoulBargainBS"
    
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "officerDeckGUID",
        "officerBuyGUID",
        "setupGUID",
        "bystandersPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function tormentedSoulBargainBS(params)
    if params.wounds == true then
        local bsPile = getObjectFromGUID(bystandersPileGUID)
        if not bsPile then
            bystandersPileGUID = getObjectFromGUID(setupGUID).Call('returnVar',"bystandersPileGUID")
            bsPile = getObjectFromGUID(bystandersPileGUID)
        end
        bsPile.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            flip=true})
    else
        getObjectFromGUID(pushvillainsguid).Call('getBystander',params.color)
    end
end 

function tormentedSoulBargainOfficer(params)
    if params.wounds == true then
        local officerpile = getObjectFromGUID(officerDeckGUID)
        officerpile.takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            flip=true})
    else
        getObjectFromGUID(officerBuyGUID).Call('gainOfficer',params.color)
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    
    if twistsresolved == 5 then
         soulbargain = "tormentedSoulBargainOfficer"
    end
    if twistsresolved < 9 then
        for _,o in pairs(Player.getPlayers()) do
            getObjectFromGUID(pushvillainsguid).Call('demonicBargain',{color = o.color,
                triggerf = soulbargain,
                fsourceguid = self.guid})
        end
    end
    return twistsresolved
end