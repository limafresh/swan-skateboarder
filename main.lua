function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function drawCheckmark(x, y, size)
	local x1 = x
	local y1 = y + size * 0.5

	local x2 = x + size * 0.5
	local y2 = y + size

	local x3 = x + size * 1.5
	local y3 = y

	love.graphics.line(x1, y1, x2, y2, x3, y3)
end

function drawPrice(x, y, price)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
	love.graphics.print(price, x, y)
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	love.graphics.draw(coin, x + 30, y, 0, 0.5, 0.5)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
end

function applyIsland()
	location = "Island"
	currentBackground = 6
	currentLand = 1
	currentObstacle = 2
end

function applyConiferousForest()
	location = "Coniferous forest"
	currentBackground = 7
	currentLand = 2
	currentObstacle = 3
end

function applyLandOfSnow()
	location = "Land of snow"
	currentBackground = 8
	currentLand = 3
	currentObstacle = 4
end

function applySpace()
	location = "Space"
	currentBackground = 9
	currentLand = 4
	currentObstacle = 5
end

function applyMuseum()
	location = "Museum"
	currentBackground = 10
	currentLand = 5
	currentObstacle = 6
end

function applyKitchen()
	location = "Kitchen"
	currentBackground = 11
	currentLand = 6
	currentObstacle = 7
end

function applyWarehouse()
	location = "Warehouse"
	currentBackground = 12
	currentLand = 7
	currentObstacle = 8
end

function resetPositions()
	gameOver = false
	love.audio.play(backgroundMusic)

	currentSwanRotation = 1

	obstacleX = 300
	obstacleY = 400
	obstacleRotated = false

	swanX = 0
	swanY = 0
	mouseStartY = nil
	futureSwanY = nil

	bgTimer = 0
	swanTimer = 0
	notEnoughCoinsTimer = 2

	coinY = 320

	scroll = 0

	if location == "City of Dreams" then
		currentBackground = 1
	end

	forThisTime = 0

	isMenuOpen = false
end

