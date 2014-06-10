function [uv] = TCSxyz2uv(xyz)
s = -xyz(:, 1) + 6*xyz(:, 2)+ 1.5;
uv(:,1) = 2*xyz(:, 1)./s;
uv(:,2) = 3*xyz(:, 2)./s;
