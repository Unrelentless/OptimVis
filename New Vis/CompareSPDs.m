function varargout = CompareSPDs(varargin)
% Last Modified by GUIDE v2.5 01-Jul-2013 13:06:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CompareSPDs_OpeningFcn, ...
                   'gui_OutputFcn',  @CompareSPDs_OutputFcn, ...
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


% --- Executes just before CompareSPDs is made visible.
function CompareSPDs_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

mydata = getappdata(handles.figure1,'mydata');
format long;

mydata.cmf = dlmread('CMF.txt');
mydata.isotemp = dlmread ('isotemp.txt');
testSPD = varargin{1};
refSPD = varargin{2};
currentMunsell = varargin{3};
munsellSPD = varargin{4};
testName = varargin{5};
refName = varargin{6};
mydata.ss = dlmread('ss.txt');
mydata.lambdas = dlmread('lambdas.txt');

setappdata(hObject,'mydata',mydata);

populateTest(hObject, handles, testSPD, currentMunsell, munsellSPD, testName)
populateRef(hObject, handles, refSPD, currentMunsell, munsellSPD, refName)
populateDiff(handles, currentMunsell)



function populateTest(hObject, handles, testSPD, currentMunsell, munsellSPD, testName)
SPD = testSPD;
if strcmp(currentMunsell,'CRI') == 1
[Ra, Rb, Rc14, Ri, e, cct] = CalculateParametersCRI(hObject, handles,SPD, munsellSPD);

    set(handles.efficacy, 'String', num2str(e));
    cct = round(cct);
    set(handles.spdName , 'String', testName);
    set(handles.cct , 'String', num2str(cct));
    set(handles.ra , 'String', num2str(Ra));
    set(handles.rb , 'String', num2str(Rb));
    set(handles.rc , 'String', num2str(Rc14));
    
    set(handles.r15, 'Visible', 'off');
    set(handles.text_r15, 'Visible', 'off');
    
    for i=1:14  
    j = strcat('r',num2str(i)); %Dynamically create variables with handles.
    k = strcat('text_r',num2str(i));
    l = strcat('R', num2str(i),':');
    text_handle = findobj('Tag',j); %convert the above string to a handle and find it.
    text_handle2 = findobj('Tag',k); %convert the above string to a handle and find it.
    set(text_handle, 'String', num2str(Ri(i))); %populate handle with value    
    set(text_handle2, 'String', l); %populate handle with value
    end
      
elseif strcmp(currentMunsell,'CQS') == 1 
    [Qa, Qamin, e, Qi, cct, index] = CalculateParametersCQS(hObject, handles,SPD, munsellSPD);   
    
    set(handles.efficacy, 'String', num2str(round(e*10)/10));
    cct = round(cct);
    set(handles.spdName , 'String', testName);
    set(handles.cct , 'String', num2str(round(cct*10)/10));
    set(handles.ra , 'String', num2str(round(Qa*10)/10));
    set(handles.text_ra , 'String', 'Qa:');
    set(handles.rb , 'String', num2str(round(Qamin*10)/10));
    set(handles.text_rb , 'String', 'Qamin:');
    set(handles.rc , 'String', num2str(index));
    set(handles.text_rc , 'String', 'Index:');       
    set(handles.r15, 'Visible', 'on');
    set(handles.text_r15, 'Visible', 'on');
    
    for i=1:15 
    j = strcat('r',num2str(i)); %Dynamically create variables with handles.
    k = strcat('text_r',num2str(i));
    l = strcat('Q', num2str(i),':');
    text_handle = findobj('Tag',j); %convert the above string to a handle and find it.
    text_handle2 = findobj('Tag',k); %convert the above string to a handle and find it.
    set(text_handle, 'String', num2str(round(Qi(i)*10)/10)); %populate handle with value    
    set(text_handle2, 'String', l); %populate handle with value
    end
end

