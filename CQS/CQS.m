function varargout = CQS(varargin)
% CQS M-file for CQS.fig
% Last Modified by GUIDE v2.5 03-Apr-2013 15:32:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CQS_OpeningFcn, ...
                   'gui_OutputFcn',  @CQS_OutputFcn, ...
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


% --- Executes just before CQS is made visible.
function CQS_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for CQS
handles.output = hObject;
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% sets mydata structure
format long;
mydata.cmf = dlmread('CMF.txt');
mydata.isotemp = dlmread ('isotemp.txt');
mydata.r = dlmread('CQS_TCS.txt');
mydata.ss = dlmread('ss.txt');
mydata.range = dlmread('lambdas.txt');
setappdata(hObject,'mydata',mydata);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
mydata = getappdata(handles.figure1,'mydata');
% choose the LEDs file to be optimised
[filenamespd,pathnamespd]=uigetfile('*.txt', 'Choose a spd file');
if (~isequal(filenamespd,0) | ~isequal(pathnamespd,0));
    file = fullfile(pathnamespd,filenamespd);
    fid = fopen(file, 'wt'); % opens the file for writing 
end;

setappdata(handles.figure1,'mydata',mydata);
guidata(hObject, handles);

function varargout = CQS_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
mydata = getappdata(handles.figure1,'mydata');
% choose the LEDs file to be optimised
[filenamespd,pathnamespd]=uigetfile('*.txt', 'Choose a spd file');
if (~isequal(filenamespd,0) | ~isequal(pathnamespd,0))
    % freeze the entry
    filespd = fullfile(pathnamespd,filenamespd);
    spd = dlmread(filespd);
    
    fileSave = fullfile(pathnamespd,strcat('results_', filenamespd));
    fid = fopen(fileSave, 'wt'); % opens the file for writing
    
    set(handles.editFilename, 'String', filenamespd );
      
    [Qa, e, cct, Qamin, in, Qi] = calcscore(handles, spd); 
    
    fprintf(fid, 'Qa=%u\ne=%u\nCCT=%u\nQimin=%u\nimin=%u\nQ2=%u\n', ...
      round(Qa), round(e),round(cct),round(Qamin), round(in),round(Qi(1))); 
    fprintf(fid, 'Q2=%u\nQ3=%u\nQ4=%u\nQ5=%u\nQ6=%u\nQ7=%u\nQ8=%u\n', ...
      round(Qi(2)), round(Qi(3)),round(Qi(4)),round(Qi(5)), round(Qi(6)),...
      round(Qi(7)), round(Qi(8)));  
    fprintf(fid, 'Q9=%u\nQ10=%u\nQ11=%u\nQ12=%u\nQ13=%u\nQ14=%u\nQ15=%u\n', ...
      round(Qi(9)), round(Qi(10)),round(Qi(11)),round(Qi(12)), round(Qi(13)),...
      round(Qi(14)), round(Qi(15))); 
    fclose(fid);
    setappdata(handles.figure1,'mydata',mydata);
 end;

%setappdata(handles.figure1,'mydata',mydata);
guidata(hObject, handles);

function [Qa, e, cct, Qamin, index, Qi] = calcscore(handles, spd)
mydata = getappdata(handles.figure1,'mydata');
[XYZt, xyzt] = spd2xyz(spd, mydata.cmf);
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
spdCCT = cqs_cal_spdRef(cct, mydata.cmf, mydata.ss, mydata.range);
setappdata(handles.figure1,'mydata',mydata);
% XYZ of reflective samples when illuminated by the test source->Step 2
XYZTCSt = cqsTCSr2xyz(spd, mydata.cmf, mydata.r);
% XYZ of reflective sample i when illuminated by the ref illuminant->Step 3
XYZTCSr = cqsTCSr2xyz(spdCCT, mydata.cmf, mydata.r);
% XYZ of a perfect diffuser illuminated by the reference illuminant->Step 4
XYZwr = w2XYZ(spdCCT, mydata.cmf);
% XYZ of a perfect diffuser illuminated by the test source->Step 5
XYZwt = w2XYZ(spd, mydata.cmf);
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
e = sum(683 .* mydata.cmf(:, 2) .* spd) / sum(spd(:));

set(handles.editQa , 'String', num2str(round(Qa))); % Qa
set(handles.editE , 'String', num2str(round(e))); % e
set(handles.editCCT , 'String', num2str(round(cct))); % CCT
set(handles.editimin , 'String', num2str(index)); % index of the worst Qi
set(handles.editQamin , 'String', num2str(round(Qamin))); % Qamin
set(handles.editQ1 , 'String', num2str(round(Qi(1)))); % Q1
set(handles.editQ2 , 'String', num2str(round(Qi(2)))); % Q2
set(handles.editQ3 , 'String', num2str(round(Qi(3)))); % Q3
set(handles.editQ4 , 'String', num2str(round(Qi(4)))); % Q4
set(handles.editQ5 , 'String', num2str(round(Qi(5)))); % Q5
set(handles.editQ6 , 'String', num2str(round(Qi(6)))); % Q6
set(handles.editQ7 , 'String', num2str(round(Qi(7)))); % Q7
set(handles.editQ8 , 'String', num2str(round(Qi(8)))); % Q8
set(handles.editQ9 , 'String', num2str(round(Qi(9)))); % Q9
set(handles.editQ10 , 'String', num2str(round(Qi(10)))); % Q10
set(handles.editQ11 , 'String', num2str(round(Qi(11)))); % Q11
set(handles.editQ12 , 'String', num2str(round(Qi(12)))); % Q12
set(handles.editQ13 , 'String', num2str(round(Qi(13)))); % Q13
set(handles.editQ14 , 'String', num2str(round(Qi(14)))); % Q14
set(handles.editQ15 , 'String', num2str(round(Qi(15)))); % Q15

