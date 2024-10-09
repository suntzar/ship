-- title:   Game Title
-- author:  Game Developer, email@example.com
-- desc:    Short Description
-- site:    http://website.com
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  Lua

-- Constants
sw, sh = 240, 136
cx, cy = sw / 2, sh / 2

-- Variables
t = 0

-- Math functions
rnd = math.random
sqrt = math.sqrt
cos = math.cos
sin = math.sin
max = math.max
min = math.min
pi = math.pi

-- Player setup
p = {
  x = cx,
  y = cy,
  vx = 0,
  vy = 0,
  ax = 0.1,
  ay = 0.1,
  s = 256,
  d = 0,
  j = false,
  falling = false
}

-- Environment setup
solids = {17, 18, 19, 20, 21, 22, 23, 24}
platforms = {49}
grass = {}

-- Particle setup
particles = {}

-- Functions

function init_grass()
  for i = 1, 60 do
    grass[i] = rnd(sw / 8, sw / 8 * 7)
  end
end

function s(a, b)
  return a + b
end

function printC(text, y, color)
  local screen_width = 240
  local text_width = print(text, 0, -6)
  local x = (screen_width - text_width) // 2
  print(text, x, y, color)
  return text_width
end

function add_part(x, y, vx, vy, color)
  local part = {
    x = x,
    y = y,
    vx = vx,
    vy = vy,
    life = 60,
    color = color
  }
  table.insert(particles, part)
end

function upd_part()
  for i = #particles, 1, -1 do
    local p = particles[i]
    p.vy = max(p.vy - 0.1, -2)
    p.y = p.y - p.vy
    p.life = p.life - 1
    if p.life <= 0 or mget(p.x // 8, p.y // 8) == 17 then
      table.remove(particles, i)
    end
  end
end

function drw_part()
  for _, p in ipairs(particles) do
    pix(p.x, p.y, p.color)
  end
end

function update_player()
  t = t + 1
  p.s = (t // 40) % 2 * 16 + 256

  if btn(2) and p.x > sw / 8 then
    p.s = (t // 10) % 3 + 256
    p.x = p.x - 1
    p.d = 1
  end
  if btn(3) and p.x < sw / 8 * 7 - 8 then
    p.s = (t // 10) % 3 + 256
    p.x = p.x + 1
    p.d = 0
  end
  if btn(4) and p.j then
    p.vy = 2
    p.j = false
  end

  if not p.j then p.s = 273 end
  if p.vx > 0 then p.vx = p.vx 

  p.vy = max(p.vy - p.ay, -2)

  p.x = p.x + p.vx
  p.y = p.y - p.vy

end

function check_collision(x, y)
  local tile = mget(x // 8, y // 8)
  for _, solid in ipairs(solids) do
    if tile == solid then
      return true
    end
  end
  return false
end

function check_platform_collision(x, y)
  local tile = mget(x // 8, y // 8)
  for _, platform in ipairs(platforms) do
    if tile == platform then
      return true
    end
  end
  return false
end

function check_collisions()
  -- Check ground collision
  if check_collision(p.x + 4, p.y) then
    p.y = (p.y // 8) * 8
    p.vy = 0
    p.j = true
    p.falling = false
  end

  -- Check platform collision
  if check_platform_collision(p.x + 4, p.y) and not p.falling then
    p.y = (p.y // 8) * 8
    p.vy = 0
    p.j = true
  end

  -- Check right wall collision
  if check_collision(p.x + 8, p.y - 4) then
    p.x = (p.x // 8) * 8
  end

  -- Check left wall collision
  if check_collision(p.x, p.y - 4) then
    p.x = (p.x // 8) * 8 + 8
  end

  -- Check ceiling collision
  if check_collision(p.x + 4, p.y - 8) then
    p.y = (p.y // 8) * 8 + 8
    p.vy = 0
  end

  -- Allow player to fall through platforms if down arrow is pressed
  if btn(1) then
    p.falling = true
  else
    p.falling = false
  end
end

function draw_game()
  cls(0)
  map(0, 0, sw // 8, sh // 8)
  spr(p.s, p.x, p.y - 8, 0, 1, p.d)
  
  local w_t = printC("ZURVIVE", cy + 1, 2)

  if t % 1 == 0 then
    add_part(rnd(cx - w_t // 2, cx + w_t // 2 - 2), cy + 6, 0, 0, 2)
  end

  drw_part()
end

function TIC()
  update_player()
  check_collisions()
  draw_game()
  upd_part()
end

-- Initialize grass
init_grass()