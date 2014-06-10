function varargout = helpMenu(varargin)
% HELPMENU MATLAB code for helpMenu.fig
%      HELPMENU, by itself, creates a new HELPMENU or raises the existing
%      singleton*.
%
%      H = HELPMENU returns the handle to a new HELPMENU or the handle to
%      the existing singleton*.
%
%      HELPMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HELPMENU.M with the given input arguments.
%
%      HELPMENU('Property','Value',...) creates a new HELPMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before helpMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to helpMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help helpMenu

% Last Modified by GUIDE v2.5 20-May-2013 16:14:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @helpMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @helpMenu_OutputFcn, ...
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


% --- Executes just before helpMenu is made visible.
function helpMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to helpMenu (see VARARGIN)

% Choose default command line output for helpMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.listbox1,'FontSize',14, 'String', importdata('HelpTopics.txt'));

% UIWAIT makes helpMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = helpMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
switch get(handles.listbox1,'Value')      
    case 1 
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Calc_CRI.txt'));
    case 2 
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Calc_CRI.txt'));
    case 3
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Calc_CQS.txt'));
    case 4 
    case 5
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Opt_CRI.txt'));        
    case 6
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Opt_CRI.txt'));        
    case 7
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Opt_CQS.txt'));       
    case 8
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Opt_Combos.txt'));    
    case 9
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Opt_Theoretical.txt'));        
    case 10    
    case 11
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Vis_Compare.txt'));    
    case 12
        set(handles.text1,'FontSize',12,'visible', 'on', 'String', importdata('Vis_Compare.txt'));          
end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text1_Callback(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text1 as text
%        str2double(get(hObject,'String')) returns contents of text1 as a double


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