function love.load()
	love.graphics.setScissor(0, 0, 360, 640)
	backgrounds = {
		love.graphics.newImage("backgrounds/cityofdreams1.png"),
		love.graphics.newImage("backgrounds/cityofdreams2.png"),
		love.graphics.newImage("backgrounds/cityofdreams3.png"),
		love.graphics.newImage("backgrounds/cityofdreams4.png"),
		love.graphics.newImage("backgrounds/cityofdreams5.png"),
		love.graphics.newImage("backgrounds/fading_sky.png"),
		love.graphics.newImage("backgrounds/cloudy_sky.png"),
		love.graphics.newImage("backgrounds/wispy_sky.png"),
		love.graphics.newImage("backgrounds/space.png"),
		love.graphics.newImage("backgrounds/museum.png"),
		love.graphics.newImage("backgrounds/kitchen.png"),
		love.graphics.newImage("backgrounds/warehouse.png")
	}

	lands = {
		love.graphics.newImage("lands/island.png"),
		love.graphics.newImage("lands/coniferous_forest.png"),
		love.graphics.newImage("lands/land_of_snow.png"),
		love.graphics.newImage("lands/space.png"),
		love.graphics.newImage("lands/museum.png"),
		love.graphics.newImage("lands/kitchen.png"),
		love.graphics.newImage("lands/warehouse.png"),
	}

	for land = 1, #lands do
		lands[land]:setWrap("repeat", "clamp")
	end

	obstacles = {
		love.graphics.newImage("obstacles/skyscraper.png"),
		love.graphics.newImage("obstacles/palm.png"),
		love.graphics.newImage("obstacles/christmas_tree.png"),
		love.graphics.newImage("obstacles/snowman.png"),
		love.graphics.newImage("obstacles/rocket.png"),
		love.graphics.newImage("obstacles/statue.png"),
		love.graphics.newImage("obstacles/fridge.png"),
		love.graphics.newImage("obstacles/obstacle.png")
	}

	swans = {
		love.graphics.newImage("swans/classic1.png"),
		love.graphics.newImage("swans/classic2.png"),
		love.graphics.newImage("swans/classic3.png"),
		love.graphics.newImage("swans/mask1.png"),
		love.graphics.newImage("swans/mask2.png"),
		love.graphics.newImage("swans/mask3.png"),
		love.graphics.newImage("swans/hat1.png"),
		love.graphics.newImage("swans/hat2.png"),
		love.graphics.newImage("swans/hat3.png"),
		love.graphics.newImage("swans/friends1.png"),
		love.graphics.newImage("swans/friends2.png"),
		love.graphics.newImage("swans/friends3.png"),
		love.graphics.newImage("swans/fashionista1.png"),
		love.graphics.newImage("swans/fashionista2.png"),
		love.graphics.newImage("swans/fashionista3.png"),
		love.graphics.newImage("swans/fun1.png"),
		love.graphics.newImage("swans/fun2.png"),
		love.graphics.newImage("swans/fun3.png"),
		love.graphics.newImage("swans/bear1.png"),
		love.graphics.newImage("swans/bear2.png"),
		love.graphics.newImage("swans/bear3.png"),
		love.graphics.newImage("swans/scarf1.png"),
		love.graphics.newImage("swans/scarf2.png"),
		love.graphics.newImage("swans/scarf3.png")
	}

	coin = love.graphics.newImage("assets/coin.png")

	coinSound = love.audio.newSource("assets/coin.flac", "static")
	backgroundMusic = love.audio.newSource("assets/awake10_megaWall.mp3", "static")
	gameOverSound = love.audio.newSource("assets/game_over_bad_chest.wav", "static")

	settingsIcon = love.graphics.newImage("icons/settings.png")
	skinsIcon = love.graphics.newImage("icons/skins.png")
	locationsIcon = love.graphics.newImage("icons/locations.png")

	locationQuad = love.graphics.newQuad(0, 189, 360, 262, 360, 640)
	landQuad = love.graphics.newQuad(0, 378, 360, 262, 360, 640)

	swanRotations = {0, -15, 15}

	speed = 500

	currentBackground = 1
	currentLand = 1
	currentObstacle = 1
	currentSwan = 1

	mode = "Easy"
	skin = "Classic"
	location = "City of Dreams"

	forAllTimes = 0
	language = "en"

	boughtMask = false
	boughtHat = false
	boughtFriends = false
	boughtFashionista = false
	boughtFun = false
	boughtBear = false
	boughtScarf = false

	boughtIsland = false
	boughtConiferousForest = false
	boughtLandOfSnow = false
	boughtSpace = false
	boughtMuseum = false
	boughtKitchen = false
	boughtWarehouse = false

	-- Load progress
	if love.filesystem.getInfo("forAllTimes.txt") then
		local contents = love.filesystem.read("forAllTimes.txt")
		forAllTimes = tonumber(contents)
	end
	if love.filesystem.getInfo("language.txt") then language = love.filesystem.read("language.txt") end
	-- Skins
	if love.filesystem.getInfo("boughtMask.txt") then
		if love.filesystem.read("boughtMask.txt") == "true" then boughtMask = true end
	end
	if love.filesystem.getInfo("boughtHat.txt") then
		if love.filesystem.read("boughtHat.txt") == "true" then boughtHat = true end
	end
	if love.filesystem.getInfo("boughtFriends.txt") then
		if love.filesystem.read("boughtFriends.txt") == "true" then boughtFriends = true end
	end
	if love.filesystem.getInfo("boughtFashionista.txt") then
		if love.filesystem.read("boughtFashionista.txt") == "true" then boughtFashionista = true end
	end
	if love.filesystem.getInfo("boughtFun.txt") then
		if love.filesystem.read("boughtFun.txt") == "true" then boughtFun = true end
	end
	if love.filesystem.getInfo("boughtBear.txt") then
		if love.filesystem.read("boughtBear.txt") == "true" then boughtBear = true end
	end
	if love.filesystem.getInfo("boughtScarf.txt") then
		if love.filesystem.read("boughtScarf.txt") == "true" then boughtScarf = true end
	end
	-- Locations
	if love.filesystem.getInfo("boughtIsland.txt") then
		if love.filesystem.read("boughtIsland.txt") == "true" then boughtIsland = true end
	end
	if love.filesystem.getInfo("boughtConiferousForest.txt") then
		if love.filesystem.read("boughtConiferousForest.txt") == "true" then boughtConiferousForest = true end
	end
	if love.filesystem.getInfo("boughtLandOfSnow.txt") then
		if love.filesystem.read("boughtLandOfSnow.txt") == "true" then boughtLandOfSnow = true end
	end
	if love.filesystem.getInfo("boughtSpace.txt") then
		if love.filesystem.read("boughtSpace.txt") == "true" then boughtSpace = true end
	end
	if love.filesystem.getInfo("boughtMuseum.txt") then
		if love.filesystem.read("boughtMuseum.txt") == "true" then boughtMuseum = true end
	end
	if love.filesystem.getInfo("boughtKitchen.txt") then
		if love.filesystem.read("boughtKitchen.txt") == "true" then boughtKitchen = true end
	end
	if love.filesystem.getInfo("boughtWarehouse.txt") then
		if love.filesystem.read("boughtWarehouse.txt") == "true" then boughtWarehouse = true end
	end

	fontLarge = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 36)
	fontGameOver = love.graphics.newFont("fonts/Press_Start_2P/PressStart2P-Regular.ttf", 65)
	fontRegular = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 24)
	fontSmall = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 18)

	lastCostumes = {
		Classic = 3,
		["In a mask"] = 6,
		["In a hat"] = 9,
		["With friends"] = 12,
		Fashionista = 15,
		Fun = 18,
		Bear = 21,
		["In a scarf"] = 24
	}

	localization = {
		en = {
			["Swan skateboarder"] = "Swan skateboarder",
			["Easy mode"] = "Easy mode",
			["Hard mode"] = "Hard mode",
			["Click to start again!"] = "Click to start again!",
			["For all times: "] = "For all times: ",
			["For this time: "] = "For this time: ",
			Classic = "Classic",
			["In a mask"] = "In a mask",
			["In a hat"] = "In a hat",
			["With friends"] = "With friends",
			Fashionista = "Fashionista",
			Fun = "Fun",
			Bear = "Bear",
			["In a scarf"] = "In a scarf",
			["City of Dreams"] = "City of Dreams",
			Island = "Island",
			["Coniferous forest"] = "Coniferous forest",
			["Land of snow"] = "Land of snow",
			Space = "Space",
			Museum = "Museum",
			Kitchen = "Kitchen",
			Warehouse = "Warehouse",
			["Not enough coins"] = "Not enough coins"
		},
		uk = {
			["Swan skateboarder"] = "Лебідь-скейтбордист",
			["Easy mode"] = "Легкий режим",
			["Hard mode"] = "Складний режим",
			["Click to start again!"] = "Натисніть, аби почати знову!",
			["For all times: "] = "За всі рази: ",
			["For this time: "] = "За цей раз: ",
			Classic = "Класичний",
			["In a mask"] = "У масці",
			["In a hat"] = "У шляпі",
			["With friends"] = "З друзями",
			Fashionista = "Модник",
			Fun = "Веселун",
			Bear = "Ведмедик",
			["In a scarf"] = "У шарфі",
			["City of Dreams"] = "Місто Мрії",
			Island = "Острів",
			["Coniferous forest"] = "Хвойний ліс",
			["Land of snow"] = "Земля снігу",
			Space = "Космос",
			Museum = "Музей",
			Kitchen = "Кухня",
			Warehouse = "Склад",
			["Not enough coins"] = "Недостатньо монет"
		}
	}

	resetPositions()