function populateRef(hObject, handles, refSPD, currentMunsell, munsellSPD, refName)
SPD = refSPD;
if strcmp(currentMunsell,'CRI') == 1
[Ra, Rb, Rc14, Ri, e, cct] = CalculateParametersCRI(hObject, handles,SPD, munsellSPD);

    set(handles.efficacy_2, 'String', num2str(e));
    cct = round(cct);
    set(handles.spdName_2 , 'String', refName);
    set(handles.cct_2 , 'String', num2str(cct));
    set(handles.ra_2 , 'String', num2str(Ra));
    set(handles.rb_2 , 'String', num2str(Rb));
    set(handles.rc_2 , 'String', num2str(Rc14));
    
    set(handles.r15_2, 'Visible', 'off');
    set(handles.text_r15_2, 'Visible', 'off');
    for i=1:14  
    j = strcat('r',num2str(i),'_2'); %Dynamically create variables with handles.
    k = strcat('text_r',num2str(i),'_2');
    l = strcat('R', num2str(i),':');
    text_handle = findobj('Tag',j); %convert the above string to a handle and find it.
    text_handle2 = findobj('Tag',k); %convert the above string to a handle and find it.
    set(text_handle, 'String', num2str(Ri(i))); %populate handle with value    
    set(text_handle2, 'String', l); %populate handle with value
    end
    
elseif strcmp(currentMunsell,'CQS') == 1 
        
    [Qa, Qamin, e, Qi, cct, index] = CalculateParametersCQS(hObject, handles,SPD, munsellSPD);   
    
    set(handles.efficacy_2, 'String', num2str(round(e*10)/10));
    cct = round(cct);
    set(handles.spdName_2 , 'String', refName);
    set(handles.cct_2 , 'String', num2str(round(cct*10)/10));
    set(handles.ra_2 , 'String', num2str(round(Qa*10)/10));
    set(handles.rb_2 , 'String', num2str(round(Qamin*10)/10));
    set(handles.rc_2 , 'String', num2str(index));
    set(handles.text_ra_2 , 'String', 'Qa:');
    set(handles.text_rb_2 , 'String', 'Qamin:');
    set(handles.text_rc_2 , 'String', 'Index:');       
    set(handles.r15_2, 'Visible', 'on');
    set(handles.text_r15_2, 'Visible', 'on');
    
    for i=1:15 
    j = strcat('r',num2str(i),'_2'); %Dynamically create variables with handles.
    k = strcat('text_r',num2str(i),'_2');
    l = strcat('Q', num2str(i),':');
    text_handle = findobj('Tag',j); %convert the above string to a handle and find it.
    text_handle2 = findobj('Tag',k); %convert the above string to a handle and find it.
    set(text_handle, 'String', num2str(round(Qi(i)*10)/10)); %populate handle with value    
    set(text_handle2, 'String', l); %populate handle with value
    end
end

function populateDiff(handles, currentMunsell)

if strcmp(currentMunsell,'CRI') == 1 
   
    set(handles.cct_diff , 'String', num2str(str2double(get(handles.cct,...
    'String')) - str2double(get(handles.cct_2, 'String'))));
        if str2double(get(handles.cct_diff, 'String')) < 0
        set(handles.cct_diff, 'ForegroundColor', 'Red')
        else
        set(handles.cct_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.efficacy_diff , 'String', num2str(str2double(get(handles.efficacy,...
    'String')) - str2double(get(handles.efficacy_2, 'String'))));
        if str2double(get(handles.efficacy_diff, 'String')) < 0
        set(handles.efficacy_diff, 'ForegroundColor', 'Red')
        else
        set(handles.efficacy_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.ra_diff , 'String', num2str(str2double(get(handles.ra,...
    'String')) - str2double(get(handles.ra_2, 'String'))));
        if str2double(get(handles.ra_diff, 'String')) < 0
        set(handles.ra_diff, 'ForegroundColor', 'Red')
        else
        set(handles.ra_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.rb_diff , 'String', num2str(str2double(get(handles.rb,...
    'String')) - str2double(get(handles.rb_2, 'String'))));
        if str2double(get(handles.rb_diff, 'String')) < 0
        set(handles.rb_diff, 'ForegroundColor', 'Red')
        else
        set(handles.rb_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.rc_diff , 'String', num2str(str2double(get(handles.rc,...
    'String')) - str2double(get(handles.rc_2, 'String'))));
        if str2double(get(handles.rc_diff, 'String')) < 0
        set(handles.rc_diff, 'ForegroundColor', 'Red')
        else
        set(handles.rc_diff, 'ForegroundColor', [0,0.498,0])
        end   
    
    set(handles.text_ra_diff , 'String', 'Ra:');
    set(handles.text_rb_diff , 'String', 'Rb:');
    set(handles.text_rc_diff , 'String', 'Rc:'); 
    
    for i=1:15 
    j = strcat('r',num2str(i),'_diff'); %Dynamically create variables with handles.
    k = strcat('text_r',num2str(i),'_diff');
    l = strcat('R', num2str(i),':');
    m = strcat('r', num2str(i));
    n = strcat('r', num2str(i),'_2');
    text_handle = findobj('Tag',j); %convert the above string to a handle and find it.
    text_handle2 = findobj('Tag',k); %convert the above string to a handle and find it.
    test_handles = findobj('Tag',m);
    ref_handles = findobj('Tag',n);
    set(text_handle , 'String', num2str(str2double(get(test_handles,...
     'String')) - str2double(get(ref_handles, 'String'))));    
    set(text_handle2, 'String', l); %populate handle with value   
        if str2double(get(text_handle, 'String')) < 0
        set(text_handle, 'ForegroundColor', 'Red')
        else
        set(text_handle, 'ForegroundColor', [0,0.498,0])
        end     
    end

    set(handles.rc_diff, 'Visible', 'on');
    set(handles.text_rc_diff , 'Visible', 'on');  
    set(handles.r15_diff, 'Visible', 'off');
    set(handles.text_r15_diff, 'Visible', 'off');
    
