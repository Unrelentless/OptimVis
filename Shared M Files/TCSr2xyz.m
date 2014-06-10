function [XYZ xyz] = TCSr2xyz(spd, cmf, r)
for i = 1:14
    p(:, 1) = sum(r(:, i) .* spd .* cmf(:, 1));
    p(:, 2) = sum(r(:, i) .* spd .* cmf(:, 2));
    p(:, 3) = sum(r(:, i) .* spd .* cmf(:, 3));
    s = sum(spd .* cmf(:, 2));
    XYZ(i,1) = p(:, 1) / s * 100;
    XYZ(i,2) = p(:, 2) / s * 100;
    XYZ(i,3) = p(:, 3) / s * 100;
    xyz(i, :) = XYZ(i, :) / sum( XYZ(i, :) );
end
    



