function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    local guids3 = {
        "playguids",
        "discardguids"
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

function click_push_villain_into_city()
    getObjectFromGUID(pushvillainsguid).Call('click_push_villain_into_city')
end

function killHandButtons(params)
    local obj = params.obj
    obj.clearButtons()
    local loc = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
    local pos = getObjectFromGUID(loc["Malekith the Accursed"]).getPosition()
    pos.z = pos.z - 2
    obj.setPositionSmooth(pos)
    for _,h in pairs(weapons) do
        local butt = h.getButtons()
        if butt then
            for i,b in pairs(butt) do
                if b.click_function:find("discardCard") then
                    h.removeButton(i-1)
                    break
                end
            end
        end
    end
    darkspearcango = true
end

function killBSButton()
    for _,b in pairs(weaponguids) do
        local obj2 = getObjectFromGUID(b)
        if obj2 then
            local color = nil
            for _,butt in pairs(obj2.getButtons()) do
                if butt.click_function:find("resolveOfferCardsEffect") then
                    color = butt.click_function:gsub("resolveOfferCardsEffect","")
                end
            end
            obj2.clearButtons()
            obj2.locked = false
            obj2.setPosition(getObjectFromGUID(discardguids[color]).getPosition())
        end
    end
    darkspearcango = true
end

function launchDarkspear()
    if #weapons == 0 and #weaponguids == 0 then
        darkspearcango = true
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local city = params.city
    local epicness = params.epicness

    weaponguids = {}
    weapons = {}
    darkspearcango = false
    for _,o in pairs(Player.getPlayers()) do
        local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
        if playcontent[1] then
            for _,obj in pairs(playcontent) do
                if obj.hasTag("Villainous Weapon") then
                    table.insert(weapons,obj)
                end
            end
        end
        local discarded = Global.Call('get_decks_and_cards_from_zone',discardguids[o.color])
        if discarded[1] and discarded[1].tag == "Deck" then
            local weaponguids2 = {}
            for _,p in pairs(discarded[1].getObjects()) do
                for _,k in pairs(p.tags) do
                    if k == "Villainous Weapon" then
                        table.insert(weaponguids2,p.guid)
                        break
                    end
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('offerCards',{color = o.color,
                pile = discarded[1],
                guids = weaponguids2,
                resolve_function = 'killHandButtons',
                args = "self",
                tooltip = "Choose this villainous weapon to be captured by Malekith.",
                label = "Pick",
                fsourceguid = self.guid})
            weaponguids = Global.Call('merge',{t1 = weaponguids,t2 = weaponguids2})
        elseif discarded[1] and discarded[1].hasTag("Villainous Weapon") then
            _G['killHandButtons' .. o.color] = function(obj)
                obj.clearButtons()
                local loc = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
                local pos = getObjectFromGUID(loc["Malekith the Accursed"]).getPosition()
                pos.z = pos.z - 2
                obj.setPositionSmooth(pos)
                for _,h in pairs(weapons) do
                    local butt = h.getButtons()
                    if butt then
                        for i,b in pairs(butt) do
                            if b.click_function:find("discardCard") then
                                h.removeButton(i-1)
                                break
                            end
                        end
                    end
                end
                for _,h in pairs(weaponguids) do
                    local obj2 = getObjectFromGUID(h)
                    if obj2 and h ~= obj.guid then
                        obj2.clearButtons()
                    end
                end
                darkspearcango = true
            end
            table.insert(weaponguids,discarded[1].guid)
            discarded[1].createButton({click_function = 'killHandButtons' .. o.color,
                function_owner=self,
                position={0,22,0},
                label="Pick",
                tooltip="Choose this villainous weapon to be captured by Malekith.",
                font_size=250,
                font_color="Black",
                color={1,1,1},
                width=750,height=450})
        end
    end
    if epicness then
        epicweapons = {}
    end
    for _,c in pairs(city) do
        local citycontent = Global.Call('get_decks_and_cards_from_zone',c)
        if citycontent[1] then
            for _,obj in pairs(citycontent) do
                if obj.hasTag("Villainous Weapon") then
                    if epicness then
                        table.insert(epicweapons,obj)
                    else
                        table.insert(weapons,obj)
                    end
                end
            end
        end
    end
    
    local loc = table.clone(getObjectFromGUID(mmZoneGUID).Call('returnVar',"mmLocations"),true)
    local pos = getObjectFromGUID(loc["Malekith the Accursed"]).getPosition()
    pos.z = pos.z - 2
    if epicness then
        getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = epicweapons,
        label = "Pick",
        tooltip = "Choose this villainous weapon to be captured by Malekith.",
        pos = pos,
        trigger_function = 'launchDarkspear',
        fsourceguid = self.guid})
    end
    getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = Turns.turn_color,
        hand = weapons,
        label = "Pick",
        tooltip = "Choose this villainous weapon to be captured by Malekith.",
        pos = pos,
        trigger_function = 'killBSButton',
        fsourceguid = self.guid})
    if cards[1] then
        cards[1].setName("Darkspear")
        cards[1].addTag("Villainous Weapon")
        cards[1].setDescription("VILLAINOUS WEAPON: These are not Villains. Instead, they are captured by the Villain closest " .. 
        "to the Villain deck or KO'd if the city is empty. The Villain gets the extra Power from the Weapon. When a Villain escapes " .. 
        "with a Weapon, the Mastermind captures that Weapon. When fighting a card with a Weapon, gain the Weapon as an artifact.\n" ..
        "THROWN ARTIFACT:This card remains in play. During your turn, you may put it on the bottom of your deck to use its Throw effect and gain 2 Attack.")
        if #weapons == 0 and #weaponguids == 0 then
            if epicness and #epicweapons == 0 then
                darkspearcango = true
            end
        end
        if epicness then
            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
                label = "+3",
                tooltip = "This strike is a Darkspear Villainous Weapon."})
        else
            getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = cards[1],
                label = "+2",
                tooltip = "This strike is a Darkspear Villainous Weapon."})
        end
        local findingWeaponResolved = function()
            if darkspearcango == true then
                return true
            else
                return false
            end
        end
        Wait.condition(click_push_villain_into_city,findingWeaponResolved)
    end
    return nil
end
