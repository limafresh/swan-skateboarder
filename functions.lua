local data = require("data")
local st = require("settings")
local functions = {}

function functions.resize(w, h)
	local w1, h1 = data.GAME_WIDTH, data.GAME_HEIGHT
	local scale = math.min(w / w1, h / h1)
	st.window.translateX, st.window.translateY, st.window.scale = (w-w1*scale)/2, (h-h1*scale)/2, scale
end

function functions.loadDataFromFiles()
	if love.filesystem.getInfo("balance.txt") then
		local contents = love.filesystem.read("balance.txt")
		st.balance = tonumber(contents)
	end

	if love.filesystem.getInfo("language.txt") then
		st.gameSettings.language = love.filesystem.read("language.txt")
	end

	for tableName, categoryTable in pairs(data.shopButtons) do
		for _, params in ipairs(categoryTable) do
			if params.price > 0 then
				local file = tableName .. "/" .. params.name .. ".txt"
				if love.filesystem.getInfo(file) then
					if love.filesystem.read(file) == "true" then params.bought = true end
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

	local x3 = x + size
	local y3 = y

	love.graphics.line(x1, y1, x2, y2, x3, y3)
end

function functions.drawPrice(x, y, price, coinImg)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(price, x, y)
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(coinImg, x + 30, y, 0, 0.5, 0.5)
	love.graphics.setColor(0, 0, 0)
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
	love.window.setTitle(functions.translate("Swan skateboarder"))
end

function functions.resetPositions(backgroundMusic)
	st.gameOver = false
	st.currentCategory = false
	love.audio.play(backgroundMusic)

	st.swan = {x = 0, y = 0, rotation = 1, timer = 0}
	st.obstacle = {x = data.INITIAL_OBSTACLE_X, y = data.INITIAL_OBSTACLE_Y, rotated = false}

	st.mouseStartY = nil
	st.futureSwanY = nil

	st.bgTimer = 0
	st.notEnoughCoinsTimer = data.NOT_ENOUGH_COINS_TIMER_SEC
	st.coin = {x = nil, y = nil}
	st.scroll = 0
	st.forThisTime = 0
	st.isMenuOpen = false

	if st.gameSettings.location == "City of Dreams" then
		st.gameAssets.background = 1
	end
end

function functions.tryBuyOrSelect(dirname, targetTable, index, onSelect, funcArgs)
	local t = targetTable[index]
	if t.bought then
		onSelect(unpack(funcArgs))
	else
		if st.balance >= t.price then
			st.balance = st.balance - t.price
			t.bought = true
			love.filesystem.write("balance.txt", tostring(st.balance))

			love.filesystem.createDirectory(dirname)
			local file = dirname .. "/" .. t.name .. ".txt"
			love.filesystem.write(file, "true")

			onSelect(unpack(funcArgs))
		else
			st.notEnoughCoinsTimer = 0
		end
	end
end

return functions