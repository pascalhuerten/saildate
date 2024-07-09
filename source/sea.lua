import "CoreLibs/graphics"
import "CoreLibs/object"
import "utils/utils"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry
class("sea").extends()

function sea:init()
    self.intensity = 0
    self.amplitude = 2
    self.period = self.amplitude * 70
    self.speed = 0
end

function sea:update(seaSpeed)
    self.intensity = seaSpeed or self.intensity
    self.animationCounter = self.animationCounter
    self.speed = self.speed + 0.2 + deltaTime * self.intensity * 50
end

-- Refactored methods in the sea class
function sea:drawBackgroundWaves()
    local y = 197

    -- Draw first layer of waves
    gfx.drawSineWave(0, y, 450, y, self.amplitude, self.amplitude, self.period, self.speed * 0.8)
    gfx.drawSineWave(0, y+1, 450, y+1, self.amplitude, self.amplitude, self.period, self.speed * 0.8)
    self:drawFilledSineWave(0, y+2, 200, 450, y+2, 200, self.amplitude, self.amplitude, self.period, self.speed * 0.8, gfx.kColorWhite)
end

function sea:drawForegroundWaves()
    local y = 205

    -- Draw first layer of waves
    gfx.drawSineWave(-40, y, 450, y, self.amplitude, self.amplitude, self.period, self.speed)
    gfx.drawSineWave(-40, y+1, 450, y+1, self.amplitude, self.amplitude, self.period, self.speed)
    -- gfx.drawSineWave(-40, y+2, 450, y+2, self.amplitude, self.amplitude, self.period, self.speed)
    gfx.drawSineWave(-40, y, 450, y, self.amplitude, self.amplitude, self.period, self.speed+20)
    gfx.drawSineWave(-40, y+1, 450, y+1, self.amplitude, self.amplitude, self.period, self.speed+20)
    self:drawFilledSineWave(-40, y+2, 200, 450, y+2, 200, self.amplitude, self.amplitude, self.period, self.speed+20, gfx.kColorWhite)
    
    -- Draw second layer of waves
    gfx.drawSineWave(-80, y+8, 450, y+8, self.amplitude, self.amplitude*1.3, self.period, self.speed * 1.2)
    gfx.drawSineWave(-80, y+9, 450, y+9, self.amplitude, self.amplitude*1.3, self.period, self.speed * 1.2)
    gfx.drawSineWave(-80, y+8, 450, y+8, self.amplitude, self.amplitude*1.3, self.period, self.speed * 1.2+15)
    gfx.drawSineWave(-80, y+9, 450, y+9, self.amplitude, self.amplitude*1.3, self.period, self.speed * 1.2+15)

    -- Draw third layer of waves
    gfx.drawSineWave(-120, y+22, 450, y+22, self.amplitude, self.amplitude * 1.8, self.period, self.speed * 1.5)
    gfx.drawSineWave(-120, y+23, 450, y+23, self.amplitude, self.amplitude * 1.8, self.period, self.speed * 1.5)
    gfx.drawSineWave(-120, y+22, 450, y+22, self.amplitude, self.amplitude * 1.8, self.period, self.speed * 1.5+10)
    gfx.drawSineWave(-120, y+23, 450, y+23, self.amplitude, self.amplitude * 1.8, self.period, self.speed * 1.5+10)
end


function sea:drawFilledSineWave(x1, y1, c1, x2, y2, c2, a1, a2, p, ps, color)
    assert(p > 0, "period must be > 0")

	local r = math.deg(math.atan2((y2 - y1), (x2 - x1)))

    local PI = 3.141592653589793
    local TWO_PI = 6.283185307179586

    -- low precision fast sine approximation
    local function lp_sin(x)
        if x < -PI then
            x += TWO_PI
        elseif x > PI then
            x -= TWO_PI
        end

        if x < 0 then
            return 1.27323954 * x + 0.405284735 * x * x
        else
            return 1.27323954 * x - 0.405284735 * x * x
        end
    end

    local points = {}
    local xspacing = 3
    local w = geom.distanceToPoint(x1, y1, x2, y2)

    local theta = 0
    if ps ~= nil then
        theta = TWO_PI * ((ps % p) / p)
    end

    local delta = (TWO_PI / p) * xspacing

    local x = 0
    local y = lp_sin(theta) * a1

    points[#points+1] = x
    points[#points+1] = y

    for _ = xspacing, w, xspacing do

        local ia = a1 + (a2 - a1) * (x / w)

        y = lp_sin(theta) * ia

        points[#points+1] = x
        points[#points+1] = y

        x += xspacing
        theta += delta
        if theta > TWO_PI then theta = theta - TWO_PI end
    end

    -- calculate the final point
    theta = TWO_PI * ((w % p) / p)
    y = lp_sin(theta) * a2
    points[#points+1] = w
    points[#points+1] = y

    -- Extend the shape down to yEnd
    points[#points+1] = w
    points[#points+1] = c1 -- Adjust to reach the bottom
    points[#points+1] = 0
    points[#points+1] = c2 -- Adjust to reach the bottom

    --Close the shape
    points[#points+1] = points[1]
    points[#points+1] = points[2]

    local poly = geom.polygon.new(table.unpack(points))
    local af = geom.affineTransform.new()

    if r ~= 0 then
        af:rotate(r)
    end

    af:translate(x1, y1)
    af:transformPolygon(poly)

    -- Fill the polygon instead of drawing its outline
    gfx.pushContext() -- Creating a new graphics context
    gfx.setColor(color)
    gfx.fillPolygon(poly)
    gfx.popContext() -- All modifications done during the context get removed
end