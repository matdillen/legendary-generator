function onLoad()
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_discard"
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
