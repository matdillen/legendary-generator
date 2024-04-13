function onLoad()
    local guids1 = {
        "pushvillainsguid"
    }
    
    for _,o in pairs(guids1) do
        _G[o] = Global.Call('returnVar',o)
    end
end

function checkViewButton()
    local content = Global.Call('get_decks_and_cards_from_zone',self.guid)
    if content[1] then
        local deckfound = false
        for _,o in pairs(content) do
            if o.tag == "Deck" then
                showViewButton()
                deckfound = true
                break
            end
        end
        if deckfound == false then
            removeViewButton()
        end
    end
end

-- function onObjectEnterZone()
--     Wait.time(checkViewButton,0.5)
-- end

-- function onObjectLeaveZone()
--     Wait.time(checkViewButton,0.5)
-- end

function showViewButton()
    self.createButton({
        click_function="view_villainstuff", function_owner=self,
        position={0,-0.4,0}, rotation = {0,180,0}, label="View", 
        tooltip = "View the stacked bystanders, heroes, villainous weapons in this space.", color={1,1,0,0.9}, 
        font_color = {0,0,0}, width=750, height=150,
        font_size = 75
    })
end

function removeViewButton()
    local butt = self.getButtons()
    if butt then
        for i,o in pairs(butt) do 
            if o.click_function == "view_villainstuff" then
                self.removeButton(i-1)
            end
        end
    end
end

function view_villainstuff(obj,player_clicker_color)
    -- spread out all the cards locked above the space. clicking again returns them to deck
end