local fn = require("functions")
local data = require("data")

function love.load()
	window = {translateX = 0, translateY = 0, scale = 0, width = 360, height = 640}
	fn.resize(love.graphics.getDimensions())

	-- Backgrounds
	backgrounds = {}
	for _, bg in ipairs(data.assetFileNames.backgrounds) do
		table.insert(backgrounds, love.graphics.newImage("backgrounds/" .. bg .. ".png"))
	end

	-- Lands
	lands = {}
	for _, ld in ipairs(data.assetFileNames.lands) do
		table.insert(lands, love.graphics.newImage("lands/" .. ld .. ".png"))
	end
	for land = 1, #lands do
		lands[land]:setWrap("repeat", "clamp")
	end

	-- Obstacles
	obstacles = {}
	for _, obst in ipairs(data.assetFileNames.obstacles) do
		table.insert(obstacles, love.graphics.newImage("obstacles/" .. obst .. ".png"))
	end

	-- Swans
	swans = {}
	for _, skin in ipairs(data.assetFileNames.skins) do
		for i = 1, 3 do
			table.insert(swans, love.graphics.newImage("swans/" .. skin .. i .. ".png"))
		end
	end

	coin = love.graphics.newImage("assets/coin.png")

	coinSound = love.audio.newSource("assets/coin.flac", "static")
	backgroundMusic = love.audio.newSource("assets/awake10_megaWall.mp3", "stream")
	backgroundMusic:setLooping(true)
	gameOverSound = love.audio.newSource("assets/game_over_bad_chest.wav", "static")

	locationQuad = love.graphics.newQuad(0, 189, 360, 262, 360, 640)
	landQuad = love.graphics.newQuad(0, 378, 360, 262, 360, 640)

	speed = 500
	forAllTimes = 0

	gameAssets = {
		background = 1,
		land = 1,
		obstacle = 1,
		swan = 1
	}

	gameSettings = {
		mode = "Easy",
		language = "en",
		skin = "Classic",
		location = "City of Dreams"
	}

	for _, button in ipairs(data.menuButtons) do
		button.icon = love.graphics.newImage(button.iconPath)
	end

	fonts = {
		large = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 36),
		gameOver = love.graphics.newFont("fonts/Press_Start_2P/PressStart2P-Regular.ttf", 65),
		pixel = love.graphics.newFont("fonts/Press_Start_2P/PressStart2P-Regular.ttf", 32),
		regular = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 24),
		small = love.graphics.newFont("fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 18)
	}

	fn.loadDataFromFiles()
	fn.resetPositions()
end

