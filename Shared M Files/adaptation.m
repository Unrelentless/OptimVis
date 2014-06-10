function [uvKries] = adaptation(uvTsource, uvRsource, uvTCSt)
ct = (4 - uvTsource(1) - 10*uvTsource(2)) / uvTsource(2);
dt = (1.708*uvTsource(2) - 1.481*uvTsource(1) + 0.404) / uvTsource(2);
cr = (4 - uvRsource(1) - 10*uvRsource(2)) / uvRsource(2);
dr = (1.708*uvRsource(2) - 1.481*uvRsource(1) + 0.404) / uvRsource(2);

for i = 1:14
   ci = (4 - uvTCSt(i,1) - 10*uvTCSt(i,2)) / uvTCSt(i,2);
   di = (1.708*uvTCSt(i,2) - 1.481*uvTCSt(i,1) + 0.404) / uvTCSt(i,2);    
   uvKries(i, 1) = (10.872 + 0.404*(cr/ct)*ci - 4*(dr/dt)*di) / (16.518 + 1.481*(cr/ct)*ci - (dr/dt)*di);
   uvKries(i, 2) = 5.520 / (16.518 + 1.481*(cr/ct)*ci - (dr/dt)*di);
end