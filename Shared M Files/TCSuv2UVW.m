function [UVW] = TCSuv2UVW(XYZtcs, uvTCS, uvSource)
for i = 1:14
    UVW(i, 3) = 25 * XYZtcs(i, 2).^(1/3) - 17;
    UVW(i, 1) = 13 * UVW(i, 3) * (uvTCS(i, 1) - uvSource(1));
    UVW(i, 2) = 13 * UVW(i, 3) * (uvTCS(i, 2) - uvSource(2)); 
end
