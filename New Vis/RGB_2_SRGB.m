function [SRGB] = RGB_2_SRGB(RGB, gamma, K1)
%RGB_2_SRGB Summary of this function goes here
%   Detailed explanation goes here

for i=1:16
    
    for j=1:3
    SRGB_temp(j,i) = (((RGB(j,i)/255).^(1/gamma))+(1-K1)).*(255/K1);
    SRGB(j,i) = abs(SRGB_temp(j,i)/255);
    if SRGB(j,i)>1
        SRGB(j,i)=1;
    elseif SRGB(j,i)<0
        SRGB(j,i)=0;
    else
        SRGB(j,i)=SRGB(j,i);
    end
    end
end
end

