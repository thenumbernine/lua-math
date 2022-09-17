return function(x,fx,dfx,d2fx)
	local cx = x + dfx/d2fx*(dfx*dfx-1)
	local cy = fx + (dfx*dfx - 1)/d2fx
	local rho = (dfx^2-1)^3/(d2fx^2)
	local mid = cx
	local inner = rho + cy^2
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
