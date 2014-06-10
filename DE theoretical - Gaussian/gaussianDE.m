function varargout = gaussianDE(varargin)
% DE M-file for DE.fig
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DE

% Last Modified by GUIDE v2.5 15-Apr-2013 15:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gaussianDE_OpeningFcn, ...
                   'gui_OutputFcn',  @gaussianDE_OutputFcn, ...
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
% --- Executes just before DE is made visible.
function gaussianDE_OpeningFcn(hObject, eventdata, handles, varargin)
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

function pushbuttonStart_Callback(hObject, eventdata, handles)
mydata = getappdata(handles.figure1,'mydata');

check_value = get(handles.checkbox4, 'Value');
    check_max = get(handles.checkbox4, 'Max');
   
    % read the DE parameters
     N = str2num(get(handles.editN, 'String')); % # LEDs       
    if (check_value == check_max)
     set(handles.editP,'String',N*10);
    end
    gen = str2num(get(handles.editG, 'String')); % # of generations
    P = str2num(get(handles.editP, 'String')); % population size
    F = str2num(get(handles.editF, 'String')); % mutation constant F
    CR = str2num(get(handles.editCR, 'String')); % crossover constant CR
    
    saveString = strcat('Gaussian',' N=',num2str(N),' Gen=',num2str(gen),...
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
    FWHMMin = 10; 
    FWHMMax = 10; 
    % save the parameters of this search
    fprintf(fid, 'Gen: %u\nP: %u\n', gen, P);
    fprintf(fid, 'F: %4.2f\nCR: %5.2f\nN: %u\n',F, CR, N);
    % calculate wavelenght regions, depends on # LEDs
    % N = # LEDs
    dlambda = (lambdaMax - lambdaMin) / N;
    %lambdas = zeros(N,1);
    lambdas(1) = lambdaMin;
    for i=2:N
        lambdas(i) = lambdas(i-1) + dlambda;
    end
    lambdas(N+1) = lambdaMax;  
% ----------------- Start differential evolution --------------------------
% ----------------- Generate initial population ---------------------------
    pop = zeros(P, 3*N); % I1,...,IN, FWHM1,...,FWHMN, lamda1,...,lamdaN 
    d = Imax - Imin;
    pop(:,1:N) = Imin + d * rand(P, N); % random intensities
    d = FWHMMax - FWHMMin;
    pop(:,N+1:2*N) = FWHMMin + d*rand(P, N); % random widths
    % wevelenghts
    d = lambdas(2)-lambdas(1);
    for i=1:N
        pop(:,2*N+i)= lambdas(i) + d * rand(P, 1);  % random lamdas
    end
    % various variables to speed up the calculations
    score = zeros(1,P); % scores of this population
    cct = zeros(1,P);   % CCT of this generation
    Ra = zeros(1,P); % Ra of this population
    Rb = zeros(1,P); % Rb of this population
    Rc = zeros(1,P); % Rc of this population
    Rmin = zeros(1,P); % Rmin of this population
    index = zeros(1,P); % min index of this population
    eta = zeros(1,P); % eta of this population
    %child population
    scoretemp = zeros(1,P); % scores of new population
    ccttemp = zeros(1,P);   % CCT of new population
    Ratemp = zeros(1,P); % Ra of new population
    Rbtemp = zeros(1,P); % Rb of new population
    Rctemp = zeros(1,P); % Rc of new population
    Rmintemp = zeros(1,P); % Rmin of new population
    indextemp = zeros(1,P); % index of Rmin of new population
    etatemp = zeros(1,P); % eta of new population
    rot= (0:1:P-1); %rotating index array
    
    spd = zeros((lambdaMax-lambdaMin)/5 + 1, P);% spds of a population
    bestscore = 0; % best score overall
    bestoverall = zeros(1, 3*N); % best overall member
    
    set(handles.editLeftToDo, 'String', gen); % initial generation 
    % --- check the initial population
    % create spds for the initial population members
    const = 2*sqrt(2* log(2));
    for i = 1:P   
        for j = 1:N
            spd(:,i)=spd(:,i) + pop(i, j).*exp(-((mydata.range(:)-...
                     pop(i,2*N+j)).^2)./(2.*(pop(i, N+j)/const).^2));     
        end
    end
    % --- calculate scores for the initial population members
    for i = 1:P
       [score(i), Ra(i), Rb(i), Rc(i), eta(i), cct(i), Rmin(i),... 
                index(i)] = calcscore(handles, spd(:,i)); 
    end
% ===== For all generations or until the desired fitness is achieved=======
    for generation = 1:gen  
        [mem, ibest] = max(score); % score the members
        if bestscore < score(ibest) % is current highest>overall highest
           bestscore = score(ibest); % replace bestscore with this gen best
           bestoverall = pop(ibest, :); % replace bestoverall with this gen
           % save generation and bestoverall member
           fprintf(fid, '\n%6d %5d\t', generation, round(bestscore));
           fprintf(fid, '%f\t',bestoverall);
           fprintf(fid, '%d\t%d\t%d\t%d\t%d\t%d\t%d',round(cct(ibest)), ...
               round(Ra(ibest)), round(Rb(ibest)), round(Rc(ibest)), ...
               round(eta(ibest)), round(Rmin(ibest)), round(index(ibest)));
        end
        
%----------Mutate and crossover - create a new population------------------
        index = randperm(2);
        a1 = randperm(P);
        rt = rem(rot+index(1), P);
        a2 = a1(rt+1);
        rt = rem(rot+index(2), P);
        a3 = a2(rt+1);
        pm1 = pop(a1,:);
        pm2 = pop(a2,:);
        pm3 = pop(a3,:);
        % crossover constant CR
        mui = rand(P, 3*N) < CR; % all randoms < 0.5 are 1, 0 otherwise
        mpo = mui < 0.5; % inverse mask to mui
        temp = pm3+F*(pm1-pm2);
        temp = pop.*mpo + temp.*mui;
        % --- limit the population values for I and FWHM
        for i = 1:P
            for j = 1:N
                if temp(i, j) > Imax
                    temp(i, j) = Imax;
                else if temp(i, j) < Imin
                    temp(i, j) = Imin;
                    end
                end
            end
            for j = N+1:2*N
                if temp(i, j) > FWHMMax
                    temp(i, j) = FWHMMax;
                else if temp(i, j) < FWHMMin
                    temp(i, j) = FWHMMin;
                    end
                end
            end
            for j = 2*N+1:3*N
                if temp(i, j) > lambdaMax
                    temp(i, j) = lambdaMax;
                else if temp(i, j) < lambdaMin
                    temp(i, j) = lambdaMin;
                    end
                end
            end
        end         
% --- select which vectors are allowed to enter the new population--> only 
% --- those with scores higher than the original scores are added
        spd = zeros((lambdaMax-lambdaMin)/5 + 1, P); % spd
        for i = 1:P   
           for j = 1:N
            spd(:,i)=spd(:,i) + temp(i, j).*exp(-((mydata.range(:)-...
                     temp(i,2*N+j)).^2)./(2.*(temp(i, N+j)./const)^2));     
           end
        end
        % calculate scores of the temp population
        for i = 1:P
            [scoretemp(i), Ratemp(i), Rbtemp(i), Rctemp(i), etatemp(i), ...
                               ccttemp(i), Rmintemp(i), indextemp(i)] = ...
                                         calcscore(handles, spd(:,i)); 
        end
        for i = 1:P
            if scoretemp(i) > score(i) % new individual is better than old?
               pop(i, :) = temp(i,:); % replace old individual with new one
               score(i) = scoretemp(i); % add its score
               Ra(i) = Ratemp(i); % replace Ra
               Rb(i) = Rbtemp(i); % replace Rb
               Rc(i) = Rctemp(i); % replace Rc
               eta(i) = etatemp(i); % replace eta
               cct(i) = ccttemp(i);   % replace CCT
               Rmin(i) = Rmintemp(i); % replace Rmin
               index(i) = indextemp(i); % replace index of Rmin
            end
        end
        set(handles.editLeftToDo, 'String', gen-generation); % generation #
        set(handles.editbestscore , 'String', num2str(round(bestscore))); % score
        drawnow;
        guidata(hObject, handles);
    end;
% ---------- Finish: score > fitness OR all geneerations checked ----------
    % prepare the best individual
    spd = zeros((lambdaMax-lambdaMin)/5 + 1, 1);% spd this
    for j = 1:N
        spd(:)=spd(:) + bestoverall(j).*exp(-((mydata.range(:)-...
               bestoverall(2*N+j)).^2)./(2.*(bestoverall(N+j)/const).^2));     
    end
    [score, Ra, Rb, Rc, eta, cct, Rmin,index] = calcscore(handles, spd); 
    set(handles.editRa , 'String', num2str(round(Ra))); % Ra
    set(handles.editRb , 'String', num2str(round(Rb))); % Rb
    set(handles.editRc , 'String', num2str(round(Rc))); % Rc
    set(handles.editLa , 'String', num2str(round(eta))); % e
    set(handles.editbestscore , 'String', num2str(round(score))); % score
    set(handles.edit , 'String', num2str(round(cct))); % CCT
    set(handles.editworst , 'String', num2str(index)); % index of the worst
    set(handles.editmin , 'String', num2str(round(Rmin))); % Rmin
    % save the best spd to file
%     fprintf(fid, '\n\n=======\nBEST SPD \n');
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
cla(handles.spd,'reset');
set(handles.spd, 'Visible', 'off');
set(handles.editA, 'Enable', 'inactive');
set(handles.editB, 'Enable', 'inactive');
set(handles.editC, 'Enable', 'inactive');
set(handles.editD, 'Enable', 'inactive');
set(handles.editE, 'Enable', 'inactive');
set(handles.checkbox4,'Enable', 'inactive');
guidata(hObject, handles);

function setOn(hObject, eventdata, handles)
set(handles.editG, 'Enable', 'on');
set(handles.editP, 'Enable', 'on');
set(handles.editF, 'Enable', 'on');
set(handles.editCR, 'Enable', 'on');
set(handles.editN, 'Enable', 'on');
set(handles.pushbuttonStart, 'Enable', 'on');
set(handles.editA, 'Enable', 'on');
set(handles.editB, 'Enable', 'on');
set(handles.editC, 'Enable', 'on');
set(handles.editD, 'Enable', 'on');
set(handles.editE, 'Enable', 'on');
set(handles.checkbox4,'Enable', 'on');
guidata(hObject, handles);

function checkboxSave_Callback(hObject, eventdata, handles)

function varargout = gaussianDE_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
