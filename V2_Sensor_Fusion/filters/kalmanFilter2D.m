function estimate = kalmanFilter2D(motion, imu, gps, camera)

    % Zaman adımı
    dt = motion.time(2) - motion.time(1);

    % Durum vektörü:
    % [x; y; vx; vy]
    state = [motion.x(1);
             motion.y(1);
             0;
             0];

    % Başlangıç hata kovaryansı
    P = eye(4); %kalmanın tahminine ne kadar güvendiğini/tahmin belirlsizliğini temsil eden kovaryans matrisi

    % Sistem matrisi
    F = [1 0 dt 0;
         0 1 0 dt;
         0 0 1  0;
         0 0 0  1];

    % IMU giriş matrisi
    B = [0.5*dt^2 0;
         0 0.5*dt^2;
         dt 0;
         0 dt];

    % Process noise
    Q = 0.01 * eye(4);

    % GPS ve kamera ölçüm matrisi
    H = [1 0 0 0;
         0 1 0 0];

    % GPS ölçüm noise'u
    Rgps = 1.0^2 * eye(2);

    % Kamera ölçüm noise'u
    Rcamera = 0.5^2 * eye(2);

    % Sonuçları saklamak için
    estimate.x = zeros(size(motion.x));
    estimate.y = zeros(size(motion.y));
    estimate.vx = zeros(size(motion.vx));
    estimate.vy = zeros(size(motion.vy));

    % İlk durum
    estimate.x(1) = state(1);
    estimate.y(1) = state(2);
    estimate.vx(1) = state(3);
    estimate.vy(1) = state(4);

    % Zaman boyunca ilerle
    for k = 2:length(motion.time)

        %% 1. PREDICTION - IMU

        u = [imu.ax(k);
             imu.ay(k)];

        state = F * state + B * u;

        P = F * P * F' + Q;


        %% 2. UPDATE - GPS

        if ~isnan(gps.x(k)) && ~isnan(gps.y(k))

            z = [gps.x(k);
                 gps.y(k)];

            innovation = z - H * state;

            S = H * P * H' + Rgps;

            K = P * H' / S;

            state = state + K * innovation;

            P = (eye(4) - K * H) * P;

        end


        %% 3. UPDATE - CAMERA

        if ~isnan(camera.x(k)) && ~isnan(camera.y(k))

            z = [camera.x(k);
                 camera.y(k)];

            innovation = z - H * state;

            S = H * P * H' + Rcamera;

            K = P * H' / S;

            state = state + K * innovation;

            P = (eye(4) - K * H) * P;

        end


        %% Sonucu kaydet

        estimate.x(k) = state(1);
        estimate.y(k) = state(2);
        estimate.vx(k) = state(3);
        estimate.vy(k) = state(4);

    end

    estimate.time = motion.time;

end