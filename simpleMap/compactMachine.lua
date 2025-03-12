require("simpleMap.robotMovement")
require("simpleMap.autoBuilder")
require("invManager")

local sides = require("sides")

local options = {}

local function addOption(name, itemName, func)
	local obj = { name = name, itemName = itemName, exec = func }
	table.insert(options, obj)
	options[itemName] = obj
end

local function getNumberInput(valid)
	local input = nil
	while input == nil do
		input = io.read('*number')
		if valid ~= nil then
			local validCount = #valid
			for	i = 1, validCount do
				if valid[i] == input then
					return input
				end
			end
			print("Not a valid input")
			input = nil
		end
	end
	return input
end

function GetItemNameList()
	return {
		redstone = "minecraft:redstone", 
		enderPearl = "minecraft:ender_pearl",
		ironBlock = "minecraft:iron_block", 
		goldBlock = "minecraft:gold_block",
		diamondBlock = "minecraft:diamond_block",
		emeraldBlock = "minecraft:emerald_block",
		machineWall = "compactmachines3:wallbreakable"
	}
end

-- FRAMES

-- FRAME
function CompactMachineWallFrame()
	local itens = GetItemNameList()
	return { { { itens.ironBlock } }, { { itens.redstone } } }
end

-- 3x
function CompactMachine3Frame()
	local itens = GetItemNameList()
	local mf = itens.machineWall

	local rowMf = { mf, mf, mf }
	local rowMiddle = { mf, nil, mf }

	local zEx = { rowMf, rowMf, rowMf }
	local zMiddle = { rowMf, rowMiddle, rowMf }
	
	return { zEx, zMiddle, zEx }
end

-- 5x
function CompactMachine5Frame()
	local itens = GetItemNameList()
	local mf = itens.machineWall
	local ir = itens.ironBlock

	local rowMf = { mf, mf, mf }
	local rowMiddle = { mf, ir, mf }

	local zEx = { rowMf, rowMf, rowMf }
	local zMiddle = { rowMf, rowMiddle, rowMf }
	
	return { zEx, zMiddle, zEx }
end

-- 7x
function CompactMachine7Frame()
	local itens = GetItemNameList()
	local mf = itens.machineWall
	local gb = itens.goldBlock

	local rowMf = { mf, mf, mf }
	local rowMiddle = { mf, gb, mf }

	local zEx = { rowMf, rowMf, rowMf }
	local zMiddle = { rowMf, rowMiddle, rowMf }
	
	return { zEx, zMiddle, zEx }
end

-- 9x
function CompactMachine9Frame()
	local itens = GetItemNameList()
	local mf = itens.machineWall
	local nn = nil
	
	local rowMf = { mf, mf, mf, mf, mf }
	local rowMiddle = { mf, nn, nn, nn, mf }
	
	local zEx = { rowMf, rowMf, rowMf, rowMf, rowMf }
	local zMd = { rowMf, rowMiddle, rowMiddle, rowMiddle, rowMf }
	
	return { zEx, zMd, zMd, zMd, zEx }
end

-- 11x
function CompactMachine11Frame()
	local itens = GetItemNameList()
	local mf = itens.machineWall
	local db = itens.diamondBlock
	local nn = nil
	
	local rowMf = { mf, mf, mf, mf, mf }
	local rowMiddle = { mf, nn, nn, nn, mf }
	local rowMiD = { mf, nn, db, nn, mf }
	
	local zEx = { rowMf, rowMf, rowMf, rowMf, rowMf }
	local zMd = { rowMf, rowMiddle, rowMiddle, rowMiddle, rowMf }
	local zMdb = { rowMf, rowMiddle, rowMiD, rowMiddle, rowMf }
	
	return { zEx, zMd, zMdb, zMd, zEx }
end

-- 13x
function CompactMachine13Frame()
	local itens = GetItemNameList()
	local mf = itens.machineWall
	local eb = itens.emeraldBlock
	local nn = nil
	
	local rowMf = { mf, mf, mf, mf, mf }
	local rowMiddle = { mf, nn, nn, nn, mf }
	local rowMiD = { mf, nn, eb, nn, mf }
	
	local zEx = { rowMf, rowMf, rowMf, rowMf, rowMf }
	local zMd = { rowMf, rowMiddle, rowMiddle, rowMiddle, rowMf }
	local zMdb = { rowMf, rowMiddle, rowMiD, rowMiddle, rowMf }
	
	return { zEx, zMd, zMdb, zMd, zEx }
end

-- BUILDERS

