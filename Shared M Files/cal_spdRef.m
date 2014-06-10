function spdRef = cal_spdRef(cct, cmf, ss, lambdas )
lambdas = lambdas * 1e-9;
if cct < 5000 % use a black body for reference
    c1 = 3.741832e-16;
    c2 = 1.4388e-2;
    spdRef = c1 .* lambdas .^-5 ./ (exp( c2 ./ (cct*lambdas )) - 1);
    % spd normalization using value at lambda = 560
    spdRef = spdRef ./ spdRef(37);
elseif cct <= 25000  % use CIE standard illuminant D
    if cct <= 7000
        xd = -4.6070e9 / cct^3 + 2.9678e6 / cct^2 + 0.09911e3 / cct + 0.244063;
    else 
        xd = -2.0064e9 / cct^3 + 1.9018e6 / cct^2 + 0.24748e3 / cct + 0.237040;
    end
    yd = -3 *xd^2 + 2.870 * xd -0.275;
    M1 = (-1.3515 - 1.7703*xd + 5.9114*yd) / (0.0241 + 0.2562*xd - 0.7341*yd);
    M2 = (0.03 - 31.4424*xd + 30.0717*yd) / (0.0241 + 0.2562*xd - 0.7341*yd);
    
    spdRef = ss(:, 2) + M1*ss(:, 3) + M2*ss(:, 4);
    spdRef = interp1(ss(:, 1), spdRef, lambdas / 1e-9 ); % lambdas from 380 to 780
    spdRef(isnan(spdRef)) = 0.0; % if NaN set to 0
else
    spdRef = -1; % a silly CCT
end
    

