clear
clc
load("positions.mat")

f = figure;
f.Position(3:4) = [1280 720];


for clock = 1:200
    plot_vehicle(wheels_positions(:, :, :, clock), body_positions(:, :, clock));
    frame(1, clock) = getframe;
    disp(clock);
end

movie(frame)

v = VideoWriter('ground_animation.avi');
open(v)
writeVideo(v,frame)
close(v)

% clear frame
% f = figure;
% f.Position(3:4) = [1280 720];
% 
% scalar_velocity = sqrt(sum(body_velocities .^ 2, 1));
% axis manual
% axis([1, 250, 0, 3])
% hold on
% for clock = 1:timestep/save_every-1
%     plot(clock:clock+1, scalar_velocity(clock:clock+1), 'b', 'LineWidth', 2)
%     drawnow
%     frame(1, clock) = getframe;
% end
% 
% v = VideoWriter('down_slope_graph.avi');
% open(v)
% writeVideo(v,frame)
% close(v)
