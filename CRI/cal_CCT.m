function cct = cal_CCT(uv,isotemp )  

%reciprocal megakelvin MK-1  u  v  slope of isotemp lines
%isotemp = load ('isotemp.txt');

cct = -1;

% Robertson's method
i = 1;
mi = isotemp(1, 1);
ui = isotemp(1, 2);
vi = isotemp(1, 3);
ti = isotemp(1, 4);
di = ((uv(2) - vi) - ti*(uv(1) - ui)) / ((1+ti^2)^0.5);

for j = 2:31
    uj = isotemp(j, 2);
    vj = isotemp(j, 3);
    tj = isotemp(j, 4);
    dj = ((uv(2)-vj) - tj*(uv(1) - uj)) / ((1+tj^2)^0.5);
    
    if di/dj < 0
        break;
    else
        di = dj;
        i = i + 1;
    end        
end

dist = ((uv(1) - uj)^2 + (uv(2) - vj)^2) ^ 0.5;
if i ~= 1 && dist < 0.05
    mi = isotemp(i, 1);
    mj = isotemp(j, 1);
    cct = 1000000 / ( mi + di /(di-dj)*(mj - mi) );
end

end


 
