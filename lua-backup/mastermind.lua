function onLoad()
    self.createButton({
        click_function="click_update_tactics", function_owner=self,
        position={0,0,1}, rotation={0,180,0}, height=250, color={0,0,0,0.75},
        label = "(4)",font_color = {1,0.1,0,1}, tooltip="Remaining tactics. Click to force update."
    })
end

function click_update_tactics()
    local setupf = getObjectFromGUID("912967")
    local mmdeck = setupf.Call('get_decks_and_cards_from_zone',self.guid)
    if mmdeck[1] and mmdeck[2] then
        for _,o in pairs(mmdeck) do
            if o.is_face_down and (not o.hasTag("Mastermind") or hasTag2(o,"Tactic:")) then
                local c = math.abs(o.getQuantity())
                self.editButton({index=0,label="(" .. c .. ")"})
                return nil
            end
        end
    elseif mmdeck[1] then
        self.editButton({index=0,label="(" .. math.abs(mmdeck[1].getQuantity())-1 .. ")"})
    else
        self.editButton({index=0,label="(" .. 0 .. ")"})
    end
end

function hasTag2(obj,tag,index)
    if not obj or not tag then
        return nil
    end
    for _,o in pairs(obj.getTags()) do
        if o:find(tag) then
            if index then
                return o:sub(index,-1)
            else 
                local res = tonumber(o:match("%d+"))
                if res then
                    return res
                else
                    return o:sub(#tag+1,-1)
                end
            end
        end
    end
    return nil
end