return function(x,fx,dfx,d2fx)
--[[
(cx-x1)^2 + (cy-y1)^2 = r^2
(cx-xn)^2 + (cy-0)^2 = r^2
cx - xn = +-sqrt(r^2 - cy^2)
xn = cx - +-sqrt(r^2 - cy^2)
]]--
	local mid = x - dfx/d2fx * (dfx*dfx + 1)
	local inner = (dfx*dfx + 1)^3/(d2fx^2) - (fx + (dfx*dfx + 1)/d2fx)^2
	if inner < 0 then return math.nan end
	local ofs = math.sqrt(inner)
	local xn1 = mid - ofs
	local xn2 = mid + ofs
	if math.abs(x - xn1) < math.abs(x - xn2) then
		x = xn1
	else
		x = xn2
	end
	return x
end
