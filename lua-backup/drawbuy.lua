--Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()

    self.createButton({
        click_function="click_draw_hero", function_owner=self,
        position={0,0,0}, label="Draw hero", color={1,1,1,0}, width=2000, height=3000
    })

    toggleButton()
    
    local guids3 = {
        "resourceguids",
        "vpileguids",
        "attackguids",
        "drawguids",
        "discardguids",
        "addguids"
    }
    
    for _,o in pairs(guids3) do
        _G[o] = table.clone(Global.Call('returnVar',o),true)
    end
    
    local guids2 = {
       "hqguids",
       "hqscriptguids"
    }
    
    for _,o in pairs(guids2) do
        _G[o] = table.clone(Global.Call('returnVar',o))
    end
        
    local guids1 = {
        "heroDeckZoneGUID",
        "kopile_guid",
        "twistZoneGUID",
        "pushvillainsguid",
        "setupGUID",
        "shardspaceguid",
        "madamehydrazoneguid",
        "recruitszoneguid"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    for i,o in pairs(hqguids) do
        if o == self.guid then
            scriptguid = hqscriptguids[i]
        end
    end
    if not scriptguid then
        local pos = self.getPosition()
        if pos.z < 5 then
            scriptguid = shardspaceguid
        elseif pos.x < -16 then
            scriptguid = madamehydrazoneguid
        else
            scriptguid = recruitszoneguid
        end
    end

    zonebonus = {}
    heroinside = {}
end

function logg(name,event,guid,txt)
    Global.Call('logg',{name = name,
        event = event,
        guid = guid,
        txt = txt})
end

function toggleButton()
    for i,b in pairs(self.getButtons()) do
        if b.click_function == "click_buy_hero" then
            self.removeButton(i - 1)
            return nil
        end
    end
    self.createButton({
         click_function="click_buy_hero", function_owner=self,
         position={0,0.4,2.5}, label="Buy hero", color={1,1,0,0.9}, width=2000, height=1000,
         font_size = 250, tooltip = "Buy this hero."
    })
end

function updateVar1(params)
    _G[params.name] = params.value
end

function updateVar2(params)
    _G[params.name] = table.clone(params.value)
end

function updateVar3(params)
    _G[params.name] = table.clone(params.value,true)
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

function click_buy_hero(obj, player_clicker_color)
    local fn = "click_buy_hero"
    local card = getHero(false,nil,true)
    if not card then
        logg(fn,"getHero",self.guid,"Hero not found.")
        return nil
    end
    if not scheme then
        scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
    end

    local recruit = getObjectFromGUID(resourceguids[player_clicker_color]).Call('returnVal')
    local cost = hasTag2(card,"Cost:") or 0
    if recruit < cost then
        broadcastToColor("You don't have enough recruit to buy this hero!",player_clicker_color,player_clicker_color)
        return nil
    else
        getObjectFromGUID(resourceguids[player_clicker_color]).Call('addValue',-cost)
        logg(fn,"addValue",resourceguids[player_clicker_color],"Recruit reduced by " .. cost .. " to buy hero " .. card.guid .. " (" .. card.getName() .. ").")
        local desc = card.getDescription()
        local dest = getObjectFromGUID(discardguids[player_clicker_color]).getPosition()
        if desc:find("WALL%-CRAWL") or scheme.getName() == "Splice Humans with Spider DNA" then
            dest = getObjectFromGUID(drawguids[player_clicker_color]).getPosition()
            card.flip()
        elseif desc:find("SOARING FLIGHT") then
            dest = getObjectFromGUID(addguids[player_clicker_color]).getPosition()
        end

        if scheme.getVar("buyEffect") then
            scheme.Call('buyEffect',{obj = obj,
                color = player_clicker_color})
        end
        dest.y = dest.y+3
        card.setPositionSmooth(dest)
        
        click_draw_hero()
    end
end

function getHero(face,bs,hero)
    local objects = get_decks_and_cards_from_zone(scriptguid)
    local card = nil
    for _,item in pairs(objects) do
        if hero and hasTag2(item,"HC:") then
            card = item
            break
        end
        if item.tag == "Card" and item.is_face_down == face and (not bs or item.hasTag(bs)) then
            card = item
        elseif item.tag == "Deck" and item.is_face_down == true and face == true and (not bs or item.hasTag(bs)) then
            card = item
        end
    end
    if not card then 
        return nil
    end
    return card
end

function getHeroUp()
    return getHero(false,nil,true)
end

function getHeroDown()
    return getHero(true)
end

function getBystander()
    return getHero(false,"Bystander")
end

function getWound()
    return getHero(false,"Wound")
end

function getCards()
    local objects = get_decks_and_cards_from_zone(scriptguid)
    return objects
end

function tuckHero()
    local hero = getHero(false)
    if hero then
        hero.setPosition(getObjectFromGUID(heroDeckZoneGUID).getPosition())
        click_draw_hero()
    end
end

function click_draw_hero()
    local hero_deck = get_decks_and_cards_from_zone(heroDeckZoneGUID)
    if not hero_deck[1] then
        return nil
    end
    if not scheme then
        scheme = getObjectFromGUID(setupGUID).Call('returnVar',"scheme")
    end
    local flip = hero_deck[1].is_face_down
    local callbackf = nil
    if scheme and scheme.getVar("drawHeroSpecial") then
        local resp = scheme.Call('drawHeroSpecial',{hero_deck = hero_deck,flip = flip})
        if resp.callbackf then
            callbackf = resp.callbackf
        end
        if resp.flip then
            flip = resp.flip
        end
    end
    local callbackf_wrapper = function(obj)
        if scheme and callbackf then
            scheme.Call(callbackf,obj)
        end
    end
    local pos = self.getPosition()
    pos.y = pos.y + 5
    if hero_deck[1] then
        if hero_deck[1].tag == "Deck" then
            hero_deck[1].takeObject({
                position = pos,
                flip = flip,
                callback_function = callbackf_wrapper
            })
        else
            if flip then
                hero_deck[1].flip()
            end
            hero_deck[1].setPositionSmooth(pos)
        end
    else
        printToAll("No hero deck found")
    end
    Wait.time(updateCost,1)
end

function editZoneBonus(params)
    zonebonus[params.id] = {params.value,params.tooltip}
    updateCost()
end

function updateCost()
    local hero = getHero(false)
    local cost = ""
    if hero then
        cost = hasTag2(hero,"Cost:") or ""
    end
    local tooltip = "[base]: " .. cost
    if cost ~= "" then
        for i,o in pairs(zonebonus) do
            cost = cost + o[1]
            tooltip = tooltip .. "\n" .. o[2] .. "[" .. i .. ":" .. o[1] .. "]"
        end
    end
    local scriptZone = getObjectFromGUID(scriptguid)
    local butt = scriptZone.getButtons()
    local buttonindex = nil
    if butt then
        for i,b in pairs(butt) do
            if b.click_function == "updateCost" then
                buttonindex = i -1
                break
            end
        end
    end
    if buttonindex and cost == "" then
        scriptZone.removeButton(buttonindex)
    elseif buttonindex then
        scriptZone.editButton({index = buttonindex, label = cost, tooltip = tooltip})
    else
        scriptZone.createButton({click_function='updateCost',
            function_owner=self,
            position={0,0,0},
            rotation={0,180,0},
            scale = {1,1,0.5},
            label=cost,
            tooltip=tooltip,
            font_size=300,
            font_color={1,1,0},
            color={0,0,0,0.75},
            width=250,height=150})
    end
end

function onObjectEnterZone(zone,object)
    if zone.guid == self.guid and not heroinside[object.guid] and object.hasTag("Hero") then
        heroinside[object.guid] = true
        Wait.condition(updateCost,function()
            if object.isSmoothMoving() or object.held_by_color then
                return false
            else
                return true
            end
        end)
    end
end

function onObjectLeaveZone(zone,object)
    if zone.guid == self.guid and heroinside[object.guid] then
        heroinside[object.guid] = nil
        Wait.condition(updateCost,function()
            local hero = getHero(false)
            if hero and hero.guid == object.guid then
                return false
            else
                return true
            end
        end)
    end
end

function get_decks_and_cards_from_zone(zoneGUID,shardinc,bsinc)
    return Global.Call('get_decks_and_cards_from_zone2',{zoneGUID=zoneGUID,shardinc=shardinc,bsinc=bsinc})
end