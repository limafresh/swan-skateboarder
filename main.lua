local fn = require("functions")
local data = require("data")
local st = require("settings")

local backgrounds = {}
local lands = {}
local obstacles = {}
local swans = {}
local coin
local audio = {}
local quads = {}
local fonts = {}
local coinCollected

function love.load()
	fn.resize(love.graphics.getDimensions())

	-- Backgrounds
	for _, bg in ipairs(data.assetFileNames.backgrounds) do
		table.insert(backgrounds, love.graphics.newImage("resources/backgrounds/" .. bg .. ".png"))
	end

	-- Lands
	for _, ld in ipairs(data.assetFileNames.lands) do
		table.insert(lands, love.graphics.newImage("resources/lands/" .. ld .. ".png"))
	end
	for land = 1, #lands do
		lands[land]:setWrap("repeat", "clamp")
	end

	-- Obstacles
	for _, obst in ipairs(data.assetFileNames.obstacles) do
		table.insert(obstacles, love.graphics.newImage("resources/obstacles/" .. obst .. ".png"))
	end

	-- Swans
	for _, skin in ipairs(data.assetFileNames.skins) do
		for i = 1, 3 do
			table.insert(swans, love.graphics.newImage("resources/swans/" .. skin .. i .. ".png"))
		end
	end

	coin = love.graphics.newImage("resources/unsorted/coin.png")

	audio.coinSound = love.audio.newSource("resources/unsorted/coin.flac", "static")
	audio.backgroundMusic = love.audio.newSource("resources/unsorted/awake10_megaWall.mp3", "stream")
	audio.backgroundMusic:setLooping(true)
	audio.gameOverSound = love.audio.newSource("resources/unsorted/game_over_bad_chest.wav", "static")

	quads.location = love.graphics.newQuad(0, 189, 360, 262, 360, 640)
	quads.land = love.graphics.newQuad(0, 378, 360, 262, 360, 640)

	for _, button in ipairs(data.menuButtons) do
		button.icon = love.graphics.newImage("resources/icons/" .. button.iconFile)
	end

	fonts.large = love.graphics.newFont("resources/fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 36)
	fonts.gameOver = love.graphics.newFont("resources/fonts/Press_Start_2P/PressStart2P-Regular.ttf", 65)
	fonts.pixel = love.graphics.newFont("resources/fonts/Press_Start_2P/PressStart2P-Regular.ttf", 32)
	fonts.regular = love.graphics.newFont("resources/fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 24)
	fonts.small = love.graphics.newFont("resources/fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 18)

	fn.loadDataFromFiles()
	fn.resetPositions(audio.backgroundMusic)
end

function love.update(dt)
	local SPEED = 500
	local COIN_OBSTACLE_GAP = 20
	local MIN_SWAN_Y = -200
	local MAX_SWAN_Y = 630
	local MIN_OBSTACLE_X = -80
	local CITY_BG_INTERVAL_IN_SEC = 2
	local SWAN_COSTUME_INTERVAL_IN_SEC = 0.5
	local SWAN_UP_FORCE = 15
	local initialCoinY = data.INITIAL_OBSTACLE_Y - COIN_OBSTACLE_GAP - coin:getHeight()

	love.window.setTitle(fn.translate("Swan skateboarder"))

	-- Set the initial y of the coin
	if st.coin.y == nil then
		st.coin.y = initialCoinY
	end

	if not st.gameOver then
		-- Jump
		if st.futureSwanY and st.swan.y > st.futureSwanY then
			st.swan.y = st.swan.y - SPEED *dt
		else
			st.futureSwanY = nil
			-- The swan always falls down
			if st.swan.y <= MAX_SWAN_Y then
				st.swan.y = st.swan.y + SPEED * dt
			end
		end

		-- Swan height limit
		if st.swan.y < MIN_SWAN_Y then
			st.swan.y = MIN_SWAN_Y
		end

		-- The obstacle always moves from right to left, creating the illusion of movement across the location
		if st.obstacle.x >= MIN_OBSTACLE_X then
			st.obstacle.x = st.obstacle.x - SPEED * dt
		else
			if st.gameSettings.mode == "Easy" then
				st.obstacle.rotated = not st.obstacle.rotated
			else
				st.obstacle.rotated = ({true, false})[math.random(1, 2)]
			end
			st.obstacle.x = data.INITIAL_OBSTACLE_X
			if st.obstacle.rotated then
				st.obstacle.y = 0
				st.coin.y = data.OBSTACLE_HEIGHT + COIN_OBSTACLE_GAP
			else
				st.obstacle.y = data.INITIAL_OBSTACLE_Y
				st.coin.y = initialCoinY
			end
			coinCollected = false
		end

		-- Determine the x of the coin
		local currentObstacle = obstacles[st.gameAssets.obstacle]
		st.coin.x = st.obstacle.x + currentObstacle:getWidth() / 2 - coin:getWidth() / 2

		-- Check collision
		local swanWidth = swans[st.gameAssets.swan]:getWidth()
		local swanHeight = swans[st.gameAssets.swan]:getHeight()
		local obstacleWidth = obstacles[st.gameAssets.obstacle]:getWidth()
		local obstacleHeight = obstacles[st.gameAssets.obstacle]:getHeight()
		if fn.checkCollision(st.swan.x, st.swan.y, swanWidth, swanHeight, st.obstacle.x, st.obstacle.y, obstacleWidth, obstacleHeight) then
			love.system.vibrate(0.1)
			st.gameOver = true
			love.audio.stop(audio.backgroundMusic)
			love.audio.stop(audio.gameOverSound)
			love.audio.play(audio.gameOverSound)
			love.filesystem.write("forAllTimes.txt", tostring(st.forAllTimes)) -- Write progress
			st.gameAssets.swan = data.lastCostumes[st.gameSettings.skin] - 2
		end

		-- Collect coin
		if not coinCollected and fn.checkCollision(st.swan.x, st.swan.y, swanWidth, swanHeight, st.coin.x, st.coin.y, coin:getWidth(), coin:getHeight()) then
			coinCollected = true
			st.forThisTime = st.forThisTime + 1
			st.forAllTimes = st.forAllTimes + 1
			love.audio.stop(audio.coinSound)
			love.audio.play(audio.coinSound)
		end

		-- Update background costume
		if st.gameSettings.location == "City of Dreams" then
			st.bgTimer = st.bgTimer + dt
			if st.bgTimer >= CITY_BG_INTERVAL_IN_SEC then
				st.gameAssets.background = st.gameAssets.background + 1
				if st.gameAssets.background > 5 then
					st.gameAssets.background = 1
				end
				st.bgTimer = 0
			end
		end

		-- Update swan costume
		st.swan.timer = st.swan.timer + dt
		if st.swan.timer >= SWAN_COSTUME_INTERVAL_IN_SEC then
			st.gameAssets.swan = st.gameAssets.swan + 1
			if st.gameAssets.swan > data.lastCostumes[st.gameSettings.skin] then
				st.gameAssets.swan = data.lastCostumes[st.gameSettings.skin] - 2
			end
			st.swan.rotation = st.swan.rotation % #data.swanRotations + 1
			st.swan.timer = 0
		end

		-- Locations with moving land
		if st.gameSettings.location ~= "City of Dreams" then
			st.scroll = (st.scroll + SPEED * dt) % 360
		end

		-- Controlling a swan with a keyboard
		if love.keyboard.isDown("up") then
			st.swan.y = st.swan.y - SWAN_UP_FORCE
		end
	end
	-- Not enough coins timer
	st.notEnoughCoinsTimer = st.notEnoughCoinsTimer + dt
end

function love.draw()
	love.graphics.setScissor(
		st.window.translateX,
		st.window.translateY,
		data.GAME_WIDTH * st.window.scale,
		data.GAME_HEIGHT * st.window.scale
	)

	love.graphics.translate(st.window.translateX, st.window.translateY)
	love.graphics.scale(st.window.scale)

	if not st.gameOver then
		-- Background
		love.graphics.draw(backgrounds[st.gameAssets.background], 0, 0)

		-- Locations with moving land
		if st.gameSettings.location ~= "City of Dreams" then
			love.graphics.draw(lands[st.gameAssets.land], -st.scroll, 0)
			love.graphics.draw(lands[st.gameAssets.land], 360 - st.scroll, 0)
		end

		-- Obstacle
		local obstacle = obstacles[st.gameAssets.obstacle]
		if st.obstacle.rotated then
			love.graphics.draw(obstacle, st.obstacle.x + obstacle:getWidth()/2, st.obstacle.y + obstacle:getHeight()/2, math.rad(180), 1, 1, obstacle:getWidth()/2, obstacle:getHeight()/2)
		else
			love.graphics.draw(obstacle, st.obstacle.x, st.obstacle.y)
		end

		-- Swan
		local swan = swans[st.gameAssets.swan]
		love.graphics.draw(swan, st.swan.x + swan:getWidth()/2, st.swan.y + swan:getHeight()/2, math.rad(data.swanRotations[st.swan.rotation]), 1, 1, swan:getWidth()/2, swan:getHeight()/2)

		-- Coin
		if not coinCollected then
			love.graphics.draw(coin, st.coin.x, st.coin.y)
		end

		-- Counter
		love.graphics.setFont(fonts.large)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.print(st.forThisTime, 12, 12)
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.print(st.forThisTime, 10, 10)

	-- Game over screen
	else
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
		love.graphics.setFont(fonts.pixel)
		love.graphics.printf("GO!", 200, 500 + (80 - fonts.pixel:getHeight()) / 2, 150, "center")
		-- Swan
		local img = swans[st.gameAssets.swan]
		local LEFT_INDENT = 10
		local BOTTOM_INDENT = 15
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.draw(img, LEFT_INDENT, data.GAME_HEIGHT - img:getHeight() - BOTTOM_INDENT)
		-- Counter
		love.graphics.setFont(fonts.small)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.print(fn.translate("For this time: ") .. st.forThisTime, 10, 120)
		love.graphics.print(fn.translate("For all times: ") .. st.forAllTimes, 10, 140)
		-- Game over label
		love.graphics.setFont(fonts.gameOver)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.printf("GAME OVER", 5, 205, 365, "center")
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 0))
		love.graphics.printf("GAME OVER", 0, 200, 360, "center")
		-- Buttons
		love.graphics.setLineWidth(2)
		local shadow = 5
		for _, btn in ipairs(data.menuButtons) do
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
		if st.isMenuOpen then
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 230))
			love.graphics.rectangle("fill", 0, 120, 360, 520)
		end

		-- Settings
		if st.isMenuOpen and currentCategory == "Settings" then
			for _, params in ipairs(data.settingsButtons) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, params.width, params.height)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, params.width, params.height)
				-- Text and checkmark
				local textY
				if st.gameSettings[params.key] == params.value then
					textY = params.y + 20
					local cx = params.x + params.width / 2
					fn.drawCheckmark(cx - 25, params.y + 80, 50)
				else
					textY = params.y + (params.height - fonts.regular:getHeight()) / 2
				end
				love.graphics.setFont(fonts.regular)
				love.graphics.printf(fn.translate(params.name), params.x, textY, params.width, "center")
			end
		end

		local SHOP_BUTTON_WIDTH = 165
		local SHOP_BUTTON_HEIGHT = 120
		local SHOP_BUTTON_BOTTOM_PADDING = 5
		local SHOP_IMG_SCALE = 0.45

		-- Skins
		if st.isMenuOpen and currentCategory == "Skins" then
			local imgIndex = 1

			for _, params in ipairs(data.shopButtons.Skins) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, SHOP_BUTTON_WIDTH, SHOP_BUTTON_HEIGHT)
				-- Image
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
				local img = swans[imgIndex]
				love.graphics.draw(
					img,
					params.x + SHOP_BUTTON_WIDTH / 2 - img:getWidth() * SHOP_IMG_SCALE / 2,
					params.y + SHOP_BUTTON_HEIGHT - img:getHeight() * SHOP_IMG_SCALE - SHOP_BUTTON_BOTTOM_PADDING,
					0,
					SHOP_IMG_SCALE, SHOP_IMG_SCALE
				)
				-- Label
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, params.y + 60, SHOP_BUTTON_WIDTH, 60)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, SHOP_BUTTON_WIDTH, SHOP_BUTTON_HEIGHT)
				-- Text
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.setFont(fonts.small)

				local textY = params.y + 60

				if st.gameSettings.skin == params.name then
					fn.drawCheckmark(params.x + 60, params.y + 85, 30)
				else
					if params.bought then
						textY = textY + (60 - fonts.small:getHeight()) / 2
					else
						fn.drawPrice(params.x + 55, params.y + 85, params.price, coin)
					end
				end
				love.graphics.printf(fn.translate(params.name), params.x, textY, 165, "center")

				imgIndex = imgIndex + 3
			end
		end

		-- Locations
		if st.isMenuOpen and currentCategory == "Locations" then
			local bgIndex = 1
			local landIndex = 0
			local obstacleIndex = 1

			for _, params in ipairs(data.shopButtons.Locations) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, SHOP_BUTTON_WIDTH, SHOP_BUTTON_HEIGHT)
				-- Images
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
				love.graphics.draw(backgrounds[bgIndex], quads.location, params.x, params.y, 0, 0.458, 0.458)
				if lands[landIndex] then
					love.graphics.draw(lands[landIndex], quads.land, params.x, params.y, 0, 0.458, 0.458)
				end
				local obstacleImg = obstacles[obstacleIndex]
				love.graphics.draw(
					obstacleImg,
					params.x + SHOP_BUTTON_WIDTH / 2 - obstacleImg:getWidth() * SHOP_IMG_SCALE / 2,
					params.y + SHOP_BUTTON_HEIGHT - obstacleImg:getHeight() * SHOP_IMG_SCALE - SHOP_BUTTON_BOTTOM_PADDING,
					0,
					SHOP_IMG_SCALE, SHOP_IMG_SCALE
				)
				-- Label
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, params.y + 60, SHOP_BUTTON_WIDTH, 60)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, SHOP_BUTTON_WIDTH, SHOP_BUTTON_HEIGHT)
				-- Text
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.setFont(fonts.small)

				local textY = params.y + 60

				if st.gameSettings.location == params.name then
					fn.drawCheckmark(params.x + 60, params.y + 85, 30)
				else
					if params.bought then
						textY = textY + (60 - fonts.small:getHeight()) / 2
					else
						fn.drawPrice(params.x + 55, params.y + 85, params.price, coin)
					end
				end
				love.graphics.printf(fn.translate(params.name), params.x, textY, 165, "center")

				if params.name == "City of Dreams" then
					bgIndex = bgIndex + 5
				else
					bgIndex = bgIndex + 1
				end
				landIndex = landIndex + 1
				obstacleIndex = obstacleIndex + 1
			end
		end

		-- Not enough coins
		if st.notEnoughCoinsTimer < 1 then
			love.graphics.setFont(fonts.regular)
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
			love.graphics.rectangle("fill", 20, 220, 320, 200)
			love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
			love.graphics.printf(fn.translate("Not enough coins"), 20, 220 + (200 - fonts.regular:getHeight()) / 2, 320, "center")
		end
	end

	love.graphics.setScissor()
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		local mx = (x - st.window.translateX) / st.window.scale
		local my = (y - st.window.translateY) / st.window.scale

		if not st.gameOver then
			st.mouseStartY = my
		else
			-- Touch restart button
			if not st.isMenuOpen and mx >= 200 and mx <= 200 + 150 and my >= 500 and my <= 500 + 80 then
				love.system.vibrate(0.1)
				fn.resetPositions(audio.backgroundMusic)
			end
			-- Menu buttons
			for _, btn in ipairs(data.menuButtons) do
				if mx >= btn.x and mx <= btn.x + 100 and my >= 15 and my <= 15 + 90 then
					love.system.vibrate(0.1)
					if btn.category == currentCategory then
						st.isMenuOpen = false
						currentCategory = nil
					else
						st.isMenuOpen = true
						currentCategory = btn.category
					end
				end
			end
			-- Touch easy mode
			if st.isMenuOpen and currentCategory == "Settings" and mx >= 10 and mx <= 10 + 340 and my >= 130 and my <= 130 + 160 then
				love.system.vibrate(0.1)
				st.gameSettings.mode = "Easy"
			end
			-- Touch hard mode
			if st.isMenuOpen and currentCategory == "Settings" and mx >= 10 and mx <= 10 + 340 and my >= 300 and my <= 300 + 160 then
				love.system.vibrate(0.1)
				st.gameSettings.mode = "Hard"
			end
			-- Eng
			if st.isMenuOpen and currentCategory == "Settings" and mx >= 10 and mx <= 10 + 165 and my >= 470 and my <= 470 + 160 then
				love.system.vibrate(0.1)
				fn.changeLanguage("en")
			end
			-- Ukr
			if st.isMenuOpen and currentCategory == "Settings" and mx >= 185 and mx <= 185 + 165 and my >= 470 and my <= 470 + 160 then
				love.system.vibrate(0.1)
				fn.changeLanguage("uk")
			end
			-- Classic or City of Dreams
			if st.isMenuOpen and mx >= 10 and mx <= 10 + 165 and my >= 130 and my <= 130 + 120 then
				love.system.vibrate(0.1)
				if currentCategory == "Skins" then
					fn.applySkin(1, "Classic")
				elseif currentCategory == "Locations" then
					st.gameSettings.location = "City of Dreams"
					st.gameAssets.background = 1
					st.gameAssets.obstacle = 1
				end
			end
			-- Other shop items
			local target = (currentCategory == "Skins") and data.shopButtons.Skins or data.shopButtons.Locations
			if data.shopButtons[currentCategory] then
				for index, item in ipairs(data.shopButtons[currentCategory]) do
					if index >= 2 then
						local t = target[index]
						if st.isMenuOpen and mx >= t.x and mx <= t.x + 165 and my >= t.y and my <= t.y + 120 then
							love.system.vibrate(0.1)
							local func = (currentCategory == "Skins") and fn.applySkin or fn.applyLocation
							fn.tryBuyOrSelect(target, index, func, item.funcArgs)
						end
					end
				end
			end
		end
	end
end

function love.mousereleased(x, y, button, istouch)
	if button == 1 then
		local my = (y - st.window.translateY) / st.window.scale

		if st.mouseStartY and not st.gameOver then
			local deltaY = st.mouseStartY - my -- Swipe length
			st.futureSwanY = st.swan.y - deltaY
			st.mouseStartY = nil
		end
	end
end

function love.keypressed(key, unicode)
	if key == "space" and st.gameOver then
		st.gameOver = false
		fn.resetPositions(audio.backgroundMusic)
	end
end

function love.resize(w, h)
	fn.resize(w, h)
end