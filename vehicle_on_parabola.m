clear
clc
close all

%% Configurations
num_rin_points = 20; % number of points on the wheel
body_len = 2; % half of the length of the vehicle body (m)
body_wid = 1.2; % half of the width of the vehicle body (m)
axle_len = 0.3; % half of the length of the axle (m)
rin_radius = 1; % raidus of the wheel (m)

g = 9.8;  % gravitational acceleration (m/s^2)
wheel_mass = 0.1;  % mass of wheel (kg)
body_mass = 1; % mass of vechile body (kg)
ground_elastictiy = 1000;  % coefficient of groud elastictiy (s^-2)
ground_damping = 0;  % coefficient of ground damping(s^-1)
rim_elasticity = 200; % coefficient of rim elastictiy (s^-2)
rim_damping = 20; % coefficient of rim damping(s^-1)
position_cm_wheels = [body_len, body_len, -body_len, -body_len;
       body_wid, -body_wid, body_wid, -body_wid; 
       1.2, 1.2, 1.2, 1.2];  % initial position of centers of mass of wheels
position_cm_body = [0; 0; 1.1]; % initial position of center of mass of body
velocity_cm_wheels = repmat([0; 0; 0], 1, 4);  % initial velocity of centers of mass of wheels
velocity_cm_body = [0; 0; 0]; % initial velocity of centers of mass of body
friction_coef = 0.5;  % coefficient of friction of the ground(m^-1)
angular_velocity_wheels = repmat([0; 5; 0], 1, 4); % initial angular velocity of wheels
angular_velocity_body = [0; 0; 0];
cond_slope = 0.5;

time = 20;
timestep = 200000;
save_every = 400;
dt = time / timestep;

% syms x y z
% h = z - 0.2 * sin(x) * sin(y);
% grad = [diff(h, x); diff(h, y); diff(h, z)];


%% Initialize

rim_length = sqrt(rin_radius^2 + axle_len^2);
position_tilde_wheels = wheels(rin_radius, num_rin_points);
position_tilde_body = body(body_len, body_wid, axle_len, 1);

% Calculate inertia tensor
mass_wheel_each = wheel_mass / num_rin_points * ones(1, num_rin_points) ;
mass_body_each = body_mass / 8 * ones(1, 8);
inertia_tensor_wheels = repmat(cal_inertia_tensor(position_tilde_wheels(:, :, 1), mass_wheel_each), 1, 1, 4);
inertia_tensor_body = cal_inertia_tensor(position_tilde_body, mass_body_each);

% Calculate angular momentum
angular_momentum_wheels = zeros(3, 4);
parfor i =1:4
    angular_momentum_wheels(:, i) = inertia_tensor_wheels(:, :, i) * angular_velocity_wheels(:, i);
end
angular_momentum_body = inertia_tensor_body * angular_velocity_body;

