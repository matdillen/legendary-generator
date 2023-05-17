function onLoad()   
    local guids1 = {
        "pushvillainsguid",
        "twistZoneGUID",
        "escape_zone_guid"
        }
        
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
    
    local guids2 = {
        "pos_vp2"
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

function click_save_silent_witness(obj,player_clicker_color)
    local hulkdeck = Global.Call('get_decks_and_cards_from_zone',obj.guid)[1]
    if not hulkdeck then
        return nil
    end
    local playerBoard = getObjectFromGUID(playerBoards[player_clicker_color])
    local dest = playerBoard.positionToWorld(pos_vp2)
    dest.y = dest.y + 3
    if player_clicker_color == "White" then
        angle = 90
    elseif player_clicker_color == "Blue" then
        angle = -90
    else
        angle = 180
    end
    local brot = {x=0, y=angle, z=0}
    if hulkdeck.tag == "Card" then
        hulkdeck.flip()
        hulkdeck.setRotationSmooth(brot)
        hulkdeck.setPositionSmooth(dest)
    else
        hulkdeck.takeObject({position = dest,
            flip = true,
            smooth = true,
            index = math.random(hulkdeck.getQuantity())-1})
    end
end

function resolveTwist(params)
    local twistsresolved = params.twistsresolved 
    local cards = params.cards
    local city = params.city

    if twistsresolved == 1 then
        getObjectFromGUID(twistZoneGUID).createButton({click_function='click_save_silent_witness', 
                 function_owner=self,
                 position={0,0,0.5},
                 rotation={0,180,0},
                 label="Save",
                 tooltip="Save a Hidden Witness by paying 2 recruit and rescue it as a bystander.",
                 color={0,0,0,1},
                 font_color = {1,0,0},
                 width=500,
                 height=200,
                 font_size = 100})
        getObjectFromGUID(twistZoneGUID).createButton({click_function='updatePower',
                    function_owner=getObjectFromGUID(pushvillainsguid),
                    position={0,0,0},
                    rotation={0,180,0},
                    label=2,
                    tooltip="You can save these Hidden Witnesses for 2 Recruit to rescue them as Bystanders.",
                    font_size=250,
                    font_color="Yellow",
                    width=0})
    end
    local witnesses = Global.Call('get_decks_and_cards_from_zone',twistZoneGUID)
    broadcastToAll("Scheme Twist: All Silent Witnesses escape and three new ones are added.")
    for _,o in pairs(witnesses) do
        o.flip()
        o.setPositionSmooth(getObjectFromGUID(escape_zone_guid).getPosition())
    end
    for i = 1,3 do
        getObjectFromGUID(pushvillainsguid).Call('addBystanders2',{cityspace = twistZoneGUID,
            face = false,
            posabsolute = true})
    end
    return twistsresolved
end
