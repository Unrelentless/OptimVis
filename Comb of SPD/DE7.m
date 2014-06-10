function varargout = DE7(varargin)
% DE7 M-file for DE7.fig
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DE7

% Last Modified by GUIDE v2.5 15-Apr-2013 15:24:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DE7_OpeningFcn, ...
                   'gui_OutputFcn',  @DE7_OutputFcn, ...
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
% --- Executes just before DE7 is made visible.
function DE7_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% sets mydata structure
format long;
mydata.cmf = dlmread('CMF.txt');
mydata.isotemp = dlmread ('isotemp.txt');
mydata.r = dlmread('TCS.txt');
mydata.ss = dlmread('ss.txt');
mydata.range = dlmread('lambdas.txt') * 1e-9;
mydata.spds = dlmread('spds.txt');
[r, N] = size(mydata.spds);
mydata.max = N;
set(handles.text49,'String',mydata.max); 
setappdata(hObject,'mydata',mydata);

function pushbuttonStart_Callback(hObject, eventdata, handles)
mydata = getappdata(handles.figure1,'mydata');
% choose the file where the results will be saved
    check_value = get(handles.checkbox6, 'Value');
    check_max = get(handles.checkbox6, 'Max');
   
    % read the DE parameters
     N = str2num(get(handles.editN, 'String')); % # LEDs       
    if (check_value == check_max)
     set(handles.editP,'String',N*10);
    end
    gen = str2num(get(handles.editG, 'String')); % # of generations
    P = str2num(get(handles.editP, 'String')); % population size
    fitness = str2num(get(handles.editFitness, 'String')); % ideal fitness
    F = str2num(get(handles.editF, 'String')); % mutation constant F
    CR = str2num(get(handles.editCR, 'String')); % crossover constant CR

