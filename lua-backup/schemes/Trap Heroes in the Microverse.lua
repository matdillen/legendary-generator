function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "heroPileGUID",
        "villainDeckZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function setupSpecial(params)
    log("Extra hero " .. params.setupParts[9] .." in villain deck.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = params.setupParts[9],
        pileGUID = heroPileGUID,
        destGUID = villainDeckZoneGUID})
    return {["villdeckc"] = 14}
end

function fightEffect(params)
    if params.obj.hasTag("Micro-Sized") then
        params.obj.removeTag("gainAsHero")
        params.obj.removeTag("Micro-Sized")
        params.obj.removeTag("Villain")
        params.obj.addTag("Hero")
        params.obj.removeTag("Power:" .. hasTag2(params.obj,"Cost:"))
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if hasTag2(obj,"Team:",6) then
        if obj.getDescription() == "" then
            obj.setDescription("SIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
        else
            obj.setDescription(obj.getDescription() .. "\r\nSIZE-CHANGING: This card costs 2 less to Recruit or Fight if you have a Hero with the listed Hero Class. Different colors can stack.")
        end
        obj.addTag("gainAsHero")
        obj.addTag("Micro-Sized")
        obj.addTag("Villain")
        obj.removeTag("Hero")
        obj.addTag("Power:" .. hasTag2(obj,"Cost:"))
    end
    return 1
end

function bonusInCity(params)
    if params.object.hasTag("Micro-Sized") then
        local colors = hasTag2(params.object,"HC:")
        local sc = nil
        if colors and colors[2] then
            sc = colors[1] .. "|" .. colors[2]
        elseif colors then
            sc = colors
        else
            return nil
        end
        local resp = getObjectFromGUID(pushvillainsguid).Call('revealCardTrait',{
            trait = sc, 
            players = {Player[Turns.turn_color]}})[1]
        if resp then
            getObjectFromGUID(pushvillainsguid).Call('powerButton',{
                label = "-2",
                zoneguid = params.zoneguid,
                tooltip = "Size-changing so villain is weaker.",
                id="sizechanging"})
        end
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 

    getObjectFromGUID(pushvillainsguid).Call('playVillains',{n=2})
    return twistsresolved
end