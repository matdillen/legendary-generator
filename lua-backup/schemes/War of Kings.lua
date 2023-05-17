function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "schemeZoneGUID",
        "officerDeckGUID",
        "twistZoneGUID",
        "mmZoneGUID"
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

function payBattlefront(obj,player_clicker_color)
    for i,o in pairs(obj.getButtons()) do
        if o.click_function == "payBattlefront" then
            obj.removeButton(i-1)
            break
        end
    end
    getObjectFromGUID(setupGUID).Call('thrones_favor',{"any",player_clicker_color,true})
    broadcastToAll("Battlefront tax paid. You may KO one of your heroes!")
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    twistsstacked = getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    broadcastToAll("Scheme Twist: Pay the battlefront tax or lose a battle.")
    getObjectFromGUID(schemeZoneGUID).createButton({click_function="payBattlefront",
        function_owner=self,
        position={0,0,0},
        rotation={0,180,0},
        label="Pay " .. twistsstacked .. "*",
        tooltip="Pay 1 Recruit for each stacked twist.",
        font_size=100,
        font_color="Black",
        color="Yellow",
        width=500,height=150})
    local pcolor = Turns.turn_color
    local turnChanged = function()
        if Turns.turn_color == pcolor then
            return false
        else
            return true
        end
    end
    local victoriousGeneral = function()
        local butt = getObjectFromGUID(schemeZoneGUID).getButtons()
        local paid = true
        for i,o in pairs(butt) do
            if o.click_function == "payBattlefront" then
                getObjectFromGUID(schemeZoneGUID).removeButton(i-1)
                paid = false
                break
            end
        end
        if paid == true then
            return nil
        end
        getObjectFromGUID(officerDeckGUID).takeObject({position = getObjectFromGUID(twistZoneGUID).getPosition(),
            flip = true,
            smooth = false})
        local thronesfavor = getObjectFromGUID(setupGUID).Call('returnVar',"thronesfavor")
        if thronesfavor:find("mm") then
            getObjectFromGUID(pushvillainsguid).Call('getWound',pcolor)
            broadcastToAll("Victorious General! The mastermind had the Throne's Favor so player " .. pcolor .. " got a wound!")
        else
            local mmLocations = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
            local mm = nil
            for i,o in pairs(mmLocations) do
                if o == mmZoneGUID then
                    mm = i
                    break
                end
            end
            if mm then
                getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mm" .. mm})
                 broadcastToAll("Victorious General! The mastermind gains the Throne's Favor!")
            else
                for i,o in pairs(mmLocations) do
                    mm = i
                    break
                end
                getObjectFromGUID(setupGUID).Call('thrones_favor',{"any","mm" .. mm})
                broadcastToAll("Victorious General! Another remaining mastermind gains the Throne's Favor!")
            end
        end
    end
    Wait.condition(victoriousGeneral,turnChanged)
    return nil
end