saveString = strcat('Combination',' N=',num2str(N),' Gen=',num2str(gen),...
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
    leds = mydata.max;
    
    % various variables to speed up the calculations
    score = zeros(1,P); % scores of this population
    cct = zeros(1,P);   % CCT of this population
    ccttemp = zeros(1,P);   % CCT of new population
    scoretemp = zeros(1,P); % scores of new population
    bestscoreincombination = 0; % best score in this combination
    bestCCTincombination = 0;   % best CCT overall 
    bestscore = 0;
    rot= (0:1:P-1); %rotating index array
    combination = dec2binvec(0, leds); % this combination
    bestcombination = dec2binvec(0, leds); % best combination overall
    intensities = zeros(P, N); % I1,...,In 
    bestintensities = zeros(1, N);
    best = zeros(1, N);
    spdN = zeros(81,N); % extracted spd  of N LEDs
    spdpop = zeros(81, P);
    spdtemp = zeros(81, P);
    % save the parameters of this search
    fprintf(fid, 'Gen: %u\tP: %u\tFitness: %5.0f\t', gen, P, fitness);
    fprintf(fid, 'F: %4.2f\tCR: %5.2f\tN: %u\n',F, CR, N);
% ----------------- Start search ------------------------------------------
    for comb=1:(2^mydata.max)
      combination = dec2binvec(comb, leds);
      j = sum(combination);
      set(handles.editLeftToDo, 'String', int2str(combination)); % initial generation 
      drawnow;
      if(j == N)
        fprintf(fid, '\n\n');
        fprintf(fid, '%d ', combination);
        % extract spds
        n = 1;
        for k = 1:mydata.max
           if(combination(k) == 1) 
              spdN(:, n) = mydata.spds(:, k);
              n= n+1;
           end;
        end;
     
% ----------------- Start differential evolution --------------------------
% ----------------- Generate initial population ---------------------------
       
        intensities(:,1:N) = Imin + d * rand(P, N); % random intensities
        spdpop = spdN * intensities'; % spds for the random intensities    
        % --- calculate scores for the initial population members
        for iii = 1:P
            [score(iii), Ra, Rb, Rc, e, cct(iii), Rmin, index] = calcscore(handles, spdpop(:,iii)); 
        end
        
% ===== For all generations or until the desired fitness is achieved=======
    for generation = 1:gen  
        [mem, ibest] = max(score); % score the members
        if bestscoreincombination < score(ibest) % is currenthighest>highest
           bestscoreincombination = score(ibest); % replace bestscore
           bestCCTincombination = cct(ibest); % replace cct
           bestintensities = intensities(ibest, :); % replace intensities
           % save generation and bestoverall member
           fprintf(fid, '\n%d %d ', generation, round(bestscoreincombination));
           fprintf(fid, '%f\t',bestintensities);
           fprintf(fid, '%d',round(bestCCTincombination));
        end
        if bestscoreincombination > fitness
           break;
        end
%----------Mutate and crossover - create a new population------------------
        index = randperm(2);
        a1 = randperm(P);
        rt = rem(rot+index(1), P);
        a2 = a1(rt+1);
        rt = rem(rot+index(2), P);
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
            [scoretemp(iii), Ra, Rb, Rc, e, ccttemp(iii), Rmin, in] = calcscore(handles, spdtemp(:,iii)); 
        end
        for iii = 1:P
            if scoretemp(iii) > score(iii) % new individual is better than old?
               intensities(iii, :) = temp(iii,:); % replace old individual with new one
               score(iii) = scoretemp(iii); % add its score
               cct(iii) = ccttemp(iii);     % add its cct
            end
        end
        guidata(hObject, handles);
    end;
   end;
  if(bestscoreincombination > bestscore)
      bestcombination = combination;
      best = bestintensities;
      bestscore = bestscoreincombination;
      set(handles.editbestscore , 'String', num2str(round(bestscore))); % score
      set(handles.editbestcomb , 'String', int2str(bestcombination)); % combination
      drawnow;
    end;
    bestscoreincombination = 0;
 end;
    
 % ---------- Finish: score > fitness OR all geneerations checked ----------
 % prepare CRI, e and score of the best individual
 % extract spds
 n = 1;
 for k = 1:mydata.max
   if(bestcombination(k) == 1) 
      spdN(:, n) = mydata.spds(:, k);
      n= n+1;
   end;
 end;
 spd = spdN * best';
   
 [score, Ra, Rb, Rc, e, cct, Rmin, in] = calcscore(handles, spd); 
 set(handles.editRa , 'String', num2str(round(Ra))); % Ra
 set(handles.editRb , 'String', num2str(round(Rb))); % Rb
 set(handles.editRc , 'String', num2str(round(Rc))); % Rc
 set(handles.editLa , 'String', num2str(round(e))); % e
 set(handles.editbestscore , 'String', num2str(round(score))); % score
 set(handles.edit , 'String', num2str(round(cct))); % CCT
 set(handles.editbestcomb , 'String', int2str(bestcombination)); % best combination
 set(handles.editworst , 'String', num2str(in)); % index of the worst
 set(handles.editmin , 'String', num2str(round(Rmin))); % Rmin
 % save to file
 fprintf(fid, '\n\n=======\nBEST COMBINATION \n');
 fprintf(fid, '%d ', bestcombination);
 fprintf(fid, '\nRa = %d\tRb = %d\tRc = %d\te = %d\tCCT = %d\tRmin = %d\tindex = %d\tscore = %d\nspd\n',...
     round(Ra), round(Rb), round(Rc), round(e), round(cct),  round(Rmin), in, round(score)); 
 fprintf(fid2, '%f\n', spd); 
 fclose(fid);
  fclose(fid2);
 % plot the overall best spd 
 plot(380:5:780, spd);
 title('The best spectral power distribution');
 grid on;
end
setOn(hObject, eventdata, handles); % unfreeze the entry files
setappdata(handles.figure1,'mydata',mydata);
guidata(hObject, handles);

%function calculatescore(hObject, eventdata, handles)
function [score, Ra, Rb, Rc, e, cct, Rmin, index] = calcscore(handles, spd)
mydata = getappdata(handles.figure1,'mydata');
[XYZt, xyzt] = spd2xyz(spd, mydata.cmf);
uvt = xyz2uv(xyzt);
cct = cal_CCT_Ohno_combo(uvt);
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
[Ra, Rb, Rc, Rmin, index] = cal_CRI_combo(UVWr, UVWt);
e = sum(683 .* mydata.cmf(:, 2) .* spd) / sum(spd(:));
%--------------------------------------------------------------------------
score = Ra + Rb + Rc + 0.5 * e; 
%score = Ra + Rb + Rc + e + 0.1 * Rmin;
%--------------------------------------------------------------------------
set(handles.editLeftToDo, 'String', 'Finished');
setappdata(handles.figure1,'mydata',mydata); 

function setInactive(hObject, eventdata, handles)
set(handles.editG, 'Enable', 'inactive');
set(handles.editP, 'Enable', 'inactive');
set(handles.editFitness, 'Enable', 'inactive');
set(handles.editF, 'Enable', 'inactive');
set(handles.editCR, 'Enable', 'inactive');
set(handles.editN, 'Enable', 'inactive');
set(handles.pushbuttonStart, 'Enable', 'inactive');
set(handles.editRa , 'String', ''); % Ra
set(handles.editRb , 'String', ''); % Rb
set(handles.editRc , 'String', ''); % Rc
set(handles.editLa , 'String', ''); % e
set(handles.editbestscore , 'String', ''); % score
set(handles.edit , 'String', ''); % CCT
set(handles.editworst , 'String', ''); % index of the worst patch
set(handles.editmin , 'String', ''); % Rmin
set(handles.editbestcomb , 'String', ''); % remove best comb
cla(handles.spd,'reset');
set(handles.spd, 'Visible', 'off');
set(handles.loadspd, 'Enable', 'inactive');
set(handles.customCheck, 'Enable', 'inactive');
set(handles.checkbox6, 'Enable', 'inactive');
guidata(hObject, handles);

function setOn(hObject, eventdata, handles)
set(handles.editG, 'Enable', 'on');
set(handles.editP, 'Enable', 'on');
set(handles.editFitness, 'Enable', 'on');
set(handles.editF, 'Enable', 'on');
set(handles.editCR, 'Enable', 'on');
set(handles.editN, 'Enable', 'on');
set(handles.pushbuttonStart, 'Enable', 'on');
set(handles.loadspd, 'Enable', 'on');
set(handles.customCheck, 'Enable', 'on');
set(handles.checkbox6, 'Enable', 'on');
guidata(hObject, handles);

function checkboxSave_Callback(hObject, eventdata, handles)

function varargout = DE7_OutputFcn(hObject, eventdata, handles) 
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

% --- Executes during object creation, after setting all properties.
function spd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate spd


% --- Executes during object creation, after setting all properties.
function edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in loadspd.
function loadspd_Callback(hObject, eventdata, handles)
mydata = getappdata(handles.figure1,'mydata');
% hObject    handle to loadspd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filenamespd,pathnamespd]=uigetfile('*.txt', 'Choose a spd file');
if (~isequal(filenamespd,0) | ~isequal(pathnamespd,0))
    % freeze the entry
    filespd = fullfile(pathnamespd,filenamespd);
    mydata.spds = dlmread(filespd);
    [r, N] = size(mydata.spds);
    mydata.max = N;
    fileSave = fullfile(pathnamespd,strcat('results_', filenamespd));
    fid = fopen(fileSave, 'wt'); % opens the file for writing 
    fclose(fid);
    setappdata(handles.figure1,'mydata',mydata);
    disp(mydata.max)
    set(handles.text49,'String',mydata.max) 
 end;


% --- Executes on button press in customCheck.
function customCheck_Callback(hObject, eventdata, handles)
mydata = getappdata(handles.figure1,'mydata');
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% hObject    handle to customCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of customCheck
if (get(hObject,'Value') == get(hObject,'Max'))
  set(handles.loadspd,'Enable','on') 
else
   set(handles.loadspd,'Enable','off') 
   mydata.spds = dlmread('spds.txt');
   [r, N] = size(mydata.spds);
    mydata.max = N;
    setappdata(handles.figure1,'mydata',mydata);
    disp(mydata.max)
    set(handles.text49,'String',mydata.max) 
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
