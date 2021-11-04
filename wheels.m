function X_tilde = wheels(radius, num_points)
    X = zeros(3, num_points);
    d_theta = 2 * pi / num_points;
    
    for i = 0:num_points-1
        X(:, i+1) = [radius*cos(i*d_theta); 0; radius*sin(i*d_theta)];
    end
    
%     theta = -theta;
%     rotation = [1, 0         , 0          ;
%                 0, cos(theta), -sin(theta); 
%                 0, sin(theta), cos(theta) ];
%             
%     X = rotation * X;
    
    X_tilde = cat(3, X, X, X, X);
end