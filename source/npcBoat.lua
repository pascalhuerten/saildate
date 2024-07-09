import "CoreLibs/graphics"
import "CoreLibs/object"
import "utils/utils"

local gfx <const> = playdate.graphics
class("npcBoat").extends()

function npcBoat:init(x, y, speed)
	self.x = x
	self.initialX = self.x
	self.y = y
	self.initialY = self.y
	self.rotation = 0
	self.speed = speed
	self.amplitude = 0.5
	self.initialRotation = self.rotation
	self.boatImage = gfx.image.new('images/npcBoat.png')
	self.animationCounter = 0
	self.hide = false
end

function npcBoat:update()

	self:animate()
end

function npcBoat:animate()
    -- Increment the counter by deltaTime
    -- Adjust the multiplier as needed to control the speed of the animation
    self.animationCounter = self.animationCounter + deltaTime * (self.speed + 0.2) * 2

	local localAmplitude = self.amplitude + self.speed
    -- Oscillate position around an initial value using the counter
    self.y = self.initialY + math.sin(self.animationCounter + 0.5 * math.pi) * localAmplitude / 2
	-- Assuming self.speed is already defined and ranges from 0 to 1

	-- Calculate target position based on speed
	local targetX = self.x - self.speed

	-- Oscillate position around an initial value using the counter for swim effect
	self.x = self.x + math.cos(self.animationCounter) * localAmplitude / 2

	-- Smoothly ease the boat's x position towards the target position
	-- Adjust the easing factor (0.1 in this example) to control the smoothing speed
	self.x = lerp(self.x, targetX, 0.9)

    -- Oscillate rotation around an initial value using the counter
    self.rotation = self.initialRotation + math.sin(self.animationCounter) * localAmplitude / 2 -- Smaller amplitude for rotation
end

function npcBoat:draw()
    self.boatImage:draw(self.x, self.y, gfx.kImageFlippedX)
end