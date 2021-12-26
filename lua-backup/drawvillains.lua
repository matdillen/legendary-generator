function onLoad()
    self.createButton({
        click_function="click_draw_villain", function_owner=self,
        position={0,0,0}, label="Draw villain", color={1,1,1,0}, width=2000, height=3000,
		tooltip = "Draw card from villain deck."
    })
    pushvillainsguid = "f3c7e3"
end

function click_draw_villain()
    getObjectFromGUID(pushvillainsguid).Call('click_draw_villain')
end