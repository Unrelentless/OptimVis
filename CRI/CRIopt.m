function varargout = CRIopt(varargin)
% CRIopt M-file for CRIopt.fig
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CRIopt

% Last Modified by GUIDE v2.5 15-Apr-2013 14:26:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CRIopt_OpeningFcn, ...
                   'gui_OutputFcn',  @CRIopt_OutputFcn, ...
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

% --- Executes just before CRIopt is made visible.
function CRIopt_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% sets mydata structure
format long;
mydata.cmf = dlmread('CMF.txt');
mydata.isotemp = dlmread ('isotemp.txt');
mydata.r = dlmread('TCS.txt');
mydata.ss = dlmread('ss.txt');
mydata.range = dlmread('lambdas.txt');
setappdata(hObject,'mydata',mydata);

function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');
global filenamespd pathnamespd filespd
[filenamespd,pathnamespd]=uigetfile('*.txt', 'Choose a spd file');


    % read the DEn parameters
    filespd = fullfile(pathnamespd,filenamespd);
    spdN = dlmread(filespd);
    [r, N] = size(spdN);
    set(handles.editN , 'String', num2str(N)); % dispaly N
    filespd = fullfile(pathnamespd,filenamespd);
    spdN = dlmread(filespd);
    [r, N] = size(spdN);
    h = msgbox('Population was optimized for the number of LEDs.','Population Optimized'); %Display Message saying populations was changed.
    set(handles.editP , 'String', num2str(N*10)); % dispaly N    
    set(handles.pushbuttonStart,'Enable','On');



function pushbuttonStart_Callback(hObject, eventdata, handles)
mydata = getappdata(handles.figure1,'mydata');
global filenamespd pathnamespd
% choose the LEDs file to be optimised

    % read the DEn parameters
    gen = str2num(get(handles.editG, 'String')); % # of generations
    P = str2num(get(handles.editP, 'String')); % population size
    F = str2num(get(handles.editF, 'String')); % mutation constant F
    CR = str2num(get(handles.editCR, 'String')); % crossover constant CR
    
    %spdN = dlmread(filenamespd); 
    filespd = fullfile(pathnamespd,filenamespd);
    spdN = dlmread(filespd);
    [r, N] = size(spdN);
    set(handles.editN , 'String', num2str(N)); % dispaly N
    
saveString = strcat('CRI Opt',' N=',num2str(N),' Gen=',num2str(gen),...
    ' P=',num2str(P),'');
    % choose the file where the results will be saved
[filename,pathname]=uiputfile(saveString,'Choose a file to save parameters in');
if ~isequal(filename,0) | ~isequal(pathname,0)
    file = fullfile(pathname,strcat(filename, '.txt'));
    file2 = fullfile(pathname, strcat(filename, '_SPD.txt'));
    fid = fopen(file, 'wt'); % opens the file for writing
    fid2 = fopen(file2, 'wt');

        % freeze the entry
    setInactive(hObject, eventdata, handles);
    
    % constants
    lambdaMin = 380;
    lambdaMax = 780;
    Imin = 0.05;
    Imax = 1;
    d = Imax - Imin;
     % various variables to speed up the calculations
    intensities = zeros(P, N); % I1,...,In 
    spdpop = zeros(81, P);
    bestscore = 0; % best score in this generation
    best = zeros(1, N); % best intensities
    %
    score = zeros(1,P); % scores of this population
    Ra = zeros(1,P); % Ra of this population
    Rb = zeros(1,P); % Rb of this population
    Rc = zeros(1,P); % Rc of this population
    eta = zeros(1,P); % efficacy of this population
    cct = zeros(1,P);   % CCT of this population
    Rmin = zeros(1,P); % Rmin of this population
    index = zeros(1,P); % index of Rmin of this population
    % child popiulation
    spdtemp = zeros(81, P);
    scoretemp = zeros(1,P); % scores of new population
    Ratemp = zeros(1,P); % Ra of new population
    Rbtemp = zeros(1,P); % Rb of new population
    Rctemp = zeros(1,P); % Rc of new population
    etatemp = zeros(1,P); % efficacy of new population
    ccttemp = zeros(1,P);   % CCT of new population
    Rmintemp = zeros(1,P); % Rmin of new population
    indextemp = zeros(1,P); % index of Rmin of this population
    rot= (0:1:P-1); %rotating index array
    % save the parameters of this search
    fprintf(fid, 'Gen: %u\nP: %u\nF: %4.2f\nCR: %5.2f\nN: %u\n', gen, P,F, CR, N);
% ----------------- Start search ------------------------------------------
% ----------------- Start differential evolution --------------------------
% ----------------- Generate initial population ---------------------------
       
    intensities(:,1:N) = Imin + d * rand(P, N); % random intensities
    spdpop = spdN * intensities'; % spds for the random intensities    
    % --- calculate scores for the initial population members
    for iii = 1:P
        [score(iii), Ra(iii), Rb(iii), Rc(iii), eta(iii), cct(iii), ...
               Rmin(iii), index(iii)] = calcscore(handles, spdpop(:,iii)); 
    end
        
