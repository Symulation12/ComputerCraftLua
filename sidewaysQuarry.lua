--Sideways Quarry!
-- Movement [complete]
-- Out of fuel returning [complete]
-- Inventory full returning [complete]
-- Retain fuel(optional)
--
--
--


args = {...}
height,width,depth = tonumber(args[1]),tonumber(args[2]),0
x,y=0,0

--Functions
function up()
	y = y + 1
	while not turtle.up() do dig("Up") end
end

function down()
	y = y - 1
	while not turtle.down() do dig("Down")	end
end

function right()
	x = x + 1
	turtle.turnRight()
	while not turtle.forward() do dig("") end
	turtle.turnLeft()
end

function left()
	x = x - 1
	turtle.turnLeft()
	while not turtle.forward() do dig("") end
	turtle.turnRight()
end

function forward()
	depth = depth + 1
	while not turtle.forward() do dig("") end
end

function goBack()
	print("Returning the yummiez")
	local x,y,depth = x,y,depth
	turtle.turnLeft()
	while x ~= 0 do
		if turtle.forward() then
			x = x-1
		else
			turtle.dig()
		end
	end
	while y ~= 0 do
		if turtle.down() then
			y = y-1
		else
			turtle.digDown()
		end
	end
	turtle.turnLeft()
	while depth ~= 0 do
		if turtle.forward() then
			depth = depth-1
		else
			turtle.dig()
		end
	end
end

function originalPos() 
	print("Getting more yummiez")
	turtle.turnRight()
	turtle.turnRight()
	local i = 0
	while i ~= depth do
		if turtle.forward() then
			i = i+1
		else
			turtle.dig()
		end
	end
	i = 0
	turtle.turnRight()
	while i ~= y do
		if turtle.up() then
			i = i+1
		else
			turtle.digUp()
		end
	end
	i = 0
	while i ~= x do
		if turtle.forward() then
			i = i+1
		else
			turtle.dig()
		end
	end
	turtle.turnLeft()
end

--direction is string (Up, Down, or empty string)
function dig(direction)
	setfenv(loadstring("turtle.dig"..direction.."()"),getfenv()) ()
end

function unload()
	print("Putting yummiez in chest")
	for i=1,16 do
		turtle.select(i)
		while not turtle.drop() do
			print("Chest is full")
			os.sleep(5)
		end
	end
	turtle.select(1)
end

function getFuel()
	print("I needs yummiez")
	while not turtle.refuel() do
		os.sleep(2)
	end
	print("YUMMIEZ!")
end
-- returns false if full
function checkInv()
	local b = false
	for i=1,16 do
		b = turtle.getItemCount(i)==0 or b -- if any of the slots are empty this will be true
	end
	return b
end

-- START
a = true
while true do
	for i=1,width do
		for j=1,height-1 do
			dig("")
			if turtle.getFuelLevel() < ((x+y+depth)*2) and turtle.getFuelLevel() > (x+y+depth) then
				goBack()
				unload()
				getFuel()
				originalPos()
			elseif turtle.getFuelLevel() < (x+y+depth) then
				--PANIC!
				print("HELP ME!")
				os.shutdown()
			end
			if not checkInv() then
				goBack()
				unload()
				originalPos()
			end
			if a then 
				up()
			else 
				down()	
			end
		end
		dig("")
		if i ~= width then
			a = not a
			if math.fmod(depth,2) == 0 then
				right()
			else
				left()
			end
		end
	end
	forward()
	a = not a
end