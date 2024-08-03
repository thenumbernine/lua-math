--[=[ recursive cached function calls.  faster than recursive calls of P(x,n)
local Ps = {
	codes = {},
}

local env = {
	Ps = Ps,
}

function Ps:buildcode(k, code)
	self.codes[k] = code
	self[k] = assert(load('local x = ... return '..code, nil, nil, env))
	return self[k]
end

Ps:buildcode(0, '1')
Ps:buildcode(1, 'x')

setmetatable(Ps, {
	__index = function(self,k)
		local code = ((2 * k - 1) / k)..' * x * Ps['..(k-1)..'](x) + '..(-(k - 1) / k)..' * Ps['..(k-2)..'](x)'
		return self:buildcode(k, code)
	end,
})

return Ps
--]=]

--[=[ inline code from recursive calls.  faster than recursive cached function calls.
local Ps = {
	codes = {},
}

function Ps:buildcode(k, code)
	self.codes[k] = code
	self[k] = assert(load('local x = ... return '..code))
	return self[k]
end

Ps:buildcode(0, '1')
Ps:buildcode(1, 'x')

setmetatable(Ps, {
	__index = function(self,k)
		local code = ((2 * k - 1) / k)..' * x * ('..self.codes[k-1]..') + '..(-(k - 1) / k)..' * ('..self.codes[k-2]..')'
		return self:buildcode(k, code)
	end,
})

return Ps
--]=]

-- [=[ using symmath for polynomial simplification and expression-tree caching.  faster than inline code for recursive calls.
local symmath = require 'symmath'
local frac = symmath.frac

local x = symmath.var'x'

local Ps = {
	exprs = {},
}

function Ps:buildcode(k, expr)
	self.exprs[k] = expr
	self[k] = expr:compile{x}
	return self[k]
end

Ps:buildcode(0, symmath.Constant(1))
Ps:buildcode(1, x)

setmetatable(Ps, {
	__index = function(self,k)
		-- invoke index operations ...
		local tmp1 = self[k-2]
		local tmp2 = self[k-1]
		local expr = frac(2 * k - 1, k) * x * self.exprs[k-1] - frac(k - 1, k) * self.exprs[k-2]
		return self:buildcode(k, expr())
	end,
})

return Ps
--]=]
