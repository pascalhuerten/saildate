import "CoreLibs/graphics"
import "CoreLibs/object"
import "utils/utils"

local gfx <const> = playdate.graphics

class("wind").extends()

function wind:init()
    self.windElements = {}
    self.windSpeed = 0
    self.windElementCount = 6
    self.screenHeight = 180
    self.minSpacing = 5
    self.possibleYPositions = {}
    self.occupiedPositions = {}
    self.animationCounter = 0

    -- Calculate possible y positions
    for pos = 0, self.screenHeight, self.minSpacing do
        table.insert(self.possibleYPositions, pos)
        self.occupiedPositions[pos] = false
    end

    -- Initialize wind elements with random free y positions
    for i = 1, self.windElementCount do
        local posY = self:findFreeY() -- Use findFreeY to get a random free position
        if not posY then
            posY = math.random(5, self.screenHeight) -- Fallback to random if no free positions
        else
            self.occupiedPositions[posY] = true -- Mark the position as occupied
        end
        table.insert(self.windElements, {
            x = math.random(0, 1200),
            y = posY,
            baseSpeed = math.random(1, 4) / 4 * 2 + 3
        })
    end
end

-- Function to find a random free y position
function wind:findFreeY()
    self:shuffle(self.possibleYPositions) -- Shuffle to ensure random selection
    for _, posY in ipairs(self.possibleYPositions) do
        if not self.occupiedPositions[posY] then
            return posY + 5 -- Add 5 to ensure the wave is visible
        end
    end
    return nil -- In case all positions are occupied
end

-- Function to shuffle a table
function wind:shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

function wind:update(windSpeed)
    self.windSpeed = windSpeed or self.windSpeed -- Update wind intensity if provided

    for i, element in ipairs(self.windElements) do
        local speed = element.baseSpeed * self.windSpeed * -2 -- Adjust speed based on intensity
        if speed == 0 then
            speed = 2
        end
        element.x = element.x + (speed * 5 * deltaTime)
        

        -- Recycle element if it moves off the right side of the screen
        if speed > 0 and element.x > 400 then
            element.x = math.random(-810, -10)
            -- Mark the element's current position as free before finding a new one
            self.occupiedPositions[element.y] = false
            local newY = self:findFreeY()
            if newY then
                element.y = newY
                self.occupiedPositions[newY] = true -- Mark the new position as occupied
            end
        -- Recycle element if it moves off the left side of the screen
        elseif speed < 0 and element.x < -10 then
            element.x = math.random(400, 1200)
            -- Mark the element's current position as free before finding a new one
            self.occupiedPositions[element.y] = false
            local newY = self:findFreeY()
            if newY then
                element.y = newY
                self.occupiedPositions[newY] = true -- Mark the new position as occupied
            end
        end
    end
end

function wind:draw()
    self.animationCounter = self.animationCounter + deltaTime * 10
    for i = 1, self.windElementCount do
        local element = self.windElements[i]
        if element then
            local x1 = element.x
            local y1 = element.y + math.sin(self.animationCounter + element.baseSpeed) * 3
            local x2 = x1 + 5
            local y2 = element.y + 2
            -- left wing
            gfx.drawLine(x1, y1, x2, y2)
            -- right wing
            gfx.drawLine(x1+5, y2, x2+5, y1)
        end
    end
end
