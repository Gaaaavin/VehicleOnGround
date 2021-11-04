function plot_vehicle(X_wheels, X_body)
    clf
    axis equal
    axis manual
    grid on
    axis([-5, 8, -5, 5, -2, 4])
    view(20, 20)
    hold on
    
    [X,Y] = meshgrid(-5:8, -5:5);
%     Z = 0.2 * sin(X) .* sin(Y);
%     Z = 0.05 * (X .^ 2);
%     Z = 0.5 * sqrt(X .^ 2 + (Y+5) .^ 2);
    Z = 0.5 .* cos(X);
    surf(X,Y,Z)
    
    for i = 1:4
        X = X_wheels(:, :, i);
        plot3([X(1, :), X(1, 1)], ...
              [X(2, :), X(2, 1)], ...
              [X(3, :), X(3, 1)], '.-r')
        for j = 1:size(X, 2)
            plot3([X(1, j), X_body(1, 2*i-1)], [X(2, j), X_body(2, 2*i-1)], [X(3, j), X_body(3, 2*i-1)], 'b')
            plot3([X(1, j), X_body(1, 2*i)], [X(2, j), X_body(2, 2*i)], [X(3, j), X_body(3, 2*i)], 'b')
        end
    end
    for i = 1:4
        plot3([X_body(1, 2*i-1), X_body(1, 2*i)], ...
              [X_body(2, 2*i-1), X_body(2, 2*i)], ...
              [X_body(3, 2*i-1), X_body(3, 2*i)], '.-k', 'LineWidth', 1)
    end
    plot3([X_body(1, 2), X_body(1, 3)], ...
          [X_body(2, 2), X_body(2, 3)], ...
          [X_body(3, 2), X_body(3, 3)], '.-k', 'LineWidth', 1)
    plot3([X_body(1, 6), X_body(1, 7)], ...
          [X_body(2, 6), X_body(2, 7)], ...
          [X_body(3, 6), X_body(3, 7)], '.-k', 'LineWidth', 1) 
    mid1 = (X_body(:, 2) + X_body(:, 3)) / 2;
    mid2 = (X_body(:, 6) + X_body(:, 7)) / 2;
    plot3([mid1(1), mid2(1)], [mid1(2), mid2(2)], [mid1(3), mid2(3)], '.-k', 'LineWidth', 1)
    hold off
%     drawnow
end