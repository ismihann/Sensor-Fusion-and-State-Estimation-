%robotun hareketini üretmek
function motion = generateMotion2D()
% GENERATEMOTION2D
% Robotun 2D ortam içerisindeki gerçek hareketini oluşturur.

% Simülasyon zamanı
dt = 0.1;
t = 0:dt:20;

% Robotun gerçek konumu
x = 10 + 2*t;
y = 10 + 1*t + 0.5*sin(0.5*t);

% Gerçek hız
vx = gradient(x, dt);
vy = gradient(y, dt);

% Gerçek ivme
ax = gradient(vx, dt);
ay = gradient(vy, dt);

% Sonuçları tek bir yapı içerisinde sakla
motion.time = t;
motion.x = x;
motion.y = y;
motion.vx = vx;
motion.vy = vy;
motion.ax = ax;
motion.ay = ay;
end

