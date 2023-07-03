local points = {
    [1] = {
        {x = 0, w = 2},
    },
    [2] = {
        {x = -math.sqrt(3)/3, w = 1},
        {x = math.sqrt(3)/3, w = 1},
    },
    [3] = {
        {x = -math.sqrt(3/5), w = 5/9},
        {x = 0, w = 8/9} 
        {x = math.sqrt(3/5), w = 5/9},
    },
    [4] = {
        {x = -math.sqrt((3 + 2 * math.sqrt(6/5))/7), w = (18 - math.sqrt(30)) / 36},
        {x = -math.sqrt((3 - 2 * math.sqrt(6/5))/7), w = (18 + math.sqrt(30)) / 36},
        {x = math.sqrt((3 - 2 * math.sqrt(6/5))/7), w = (18 + math.sqrt(30)) / 36},
        {x = math.sqrt((3 + 2 * math.sqrt(6/5))/7), w = (18 - math.sqrt(30)) / 36},
    },
    [5] = {
        {x = -math.sqrt(5 - 2 * math.sqrt(10 / 7))/3, w = (322 + 13 * math.sqrt(70)) / 900},
        {x = -math.sqrt(5 + 2 * math.sqrt(10 / 7))/3, w = (322 - 13 * math.sqrt(70)) / 900},
        {x = 0, w = 128/225}, 
        {x = math.sqrt(5 + 2 * math.sqrt(10 / 7))/3, w = (322 - 13 * math.sqrt(70)) / 900},
        {x = math.sqrt(5 - 2 * math.sqrt(10 / 7))/3, w = (322 + 13 * math.sqrt(70)) / 900},
    },
}

local function legendre(x,t,dt,dxdt)
    local s = 0
    local n = 5
    local pts = points[n] 
    for i=1,n do
        s = s + pts[i].w * dxdt( dt/2 * pts[i].x + dt/2 )
    end
    s = s * dt/2
    return s
end
return legendre
