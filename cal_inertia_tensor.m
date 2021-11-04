function I = cal_inertia_tensor(X, M_each)
    I = zeros(3, 3);
    I(1, 1) = sum(((X(2, :) .^ 2) + (X(3, :) .^ 2)) .* M_each);
    I(1, 2) = sum((-X(1, :) .* X(2, :)) .* M_each);
    I(1, 3) = sum((-X(1, :) .* X(3, :)) .* M_each);
    I(2, 1) = sum((-X(2, :) .* X(1, :)) .* M_each);
    I(2, 2) = sum(((X(1, :) .^ 2) + (X(3, :) .^ 2)) .* M_each);
    I(2, 3) = sum((-X(2, :) .* X(3, :)) .* M_each);
    I(3, 1) = sum((-X(3, :) .* X(1, :)) .* M_each);
    I(3, 2) = sum((-X(3, :) .* X(2, :)) .* M_each);
    I(3, 3) = sum(((X(1, :) .^ 2) + (X(2, :) .^ 2)) .* M_each);
end