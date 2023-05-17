function onLoad()   
    local guids1 = {
        "pushvillainsguid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "city_zones_guids",
        "hqguids"
        }
        
    for _,o in pairs(guids2) do
        _G[o] = {table.unpack(Global.Call('returnVar',o))}
    end
end

function hasTag2(obj,tag,index)
    return Global.Call('hasTag2',{obj = obj,tag = tag,index = index})
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards

    getObjectFromGUID(pushvillainsguid).Call('stackTwist',cards[1])
    if twistsresolved < 5 then
        broadcastToAll("Scheme Twist: Choose " .. twistsresolved .. " different Hero Classes and each hero in the HQ that is any of them will be KO'd.",{1,1,1})
        local mmpromptzone = getObjectFromGUID(city_zones_guids[4])
        local zshift = 0
        local colorspicked = {}
        local buttonindices = {}
        local colors = {"Green","Yellow","Red","Silver","Blue"}
        local colorlabs = {"Green","Yellow","Red","White","Blue"}
        for i,o in ipairs(colors) do
            buttonindices[i] = i-1
            _G["helicarrierColor" .. i] = function()
                mmpromptzone.removeButton(buttonindices[i])
                for i2,o2 in pairs(buttonindices) do
                    if i2 > i then
                        buttonindices[i2] = o2-1
                    end
                end
                table.insert(colorspicked,o)
                if #colorspicked > twistsresolved - 1 then
                    mmpromptzone.clearButtons()
                    for _,o3 in pairs(hqguids) do
                        local hero = getObjectFromGUID(o3).Call('getHeroUp')
                        if hero then 
                            for _,color in pairs(colorspicked) do
                                if hero.hasTag("HC:" .. color) then
                                    getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                                    getObjectFromGUID(o3).Call('click_draw_hero')
                                    break
                                end
                            end
                        end
                    end
                end
            end
            mmpromptzone.createButton({click_function="helicarrierColor" .. i,
                function_owner=self,
                position={0,0,zshift},
                rotation={0,180,0},
                label=o,
                tooltip="Heroes with this hero color will be KO'd: " .. o,
                font_size=100,
                font_color="Black",
                color=colorlabs[i],
                width=1500,height=50})
            zshift = zshift + 0.5
        end
    else
        broadcastToAll("Scheme Twist: All heroes in the HQ with a hero class KO'd!")
        for _,o in pairs(hqguids) do
            local hero = getObjectFromGUID(o).Call('getHeroUp')
            --log(hero)
            if hero and hasTag2(hero,"HC:",4) then
                getObjectFromGUID(pushvillainsguid).Call('koCard',hero)
                getObjectFromGUID(o).Call('click_draw_hero')
            end
        end
    end
    return nil
end
