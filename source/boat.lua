import "CoreLibs/graphics"
import "CoreLibs/object"
import "utils/utils"

local gfx <const> = playdate.graphics
class("boat").extends()

function boat:init()
	self.x = playdate.display.getWidth() / 2
	self.initialX = self.x
	self.y = playdate.display.getHeight() / 2
	self.initialY = self.y
	self.rotation = 0
	self.speed = 0
	self.amplitude = 2
	self.initialRotation = self.rotation
	self.boatImage = gfx.image.new('images/boat.png')
	-- Get array of sail image frames from sail-0 to sail-4
	self.sailImages = {}
	self.sailImageCount = 6
	for i = 0, self.sailImageCount - 1 do
		self.sailImages[i] = gfx.image.new('images/sail-' .. i + 1 .. '.png')
	end
	self.currentSailFrame = 0
	self.animationCounter = 0
	self.attacking = false
	self.attackTargetX = 300
end

function boat:update()
	if(playdate.buttonJustPressed(playdate.kButtonUp)) then
		self.attacking = not self.attacking
	end
	-- Increase speed when crank is turned clockwise and vice versa
	local change, _ = playdate.getCrankChange()
	if self.attacking then
		self.attackTargetX = self.attackTargetX + change * 1.5
	else
		self.speed = self.speed + change / 360
	end
	self.attackTargetX = clamp(self.attackTargetX, 0, playdate.display.getWidth())
		-- Clamp speed to range min 0 and max 1
	self.speed = clamp(self.speed, 0, 1)

	-- Show sail image based on speed value
	self.currentSailFrame = math.floor(self.speed * (self.sailImageCount - 1) + 0.9)

	self:animate()
end

function boat:animate()
    -- Increment the counter by deltaTime
    -- Adjust the multiplier as needed to control the speed of the animation
    self.animationCounter = self.animationCounter + deltaTime * (self.speed + 0.2) * 3

	local localAmplitude = self.amplitude + self.speed
    -- Oscillate position around an initial value using the counter
    self.y = self.initialY + math.sin(self.animationCounter + 0.5 * math.pi) * localAmplitude / 2
	-- Assuming self.speed is already defined and ranges from 0 to 1
	
	-- Define screen bounds for the boat's movement
	local leftBound = playdate.display.getWidth() / 2 - 20
	local rightBound = playdate.display.getWidth() / 2 + 20

	-- Calculate target position based on speed
	local targetX = lerp(leftBound, rightBound, self.speed)

	-- Oscillate position around an initial value using the counter for swim effect
	self.x = self.x + math.cos(self.animationCounter) * localAmplitude / 2

	-- Smoothly ease the boat's x position towards the target position
	-- Adjust the easing factor (0.1 in this example) to control the smoothing speed
	self.x = lerp(self.x, targetX, 0.1)

    -- Oscillate rotation around an initial value using the counter
    self.rotation = self.initialRotation + math.sin(self.animationCounter) * localAmplitude / 2 -- Smaller amplitude for rotation
end

function boat:draw()
	if self.attacking then
		local ditherType = playdate.graphics.image.kDitherTypeBayer8x8 -- Define the dither type
		local offsetX = self.x - 200
		local offsetY = self.y - 120

		self.boatImage:drawFaded(offsetX, offsetY, 0.5, ditherType)
		self.sailImages[self.currentSailFrame]:drawFaded(offsetX, offsetY, 0.3, ditherType)
	else
		self.boatImage:drawRotated(self.x, self.y, self.rotation)
		self.sailImages[self.currentSailFrame]:drawRotated(self.x, self.y, self.rotation)
	end
end

function boat:drawTrajectory()
	if not self.attacking then
		-- If the boat is not attacking, returns early
		return
	end
	-- Draw a parabolic trajectory curve from the boat to the targetX
	local numPoints = 20
	local points = {}
	-- Define start and end positions
	local startX, startY = self.x-5, self.y + 72
	local endX, endY = self.attackTargetX, startY + 15
	-- Variable to control the height/intensity of the curve
	local curveHeight = 50 -- Adjust this value to control the curve's peak height
	for i = 1, numPoints do
		local t = i / numPoints
		local x = lerp(startX, endX, t)
		-- Adjust y calculation for a parabolic curve
		local y = startY + (endY - startY) * t - 4 * curveHeight * t * (1 - t)
		table.insert(points, x)
		table.insert(points, y)
	end


	-- Increase stroke width for a thicker line
	gfx.pushContext()
	gfx.setLineWidth(3)

	-- Number of iterations for drawing shifted polygons
	local numIterations = 4
	local shiftAmount = 2

	for iteration = 1, numIterations do
		-- Create a new set of points for this iteration, shifted to the right
		local shiftedPoints = {}
		for i = 1, #points, 2 do -- points is indexed from 1, and every point has an x (i) and y (i+1) component
			shiftedPoints[i] = points[i] + (shiftAmount * (iteration - 1)) -- Shift x coordinate
			shiftedPoints[i + 1] = points[i + 1] -- Keep y coordinate the same
		end

		-- Convert shifted points to a playdate.geometry.polygon object
		local shiftedPolygon = playdate.geometry.polygon.new(table.unpack(shiftedPoints))
		playdate.graphics.drawPolygon(shiftedPolygon)
	end

    gfx.popContext() -- All modifications done during the context get removed
end