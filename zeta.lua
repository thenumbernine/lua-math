--[[ https://dlmf.nist.gov/25.2#E9
local choose = require 'math.choose'
return function(s)
	local N = 10
	local n = 10
	local sum = 0
	for k=1,N do
		sum = sum + 1/k^s + N^(1-s) / (s-1) - N^(-s)/2 
	end
	for k=1,n do
		sum = sum + choose(s+2*k-2, 2*k-1) * B[2*k] / (2*k) * N^(1-s-2*k)
	end
	return sum
end
--]]

-- https://math.stackexchange.com/questions/490308/show-how-to-calculate-the-riemann-zeta-function-for-the-first-non-trivial-zero
-- takes forever
return function(s)
	local sum = 0
	for n=1,100 do
		local absstep = 1 / n^s 
		local step = (n%2==0 and -1 or 1) * absstep 
		sum = sum + step
		print(n, sum)
		if absstep == 0 then
			return 1 / (1 - 2 ^ (1 - s)) * sum
		end
	end
end
