--Apis
os.loadAPI("rPeripheral")
os.loadAPI("hf")

--vars
local p = {} -- all peripherals indexed by name, need functions for finding p by type
local utils = {} -- utility peripherals
local inventory = {} -- list of all items in system
local map = {} -- Must be serializeable map[name] = {adjNames?}
local glassesID  = 1311
local facing = 0
-- south = 0 +z
-- west = 1 -x
-- north = 2 -z
-- east = 3 +z
--Load peripherals
local con = peripheral.wrap("back")


--functions
local function opposite(dir)
	if dir=="west" then return "east"
	elseif dir =="east" then return "west"
	elseif dir=="north" then return "south"
	elseif dir=="south" then return "north"
	elseif dir=="up" then return "down"
	elseif dir=="down" then return "up"
	end
end

local function directionToString(dir)
	if dir == 0 then return "south"
	elseif dir == 1 then return "west"
	elseif dir == 2 then return "north"
	elseif dir == 3 then return "east"
	end
end

local function direction(str)
	if str=="left" then 
		if (facing-1)<0 then
			return directionToString(3)
		else
			return directionToString(facing-1)
		end
	elseif str=="right" then return directionToString(math.fmod(facing+1,4))
	elseif str=="up" then return "up" 
	elseif str=="down" then return "down" 
	end
end

local function locateGlasses()
	local glassesIndex
	local glassesChest
	for k,v in pairs(p) do
		for i=0,v.getSizeInventory()-1 do
			local stack = v.getStackInSlot(i)
			if stack ~=	nil and stack.id == glassesID then
				return i,v
			end
		end
	end
	return nil,nil
end

local function resetMarks()
	for k,v in pairs(p) do
		if v.mark then
			v.mark = false
		end
	end
end

