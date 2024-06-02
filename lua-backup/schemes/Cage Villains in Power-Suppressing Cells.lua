function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "setupGUID",
        "hmPileGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "topBoardGUIDs"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
        "vpileguids",
        "playguids",
        "playerBoards"
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

function ditchCops(obj)
    local copstoditch = 10-#Player.getPlayers()*2
    local henchpos = getObjectFromGUID(hmPileGUID).getPosition()
    henchpos.y = henchpos.y + 5
    for i = 1,copstoditch do
        obj.takeObject({position=henchpos,smooth=false})
    end
end

function setupSpecial(params)
    log("Add extra cops henchmen.")
    getObjectFromGUID(setupGUID).Call('findInPile2',{deckName = "Cops",
        pileGUID = hmPileGUID,
        destGUID = topBoardGUIDs[4],
        callbackf = "ditchCops",
        fsourceguid = self.guid})
    log("Cops moved next to scheme.")
end

function setupCounter(init)
    if init then
        return {["zoneguid"] = topBoardGUIDs[4],
                ["tooltip"] = "Cops left: __."}
    else
        local woundsdeck = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[4])[1]
        if woundsdeck then
            return math.abs(woundsdeck.getQuantity())
        else
            return 0
        end
    end
end

function lockUp(params)
    local obj = params.obj
    local color = params.player_clicker_color
    obj.setDescription(obj.getDescription() .. "\nARTIFACT: Ensures this card is not removed during clean-up.")
    --obj.locked = true
    local heroguid = obj.guid
    local cops = Global.Call('get_decks_and_cards_from_zone',topBoardGUIDs[4])
    local objpos = obj.getPosition()
    objpos.y = objpos.y + 3
    objpos.z = objpos.z -1
    local lockCop = function(obj)
        --obj.locked = true
        obj.setDescription(obj.getDescription() .. "\nARTIFACT: Ensures this card is not removed during clean-up.")
        _G["giveHero" .. heroguid] = function(params)
            getObjectFromGUID(heroguid).setPosition(getObjectFromGUID(vpileguids[params.id]).getPosition())
        end
        _G["unlock" .. color .. obj.guid .. heroguid] = function(obj,player_clicker_color)
            local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
            if attack < 3 then
                broadcastToColor("You don't have enough attack to beat this cop!",player_clicker_color,player_clicker_color)
                return nil
            end
            getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-3)
            obj.setDescription(obj.getDescription():gsub("\nARTIFACT: Ensures this card is not removed during clean%-up.",""))
            local hero = getObjectFromGUID(heroguid)
            hero.setDescription(hero.getDescription():gsub("\nARTIFACT: Ensures this card is not removed during clean%-up.",""))
            --hero.locked = false
            obj.setPosition(getObjectFromGUID(vpileguids[player_clicker_color]).getPosition())
            obj.clearButtons()
            local choices = {}
            local choicecolors = {}
            for _,o in pairs(Player.getPlayers()) do
                choices[o.color] = o.color
                table.insert(choicecolors,o.color)
            end
            getObjectFromGUID(pushvillainsguid).Call('offerChoice',{color = player_clicker_color,
                choices = choices,
                choicecolors = choicecolors,
                fsourceguid = self.guid,
                resolve_function = 'giveHero' .. heroguid})
            --obj.locked = false
        end
        obj.createButton({click_function="unlock" .. color .. obj.guid .. heroguid,
            function_owner=self,
            position={0,22,0},
            label="Fight",
            tooltip="Fight this cop to rescue the hero",
            font_size=250,
            font_color="Black",
            color={1,1,1},
            width=750,height=450})
    end
    if cops[1] and cops[1].tag == "Deck" then
        cops[1].takeObject({position = objpos,
            callback_function = lockCop,
            smooth = true})
    elseif cops[1] then
        cops[1].setPositionSmooth(objpos)
        lockCop(cops[1])
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved
    for i,o in pairs(vpileguids) do
        if Player[i].seated == true then
            local vpilecontent = Global.Call('get_decks_and_cards_from_zone',o)
            local annipile = getObjectFromGUID(topBoardGUIDs[4])
            local copguids = {}
            if vpilecontent[1] and vpilecontent[1].tag == "Deck" then
                local vpileCards = vpilecontent[1].getObjects()
                for j = 1, vpilecontent[1].getQuantity() do
                    if vpileCards[j].name == "Cops" then
                        table.insert(copguids,vpileCards[j].guid)
                    end
                end
                if vpilecontent[1].getQuantity() ~= #copguids then
                    for j = 1,#copguids do
                        vpilecontent[1].takeObject({position=annipile.getPosition(),
                            guid=copguids[j]})
                    end
                else
                    vpilecontent[1].setPositionSmooth(annipile.getPosition())
                end
            elseif vpilecontent[1] and vpilecontent[1].getName() == "Cops" then
                vpilecontent[1].setPositionSmooth(annipile.getPosition())
            end
        end
    end
    for _,o in pairs(Player.getPlayers()) do
        local hand = o.getHandObjects()
        local handi = table.clone(hand)
        local iter = 0
        for i,obj in ipairs(handi) do
            if not hasTag2(obj,"HC:") then
                table.remove(hand,i-iter)
                iter = iter + 1
            end
        end
        if hand[1] then
            local playcontent = Global.Call('get_decks_and_cards_from_zone',playguids[o.color])
            local copcount = 0
            if playcontent[1] then
                for _,card in pairs(playcontent) do
                    if card.getName() == "Cops" then
                        copcount = copcount + 1
                    end
                end
            end
            getObjectFromGUID(pushvillainsguid).Call('promptDiscard',{color = o.color,
                hand = hand,
                pos = getObjectFromGUID(playerBoards[o.color]).positionToWorld({2-2*copcount,4,3.7}),
                label = "Lock",
                tooltip = "Lock up this card.",
                trigger_function = 'lockUp',
                args = "self",
                fsourceguid = self.guid})
        end
    end
    broadcastToAll("Scheme Twist: Choose a non-grey hero from your hand to be locked up.")
    return twistsresolved
end