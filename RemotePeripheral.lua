--I made this super cool OO way of doing this, then I figured out what the wrap function really does :P

function remoteWrap(name,con) 
	if hf.tableContains(con.getNamesRemote(),name) then
		local methods = con.getMethodsRemote(name)
		local warpTable = {}
		for k,v in pairs(methods) do
			warpTable[v] = function(...)
				return con.callRemote(name,v,...)
			end
		end
		warpTable.name = name
		warpTable.connection = con
		warpTable.adj = {}
		return warpTable
	else
		return nil
	end
end

--Functions copied from Open CC Sensors, sensor API. Modified for RemotePeripheral API
local function waitForResponse( _id )
	while true do
		local event = {os.pullEvent()}
		if event[2] == _id then
			if event[1] == "ocs_success" then
				return event[3]
			elseif event[1] == "ocs_error" then
				return nil, event[3]
			end
		end
	end
end



function remoteWrapSensor(name,con)
	local wrappedTable = {}
		if con.getTypeRemote(name) == "sensor" then
			local periph = remoteWrap(name,con)
			for k,v in pairs(periph) do
				if type(k) == "string" and type(v) == "function" then
					wrappedTable[k] = function(...)
						local id = periph[k](...)
						if id == -1 then
							return false
						end
						return waitForResponse(id)
					end
				end
			end
			return wrappedTable
		else
			return nil, "not a sensor"
		end
end