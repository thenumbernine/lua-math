local class = require 'ext.class'

local Complex = class()

function Complex:init(re,im)
    if type(re) == 'table' and getmetatable(re) == Complex then
        local c = re
        self.re = c.re
        self.im = c.im
    else
        if re == nil then re = 0 end
        if im == nil then im = 0 end
        self.re = tonumber(re) or error("passed complex a bad real value "..tostring(re))
        self.im = tonumber(im) or error("passed complex a bad imag value "..tostring(im))
    end
end

function Complex.__unm(a)
    return Complex(-a.re, -a.im)
end

function Complex.__eq(a,b)
    -- 5.1 lua eq's only work if both objects are tables
    if type(a) == 'number' then a = Complex(a,0) end
    if type(b) == 'number' then b = Complex(b,0) end
    return a.re == b.re and a.im == b.im
end

function Complex.__add(a,b)
    if type(a) == 'number' then a = Complex(a,0) end
    if type(b) == 'number' then b = Complex(b,0) end
    return Complex(a.re + b.re, a.im + b.im)
end

function Complex.__sub(a,b)
    if type(a) == 'number' then a = Complex(a,0) end
    if type(b) == 'number' then b = Complex(b,0) end
    return Complex(a.re - b.re, a.im - b.im)
end

function Complex.__mul(a,b)
    if type(a) == 'number' then a = Complex(a,0) end
    if type(b) == 'number' then b = Complex(b,0) end
    return Complex(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re)
end

-- a / b = a * b^-1
function Complex.__div(a,b)
    if type(a) == 'number' then a = Complex(a,0) end
    if type(b) == 'number' then b = Complex(b,0) end
    return a * b:inv()
end

-- a^b = exp(log(a^b)) = exp(b log(a))
function Complex.__pow(a,b)
    if type(a) == 'number' then a = Complex(a,0) end
    if type(b) == 'number' then b = Complex(b,0) end
    return (a:log() * b):exp()
end
Complex.pow = Complex.__pow

function Complex:conj()
    return Complex(self.re, -self.im)
end

function Complex.real(c)
    if type(c) == 'number' then return c end
    return c.re
end

function Complex.imag(c)
    if type(c) == 'number' then return 0 end
    return c.im
end

-- norm is a * conj(a)
function Complex:norm()
    return self.re * self.re + self.im * self.im
end

function Complex:inv()
    return self:conj() * (1/self:norm())
end

function Complex:exp()
    local mag = math.exp(self.re)
    return Complex(mag * math.cos(self.im), mag * math.sin(self.im))
end

function Complex:log()
    return Complex(math.log(self:abs()), self:arg())
end

function Complex.sqrt(c)
    if type(c) == 'number' then 
        if c >= 0 then 
            return math.sqrt(c) 
        else 
            return Complex(0,math.sqrt(-c)) 
        end
    end
    return c ^ .5
end

function Complex.abs(c)
    if type(c) == 'number' then return math.abs(c) end
    return math.sqrt(c:norm())
end

function Complex:arg()
    return math.atan2(self.im, self.re)
end

function Complex:__tostring()
    if self.im == 0 then 
        return tostring(self.re)
    elseif self.im > 0 then
        return self.re..'+i'..self.im
    else
        return self.re..'-i'..math.abs(self.im)
    end
end

function Complex.__concat(a,b) return tostring(a) .. tostring(b) end

return Complex
