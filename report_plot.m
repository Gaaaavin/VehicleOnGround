clear
clc
load("archive/data/positions_ground.mat")

f = figure;
f.Position(3:4) = [1280 720];

scalar_velocity = sqrt(sum(body_velocities .^ 2, 1));
plot(scalar_velocity, 'LineWidth', 1)

saveas(gcf, 'archive/figure/down_ground.png')