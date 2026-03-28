local M = {}

function M.checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function M.drawCheckmark(x, y, size)
	local x1 = x
	local y1 = y + size * 0.5

	local x2 = x + size * 0.5
	local y2 = y + size

	local x3 = x + size * 1.5
	local y3 = y

	love.graphics.line(x1, y1, x2, y2, x3, y3)
end

function M.drawPrice(x, y, price)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
	love.graphics.print(price, x, y)
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	love.graphics.draw(coin, x + 30, y, 0, 0.5, 0.5)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0))
end

function M.applySkin(cur, newSkin)
	currentSwan = cur
	skin = newSkin
end

function M.applyLocation(name, bg, land, obstacle)
	location = name
	currentBackground = bg
	currentLand = land
	currentObstacle = obstacle
end

function M.changeLanguage(lang)
	language = lang
	love.filesystem.write("language.txt", lang)
end

function M.resetPositions()
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

function M.markBought(targetTable)
	local index = 2
	for _, params in ipairs(targetTable) do
		if params.file then
			if love.filesystem.getInfo(params.file) then
				if love.filesystem.read(params.file) == "true" then params.bought = true end
			end
			index = index + 1
		end
	end
end

function M.tryBuyOrSelect(targetTable, index, onSelect)
	local t = targetTable[index]
	if t.bought then
		onSelect()
	else
		if forAllTimes >= t.price then
			forAllTimes = forAllTimes - t.price
			t.bought = true
			love.filesystem.write("forAllTimes.txt", tostring(forAllTimes))
			love.filesystem.write(t.file, "true")
			onSelect()
		else
			notEnoughCoinsTimer = 0
		end
	end
end

return M