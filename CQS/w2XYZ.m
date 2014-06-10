function [XYZ] = w2XYZ(spd, cmf)
    p(:, 1) = sum(spd .* cmf(:, 1));
    p(:, 2) = sum(spd .* cmf(:, 2));
    p(:, 3) = sum(spd .* cmf(:, 3));
    s = sum(spd .* cmf(:, 2));
    XYZ(1) = p(:, 1) / s * 100;
    XYZ(2) = p(:, 2) / s * 100;
    XYZ(3) = p(:, 3) / s * 100;
end