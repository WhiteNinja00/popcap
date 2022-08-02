function onCreate()
	-- background shit

     makeLuaSprite('vault','vault',-300,160)
     addLuaSprite('vault',false)

	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end