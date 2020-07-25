-- 144mB = 1 seared stone or 1 ingot of anything else
-- 288mB = 1 block of obsidian from molten obsidian
-- 1296mB = 1 block of metal
-- 1000mB = 1 bucket of anything or 1 clear glass block
-- 250mB = 1 glass pane
-- OP can't differentiate meta values so I need to remember what's inside

--tempargs
local args = {...}

--peripherals
local modem = peripheral.wrap("right")
local tank = peripheral.wrap("left")
--vars
local liquids = { -- Lua doesn't have enums :(
	["iron"]=1,
	["gold"]=2,
	["copper"]=3,
	["aluminum"]=4,
	["cobalt"]=5,
	["ardite"]=6,
	["bronze"]=7,
	["aluminumBrass"]=8,
	["manlyn"]=9, -- stupid spelling
	["alumite"]=10,
	["obsidian"]=11,
	["steel"]=12,
	["glass"]=14,
	["searedStone"]=15,
	["tin"]=16,
	["emerald"]=17
}
local block = {
	[liquids["iron"]] = 1296,
	[liquids["gold"]] = 1296,
	[liquids["copper"]] = 1296,
	[liquids["aluminum"]] = 1296,
	[liquids["cobalt"]] = 1296,
	[liquids["ardite"]] = 1296,
	[liquids["bronze"]] = 1296,
	[liquids["aluminumBrass"]] = 1296,
	[liquids["manlyn"]] = 1296,
	[liquids["alumite"]] = 1296,
	[liquids["obsidian"]] = 288,
	[liquids["steel"]] = 1296,
	[liquids["glass"]] = 1000,
	[liquids["searedStone"]] = 144,
	[liquids["tin"]] = 1296,
	[liquids["emerald"]] = -1
}




--Liquid currently in smeltery
local currentLiquid = liquids[args[1]]
local step,position = 1,0
local function getFloor(pos)
	return math.floor((pos or position)/4)+1
end
-- functions
-- pass in amount of mB returns blocks,ingots, and leftover
local function blocks(amount,liquid)
	local b = math.floor(amount/block[liquid])
	local i,exact
	if liquid == liquids["emerald"] or liquid == liquids["glass"] or liquid == liquids["searedStone"] then
		i = -1
		exact = math.fmod(amount,block[liquid])
	else
		i = math.fmod(amount,block[liquid])
		exact = -1
		if math.fmod(i,144) == 0 then
			i = i/144
		else
			i = math.floor(i/144)
			exact = math.fmod(i/144)
		end
	end
	return b,i,exact
end

local function checkFuel()
	if turtle.getFuelLevel() < 50 then
		modem.trasmit(1224,1,"SySmelter1 needs refuel")
		while not turtle.refuel() do
			os.sleep(4)
		end
	end
end

local function changePosition()
	turtle.turnLeft()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	for i=1,4 do
		turtle.forward()
	end
	turtle.turnRight()
	turtle.forward()
	turtle.forward()
	if getFloor() == 1 then
		position = math.fmod((position + 1),4)
	else
		position = math.fmod((position + 1),4) + 4
	end
	
end
local function changeFloor()
	for i = 1,5 do
		if position > 3 then
			turtle.down()
			if i == 5 then
				position = position - 4
			end
		else
			turtle.up()
			if i == 5 then
				position = position + 4
			end
		end
	end
end
--  Same as change postion but creates blocks along the way (Max amount is 3)
local function changePositionBlocks(amount)  
	local completed = 0
	turtle.turnLeft()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	for i=1,3 do
		turtle.forward()
		if completed ~= amount then
			turtle.turnRight()
			redstone.setOutput("front",true)
			os.sleep(0.1)
			redstone.setOutput("front",false)
			turtle.turnLeft()
			completed = completed + 1
		end
	end
	turtle.forward()
	turtle.turnRight()
	turtle.forward()
	turtle.forward()
	if getFloor() == 1 then
		position = math.fmod((position + 1),4)
	else
		position = math.fmod((position + 1),4) + 4
	end

end

local function gotoPosition(pos)
	if getFloor(pos)~=getFloor()  then
		changeFloor()
	end
	while position ~= pos do
		changePosition()
	end
end


local function collectBlocks() 
	gotoPosition(2)
	for i =1,3 do
		turtle.up()
	end
	for i=1,3 do 
		turtle.turnLeft()
		turtle.forward()
		turtle.turnRight()
		for i=1,3 do
			turtle.forward()
			turtle.suckUp()
		end
		turtle.forward()
		turtle.turnRight()
		turtle.forward()
	end
	for i=1,3 do 
		turtle.down()
	end
	position = 1
