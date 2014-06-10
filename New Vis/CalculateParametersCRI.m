function [Ra, Rb, Rc14, Ri, e, cct] = CalculateParametersCRI(hObject, handles,SPD, munsellSPD)
mydata = getappdata(handles.figure1,'mydata');

    % Calculate XYZ and xyz of the test light source from its spd 
    [XYZt, xyzt] = spd2xyz(SPD, mydata.cmf);
    % Calculate uv from the xyz values 
    uvt = xyz2uv(xyzt);
    % Calculate CCT for the test source from its uv
    cct = cal_CCT_Ohno(uvt);
    % Calculate the reference source from CTT
    spdCCT = cal_spdRef(cct, mydata.cmf, mydata.ss, mydata.lambdas);
    mydata.spdCCT = spdCCT;
    % Calculate XYZ  and xyz of the reference source
    [XYZr, xyzr] = spd2xyz(spdCCT,mydata.cmf );
    % Calculate uv from the xyz values of the reference source
    uvr = xyz2uv(xyzr);
    % Calculate xyz of the test colour samples illuminated by the test source 
    [XYZTCSt, xyzTCSt] = TCSr2xyz(SPD, mydata.cmf, munsellSPD);
    % Calculate xyz of the test colour samples illuminated by the reference source 
    [XYZTCSr, xyzTCSr] = TCSr2xyz(spdCCT, mydata.cmf, munsellSPD);
    % Calculate uv of the test colour samples illuminated by the test source
    uvTCSt = TCSxyz2uv(xyzTCSt);
    % Calculate uv of the test colour samples illuminated by the reference source
    uvTCSr = TCSxyz2uv(xyzTCSr);
    % Adapt colour of the test colour samples illuminated by the test source to the reference source
    uvKries = adaptation(uvt, uvr, uvTCSt);
    % Calculate UVW of the test colour samples illuminated by the test light source
    UVWt = TCSuv2UVW(XYZTCSt, uvKries, uvr);
    % Calculate UVW of the test colour samples illuminated by the reference light source
    UVWr = TCSuv2UVW(XYZTCSr, uvTCSr, uvr);
    % Calculate CRI indices Ra, Rb, Rc14, Ri of the test source
    [Ra, Rb, Rc14, Ri, dE] = cal_CRI(UVWr, UVWt);
    Ra = round(Ra*10)/10;
    Rb = round(Rb*10)/10;
    Rc14 = round(Rc14*10)/10;
    for i=1:14
        Ri(i) = round(Ri(i)*10)/10;
    end
    % Luminous efficacy
    e = sum(683 .* mydata.cmf(:, 2) .* SPD) / sum(SPD(:));
    e = round(e);

    guidata(hObject, handles);