end

function love.update(dt)
	lang = localization[language]
	love.window.setTitle(lang["Swan skateboarder"])
	if not gameOver then
		-- Jump
		if futureSwanY and swanY > futureSwanY then
			swanY = swanY - speed *dt
		else
			futureSwanY = nil
			-- The swan always falls down
			if swanY <= 630 then
				swanY = swanY + speed * dt
			end
		end

		-- Swan height limit
		if swanY < -200 then
			swanY = -200
		end

		-- The obstacle always moves from right to left, creating the illusion of movement across the location
		if obstacleX >= -80 then
			obstacleX = obstacleX - speed * dt
		else
			if mode == "Easy" then
				obstacleRotated = not obstacleRotated
			else
				obstacleRotated = ({true, false})[math.random(1, 2)]
			end
			if obstacleRotated then
				obstacleX = 360
				obstacleY = 0
				coinY = 270
			else
				obstacleX = 300
				obstacleY = 400
				coinY = 320
			end
			coinCollected = false
		end

		-- Check collision
		local swanWidth = swans[currentSwan]:getWidth()
		local swanHeight = swans[currentSwan]:getHeight()
		local obstacleWidth = obstacles[currentObstacle]:getWidth()
		local obstacleHeight = obstacles[currentObstacle]:getHeight()
		local coinWidth = 50
		local coinHeight = 50
		if checkCollision(swanX, swanY, swanWidth, swanHeight, obstacleX, obstacleY, obstacleWidth, obstacleHeight) then
			gameOver = true
			love.audio.stop(backgroundMusic)
			love.audio.stop(gameOverSound)
			love.audio.play(gameOverSound)
			love.filesystem.write("forAllTimes.txt", tostring(forAllTimes)) -- Write progress
		end
		-- Collect coin
		if not coinCollected and checkCollision(swanX, swanY, swanWidth, swanHeight, obstacleX, coinY, coinWidth, coinHeight) then
			coinCollected = true
			forThisTime = forThisTime + 1
			forAllTimes = forAllTimes + 1
			love.audio.stop(coinSound)
			love.audio.play(coinSound)
		end

		-- Update background costume
		if location == "City of Dreams" then
			bgTimer = bgTimer + dt
			if bgTimer >= 2 then
				currentBackground = currentBackground + 1
				if currentBackground > 5 then
					currentBackground = 1
				end
				bgTimer = bgTimer - 2
			end
		end

		-- Update swan costume
		swanTimer = swanTimer + dt
		if swanTimer >= 0.5 then
			currentSwan = currentSwan + 1
			if currentSwan > lastCostumes[skin] then
				currentSwan = lastCostumes[skin] - 2
			end
			currentSwanRotation = currentSwanRotation % #swanRotations + 1
			swanTimer = swanTimer - 0.5
		end

		-- Locations with moving land
		if location ~= "City of Dreams" then
			scroll = (scroll + speed * dt) % 360
		end

		-- Controlling a swan with a keyboard
		if love.keyboard.isDown("up") then
			swanY = swanY - 15
		end
	end
	-- Not enough coins timer
	notEnoughCoinsTimer = notEnoughCoinsTimer + dt
end

