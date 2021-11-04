function new_Xtilde = Rodrigues(X_tilde, omega)
    if norm(omega) == 0
        new_Xtilde = X_tilde;
    else
        unit_omega = omega / norm(omega);
        P = unit_omega' * unit_omega;
        new_Xtilde = P * X_tilde + cos(norm(omega)) * (1 - P) * X_tilde + ...
            sin(norm(omega)) * cross(unit_omega .* ones(size(X_tilde)), X_tilde, 1);
    end
end