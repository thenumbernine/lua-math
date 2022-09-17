--[[
cubic requires a solver of its own,
so will that solver have convergence better than a non cubic solver?

		c0 +   c1 x +   c2 x^2 + c3 x^3 = f(x)    -- 0th
		       c1   + 2 c2 x + 3 c3 x^2 = f'(x)   -- 1st
		              2 c2   + 6 c3 x   = f''(x)  -- 2nd
		                       6 c3     = f'''(x) -- 3rd
when cs are reversed this becomes upper diagonal
which is easily solvable

[1 x  x^2  x^3   x^4][c0]   [f   ]
[0 1 2x   3x^2  4x^3][c1]   [f'  ]
[0 0 2    6x   12x^2][c2] = [f'' ]
[0 0 0    6    24x  ][c3]   [f''']
[0 0 0    0    24   ][c4]   [f'4 ]

in general a_uv c_v = d^u/dx^u[f]
for a_uv = 
	u <= v : 
		u == v : u!
		u == v - 1 : v! x
		u == v - 2 : v!/2 x^2
		u == v - m : v!/m! x^m
	otherwise : 0
from there...
for i = n to 0:
	c_i =  (d^i/dx^i[f] - (sum j=i+1 to n of a_ij c_j)) / a_ii
that gives you the n'th degree polynomial to approximate f
next solve the root. helps if n is odd to guarantee a root.

cubic newton convergence:
y = c0 + c1 x + c2 x^2 + c3 x^3
y' = c1 + 2 c2 x + 3 c3 x^2
y'' = 2 c2 + 6 c3 x
y y'' = 2 c0 c2 
		     + (2 c1 c2 + 6 c0 c3) x
		  + (2 c2 + 6 c1 c3) x^2 
		  + (2 c2 c3 + 6 c2 c3) x^3 
		  + 6 c3^2 x^4
y'^2 = c1^2 
		 + 4 c1 c2 x
		 + (4 c2^2 + 6 c1 c3) x^2
		 + 12 c2 c3 x^3
		 + 9 c3^2 x^4
...compare
]]--
return function()
	error 'todo'
end
