local component = require("component")
local sides = require("sides")

local rb = component.robot

local function printPos(robot)
	--print("[NEW POS] LookTo: ".. sides[robot.looking] .. ", X: " .. robot.x .. ", Y: " .. robot.y .. ", Z: " .. robot.z .. "\n")
end

function GetRobotObject(x, y, z, side)
	local robot = {}
	robot.x = x or 0
	robot.y = y or 0
	robot.z = z or 0
	robot.looking = side or sides.front
	
	return robot
end

-- turn around
function LookTo(robot, side)
	if robot.looking == side then
		return
	end
	
	if side == sides.front then
		if robot.looking == sides.right then
			rb.turn(false)
		elseif robot.looking == sides.left then
			rb.turn(true)
		elseif robot.looking == sides.back then
			rb.turn(true)
			rb.turn(true)
		end
	elseif side == sides.back then 
		if robot.looking == sides.right then
			rb.turn(true)
		elseif robot.looking == sides.left then
			rb.turn(false)
		elseif robot.looking == sides.front then
			rb.turn(true)
			rb.turn(true)
		end
	elseif side == sides.right then
		if robot.looking == sides.front then
			rb.turn(true)
		elseif robot.looking == sides.back then
			rb.turn(false)
		elseif robot.looking == sides.left then
			rb.turn(false)
			rb.turn(false)
		end
	elseif side == sides.left then
		if robot.looking == sides.front then
			rb.turn(false)
		elseif robot.looking == sides.back then
			rb.turn(true)
		elseif robot.looking == sides.right then
			rb.turn(false)
			rb.turn(false)
		end
	end
	
	robot.looking = side
	
end

function MoveX(robot, direction)
	if robot.x == direction then
		return true
	end
	
	if robot.x > direction then 
		LookTo(robot, sides.left)
		if rb.move(sides.front) then
			robot.x = robot.x -1
			return true
		end
	else
		LookTo(robot, sides.right)
		if rb.move(sides.front) then
			robot.x = robot.x +1
			return true
		end
	end
	
	return false
end

function MoveY(robot, direction)
	if robot.y == direction then
		return true
	end
	
	if robot.y > direction then 
		LookTo(robot, sides.back)
		if rb.move(sides.front) then
			robot.y = robot.y -1
			return true
		end
	else
		LookTo(robot, sides.front)
		if rb.move(sides.front) then
			robot.y = robot.y +1
			return true
		end
	end
	
	return false
end

function MoveZ(robot, z)
	if robot.z == z then
		return true
	end
	
	if robot.z > z then
		if rb.move(sides.down) then
			robot.z = robot.z -1
			return true
		end
	else
		if rb.move(sides.up) then
			robot.z = robot.z +1
			return true
		end
	end
	
	return false
end

function MoveToX(robot, x)
	while robot.x ~= x do
		if MoveX(robot, x) == false then
			return false
		end
	end
	
	printPos(robot)
	return true
end

function MoveToY(robot, y)
	while robot.y ~= y do
		if MoveY(robot, y) == false then
			return false
		end
	end
	
	printPos(robot)
	return true
end

function MoveToZ(robot, z)
	while robot.z ~= z do
		if MoveZ(robot, z) == false then
			return false
		end
	end

	printPos(robot)
	return true
end

function MoveTo(robot, x, y, z)
	print("== MOVE TO LOOP x: " .. (x or "na") .. ", y: " .. (y or "na") .. ", z: " .. (z or "na"))
	while (x == nil or robot.x ~= x) or (y == nil or robot.y ~= y) or (z == nil or robot.z ~= z) do
		if x ~= nil and robot.x ~= x then
			MoveToX(robot, x)
		end
		if y ~= nil and robot.y ~= y then
			MoveToY(robot, y)
		end
		if z ~= nil and robot.z ~= z  then
			MoveToZ(robot, z)
		end
		printPos(robot)
		print("== ON LOOP... CURRENT POS x: " .. robot.x .. ", y: " .. robot.y .. ", z: " .. robot.z)
		if (x == nil or robot.x == x) and (y == nil or robot.y == y) and (z == nil or robot.z == z) then
			break;
		end
	end
	print("== LOOP ENDED ON POS x: " .. robot.x .. ", y: " .. robot.y .. ", z: " .. robot.z)
end

function MoveToArray(robot, positions, action, actionOptions)
	local posCount = table.getn(positions)
	
	for i = 0, posCount do 
		local pos = positions[i]
		MoveTo(robot, pos.x, pos.y, pos.z)
		if action ~= nil then
			action(robot, actionOptions)
		end
	end
	
end