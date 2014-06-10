function [XYZ] = calc_XYZ(SPD,munsell,xyz, colour_mult)
%CALC_XYZ Summary of this function goes here
%   Detailed explanation goes here
y_norm = sum(SPD.*xyz(:, 2));
    
    for i=1:16
          %calculate the XYZ using the reflectance samples  
        X_R(i) = sum(colour_mult.*SPD.*munsell(:,i).*xyz(:,1));
        Y_R(i) = sum(colour_mult.*SPD.*munsell(:,i).*xyz(:,2));
        Z_R(i) = sum(colour_mult.*SPD.*munsell(:,i).*xyz(:,3));

        %normalize the results for y
        X(1, i) = X_R(1, i) / y_norm * 100;
        Y(1, i) = Y_R(1, i) / y_norm * 100;
        Z(1, i) = Z_R(1, i) / y_norm * 100;
    end

XYZ = [X;Y;Z];
end

