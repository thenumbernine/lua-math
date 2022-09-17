require 'ext'
local function printf(...)
	return print(string.format(...))
end

local Problem = class()

local Poly = class(Problem)
function Poly:init(...)
	self.coeffs = {...}
end
function Poly:f(x)
	local y = 0
	for i,c in ipairs(self.coeffs) do
		y = y * x + c
	end
	return y
end
function Poly:df(x)
	local dy = 0
	for i=1,#self.coeffs-1 do
		local c = self.coeffs[i]
		dy = dy * x + c * (#self.coeffs - i)
	end
	return dy
end
function Poly:d2f(x)
	local d2y = 0
	for i=1,#self.coeffs-2 do
		error 'todo'
		local c = self.coeffs[i]
		d2y = d2y * x + c * (#self.coeffs - i)
	end
	return d2y
end

local Sqrt = class(Problem)
Sqrt.name = 'sqrt'
Sqrt.c = 2
Sqrt.x0 = Sqrt.c
Sqrt.soln = math.sqrt(Sqrt.c)
function Sqrt:f(x) return x^2-self.c end
function Sqrt:df(x) return 2*x end
function Sqrt:d2f(x) return 2 end

-- hyperbolic does best, circle oscillates
local Sine = class(Problem)
Sine.name = 'pi'
Sine.x0 = 3
Sine.soln = math.pi
function Sine:f(x) return math.sin(x) end
function Sine:df(x) return math.cos(x) end
function Sine:d2f(x) return -math.sin(x) end

-- circle does best
local Exp = class(Problem)
Exp.name = 'log'
Exp.c = 2
Exp.x0 = Exp.c
Exp.soln = math.log(2)
function Exp:f(x) return math.exp(x) - self.c end
function Exp:df(x) return math.exp(x) end
function Exp:d2f(x) return math.exp(x) end

local problem = Exp()
--local problem = Sine()
--local problem = Sqrt()

local Solver = class()
Solver.maxiter = 10
function Solver:run(problem)
	self.problem = problem
	self.xs = table()
	local x = self.problem.x0
	self.xs:insert(x)
	for i=1,self.maxiter do
		local fx = self.problem:f(x)
		local dfx = self.problem:df(x)
		local d2fx = self.problem:d2f(x)
		x = self:iterate(x,fx,dfx,d2fx)
		self.xs:insert(x)
	end
	return self
end
function Solver:write(out)
	out = out or io.stdout
	for i,x in ipairs(self.xs) do
		out:write(string.format('%d %.50f\n',i,math.abs(x-self.problem.soln)))
	end
end
function Solver:print()
	print(self.name)
	self:write()
	print() 
end
function Solver:gnuplot()
	local datafilename = self.problem.name..'_'..self.name..'.txt'
	io.writefile(datafilename, self.xs:map(function(x,i)
		return ('%d\t%.50f'):format(i-1,x)
	end):concat('\n'))
	local errfilename = self.problem.name..'_'..self.name..'_err.txt'
	io.writefile(errfilename, self.xs:map(function(x,i)
		return ('%d\t%.50f'):format(i-1,math.abs(x-self.problem.soln))
	end):concat('\n'))
	return datafilename, errfilename
end


local Newton = class(Solver)
Newton.name = 'newton'
function Newton:iterate(...)
	return (require 'rootfind.step.newton')(...)
end

local CircleVerbose = class(Solver)
CircleVerbose.name = 'circleverbose'
function CircleVerbose:iterate(x,fx,dfx,d2fx)
	-- point on edge (at current state)
	local x1 = x
	local y1 = fx
	-- tangent at that point
	local tx = 1
	local ty = dfx
	-- normal (right angle to tangent)
	local nx = -ty
	local ny = tx
	-- unit normal
	local inl = 1/math.sqrt(nx*nx+ny*ny)
	local nnx = nx*inl
	local nny = ny*inl
	-- radius curvature
	local k = d2fx/(math.sqrt(1+dfx*dfx)^3)
	local r = 1/k
	-- circle center
	local cx = x1 + nnx * r
	local cy = y1 + nny * r
--[[
	print('x',x,'f',fx,'df',dfx,'d2f',d2fx)
	print('pt on curve',x1,y1)
	print('tangent',tx,ty)
	print('normal',nx,ny,'inv len',inl)
	print('unit normal',nnx,nny)
	print('curvature',k,'radius',r)
	print('center',cx,cy)
]]--
--[[
(cx-x1)^2 + (cy-y1)^2 = r^2
(cx-xn)^2 + (cy-0)^2 = r^2
cx - xn = +-sqrt(r^2 - cy^2)
xn = cx - +-sqrt(r^2 - cy^2)
]]--
	local mid = cx
	local inner = r*r - cy*cy
	--print('mid',mid,'inner',inner)
	if inner < 0 then return math.nan end
	local ofs = math.sqrt(inner)
	--print('ofs',ofs)
	local xn1 = mid + ofs
	local xn2 = mid - ofs
	if math.abs(x - xn1) < math.abs(x - xn2) then
		x = xn1
	else
		x = xn2
	end
	return x 
end

local Circle = class(Solver)
Circle.name ='circle'
function Circle:iterate(...)
	return (require 'rootfind.step.circle')(...)
end

Hyperbolic = class(Solver)
Hyperbolic.name = 'hyperbolic'
function Hyperbolic:iterate(...)
	return (require 'rootfind.step.hyperbola')(...)
end

local Parabolic = class(Solver)
Parabolic.name = 'parabolic'
function Parabolic:iterate(...)
	return (require 'rootfind.step.parabola')(...)
end


local Cubic = class(Solver)
Cubic.name = 'cubic'
function Cubic:iterate(...)
	return (require 'rootfind.step.cubic')(...)
end

local problems = table{
	Sqrt(),
	Sine(),
	Exp(),
}

local solvers = table{
	Newton(),
	CircleVerbose(),
	Circle(),
	Hyperbolic(),
	Parabolic(),
}

local plotlines = table()
plotlines:append{
	'set style data lines',
	'set term svg',
}
for _,problem in ipairs(problems) do
	local datafilenames = table()
	local errfilenames = table()
	for _,solver in ipairs(solvers) do
		solver:run(problem)
		local datafilename, errfilename = solver:gnuplot()
		datafilenames:insert(('%q'):format(datafilename))
		errfilenames:insert(('%q'):format(errfilename))
	end
	plotlines:insert('unset log y')
	plotlines:insert('set output "'..problem.name..'.svg"')
	plotlines:insert('plot '..datafilenames:concat(', '))
	plotlines:insert('set log y')
	plotlines:insert('set output "'..problem.name..'_err.svg"')
	plotlines:insert('plot '..errfilenames:concat(', '))
end
local plotfilename = 'plot.gnuplot'
io.writefile(plotfilename, plotlines:concat('\n')) 
os.execute('gnuplot '..plotfilename)

