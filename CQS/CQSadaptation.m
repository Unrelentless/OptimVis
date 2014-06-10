function [XYZTCS_c XYZwt_c] = CQSadaptation(XYZTCSt, XYZwr, XYZwt )
M=[0.7982 0.3389 -0.1371; 
  -0.5918 1.5512 0.0406; 
   0.0008 0.0239 0.9753];
Minv = [1.076450 -0.237662 0.161212; 
        0.410964 0.554342 0.034694; 
       -0.010954 -0.013389 1.024343];

   RGBwr = M * XYZwr';      % white illuminated by the reference illuminant
   RGBwt = M * XYZwt';      % white illuminated by the test source
   alpha = XYZwt(2)/XYZwr(2);   % Yw,test / Yw,ref
   
   XYZ = XYZTCSt';
   RGBTCSt = zeros(3,15);
   RGBTCSt_cor = zeros(3,15);
   XYZTCS_c = zeros(3,15);
   for i = 1:15
     RGBTCSt(:,i) = M * XYZ(:,i);  % samples illuminated by the test source
     RGBTCSt_cor(:,i) = RGBTCSt(:,i) .* alpha .* (RGBwr ./ RGBwt);
     XYZTCS_c(:,i) = Minv * RGBTCSt_cor(:,i);
   end
    XYZTCS_c = XYZTCS_c';
    % chromatic adaptation of the test source white 
    RGBwt_cor = RGBwt .* alpha .* (RGBwr ./ RGBwt);
    XYZwt_c = Minv * RGBwt_cor;
end