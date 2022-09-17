--[[
x_n+1 = x_n - f(x_n) / f'(x_n)
g(x) = x - f/f'
dg/dx = 1 - (f'^2 - f f'')/(f'^2)
		    = 1 - (1 - f f''/f'^2)
		 = f f'' / f'^2
so newton converges for |dg/dx| < 1
i.e. |f f'' / f'^2| < 1
i.e. |f f''| < |f'^2|
]]--
return function(x,fx,dfx)
	return x - fx / dfx
end

