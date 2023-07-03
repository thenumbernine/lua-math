local function euler(x, t, dt, dxdt)
    return x + dt * dxdt(x,t)
end
return euler
