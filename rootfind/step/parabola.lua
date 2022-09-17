--[[
parabolic solver...
... constrain at point ...
ax^2 + bx + c = f(x)
2ax + b = f'(x)
2a = f''(x)
... build poly
a = 1/2 f''
b = f' - x f''
c = f - x (f' - x f'') - 1/2 x^2 f''
		= f - x f' + 1/2 x^2 f''
... find roots
x(n+1) = 1/(2a) (-b +- sqrt(b^2 - 4ac)) for a,b,c @ x(n)

the next question is convergence rate & condition
if one solver wont converge or will slowly
can we create a better solver to extrapolate the first?
]]--

return function(x,fx,dfx,d2fx)
	local a = .5 * d2fx
	local b = dfx - x * d2fx
	local c = fx + x * (-dfx + x * .5 * d2fx)
	local inner = b * b - 4 * a * c
	if inner < 0 then return math.nan end 
	local ofs = math.sqrt(inner) / (2 * a)
	local mid = -b / (2 * a)
	local xn1 = mid - ofs
	local xn2 = mid + ofs
	if math.abs(xn1 - x) < math.abs(xn2 - x) then
		return xn1
	else
		return xn2
	end
end
