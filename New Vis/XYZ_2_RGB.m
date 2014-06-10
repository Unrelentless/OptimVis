function [RGB] = XYZ_2_RGB(XYZ, CRT_calc)
%XYZ_2_RGB Summary of this function goes here
%   Detailed explanation goes here

for i=1:16

    RGB(:,i) = CRT_calc*XYZ(:,i);
    
end
end

