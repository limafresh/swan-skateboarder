local data = require("data")
local st = require("settings")
local functions = {}

function functions.resize(w, h)
	local w1, h1 = data.GAME_WIDTH, data.GAME_HEIGHT
	local scale = math.min(w / w1, h / h1)
	st.window.translateX, st.window.translateY, st.window.scale = (w-w1*scale)/2, (h-h1*scale)/2, scale
end

function functions.loadDataFromFiles()
	if love.filesystem.getInfo("forAllTimes.txt") then
		local contents = love.filesystem.read("forAllTimes.txt")
		st.forAllTimes = tonumber(contents)
	end

	if love.filesystem.getInfo("language.txt") then
		st.gameSettings.language = love.filesystem.read("language.txt")
	end

	for _, categoryTable in pairs(data.shopButtons) do
		for _, params in ipairs(categoryTable) do
			if params.file then
				if love.filesystem.getInfo(params.file) then
					if love.filesystem.read(params.file) == "true" then params.bought = true end
				end
			end
		end
	end
end

function functions.translate(key)
	local lang = data.translations[st.gameSettings.language]
	if lang and lang[key] then
		return lang[key]
	else
		return key
	end
end

function functions.checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function functions.drawCheckmark(x, y, size)
	local x1 = x
	local y1 = y + size * 0.5

	local x2 = x + size * 0.5
	local y2 = y + size

	local x3 = x + size * 1.5
	local y3 = y

	love.graphics.line(x1, y1, x2, y2, x3, y3)
end

function functions.drawPrice(x, y, price, coinImg)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
	love.graphics.print(price, x, y)
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	love.graphics.draw(coinImg, x + 30, y, 0, 0.5, 0.5)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
end

function functions.applySkin(cur, newSkin)
	st.gameAssets.swan = cur
	st.gameSettings.skin = newSkin
end

function functions.applyLocation(name, bg, land, obstacle)
	st.gameSettings.location = name
	st.gameAssets.background = bg
	st.gameAssets.land = land
	st.gameAssets.obstacle = obstacle
end

function functions.changeLanguage(lang)
	st.gameSettings.language = lang
	love.filesystem.write("language.txt", lang)
end

function functions.resetPositions(backgroundMusic)
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

	if st.gameSettings.location == "City of Dreams" then
		st.gameAssets.background = 1
	end

	forThisTime = 0

	isMenuOpen = false
end

function functions.tryBuyOrSelect(targetTable, index, onSelect, funcArgs)
	local t = targetTable[index]
	if t.bought then
		onSelect(unpack(funcArgs))
	else
		if st.forAllTimes >= t.price then
			st.forAllTimes = st.forAllTimes - t.price
			t.bought = true
			love.filesystem.write("forAllTimes.txt", tostring(st.forAllTimes))
			love.filesystem.write(t.file, "true")
			onSelect(unpack(funcArgs))
		else
			notEnoughCoinsTimer = 0
		end
	end
end

return functions