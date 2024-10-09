math.randomseed(love.timer.getTime())

----CONSTANTES----

SW = 1246*2 -- Largura original da tela 561
SH = 561*2 -- Altura original da tela 1246

CX = SW / 2
CY = SH / 2

game = {
  x = CX-SH*0.45,
  y = CY-SH*0.45,
  w = SH*0.9,
  h = SH*0.9,
  s = 8,
  v = 0.1
}

rndm = math.random
lvg = love.graphics
abs = math.abs
sen = math.sin
cos = math.cos
max = math.max
min = math.min
pi  = math.pi
flr = math.floor
sqrt = math.sqrt
keyD =  love.keyboard.isDown

cb = 1/255 -- Color Base

debug = {}
button = {}
timeh = 0
t = 0

Tctrl = {
  touch = false,
  {
    {
      x = SW*0.1,
      y = SH*0.8,
      w = 200,
      h = 200,
      r = 150,
      a = 0,
    },
    {
      x = SW*0.2,
      y = SH*0.8,
      w = 200,
      h = 200,
      r = 150,
      a = 0,
    }
  },
  {
    {
      x = SW*0.8,
      y = SH*0.8,
      w = 200,
      h = 200,
      r = 150,
      a = 0,
    },
    {
      x = SW*0.9,
      y = SH*0.8,
      w = 200,
      h = 200,
      r = 150,
      a = 0,
    }
  }
}

color = {
  {r = 176, g = 216, b = 255}, -- Azul
  {r = 255, g = 102, b = 102}, -- Vermelho
  {r = 176, g = 255, b = 176}, -- Verde
  {r = 255, g = 219, b = 153}, -- Amarelo
  {r = 200, g = 176, b = 255}, -- Anil
  {r = 255, g = 178, b = 102}, -- Laranja
  {r = 219, g = 176, b = 255} -- Violeta
}
  
  

players = {}

for i = 1, 3 do
  players[i] = {
    x = CX,
    y = CY,
    w = 80,
    h = 80,
    a = 0,
    vx = 0,
    vy = 0,
    vm = 10,
    ax = 0.1,
    ay = 0.1,
    eng = 1,
    c = color[i],
    hunter = false
  }
end

