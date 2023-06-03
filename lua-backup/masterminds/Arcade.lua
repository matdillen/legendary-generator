function onLoad()
    mmname = "Arcade"
    
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "bystandersPileGUID",
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

function setupMM(params)
    local arc = 5
    if params.epicness then
        arc = 8
        getObjectFromGUID(setupGUID).Call('playHorror')
    end
    local bsPile = getObjectFromGUID(bystandersPileGUID)
    if not bsPile then
        bystandersPileGUID = getObjectFromGUID(setupGUID).Call('returnVar',"bystandersPileGUID")
        bsPile = getObjectFromGUID(bystandersPileGUID)
    end
    for i=1,arc do
        bsPile.takeObject({position=self.getPosition(),
            flip=false,
            smooth=false})
    end
    arcadebasepower = 3
    if params.epicness then
        arcadebasepower = 4
    end
    
    updateMMArcade()
    
    function onObjectEnterZone(zone,object)
        updateMMArcade()
    end
    
    function onObjectLeaveZone(zone,object)
        updateMMArcade()
    end
end
    
function updateMMArcade()
    local strikeloc = self.guid
    local checkvalue = 1
    if not Global.Call('get_decks_and_cards_from_zone',strikeloc)[1] then
        getObjectFromGUID(strikeloc).clearButtons()
        checkvalue = 0
    else
        if not getObjectFromGUID(strikeloc).getButtons() then
            getObjectFromGUID(strikeloc).createButton({click_function='updateMMArcade',
                function_owner=self,
                position={0,0,0},
                rotation={0,180,0},
                label=arcadebasepower,
                tooltip="You can fight these Human Shields for " .. arcadebasepower .. " to rescue them as Bystanders.",
                font_size=250,
                font_color="Red",
                width=0})
        else
            getObjectFromGUID(strikeloc).editButton({label=arcadebasepower,
                tooltip="You can fight these Human Shields for " .. arcadebasepower .. " to rescue them as Bystanders."})
        end
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
            checkvalue = checkvalue,
            label = "X",
            tooltip = "You can't fight Arcade while he has any Human Shields.",
            f = 'updateMMArcade',
            f_owner = self})
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
