local fn = require("functions")

function love.load()
	love.graphics.setScissor(0, 0, 360, 640)

	-- Backgrounds
	backgrounds = {}
	local bgs = {
		"cityofdreams1", "cityofdreams2", "cityofdreams3", "cityofdreams4",
		"cityofdreams5", "fading_sky", "cloudy_sky", "wispy_sky", "space",
		"museum", "kitchen", "warehouse"
	}
	for _, bg in ipairs(bgs) do
		table.insert(backgrounds, love.graphics.newImage("backgrounds/" .. bg .. ".png"))
	end

	-- Lands
	lands = {}
	local landsList = {
		"island", "coniferous_forest", "land_of_snow", "space",
		"museum", "kitchen", "warehouse"
	}
	for _, ld in ipairs(landsList) do
		table.insert(lands, love.graphics.newImage("lands/" .. ld .. ".png"))
	end
	for land = 1, #lands do
		lands[land]:setWrap("repeat", "clamp")
	end

	-- Obstacles
	obstacles = {}
	local obstaclesList = {
		"skyscraper", "palm", "christmas_tree", "snowman",
		"rocket", "statue", "fridge", "obstacle"
	}
	for _, obst in ipairs(obstaclesList) do
		table.insert(obstacles, love.graphics.newImage("obstacles/" .. obst .. ".png"))
	end

	-- Swans
	swans = {}
	local skinsList = {
		"classic", "mask", "hat", "friends", "fashionista",
		"fun", "bear", "scarf"
	}
	for _, skin in ipairs(skinsList) do
		for i = 1, 3 do
			table.insert(swans, love.graphics.newImage("swans/" .. skin .. i .. ".png"))
		end
	end

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

	menuButtons = {
		{r = 0, g = 255, b = 0, x = 15, icon = settingsIcon, category = "Settings"},
		{r = 0, g = 230, b = 230, x = 130, icon = skinsIcon, category = "Skins"},
		{r = 255, g = 0, b = 127, x = 245, icon = locationsIcon, category = "Locations"}
	}

	skins = {
		{
			name = "Classic",
			x = 10, y = 130,
			img_offset_y = 20,
			price = 0,
			bought = true,
		},
		{
			name = "In a mask",
			x = 185, y = 130,
			img_offset_y = 20,
			price = 35,
			bought = false,
			file = "boughtMask.txt"
		},
		{
			name = "In a hat",
			x = 10, y = 260,
			img_offset_y = 13,
			price = 40,
			bought = false,
			file = "boughtHat.txt"
		},
		{
			name = "With friends",
			x = 185, y = 260,
			img_offset_y = 20,
			price = 45,
			bought = false,
			file = "boughtFriends.txt"
		},
		{
			name = "Fashionista",
			x = 10, y = 390,
			img_offset_y = 13,
			price = 50,
			bought = false,
			file = "boughtFashionista.txt"
		},
		{
			name = "Fun",
			x = 185, y = 390,
			img_offset_y = 10,
			price = 55,
			bought = false,
			file = "boughtFun.txt"
		},
		{
			name = "Bear",
			x = 10, y = 520,
			img_offset_y = 9,
			price = 60,
			bought = false,
			file = "boughtBear.txt"
		},
		{
			name = "In a scarf",
			x = 185, y = 520,
			img_offset_y = 20,
			price = 65,
			bought = false,
			file = "boughtScarf.txt"
		}
	}

	locations = {
		{
			name = "City of Dreams",
			x = 10, y = 130,
			obstacle_offset_x = 65,
			price = 0,
			bought = true,
		},
		{
			name = "Island",
			x = 185, y = 130,
			obstacle_offset_x = 55,
			price = 35,
			bought = false,
			file = "boughtIsland.txt"
		},
		{
			name = "Coniferous forest",
			x = 10, y = 260,
			obstacle_offset_x = 55,
			price = 40,
			bought = false,
			file = "boughtConiferousForest.txt"
		},
		{
			name = "Land of snow",
			x = 185, y = 260,
			obstacle_offset_x = 55,
			price = 45,
			bought = false,
			file = "boughtLandOfSnow.txt"
		},
		{
			name = "Space",
			x = 10, y = 390,
			obstacle_offset_x = 65,
			price = 50,
			bought = false,
			file = "boughtSpace.txt"
		},
		{
			name = "Museum",
			x = 185, y = 390,
			obstacle_offset_x = 55,
			price = 55,
			bought = false,
			file = "boughtMuseum.txt"
		},
		{
			name = "Kitchen",
			x = 10, y = 520,
			obstacle_offset_x = 65,
			price = 60,
			bought = false,
			file = "boughtKitchen.txt"
		},
		{
			name = "Warehouse",
			x = 185, y = 520,
			obstacle_offset_x = 55,
			price = 65,
			bought = false,
			file = "boughtWarehouse.txt"
		}
	}

	shopConfig = {
		Skins = {
			{index = 2, func = function() fn.applySkin(4, "In a mask") end},
			{index = 3, func = function() fn.applySkin(7, "In a hat") end},
			{index = 4, func = function() fn.applySkin(10, "With friends") end},
			{index = 5, func = function() fn.applySkin(13, "Fashionista") end},
			{index = 6, func = function() fn.applySkin(16, "Fun") end},
			{index = 7, func = function() fn.applySkin(19, "Bear") end},
			{index = 8, func = function() fn.applySkin(22, "In a scarf") end},
		},
		Locations = {
			{index = 2, func = function() fn.applyLocation("Island", 6, 1, 2) end},
			{index = 3, func = function() fn.applyLocation("Coniferous forest", 7, 2, 3) end},
			{index = 4, func = function() fn.applyLocation("Land of snow", 8, 3, 4) end},
			{index = 5, func = function() fn.applyLocation("Space", 9, 4, 5) end},
			{index = 6, func = function() fn.applyLocation("Museum", 10, 5, 6) end},
			{index = 7, func = function() fn.applyLocation("Kitchen", 11, 6, 7) end},
			{index = 8, func = function() fn.applyLocation("Warehouse", 12, 7, 8) end},
		}
	}

	-- Load progress
	if love.filesystem.getInfo("forAllTimes.txt") then
		local contents = love.filesystem.read("forAllTimes.txt")
		forAllTimes = tonumber(contents)
	end

	if love.filesystem.getInfo("language.txt") then language = love.filesystem.read("language.txt") end

	fn.markBought(skins)
	fn.markBought(locations)

	fontLarge = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 36)
	fontGameOver = love.graphics.newFont("fonts/Press_Start_2P/PressStart2P-Regular.ttf", 65)
	fontPixel = love.graphics.newFont("fonts/Press_Start_2P/PressStart2P-Regular.ttf", 32)
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

	fn.resetPositions()
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
		if fn.checkCollision(swanX, swanY, swanWidth, swanHeight, obstacleX, obstacleY, obstacleWidth, obstacleHeight) then
			gameOver = true
			love.audio.stop(backgroundMusic)
			love.audio.stop(gameOverSound)
			love.audio.play(gameOverSound)
			love.filesystem.write("forAllTimes.txt", tostring(forAllTimes)) -- Write progress
			currentSwan = lastCostumes[skin] - 2
		end

		-- Collect coin
		if not coinCollected and fn.checkCollision(swanX, swanY, swanWidth, swanHeight, obstacleX, coinY, coinWidth, coinHeight) then
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
		love.graphics.setColor(love.math.colorFromBytes(0, 255, 0)) --Fill
		love.graphics.rectangle("fill", 200, 500, 150, 80, 30)
		love.graphics.setLineWidth(5) -- Contour
		love.graphics.setColor(love.math.colorFromBytes(34, 177, 76))
		love.graphics.rectangle("line", 200, 500, 150, 80, 30)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0)) -- Label
		love.graphics.setFont(fontPixel)
		love.graphics.printf("GO!", 200, 500 + (80 - fontPixel:getHeight()) / 2, 150, "center")
		-- Swan
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.draw(swans[currentSwan], 10, 400)
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
		-- Buttons
		love.graphics.setLineWidth(2)
		local shadow = 5
		for _, btn in ipairs(menuButtons) do
			local r, g, b = btn.r, btn.g, btn.b
			if currentCategory == btn.category then
				r, g, b = r * 0.7, g * 0.7, b * 0.7
			end
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.rectangle("fill", btn.x + shadow, 15 + shadow, 100, 90, 20)
			love.graphics.setColor(love.math.colorFromBytes(r, g, b))
			love.graphics.rectangle("fill", btn.x, 15, 100, 90, 20)
			love.graphics.draw(btn.icon, btn.x, 15)
		end

		-- Menu
		if isMenuOpen then
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 230))
			love.graphics.rectangle("fill", 0, 120, 360, 520)
		end

		-- Settings
		if isMenuOpen and currentCategory == "Settings" then
			local settingsButtons = {
				{name = "Easy mode", x = 10, y = 130, width = 340, height = 160, var = mode, value = "Easy"},
				{name = "Hard mode", x = 10, y = 300, width = 340, height = 160, var = mode, value = "Hard"},
				{name = "English", x = 10, y = 470, width = 165, height = 160, var = language, value = "en"},
				{name = "Українська", x = 185, y = 470, width = 165, height = 160, var = language, value = "uk"}
			}

			for _, params in ipairs(settingsButtons) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, params.width, params.height)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, params.width, params.height)
				-- Text and checkmark
				local textY
				local text
				if params.var == params.value then
					textY = params.y + 20
					local cx = params.x + params.width / 2
					fn.drawCheckmark(cx - 25, params.y + 80, 50)
				else
					textY = params.y + (params.height - fontRegular:getHeight()) / 2
				end
				if lang[params.name] then text = lang[params.name] else text = params.name end
				love.graphics.setFont(fontRegular)
				love.graphics.printf(text, params.x, textY, params.width, "center")
			end
		end

		local rect_width = 165
		local rect_height = 120

		-- Skins
		if isMenuOpen and currentCategory == "Skins" then
			local img_index = 1

			for _, params in ipairs(skins) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, rect_width, rect_height)
				-- Image
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
				love.graphics.draw(swans[img_index], params.x + 50, params.y + params.img_offset_y, 0, 0.45, 0.45)
				-- Label
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, params.y + 60, rect_width, 60)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, rect_width, rect_height)
				-- Text
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.setFont(fontSmall)

				local textY = params.y + 60

				if skin == params.name then
					fn.drawCheckmark(params.x + 60, params.y + 85, 30)
				else
					if params.bought then
						textY = textY + (60 - fontSmall:getHeight()) / 2
					else
						fn.drawPrice(params.x + 55, params.y + 85, params.price)
					end
				end
				love.graphics.printf(lang[params.name], params.x, textY, 165, "center")

				img_index = img_index + 3
			end
		end

		-- Locations
		if isMenuOpen and currentCategory == "Locations" then
			local bg_index = 1
			local land_index = 0
			local obstacle_index = 1

			for _, params in ipairs(locations) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, rect_width, rect_height)
				-- Images
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
				love.graphics.draw(backgrounds[bg_index], locationQuad, params.x, params.y, 0, 0.458, 0.458)
				if lands[land_index] then
					love.graphics.draw(lands[land_index], landQuad, params.x, params.y, 0, 0.458, 0.458)
				end
				love.graphics.draw(obstacles[obstacle_index], params.x + params.obstacle_offset_x, params.y + 5, 0, 0.45, 0.45)
				-- Label
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, params.y + 60, rect_width, 60)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, rect_width, rect_height)
				-- Text
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.setFont(fontSmall)

				local textY = params.y + 60

				if location == params.name then
					fn.drawCheckmark(params.x + 60, params.y + 85, 30)
				else
					if params.bought then
						textY = textY + (60 - fontSmall:getHeight()) / 2
					else
						fn.drawPrice(params.x + 55, params.y + 85, params.price)
					end
				end
				love.graphics.printf(lang[params.name], params.x, textY, 165, "center")

				if params.name == "City of Dreams" then
					bg_index = bg_index + 5
				else
					bg_index = bg_index + 1
				end
				land_index = land_index + 1
				obstacle_index = obstacle_index + 1
			end
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
			if not isMenuOpen and x >= 200 and x <= 200 + 150 and y >= 500 and y <= 500 + 80 then
				gameOver = false
				fn.resetPositions()
			end
			-- Menu buttons
			for _, btn in ipairs(menuButtons) do
				if x >= btn.x and x <= btn.x + 100 and y >= 15 and y <= 15 + 90 then
					isMenuOpen = not isMenuOpen
					if isMenuOpen then
						currentCategory = btn.category
					else
						currentCategory = nil
					end
				end
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
				fn.changeLanguage("en")
			end
			-- Ukr
			if isMenuOpen and currentCategory == "Settings" and x >= 185 and x <= 185 + 165 and y >= 470 and y <= 470 + 160 then
				fn.changeLanguage("uk")
			end
			-- Classic or City of Dreams
			if isMenuOpen and x >= 10 and x <= 10 + 165 and y >= 130 and y <= 130 + 120 then
				if currentCategory == "Skins" then
					fn.applySkin(1, "Classic")
				elseif currentCategory == "Locations" then
					location = "City of Dreams"
					currentBackground = 1
					currentObstacle = 1
				end
			end
			-- Other shop items
			local target = (currentCategory == "Skins") and skins or locations
			if shopConfig[currentCategory] then
				for _, item in ipairs(shopConfig[currentCategory]) do
					local t = target[item.index]
					if isMenuOpen and x >= t.x and x <= t.x + 165 and y >= t.y and y <= t.y + 120 then
						fn.tryBuyOrSelect(target, item.index, item.func)
					end
				end
			end
		end
	end
end

function love.mousereleased(x, y, button, istouch)
	if button == 1 then
		if mouseStartY and not gameOver then
			local deltaY = mouseStartY - y -- Swipe length
			futureSwanY = swanY - deltaY
			mouseStartY = nil
		end
	end
end

function love.keypressed(key, unicode)
	if key == "space" and gameOver then
		gameOver = false
		fn.resetPositions()
	end
end