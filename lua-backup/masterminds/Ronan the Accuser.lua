function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID",
        "discardguids"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateMMRonan()
    local weapons = Global.Call('get_decks_and_cards_from_zone',self.guid)
    local weaponbonus = 0
    if weapons[1] and weapons[1].tag == "Deck" then
        for _,o in pairs(weapons[1].getObjects()) do
            local isWeapon = false
            local potentialweaponbonus = 0
            for _,k in pairs(o.tags) do
                if k == "Villainous Weapon" then
                    isWeapon = true 
                elseif k:find("Power:") then
                    potentialweaponbonus = potentialweaponbonus + tonumber(k:match("%d+"))
                    break
                end
            end
            if isWeapon == true then
                weaponbonus = weaponbonus + potentialweaponbonus
            end
        end
    elseif weapons[1] and weapons[1].hasTag("Villainous Weapon") and hasTag2(weapons[1],"Power:") then
        weaponbonus = weaponbonus + hasTag2(weapons[1],"Power:")
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = 1,
        label = "+" .. weaponbonus,
        tooltip = "Bonus from Ronan's villainous weapons.",
        f = 'updateMMRonan',
        id = "villainousweapon",
        f_owner = self})
end

function setupMM(params)
    epicness = params.epicness
    
    function onObjectEnterZone(zone,object)
        Wait.time(updateMMRonan,0.1)
    end
    function onObjectLeaveZone(zone,object)
        Wait.time(updateMMRonan,0.1)
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local cards = params.cards
    local epicness = params.epicness
    local strikeloc = params.strikeloc

    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        if #hand > 0 then
            local pos = getObjectFromGUID(discardguids[o.color]).getPosition()
            pos.y = pos.y + 2
            if epicness and #hand > 5 then
                hand[math.random(#hand)].setPosition(pos)
                local hand2 = o.getHandObjects()
                hand2[math.random(#hand2)].setPosition(pos)
                broadcastToAll("Master Strike: Each player with six or more cards in hand discards two cards at random.")
            elseif not epicness then
                hand[math.random(#hand)].setPosition(pos)
                broadcastToAll("Master Strike: Each player discards a card at random.")
            end
        end
    end
    if cards[1] then
        local bonusval = 1
        if epicness then
            bonusval = bonusval + 1
        end
        strikesstacked = strikesstacked + 1
        cards[1].setTags("Villainous Weapon","Power:+" .. bonusval,"Artifact")
        cards[1].setName("Necrocraft Ship")
        cards[1].setPositionSmooth(getObjectFromGUID(strikeloc).getPosition())
    end
    return nil
end