local function rk4(x,t,dt,dxdt)
    local k1 = dxdt(x,t)
    local k2 = dxdt(x + k1 * (dt/2), t + dt/2)
    local k3 = dxdt(x + k2 * (dt/2), t + dt/2)
    local k4 = dxdt(x + dt * k3, t + dt)
    return x + (k1 + k2 * 2 + k3 * 2 + k4) * (dt / 6)
end
return rk4
