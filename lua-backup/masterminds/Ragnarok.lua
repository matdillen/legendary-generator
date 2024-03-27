function onLoad()
    mmname = "Ragnarok"
    
    local guids1 = {
        "pushvillainsguid",
        "mmZoneGUID"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_discard",
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
    
    local guids3 = {
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

function updateMMRagnarok()
    local hccolors = {
        ["Red"] = 0,
        ["Yellow"] = 0,
        ["Green"] = 0,
        ["Silver"] = 0,
        ["Blue"] = 0
    }
    for _,o in pairs(hqguids) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            for _,k in pairs(hero.getTags()) do
                if k:find("HC:") then
                    hccolors[k:gsub("HC:","")] = 2
                end
                if k:find("HC1:") then
                    hccolors[k:gsub("HC1:","")] = 2
                end
                if k:find("HC2:") then
                    hccolors[k:gsub("HC2:","")] = 2
                end
            end
        end
    end
    local boost = 0
    for _,o in pairs(hccolors) do
        boost = boost + o
    end
    getObjectFromGUID(mmZoneGUID).Call('mmButtons',{mmname = mmname,
        checkvalue = boost,
        label = "+" .. boost,
        tooltip = "Ragnarok gets +2 for each Hero Class among Heroes in the HQ.",
        f = 'updateMMRagnarok',
        id = "ragnarokHC",
        f_owner = self})
end

function setupMM()
    updateMMRagnarok()
    function onObjectEnterZone(zone,object)
        updateMMRagnarok()
    end
    function onObjectLeaveZone(zone,object)
        updateMMRagnarok()
    end
end

function resolveStrike(params)
    local strikesresolved = params.strikesresolved

    broadcastToAll("Master Strike: Each player says \"zero\" or \"not zero.\" Then, each player discards all their cards with that cost.")
    for _,p in pairs(Player.getPlayers()) do
        local playerboard = getObjectFromGUID(playerBoards[p.color])
        _G["RagnarokDiscardZero" .. p.color] = function(obj)
            local butt = obj.getButtons()
            for i,o in pairs(butt) do
                if o.click_function:find("RagnarokDiscard") then
                    obj.removeButton(i-1)
                end
            end
            for i,o in pairs(playerBoards) do
                if o == obj.guid then
                    local hand = Player[i].getHandObjects()
                    for _,card in pairs(hand) do
                        if not hasTag2(card,"Cost:") or hasTag2(card,"Cost:") < 1 then
                            card.setPosition(getObjectFromGUID(o).positionToWorld(pos_discard))
                        end
                    end
                    break
                end
            end
        end
        _G["RagnarokDiscardNonZero" .. p.color] = function(obj)
            local butt = obj.getButtons()
            for i,o in pairs(butt) do
                if o.click_function:find("RagnarokDiscard") then
                    obj.removeButton(i-1)
                end
            end
            for i,o in pairs(playerBoards) do
                if o == obj.guid then
                    local hand = Player[i].getHandObjects()
                    for _,card in pairs(hand) do
                        if hasTag2(card,"Cost:") and hasTag2(card,"Cost:") > 0 then
                            card.setPosition(getObjectFromGUID(o).positionToWorld(pos_discard))
                        end
                    end
                    break
                end
            end
        end
        playerboard.createButton({click_function="RagnarokDiscardZero" .. p.color,
            function_owner=self,
            position={0,3,5},
            label="Zero",
            tooltip="Discard all cards with a cost of 0.",
            font_size=250,
            font_color="Black",
            color={1,1,0},
            width=750,height=450})
        playerboard.createButton({click_function="RagnarokDiscardNonZero" .. p.color,
            function_owner=self,
            position={0,3,6},
            label="Non-Zero",
            tooltip="Discard all cards that don't cost 0.",
            font_size=250,
            font_color="Black",
            color={1,0,0},
            width=750,height=450})
    end
    return strikesresolved
end