function [XYZ xyz] = spd2xyz(spd, cmf)
p = spd'*cmf;
XYZ = p /p(2) * 100;
xyz = XYZ/sum(XYZ);

