for i = 1, #players do
  players[i].x = game.x + game.w / (#players + 1) * i
  players[i].hunter = i == 1
end

----FUNÇÕES-ÚTEIS----

function drawp(self,spr)
  lvg.setColor(1,1,1)
  lvg.draw(spr, self.x, self.y, self.a, self.w/spr:getWidth(), self.h/spr:getHeight(),spr:getWidth()/2,spr:getHeight()/2)
end

function cosmetic(self,spr,dx,dy)
  lvg.setColor(1,1,1)
  lvg.draw(spr, self.x, self.y, self.a, self.w/spr:getWidth(), self.h/spr:getHeight(),spr:getWidth()/2*(dx or 1),spr:getHeight()/2*(dy or 1))
end

function movep(self,lf,rg,up,dw,dt,tx,ty,tp)
  
  local mx, my = love.mouse.getPosition()
  mx = mx/scale - (TSW/scale-SW)/2
  my = my/scale

  if lf and not rg then self.a = self.a - pi/180*5*dt end
  if rg and not lf then self.a = self.a + pi/180*5*dt end
  
  if love.mouse.isDown(2) and sqrt((self.x - mx)^2 + (self.y - my)^2) > self.h/2 or tp then 
    if love.mouse.isDown(2) then self.a = -math.atan2(self.x-mx,self.y-my) end
    if tp then self.a = -math.atan2(self.x-tx/scale,self.y-ty/scale) end
    self.vx = self.vx + self.ax * sen(self.a)*dt
    self.vy = self.vy - self.ay * cos(self.a)*dt
  end

  if up then 
    self.vx = self.vx + self.ax * sen(self.a)*dt
    self.vy = self.vy - self.ay * cos(self.a)*dt
    self.eng = max(self.eng - 0.1,-0.5)
  end

  self.eng = min(self.eng + 0.05, 1)
  self.vx = min(self.vx,self.vm)
  self.vx = max(self.vx,-self.vm)
  self.vy = min(self.vy,self.vm)
  self.vy = max(self.vy,-self.vm)

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  if self.x < game.x - self.w/2 then self.x = game.x + game.w + self.w/2 end
  if self.x > game.x + game.w + self.w/2 then self.x = game.x - self.w/2 end
  if self.y < game.y - self.h/2 then self.y = game.y + game.h + self.h/2 end
  if self.y > game.y + game.h + self.h/2 then self.y = game.y - self.h/2 end

end

function colision(q1, q2)
  debug[1] = q1.x-q1.w/2
  debug[2] = q1.y-q1.h/2
  debug[3] = q1.w
  debug[4] = q1.h
  debug[5] = q2.x-q2.w/2
  debug[6] = q2.y-q2.h/2
  debug[7] = q2.w
  debug[8] = q2.h
  return q1.x-q1.w/2 < q2.x-q2.w/2 + q2.w and
         q1.x-q1.w/2 + q1.w > q2.x-q2.w/2 and
         q1.y-q1.h/2 < q2.y-q2.h/2 + q2.h and
         q1.y-q1.h/2 + q1.h > q2.y-q2.h/2
end

function heron(a,b,c)
  local s = (a+b+c)/2
  return sqrt(s*(s-a)*(s-b)*(s-c))
end

function polycolision(x,y,x1,y1,x2,y2,x3,y3)
  
  local d1 = sqrt( (x1-x2)^2 + (y1-y2)^2 )
  local d2 = sqrt( (x1-x3)^2 + (y1-y3)^2 )
  local d3 = sqrt( (x2-x3)^2 + (y2-y3)^2 )
  
  local d4 = sqrt( (x-x1)^2 + (y-y1)^2 )
  local d5 = sqrt( (x-x2)^2 + (y-y2)^2 )
  local d6 = sqrt( (x-x3)^2 + (y-y3)^2 )
  
  local a = heron(d1,d2,d3)
  local a1 = heron(d1,d4,d5)
  local a2 = heron(d2,d4,d6)
  local a3 = heron(d3,d5,d6)
  
  if tonumber(tostring(a / (a1 + a2 + a3))) == 1 then love.system.vibrate(0.5) end

  return tonumber(tostring(a / (a1 + a2 + a3))) == 1
  
end

function drawArrow()
  drawp({x = tchx, y = tchy, a = t*(pi/100), w = 100, h = 100},arrow)
  tchx = -CX
  tchy = -CY
end

function updateScale(w, h)
  scale = h / SH
  TSW = w
  TSH = h
  TSX = (TSW/scale-SW)/2
  --SH = h / scale
  --CY = SH / 2
end

----FUNÇÕES-PADRÃO----

function love.load()
  --love.window.setMode(SW, SH) -- Define o modo da janela com a largura e altura originais
  love.window.setFullscreen(true, "desktop")
  
  math.randomseed(love.timer.getTime())
  
  font = love.graphics.newFont("assets/fonts/Inversionz.ttf", 24*2)
  love.graphics.setFont(font)
  
  cursor = love.mouse.newCursor("assets/textures/UI/arrow.png",77/2,77/2)
  love.mouse.setCursor(cursor)

  ship = love.graphics.newImage("assets/textures/ships/ship_color.png")
  ships = {
    love.graphics.newImage("assets/textures/ships/ship1.png"),
    love.graphics.newImage("assets/textures/ships/ship2.png"),
    love.graphics.newImage("assets/textures/ships/ship3.png")
  }
  
  stroke = love.graphics.newImage("assets/textures/cosmetics/ship-stroke.png")
  fire = love.graphics.newImage("assets/textures/cosmetics/fire.png")
  arrow = love.graphics.newImage("assets/textures/UI/arrow.png")
  button_r = love.graphics.newImage("assets/textures/UI/button_r.png")
  button_p = love.graphics.newImage("assets/textures/UI/button_p.png")
  
  -- Atualiza a escala sempre que a janela é redimensionada
  local w, h = love.graphics.getDimensions()
  updateScale(w, h)
end

function love.resize(w, h)
  -- Atualiza a escala sempre que a janela é redimensionada
  updateScale(w, h)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  -- Aplica a escala aos toques na tela
  local x = x / scale
  local y = y / scale
  local dx = dx / scale
  local dy = dy / scale
  
  love.system.vibrate(0.01)
  
  tchx = x
  tchy = y
end

function love.update(dt)
  
  t = t + dt * 60
  timeh = timeh + 1
  dtdb = dt
  
  local p1lf = false
  local p1rg = false
  local p2lf = false
  local p2rg = false
  local tx = 0
  local ty = 0
  local tp = false
  for i=1,4 do button[i] = button_r end
  local touches = love.touch.getTouches()
  for i, id in ipairs(touches) do
    local x, y = love.touch.getPosition(id)
    local pres = love.touch.getPressure(id)
    tx = x
    ty = y
    tp = pres
    Tctrl.touch = true
    --if x/scale < CX then p1lf = true end
    --[[if x/scale > CX then p1rg = true end
    if colision(x/scale ,y/scale , Tctrl[1][1].x+Tctrl[1][1].r*cos(Tctrl[1][1].a+2*pi/3*0), Tctrl[1][1].y+Tctrl[1][1].r*sen(Tctrl[1][1].a+2*pi/3*0), Tctrl[1][1].x+Tctrl[1][1].r*cos(Tctrl[1][1].a+2*pi/3*1), Tctrl[1][1].y+Tctrl[1][1].r*sen(Tctrl[1][1].a+2*pi/3*1), Tctrl[1][1].x+Tctrl[1][1].r*cos(Tctrl[1][1].a+2*pi/3*2), Tctrl[1][1].y+Tctrl[1][1].r*sen(Tctrl[1][1].a+2*pi/3*2)) then p1lf = true end
    if colision(x/scale ,y/scale , Tctrl[1][2].x+Tctrl[1][2].r*cos(Tctrl[1][2].a+2*pi/3*0), Tctrl[1][2].y+Tctrl[1][2].r*sen(Tctrl[1][2].a+2*pi/3*0), Tctrl[1][2].x+Tctrl[1][2].r*cos(Tctrl[1][2].a+2*pi/3*1), Tctrl[1][2].y+Tctrl[1][2].r*sen(Tctrl[1][2].a+2*pi/3*1), Tctrl[1][2].x+Tctrl[1][2].r*cos(Tctrl[1][2].a+2*pi/3*2), Tctrl[1][2].y+Tctrl[1][2].r*sen(Tctrl[1][2].a+2*pi/3*2)) then p1rg = true end
    if colision(x/scale ,y/scale , Tctrl[2][1].x+Tctrl[2][1].r*cos(Tctrl[2][1].a+2*pi/3*0), Tctrl[2][1].y+Tctrl[2][1].r*sen(Tctrl[2][1].a+2*pi/3*0), Tctrl[2][1].x+Tctrl[2][1].r*cos(Tctrl[2][1].a+2*pi/3*1), Tctrl[2][1].y+Tctrl[2][1].r*sen(Tctrl[2][1].a+2*pi/3*1), Tctrl[2][1].x+Tctrl[2][1].r*cos(Tctrl[2][1].a+2*pi/3*2), Tctrl[2][1].y+Tctrl[2][1].r*sen(Tctrl[2][1].a+2*pi/3*2)) then p2lf = true end
    if colision(x/scale ,y/scale , Tctrl[2][2].x+Tctrl[2][2].r*cos(Tctrl[2][2].a+2*pi/3*0), Tctrl[2][2].y+Tctrl[2][2].r*sen(Tctrl[2][2].a+2*pi/3*0), Tctrl[2][2].x+Tctrl[2][2].r*cos(Tctrl[2][2].a+2*pi/3*1), Tctrl[2][2].y+Tctrl[2][2].r*sen(Tctrl[2][2].a+2*pi/3*1), Tctrl[2][2].x+Tctrl[2][2].r*cos(Tctrl[2][2].a+2*pi/3*2), Tctrl[2][2].y+Tctrl[2][2].r*sen(Tctrl[2][2].a+2*pi/3*2)) then p2rg = true end ]]
    
    if Tctrl.touch then
      if colision({x = x/scale , y = y/scale, w = 0, h = 0} , Tctrl[1][1]) then p1lf = true button[1] = button_p end
      if colision({x = x/scale , y = y/scale, w = 0, h = 0} , Tctrl[1][2]) then p1rg = true button[2] = button_p end
      if colision({x = x/scale , y = y/scale, w = 0, h = 0} , Tctrl[2][1]) then p2lf = true button[3] = button_p end
      if colision({x = x/scale , y = y/scale, w = 0, h = 0} , Tctrl[2][2]) then p2rg = true button[4] = button_p end
    end
  end
  
  game.w = max(game.w - dt*60*2*game.v,0)
  game.h = max(game.h - dt*60*2*game.v,0)
  if game.w >= 0 then game.x = game.x + dt*60*game.v end
  if game.h >= 0 then game.y = game.y + dt*60*game.v end
  
  
  --movep(players[1], false, false, tp, false,dt*60,tx,ty,tp)
  movep(players[1], keyD("a") or p1lf, keyD("d") or p1rg, keyD("w") or p1lf and p1rg, keyD("s"),dt*60)
  movep(players[2], keyD("left") or p2lf, keyD("right") or p2rg, keyD("up") or p2lf and p2rg, keyD("down"),dt*60)
  movep(players[3], keyD("j"), keyD("l"), keyD("i"), keyD("k"),dt*60)

  for i=1,#players do
    for j=1,#players do
      if i ~= j and colision(players[i], players[j]) and timeh > 60*4 then if players[i].hunter then players[i].hunter = false players[j].hunter = true timeh = 0 end end 
    end 
  end
end

function love.keypressed(key)
  if key == "tab" then
     local state = not love.mouse.isVisible()   -- the opposite of whatever it currently is
     love.mouse.setVisible(state)
  end
end

function love.draw()
  -- Aplica a escala ao desenhar
  lvg.scale(scale, scale)
  lvg.translate(TSX,0)
  lvg.setBackgroundColor(cb*39,cb*39,cb*54)
  lvg.setColor(1,1,1)
  
  for i=1,#players do
    --cosmetic(players[i],fire,1,(players[i].vm-sqrt(abs(players[i].vx)^2+abs(players[i].vy)^2))/players[i].vm)
    cosmetic(players[i],fire,1,players[i].eng)
    lvg.setColor(players[i].c.r * cb,players[i].c.g * cb,players[i].c.b * cb)
    lvg.circle("fill", players[i].x, players[i].y, players[i].w * 0.2)
    drawp(players[i],ship)
    if players[i].hunter then drawp(players[i],stroke) end
  end

  lvg.setColor(cb*39,cb*39,cb*54)
  lvg.rectangle("fill", 0, 0, game.x, SH) -- esquerda
  lvg.rectangle("fill", SW, 0, (game.w-SW)/2, SH) --direita
  lvg.rectangle("fill", 0, 0, SW, game.y) -- cima
  lvg.rectangle("fill", 0, SH, SW, (game.h-SH)/2) --baixo

  lvg.setColor(cb*255,cb*255,cb*235)
  
  lvg.rectangle("line", game.x, game.y, game.w, game.h)
  
  lvg.setColor(1,1,1)

  --[[
  lvg.setColor(cb*255,cb*255,cb*235)
  lvg.polygon("fill", Tctrl[1][1].x+Tctrl[1][1].r*cos(Tctrl[1][1].a+2*pi/3*0), Tctrl[1][1].y+Tctrl[1][1].r*sen(Tctrl[1][1].a+2*pi/3*0), Tctrl[1][1].x+Tctrl[1][1].r*cos(Tctrl[1][1].a+2*pi/3*1), Tctrl[1][1].y+Tctrl[1][1].r*sen(Tctrl[1][1].a+2*pi/3*1), Tctrl[1][1].x+Tctrl[1][1].r*cos(Tctrl[1][1].a+2*pi/3*2), Tctrl[1][1].y+Tctrl[1][1].r*sen(Tctrl[1][1].a+2*pi/3*2))
  lvg.polygon("fill", Tctrl[1][2].x+Tctrl[1][2].r*cos(Tctrl[1][2].a+2*pi/3*0), Tctrl[1][2].y+Tctrl[1][2].r*sen(Tctrl[1][2].a+2*pi/3*0), Tctrl[1][2].x+Tctrl[1][2].r*cos(Tctrl[1][2].a+2*pi/3*1), Tctrl[1][2].y+Tctrl[1][2].r*sen(Tctrl[1][2].a+2*pi/3*1), Tctrl[1][2].x+Tctrl[1][2].r*cos(Tctrl[1][2].a+2*pi/3*2), Tctrl[1][2].y+Tctrl[1][2].r*sen(Tctrl[1][2].a+2*pi/3*2))

  lvg.polygon("fill", Tctrl[2][1].x+Tctrl[2][1].r*cos(Tctrl[2][1].a+2*pi/3*0), Tctrl[2][1].y+Tctrl[2][1].r*sen(Tctrl[2][1].a+2*pi/3*0), Tctrl[2][1].x+Tctrl[2][1].r*cos(Tctrl[2][1].a+2*pi/3*1), Tctrl[2][1].y+Tctrl[2][1].r*sen(Tctrl[2][1].a+2*pi/3*1), Tctrl[2][1].x+Tctrl[2][1].r*cos(Tctrl[2][1].a+2*pi/3*2), Tctrl[2][1].y+Tctrl[2][1].r*sen(Tctrl[2][1].a+2*pi/3*2))
  lvg.polygon("fill", Tctrl[2][2].x+Tctrl[2][2].r*cos(Tctrl[2][2].a+2*pi/3*0), Tctrl[2][2].y+Tctrl[2][2].r*sen(Tctrl[2][2].a+2*pi/3*0), Tctrl[2][2].x+Tctrl[2][2].r*cos(Tctrl[2][2].a+2*pi/3*1), Tctrl[2][2].y+Tctrl[2][2].r*sen(Tctrl[2][2].a+2*pi/3*1), Tctrl[2][2].x+Tctrl[2][2].r*cos(Tctrl[2][2].a+2*pi/3*2), Tctrl[2][2].y+Tctrl[2][2].r*sen(Tctrl[2][2].a+2*pi/3*2))
  ]]

  --[[
  lvg.rectangle("fill", Tctrl[1][1].x-Tctrl[1][1].w/2, Tctrl[1][1].y-Tctrl[1][1].h/2, Tctrl[1][1].w, Tctrl[1][1].h)
  lvg.rectangle("fill", Tctrl[1][2].x-Tctrl[1][2].w/2, Tctrl[1][2].y-Tctrl[1][2].h/2, Tctrl[1][2].w, Tctrl[1][2].h)
  lvg.rectangle("fill", Tctrl[2][1].x-Tctrl[2][1].w/2, Tctrl[2][1].y-Tctrl[2][1].h/2, Tctrl[2][1].w, Tctrl[2][1].h)
  lvg.rectangle("fill", Tctrl[2][2].x-Tctrl[2][2].w/2, Tctrl[2][2].y-Tctrl[2][2].h/2, Tctrl[2][2].w, Tctrl[2][2].h)
  ]]

  if Tctrl.touch then
    drawp(Tctrl[1][1],button[1])
    drawp(Tctrl[1][2],button[2])
    drawp(Tctrl[2][1],button[3])
    drawp(Tctrl[2][2],button[4])
  end

  --lvg.print(table.concat(debug,"\n"),50,50)
  debug = {TSW,SW,TSW-SW}
  lvg.print(table.concat(debug,"\n"),50,50)
  drawArrow()
  
  --lvg.setColor(1,0.5,0.5)
  --lvg.rectangle("line",debug[1],debug[2],debug[3],debug[4])
  --lvg.setColor(0.5,0.5,1)
  --lvg.rectangle("line",debug[5],debug[6],debug[7],debug[8])
  lvg.setColor(1,0,0)
  lvg.rectangle("line", 2,2, SW-4,SH-4)

end
