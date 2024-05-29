function onLoad()
    local guids1 = {
        "pushvillainsguid",
        "bystandersPileGUID",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end

    prime_sentinel_lua = [[
        local guids = {
            "pushvillainsguid",
            "kopile_guid",
            "playerBoards",
            "discardguids",
            "setupGUID"
            }
            
        for _,o in pairs(guids) do
            _G[o] = Global.Call('table_clone',Global.Call('returnVar',o))
        end
        function bonusInGeneral(params)
            local kopilecontent = Global.Call('get_decks_and_cards_from_zone',kopile_guid)
            local strikes = 0
            for _,o in pairs(kopilecontent.getObjects()) do
                if o.name == "Masterstrike" then
                    strikes = strikes + 1
                end
            end
            getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
                checkvalue = 1,
                label = "+" .. strikes,
                tooltip = "Sentinel masterminds get +1 for each Master Strike in the KO pile.",
                f = "mm",
                id = "bastionsentinel"})
        end
        function resolveStrike(params)
            local strikesresolved = params.strikesresolved
            
            for _,p in pairs(Player.getPlayers()) do
                local playerBoard = getObjectFromGUID(playerBoards[p.color])
                local posdiscard = getObjectFromGUID(discardguids[p.color]).getPosition()
                if Global.Call('table_clone',getObjectFromGUID(setupGUID).Call('returnVar',"setupParts"))[5] == "Bastion, Fused Sentinel - epic" then
                    posdiscard = getObjectFromGUID(kopile_guid).getPosition()
                end
                posdiscard.y = posdiscard.y + 2
                local deck = playerBoard.Call('returnDeck')[1]
                local primeSentinelDiscard = function()
                    if not deck then
                        deck = playerBoard.Call('returnDeck')[1]
                    end
                    if deck and deck.tag == "Deck" then
                        for _,tag in pairs(deck.getObjects()[1].tags) do
                            if tag:find("Cost:") and tonumber(tag:match("%d+")) > 0 then
                                deck.takeObject({position = posdiscard,
                                    flip = true,
                                    smooth = true})
                                break
                            end
                        end
                    elseif deck then
                        if hasTag2(deck,"Cost:") and hasTag2(deck,"Cost:") > 0 then
                            deck.setPosition(posdiscard)
                        end
                    end
                end
                if deck then
                    primeSentinelDiscard()
                else
                    playerBoard.Call('click_refillDeck')
                    deck = nil
                    Wait.time(primeSentinelDiscard,1)
                end
            end
            return strikesresolved
        end
    ]]
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

function resolveStrike(params)
    local strikesresolved = params.strikesresolved
    local epicness = params.epicness

    local mmZone = getObjectFromGUID(mmZoneGUID)
    local zoneguid = mmZone.Call('getNextMMLoc')
    local power = 3
    local mmname = "Bastion, Fused Sentinel"
    if epicness then
        power = 4
        mmname = "Bastion, Fused Sentinel - epic"
    end
    if zoneguid then
        local newsentinelname = "Prime Sentinel " .. strikesresolved
        getObjectFromGUID(bystandersPileGUID).takeObject({position = getObjectFromGUID(zoneguid).getPosition(),
            flip = true,
            smooth = true,
            callback_function = function(obj) 
                obj.addTag("Power:" .. power) 
                obj.addTag("Mastermind")
                obj.removeTag("Bystander")
                obj.setName(newsentinelname)
                mmZone.Call('setupMasterminds',{obj = obj,epicness = false,tactics = 0})
            end})
        mmZone.Call('updateMasterminds',newsentinelname)
        mmZone.Call('updateMastermindsLocation',{newsentinelname,zoneguid})
        local strikeloc = mmZone.Call('getStrikeloc',newsentinelname)
        local strikezone = getObjectFromGUID(strikeloc)
        local prime_sentinel_lua_new = "sentinelzoneguid = \"" .. zoneguid .. "\"\r\n" .. "mmname = \"" .. newsentinelname .. "\"\r\n" .. prime_sentinel_lua
        strikezone.setLuaScript(prime_sentinel_lua_new)
        strikezone.reload()
    else
        broadcastToAll("No additional locations for masterminds found. Sort the extra Prime Sentinel out yourself.")
        return nil
    end
    return strikesresolved
end