% ===== For all generations or until the desired fitness is achieved=======
    for generation = 1:gen  
        [mem, ibest] = max(score); % score the members
        if bestscore < mem % is currenthighest>highest
           bestscore = mem; % replace bestscore
           best = intensities(ibest, :); % replace intensities
           % save generation and bestoverall member
%            fprintf(fid, '\n%6d %5d\t', generation, round(bestscore));
           fprintf(fid, '%f\t',best);
           fprintf(fid, '%d\t%d\t%d\t%d\t%d\t%d\t%d',round(cct(ibest)), ...
               round(Ra(ibest)), round(Rb(ibest)), round(Rc(ibest)), ...
               round(eta(ibest)), round(Rmin(ibest)), round(index(ibest)));
        end
%----------Mutate and crossover - create a new population------------------
        indexRot = randperm(2);
        a1 = randperm(P);
        rt = rem(rot+indexRot(1), P);
        a2 = a1(rt+1);
        rt = rem(rot+indexRot(2), P);
        a3 = a2(rt+1);
        pm1 = intensities(a1,:);
        pm2 = intensities(a2,:);
        pm3 = intensities(a3,:);
        % crossover constant CR
        mui = rand(P, N) < CR; % all randoms < 0.5 are 1, 0 otherwise
        mpo = mui < 0.5; % inverse mask to mui
        temp = pm3+F*(pm1-pm2);
        temp = intensities.*mpo + temp.*mui;
        % --- limit the population values for I
        for ii = 1:P
            for jj = 1:N
                if temp(ii, jj) > Imax
                    temp(ii, jj) = Imax;
                else if temp(ii, jj) < Imin
                    temp(ii, jj) = Imin;
                    end
                end
            end
        end 
    
% --- select which vectors are allowed to enter the new population--> only 
% --- those with scores higher than the original scores are added
        spdtemp = spdN * temp'; % spds for the random intensities  
        % calculate scores of the temp population
        for iii = 1:P
            [scoretemp(iii), Ratemp(iii), Rbtemp(iii), Rctemp(iii), ...
                etatemp(iii), ccttemp(iii), Rmintemp(iii), indextemp(iii)] = ...
                                     calcscore(handles, spdtemp(:,iii)); 
        end
        for iii = 1:P
            if scoretemp(iii) > score(iii) % new individual is better than old?
               intensities(iii, :) = temp(iii,:); % replace old individual with new one
               score(iii) = scoretemp(iii); % add its score
               Ra(iii) = Ratemp(iii); % replace Ra
               Rb(iii) = Rbtemp(iii); % replace Rb
               Rc(iii) = Rctemp(iii); % replace Rc
               eta(iii) = etatemp(iii); % replace eta
               cct(iii) = ccttemp(iii);   % replace CCT
               Rmin(iii) = Rmintemp(iii); % replace Rmin
               index(iii) = indextemp(iii); % replace index of Rmin
            end
        end
        set(handles.editLeftToDo, 'String', gen-generation); % generation #
        set(handles.editbestscore , 'String', num2str(round(bestscore))); % score
        drawnow;
        guidata(hObject, handles);
    end;
    
 
    
 % ---------- Finish: score > fitness OR all geneerations checked ----------
 % prepare CRI, e and score of the best individual
 % extract spds
 spd = spdN * best';
   
 [score, Ra, Rb, Rc, e, cct, Rmin, in] = calcscore(handles, spd); 
 set(handles.editRa , 'String', num2str(round(Ra))); % Ra
 set(handles.editRb , 'String', num2str(round(Rb))); % Rb
 set(handles.editRc , 'String', num2str(round(Rc))); % Rc
 set(handles.editLa , 'String', num2str(round(e))); % e
 set(handles.editbestscore , 'String', num2str(round(score))); % score
 set(handles.edit , 'String', num2str(round(cct))); % CCT
 set(handles.editworst , 'String', num2str(in)); % index of the worst
 set(handles.editmin , 'String', num2str(round(Rmin))); % Rmin
 % save spd to file
%  fprintf(fid, '\n\n=======\nBEST SPD \n');
 fprintf(fid2, '%f\n', spd); 
 fclose(fid);
  fclose(fid2);
 % plot the overall best spd 
 plot(380:5:780, spd);
 title('The best spectral power distribution');
 grid on;
 end;

setOn(hObject, eventdata, handles); % unfreeze the entry files
setappdata(handles.figure1,'mydata',mydata);
guidata(hObject, handles);


%function calculatescore(hObject, eventdata, handles)
function [score, Ra, Rb, Rc, e, cct, Rmin, index] = calcscore(handles, spd)
mydata = getappdata(handles.figure1,'mydata');

    A = str2num(get(handles.editA, 'String')); % # get a coefficient
    B = str2num(get(handles.editB, 'String')); % # get b coefficient
    C = str2num(get(handles.editC, 'String')); % # get c coefficient
    D = str2num(get(handles.editD, 'String')); % # get d coefficient
    E = str2num(get(handles.editE, 'String')); % # get e coefficient
    
