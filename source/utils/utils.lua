function clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function lerp(a, b, t)
    return a + (b - a) * t
end