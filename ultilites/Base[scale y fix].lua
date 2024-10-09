----CONSTANTES----

SW = 561 
SH = 1246

CX = SW/2
CY = CY

NSW = 561
NSH = 1246

rndm = math.random 

lvg = love.graphics

sen = math.sin
cos = math.cos
pi  = math.pi

flr = math.floor

--botoes



-- cores
function cor1()
 setColor(126,141,86)
end
function cor2()
 setColor(30,19,31,flr(255/8*7))
end
cb = 1/255

----VARIAVEIS

t = 0

----TABELAS----



----REQUIRE----



----FUNÇÕES-ÚTEIS----

-- encurta e readapta a função love.graphics.setColor() pra funcionar com valores de 0 a 255 ao invés de 0 a 1
function setColor(r,g,b,a) 
 local a = a or 255
 love.graphics.setColor(1/255*r,1/255*g,1/255*b,1/255*a)
end

-- centraliza um texto no eixo x
function CTXT(text,x,y,s)
 local w = font:getWidth(text)
 local h = font:getHeight(text)
 love.graphics.print(text,x,y, 0, s or 1, s or 1, w/2, h/2)
end

-- cria um efeito fade gradiente
function gradiente(x,y,w,h,r,g,b)
 for i=0,h do
  setColor(r,g,b,255/h*(h-i))
  lvg.rectangle("fill",x,y+i,w,1) 
 end
end

-- retornar a distância entre dois pontos
function dst(x1,y1,x2,y2)
 return math.sqrt((x2-x1)^2+(y2-y1)^2)
end

-- verifica se um ponto esta dentro de um retângulo
function pr(x,y,rx,ry,rw,rh)
 return  x >rx and x<rx+rw and y>ry and y<ry+rh 
end

-- verifica se um ponto esta dentro de um círculo
function pc(x, y, cx, cy, r)
  -- retorna true se o ponto (x, y) está dentro do círculo com centro (cx, cy) e raio r
  local distancia = math.sqrt ((x - cx)^2 + (y - cy)^2) -- calcula a distância entre o ponto e o centro do círculo
  return distancia < r -- retorna true se a distância for menor que o raio, ou false se não for
end



----FUNÇÕES-PADRÃO----



function love.load()
  love.window.setMode(1, 2)
  love.window.setFullscreen(true, "desktop")
  
  math.randomseed(love.timer.getTime())
  
  font = love.graphics.newFont("defalt.ttf",24) 
  love.graphics.setFont(font)
  
  Strue = love.audio.newSource('true.mp3','static')
  Sfalse = love.audio.newSource('false.mp3','static')
  Stap = love.audio.newSource('tap.mp3','static')
end



function love.update(dt)
 -- timers 
 t = t + dt*60
 
end



function love.touchpressed(id, x, y, dx, dy, pressure)
 x = x/scale
 y = y/scale
 
 xt = x
 yt = y
 
 if pressure then love.event.quit() end
 
end 



function love.keypressed(key)
 if key == "escape" then
  love.event.quit()
 end
end



function love.draw() 

 ---

 NSW = love.graphics.getWidth()
 NSH = love.graphics.getHeight()
 scale = NSW/SW  
 SH = NSH/scale
 CY = SH/2
 love.graphics.scale(scale, scale) 
 love.graphics.setBackgroundColor(cb*40,cb*45,cb*50)
 lvg.setColor(1,1,1)
 ---
 
end 
