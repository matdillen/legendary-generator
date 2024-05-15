function tacticEffect()
    local current_hq = Global.Call('table_clone',Global.Call('returnVar',"current_hq"))
    for _,o in pairs(current_hq) do
        local hero = getObjectFromGUID(o).Call('getHeroUp')
        if hero then
            getObjectFromGUID(o).Call('editZoneBonus',{id = "annihilusnegativezone",
                value = -2,
                tooltip = "This hero costs 2 less because of Annihilus's Pull into the Negative Zone tactic being fought this turn."})
            local color = Turns.turn_color
            local heroguid = hero.guid
            Wait.condition(
                function()
                    getObjectFromGUID(o).Call('editZoneBonus',{id = "annihilusnegativezone",
                        value = 0,
                        tooltip = "This hero no longer costs less because of Annihilus's Pull into the Negative Zone tactic being fought this turn."})
                end,
                function()
                    local hero = getObjectFromGUID(o).Call('getHeroUp')
                    if Turns.turn_color ~= color or not hero or hero.guid ~= heroguid then
                        return true
                    else
                        return false
                    end
                end)
        end
    end
end