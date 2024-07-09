import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics
class("seedling").extends()

function seedling:init()
	self.x = 33
	self.y = 88
	self.h = 88
	self.w = 13
	-- List of particles
	self.particles = {}
end

function seedling:update()
	if(playdate.buttonJustPressed(playdate.kButtonDown)) then
		print("Button down pressed")
		self:explode()
	end

	for i = 1, #self.particles do
		local p = self.particles[i]
		p.x = p.x + p.dx
		p.y = p.y + p.dy
		p.dy = p.dy + 0.1
		self.particles[i] = p
	end
end

function seedling:draw()
	gfx.drawRect(self.x, self.y, self.w, self.h)
	for i = 1, #self.particles do
		local p = self.particles[i]
		gfx.drawRect(p.x, p.y, 8,8)
	end
end

function seedling:explode()
	for i = 1, 10 do
		local p = {
			x = self.x+self.w/2,
			y = self.y+self.h/2,
			dx = math.random(-2, 2),
			dy = math.random(-2, 2),
		}
		table.insert(self.particles, p)
	end

	-- print the number of particles
	print("Number of particles: " .. #self.particles)
end