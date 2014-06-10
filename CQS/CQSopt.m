function varargout = CQSopt(varargin)
% ========================================================================
% This version uses the CQS metric for colour-rendering by Davis and Ohno. 
% Optimises a set of n LEDs - the number of LEDs is determined
% automaticaly from the input spd file.
% The results are saved into a txt file.
% ========================================================================
% DEn M-file for DEn.fig
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DEn

% Last Modified by GUIDE v2.5 01-May-2013 16:48:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CQSopt_OpeningFcn, ...
                   'gui_OutputFcn',  @CQSopt_OutputFcn, ...
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

% --- Executes just before DEn is made visible.
function CQSopt_OpeningFcn(hObject, eventdata, handles, varargin)
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

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
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
    %spdN = dlmread(filenamespd); 
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
    
    saveString = strcat('CQS Opt',' N=',num2str(N),' Gen=',num2str(gen),...
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
    Qa = zeros(1,P); % Ra of this population
    eta = zeros(1,P); % efficacy of this population
    cct = zeros(1,P);   % CCT of this population
    Qamin = zeros(1,P); % Rmin of this population
    index = zeros(1,P); % index of Rmin of this population
    % child popiulation
    spdtemp = zeros(81, P);
    scoretemp = zeros(1,P); % scores of new population
    Qatemp = zeros(1,P); % Ra of new population
    etatemp = zeros(1,P); % efficacy of new population
    ccttemp = zeros(1,P);   % CCT of new population
    Qmintemp = zeros(1,P); % Rmin of new population
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
        [score(iii), Qa(iii), eta(iii), cct(iii), Qamin(iii), index(iii)] ...
               = calcscore(handles, spdpop(:,iii)); 
    end
        
% ===== For all generations or until the desired fitness is achieved=======
    for generation = 1:gen  
        [mem, ibest] = max(score); % score the members
        if bestscore < mem % is currenthighest>highest
           bestscore = mem; % replace bestscore
           best = intensities(ibest, :); % replace intensities
           % save generation and bestoverall member
           fprintf(fid, '\n%6d %5d\t', generation, round(bestscore));
           fprintf(fid, '%f\t',best);
           fprintf(fid, '%d\t%d\t%d\t%d\t%d',round(cct(ibest)), ...
               round(Qa(ibest)), round(eta(ibest)), ...
               round(Qamin(ibest)), round(index(ibest)));
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
        mui = rand(P, N) < CR;   % all randoms < 0.5 are 1, 0 otherwise
        mpo = mui < 0.5;         % inverse mask to mui
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
          [scoretemp(iii), Qatemp(iii), etatemp(iii), ccttemp(iii), ...
        Qamintemp(iii), indextemp(iii)] = calcscore(handles, spdtemp(:,iii)); 
        end
        for iii = 1:P
            if scoretemp(iii) > score(iii) % new individual is better than old?
               intensities(iii, :) = temp(iii,:); % replace old individual with new one
               score(iii) = scoretemp(iii);  % add its score
               Qa(iii) = Qatemp(iii);        % replace Qa
               eta(iii) = etatemp(iii);      % replace eta
               cct(iii) = ccttemp(iii);      % replace CCT
               Qamin(iii) = Qamintemp(iii);  % replace Qamin
               index(iii) = indextemp(iii);  % replace index of Qamin
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
   
 [score, Qa, e, cct, Qamin, in] = calcscore(handles, spd); 
 set(handles.editRa , 'String', num2str(round(Qa))); % Qa
 set(handles.editLa , 'String', num2str(round(e))); % e
 set(handles.editbestscore , 'String', num2str(round(score))); % score
 set(handles.edit , 'String', num2str(round(cct))); % CCT
 set(handles.editworst , 'String', num2str(in)); % index of the worst
 set(handles.editmin , 'String', num2str(round(Qamin))); % Qamin
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
function [score, Qa, e, cct, Qamin, index] = calcscore(handles, spd)
mydata = getappdata(handles.figure1,'mydata');
    A = str2num(get(handles.editA, 'String')); % # get a coefficient
    B = str2num(get(handles.editB, 'String')); % # get b coefficient
    C = str2num(get(handles.editC, 'String')); % # get c coefficient
[XYZt, xyzt] = spd2xyz(spd, mydata.cmf);
uvt = xyz2uv(xyzt);       % required for calculating CCT
cct = cqs_cal_CCT_Ohno(uvt);  % calculate CCT of the test spd
if cct == -1     %silly CCT
    score = -1;
    Qa = -1;
    e = -1;
    Qamin = -1;
    index = -1;
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
%--------------------------------------------------------------------------
score = A * Qa + C * e + B * Qamin;
%--------------------------------------------------------------------------
setappdata(handles.figure1,'mydata',mydata); 


function setInactive(hObject, eventdata, handles)
set(handles.editG, 'Enable', 'inactive');
set(handles.editP, 'Enable', 'inactive');
set(handles.editF, 'Enable', 'inactive');
set(handles.editCR, 'Enable', 'inactive');
set(handles.pushbuttonStart, 'Enable', 'inactive');
set(handles.editRa , 'String', ''); % Qa
set(handles.editLa , 'String', ''); % e
set(handles.editbestscore , 'String', ''); % score
set(handles.edit , 'String', ''); % CCT
set(handles.editworst , 'String', ''); % index of the worst patch
set(handles.editmin , 'String', ''); % Qamin
%set(handles.editN , 'String', ''); % remove N
cla(handles.spd,'reset');
set(handles.spd, 'Visible', 'off');
set(handles.editA, 'Enable', 'inactive');
set(handles.editB, 'Enable', 'inactive');
set(handles.editC, 'Enable', 'inactive');
set(handles.pushbutton6,'Enable', 'inactive');
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
set(handles.pushbutton6,'Enable', 'on');
guidata(hObject, handles);

function varargout = CQSopt_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
