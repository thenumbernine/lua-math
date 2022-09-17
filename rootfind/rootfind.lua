--[[
args:
	x0 = start
	f = table of function and subsequent derivatives
	step = step function method. default newton
	epsilon = how small steps must get before stopping iteration. default 0
	norm = norm used for comparing epsilon. default math.abs
	maxiter = max iterations
--]]
local map = require 'table.map'
return function(args)
	local x = args.x0
	local fx = map(args.f, function(f) return f(x) end)
	local epsilon = args.epsilon or 0
	local step = args.step or require 'rootfind.step.newton'
	local norm = args.norm or math.abs
	for i=1,args.maxiter do
		local oldx = x
		x = step(x, unpack(fx))
		if norm(x - oldx) < epsilon then break end 
	end
	return x
end
