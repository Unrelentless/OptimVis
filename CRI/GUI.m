function varargout = GUI(varargin)
% Last Modified by GUIDE v2.5 03-Apr-2013 15:33:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function figure1_CreateFcn(hObject, eventdata, handles)

format long;

mydata.cmf = dlmread('CMF.txt');
mydata.isotemp = dlmread ('isotemp.txt');
mydata.r = dlmread('TCS.txt');
mydata.ss = dlmread('ss.txt');
mydata.lambdas = dlmread('lambdas.txt');

mydata.spd = [];
setappdata(hObject,'mydata',mydata);

function pbLoad_Callback(hObject, eventdata, handles)
[filename,pathname]=uigetfile('*.txt');
if ~isequal(filename,0) | ~isequal(pathname,0)
    loadDataName = fullfile(pathname,filename);
    spd = load(loadDataName);
    mydata = getappdata(handles.figure1,'mydata');
    mydata.spd = spd;

    % Calculate XYZ and xyz of the test light source from its spd 
    [XYZt, xyzt] = spd2xyz(mydata.spd, mydata.cmf);
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
    [XYZTCSt, xyzTCSt] = TCSr2xyz(mydata.spd, mydata.cmf, mydata.r);
    % Calculate xyz of the test colour samples illuminated by the reference source 
    [XYZTCSr, xyzTCSr] = TCSr2xyz(spdCCT, mydata.cmf, mydata.r);
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
    e = sum(683 .* mydata.cmf(:, 2) .* mydata.spd) / sum(mydata.spd(:));
    e = round(e);
    set(handles.efficacy, 'String', num2str(e));
    setappdata(handles.figure1,'mydata',mydata); 

    set(handles.eFilename, 'String', filename);
    cct = round(cct);
    set(handles.cct , 'String', num2str(cct));
    set(handles.ra , 'String', num2str(Ra));
    set(handles.rb , 'String', num2str(Rb));
    set(handles.rc , 'String', num2str(Rc14));
    set(handles.r1 , 'String', num2str(Ri(1)));
    set(handles.r2 , 'String', num2str(Ri(2)));
    set(handles.r3 , 'String', num2str(Ri(3)));
    set(handles.r4 , 'String', num2str(Ri(4)));
    set(handles.r5 , 'String', num2str(Ri(5)));
    set(handles.r6 , 'String', num2str(Ri(6)));
    set(handles.r7 , 'String', num2str(Ri(7)));
    set(handles.r8 , 'String', num2str(Ri(8)));
    set(handles.r9 , 'String', num2str(Ri(9)));
    set(handles.r10 , 'String', num2str(Ri(10)));
    set(handles.r11 , 'String', num2str(Ri(11)));
    set(handles.r12 , 'String', num2str(Ri(12)));
    set(handles.r13 , 'String', num2str(Ri(13)));
    set(handles.r14 , 'String', num2str(Ri(14)));

    guidata(hObject, handles);
end


function bSave_Callback(hObject, eventdata, handles)
[filename,pathname]=uiputfile('*.txt');
if ~isequal(filename,0) | ~isequal(pathname,0)
    saveDataName = fullfile(pathname,filename);
    fid = fopen(saveDataName, 'wt');
    fprintf(fid, 'Data: %s\n\n', get(handles.eFilename, 'String'));
    fprintf(fid, 'Lumious efficacy: %s lm/W\n\n', get(handles.efficacy, 'String'));
    fprintf(fid, 'CCT: %s\n\n', get(handles.cct, 'String'));
    fprintf(fid, 'Ra: %s\n\n', get(handles.ra, 'String'));
    fprintf(fid, 'Rb: %s\n\n', get(handles.rb, 'String'));
    fprintf(fid, 'Rc: %s\n\n', get(handles.rc, 'String'));
    fprintf(fid, 'R1: %s\n\n', get(handles.r1, 'String'));
    fprintf(fid, 'R2: %s\n\n', get(handles.r2, 'String'));
    fprintf(fid, 'R3: %s\n\n', get(handles.r3, 'String'));
    fprintf(fid, 'R4: %s\n\n', get(handles.r4, 'String'));
    fprintf(fid, 'R5: %s\n\n', get(handles.r5, 'String'));
    fprintf(fid, 'R6: %s\n\n', get(handles.r6, 'String'));
    fprintf(fid, 'R7: %s\n\n', get(handles.r7, 'String'));
    fprintf(fid, 'R8: %s\n\n', get(handles.r8, 'String'));
    fprintf(fid, 'R9: %s\n\n', get(handles.r9, 'String'));
    fprintf(fid, 'R10: %s\n\n', get(handles.r10, 'String'));
    fprintf(fid, 'R11: %s\n\n', get(handles.r11, 'String'));
    fprintf(fid, 'R12: %s\n\n', get(handles.r12, 'String'));
    fprintf(fid, 'R13: %s\n\n', get(handles.r13, 'String'));
    fprintf(fid, 'R14: %s\n\n', get(handles.r14, 'String'));
    fclose(fid);
end

function bSaveSpd_Callback(hObject, eventdata, handles)
[filename,pathname]=uiputfile('*.txt');
if ~isequal(filename,0) | ~isequal(pathname,0)
    saveDataName = fullfile(pathname,filename);
    fid = fopen(saveDataName, 'wt');
    fprintf(fid, 'Reference source spd:\n\n');
    mydata = getappdata(handles.figure1,'mydata');
    lambdas = 380;
    for i = 1:81
       fprintf(fid, '%d %0.3f\n', lambdas, mydata.spdCCT(i));
       lambdas = lambdas + 5;
    end
    fclose(fid);
end

% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit20_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit21_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit22_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit23_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit25_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit26_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit27_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit28_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit29_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit30_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit31_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit32_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cct_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ra_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rb_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cct_est_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit52_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function efficacy_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function eFilename_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