-- wrapper
local function build(frame, quantity, itemToDrop, buildName)
	local crafted = 0
	print("========== BUILDING " .. quantity .. " " .. buildName)
	local function dropFunc(robot)
		MoveTo(robot, 7)
		DropItem(sides.down, itemToDrop, 1)
	end
	
	local function validadeItens(robot)
		local area, itens = GetAreaAndItemNeededByFrame(frame)
		local hasQuantity = GetOwnQuantityOf(itemToDrop)
		local needed = 2 * (quantity - crafted)
		if hasQuantity < needed then
			local col = Collectables[itemToDrop]
			print("[GET ITEM TO DROP] " .. itemToDrop)
			if col ~= nil then
				MoveTo(robot, col.x, col.y, col.z)
				LookTo(robot, col.side)
				SuckItemFromInventory(sides.front, itemToDrop, needed - hasQuantity)
			end
			if GetOwnQuantityOf(itemToDrop) < 1 then
				return false
			end
		end

		local function getOrCraft(robot, collectable, item, retry)
			local quantityOnInv = GetOwnQuantityOf(item.name)
			local needed = item.quantity * (quantity - crafted)
			if quantityOnInv >= needed then
				return true
			end
			
			if collectable == nil then
				return false
			end
			
			MoveTo(robot, collectable.x, collectable.y, collectable.z)
			LookTo(robot, collectable.side)
			SuckItemFromInventory(sides.front, item.name, needed - quantityOnInv)
			quantityOnInv = GetOwnQuantityOf(item.name)
			print("AFTER COLLECT " .. item.name .. " - has " .. quantityOnInv .. " of " .. needed - quantityOnInv)
			if quantityOnInv < needed then
				if retry == false then
					return false
				end
				
				local opt = options[item.name]
				if opt ~= nil then
					MoveTo(robot, 0, 0, 0)
					LookTo(robot, sides.front)
					local toCraft = (needed - quantityOnInv) / 16
					if toCraft > math.floor(toCraft) then
						toCraft = math.floor(toCraft) + 1
					end
					opt.exec(toCraft)
					getOrCraft(robot, collectable, item, false)
				end
			end
			
		end
		
		for i, value in ipairs(itens) do
			if getOrCraft(robot, Collectables[value.name], value) == false then
				return false
			end
			crafted = crafted + 1
		end
	end

	for i = 1, quantity do 
		local settings = { collectables = Collectables }
		settings.area, settings.itens = GetAreaAndItemNeededByFrame(frame)
		
		if AutoBuild(frame, settings, dropFunc, validadeItens) then
			print("========== BUILDED " .. buildName .. ", " .. i .. " OF " .. quantity)
		else
			print("========== FAILED TO BUILD " .. buildName)
			return false
		end
		os.sleep(5)
	end

	return true
end

-- FRAME
local function buildCompactMachineWall(quantity)
	local frame = CompactMachineWallFrame()
	local dropabble = GetItemNameList().redstone

	return build(frame, quantity, dropabble, "COMPACT MACHINE FRAME")
end

-- 3x
local function buildCompactMachine3(quantity)
	local frame = CompactMachine3Frame()
	local dropabble = GetItemNameList().enderPearl

	return build(frame, quantity, dropabble, "COMPACT MACHINE 3")
end

-- 5x
function buildCompactMachine5(quantity)
	local frame = CompactMachine5Frame()
	local dropabble = GetItemNameList().enderPearl

	return build(frame, quantity, dropabble, "COMPACT MACHINE 5")
end

-- 7x
function buildCompactMachine7(quantity)
	local frame = CompactMachine7Frame()
	local dropabble = GetItemNameList().enderPearl

	return build(frame, quantity, dropabble, "COMPACT MACHINE 7")
end

-- 9x
function buildCompactMachine9(quantity)
	local frame = CompactMachine9Frame()
	local dropabble = GetItemNameList().enderPearl

	return build(frame, quantity, dropabble, "COMPACT MACHINE 9")
end

-- 11x
function buildCompactMachine11(quantity)
	local frame = CompactMachine11Frame()
	local dropabble = GetItemNameList().enderPearl

	return build(frame, quantity, dropabble, "COMPACT MACHINE 11")
end

-- 13x
function buildCompactMachine13(quantity)
	local frame = CompactMachine13Frame()
	local dropabble = GetItemNameList().enderPearl

	return build(frame, quantity, dropabble, "COMPACT MACHINE 13")
end

local itemList = GetItemNameList()
Collectables = {}
Collectables[itemList.enderPearl] = { x = -1, y = 1, side = sides.back }
Collectables[itemList.redstone] = { x = -2, y = 1, side = sides.back }
Collectables[itemList.machineWall] = { x = -3, y = 1, side = sides.back }
Collectables[itemList.ironBlock] = { x = -4, y = 1, side = sides.back }
Collectables[itemList.goldBlock] = { x = -5, y = 1, side = sides.back }
Collectables[itemList.emeraldBlock] = { x = -6, y = 1, side = sides.back }
Collectables[itemList.diamondBlock] = { x = -7, y = 1, side = sides.back }

addOption("Compact Machine Wall", itemList.machineWall, buildCompactMachineWall)
addOption("Compact Machine 3x3x3", "compactMachine3", buildCompactMachine3)
addOption("Compact Machine 5x5x5", "compactMachine5", buildCompactMachine5)
addOption("Compact Machine 7x7x7", "compactMachine7", buildCompactMachine7)
addOption("Compact Machine 9x9x9", "compactMachine9", buildCompactMachine9)
addOption("Compact Machine 11x11x11", "compactMachine11", buildCompactMachine11)
addOption("Compact Machine 13x13x13", "compactMachine13", buildCompactMachine13)

function BuildCompactMachine()
	print("Wich one: ")
	local valids = {}
	
	for i, value in ipairs(options) do
		print(i .. " - " .. value.name)
		table.insert(valids, i)
	end
	local input = getNumberInput(valids)

	local option = options[input]
	if option == nil then
		return
	end

	print("Quantity: ")
	local inputQuantity = getNumberInput()

	print("Building...")
	option.exec(inputQuantity)
	
end

BuildCompactMachine()
