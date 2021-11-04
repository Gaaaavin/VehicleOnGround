function nabla = compute_nabla(x, y, z)
%     nabla = [-0.2 * x; 
%         0;
%         1]; %parabola
%     nabla = [-0.5 * x / sqrt(x ^ 2 + y ^ 2);
%              -0.5 * y / sqrt(x ^ 2 + y ^ 2);
%              1]; %cone
    nabla = [-(1 / sqrt(3)); 0; 1];
end