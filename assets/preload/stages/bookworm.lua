function onCreate()
	-- background shit

     makeLuaSprite('bookworm bg','bookworm bg',-300,160)
     addLuaSprite('bookworm bg',false)

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end