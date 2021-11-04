num_points = 20;

body_len = 2;
body_wid = 1.5;
axle_len = 0.1;
rin_radius = 1;
Xcenter_mass = [body_len, body_len, -body_len, -body_len, 0;
               body_wid, -body_wid, body_wid, -body_wid, 0;
               0, 0, 0, 0, 0];

Xwheel1 = wheels(rin_radius, num_points) + Xcenter_mass(:, 1);
Xwheel2 = wheels(rin_radius, num_points) + Xcenter_mass(:, 2);
Xwheel3 = wheels(rin_radius, num_points) + Xcenter_mass(:, 3);
Xwheel4 = wheels(rin_radius, num_points) + Xcenter_mass(:, 4);
Xbody = body(Xcenter_mass, body_len, body_wid, axle_len);

Xwheels = cat(3, Xwheel1, Xwheel2, Xwheel3, Xwheel4);
axis equal
axis manual
axis([-10, 10, -10, 10, -10, 10])
plot_vehicle(Xwheels, Xbody)

