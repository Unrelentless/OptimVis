function cct = cal_CCT_est(uv, xyz)  
 %McCamy's approximation algorithm to estimate the cct from xy

 n = (xyz(1)-0.3320) / (xyz(2)-0.1858);
 cct = -449*n^3+3525*n^2-6823.3*n+5520.33;
end


 
