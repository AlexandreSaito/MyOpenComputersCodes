local component = require("component")
local sides = require("sides")
local rb = component.robot
local ic = component.inventory_controller

function getOwnItemInfo(slotIndex)	
	return ic.getStackInInternalSlot(slotIndex)
end

function GetItemInfo(side, slotIndex)
	return ic.getStackInSlot(side, slotIndex)
end

function GetOwnInventoryInfo()
	local inventory = {}
	inventory.size = rb.inventorySize()
	
	for i = 1, inventory.size do 
		inventory[i] = getOwnItemInfo(i)
	end
	
	return inventory
end

function GetInventoryInfo(side)
	local inventory = {}
	inventory.size = ic.getInventorySize(side)
	
	for i = 1, inventory.size do 
		inventory[i] = GetItemInfo(side, i)
	end

	return inventory
end

function GetOwnQuantityOf(itemName, slotIndex)	
	if slotIndex ~= nil then 
		local slot = getOwnItemInfo(slotIndex)
		
		if slot == nil then
			return 0
		end
		
		if slot.name ~= itemName then
			return 0
		end
		
		return slot.size
	end
	
	local quantity = 0
	local size = rb.inventorySize()
	for i = 1, size do 
		local slot = getOwnItemInfo(i)
		if slot ~= nil and slot.name == itemName then
			quantity = quantity + slot.size
		end
	end
	
	return quantity
end

function GetQuantityOf(side, itemName, slotIndex)	
	if slotIndex ~= nil then 
		local slot = GetItemInfo(side, slotIndex)
		
		if slot == nil then
			return 0
		end
		
		if slot.name ~= itemName then
			return 0
		end
		
		return slot.size
	end
	
	local quantity = 0
	local size = ic.getInventorySize(side)
	for i = 1, size do 
		local slot = GetItemInfo(side, i)
		if slot ~= nil and slot.name == itemName then
			quantity = quantity + slot.size
		end
	end
	
	return quantity
end

function GetOwnFirstSlotOf(itemName)
	local invSize = rb.inventorySize()
	for i = 1, invSize do 
		local slot = getOwnItemInfo(i)
		if slot ~= nil and slot.name == itemName then
			return i
		end
	end
	
	return -1
end

function GetFirstSlotOf(side, itemName)
	local invSize = ic.getInventorySize(side)
	
	for i = 1, invSize do 
		local slot = GetItemInfo(side, i)
		if slot ~= nil and slot.name == itemName then
			return i
		end
	end
	
	return -1
end

function SuckFromInventory(side, quantity)
	rb.suck(side, quantity)
end

function SuckItemFromInventory(side, itemName, quantity)
	local currentQuantity = GetOwnQuantityOf(itemName)
	local quantitySucked = 0
	local itemSlot = GetFirstSlotOf(side, itemName)
	
	while quantitySucked < quantity and itemSlot ~= -1 do
		local item = GetItemInfo(side, itemSlot)
		local quantityNeeded = quantity - quantitySucked
		if ic.suckFromSlot(side, itemSlot, quantityNeeded) then
			local newQuantity = GetOwnQuantityOf(itemName)
			quantitySucked = newQuantity - currentQuantity
		end
		
		if quantitySucked < quantity then
			itemSlot = GetFirstSlotOf(side, itemName)
		end
	end

	print("[SUCKED " .. quantitySucked .. " of " .. itemName .. "]")
	return quantitySucked
end

function DropItem(side, itemName, quantity)
	local itemDropped = 0
	print("[DROPPING " .. itemName .. " - " .. quantity .. "]")
	if SelectItem(itemName) == false then
		return false
	end
	
	if rb.drop(sides.down, quantity) then
		return true
	end
	
	return false
end

function SelectItem(itemName)
	local currentItem = getOwnItemInfo(rb.select())
	if currentItem ~= nil and currentItem.name == itemName then
		return true
	end
	print("--- SELECTING ITEM " .. itemName)
	local slot = GetOwnFirstSlotOf(itemName)
	if slot == -1 then
		print("--- ITEM NOT FOUND " .. itemName)
		return false
	end
	
	rb.select(slot)
	return true
end

function PlaceItem(side, itemName)
	if SelectItem(itemName) then
		print("--- PLACING ITEM " .. itemName)
		PlaceSelected(side)
		return true
	end
	
	return false
end

function PlaceSelected(side)
	rb.place(side)
end
