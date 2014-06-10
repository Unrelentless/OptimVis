function [uv] = xyz2uv(xyz)
s = -2*xyz(1) + 12 * xyz(2) + 3;
uv(1) = 4 * xyz(1) / s;
uv(2) = 6 * xyz(2) / s;