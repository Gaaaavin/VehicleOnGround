function H = compute_h(x, y, z)
%     H = z - 0.05 * (x .^ 2); % parabola
%     H = z - (1 * sqrt(3)) * x; % cone
    H = z - (1 / sqrt(3)) * x; % up slope
end