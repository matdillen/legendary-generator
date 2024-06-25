function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistPileGUID",
        "twistZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function setupSpecial(params)
    log("Set up 3 twists next to scheme already.")
    local stPile = getObjectFromGUID(twistPileGUID)
    local pos = getObjectFromGUID(twistZoneGUID).getPosition()
    for i=1,3 do
        stPile.takeObject({position = pos,
            flip=false,smooth=false})
    end
end

function bonusInCity(params)
    if params.object.hasTag("Killbot") then
        getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj= params.object, 
            label = params.twistsstacked,
            zoneguid = params.zoneguid,
            tooltip = "This Killbot bystander has power equal to the number of twists stacked next to the scheme.",
            id="twistsstacked"})
    end
end

function nonTwist(params)
    local obj = params.obj
    
    if obj.hasTag("Bystander") then
        obj.addTag("Villain")
        obj.addTag("Killbot")
        obj.addTag("Power:3")
        obj.removeTag("Bystander")
    end
    return 1
end

function setupCounter(init)
    if init then
        return {["tooltip"] = "Killbots escaped: __/5."}
    else
        local counter = 0
        local escaped = Global.Call('get_decks_and_cards_from_zone',escape_zone_guid)
        if escaped[1] and escaped[1].tag == "Deck" then
            local escapees = Global.Call('hasTagD',{deck = escaped[1],tag = "Killbot"})
            if escapees then
                counter = counter + #escapees
            end
        elseif escaped[1] and escaped[1].hasTag("Killbot") then
            counter = counter + 1
        end
        return counter
    end
end

function resolveTwist(params)
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    getObjectFromGUID(pushvillainsguid).Call('updatePower')
    return nil
end