%Name:      VisMenu
%Version:   0.76
%By:        Pavel Boryseiko
%This program compares light sources using the CRI or CQS metric in 1nm
%or 5nm resolutions. It allows the loading of custom SPDs for comparison with
%reference light sources as well as stores the loaded SPD in a text file
%to be called back later without having to re-load it.
%

function varargout = VisMenu(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VisMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @VisMenu_OutputFcn, ...
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


% --- Executes just before VisMenu is made visible.
function VisMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VisMenu (see VARARGIN)


% Choose default command line output for VisMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

format long;
%read in 5nm SPDs from txt files.
mydata.SPDs_CIE = dlmread ('Normalized_CIE_Illuminants.txt');
mydata.SPDs_F1 = dlmread ('Normalized_Fluorescents.txt');
mydata.SPDs_F2 = dlmread ('Normalized_Fluorescents2.txt');
mydata.SPDs_HP = dlmread ('Normalized_HP.txt');
mydata.SPDs_LED3 = dlmread ('LEDOpt.txt');
mydata.SPDs_LED2 = dlmread ('Normalized_LEDPhil.txt');
mydata.SPDs_LED1 = dlmread ('Normalized_LEDResearch.txt');
%read in 1nm SPDs from txt files.
mydata.SPDs_CIE_1nm = dlmread ('Normalized_CIE_Illuminants_1nm.txt');
mydata.SPDs_F1_1nm = dlmread ('Fluorescents_1nm.txt');
mydata.SPDs_F2_1nm = dlmread ('Fluorescents2_1nm.txt');
mydata.SPDs_HP_1nm = dlmread ('HP_1nm.txt');
mydata.SPDs_LED3_1nm = dlmread ('LEDOpt_1nm.txt');
mydata.SPDs_LED2_1nm = dlmread ('LEDPhil_1nm.txt');
mydata.SPDs_LED1_1nm = dlmread ('LEDResearch_1nm.txt');
%read in other paramters
mydata.xyz = dlmread('xyz.txt');
mydata.CRT_calc = dlmread('CRT_calc.txt');
mydata.munsell = dlmread('Munsell_CRI.txt');
mydata.resolution = '5nm'; %inititalize resolution
mydata.colourMetric = 'CRI'; %initialize coour metric
mydata.gamma = 0; %initialize Gamma
mydata.K1 = 0;  %initiialize K1
%create the 3D array of all SPDs in this order:
%CIE, F1, F2, HP, LED1, LED2, LED3
mydata.array_5nm = cat(3, mydata.SPDs_CIE(:, :), mydata.SPDs_F1(:, :), ...
    mydata.SPDs_F2(:, :), mydata.SPDs_HP(:, :), mydata.SPDs_LED1(:, :), ...
    mydata.SPDs_LED2(:, :), mydata.SPDs_LED3(:, :));
mydata.array_1nm = cat(3, mydata.SPDs_CIE_1nm(:, :), mydata.SPDs_F1_1nm(:, :), ...
    mydata.SPDs_F2_1nm(:, :), mydata.SPDs_HP_1nm(:, :), mydata.SPDs_LED1_1nm(:, :), ...
    mydata.SPDs_LED2_1nm(:, :), mydata.SPDs_LED3_1nm(:, :));

setappdata(hObject,'mydata',mydata);



% --- Outputs from this function are returned to the command line.
function varargout = VisMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in testList.
function testList_Callback(hObject, eventdata, handles)
% hObject    handle to testList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testList
mydata = getappdata(handles.figure1,'mydata');
%check if gamma has been set
if mydata.gamma > 0
set(handles.testTypeList,'Value',1); %returns cursor to default position
%check if in 5nm resolution mode
     if strcmp(mydata.resolution,'5nm') == 1
switch get(handles.testList,'Value')      
    case 1 %if Standard Illuminats
        set(handles.testTypeList,'visible', 'on', 'String', importdata('CIEStandards.txt'));
    case 2 %if Fluoro1
        set(handles.testTypeList,'visible', 'on', 'String', importdata('Fluorescents15-2.txt'));
    case 3 %if Fluoro2
        set(handles.testTypeList,'visible', 'on', 'String', importdata('Fluorescents15-3.txt'));
    case 4 %if HP
        set(handles.testTypeList,'visible', 'on', 'String', importdata('HighPressure.txt'));        
    case 5 %if LED1
        set(handles.testTypeList,'visible', 'on', 'String', importdata('ResearchLEDs.txt'));        
    case 6 %if LED2
        set(handles.testTypeList,'visible', 'on', 'String', importdata('PhillipsLEDs.txt'));        
    case 7 %if Optimized  
        set(handles.testTypeList,'visible', 'on', 'String', importdata('OptimizedLEDs.txt'));        
    case 8 %not used
        set(handles.testTypeList, 'visible', 'off');       
end
%check if in 1nm resolution mode
    elseif strcmp(mydata.resolution,'1nm') == 1
 switch get(handles.testList,'Value')      
    case 1 %if Standard Illuminats
        set(handles.testTypeList,'visible', 'on', 'String', importdata('CIEStandards_1nm.txt'));
    case 2 %if Fluoro1
        set(handles.testTypeList,'visible', 'off', 'String', importdata('Fluorescents15-2_1nm.txt'));
    case 3 %if Fluoro2
        set(handles.testTypeList,'visible', 'off', 'String', importdata('Fluorescents15-3_1nm.txt'));
    case 4 %if HP
        set(handles.testTypeList,'visible', 'off', 'String', importdata('HighPressure_1nm.txt'));        
    case 5 %if LED1
        set(handles.testTypeList,'visible', 'off', 'String', importdata('ResearchLEDs_1nm.txt'));        
    case 6 %if LED2
        set(handles.testTypeList,'visible', 'off', 'String', importdata('PhillipsLEDs_1nm.txt'));        
    case 7 %if Optimized  
        set(handles.testTypeList,'visible', 'on', 'String', importdata('OptimizedLEDs_1nm.txt'));        
    case 8 %not used
        set(handles.testTypeList, 'visible', 'off');       
 end
     end
end

% --- Executes on selection change in testTypeList.
function testTypeList_Callback(hObject, eventdata, handles)
% hObject    handle to testTypeList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testTypeList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testTypeList
mydata = getappdata(handles.figure1,'mydata');

if mydata.gamma > 0 %disable until gamma is set  
    %Specific SPD that is used depends on which option was selected from
    %list boxes.
    if strcmp(mydata.resolution,'5nm') == 1
        SPD = mydata.array_5nm(:,get(handles. testTypeList,'Value'), get(handles.testList,'Value'));
        convert2SRGB(handles, SPD)    
    elseif strcmp(mydata.resolution,'1nm') == 1
        SPD = mydata.array_1nm(:,get(handles. testTypeList,'Value'), get(handles.testList,'Value'));
        convert2SRGB(handles, SPD)   
    end
    try
    %Update test TCS panel's title to show what which light source is being
    %rendered.
    testTypeValue = get(handles.testTypeList,'Value');
    testTypeString = get(handles.testTypeList,'String');
    testTypeSelected = testTypeString{testTypeValue};
    testValue = get(handles.testList,'Value');
    testString = get(handles.testList,'String');
    testSelected = testString{testValue};
    testSourceString = strcat('Test Light Source::',testSelected,'::',...
    testTypeSelected,'::',mydata.colourMetric,'::',mydata.resolution);
    set(handles.testSource_panel,'Title',testSourceString)
    catch err
    end
end

% --- Executes on selection change in refList.
function refList_Callback(hObject, eventdata, handles)
% hObject    handle to refList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if mydata.gamma > 0 %check if gamma has been set
set(handles.refTypeList,'Value',1); %returns cursor to default position
%check if in 5nm mode
     if strcmp(mydata.resolution,'5nm') == 1
switch get(handles.refList,'Value')      
    case 1 %if Standard Illuminants
        set(handles.refTypeList,'visible', 'on', 'String', importdata('CIEStandards.txt'));
    case 2 %if Fluoro1
        set(handles.refTypeList,'visible', 'on', 'String', importdata('Fluorescents15-2.txt'));
    case 3 %if Fluoro2
        set(handles.refTypeList,'visible', 'on', 'String', importdata('Fluorescents15-3.txt'));
    case 4 %if HP
        set(handles.refTypeList,'visible', 'on', 'String', importdata('HighPressure.txt'));        
    case 5 %if LED1
        set(handles.refTypeList,'visible', 'on', 'String', importdata('ResearchLEDs.txt'));        
    case 6 %if LED2
        set(handles.refTypeList,'visible', 'on', 'String', importdata('PhillipsLEDs.txt'));        
    case 7 %if Optimized  
        set(handles.refTypeList,'visible', 'on', 'String', importdata('OptimizedLEDs.txt'));       
    case 8 %not used
        set(handles.refTypeList, 'visible', 'off');           
end
%check if in 1nm resolution mode
     elseif strcmp(mydata.resolution,'1nm') == 1
switch get(handles.refList,'Value')      
    case 1 %if Standard Illuminants
        set(handles.refTypeList,'visible', 'on', 'String', importdata('CIEStandards_1nm.txt'));
    case 2 %if Fluoro1
        set(handles.refTypeList,'visible', 'off', 'String', importdata('Fluorescents15-2_1nm.txt'));
    case 3 %if Fluoro2
        set(handles.refTypeList,'visible', 'off', 'String', importdata('Fluorescents15-3_1nm.txt'));
    case 4 %if HP
        set(handles.refTypeList,'visible', 'off', 'String', importdata('HighPressure_1nm.txt'));        
    case 5 %if LED1
        set(handles.refTypeList,'visible', 'off', 'String', importdata('ResearchLEDs_1nm.txt'));        
    case 6 %if LED2
        set(handles.refTypeList,'visible', 'off', 'String', importdata('PhillipsLEDs_1nm.txt'));        
    case 7 %if Optimized  
        set(handles.refTypeList,'visible', 'on', 'String', importdata('OptimizedLEDs_1nm.txt'));       
    case 8 %not used
        set(handles.refTypeList, 'visible', 'off');           
end         
     end
end

% --- Executes on selection change in refTypeList.
function refTypeList_Callback(hObject, eventdata, handles)
% hObject    handle to refTypeList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns refTypeList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from refTypeList
mydata = getappdata(handles.figure1,'mydata');

if mydata.gamma > 0 %disable until gamma is set
    if strcmp(mydata.resolution,'5nm') == 1
        SPD = mydata.array_5nm(:,get(handles. refTypeList,'Value'), get(handles.refList,'Value'));
        convert2SRGB2(handles, SPD)    
    elseif strcmp(mydata.resolution,'1nm') == 1
        SPD = mydata.array_1nm(:,get(handles. refTypeList,'Value'), get(handles.refList,'Value'));
        convert2SRGB2(handles, SPD)   
    end
    try
    %Update ref TCS panel's title to show what which light source is being
    %rendered.
    refTypeValue = get(handles.refTypeList,'Value');
    refTypeString = get(handles.refTypeList,'String');
    refTypeSelected = refTypeString{refTypeValue};
    refValue = get(handles.refList,'Value');
    refString = get(handles.refList,'String');
    refSelected = refString{refValue};
    refSourceString = strcat('Reference Light Source::',refSelected,'::',...
    refTypeSelected,'::',mydata.colourMetric,'::',mydata.resolution);
      set(handles.refSource_panel,'Title',refSourceString)  
    catch err
    end
end

%--Contains all external functions to convert SPD to screen RGB values for
%display on the test side.
function convert2SRGB(handles, SPD)
mydata = getappdata(handles.figure1,'mydata');
%get necessary information
munsell = mydata.munsell;
CRT_calc = mydata.CRT_calc;
xyz = mydata.xyz;
gamma = str2num(mydata.gamma);
K1 = str2num(mydata.K1);
colour_mult = str2num(mydata.colour_mult);
%Troubleshooting Matrix size
% disp(size(xyz))
% disp(size(munsell))
% disp(size(SPD))
try
%Calculate SRGB
[XYZ] = calc_XYZ(SPD,munsell,xyz,colour_mult); %convert to XYZ
[RGB] = XYZ_2_RGB(XYZ, CRT_calc); %convert to RGB
[SRGB] = RGB_2_SRGB(RGB, gamma, K1); %convert to SRGB using gamma and K1 values
mydata.SRGB = SRGB;
setappdata(handles.figure1,'mydata',mydata);
%Apply calculated colours to TCS
applyColors(handles)

catch err
    msgbox('Invalid Selection. No such SPD.','Error');
end
%--Contains all the functions to convert SPD to screen RGB values afor
%display on the reference side.
function convert2SRGB2(handles, SPD)
mydata = getappdata(handles.figure1,'mydata');
%get necessary information
munsell = mydata.munsell;
CRT_calc = mydata.CRT_calc;
xyz = mydata.xyz;
gamma = str2num(mydata.gamma);
K1 = str2num(mydata.K1);
colour_mult = str2num(mydata.colour_mult);
%Troubleshooting Matrix size
% disp(size(xyz))
% disp(size(munsell))
% disp(size(SPD))
try
%Calculate SRGB
[XYZ] = calc_XYZ(SPD,munsell,xyz,colour_mult); %convert to XYZ
[RGB] = XYZ_2_RGB(XYZ, CRT_calc); %convert to RGB
[SRGB] = RGB_2_SRGB(RGB, gamma, K1); %convert to SRGB using gamma and K1 values
mydata.SRGB2 = SRGB;
setappdata(handles.figure1,'mydata',mydata);
%Apply calculated colours to TCS
applyColors2(handles)
catch err
    msgbox('Invalid Selection. No such SPD.','Error');    
end

%--Updates the colours to the necessary test colour samples of the test
%side.
function applyColors(handles)
mydata = getappdata(handles.figure1,'mydata');
%Check whether CQS or CRI is selected
if strcmp(mydata.colourMetric,'CRI') == 1
    mydata.TCS = importdata('CRI_ColourSamples.txt');
elseif strcmp(mydata.colourMetric,'CQS') == 1
    mydata.TCS = importdata('CQS_ColourSamples.txt');
end
final_SRGB = mydata.SRGB;
%dynamically colours the samples.
try
for i=1:16  
    j = strcat('TCS',num2str(i)); %Dynamically create variables with identical name as test colour samples.
    text_handle = findobj('Tag',j); %convert the above string to a handle.
    set(text_handle,'String',mydata.TCS(i, 1)); %Dynamically update the munsell hue/chroma/value names
    set(text_handle,'Backgroundcolor',[final_SRGB(1,i),final_SRGB(2,i),final_SRGB(3,i)]); %colour the sample.
end
%catch generic errors.
catch err
    msgbox('Please refresh test light source listboxes.','Invalid SPD')
end
%--Updates the colours to the necessary test colour samples of the
%reference side.
function applyColors2(handles)
mydata = getappdata(handles.figure1,'mydata');
%Check whether CQS or CRI is selected
if strcmp(mydata.colourMetric,'CRI') == 1
    mydata.TCS = importdata('CRI_ColourSamples.txt');
elseif strcmp(mydata.colourMetric,'CQS') == 1
    mydata.TCS = importdata('CQS_ColourSamples.txt');
end
final_SRGB = mydata.SRGB2;
%dynamically colours the samples.
try
for i=1:16  
    j = strcat('TCS',num2str(i),'_2'); %Dynamically create variables with identical name as test colour samples.
    text_handle = findobj('Tag',j); %convert the above string to a handle and fid the handle.
    set(text_handle,'String',mydata.TCS(i, 1)); %Dynamically update the munsell hue/chroma/value names
    set(text_handle,'Backgroundcolor',[final_SRGB(1,i),final_SRGB(2,i),final_SRGB(3,i)]); %colour the sample.
end
%catch generic errors
 catch err
     msgbox('Please refresh reference light source listboxes.','Invalid SPD')
end

% --- Executes on button press in setMonitor.
function setMonitor_Callback(hObject, eventdata, handles)
% hObject    handle to setMonitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
handles.output = hObject;
guidata(hObject, handles);
if get(handles.allowCustom_check, 'Value') == 1
set(handles.refTypeList,'Enable','on');
set(handles.refList,'Enable','on');
%set listboxes' information
set(handles.testList,'String', importdata('MainLightSources.txt'));
set(handles.refList,'String', importdata('MainLightSources.txt'));  
else
%enable listboxes
set(handles.testTypeList,'Enable','on');
set(handles.testList,'Enable','on');
set(handles.refTypeList,'Enable','on');
set(handles.refList,'Enable','on');
%set listboxes' information
set(handles.testList,'String', importdata('MainLightSources.txt'));
set(handles.refList,'String', importdata('MainLightSources.txt'));  
end
% %enable other controls
% set(handles.button_1nm,'Enable','on');
% set(handles.enable_CQS,'Enable','on');
% set(handles.plot_SPD_button,'Enable','on');
% set(handles.plot_TCS_button,'Enable','on');
%Enable panel visibiliy
set(handles.panel_1,'Visible','on');
set(handles.panel_2,'Visible','on');
set(handles.panel_3,'Visible','on');
set(handles.panel_4,'Visible','on');
set(handles.panel_5,'Visible','on');
set(handles.plot_SPD_button,'Visible','on');
set(handles.plot_TCS_button,'Visible','on');
set(handles.compare_button,'Visible','on');
%get values from text boxes
mydata.gamma = get(handles.editGamma,'String');
mydata.K1 = get(handles.editK1, 'String');
mydata.colour_mult = get(handles.colour_multiplier, 'String');

setappdata(handles.figure1,'mydata',mydata);

% --- Executes on button press in enable_CRI.
function enable_CRI_Callback(hObject, eventdata, handles)
% hObject    handle to enable_CRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
%set variables and border colors to show which option is selected
mydata.colourMetric = 'CRI';
set(handles.Border_CRI, 'BackGroundColor', [0,0.498,0])
set(handles.Border_CQS, 'BackGroundColor', 'red')
%check whether 1nm or 5nm is selected
if strcmp(mydata.resolution,'1nm') == 1
    mydata.munsell = dlmread('Munsell_CRI_1nm.txt');
elseif strcmp(mydata.resolution,'5nm') == 1
    mydata.munsell = dlmread('Munsell_CRI.txt');
end
disp('Metric set to CRI')
setappdata(handles.figure1,'mydata',mydata);

% --- Executes on button press in enable_CQS.
function enable_CQS_Callback(hObject, eventdata, handles)
% hObject    handle to enable_CQS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
%set variables and border colors to show which option is selected
mydata.colourMetric = 'CQS';
set(handles.Border_CQS, 'BackGroundColor', [0,0.498,0])
set(handles.Border_CRI, 'BackGroundColor', 'red')
%check whether 1nm or 5nm is selected
if strcmp(mydata.resolution,'1nm') == 1
    mydata.munsell = dlmread('Munsell_CQS_1nm.txt');
elseif strcmp(mydata.resolution,'5nm') == 1
    mydata.munsell = dlmread('Munsell_CQS.txt');
end
disp('Metric set to CQS')
setappdata(handles.figure1,'mydata',mydata);

% --- Executes on button press in button_1nm.
function button_1nm_Callback(hObject, eventdata, handles)
% hObject    handle to button_1nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
%set variables and border colors to show which option is selected
mydata.SPDs_CIE = dlmread ('CIE_Illuminants_1nm.txt');
mydata.xyz = dlmread('xyz_1nm.txt');
mydata.resolution = '1nm';
set(handles.Border_1nm, 'BackGroundColor', [0,0.498,0])
set(handles.Border_5nm, 'BackGroundColor', 'red')
%check whether CQS or CRI is selected
if strcmp(mydata.colourMetric,'CRI') == 1
    mydata.munsell = dlmread('Munsell_CRI_1nm.txt');
elseif strcmp(mydata.colourMetric,'CQS') == 1
    mydata.munsell = dlmread('Munsell_CQS_1nm.txt');
end
%Update the listboxes with the correct information
set(handles.testList,'String', importdata('MainLightSources_1nm.txt'));
set(handles.refList,'String', importdata('MainLightSources_1nm.txt'));

disp('Resolution set to 1 nm')
setappdata(handles.figure1,'mydata',mydata);

% --- Executes on button press in button_5nm.
function button_5nm_Callback(hObject, eventdata, handles)
% hObject    handle to button_5nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
mydata.SPDs_CIE = dlmread ('CIE_Illuminants.txt');
mydata.xyz = dlmread('xyz.txt');
mydata.resolution = '5nm';
set(handles.Border_5nm, 'BackGroundColor', [0,0.498,0])
set(handles.Border_1nm, 'BackGroundColor', 'red')
%check whether CQS or CRI is selected
if strcmp(mydata.colourMetric,'CRI') == 1
    mydata.munsell = dlmread('Munsell_CRI.txt');
elseif strcmp(mydata.colourMetric,'CQS') == 1
    mydata.munsell = dlmread('Munsell_CQS.txt');
end
%update listboxes with the correct information
set(handles.testList,'String', importdata('MainLightSources.txt'));
set(handles.refList,'String', importdata('MainLightSources.txt'));

disp('Resolution set to 5 nm')
setappdata(handles.figure1,'mydata',mydata);


% --- Executes on button press in allowCustom_check.
function allowCustom_check_Callback(hObject, eventdata, handles)
% hObject    handle to allowCustom_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of allowCustom_checkvv

%check if the allow custom SPD checkbox is checked and enable/disable other
%controls appropriately
if get(handles.allowCustom_check, 'Value') == 1
set(handles.loadCustom_button, 'Enable', 'on')
set(handles.testList, 'Enable', 'off')
set(handles.testTypeList, 'Enable', 'off')
set(handles.save2Opt_check, 'Visible', 'on');
else
set(handles.loadCustom_button, 'Enable', 'off')
set(handles.testList, 'Enable', 'on')
set(handles.testTypeList, 'Enable', 'on')
set(handles.save2Opt_check, 'Visible', 'off');
end

% --- Executes on button press in loadCustom_button.
function loadCustom_button_Callback(hObject, eventdata, handles)
% hObject    handle to loadCustom_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
%Initialize variables
emptyColumn = 0;
%Open file
[filenamespd,pathnamespd]=uigetfile('*.txt', 'Choose a spd file');
filespd = fullfile(pathnamespd,filenamespd);
mydata.customFilename = filenamespd; 
  try
%start reading the file
disp(filespd)
disp(filenamespd)
fileID = fopen(filespd);
SPD = dlmread(filespd);
mydata.customSPD = SPD;
%finish reading the file
fclose(fileID);
%convert SPD to SRGB and colour TCS
%depending on whether the input file is 1nm or 5nm
if size(SPD) == [401,1]
    convert2SRGB(handles, SPD)
elseif size(SPD) == [81, 1]
    convert2SRGB(handles, SPD)
end
%Check if save to optimized is checked
if get(handles.save2Opt_check, 'Value') == 1
    %Check if 5nm SPD is loaded
    if size(SPD) == [81, 1]
        %Check all cells for 0s. If all cells are 0 that means
        %there is no SPD in that column.        
        for j=1:16
            for k=1:81
             if mydata.SPDs_LED3(k, j) ~= 0, emptyColumn = 0; break, end  
             emptyColumn = j;
            end       
            if emptyColumn ~= 0, break, end
        end  
    try
        mydata.SPDs_LED3(:, emptyColumn) = SPD;
        %dlmwrite('C:\Users\Unrelentless\Desktop\Pavel\OptimVis Project\New Vis\SPDs\LEDOpt.txt', mydata.SPDs_LED3, 'delimiter', '\t', 'newline','pc');
        dlmwrite('OptimVis Project\New Vis\SPDs\LEDOpt.txt', mydata.SPDs_LED3, 'delimiter', '\t', 'newline','pc');
        %Open file for writing
        %fid = fopen('C:\Users\Unrelentless\Desktop\Pavel\OptimVis Project\New Vis\Light Source Types\OptimizedLEDs.txt','a');
        fid = fopen('OptimVis Project\New Vis\Light Source Types\OptimizedLEDs.txt','a');
        % write values at end of file
        fprintf(fid,'%s\n', filenamespd);
        % close the file 
        fclose(fid);
    catch err
       msgbox('Please manually delete SPDs and their corresponding names from the text files to continue saving them to the Optimized LEDs listbox.',...
           'Maximum number of Optimized LEDs reached') 
    end
    %Check if 1nm SPD is loaded
    elseif size(SPD) == [401, 1]
        %Check all cells for 0s. If all cells are 0 that means
        %there is no SPD in that column.        
        for j=1:16
            for k=1:401
             if mydata.SPDs_LED3(k, j) ~= 0, emptyColumn = 0; break, end  
             emptyColumn = j;
            end       
            if emptyColumn ~= 0, break, end
        end  
            try
                mydata.SPDs_LED3(:, emptyColumn) = SPD;
                %dlmwrite('C:\Users\Unrelentless\Desktop\Pavel\OptimVis Project\New Vis\SPDs\LEDOpt_1nm.txt', mydata.SPDs_LED3, 'delimiter', '\t', 'newline','pc');
                dlmwrite('OptimVis Project\New Vis\SPDs\LEDOpt_1nm.txt', mydata.SPDs_LED3, 'delimiter', '\t', 'newline','pc');
                %Open file for writing
                %fid = fopen('C:\Users\Unrelentless\Desktop\Pavel\OptimVis Project\New Vis\Light Source Types\OptimizedLEDs_1nm.txt','a');
                fid = fopen('OptimVis Project\New Vis\Light Source Types\OptimizedLEDs_1nm.txt','a');
                % write values at end of file
                fprintf(fid,'%s\n', filenamespd);
                % close the file 
                fclose(fid);
            catch err
               msgbox('Please manually delete SPDs and their corresponding names from the text files to continue saving them to the Optimized LEDs listbox.',...
                   'Maximum number of Optimized LEDs reached') 
            end
    end
end
%load the updated SPDs back into the 3D cell for immediate use
mydata.array_5nm = cat(3, mydata.SPDs_CIE(:, :), mydata.SPDs_F1(:, :), ...
    mydata.SPDs_F2(:, :), mydata.SPDs_HP(:, :), mydata.SPDs_LED1(:, :), ...
    mydata.SPDs_LED2(:, :), mydata.SPDs_LED3(:, :));
mydata.array_1nm = cat(3, mydata.SPDs_CIE_1nm(:, :), mydata.SPDs_F1_1nm(:, :), ...
    mydata.SPDs_F2_1nm(:, :), mydata.SPDs_HP_1nm(:, :), mydata.SPDs_LED1_1nm(:, :), ...
    mydata.SPDs_LED2_1nm(:, :), mydata.SPDs_LED3_1nm(:, :));

    %Update test TCS panel's title to show which light source is being
    %rendered at this moment
    testTypeSelected = mydata.customFilename;
     testSelected = '';
    testSourceString = strcat('Test Light Source::',testSelected,...
        testTypeSelected,'::',mydata.colourMetric,'::',mydata.resolution);
    set(handles.testSource_panel,'Title',testSourceString)
%Load all necessary information to back into mydata    
setappdata(handles.figure1,'mydata',mydata);
% catch any errors.
catch err
   msgbox('Please make sure that the file selected is in the correct format and resolution.',...
       'Invalid SPD format') 
end




% --- Executes on button press in plot_SPD_button.
function plot_SPD_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_SPD_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%create name for the figure dynamically
mydata = getappdata(handles.figure1,'mydata');
%Get the SPD and name of the test light source
try
    if get(handles.allowCustom_check, 'Value') == 1
       testSelected = mydata.customFilename;
       mydata.spdPlotTest = mydata.customSPD;
    else
    testValue = get(handles.testTypeList,'Value');
    testString = get(handles.testTypeList,'String');
        if strcmp(mydata.resolution,'1nm') == 1
        mydata.spdPlotTest = mydata.array_1nm(:,get(handles. testTypeList,'Value'), get(handles.testList, 'Value')); 
        else
        mydata.spdPlotTest = mydata.array_5nm(:,get(handles. testTypeList,'Value'), get(handles.testList, 'Value'));
        end
    testSelected = testString{testValue};
    end
%Get the name and SPD for the reference light source
refValue = get(handles.refTypeList,'Value');
refString = get(handles.refTypeList,'String');
refSelected = refString{refValue};
        if strcmp(mydata.resolution,'1nm') == 1
        mydata.spdPlotRef = mydata.array_1nm(:,get(handles. refTypeList,'Value'), get(handles.refList, 'Value')); 
        %set x-axis grid
        xGrid = 380:1:780;
        else
        mydata.spdPlotRef = mydata.array_5nm(:,get(handles. refTypeList,'Value'), get(handles.refList, 'Value'));
        %set x-axis grid
        xGrid = 380:5:780;
        end
figureTitle = sprintf('SPD of %s and %s',testSelected,refSelected);
%Create figure and plot
figure('Name',figureTitle,'NumberTitle','off')
plot(xGrid,mydata.spdPlotTest);
hold on;
plot(xGrid,mydata.spdPlotRef,'Color','red');
hold off;
grid on;
xlabel('Wavelength')
ylabel('Intensity')
hleg1 = legend(testSelected,refSelected);
set(hleg1,'Location','NorthEast')
catch err
   msgbox('Please make sure to select two SPDs to plot.','Not enough SPDs') 
end

% --- Executes on button press in plot_TCS_button.
function plot_TCS_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_TCS_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
    TCS = mydata.munsell;
%tell plot which colour metric is selected
if strcmp(mydata.colourMetric,'CQS') == 1
    colour_metric = 1;
    TCS_sRGB = dlmread('sRGB_CQS_D65.txt');
else
    colour_metric = 0;
    TCS_sRGB = dlmread('sRGB_CRI_D65.txt');
end
    
%run the draw TCS function
Draw_TCS(TCS, colour_metric, TCS_sRGB)

% --- Executes on button press in compare_button.
function compare_button_Callback(hObject, eventdata, handles)
% hObject    handle to compare_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
if get(handles.allowCustom_check, 'Value') == 1
       testSelected = mydata.customFilename;
       testSPD = mydata.customSPD;
    else
    testValue = get(handles.testTypeList,'Value');
    testString = get(handles.testTypeList,'String');
    testSelected = testString{testValue};
    testSPD = mydata.array_5nm(:,get(handles. testTypeList,'Value'), get(handles.testList, 'Value')); 
end
    %Get the name and SPD for the reference light source
refValue = get(handles.refTypeList,'Value');
refString = get(handles.refTypeList,'String');
refSelected = refString{refValue};

    refSPD = mydata.array_5nm(:,get(handles. refTypeList,'Value'), get(handles.refList, 'Value'));
    TCS = mydata.munsell;
    currentMunsell = mydata.colourMetric;
    CompareSPDs(testSPD, refSPD, currentMunsell, TCS, testSelected, refSelected)

% --- Executes during object creation, after setting all properties.
function testList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function testTypeList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testTypeList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function refList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function refTypeList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refTypeList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editGamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editK1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editK1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editGamma_Callback(hObject, eventdata, handles)
% hObject    handle to editGamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGamma as text
%        str2double(get(hObject,'String')) returns contents of editGamma as a double



function editK1_Callback(hObject, eventdata, handles)
% hObject    handle to editK1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editK1 as text
%        str2double(get(hObject,'String')) returns contents of editK1 as a double



function colour_multiplier_Callback(hObject, eventdata, handles)
% hObject    handle to colour_multiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colour_multiplier as text
%        str2double(get(hObject,'String')) returns contents of colour_multiplier as a double


% --- Executes during object creation, after setting all properties.
function colour_multiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colour_multiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save2Opt_check.
function save2Opt_check_Callback(hObject, eventdata, handles)
% hObject    handle to save2Opt_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save2Opt_check
