function [Ra, Rb, Rc14, Ri, dE] = cal_CRI(UVWr, UVWt)
dE = ( ( UVWr(:, 1)-UVWt(:, 1) ).^2+( UVWr(:, 2)-UVWt(:, 2) ).^2+( UVWr(:, 3)-UVWt(:, 3) ).^2 ) .^(1/2);
Ri = 100 - 4.6 * dE;
Ra = sum( Ri(1:8) ) / 8;
Rb = sum( Ri(9:14)) / 6;
Rc14 = sum( Ri ) / 14;