% H = zeros(1, num_rin_points, 4);
% nabla = zeros(3, num_rin_points, 4);
% angular_momentum = pagemtimes(inertia_tensor, angular_velocity);
%% Simulate
wheels_positions = zeros(3, 20, 4, timestep / save_every);
body_positions = zeros(3, 8, timestep / save_every);
for clock = 1:timestep
% for clock = 1
    % Step0: calculate absolute position and velocity
    absolute_position_wheels = zeros(size(position_tilde_wheels));
    absolute_velocity_wheels = zeros(size(position_tilde_wheels));
    parfor i = 1:4
        absolute_position_wheels(:, :, i) = position_cm_wheels(:, i) + position_tilde_wheels(:, :, i);
        absolute_velocity_wheels(:, :, i) = velocity_cm_wheels(:, i) + ...
            cross(angular_velocity_wheels(:, i) .* ones(size(position_tilde_wheels(:, :, i))), position_tilde_wheels(:, :, i));
    end
    absolute_position_body = position_cm_body + position_tilde_body;
    absolute_velocity_body = velocity_cm_body + cross(angular_velocity_body .* ones(size(position_tilde_body)), position_tilde_body);
    
    % Step1: rotate position tilde
    rotation_wheels = angular_velocity_wheels * dt;
    rotation_body = angular_velocity_body * dt;
    parfor i = 1:4
        position_tilde_wheels(:, :, i) = Rodrigues(position_tilde_wheels(:, :, i), rotation_wheels(:, i));
    end
    position_tilde_body = Rodrigues(position_tilde_body, rotation_body);
    
    % Step2: Calculate forces
    force_wheels = zeros(3, num_rin_points, 4);
    force_body = zeros(3, 8);
    
    % gravity
    gravity_wheels = repmat([0; 0; -g] .* mass_wheel_each, 1, 1, 4);
    gravity_body = [0; 0; -g] .* mass_body_each;
    force_wheels = force_wheels + gravity_wheels;
    force_body = force_body + gravity_body;
    
    % ground
    for i = 1:4
        xs = absolute_position_wheels(1, :, i);
        ys = absolute_position_wheels(2, :, i);
        zs = absolute_position_wheels(3, :, i);
        parfor j = 1:num_rin_points
            x = xs(j);
            y = ys(j);
            z = zs(j);
            H = compute_h(x, y, z);
            nabla = compute_nabla(x, y, z);
        
            if H <= 0
                direction = nabla / norm(nabla);
                force_normal = ground_elastictiy * (-H / norm(nabla)) * direction;
                velocity_normal = direction * (absolute_velocity_wheels(:, j, i)' * direction);
                velocity_tan = absolute_velocity_wheels(:, j, i) - velocity_normal;
                   
                if velocity_tan == 0
                    force_friction = 0;
                else
                    force_friction = friction_coef * ground_elastictiy * (-H / norm(nabla)) * (-velocity_tan / norm(velocity_tan));
                end
            else
                force_normal = [0; 0; 0];
                force_friction = [0; 0; 0];
            end
            
            force_wheels(:, j, i) = force_wheels(:, j, i) + force_normal + force_friction;
        end
    end
    
    % rims
    for i = 1:4
        sum_tension1 = 0;
        sum_tension2 = 0;
        body_position1 = absolute_position_body(:, 2*i-1);
        body_position2 = absolute_position_body(:, 2*i);
        body_velocity1 = absolute_velocity_body(:, 2*i-1);
        body_velocity2 = absolute_velocity_body(:, 2*i);
        parfor j = 1:num_rin_points
            distance1 = absolute_position_wheels(:, j, i) - body_position1;
            distance2 = absolute_position_wheels(:, j, i) - body_position2;
            delta_velocity1 = absolute_velocity_wheels(:, j, i) - body_velocity1;
            delta_velocity2 = absolute_velocity_wheels(:, j, i) - body_velocity2;
            
            tension1 = rim_elasticity * (rim_length - sqrt(sum(distance1 .^2))) - ...
                rim_damping / sqrt(sum(distance1 .^2)) * sum(distance1 .* delta_velocity1);
            tension2 = rim_elasticity * (rim_length - sqrt(sum(distance2 .^2))) - ...
                rim_damping / sqrt(sum(distance2 .^2)) * sum(distance2 .* delta_velocity2);
            
            force_wheels(:, j, i) = force_wheels(:, j, i) + ...
                tension1 * ((distance1) / norm(distance1)) + ...
                tension2 * ((distance2) / norm(distance2));
            
            sum_tension1 = sum_tension1 - tension1 * ((distance1) / norm(distance1));
            sum_tension2 = sum_tension2 - tension2 * ((distance2) / norm(distance2));
%             force_body(:, i*2-1) = force_body(:, i*2-1) - tension1 * ((distance1) / norm(distance1));
%             force_body(:, i*2) = force_body(:, i*2) - tension2 * ((distance2) / norm(distance2));
        end
        force_body(:, i*2-1) = force_body(:, i*2-1) + sum_tension1;
        force_body(:, i*2) = force_body(:, i*2) + sum_tension2;
    end
    
    % Step3: Update velocity of centers of mass
    velocity_cm_wheels = velocity_cm_wheels + squeeze(sum(force_wheels, 2)) * dt / wheel_mass;
    velocity_cm_body = velocity_cm_body + sum(force_body, 2) * dt / body_mass;
    
    % Step4: Update position of centers of mass
    position_cm_wheels = position_cm_wheels + velocity_cm_wheels * dt;
    position_cm_body = position_cm_body + velocity_cm_body * dt;
    
    
    % Step5: Update angular momentum
    angular_momentum_wheels = angular_momentum_wheels + sum(cross(position_tilde_wheels, force_wheels, 1), 2) * dt;
    angular_momentum_body = angular_momentum_body + sum(cross(position_tilde_body, force_body), 2) * dt;
    
    % Step6: Update angular velocity
    parfor i = 1:4
        angular_velocity_wheels(:, i) = inertia_tensor_wheels(:, :, i) \ angular_momentum_wheels(:, i);
    end
    angular_velocity_body = inertia_tensor_body \ angular_momentum_body;
    
    % plot
%     frame = plot_vehicle(absolute_position_wheels, absolute_position_body);
    disp(clock)
    
    if mod(clock, save_every) == 0
        wheels_positions(:, :, :, clock / save_every) = absolute_position_wheels;
        body_positions(:, :, clock / save_every) = absolute_position_body;
    end
end

save("positions.mat", "wheels_positions", "body_positions", "timestep", "save_every")

% for clock = 1:(timestep / 16)
%     plot_vehicle(wheels_positions(:, :, :, clock), body_positions(:, :, clock));
% end