[XYZt, xyzt] = spd2xyz(spd, mydata.cmf);
uvt = xyz2uv(xyzt);
cct = cal_CCT_Ohno_opt(uvt);
if cct == -1
    score = -1;
    Ra = -1;
    Rb = -1;
    Rc = -1;
    e = -1;
    Rmin = -1;
    index = -1;
    setappdata(handles.figure1,'mydata',mydata);
    return;
end    
spdCCT = cal_spdRef(cct, mydata.cmf, mydata.ss, mydata.range);
setappdata(handles.figure1,'mydata',mydata);
[XYZr, xyzr] = spd2xyz(spdCCT,mydata.cmf );
uvr = xyz2uv(xyzr);
[XYZTCSt, xyzTCSt] = TCSr2xyz(spd, mydata.cmf, mydata.r);
[XYZTCSr, xyzTCSr] = TCSr2xyz(spdCCT, mydata.cmf, mydata.r);
uvTCSt = TCSxyz2uv(xyzTCSt);
uvTCSr = TCSxyz2uv(xyzTCSr);
uvKries = adaptation(uvt, uvr, uvTCSt);
UVWt = TCSuv2UVW(XYZTCSt, uvKries, uvr);
UVWr = TCSuv2UVW(XYZTCSr, uvTCSr, uvr);
[Ra, Rb, Rc, Rmin, index] = cal_CRI_opt(UVWr, UVWt);
e = sum(683 .* mydata.cmf(:, 2) .* spd) / sum(spd(:));
%--------------------------------------------------------------------------
score = A * Ra + B * Rb + C * Rc + E * e + D * Rmin;
%--------------------------------------------------------------------------

setappdata(handles.figure1,'mydata',mydata); 


function setInactive(hObject, eventdata, handles)
set(handles.editG, 'Enable', 'inactive');
set(handles.editP, 'Enable', 'inactive');
set(handles.editF, 'Enable', 'inactive');
set(handles.editCR, 'Enable', 'inactive');
set(handles.pushbuttonStart, 'Enable', 'inactive');
set(handles.editRa , 'String', ''); % Ra
set(handles.editRb , 'String', ''); % Rb
set(handles.editRc , 'String', ''); % Rc
set(handles.editLa , 'String', ''); % e
set(handles.editbestscore , 'String', ''); % score
set(handles.edit , 'String', ''); % CCT
set(handles.editworst , 'String', ''); % index of the worst patch
set(handles.editmin , 'String', ''); % Rmin
set(handles.editN , 'String', ''); % remove N
cla(handles.spd,'reset');
set(handles.spd, 'Visible', 'off');
set(handles.editA, 'Enable', 'inactive');
set(handles.editB, 'Enable', 'inactive');
set(handles.editC, 'Enable', 'inactive');
set(handles.editD, 'Enable', 'inactive');
set(handles.editE, 'Enable', 'inactive');
set(handles.pushbutton3, 'Enable', 'inactive');
guidata(hObject, handles);

function setOn(hObject, eventdata, handles)
set(handles.editG, 'Enable', 'on');
set(handles.editP, 'Enable', 'on');
set(handles.editF, 'Enable', 'on');
set(handles.editCR, 'Enable', 'on');
set(handles.pushbuttonStart, 'Enable', 'on');
set(handles.editA, 'Enable', 'on');
set(handles.editB, 'Enable', 'on');
set(handles.editC, 'Enable', 'on');
set(handles.editD, 'Enable', 'on');
set(handles.editE, 'Enable', 'on');
set(handles.pushbutton3, 'Enable', 'on');
guidata(hObject, handles);

function varargout = CRIopt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function editG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editFitness_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editCR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function editRa_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRb_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editRc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editLa_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editLeftToDo_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editbestscore_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function spd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate spd



function editG_Callback(hObject, eventdata, handles)
% hObject    handle to editG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editG as text
%        str2double(get(hObject,'String')) returns contents of editG as a double



function editP_Callback(hObject, eventdata, handles)
% hObject    handle to editP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editP as text
%        str2double(get(hObject,'String')) returns contents of editP as a double



function editF_Callback(hObject, eventdata, handles)
% hObject    handle to editF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editF as text
%        str2double(get(hObject,'String')) returns contents of editF as a double



function editCR_Callback(hObject, eventdata, handles)
% hObject    handle to editCR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCR as text
%        str2double(get(hObject,'String')) returns contents of editCR as a double



function editA_Callback(hObject, eventdata, handles)
% hObject    handle to editA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editA as text
%        str2double(get(hObject,'String')) returns contents of editA as a double


% --- Executes during object creation, after setting all properties.
function editA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editB_Callback(hObject, eventdata, handles)
% hObject    handle to editB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editB as text
%        str2double(get(hObject,'String')) returns contents of editB as a double


% --- Executes during object creation, after setting all properties.
function editB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editD_Callback(hObject, eventdata, handles)
% hObject    handle to editD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editD as text
%        str2double(get(hObject,'String')) returns contents of editD as a double


% --- Executes during object creation, after setting all properties.
function editD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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



function editC_Callback(hObject, eventdata, handles)
% hObject    handle to editC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editC as text
%        str2double(get(hObject,'String')) returns contents of editC as a double


% --- Executes during object creation, after setting all properties.
function editC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
