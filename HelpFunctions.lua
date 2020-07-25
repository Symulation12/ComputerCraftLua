function tableContains(t,value)
	for k,v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end


function printTable(t)
	for k,v in pairs(t) do
		print(k..":"..tostring(v))
	end
end

function copyTable(t)
	local copy = {}
	for k,v in pairs(t) do
		copy[k] = v
	end
	return copy
end

 -- Lua users wiki is cool
function stringStartsWith(str,test)
	return string.sub(str,1,string.len(test))==test
end

function convertrgid(id)
	dmg = math.floor(id/32768)
	idx = math.fmod(id,32768)
	return idx,dmg
end

function sameTable(t1,t2)
	if t1 == nil or t2 == nil then
		if t1 == nil and t2 == nil then
			return true
		end
		return false
	end
	local same = true
	for k,v in pairs(t1) do 
		if t1[k] ~= t2[k] then
			same = false
		end
	end
	return same
end