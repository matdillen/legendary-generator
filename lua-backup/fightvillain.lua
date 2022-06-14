--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
    setupGUID = "912967"
    
    local guids3 = {
        "discardguids",
        "cityguids",
        "vpileguids",
        "shardguids",
        "attackguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = callGUID(o,3)
    end
    
    local guids2 = {
       "allTopBoardGUIDS"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = callGUID(o,2)
    end
        
    local guids1 = {
        "heroDeckZoneGUID",
        "pushvillainsguid",
        "mmZoneGUID"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = callGUID(o,1)
    end
    
    for i,o in pairs(cityguids) do
        if o == self.guid then
            zoneName = i
        end
    end
    toggleButton()
    
    zoneBonuses = {}
    objectsInside = {}
end

function toggleButton()
    if self.getButtons() then
        self.clearButtons()
    else
        self.createButton({
            click_function="click_fight_villain", function_owner=self,
            position={0,-0.4,-0.4}, rotation = {0,180,0}, label=zoneName, 
            tooltip = "Fight the villain in this city space!", color={1,0,0,0.9}, 
            font_color = {0,0,0}, width=750, height=150,
            font_size = 75
        })
    end
end

function callGUID(var,what)
    if not var then
        log("Error, can't fetch guid of object with name nil.")
        return nil
    elseif not what then
        log("Error, can't fetch guid of object with missing type.")
        return nil
    end
    if what == 1 then
        return getObjectFromGUID(setupGUID).Call('returnVar',var)
    elseif what == 2 then
        return table.clone(getObjectFromGUID(setupGUID).Call('returnVar',var))
    elseif what == 3 then
        return table.clone(getObjectFromGUID(setupGUID).Call('returnVar',var),true)
    else
        log("Error, can't fetch guid of object with unknown type.")
        return nil
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

function onObjectEnterZone(zone,object)
    if zone.guid == self.guid and not objectsInside[object.guid] then
        objectsInside[object.guid] = true
        Wait.condition(setZonePower,function()
            if object.isSmoothMoving() or object.held_by_color then
                return false
            else
                return true
            end
        end)
    end
end

function onObjectLeaveZone(zone,object)
    if zone.guid == self.guid and objectsInside[object.guid] then
        objectsInside[object.guid] = nil
        if object.hasTag("Villain") then
            if zoneBonuses["base"] then 
                getObjectFromGUID(pushvillainsguid).Call('powerButton',{obj = object,label = zoneBonuses["base"][1],tooltip = zoneBonuses["base"][2]})
            end
            for i,_ in pairs(zoneBonuses) do
                if i ~= "local" then
                    zoneBonuses[i] = nil
                end
            end
        end
        Wait.time(setZonePower,0.2)
    end
end

function updateZonePower(params)
    local label = params.label
    local tooltip = params.tooltip
    local id = params.id
    if not zoneBonuses["local"] then
        zoneBonuses["local"] = {}
    end
    zoneBonuses["local"][id] = {label,tooltip}
    --log(zoneBonuses)
    setZonePower()
end

function setZonePower()
    local cards = get_decks_and_cards_from_zone(self.guid)
    local villainfound = 0
    for _,obj in pairs(cards) do
        if obj.getName() == "Shard" then
            local val = obj.Call('returnVal')
            zoneBonuses["shard"] = {"+" .. val,"Power bonus from shards here."}
        elseif obj.hasTag("Villain") then
            villainfound = 1
            local val = tostring(hasTag2(obj,"Power:"))
            zoneBonuses["card"] = {val,"Base power as written on the card."}
            local butt = obj.getButtons()
            if butt then
                local tip = (butt[1].tooltip:gsub("%[.*",""))
                local box = (butt[1].tooltip:gsub(".*%[",""))
                box = (box:gsub("%]",""))
                zoneBonuses[(box:gsub(":.*",""))] = {(box:gsub(".*:","")),tip}
                obj.clearButtons()
            else
                zoneBonuses["base"] = nil
            end
        end
    end
    if villainfound == 0 then
        for i,_ in pairs(zoneBonuses) do
            if i ~= "local" then
                zoneBonuses[i] = nil
            end
        end
    end
    --log(zoneBonuses)
    local bonusesToUpdate = table.clone(zoneBonuses,true)
    if zoneBonuses["local"] then
        bonusesToUpdate["local"] = nil
        if villainfound > 0 then
            for i,o in pairs(zoneBonuses["local"]) do
                bonusesToUpdate[i] = o
            end
        end
    end
    local lab,tool = getObjectFromGUID(mmZoneGUID).Call('updateLabel',bonusesToUpdate)
    --log("lab: " .. lab or "nil")
    --log("tool: " .. tool or "nil")
    local butt = self.getButtons()
    local buttonindex = nil
    if butt then
        for i,b in pairs(butt) do
            if b.click_function ~= "click_fight_villain" and b.click_function ~= "scan_villain" then
                buttonindex = i -1
                break
            end
        end
    end
    if lab == "" and buttonindex then
        self.removeButton(buttonindex)
    elseif buttonindex then
        self.editButton({index = buttonindex, label = lab, tooltip = tool})
    else
        self.createButton({click_function='setZonePower',
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            label=lab,
            tooltip=tool,
            font_size=300,
            font_color={1,0,0},
            color={0,0,0,0.75},
            width=250,height=150})
    end
end

function hasTag2(obj,tag,index)
    return getObjectFromGUID(setupGUID).Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function updateCityZone()
    cityguids = callGUID("cityguids",3)
    for i,o in pairs(cityguids) do
        if o == self.guid then
            zoneName = i
        end
    end
    self.editButton({index = 0,
        label = zoneName})
end

function click_fight_villain_call(params)
    click_fight_villain(params.obj,params.color,params.otherguid)
end

function click_fight_villain(obj, player_clicker_color,otherguid)
    local guid = otherguid or self.guid
    local cards = get_decks_and_cards_from_zone(guid)
    if not cards[1] then
        return nil
    end
    
    local schemeParts = getObjectFromGUID(setupGUID).Call('returnSetupParts')
    if not schemeParts then
        printToAll("No scheme specified!")
        schemeParts = {"no scheme"}
    end
    
    local dest = getObjectFromGUID(vpileguids[player_clicker_color]).getPosition()
    dest.y = dest.y + 3
    
    if player_clicker_color == "White" then
        angle = 90
    elseif player_clicker_color == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    
    for i,obj in pairs(cards) do
        if obj.hasTag("Villain") then
            local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
            local power = hasTag2(obj,"Power:") or 0
            if obj.getButtons() then
                for _,b in pairs(obj.getButtons()) do
                    if b.click_function == "updatePower" then
                        if b.label:match("%d+") and not b.label:find("-") then
                            power = power + tonumber(b.label:match("%d+"))
                        elseif b.label:match("%d+") then
                            power = power - tonumber(b.label:match("%d+"))
                        elseif b.label == "X" then
                            broadcastToColor("You can't fight this villain right now due to some restriction!",player_clicker_color,player_clicker_color)
                            return nil
                        end
                    end
                end
            end
            if attack < power then
                broadcastToColor("You don't have enough attack to fight this villain!",player_clicker_color,player_clicker_color)
                return nil
            else
                getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-power)
                local result = getObjectFromGUID(pushvillainsguid).Call('resolveVillainEffect',{obj = obj,color = player_clicker_color})
                if result then
                    obj.setRotationSmooth(brot)
                    obj.setPositionSmooth(dest)
                    broadcastToColor("You defeated the Villain " .. obj.getName() .. " and it was put into your victory pile.",player_clicker_color,player_clicker_color)
                end
                cards[i] = nil
                for _,obj2 in pairs(cards) do
                    if obj2 and not obj2.hasTag("Location") then
                        if obj2.hasTag("Bystander") and obj2.getName() ~= "" then
                            broadcastToColor("You saved " .. obj2.getName() .. ", a special bystander!",player_clicker_color,player_clicker_color)
                        elseif obj2.hasTag("Bystander") and obj2.tag == "Deck" then
                            broadcastToColor("You saved " .. obj2.getQuantity() .. " bystanders!",player_clicker_color,player_clicker_color)
                        elseif obj2.hasTag("Bystander") then
                            broadcastToColor("You saved a regular bystander!",player_clicker_color,player_clicker_color)
                        end
                        if obj2.getName() == "Shard" then
                            getObjectFromGUID(shardguids[player_clicker_color]).Call('add_subtract')
                            local pos = getObjectFromGUID(heroDeckZoneGUID).getPosition()
                            pos.x = pos.x + 7
                            obj2.setPositionSmooth(pos)
                            broadcastToColor("You gained a shard!",player_clicker_color,player_clicker_color)
                        else
                            obj2.setRotationSmooth(brot)
                            if obj2.hasTag("Villainous Weapon") then
                                local pos = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
                                pos.y = pos.y + 3
                                obj2.setPositionSmooth(pos)
                                broadcastToColor("You gained the Villainous Weapon " .. obj2.getName() .. " to your discard pile!",player_clicker_color,player_clicker_color)
                            else
                                obj2.setPositionSmooth(dest)
                            end
                        end
                    end
                end
            end
        end
    end
end

function scan_villain(obj,player_clicker_color)
    local cards = get_decks_and_cards_from_zone(self.guid)
    if not cards[1] then
        return nil
    end
    local attack = getObjectFromGUID(attackguids[player_clicker_color]).Call('returnVal')
    if attack < 1 then
        broadcastToColor("You don't have enough attack to scan this city space!",player_clicker_color,player_clicker_color)
        return nil
    end
    getObjectFromGUID(attackguids[player_clicker_color]).Call('addValue',-1)
    for _,obj in pairs(cards) do
        if obj.hasTag("Alien Brood") then
            obj.removeTag("Alien Brood")
            obj.flip()
            getObjectFromGUID(pushvillainsguid).Call('resolve_alien_brood_scan',obj)
            self.editButton({index = 0,label = zoneName, tooltip = "Fight the villain in this city space!", click_function = 'click_fight_villain'})
        end
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    --this function returns cards, decks and shards in a city space (or the start zone)
    --returns a table of objects
    local zone = getObjectFromGUID(zoneGUID)
    if zone then
        decks = zone.getObjects()
    else
        return nil
    end
    local shardname = "Shard"
    local hopename = "Baby Hope Token"
    if shardinc == false then
        shardname = "notShardName"
        hopename = "notBaby Hope Token"
    end
    local result = {}
    if decks then
        for k, deck in pairs(decks) do
            if deck.tag == "Deck" or deck.tag == "Card" or deck.getName() == shardname or deck.getName() == hopename then
                if bsinc == nil or not deck.hasTag("Bystander") then
                    table.insert(result, deck)
                end
            end
        end
    end
    return result
end