local fn = require("functions")
local data = require("data")
local st = require("settings")

local SPEED = 500
local MIN_SWAN_Y = -200
local MAX_SWAN_Y = 630
local CITY_BG_INTERVAL_IN_SEC = 2
local SWAN_COSTUME_INTERVAL_IN_SEC = 0.5
local SWAN_UP_FORCE = 0.03
local GAME_OVER_SHADOW = 5
local SETTINGS_CHECKMARK_SIZE = 50
local NOT_ENOUGH_COINS_WIDTH = 320
local NOT_ENOUGH_COINS_HEIGHT = 200

local backgrounds = {}
local lands = {}
local obstacles = {}
local swans = {}
local coin
local audio = {}
local quads = {}
local fonts = {}
local drawHitboxes = false
local hb = data.hitboxes

function love.load(arg)
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

	quads.location = love.graphics.newQuad(0, 189, data.GAME_WIDTH, 262, data.GAME_WIDTH, data.GAME_HEIGHT)
	quads.land = love.graphics.newQuad(0, 378, data.GAME_WIDTH, 262, data.GAME_WIDTH, data.GAME_HEIGHT)

	for _, button in ipairs(data.menuButtons) do
		button.icon = love.graphics.newImage("resources/icons/" .. button.iconFile)
	end

	fonts.large = love.graphics.newFont("resources/fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 36)
	fonts.gameOver = love.graphics.newFont("resources/fonts/Press_Start_2P/PressStart2P-Regular.ttf", 65)
	fonts.pixel = love.graphics.newFont("resources/fonts/Press_Start_2P/PressStart2P-Regular.ttf", 32)
	fonts.regular = love.graphics.newFont("resources/fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 24)
	fonts.small = love.graphics.newFont("resources/fonts/Playpen_Sans/PlaypenSans-Regular.ttf", 18)

	if arg and arg[1] == "--drawHitboxes" then
		drawHitboxes = true
	end

	fn.loadDataFromFiles()
	love.window.setTitle(fn.translate("Swan skateboarder"))
	fn.resetPositions(audio.backgroundMusic)
end

function love.update(dt)
	if not st.gameOver then
		-- Jump
		if st.swan.nextY and st.swan.y > st.swan.nextY then
			st.swan.y = st.swan.y - SPEED *dt
		else
			st.swan.nextY = nil
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
		if st.obstacle.x >= -hb.obstacle.width then
			st.obstacle.x = st.obstacle.x - SPEED * dt
		else
			if st.gameSettings.mode == "Easy" then
				st.obstacle.rotated = not st.obstacle.rotated
			else
				st.obstacle.rotated = ({true, false})[math.random(1, 2)]
			end
			st.obstacle.x = data.GAME_WIDTH
			if st.obstacle.rotated then
				st.obstacle.y = 0
				st.coin.y = hb.obstacle.height + data.COIN_OBSTACLE_GAP
			else
				st.obstacle.y = data.initialObstacleY
				st.coin.y = data.initialCoinY
			end
			st.coin.collected = false
		end

		-- Determine the x of the coin
		st.coin.x = st.obstacle.x + hb.obstacle.width / 2 - hb.coin.width / 2

		-- Check collision
		if fn.checkCollision(st.swan.x, st.swan.y, hb.swan.width, hb.swan.height, st.obstacle.x, st.obstacle.y, hb.obstacle.width, hb.obstacle.height) then
			love.system.vibrate(0.1)
			st.gameOver = true
			love.audio.stop(audio.backgroundMusic)
			love.audio.stop(audio.gameOverSound)
			love.audio.play(audio.gameOverSound)
			love.filesystem.write("balance.txt", tostring(st.balance)) -- Write progress
			st.costumes.swan = data.lastCostumes[st.gameSettings.skin] - 2
		end

		-- Collect coin
		if not st.coin.collected and fn.checkCollision(st.swan.x, st.swan.y, hb.swan.width, hb.swan.height, st.coin.x, st.coin.y, hb.coin.width, hb.coin.height) then
			st.coin.collected = true
			st.forThisTime = st.forThisTime + 1
			st.balance = st.balance + 1
			love.audio.stop(audio.coinSound)
			love.audio.play(audio.coinSound)
		end

		-- Update background costume
		if st.gameSettings.location == "City" then
			st.bgTimer = st.bgTimer + dt
			if st.bgTimer >= CITY_BG_INTERVAL_IN_SEC then
				st.costumes.background = st.costumes.background % 5 + 1
				st.bgTimer = 0
			end
		end

		-- Update swan costume
		st.swan.timer = st.swan.timer + dt
		if st.swan.timer >= SWAN_COSTUME_INTERVAL_IN_SEC then
			st.costumes.swan = st.costumes.swan + 1
			if st.costumes.swan > data.lastCostumes[st.gameSettings.skin] then
				st.costumes.swan = data.lastCostumes[st.gameSettings.skin] - 2
			end
			st.swan.rotation = st.swan.rotation % #data.swanRotations + 1
			st.swan.timer = 0
		end

		-- Locations with moving land
		if st.gameSettings.location ~= "City" then
			st.scroll = (st.scroll + SPEED * dt) % data.GAME_WIDTH
		end

		-- Controlling a swan with a keyboard
		if love.keyboard.isDown("up") then
			st.swan.y = st.swan.y - SWAN_UP_FORCE * SPEED
		end
	end
	-- Not enough coins timer
	if st.notEnoughCoinsTimer < data.NOT_ENOUGH_COINS_TIMER_SEC then
		st.notEnoughCoinsTimer = st.notEnoughCoinsTimer + dt
	end
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
		love.graphics.draw(backgrounds[st.costumes.background], 0, 0)

		-- Locations with moving land
		if st.gameSettings.location ~= "City" then
			love.graphics.draw(lands[st.costumes.land], -st.scroll, 0)
			love.graphics.draw(lands[st.costumes.land], data.GAME_WIDTH - st.scroll, 0)
		end

		-- Obstacle
		local obstacle = obstacles[st.costumes.obstacle]
		local radius
		if st.obstacle.rotated then
			radius = 180
		else
			radius = 0
		end
		love.graphics.draw(
			obstacle,
			st.obstacle.x + hb.obstacle.width / 2,
			st.obstacle.y + hb.obstacle.height / 2,
			math.rad(radius),
			1,
			1,
			obstacle:getWidth() / 2,
			hb.obstacle.height / 2
		)

		-- Swan
		local swan = swans[st.costumes.swan]
		love.graphics.draw(
			swan,
			st.swan.x + hb.swan.width / 2,
			st.swan.y + hb.swan.height / 2,
			math.rad(data.swanRotations[st.swan.rotation]),
			1,
			1,
			hb.swan.width / 2,
			swan:getHeight() - hb.swan.height / 2
		)

		if drawHitboxes then
			fn.drawHitboxes()
		end

		-- Coin
		if not st.coin.collected then
			love.graphics.draw(coin, st.coin.x, st.coin.y)
		end

		-- Counter
		love.graphics.setFont(fonts.large)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(st.forThisTime, 12, 12)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(st.forThisTime, 10, 10)

	-- Game over screen
	else
		-- Background
		love.graphics.setColor(love.math.colorFromBytes(0, 170, 255))
		love.graphics.rectangle("fill", 0, 0, data.GAME_WIDTH, data.GAME_HEIGHT)
		-- Restart button
		love.graphics.setColor(love.math.colorFromBytes(0, 255, 0)) --Fill
		love.graphics.rectangle(
			"fill",
			data.restartButton.x,
			data.restartButton.y,
			data.restartButton.width,
			data.restartButton.height,
			data.restartButton.cornerRadius
		)
		love.graphics.setLineWidth(5) -- Contour
		love.graphics.setColor(love.math.colorFromBytes(34, 177, 76))
		love.graphics.rectangle(
			"line",
			data.restartButton.x,
			data.restartButton.y,
			data.restartButton.width,
			data.restartButton.height,
			data.restartButton.cornerRadius
		)
		love.graphics.setColor(0, 0, 0) -- Label
		love.graphics.setFont(fonts.pixel)
		love.graphics.printf(
			"GO!",
			data.restartButton.x,
			data.restartButton.y + data.restartButton.height / 2 - fonts.pixel:getHeight() / 2,
			data.restartButton.width,
			"center"
		)
		-- Swan
		local img = swans[st.costumes.swan]
		local leftIndent = 10
		local bottomIndent = 15
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(img, leftIndent, data.GAME_HEIGHT - img:getHeight() - bottomIndent)
		-- Counter
		love.graphics.setFont(fonts.small)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(fn.translate("For this time: ") .. st.forThisTime, 10, 120)
		love.graphics.print(fn.translate("Balance: ") .. st.balance, 10, 140)
		-- Game over label
		love.graphics.setFont(fonts.gameOver)
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf("GAME OVER", GAME_OVER_SHADOW, 205, data.GAME_WIDTH + GAME_OVER_SHADOW, "center")
		love.graphics.setColor(love.math.colorFromBytes(255, 255, 0))
		love.graphics.printf("GAME OVER", 0, 200, data.GAME_WIDTH, "center")
		-- Buttons
		for _, btn in ipairs(data.menuButtons) do
			local r, g, b = btn.r, btn.g, btn.b
			local c = data.menuButton.selectedBrightness
			if st.currentCategory == btn.category then
				r, g, b = r * c, g * c, b * c
			end
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle(
				"fill",
				btn.x + GAME_OVER_SHADOW,
				data.menuButton.y + GAME_OVER_SHADOW,
				data.menuButton.width,
				data.menuButton.height,
				data.menuButton.cornerRadius
			)
			love.graphics.setColor(love.math.colorFromBytes(r, g, b))
			love.graphics.rectangle(
				"fill",
				btn.x,
				data.menuButton.y,
				data.menuButton.width,
				data.menuButton.height,
				data.menuButton.cornerRadius
			)
			love.graphics.draw(btn.icon, btn.x, data.menuButton.y)
		end

		-- Menu
		if st.isMenuOpen then
			love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 230))
			love.graphics.rectangle("fill", 0, 120, data.GAME_WIDTH, 520)
		end

		love.graphics.setLineWidth(data.button.border) -- for settings and shop buttons

		-- Settings
		if st.isMenuOpen and st.currentCategory == "Settings" then
			for _, params in ipairs(data.settingsButtons) do
				-- Fill
				love.graphics.setColor(data.button.bgColor)
				love.graphics.rectangle("fill", params.x, params.y, params.width, params.height)
				-- Border
				love.graphics.setColor(data.button.textAndBorderColor)
				love.graphics.rectangle("line", params.x, params.y, params.width, params.height)
				-- Text and checkmark
				local textY
				if st.gameSettings[params.key] == params.value then
					textY = params.y + 20
					fn.drawCheckmark(
						params.x + params.width / 2 - SETTINGS_CHECKMARK_SIZE / 2,
						params.y + 80,
						SETTINGS_CHECKMARK_SIZE
					)
				else
					textY = params.y + params.height / 2 - fonts.regular:getHeight() / 2
				end
				love.graphics.setFont(fonts.regular)
				love.graphics.printf(fn.translate(params.name), params.x, textY, params.width, "center")
			end
		end

		-- Shop
		if st.isMenuOpen and data.shopButtons[st.currentCategory] then
			-- For skins
			local imgIndex = 1
			-- For locations
			local bgIndex = 1
			local landIndex = 0
			local obstacleIndex = 1

			for _, params in ipairs(data.shopButtons[st.currentCategory]) do
				-- Fill
				love.graphics.setColor(data.button.bgColor)
				love.graphics.rectangle("fill", params.x, params.y, data.shopButton.width, data.shopButton.height)
				-- Image
				love.graphics.setColor(1, 1, 1)
				local img
				if st.currentCategory == "Skins" then
					img = swans[imgIndex]
				elseif st.currentCategory == "Locations" then
					love.graphics.draw(backgrounds[bgIndex], quads.location, params.x, params.y, 0, 0.458, 0.458)
					if lands[landIndex] then
						love.graphics.draw(lands[landIndex], quads.land, params.x, params.y, 0, 0.458, 0.458)
					end
					img = obstacles[obstacleIndex]
				end
				love.graphics.draw(
					img,
					params.x + data.shopButton.width / 2 - img:getWidth() * data.shopButton.imgScale / 2,
					params.y + data.shopButton.height - img:getHeight() * data.shopButton.imgScale - data.shopButton.bottomPadding,
					0,
					data.shopButton.imgScale, data.shopButton.imgScale
				)
				-- Label
				local labelY = params.y + data.shopButton.height - data.shopButton.labelHeight
				love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 150))
				love.graphics.rectangle("fill", params.x, labelY, data.shopButton.width, data.shopButton.labelHeight)
				-- Border
				love.graphics.setColor(data.button.textAndBorderColor)
				love.graphics.rectangle("line", params.x, params.y, data.shopButton.width, data.shopButton.height)
				-- Text
				love.graphics.setFont(fonts.small)
				local textY = labelY
				if st.gameSettings[(st.currentCategory == "Skins") and "skin" or "location"] == params.name then
					fn.drawCheckmark(
						params.x + data.shopButton.width / 2 - data.shopButton.checkmarkSize / 2,
						params.y + data.shopButton.priceAndCheckmarkY,
						data.shopButton.checkmarkSize
					)
				else
					if params.bought then
						textY = labelY + data.shopButton.labelHeight / 2 - fonts.small:getHeight() / 2
					else
						local priceWidth = fn.getPriceWidth(params.price, coin)
						fn.drawPrice(params.x + data.shopButton.width / 2 - priceWidth / 2,
									 params.y + data.shopButton.priceAndCheckmarkY, params.price, coin)
					end
				end
				love.graphics.printf(fn.translate(params.name), params.x, textY, data.shopButton.width, "center")

				if st.currentCategory == "Skins" then
					imgIndex = imgIndex + 3
				elseif st.currentCategory == "Locations" then
					if params.name == "City" then
						bgIndex = bgIndex + 5
					else
						bgIndex = bgIndex + 1
					end
					landIndex = landIndex + 1
					obstacleIndex = obstacleIndex + 1
				end
			end
		end

		-- Not enough coins
		if st.notEnoughCoinsTimer < data.NOT_ENOUGH_COINS_TIMER_SEC then
			local x = data.GAME_WIDTH / 2 - NOT_ENOUGH_COINS_WIDTH / 2
			local y = data.GAME_HEIGHT / 2 - NOT_ENOUGH_COINS_HEIGHT / 2
			love.graphics.setFont(fonts.regular)
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", x, y, NOT_ENOUGH_COINS_WIDTH, NOT_ENOUGH_COINS_HEIGHT, 10)
			love.graphics.setColor(0, 0, 0)
			love.graphics.printf(
				fn.translate("Not enough coins"),
				x,
				y + NOT_ENOUGH_COINS_HEIGHT / 2 - fonts.regular:getHeight() / 2,
				NOT_ENOUGH_COINS_WIDTH,
				"center"
			)
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
			-- Restart button
			if not st.isMenuOpen and mx >= data.restartButton.x and mx <= data.restartButton.x + data.restartButton.width and my >= data.restartButton.y and my <= data.restartButton.y + data.restartButton.height then
				love.system.vibrate(0.1)
				fn.resetPositions(audio.backgroundMusic)
			end
			-- Menu buttons
			for _, btn in ipairs(data.menuButtons) do
				if mx >= btn.x and mx <= btn.x + data.menuButton.width and my >= data.menuButton.y and my <= data.menuButton.y + data.menuButton.height then
					love.system.vibrate(0.1)
					if btn.category == st.currentCategory then
						st.isMenuOpen = false
						st.currentCategory = nil
					else
						st.isMenuOpen = true
						st.currentCategory = btn.category
					end
				end
			end
			-- Settings buttons
			if st.isMenuOpen and st.currentCategory == "Settings" then
				for _, btn in ipairs(data.settingsButtons) do
					if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
						love.system.vibrate(0.1)
						st.gameSettings[btn.key] = btn.value
						if btn.key == "language" then
							fn.changeLanguage(btn.value)
						end
					end
				end
			end
			-- Shop buttons
			if data.shopButtons[st.currentCategory] then
				for index, item in ipairs(data.shopButtons[st.currentCategory]) do
					local btn = data.shopButtons[st.currentCategory][index]
					if st.isMenuOpen and mx >= btn.x and mx <= btn.x + data.shopButton.width and my >= btn.y and my <= btn.y + data.shopButton.height then
						love.system.vibrate(0.1)
						local func = (st.currentCategory == "Skins") and fn.applySkin or fn.applyLocation
						fn.tryBuyOrSelect(st.currentCategory, data.shopButtons[st.currentCategory], index, func, item.funcArgs)
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
			st.swan.nextY = st.swan.y - deltaY
			st.mouseStartY = nil
		end
	end
end

function love.keypressed(key, unicode)
	if key == "space" and st.gameOver then
		fn.resetPositions(audio.backgroundMusic)
	end
end

function love.resize(w, h)
	fn.resize(w, h)
end