-- wikipedia is tasty
local function breadthFirstSearch(start,finish)
	local Q = {}
	table.insert(Q,{start,})
	start.mark = true
	while next(Q) ~= nil do
		local t = table.remove(Q,1)
		if hf.sameTable(t[#t],finish) then
			resetMarks()
			return t
		end
		for k,v in pairs(t[#t].adj) do
			if v ~= nil then
				if not v.mark then
					v.mark = true  
					local temp = hf.copyTable(t)
					table.insert(temp,v)
					table.insert(Q,temp)
				end
			end
		end
	end
	resetMarks()
	return nil
end

local function isChest(periph)
	if periph.getSizeInventory() >=27 then
		return true
	end
	return false
end

local function path2dir(p)
	local path = {}
	local i = 1
	while i ~= #p do
		local a,b = p[i],p[i+1]
		for k,v in pairs(p[i].adj) do
			if hf.sameTable(v,p[i+1]) then
				table.insert(path,k)
				break
			end
		end
		i = i+1
	end
	return path
end

local function moveAlong(start,path,stack)
	local current = start
	for k,v in ipairs(path) do
		if current == nil then
		--	print("WHY IS CURRENT NIL???")
		end

		for i=0,current.getSizeInventory()-1 do
			local cStack = current.getStackInSlot(i)
			if cStack ~= nil and cStack.id == stack.id and cStack.dmg == stack.dmg and cStack.qty == stack.qty then
				local info = current.push(v,i,stack.qty)
				if info ~= 0 then
				--	print("Glasses moved successfully to "..v)
				end
				break
			end
		end
		if k ~= #path then -- If we didn't finish the path
			--print("Connections:")
			--for k,v in pairs(current.adj) do
			--	print(k..":"..tostring(v.name))
			--end
			--print("Next current is in direction "..v.." adj in that dir is "..tostring(current.adj[v].name))
			current = current.adj[v]
		end
	end
end

local function saveMap()
	local file = fs.open("map","w")
	file.write(textutils.serialize(map))
	file.close()
	print("Map saved")
end

local function findPeripheralByName(name)
	for k,v in pairs(p) do
		if v.name == name then
			return v
		end
	end
	return nil
end

local function loadMap()
	if fs.exists("map") then
		print("Loading map...")
		local file = fs.open("map","r")
		local text = file.readAll()
		map = textutils.unserialize(text)
		for k,v in pairs(map) do
			local periph = findPeripheralByName(k)
			local tAdj = {}
			for i,j in pairs(v) do
				local periph2 = findPeripheralByName(j)
				tAdj[i] = periph2
			end
			periph.adj = tAdj
		end
		file.close()
		print("Map successfully loaded")
		return true
	else
		return false
	end
end

local function calibrateMap()
	print([[
	Begin calibration
	How many inventories are in your wall?
	]])
	local finalCount,count = 18,1

	local indx,chest = locateGlasses() -- run once for first chest
	print(tostring(chest))
	local compass = "",""
	for i=1,4 do
		if i==1 then compass = "up"
		elseif i==2 then compass = "down"
		elseif i==3 then compass = direction("left")
		elseif i==4 then compass = direction("right")
		end
		chest.push(compass,indx,1)
		local indx2,chest2 = locateGlasses()
		if indx2 == nil then
			chest.pull(compass,0,1)
			chest.adj[compass] = nil
		else
			--print("Mapping "..compass.." of "..chest.name.." to "..chest2.name)
			chest.adj[compass] = chest2
			chest.pull(compass,indx2,1)
		end
	end
	chest.mapped = true

		
	while count ~= finalCount do --get rest of chests
		for k,v in pairs(p) do 
			if not v.mapped then
				indx,chest = locateGlasses()
				dir,compass,canPath = "","",true
				if chest ~= nil then
				--	print("Finding path between "..chest.name.." and "..v.name)
					local path = breadthFirstSearch(chest,v)
					if path == nil then
						canPath = false
					else
						v.mapped = true
						count = count + 1
						local path2 = path2dir(path)
						--hf.printTable(path2)
						moveAlong(chest,path2,chest.getStackInSlot(indx))
					end
					if canPath then
						for i=1,4 do -- Change this to handle floors
							if i==1 then compass = "up"
							elseif i==2 then compass = "down"
							elseif i==3 then compass = direction("left")
							elseif i==4 then compass = direction("right")
							end
							v.push(compass,indx,1)
							local indx2,chest2 = locateGlasses()
							if indx2 == nil then
								v.pull(compass,0,1)
								v.adj[compass] = nil
							else
								v.adj[compass] = chest2
								--print("Mapping "..compass.." of "..v.name.." to "..chest2.name)
								v.pull(compass,indx2,1)
							end
						end
					end
				else
					error("Something went wrong with mapping")
				end
			end
		end
	end
	print("AUTO-MAP COMPLETE")
	print("Creating Serializable map")
	for k,v in pairs(p) do
		local sAdj = {}
		for i,j in pairs(v.adj) do
			sAdj[i] = j.name
		end
		map[v.name]= sAdj
	end
	print("Serializable map created")
end

local function getOpenSlots(chest)
	local count = 0
	for i=0,chest.getSizeInventory()-1 do
		local stack = chest.getStackInSlot(i)
		if stack== nil then
			count = count + 1
		end
	end
	
	return count
end

local function getFirstStack(chest)
	for i=0,chest.getSizeInventory()-1 do
		local stack = chest.getStackInSlot(i)
		if stack ~= nil then
			return i,stack.qty
		end
	end
end

local function similar(a,b)
	local c = (math.abs(a-b)/((a+b)/2)) *100
	print(c)
	if c<10 then
		return true
	else
		return false
	end
end

local function balanceChest(chest,dir)
	print("Balancing chest:"..chest.name.." to "..dir)
	local ratio1 = getOpenSlots(chest)/chest.getSizeInventory() *100
	local ratio2 = getOpenSlots(chest.adj[dir])/chest.adj[dir].getSizeInventory()*100
	print(tostring(ratio1)..","..tostring(ratio2))
	while not similar(ratio1,ratio2) do
		if ratio1 < ratio2 then -- chest has more open slots
			local index,qty = getFirstStack(chest)
			chest.push(dir,index,qty)
		elseif ratio1 > ratio2  then-- the other thing
			local index,qty = getFirstStack(chest.adj[dir])
			print(index)
			chest.pull(dir,index,qty)
		end
		ratio1,ratio2 = (getOpenSlots(chest)/chest.getSizeInventory()),(getOpenSlots(chest.adj[dir])/chest.adj[dir].getSizeInventory())
	end
end

local function balanceChests()
	for k,v in pairs(p) do
		if isChest(v) then
			for i,j in pairs(v.adj) do
				if isChest(j) then
					balanceChest(v,i)
				end
			end
		end
	end
end

local function takeInventory()
	for k,v in pairs(p) do 
		for i=0, v.getSizeInventory()-1 do
			local data = v.getStackInSlot(i)--qty,dmg,id,name (name probably isn't unique),rawName(unique, but unrelated)
			if data ~= nil then
				if inventory[data.id] == nil then
					inventory[data.id] = {}
				end
				if inventory[data.id][data.dmg] == nil then
					inventory[data.id][data.dmg] = {}
				end
				inventory[data.id][data.dmg][1] = (inventory[data.id][data.dmg][1] or 0) + data.qty
				inventory[data.id][data.dmg][2] = data.name
			end
		end
	end
end
--start
print("Setting up first table...")
for k, v in pairs(con.getNamesRemote()) do
	if hf.stringStartsWith(v,"chat") or hf.stringStartsWith(v,"terminal_glasses_bridge") or hf.stringStartsWith(v,"pim") then
		utils[k] = rPeripheral.remoteWrap(v,con)
	else
		p[k] = rPeripheral.remoteWrap(v,con)
	end
	if v.getStackInSlot == nil and v.get ~= nil then
		v.getStackInSlot = function(i) get(i+1) end
	end
end
print("Complete")
if not loadMap() then
	calibrateMap()
	saveMap()
end
takeInventory()
for k,v in pairs(inventory) do
	for i,j in pairs(v) do
		print(j[2].." -> "..j[1])
	end
end
-- Next, search?