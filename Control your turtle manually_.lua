print("Doing all the things :)")
local com = {
	[17]=turtle.forward,
	[30]=turtle.turnLeft,
	[32]=turtle.turnRight,
	[31]=turtle.back,
	[57]=turtle.dig,
	[16]=turtle.up,
	[18]=turtle.down,
	[38]=turtle.refuel,
	[2] = turtle.select,
	[3] = turtle.select,
	[4] = turtle.select,
	[5] = turtle.select,
	[6] = turtle.select,
	[7] = turtle.select,
	[8] = turtle.select,
	[9] = turtle.select,
	[10] = turtle.select,
	[11] = turtle.select,
	[12] = turtle.select,
	[13] = turtle.select,
	[14] = turtle.select,
	[79] = turtle.select,
	[80] = turtle.select,
	[81] = turtle.select,
	[21] = turtle.suckUp,
	[22] = turtle.suck,
	[23] = turtle.suckDown,
	[35] = turtle.dropUp,
	[36] = turtle.drop,
	[37] = turtle.dropDown,
	[44] = turtle.placeUp,
	[45] = turtle.place,
	[46] = turtle.placeDown
}
local err = {
	[17]= "I needz yummiez",
	[31]= "I needz yummiez",
	[16]= "I needz yummiez",
	[18]= "I needz yummiez",
	[38]= "That's not yummiez,silly",
	[21] = "Ecchi is bad!",
	[22] = "Ecchi is bad!",
	[23] = "Ecchi is bad!",
	[35] = "That thing is full",
	[36] = "That thing is full",
	[37] = "That thing is full",
	[44] = "I don't think I can do that",
	[45] = "I don't think I can do that",
	[46] = "I don't think I can do that"
	
}
while true do
	ev,code = os.pullEvent("key")
	if com[code] == nil then
		print("I don't understand :(")
	elseif code <=14 and code >=2 then
		com[code](code-1)
	elseif code >=79 and code <=81 then
		com[code](code-66)
	elseif not com[code]() and err[code] ~=nil then
		print(err[code])
	end
end