function love.update(dt)
	love.window.setTitle(fn.translate("Swan skateboarder"))
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
			if gameSettings.mode == "Easy" then
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
		local swanWidth = swans[gameAssets.swan]:getWidth()
		local swanHeight = swans[gameAssets.swan]:getHeight()
		local obstacleWidth = obstacles[gameAssets.obstacle]:getWidth()
		local obstacleHeight = obstacles[gameAssets.obstacle]:getHeight()
		if fn.checkCollision(swanX, swanY, swanWidth, swanHeight, obstacleX, obstacleY, obstacleWidth, obstacleHeight) then
			love.system.vibrate(0.1)
			gameOver = true
			love.audio.stop(backgroundMusic)
			love.audio.stop(gameOverSound)
			love.audio.play(gameOverSound)
			love.filesystem.write("forAllTimes.txt", tostring(forAllTimes)) -- Write progress
			gameAssets.swan = data.lastCostumes[gameSettings.skin] - 2
		end

		-- Collect coin
		if not coinCollected and fn.checkCollision(swanX, swanY, swanWidth, swanHeight, obstacleX, coinY, coin:getWidth(), coin:getHeight()) then
			coinCollected = true
			forThisTime = forThisTime + 1
			forAllTimes = forAllTimes + 1
			love.audio.stop(coinSound)
			love.audio.play(coinSound)
		end

		-- Update background costume
		if gameSettings.location == "City of Dreams" then
			bgTimer = bgTimer + dt
			if bgTimer >= 2 then
				gameAssets.background = gameAssets.background + 1
				if gameAssets.background > 5 then
					gameAssets.background = 1
				end
				bgTimer = bgTimer - 2
			end
		end

		-- Update swan costume
		swanTimer = swanTimer + dt
		if swanTimer >= 0.5 then
			gameAssets.swan = gameAssets.swan + 1
			if gameAssets.swan > data.lastCostumes[gameSettings.skin] then
				gameAssets.swan = data.lastCostumes[gameSettings.skin] - 2
			end
			currentSwanRotation = currentSwanRotation % #data.swanRotations + 1
			swanTimer = swanTimer - 0.5
		end

		-- Locations with moving land
		if gameSettings.location ~= "City of Dreams" then
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
	love.graphics.setScissor(window.translateX, window.translateY, window.width * window.scale, window.height * window.scale)

	love.graphics.translate(window.translateX, window.translateY)
	love.graphics.scale(window.scale)

	if not gameOver then
		-- Background
		love.graphics.draw(backgrounds[gameAssets.background], 0, 0)

		-- Locations with moving land
		if gameSettings.location ~= "City of Dreams" then
			love.graphics.draw(lands[gameAssets.land], -scroll, 0)
			love.graphics.draw(lands[gameAssets.land], 360 - scroll, 0)
		end

		-- Obstacle
		local obstacle = obstacles[gameAssets.obstacle]
		if obstacleRotated then
			love.graphics.draw(obstacle, obstacleX + obstacle:getWidth()/2, obstacleY + obstacle:getHeight()/2, math.rad(180), 1, 1, obstacle:getWidth()/2, obstacle:getHeight()/2)
		else
			love.graphics.draw(obstacle, obstacleX, obstacleY)
		end

		-- Swan
		local swan = swans[gameAssets.swan]
		love.graphics.draw(swan, swanX + swan:getWidth()/2, swanY + swan:getHeight()/2, math.rad(data.swanRotations[currentSwanRotation]), 1, 1, swan:getWidth()/2, swan:getHeight()/2)

		-- Coin
		if not coinCollected then
			love.graphics.draw(coin, obstacleX, coinY)
		end

		-- Counter
		love.graphics.setFont(fonts.large)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.print(forThisTime, 12, 12)
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.print(forThisTime, 10, 10)

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
		local img = swans[gameAssets.swan]
		local leftIndent = 10
		local bottomIndent = 15
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
		love.graphics.draw(img, leftIndent, window.height - img:getHeight() - bottomIndent)
		-- Counter
		love.graphics.setFont(fonts.small)
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
		love.graphics.print(fn.translate("For this time: ") .. forThisTime, 10, 120)
		love.graphics.print(fn.translate("For all times: ") .. forAllTimes, 10, 140)
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
		if isMenuOpen then
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 230))
			love.graphics.rectangle("fill", 0, 120, 360, 520)
		end

		-- Settings
		if isMenuOpen and currentCategory == "Settings" then
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
				if gameSettings[params.key] == params.value then
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

		local rectWidth = 165
		local rectHeight = 120
		local bottomPadding = 5
		local imgScale = 0.45

		-- Skins
		if isMenuOpen and currentCategory == "Skins" then
			local imgIndex = 1

			for _, params in ipairs(data.shopButtons.Skins) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, rectWidth, rectHeight)
				-- Image
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
				local img = swans[imgIndex]
				love.graphics.draw(
					img,
					params.x + rectWidth / 2 - img:getWidth() * imgScale / 2,
					params.y + rectHeight - img:getHeight() * imgScale - bottomPadding,
					0,
					imgScale, imgScale
				)
				-- Label
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, params.y + 60, rectWidth, 60)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, rectWidth, rectHeight)
				-- Text
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.setFont(fonts.small)

				local textY = params.y + 60

				if gameSettings.skin == params.name then
					fn.drawCheckmark(params.x + 60, params.y + 85, 30)
				else
					if params.bought then
						textY = textY + (60 - fonts.small:getHeight()) / 2
					else
						fn.drawPrice(params.x + 55, params.y + 85, params.price)
					end
				end
				love.graphics.printf(fn.translate(params.name), params.x, textY, 165, "center")

				imgIndex = imgIndex + 3
			end
		end

		-- Locations
		if isMenuOpen and currentCategory == "Locations" then
			local bgIndex = 1
			local landIndex = 0
			local obstacleIndex = 1

			for _, params in ipairs(data.shopButtons.Locations) do
				-- Fill
				love.graphics.setColor(love.math.colorFromBytes(0, 230, 230))
				love.graphics.rectangle("fill", params.x, params.y, rectWidth, rectHeight)
				-- Images
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
				love.graphics.draw(backgrounds[bgIndex], locationQuad, params.x, params.y, 0, 0.458, 0.458)
				if lands[landIndex] then
					love.graphics.draw(lands[landIndex], landQuad, params.x, params.y, 0, 0.458, 0.458)
				end
				local obstacleImg = obstacles[obstacleIndex]
				love.graphics.draw(
					obstacleImg,
					params.x + rectWidth / 2 - obstacleImg:getWidth() * imgScale / 2,
					params.y + rectHeight - obstacleImg:getHeight() * imgScale - bottomPadding,
					0,
					imgScale, imgScale
				)
				-- Label
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, params.y + 60, rectWidth, 60)
				-- Contour
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.rectangle("line", params.x, params.y, rectWidth, rectHeight)
				-- Text
				love.graphics.setLineWidth(2)
				love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
				love.graphics.setFont(fonts.small)

				local textY = params.y + 60

				if gameSettings.location == params.name then
					fn.drawCheckmark(params.x + 60, params.y + 85, 30)
				else
					if params.bought then
						textY = textY + (60 - fonts.small:getHeight()) / 2
					else
						fn.drawPrice(params.x + 55, params.y + 85, params.price)
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
		if notEnoughCoinsTimer < 1 then
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
		local mx = (x - window.translateX) / window.scale
		local my = (y - window.translateY) / window.scale

		if not gameOver then
			mouseStartY = my
		else
			-- Touch restart button
			if not isMenuOpen and mx >= 200 and mx <= 200 + 150 and my >= 500 and my <= 500 + 80 then
				love.system.vibrate(0.1)
				fn.resetPositions()
			end
			-- Menu buttons
			for _, btn in ipairs(data.menuButtons) do
				if mx >= btn.x and mx <= btn.x + 100 and my >= 15 and my <= 15 + 90 then
					love.system.vibrate(0.1)
					if btn.category == currentCategory then
						isMenuOpen = false
						currentCategory = nil
					else
						isMenuOpen = true
						currentCategory = btn.category
					end
				end
			end
			-- Touch easy mode
			if isMenuOpen and currentCategory == "Settings" and mx >= 10 and mx <= 10 + 340 and my >= 130 and my <= 130 + 160 then
				love.system.vibrate(0.1)
				gameSettings.mode = "Easy"
			end
			-- Touch hard mode
			if isMenuOpen and currentCategory == "Settings" and mx >= 10 and mx <= 10 + 340 and my >= 300 and my <= 300 + 160 then
				love.system.vibrate(0.1)
				gameSettings.mode = "Hard"
			end
			-- Eng
			if isMenuOpen and currentCategory == "Settings" and mx >= 10 and mx <= 10 + 165 and my >= 470 and my <= 470 + 160 then
				love.system.vibrate(0.1)
				fn.changeLanguage("en")
			end
			-- Ukr
			if isMenuOpen and currentCategory == "Settings" and mx >= 185 and mx <= 185 + 165 and my >= 470 and my <= 470 + 160 then
				love.system.vibrate(0.1)
				fn.changeLanguage("uk")
			end
			-- Classic or City of Dreams
			if isMenuOpen and mx >= 10 and mx <= 10 + 165 and my >= 130 and my <= 130 + 120 then
				love.system.vibrate(0.1)
				if currentCategory == "Skins" then
					fn.applySkin(1, "Classic")
				elseif currentCategory == "Locations" then
					gameSettings.location = "City of Dreams"
					gameAssets.background = 1
					gameAssets.obstacle = 1
				end
			end
			-- Other shop items
			local target = (currentCategory == "Skins") and data.shopButtons.Skins or data.shopButtons.Locations
			if data.shopButtons[currentCategory] then
				for index, item in ipairs(data.shopButtons[currentCategory]) do
					if index >= 2 then
						local t = target[index]
						if isMenuOpen and mx >= t.x and mx <= t.x + 165 and my >= t.y and my <= t.y + 120 then
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
		local my = (y - window.translateY) / window.scale

		if mouseStartY and not gameOver then
			local deltaY = mouseStartY - my -- Swipe length
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

function love.resize(w, h)
	fn.resize(w, h)
end