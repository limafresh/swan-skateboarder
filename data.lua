local data = {}

data.GAME_WIDTH = 360
data.GAME_HEIGHT = 640

data.OBSTACLE_HEIGHT = 249
data.INITIAL_OBSTACLE_X = 300
data.INITIAL_OBSTACLE_Y = data.GAME_HEIGHT - data.OBSTACLE_HEIGHT

data.assetFileNames = {
	backgrounds = {
		"cityofdreams1", "cityofdreams2", "cityofdreams3", "cityofdreams4",
		"cityofdreams5", "fading_sky", "cloudy_sky", "wispy_sky", "space",
		"museum", "kitchen", "warehouse"
	},
	lands = {
		"island", "coniferous_forest", "land_of_snow", "space",
		"museum", "kitchen", "warehouse"
	},
	obstacles = {
		"skyscraper", "palm", "christmas_tree", "snowman",
		"rocket", "statue", "fridge", "obstacle"
	},
	skins = {
		"classic", "mask", "hat", "friends", "fashionista",
		"fun", "bear", "scarf"
	}
}

data.swanRotations = {0, -15, 15}

data.button = {
	bgColor = {0, 230/255, 230/255},
	textAndBorderColor = {0, 0, 0},
	border = 2
}

data.restartButton = {
	x = 200,
	y = 500,
	width = 150,
	height = 80,
	cornerRadius = 30
}

data.menuButton = {
	y = 15,
	width = 100,
	height = 90,
	cornerRadius = 20,
	selectedBrightness = 0.7
}

data.menuButtons = {
	{r = 0, g = 255, b = 0, x = 15, iconFile = "settings.png", category = "Settings"},
	{r = 0, g = 230, b = 230, x = 130, iconFile = "skins.png", category = "Skins"},
	{r = 255, g = 0, b = 127, x = 245, iconFile = "locations.png", category = "Locations"}
}

data.settingsButtons = {
	{name = "Easy mode", x = 10, y = 130, width = 340, height = 160, key = "mode", value = "Easy"},
	{name = "Hard mode", x = 10, y = 300, width = 340, height = 160, key = "mode", value = "Hard"},
	{name = "English", x = 10, y = 470, width = 165, height = 160, key = "language", value = "en"},
	{name = "Українська", x = 185, y = 470, width = 165, height = 160, key = "language", value = "uk"}
}

data.shopButton = {
	width = 165,
	height = 120,
	bottomPadding = 5,
	imgScale = 0.45,
	labelHeight = 60,
	checkmarkSize = 30,
	priceAndCheckmarkY = 85
}

data.shopButtons = {
	Skins = {
		{name = "Classic", x = 10, y = 130, price = 0, bought = true},
		{name = "In a mask", x = 185, y = 130, price = 35, bought = false, file = "boughtMask.txt", funcArgs = {4, "In a mask"}},
		{name = "In a hat", x = 10, y = 260, price = 40, bought = false, file = "boughtHat.txt", funcArgs = {7, "In a hat"}},
		{name = "With friends", x = 185, y = 260, price = 45, bought = false, file = "boughtFriends.txt", funcArgs = {10, "With friends"}},
		{name = "Fashionista", x = 10, y = 390, price = 50, bought = false, file = "boughtFashionista.txt", funcArgs = {13, "Fashionista"}},
		{name = "Fun", x = 185, y = 390, price = 55, bought = false, file = "boughtFun.txt", funcArgs = {16, "Fun"}},
		{name = "Bear", x = 10, y = 520, price = 60, bought = false, file = "boughtBear.txt", funcArgs = {19, "Bear"}},
		{name = "In a scarf", x = 185, y = 520, price = 65, bought = false, file = "boughtScarf.txt", funcArgs = {22, "In a scarf"}}
	},
	Locations = {
		{name = "City of Dreams", x = 10, y = 130, price = 0, bought = true},
		{name = "Island", x = 185, y = 130, price = 35, bought = false, file = "boughtIsland.txt", funcArgs = {"Island", 6, 1, 2}},
		{name = "Coniferous forest", x = 10, y = 260, price = 40, bought = false, file = "boughtConiferousForest.txt", funcArgs = {"Coniferous forest", 7, 2, 3}},
		{name = "Land of snow", x = 185, y = 260, price = 45, bought = false, file = "boughtLandOfSnow.txt", funcArgs = {"Land of snow", 8, 3, 4}},
		{name = "Space", x = 10, y = 390, price = 50, bought = false, file = "boughtSpace.txt", funcArgs = {"Space", 9, 4, 5}},
		{name = "Museum", x = 185, y = 390, price = 55, bought = false, file = "boughtMuseum.txt", funcArgs = {"Museum", 10, 5, 6}},
		{name = "Kitchen", x = 10, y = 520, price = 60, bought = false, file = "boughtKitchen.txt", funcArgs = {"Kitchen", 11, 6, 7}},
		{name = "Warehouse", x = 185, y = 520, price = 65, bought = false, file = "boughtWarehouse.txt", funcArgs = {"Warehouse", 12, 7, 8}}
	}
}

data.lastCostumes = {
	Classic = 3,
	["In a mask"] = 6,
	["In a hat"] = 9,
	["With friends"] = 12,
	Fashionista = 15,
	Fun = 18,
	Bear = 21,
	["In a scarf"] = 24
}

data.translations = {
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

return data