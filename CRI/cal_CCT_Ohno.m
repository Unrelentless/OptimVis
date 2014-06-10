function cct = cal_CCT_Ohno(uv)  
xyzBars = load('bars.txt');
lambdas = [360:1:830];
lam = lambdas'*0.000000001;
e1 = [0; 0.1; 0.2; 0.3; 0.4; 0.5; 0.6; 0.7; 0.8; 0.9; 1];
e2 = [0.1; 0.2; 0.3; 0.4; 0.5; 0.6; 0.7; 0.8; 0.9; 1];
c1 = 3.7415e-16;
c2 = 0.014388;

% Table 1
basicCCT = load('basicCCT.txt');
basicCCT(:, 4) = ((uv(:,1) - basicCCT(:,2)).^2 + (uv(:,2) - basicCCT(:,3)).^2).^0.5;
[m,I] = min(basicCCT(:, 4));
tm = basicCCT(I-1:I+1, 1);

%Table 2
t = [tm(1) + (tm(2) -tm(1))*e1; tm(2) + (tm(3) -tm(2))*e2];
for i = 1:21
    p = c1 ./ lam .^5 ./ (exp(c2 ./ (t(i) .* lam))-1);
    p1 = p ./ p(201);
    p2 = p1' * xyzBars;
    XYZ = p2 / p(2) *100;
    xyz = XYZ / sum(XYZ);
    s = -xyz(1) + 6 * xyz(2) + 1.5;
    uvcct(i,1) = 2 * xyz(1) / s;
    uvcct(i,2) = 3 * xyz(2) / s;
end
d = ((uv(:,1) - uvcct(:,1)).^2 + (uv(:,2) - uvcct(:,2)).^2).^0.5;
[m,I] = min(d);
tm = t(I-1:I+1, 1);

%Table 3
t = [tm(1) + (tm(2) -tm(1))*e1; tm(2) + (tm(3) -tm(2))*e2];
for i = 1:21
    p = c1 ./ lam .^5 ./ (exp(c2 ./ (t(i) .* lam))-1);
    p1 = p ./ p(201);
    p2 = p1' * xyzBars;
    XYZ = p2 / p(2) *100;
    xyz = XYZ / sum(XYZ);
    s = -xyz(1) + 6 * xyz(2) + 1.5;
    uvcct(i,1) = 2 * xyz(1) / s;
    uvcct(i,2) = 3 * xyz(2) / s;
end
d = ((uv(:,1) - uvcct(:,1)).^2 + (uv(:,2) - uvcct(:,2)).^2).^0.5;
[m,I] = min(d);
tm = t(I-1:I+1, 1);

%Parabolic solution
a = d(I-1) / (t(I-1) - t(I)) / (t(I-1) - t(I+1)) ;
b = d(I) / (t(I) - t(I-1)) / (t(I) - t(I+1));
c = d(I+1) / (t(I+1) - t(I-1)) / (t(I+1) - t(I));
A = a + b + c;
B = -(a*(t(I+1)+t(I)) + b*(t(I-1)+t(I+1)) + c*(t(I)+t(I-1)));
C = a*t(I)*t(I+1) + b*t(I-1)*t(I+1) + c*t(I-1)*t(I);
cctp = -(B / 2 / A);

%Triangular solution
dist = sqrt( (uvcct(I+1,1)-uvcct(I-1,1))^2 + (uvcct(I+1, 2)-uvcct(I-1,2))^2 );
x = ( (d(I-1))^2 - (d(I+1))^2 + dist^2) / (2 * dist);
cctt = t(I-1) + ((t(I+1) - t(I-1))* x / dist);

duv = A*cctp^2 + B*cctp + C;
if(duv < 0.0005)
    cct = cctt;
else
    cct = cctp;
end

end


 
