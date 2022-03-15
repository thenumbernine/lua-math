local EulerMascheroni = require 'math.EulerMascheroni'
-- Gamma function 
local function gamma(z)
	--[[ only single precision accurate
	-- https://dlmf.nist.gov/5.11#E3
	local g = {
		[0] = 1,
		1/12,
		1/288,
		-139/51840,
		-571/2488320,
		163879/209018880,
		5246819/75246796800,
	}
	local sum = 0
	for k=0,6 do
		sum = sum + g[k] / z^k
	end
	return math.exp(-z) * z^z * math.sqrt(2 * math.pi / z) * sum
	--]]

	--[[ http://mathworld.wolfram.com/GammaFunction.html eqn 32
	local sum = 0
	local lastGamma
	for k=2,math.huge do
		sum = sum + (k%2==0 and 1 or -1) * zeta(k) * z^k / k
		local Gamma = 1 / (z * math.exp(EulerMascheroni * z - sum))
		if lastGamma then
			local deltaGamma = math.abs(Gamma - lastGamma)
			if deltaGamma == 0 then
				print(k, Gamma, deltaGamma)
				return Gamma
			end
		end
		lastGamma = Gamma
	end
	--]]

	-- [[ https://en.wikipedia.org/wiki/Lanczos_approximation

	local p = {
		[0] = 676.5203681218851,
		-1259.1392167224028,
		771.32342877765313,
		-176.61502916214059,
		12.507343278686905,
		-0.13857109526572012,
		9.9843695780195716e-6,
		1.5056327351493116e-7,
	}

	local epsilon = 1e-07
	
	if z < 0.5 then
		y = math.pi / (math.sin(math.pi*z) * gamma(1-z)) -- Reflection formula 
	else
		z = z - 1
		x = 0.99999999999980993
		for i=0,#p do
			x = x + p[i] / (z+i+1)
		end
		t = z + #p + 0.5
		y = math.sqrt(2*math.pi) * t^(z + 0.5) * math.exp(-t) * x
	end
	return y
	--]]
end

return gamma
