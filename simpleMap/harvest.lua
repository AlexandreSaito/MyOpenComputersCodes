require("./simpleMap/robotMovement")

local HarvestModes = { breakCrop = 0, rightClick = 1 }

function harvest(robot, harvestMode, side)
	
end

function harvestArea()
	local origin = { x = 0, y = 0, z = 0}
	local robot = getRobotObject(origin.x, origin.y, origin.z);
	local area = {xStart = 1, xEnd = 21, yStart = 0, yEnd = 10, zInterectable = 0, zMoveable = 1 }
	
	-- get resource if needed
	
	-- go to start of farm
	moveToZ(robot, area.zMoveable)
	moveTo(robot, area.xStart, area.yStart)
	
	for x = area.xStart, area.xEnd do 
		local currentY = area.yEnd
		local increment = 1
		if currentY == robot.y then
			currentY = area.yStart
			increment = -1
		end
		
		for y = robot.y, currentY, increment do
			harvest(robot, HarvestModes.rightClick, sides.down)
			print(x, y)
			sleep(0.1)
		end
		sleep(0.1)
	end
	
	-- back to origin
	moveTo(robot, origin.x, origin.y)
	moveToZ(robot, origin.z)
	
end