elseif strcmp(currentMunsell,'CQS') == 1 
    
    set(handles.cct_diff , 'String', num2str(str2double(get(handles.cct,...
    'String')) - str2double(get(handles.cct_2, 'String'))));
        if str2double(get(handles.cct_diff, 'String')) < 0
        set(handles.cct_diff, 'ForegroundColor', 'Red')
        else
        set(handles.cct_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.efficacy_diff , 'String', num2str(str2double(get(handles.efficacy,...
    'String')) - str2double(get(handles.efficacy_2, 'String'))));
        if str2double(get(handles.efficacy_diff, 'String')) < 0
        set(handles.efficacy_diff, 'ForegroundColor', 'Red')
        else
        set(handles.efficacy_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.ra_diff , 'String', num2str(str2double(get(handles.ra,...
    'String')) - str2double(get(handles.ra_2, 'String'))));
        if str2double(get(handles.ra_diff, 'String')) < 0
        set(handles.ra_diff, 'ForegroundColor', 'Red')
        else
        set(handles.ra_diff, 'ForegroundColor', [0,0.498,0])
        end   
    set(handles.rb_diff , 'String', num2str(str2double(get(handles.rb,...
    'String')) - str2double(get(handles.rb_2, 'String'))));
        if str2double(get(handles.rb_diff, 'String')) < 0
        set(handles.rb_diff, 'ForegroundColor', 'Red')
        else
        set(handles.rb_diff, 'ForegroundColor', [0,0.498,0])
        end   
    
    set(handles.text_ra_diff , 'String', 'Qa:');
    set(handles.text_rb_diff , 'String', 'Qamin:');
    
    for i=1:15 
    j = strcat('r',num2str(i),'_diff'); %Dynamically create variables with handles.
    k = strcat('text_r',num2str(i),'_diff');
    l = strcat('Q', num2str(i),':');
    m = strcat('r', num2str(i));
    n = strcat('r', num2str(i),'_2');
    text_handle = findobj('Tag',j); %convert the above string to a handle and find it.
    text_handle2 = findobj('Tag',k); %convert the above string to a handle and find it.
    test_handles = findobj('Tag',m);
    ref_handles = findobj('Tag',n);
    set(text_handle , 'String', num2str(str2double(get(test_handles,...
     'String')) - str2double(get(ref_handles, 'String'))));    
    set(text_handle2, 'String', l); %populate handle with value
        if str2double(get(text_handle, 'String')) < 0
        set(text_handle, 'ForegroundColor', 'Red')
        else
        set(text_handle, 'ForegroundColor', [0,0.498,0])
        end 
    end

    set(handles.rc_diff, 'Visible', 'off');
    set(handles.text_rc_diff , 'Visible', 'off');     
    set(handles.r15_diff, 'Visible', 'on');
    set(handles.text_r15_diff, 'Visible', 'on');
    
end



% --- Outputs from this function are returned to the command line.
function varargout = CompareSPDs_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
