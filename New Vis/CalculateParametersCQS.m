
function [Qa, Qamin, e, Qi, cct, index] = CalculateParametersCQS(hObject, handles,SPD, munsellSPD)
mydata = getappdata(handles.figure1,'mydata');
[XYZt, xyzt] = spd2xyz(SPD, mydata.cmf);
uvt = xyz2uv(xyzt);       % required for calculating CCT
cct = cqs_cal_CCT_Ohno(uvt);  % calculate CCT of the test spd
if cct == -1     %silly CCT
    Qa = -1;
    e = -1;
    Qamin = -1;
    index = -1;
    Qi = -1;
    setappdata(handles.figure1,'mydata',mydata);
    return;
end  
% Colour quality scale (colour-rendering)
% cal ref illuminant(a Planckian radiator/phase of daylight)->Step 1 in CQS
spdCCT = cqs_cal_spdRef(cct, mydata.cmf, mydata.ss, mydata.lambdas);
setappdata(handles.figure1,'mydata',mydata);
% XYZ of reflective samples when illuminated by the test source->Step 2
XYZTCSt = cqsTCSr2xyz(SPD, mydata.cmf, munsellSPD);
% XYZ of reflective sample i when illuminated by the ref illuminant->Step 3
XYZTCSr = cqsTCSr2xyz(spdCCT, mydata.cmf, munsellSPD);
% XYZ of a perfect diffuser illuminated by the reference illuminant->Step 4
XYZwr = w2XYZ(spdCCT, mydata.cmf);
% XYZ of a perfect diffuser illuminated by the test source->Step 5
XYZwt = w2XYZ(SPD, mydata.cmf);
% CMCCAT2000 adaptation --> Step 6 in CQS including the test source white
[XYZTCStc XYZwtc]= CQSadaptation(XYZTCSt, XYZwr, XYZwt);
% CIE 1976 L*a*b* for each sample illuminated by reference illuminant-->Step 7
LABref = CIELab(XYZTCSr, XYZwr);
% CIE 1976 L*a*b* coordinates for each sample illuminated by test source-->Step 8
LABtest = CIELab(XYZTCStc, XYZwtc);
% Chroma of samples under the reference illuminant and test source-->Step 9
Cref = ((LABref(:,2)).^2 + (LABref(:,3)).^2).^(1/2);
Ctest = ((LABtest(:,2)).^2 + (LABtest(:,3)).^2).^(1/2);
% Differences in CIELAB-->Step 10
dL = LABtest(:,1) - LABref(:,1);
da = LABtest(:,2) - LABref(:,2);
db = LABtest(:,3) - LABref(:,3);
dC = Ctest - Cref;
dE = (dL.^2+da.^2+db.^2).^(1/2);
% Aplication of the saturation factor--> Step 11
dEsat = zeros(15,1);
for i=1:15
    if(dC(i)<= 0)
      dEsat(i) = dE(i); 
    else
      dEsat(i) = ( dE(i)^2 - dC(i)^2 ) ^ (1/2);
    end
end
% Root Mean Square--> Step 12
dErms = ((sum(dEsat.^2))/15)^(1/2);
% Scaling factor-->Step 13
Qarms = 100 - 3.1*dErms;
% 0-100 Scale conversion--> Step 14
Qas = 10*log(exp(Qarms/10)+1);
% CCT factor-->Step 15
if(cct < 3200)
  Mcct=cct^2*(-8.7586*10^(-8)) + cct*(5.5659*10^(-4)) + 0.11205; 
else
  Mcct=1;
end
% General CQS-->Step 16
Qa = Mcct*Qas;
% Special CQS - individual CQSi
Qipre = 100-3.1*dEsat;
Qis = 10*log(exp(Qipre/10)+1);
Qi = Mcct*Qis;
%min Qai and its index
[Qamin, index] = min(Qi);
e = sum(683 .* mydata.cmf(:, 2) .* SPD) / sum(SPD(:));

