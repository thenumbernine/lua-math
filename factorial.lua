local function factorial(n)
    assert(n >= 0)
    local prod = 1
    for i=1,n do
        prod = prod * i
    end
    return prod
end
return factorial