setappdata(handles.figure1,'mydata',mydata); 


function editFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editCCT_Callback(hObject, eventdata, handles)
% hObject    handle to editCCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCCT as text
%        str2double(get(hObject,'String')) returns contents of editCCT as a double


% --- Executes during object creation, after setting all properties.
function editCCT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCCT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQa_Callback(hObject, eventdata, handles)
% hObject    handle to editQa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQa as text
%        str2double(get(hObject,'String')) returns contents of editQa as a double


% --- Executes during object creation, after setting all properties.
function editQa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQamin_Callback(hObject, eventdata, handles)
% hObject    handle to editQamin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQamin as text
%        str2double(get(hObject,'String')) returns contents of editQamin as a double


% --- Executes during object creation, after setting all properties.
function editQamin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQamin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editimin_Callback(hObject, eventdata, handles)
% hObject    handle to editimin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editimin as text
%        str2double(get(hObject,'String')) returns contents of editimin as a double


% --- Executes during object creation, after setting all properties.
function editimin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editimin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ1_Callback(hObject, eventdata, handles)
% hObject    handle to editQ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ1 as text
%        str2double(get(hObject,'String')) returns contents of editQ1 as a double


% --- Executes during object creation, after setting all properties.
function editQ1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ2_Callback(hObject, eventdata, handles)
% hObject    handle to editQ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ2 as text
%        str2double(get(hObject,'String')) returns contents of editQ2 as a double


% --- Executes during object creation, after setting all properties.
function editQ2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ3_Callback(hObject, eventdata, handles)
% hObject    handle to editQ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ3 as text
%        str2double(get(hObject,'String')) returns contents of editQ3 as a double


% --- Executes during object creation, after setting all properties.
function editQ3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ4_Callback(hObject, eventdata, handles)
% hObject    handle to editQ4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ4 as text
%        str2double(get(hObject,'String')) returns contents of editQ4 as a double


% --- Executes during object creation, after setting all properties.
function editQ4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ5_Callback(hObject, eventdata, handles)
% hObject    handle to editQ5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ5 as text
%        str2double(get(hObject,'String')) returns contents of editQ5 as a double


% --- Executes during object creation, after setting all properties.
function editQ5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ6_Callback(hObject, eventdata, handles)
% hObject    handle to editQ6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ6 as text
%        str2double(get(hObject,'String')) returns contents of editQ6 as a double


% --- Executes during object creation, after setting all properties.
function editQ6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ7_Callback(hObject, eventdata, handles)
% hObject    handle to editQ7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ7 as text
%        str2double(get(hObject,'String')) returns contents of editQ7 as a double


% --- Executes during object creation, after setting all properties.
function editQ7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ8_Callback(hObject, eventdata, handles)
% hObject    handle to editQ8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ8 as text
%        str2double(get(hObject,'String')) returns contents of editQ8 as a double


% --- Executes during object creation, after setting all properties.
function editQ8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ9_Callback(hObject, eventdata, handles)
% hObject    handle to editQ9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ9 as text
%        str2double(get(hObject,'String')) returns contents of editQ9 as a double


% --- Executes during object creation, after setting all properties.
function editQ9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ10_Callback(hObject, eventdata, handles)
% hObject    handle to editQ10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ10 as text
%        str2double(get(hObject,'String')) returns contents of editQ10 as a double


% --- Executes during object creation, after setting all properties.
function editQ10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ11_Callback(hObject, eventdata, handles)
% hObject    handle to editQ11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ11 as text
%        str2double(get(hObject,'String')) returns contents of editQ11 as a double


% --- Executes during object creation, after setting all properties.
function editQ11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ12_Callback(hObject, eventdata, handles)
% hObject    handle to editQ12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ12 as text
%        str2double(get(hObject,'String')) returns contents of editQ12 as a double


% --- Executes during object creation, after setting all properties.
function editQ12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ13_Callback(hObject, eventdata, handles)
% hObject    handle to editQ13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ13 as text
%        str2double(get(hObject,'String')) returns contents of editQ13 as a double


% --- Executes during object creation, after setting all properties.
function editQ13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ14_Callback(hObject, eventdata, handles)
% hObject    handle to editQ14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ14 as text
%        str2double(get(hObject,'String')) returns contents of editQ14 as a double


% --- Executes during object creation, after setting all properties.
function editQ14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQ15_Callback(hObject, eventdata, handles)
% hObject    handle to editQ15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQ15 as text
%        str2double(get(hObject,'String')) returns contents of editQ15 as a double


% --- Executes during object creation, after setting all properties.
function editQ15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQ15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbuttonLoad_CreateFcn(hObject, eventdata, handles)



function editE_Callback(hObject, eventdata, handles)
% hObject    handle to editE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editE as text
%        str2double(get(hObject,'String')) returns contents of editE as a double


% --- Executes during object creation, after setting all properties.
function editE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