end

local function createBlocks(amount)
	local toCreate = amount
	local created = 0
	gotoPosition(6)
	while toCreate > 0 do
		checkFuel()
		if created == 9 then
			collectBlocks()
			gotoPosition(6)
			created = 0
		end
		changePositionBlocks(math.min(toCreate,3))
		toCreate = toCreate - 3
		created = created + 3
	end
	collectBlocks()
end

local function createIngots(amount)
	local created = 0
	gotoPosition(0)
	turtle.turnLeft()
	turtle.forward()
	turtle.turnRight()
	while created~=amount do
		redstone.setOutput("front",true)
		os.sleep(0.1)
		redstone.setOutput("front",false)
		turtle.down()
		os.sleep(5)
		turtle.suck()
		turtle.up()
		created = created + 1
	end
	turtle.turnRight()
	turtle.forward()
	turtle.turnLeft()
end

local function collectExcess(excess)
	gotoPosition(2)
	redstone.setOutput("front",true)
	os.sleep(0.1)
	redstone.setOutput("front",false)
	local amount = peripheral.call("front","getTanks","front")[1]["amount"]
	while amount ~= 0 do
		os.sleep(2)
		amount = peripheral.call("front","getTanks","front")[1]["amount"]
	end
	turtle.turnLeft()
	turtle.forward()
	turtle.turnRight()
	turtle.down()
	tank.suck()
	turtle.up()
	turtle.turnRight()
	turtle.forward()
	turtle.turnLeft()
end

local function dropAmount(amount)
	local currentDropped = 0
	for i=1,16 do
		if currentDropped == amount then
			break
		end
		turtle.select(i)
		local ic = turtle.getItemCount(i)
		local td = math.min(ic,amount-currentDropped)
		turtle.drop(td)
		currentDropped = currentDropped + td
	end
end

local function waitForSmeltery(sc)
	local bool = false
	while not bool do
		sleep(0)
		os.startTimer(1)
		os.pullEvent("timer")
		bool = true
		for i=0,sc.getSizeInventory() do
			bool = bool and sc.getStackInSlot(i)==nil
		end
	end
end
--Called while in front of controller
local function checkLavaTank()
	turtle.turnLeft()
	turtle.forward()
	turtle.turnRight()
	local amount = peripheral.call("front","getTanks","front")[1]["amount"]
	if amount < 1000 then
		modem.transmit(1224,1,"Smeltery needs lava")
		while amount < 3000 do
			os.startTimer(1)
			os.pullEvent("timer")
			amount = peripheral.call("front","getTanks","front")[1]["amount"]
			sleep(60)
		end
	end
end
-- Start

--Step 1, load smeltery
--Step 2, Repeatedly check smeltery until it is empty 
--Step 2.5, if you have more, continue loading
--Step 3, Once done loading go to drain and get liquid quantity, calculate blocks etc.
--Step 4, If you need to get blocks, go to second floor and start block creation
--Step 5, return to first floor and collect blocks, if you have more to make repeat 4
--Step 6, Create ingots and collect them (one drain will do)
--Step 7, Drop off ingots... somewhere
--Step 8, Return to controller

step = 1
checkFuel()
local sc = peripheral.wrap("front")
local scSize = sc.getSizeInventory()
local itemCount = 0
for i=1,16 do
	itemCount = itemCount + turtle.getItemCount(i)
end
while itemCount ~= 0 do
	local drop = math.min(scSize,itemCount)
	dropAmount(drop)
	itemCount = itemCount - drop
	waitForSmeltery(sc)
	checkLavaTank()
end
modem.transmit(1224,1,"Finished meltdown")
step = 3
turtle.up()
turtle.turnLeft()
turtle.forward()
turtle.forward()
turtle.turnRight()
turtle.forward()
position = 0

local amount = peripheral.call("front","getTanks","front")[1]["amount"]

local blocks,ingots,excess = blocks(amount,currentLiquid)
step = 4
checkFuel()
modem.transmit(1224,1,"Obtained ".. blocks.." blocks of "..args[1])
if blocks > 0 then createBlocks(blocks) end
step = 6
checkFuel()
if ingots > 0 then createIngots(ingots) end
checkFuel()
if excess > 0 then collectExcess(excess) end
gotoPosition(0)
turtle.back()
turtle.turnRight()
turtle.forward()
turtle.forward()
turtle.turnLeft()
turtle.down()
modem.transmit(1224,1,"Smelting Complete")
--drop off somewhere