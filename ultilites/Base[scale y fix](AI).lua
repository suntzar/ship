----CONSTANTES----

local SW = 561 -- Largura original da tela
local SH = 1246 -- Altura original da tela

local CX = SW / 2
local CY = SH / 2

local scale -- Escala para redimensionamento

local rndm = math.random
local lvg = love.graphics
local sen = math.sin
local cos = math.cos
local pi  = math.pi
local flr = math.floor

-- ... (restante das suas constantes e variáveis)

----FUNÇÕES-ÚTEIS----

-- ... (suas funções úteis)

----FUNÇÕES-PADRÃO----

function love.load()
  love.window.setMode(SW, SH) -- Define o modo da janela com a largura e altura originais
  love.window.setFullscreen(true, "desktop")
  
  math.randomseed(love.timer.getTime())
  
  --font = love.graphics.newFont("default.ttf", 24)
  --love.graphics.setFont(font)
  
  -- ... (restante do seu love.load)
end

function love.resize(w, h)
  -- Atualiza a escala sempre que a janela é redimensionada
  scale = w / SW
  SH = h / scale
  CY = SH / 2
end

function love.update(dt)
  -- ... (seu love.update)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  -- Aplica a escala aos toques na tela
  x = x / scale
  y = y / scale
  
  -- ... (restante do seu love.touchpressed)
end

function love.draw()
  -- Aplica a escala ao desenhar
  love.graphics.scale(scale, scale)
  
  
  
  -- ... (restante do seu love.draw)
end
