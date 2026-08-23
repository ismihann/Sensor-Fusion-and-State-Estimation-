# V1 – IMU-GPS Sensor Fusion with Kalman Filter

## 1. Project Overview

This project demonstrates a basic sensor fusion system for position and velocity estimation using simulated IMU and GPS measurements.

The system starts with a known motion profile and generates simulated sensor measurements by introducing noise and sensor bias. IMU acceleration measurements are filtered and integrated to estimate velocity and position. GPS provides an independent but noisy position measurement. Finally, a Kalman Filter combines the IMU-based prediction with GPS measurements to obtain a more stable state estimate.

The main goal of V1 is to understand the fundamental principles of sensor fusion and state estimation.

---

## 2. Objective

The objectives of this version are:

- Generate a known motion profile.
- Simulate noisy IMU acceleration measurements.
- Introduce a constant IMU bias.
- Reduce high-frequency IMU noise using a moving-average filter.
- Estimate velocity and position by integrating acceleration.
- Simulate noisy GPS position measurements.
- Fuse IMU and GPS measurements using a Kalman Filter.
- Compare IMU, GPS, and Kalman Filter position estimates.
- Evaluate estimation performance using RMSE.

---

## 3. System Architecture

The overall architecture of the V1 system is:

```text
                    TRUE MOTION
                        │
                        ▼
              ┌───────────────────┐
              │  Motion Model     │
              │ a_true, v_true,  │
              │ x_true            │
              └─────────┬─────────┘
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
      ┌──────────────┐      ┌──────────────┐
      │  IMU Model   │      │  GPS Model   │
      │              │      │              │
      │ Noise        │      │ GPS Noise    │
      │ + Bias       │      │              │
      └──────┬───────┘      └──────┬───────┘
             │                     │
             ▼                     ▼
      ┌──────────────┐       GPS Position
      │ IMU Filter   │
      │ Moving Mean  │
      └──────┬───────┘
             │
             ▼
      Filtered Acceleration
             │
             ▼
      ┌──────────────┐
      │ Integration  │
      │              │
      │ a → v → x    │
      └──────┬───────┘
             │
             ▼
      IMU Position Estimate
             │
             │
             └──────────────┐
                            ▼
                  ┌─────────────────┐
                  │  Kalman Filter  │
                  │                 │
                  │ IMU Prediction  │
                  │       +         │
                  │ GPS Correction  │
                  └────────┬────────┘
                           │
                           ▼
                  Kalman State Estimate
                    Position + Velocityan

---

## 4. Results

### Acceleration Comparison

![Acceleration Comparison](figures/acceleration_comparison.png)

### Position Comparison

![Position Comparison](figures/position_comparison.png)

### Velocity Comparison

![Velocity Comparison](figures/velocity_comparison.png)

### RMSE Results

The estimation performance is evaluated using Root Mean Square Error (RMSE).

| Method | Position RMSE |
|--------|---------------|
IMU      : 1.1365 m
GPS      : 0.9988 m
Kalman   : 0.4304 m

The Kalman Filter provides a lower position estimation error compared to the standalone IMU and GPS measurements.
