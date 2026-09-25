function environment = createEnvironment()
% CREATEENVIRONMENT
% V2 sensor fusion projesi için 2D ortam oluşturur.

% Ortam boyutları (metre)
environment.width = 100;
environment.height = 100;

% Ortamdaki landmarkların koordinatları
environment.landmarks = [
    10 80;
    30 20;
    50 70;
    75 25;
    90 85
    ];

% Ortamı çiz
figure;
hold on; % grafikte birden fazla şey çizeceğiz ( yani bu grafiğin üzerinde çizmeye devam et)
grid on;
axis equal; %x ve y de ölçekler eşit olsun

xlim([0 environment.width]);
ylim([0 environment.height]);

% Landmarkları çiz
plot(environment.landmarks(:,1), ...
    environment.landmarks(:,2), ...
    'r^', ...
    'MarkerSize', 10, ...
    'LineWidth', 2);

% Landmark numaralarını yaz
for i = 1:size(environment.landmarks,1)
    text(environment.landmarks(i,1) + 2, ...
        environment.landmarks(i,2), ...
        sprintf('L%d', i), ...
        'FontSize', 10);
end

xlabel('X Position (m)');
ylabel('Y Position (m)');
title('V2 - 2D Sensor Fusion Environment');

legend('Landmarks');

hold off;
end
