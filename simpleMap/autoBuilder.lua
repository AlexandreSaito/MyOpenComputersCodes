require("simpleMap.robotMovement")
require("invManager")
local sides = require("sides")

local inLoopSleepTime = 0.05

local function hasEnoughItens(itens)
	local hasEnough = true
	local missing = {}

	print("-----------------------")
	for i, value in ipairs(itens) do
		local onInventory = GetOwnQuantityOf(value.name)
		print("item: " .. value.name .. ", need: " .. value.quantity .. ", has: " .. onInventory)
		if value.quantity > onInventory then
			hasEnough = false
			table.insert(missing, { name = value.name, quantity = value.quantity - onInventory })
		end
	end
	print("-----------------------")

	return hasEnough, missing
end

function FindIndexByItemName(itemList, itemName)
	local q = #itemList

	for i = 1, q do
		if itemList[i].name == itemName then
			return i
		end
	end

	return -1
end

function GetAreaAndItemNeededByFrame(frame)
	local area = { x = 0, y = 0, z = 0 }
	local itens = {}
	area.z = #frame

	for z = 1, area.z do
		local zRow = frame[z]
		local qY = #zRow

		if qY > area.y then
			area.y = qY
		end

		for y = 1, qY do
			local yRow = zRow[y]
			local qX = #yRow

			if qX > area.x then
				area.x = qX
			end

			for x = 1, qX do
				local xRow = yRow[x]
				if xRow ~= nil and xRow ~= "none" then
					local index = FindIndexByItemName(itens, xRow)
					local item = itens[index]

					if index == -1 then
						table.insert(itens, { name = xRow, quantity = 0 })
						index = FindIndexByItemName(itens, xRow)
						item = itens[index]
						itens[xRow] = item
					end

					item.quantity = item.quantity + 1

					--print("item " .. item.name .. " " .. item.quantity)
				end
				os.sleep(inLoopSleepTime)
			end

		end

	end

	return area, itens
end

function AutoBuild(frame, settings, actionOnEnd, actionOnBefore)
	local origin = { x = 0, y = 0, z = 0 }
	local robot = GetRobotObject(origin.x, origin.y, origin.z);

	-- default settings
	if settings == nil then
		settings = {}
	end

	if settings.backToOrigin == nil then
		settings.backToOrigin = true
	end

	if settings.buildDirection == nil then
		settings.buildDirection = -1
	end

	if settings.itens == nil or settings.area == nil then
		settings.area, settings.itens = GetAreaAndItemNeededByFrame(frame)
	end

	if actionOnBefore ~= nil then
		if actionOnBefore(robot) == false then
			MoveTo(robot, origin.x, origin.y, origin.z)
			LookTo(robot, sides.front)
			return false
		end
	end
	
	--print("ITENS NEEDED: ")
	--for i, value in ipairs(settings.itens) do
	--	print("	" .. value.quantity .. " - " .. value.name)
	--end

	local missingItens = {}
	local hasItens, missingItens = hasEnoughItens(settings.itens)

	if hasItens == false then
		if settings.collectables ~= nil then
			for i, value in ipairs(missingItens) do
				print("has to grab " .. value.quantity .. " of " .. value.name)
				local collectable = settings.collectables[value.name]
				if collectable == nil then
					print("\n\n collectable not register " .. value.name)
					break
				end
				MoveTo(robot, collectable.x, collectable.y, collectable.z)
				LookTo(robot, collectable.side)
				SuckItemFromInventory(sides.front, value.name, value.quantity)
			end
			-- get itens
			hasItens, missingItens = hasEnoughItens(settings.itens)
		end

		if hasItens == false then
			MoveTo(robot, origin.x, origin.y, origin.z)
			print("NOT ENOUGH ITENS, Should retry? (y/n)")
			local input = io.read()
			if input == 'y' then
				return AutoBuild(AutoBuild, settings)
			end
			return false
		end

	end

	local startX = origin.x + ((settings.area.x -1) * settings.buildDirection)
	local startY = origin.y + settings.area.y

	if settings.tryCenterX then
		startX = startX / 2
	end
	if settings.offSetX ~= nil then
		startX = startX + settings.offSetX
	end
	if settings.offSetY ~= nil then
		startY = startY + settings.offSetY
	end

	MoveTo(robot, startX, startY)

	print("[STARTING TO PLACE ITENS]")
	for i = 1, settings.area.z do
		local zRow = frame[i]
		local yCount = #zRow
		MoveToZ(robot, i - 1)
		--MoveToY(robot, startY)

		for y = 1, yCount do
			local yRow = zRow[y]
			local xCount = #yRow
			local localY = startY - (y -1)
			MoveToY(robot, localY)
			--MoveToX(robot, startX)

			for x = 1, xCount do
				local item = yRow[x]
				if item ~= nil and item ~= "none" then 
					local localX = startX + (x -1)
					MoveToX(robot, localX)
					LookTo(robot, sides.front)

					print("Should place " .. item .. " at x: " .. localX .. ", y: " .. localY .. ", z: " .. i)
					PlaceItem(sides.front, item)
				end
				os.sleep(0.05)
			end
		end
	end

	if actionOnEnd ~= nil then
		actionOnEnd(robot)
	end
	
	if settings.backToOrigin then
		MoveTo(robot, origin.x, origin.y, origin.z)
		LookTo(robot, sides.front)
	end

	return true
end