function love.draw()
	-- Background
	love.graphics.draw(backgrounds[currentBackground], 0, 0)

	-- Locations with moving land
	if location ~= "City of Dreams" then
		love.graphics.draw(lands[currentLand], -scroll, 0)
		love.graphics.draw(lands[currentLand], 360 - scroll, 0)
	end

	-- Obstacle
	local obstacle = obstacles[currentObstacle]
	if obstacleRotated then
		love.graphics.draw(obstacle, obstacleX + obstacle:getWidth()/2, obstacleY + obstacle:getHeight()/2, math.rad(180), 1, 1, obstacle:getWidth()/2, obstacle:getHeight()/2)
	else
		love.graphics.draw(obstacle, obstacleX, obstacleY)
	end

	-- Swan
	local swan = swans[currentSwan]
	love.graphics.draw(swan, swanX + swan:getWidth()/2, swanY + swan:getHeight()/2, math.rad(swanRotations[currentSwanRotation]), 1, 1, swan:getWidth()/2, swan:getHeight()/2)

	-- Coin
	if not coinCollected then
		love.graphics.draw(coin, obstacleX, coinY)
	end

	-- Counter
	love.graphics.setFont(fontLarge)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
	love.graphics.print(forThisTime, 12, 12)
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	love.graphics.print(forThisTime, 10, 10)

	-- Game over screen
	if gameOver then
		-- Background
		love.graphics.setColor(love.math.colorFromBytes(0, 170, 255))
		love.graphics.rectangle("fill", 0, 0, 360, 640)
		-- Restart button
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.rectangle("fill", 0, 400, 360, 240)
		love.graphics.setColor(love.math.colorFromBytes(240, 240, 240))
		love.graphics.rectangle("fill", 10, 410, 340, 220)
		love.graphics.setFont(fontRegular)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.printf(lang["Click to start again!"], 10, 420, 340, "center")
		-- Counter
		love.graphics.setFont(fontSmall)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.print(lang["For this time: "] .. forThisTime, 10, 120)
		love.graphics.print(lang["For all times: "] .. forAllTimes, 10, 140)
		-- Game over label
		love.graphics.setFont(fontGameOver)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.printf("GAME OVER", 5, 205, 365, "center")
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 0))
		love.graphics.printf("GAME OVER", 0, 200, 360, "center")
		-- Top bar
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.rectangle("fill", 10, 10, 340, 100)
		-- Buttons
		love.graphics.setLineWidth(2)
		love.graphics.setColor(love.math.colorFromBytes(0, 255, 0)) -- settings
		love.graphics.rectangle("fill", 15, 15, 100, 90)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.rectangle("line", 15, 15, 100, 90)
		love.graphics.draw(settingsIcon, 15, 15)
		love.graphics.setColor(love.math.colorFromBytes(0, 230, 230)) -- skins
		love.graphics.rectangle("fill", 130, 15, 100, 90)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.rectangle("line", 130, 15, 100, 90)
		love.graphics.draw(skinsIcon, 130, 15)
		love.graphics.setColor(love.math.colorFromBytes(255, 0, 127)) -- locations
		love.graphics.rectangle("fill", 245, 15, 100, 90)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.rectangle("line", 245, 15, 100, 90)
		love.graphics.draw(locationsIcon, 245, 15)

		-- Menu
		if isMenuOpen then
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 230))
			love.graphics.rectangle("fill", 0, 120, 360, 520)
		end

		-- Settings
		if isMenuOpen and currentCategory == "Settings" then
			love.graphics.setLineWidth(2)
			love.graphics.setFont(fontRegular)
			love.graphics.setColor(love.math.colorFromBytes(0, 230, 230)) -- Easy mode
			love.graphics.rectangle("fill", 10, 130, 340, 160)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("line", 10, 130, 340, 160)
			local textY
			if mode == "Easy" then
				textY = 150
				drawCheckmark(140, 210, 50)
			else
				textY = 130 + (160 - fontRegular:getHeight()) / 2
			end
			love.graphics.printf(lang["Easy mode"], 10, textY, 340, "center")
			love.graphics.setColor(love.math.colorFromBytes(0, 230, 230)) -- Hard mode
			love.graphics.rectangle("fill", 10, 300, 340, 160)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("line", 10, 300, 340, 160)
			if mode == "Hard" then
				textY = 320
				drawCheckmark(140, 380, 50)
			else
				textY = 300 + (160 - fontRegular:getHeight()) / 2
			end
			love.graphics.printf(lang["Hard mode"], 10, textY, 340, "center")
			love.graphics.setColor(love.math.colorFromBytes(0, 230, 230)) -- en
			love.graphics.rectangle("fill", 10, 470, 165, 160)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("line", 10, 470, 165, 160)
			local textY
			if language == "en" then
				textY = 490
				drawCheckmark(60, 550, 50)
			else
				textY = 470 + (160 - fontRegular:getHeight()) / 2
			end
			love.graphics.printf("English", 10, textY, 165, "center")
			love.graphics.setColor(love.math.colorFromBytes(0, 230, 230)) -- uk
			love.graphics.rectangle("fill", 185, 470, 165, 160)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("line", 185, 470, 165, 160)
			local textY
			if language == "uk" then
				textY = 490
				drawCheckmark(235, 550, 50)
			else
				textY = 470 + (160 - fontRegular:getHeight()) / 2
			end
			love.graphics.printf("Українська", 185, textY, 165, "center")
		end

		-- Skins
		if isMenuOpen and currentCategory == "Skins" then
			-- Fills
			love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
			love.graphics.rectangle("fill", 10, 130, 165, 120) -- Classic
			love.graphics.rectangle("fill", 185, 130, 165, 120) -- In a mask
			love.graphics.rectangle("fill", 10, 260, 165, 120) -- In a hat
			love.graphics.rectangle("fill", 185, 260, 165, 120) -- With friends
			love.graphics.rectangle("fill", 10, 390, 165, 120) -- Fashionista
			love.graphics.rectangle("fill", 185, 390, 165, 120) -- Fun
			love.graphics.rectangle("fill", 10, 520, 165, 120) -- Bear
			love.graphics.rectangle("fill", 185, 520, 165, 120) -- In a scarf
			-- Images
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
			love.graphics.draw(swans[1], 60, 150, 0, 0.45, 0.45) -- Classic
			love.graphics.draw(swans[4], 235, 150, 0, 0.45, 0.45) -- In a mask
			love.graphics.draw(swans[7], 60, 273, 0, 0.45, 0.45) -- In a hat
			love.graphics.draw(swans[10], 235, 280, 0, 0.45, 0.45) -- With friends
			love.graphics.draw(swans[13], 60, 403, 0, 0.45, 0.45) -- Fashionista
			love.graphics.draw(swans[16], 235, 400, 0, 0.45, 0.45) -- Fun
			love.graphics.draw(swans[19], 60, 529, 0, 0.45, 0.45) -- Bear
			love.graphics.draw(swans[22], 235, 540, 0, 0.45, 0.45) -- In a scarf
			-- Labels
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
			love.graphics.rectangle("fill", 10, 190, 165, 60) -- Classic
			love.graphics.rectangle("fill", 185, 190, 165, 60) -- In a mask
			love.graphics.rectangle("fill", 10, 320, 165, 60) -- In a hat
			love.graphics.rectangle("fill", 185, 320, 165, 60) -- With friends
			love.graphics.rectangle("fill", 10, 450, 165, 60) -- Fashionista
			love.graphics.rectangle("fill", 185, 450, 165, 60) -- Fun
			love.graphics.rectangle("fill", 10, 580, 165, 60) -- Bear
			love.graphics.rectangle("fill", 185, 580, 165, 60) -- In a scarf
			-- Contours
			love.graphics.setLineWidth(2)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("line", 10, 130, 165, 120) -- Classic
			love.graphics.rectangle("line", 185, 130, 165, 120) -- In a mask
			love.graphics.rectangle("line", 10, 260, 165, 120) -- In a hat
			love.graphics.rectangle("line", 185, 260, 165, 120) -- With friends
			love.graphics.rectangle("line", 10, 390, 165, 120) -- Fashionista
			love.graphics.rectangle("line", 185, 390, 165, 120) -- Fun
			love.graphics.rectangle("line", 10, 520, 165, 120) -- Bear
			love.graphics.rectangle("line", 185, 520, 165, 120) -- In a scarf
			-- Text
			love.graphics.setLineWidth(2)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.setFont(fontSmall)
			if skin == "Classic" then -- Classic
				textY = 190
				drawCheckmark(70, 215, 30)
			else
				textY = 190 + (60 - fontSmall:getHeight()) / 2
			end
			love.graphics.printf(lang.Classic, 10, textY, 165, "center")
			if skin == "In a mask" then -- In a mask
				textY = 190
				drawCheckmark(245, 215, 30)
			else
				if boughtMask then
					textY = 190 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 190
					drawPrice(240, 215, 35)
				end
			end
			love.graphics.printf(lang["In a mask"], 185, textY, 165, "center")
			if skin == "In a hat" then -- In a hat
				textY = 320
				drawCheckmark(70, 345, 30)
			else
				if boughtHat then
					textY = 320 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 320
					drawPrice(65, 345, 40)
				end
			end
			love.graphics.printf(lang["In a hat"], 10, textY, 165, "center")
			if skin == "With friends" then -- With friends
				textY = 320
				drawCheckmark(245, 345, 30)
			else
				if boughtFriends then
					textY = 320 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 320
					drawPrice(240, 345, 45)
				end
			end
			love.graphics.printf(lang["With friends"], 185, textY, 165, "center")
			if skin == "Fashionista" then -- Fashionista
				textY = 450
				drawCheckmark(70, 475, 30)
			else
				if boughtFashionista then
					textY = 450 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 450
					drawPrice(65, 475, 50)
				end
			end
			love.graphics.printf(lang.Fashionista, 10, textY, 165, "center")
			if skin == "Fun" then -- Fun
				textY = 450
				drawCheckmark(245, 475, 30)
			else
				if boughtFun then
					textY = 450 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 450
					drawPrice(240, 475, 55)
				end
			end
			love.graphics.printf(lang.Fun, 185, textY, 165, "center")
			if skin == "Bear" then -- Bear
				textY = 580
				drawCheckmark(70, 605, 30)
			else
				if boughtBear then
					textY = 580 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 580
					drawPrice(65, 605, 60)
				end
			end
			love.graphics.printf(lang.Bear, 10, textY, 165, "center")
			if skin == "In a scarf" then -- In a scarf
				textY = 580
				drawCheckmark(245, 605, 30)
			else
				if boughtScarf then
					textY = 580 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 580
					drawPrice(240, 605, 65)
				end
			end
			love.graphics.printf(lang["In a scarf"], 185, textY, 165, "center")
		end

		-- Locations
		if isMenuOpen and currentCategory == "Locations" then
			-- Fills
			love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
			love.graphics.rectangle("fill", 10, 130, 165, 120) -- City of Dreams
			love.graphics.rectangle("fill", 185, 130, 165, 120) -- Island
			love.graphics.rectangle("fill", 10, 260, 165, 120) -- Coniferous forest
			love.graphics.rectangle("fill", 185, 260, 165, 120) -- Land of snow
			love.graphics.rectangle("fill", 10, 390, 165, 120) -- Space
			love.graphics.rectangle("fill", 185, 390, 165, 120) -- Museum
			love.graphics.rectangle("fill", 10, 520, 165, 120) -- Kitchen
			love.graphics.rectangle("fill", 185, 520, 165, 120) -- Warehouse
			-- Images
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
			love.graphics.draw(backgrounds[1], locationQuad, 10, 130, 0, 0.458, 0.458) -- City of Dreams
			love.graphics.draw(obstacles[1], 75, 135, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[6], locationQuad, 185, 130, 0, 0.458, 0.458) -- Island
			love.graphics.draw(lands[1], landQuad, 185, 130, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[2], 240, 135, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[7], locationQuad, 10, 260, 0, 0.458, 0.458) -- Coniferous forest
			love.graphics.draw(lands[2], landQuad, 10, 260, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[3], 65, 265, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[8], locationQuad, 185, 260, 0, 0.458, 0.458) -- Land of snow
			love.graphics.draw(lands[3], landQuad, 185, 260, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[4], 240, 265, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[9], locationQuad, 10, 390, 0, 0.458, 0.458) -- Space
			love.graphics.draw(lands[4], landQuad, 10, 390, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[5], 75, 395, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[10], locationQuad, 185, 390, 0, 0.458, 0.458) -- Museum
			love.graphics.draw(lands[5], landQuad, 185, 390, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[6], 240, 395, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[11], locationQuad, 10, 520, 0, 0.458, 0.458) -- Kitchen
			love.graphics.draw(lands[6], landQuad, 10, 520, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[7], 75, 525, 0, 0.45, 0.45)
			love.graphics.draw(backgrounds[12], locationQuad, 185, 520, 0, 0.458, 0.458) -- Warehouse
			love.graphics.draw(lands[7], landQuad, 185, 520, 0, 0.458, 0.458)
			love.graphics.draw(obstacles[8], 240, 525, 0, 0.45, 0.45)
			-- Labels
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
			love.graphics.rectangle("fill", 10, 190, 165, 60) -- City of Dreams
			love.graphics.rectangle("fill", 185, 190, 165, 60) -- Island
			love.graphics.rectangle("fill", 10, 320, 165, 60) -- Coniferous forest
			love.graphics.rectangle("fill", 185, 320, 165, 60) -- Land of snow
			love.graphics.rectangle("fill", 10, 450, 165, 60) -- Space
			love.graphics.rectangle("fill", 185, 450, 165, 60) -- Museum
			love.graphics.rectangle("fill", 10, 580, 165, 60) -- Kitchen
			love.graphics.rectangle("fill", 185, 580, 165, 60) -- Warehouse
			-- Contours
			love.graphics.setLineWidth(2)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("line", 10, 130, 165, 120) -- City of Dreams
			love.graphics.rectangle("line", 185, 130, 165, 120) -- Island
			love.graphics.rectangle("line", 10, 260, 165, 120) -- Coniferous forest
			love.graphics.rectangle("line", 185, 260, 165, 120) -- Land of snow
			love.graphics.rectangle("line", 10, 390, 165, 120) -- Space
			love.graphics.rectangle("line", 185, 390, 165, 120) -- Museum
			love.graphics.rectangle("line", 10, 520, 165, 120) -- Kitchen
			love.graphics.rectangle("line", 185, 520, 165, 120) -- Warehouse
			-- Text
			love.graphics.setLineWidth(2)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.setFont(fontSmall)
			if location == "City of Dreams" then -- City of Dreams
				textY = 190
				drawCheckmark(70, 215, 30)
			else
				textY = 190 + (60 - fontSmall:getHeight()) / 2
			end
			love.graphics.printf(lang["City of Dreams"], 10, textY, 165, "center")
			if location == "Island" then -- Island
				textY = 190
				drawCheckmark(245, 215, 30)
			else
				if boughtIsland then
					textY = 190 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 190
					drawPrice(240, 215, 35)
				end
			end
			love.graphics.printf(lang.Island, 185, textY, 165, "center")
			if location == "Coniferous forest" then -- Coniferous forest
				textY = 320
				drawCheckmark(70, 345, 30)
			else
				if boughtConiferousForest then
					textY = 320 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 320
					drawPrice(65, 345, 40)
				end
			end
			love.graphics.printf(lang["Coniferous forest"], 10, textY, 165, "center")
			if location == "Land of snow" then -- Land of snow
				textY = 320
				drawCheckmark(245, 345, 30)
			else
				if boughtLandOfSnow then
					textY = 320 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 320
					drawPrice(240, 345, 45)
				end
			end
			love.graphics.printf(lang["Land of snow"], 185, textY, 165, "center")
			if location == "Space" then -- Space
				textY = 450
				drawCheckmark(70, 475, 30)
			else
				if boughtSpace then
					textY = 450 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 450
					drawPrice(65, 475, 50)
				end
			end
			love.graphics.printf(lang.Space, 10, textY, 165, "center")
			if location == "Museum" then -- Museum
				textY = 450
				drawCheckmark(245, 475, 30)
			else
				if boughtMuseum then
					textY = 450 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 450
					drawPrice(240, 475, 55)
				end
			end
			love.graphics.printf(lang.Museum, 185, textY, 165, "center")
			if location == "Kitchen" then -- Kitchen
				textY = 580
				drawCheckmark(70, 605, 30)
			else
				if boughtKitchen then
					textY = 580 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 580
					drawPrice(65, 605, 60)
				end
			end
			love.graphics.printf(lang.Kitchen, 10, textY, 165, "center")
			if location == "Warehouse" then -- Warehouse
				textY = 580
				drawCheckmark(245, 605, 30)
			else
				if boughtWarehouse then
					textY = 580 + (60 - fontSmall:getHeight()) / 2
				else
					textY = 580
					drawPrice(240, 605, 65)
				end
			end
			love.graphics.printf(lang.Warehouse, 185, textY, 165, "center")
		end
	end
	if notEnoughCoinsTimer < 1 then
		love.graphics.setFont(fontRegular)
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.rectangle("fill", 20, 220, 320, 200)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.printf(lang["Not enough coins"], 20, 220 + (200 - fontRegular:getHeight()) / 2, 320, "center")
	end
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		if not gameOver then
			mouseStartY = y
		else
			-- Touch restart button
			if not isMenuOpen and x >= 0 and x <= 0 + 360 and y >= 400 and y <= 400 + 240 then
				gameOver = false
				resetPositions()
			end
			-- Touch settings button
			if x >= 15 and x <= 15 + 100 and y >= 15 and y <= 15 + 90 then
				isMenuOpen = not isMenuOpen
				currentCategory = "Settings"
			end
			-- Touch skins button
			if x >= 130 and x <= 130 + 100 and y >= 15 and y <= 15 + 90 then
				isMenuOpen = not isMenuOpen
				currentCategory = "Skins"
			end
			-- Touch locations button
			if x >= 245 and x <= 245 + 100 and y >= 15 and y <= 15 + 90 then
				isMenuOpen = not isMenuOpen
				currentCategory = "Locations"
			end
			-- Touch easy mode
			if isMenuOpen and currentCategory == "Settings" and x >= 10 and x <= 10 + 340 and y >= 130 and y <= 130 + 160 then
				mode = "Easy"
			end
			-- Touch hard mode
			if isMenuOpen and currentCategory == "Settings" and x >= 10 and x <= 10 + 340 and y >= 300 and y <= 300 + 160 then
				mode = "Hard"
			end
			-- Eng
			if isMenuOpen and currentCategory == "Settings" and x >= 10 and x <= 10 + 165 and y >= 470 and y <= 470 + 160 then
				language = "en"
				love.filesystem.write("language.txt", "en")
			end
			-- Ukr
			if isMenuOpen and currentCategory == "Settings" and x >= 185 and x <= 185 + 165 and y >= 470 and y <= 470 + 160 then
				language = "uk"
				love.filesystem.write("language.txt", "uk")
			end
			-- Classic or City of Dreams
			if isMenuOpen and x >= 10 and x <= 10 + 165 and y >= 130 and y <= 130 + 120 then
				if currentCategory == "Skins" then
					currentSwan = 1
					skin = "Classic"
				elseif currentCategory == "Locations" then
					location = "City of Dreams"
					currentBackground = 1
					currentObstacle = 1
				end
			end
			-- In a mask or Island
			if isMenuOpen and x >= 185 and x <= 185 + 165 and y >= 130 and y <= 130 + 120 then
				if currentCategory == "Skins" then
					if boughtMask then
						currentSwan = 4
						skin = "In a mask"
					else
						if forAllTimes >= 35 then
							forAllTimes = forAllTimes - 35
							boughtMask = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtMask.txt", "true")
							currentSwan = 4
							skin = "In a mask"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtIsland then
						applyIsland()
					else
						if forAllTimes >= 35 then
							forAllTimes = forAllTimes - 35
							boughtIsland = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtIsland.txt", "true")
							applyIsland()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
			-- In a hat or Coniferous forest
			if isMenuOpen and x >= 10 and x <= 10 + 165 and y >= 260 and y <= 260 + 120 then
				if currentCategory == "Skins" then
					if boughtHat then
						currentSwan = 7
						skin = "In a hat"
					else
						if forAllTimes >= 40 then
							forAllTimes = forAllTimes - 40
							boughtHat = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtHat.txt", "true")
							currentSwan = 7
							skin = "In a hat"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtConiferousForest then
						applyConiferousForest()
					else
						if forAllTimes >= 40 then
							forAllTimes = forAllTimes - 40
							boughtConiferousForest = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtConiferousForest.txt", "true")
							applyConiferousForest()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
			-- With friends or Land of snow
			if isMenuOpen and x >= 185 and x <= 185 + 165 and y >= 260 and y <= 260 + 120 then
				if currentCategory == "Skins" then
					if boughtFriends then
						currentSwan = 10
						skin = "With friends"
					else
						if forAllTimes >= 45 then
							forAllTimes = forAllTimes - 45
							boughtFriends = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtFriends.txt", "true")
							currentSwan = 10
							skin = "With friends"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtLandOfSnow then
						applyLandOfSnow()
					else
						if forAllTimes >= 45 then
							forAllTimes = forAllTimes - 45
							boughtLandOfSnow = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtLandOfSnow.txt", "true")
							applyLandOfSnow()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
			-- Fashionista or Space
			if isMenuOpen and x >= 10 and x <= 10 + 165 and y >= 390 and y <= 390 + 120 then
				if currentCategory == "Skins" then
					if boughtFashionista then
						currentSwan = 13
						skin = "Fashionista"
					else
						if forAllTimes >= 50 then
							forAllTimes = forAllTimes - 50
							boughtFashionista = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtFashionista.txt", "true")
							currentSwan = 13
							skin = "Fashionista"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtSpace then
						applySpace()
					else
						if forAllTimes >= 50 then
							forAllTimes = forAllTimes - 50
							boughtSpace = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtSpace.txt", "true")
							applySpace()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
			-- Fun or Museum
			if isMenuOpen and x >= 185 and x <= 185 + 165 and y >= 390 and y <= 390 + 120 then
				if currentCategory == "Skins" then
					if boughtFun then
						currentSwan = 16
						skin = "Fun"
					else
						if forAllTimes >= 55 then
							forAllTimes = forAllTimes - 55
							boughtFun = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtFun.txt", "true")
							currentSwan = 16
							skin = "Fun"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtMuseum then
						applyMuseum()
					else
						if forAllTimes >= 55 then
							forAllTimes = forAllTimes - 55
							boughtMuseum = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtMuseum.txt", "true")
							applyMuseum()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
			-- Bear or Kitchen
			if isMenuOpen and x >= 10 and x <= 10 + 165 and y >= 520 and y <= 520 + 120 then
				if currentCategory == "Skins" then
					if boughtBear then
						currentSwan = 19
						skin = "Bear"
					else
						if forAllTimes >= 60 then
							forAllTimes = forAllTimes - 60
							boughtBear = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtBear.txt", "true")
							currentSwan = 19
							skin = "Bear"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtKitchen then
						applyKitchen()
					else
						if forAllTimes >= 60 then
							forAllTimes = forAllTimes - 60
							boughtKitchen = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtKitchen.txt", "true")
							applyKitchen()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
			-- In a scarf or Warehouse
			if isMenuOpen and x >= 185 and x <= 185 + 165 and y >= 520 and y <= 520 + 120 then
				if currentCategory == "Skins" then
					if boughtScarf then
						currentSwan = 22
						skin = "In a scarf"
					else
						if forAllTimes >= 65 then
							forAllTimes = forAllTimes - 65
							boughtScarf = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtScarf.txt", "true")
							currentSwan = 22
							skin = "In a scarf"
						else
							notEnoughCoinsTimer = 0
						end
					end
				elseif currentCategory == "Locations" then
					if boughtWarehouse then
						applyWarehouse()
					else
						if forAllTimes >= 65 then
							forAllTimes = forAllTimes - 65
							boughtWarehouse = true
							love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
							love.filesystem.write("boughtWarehouse.txt", "true")
							applyWarehouse()
						else
							notEnoughCoinsTimer = 0
						end
					end
				end
			end
		end
	end
end

function love.mousereleased(x, y, button, istouch)
	if button == 1 and mouseStartY and not gameOver then
		local deltaY = mouseStartY - y -- Swipe length
		futureSwanY = swanY - deltaY
		mouseStartY = nil
	end
end

function love.keypressed(key, unicode)
	if key == "space" and gameOver then
		gameOver = false
		resetPositions()
	end
end
