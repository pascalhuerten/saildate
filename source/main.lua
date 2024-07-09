
-- Common CoreLibs imports.
-- import "CoreLibs/object"
-- import "CoreLibs/graphics"
-- import "CoreLibs/sprites"
-- import "CoreLibs/timer"

-- Project imports
import "button"
import "crank"
import "lifecycle"
import "simulator"
import "boat"
import "npcBoat"
import "wind"
import "sea"

-- Use common shorthands for playdate code
local gfx <const> = playdate.graphics
local display <const> = playdate.display
local font = gfx.font.new('font/Mini Sans 2X')

local boat = boat()
local npcBoat = npcBoat(300, 0, 0.3)
local wind = wind()
local sea = sea()
local skybox = gfx.image.new('images/skybox.png')

local function loadGame()
	display.setRefreshRate(30) -- Sets framerate to 30 fps
	math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
	gfx.setFont(font)
end

local function updateGame()
	boat:update()
	npcBoat:update()
    wind:update(boat.speed)
    sea:update(boat.speed)
end

local function drawGame()
	gfx.clear() -- Clears the screen
	skybox:draw(0, 0) -- Draw the skybox
	npcBoat:draw()
	boat:drawTrajectory()
    sea:drawBackgroundWaves()
    wind:draw()
    boat:draw()
    sea:drawForegroundWaves()
end

loadGame()

function playdate.update()-- Get deltaTime in seconds
	deltaTime = playdate.getElapsedTime() * 2 -- Assuming getElapsedTime() returns milliseconds
	playdate.resetElapsedTime()
	updateGame()
	drawGame()
	playdate.drawFPS(0,0) -- FPS widget
end