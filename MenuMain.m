%Optimization/Visualization wth Title Menu
%Version 0.2
%By: Pavel Boryseiko
%01/04/13

function varargout = MenuMain(varargin)
% MENUMAIN MATLAB code for MenuMain.fig
%      MENUMAIN, by itself, creates a new MENUMAIN or raises the existing
%      singleton*.
%
%      H = MENUMAIN returns the handle to a new MENUMAIN or the handle to
%      the existing singleton*.
%
%      MENUMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MENUMAIN.M with the given input arguments.
%
%      MENUMAIN('Property','Value',...) creates a new MENUMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MenuMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MenuMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MenuMain

% Last Modified by GUIDE v2.5 01-May-2013 12:54:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MenuMain_OpeningFcn, ...
                   'gui_OutputFcn',  @MenuMain_OutputFcn, ...
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


% --- Executes just before MenuMain is made visible.
function MenuMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MenuMain (see VARARGIN)

imshow('MainScreen.jpg', 'border', 'tight')
% Choose default command line output for MenuMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MenuMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = MenuMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function opt_menu_Callback(hObject, eventdata, handles)
% hObject    handle to opt_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function vis_menu_Callback(hObject, eventdata, handles)
% hObject    handle to vis_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function CRI_menu_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_opt_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function CQS_menu_Callback(hObject, eventdata, handles)
% hObject    handle to CQS_opt_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function DE_menu_Callback(hObject, eventdata, handles)
% hObject    handle to DE_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function gaus_menu_Callback(hObject, eventdata, handles)
% hObject    handle to gaus_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gaussianDE()

% --------------------------------------------------------------------
function rect_menu_Callback(hObject, eventdata, handles)
% hObject    handle to rect_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rectDE()

% --------------------------------------------------------------------
function tri_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tri_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
triDE()


% --------------------------------------------------------------------
function CQS_calc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to CQS_calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CQS()

% --------------------------------------------------------------------
function CQS_opt_menu_Callback(hObject, eventdata, handles)
% hObject    handle to CQS_opt_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CQSopt()

% --------------------------------------------------------------------
function CRI_calc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI()

% --------------------------------------------------------------------
function CRI_opt_menu_Callback(hObject, eventdata, handles)
% hObject    handle to CRI_opt_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CRIopt()


% --------------------------------------------------------------------
function Calc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Calc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function spd_combo_menu_Callback(hObject, eventdata, handles)
% hObject    handle to spd_combo_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DE7()


% --------------------------------------------------------------------
function compare_menu_Callback(hObject, eventdata, handles)
% hObject    handle to compare_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VisMenu()

% --------------------------------------------------------------------
function plot_menu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Plot_GUI()


% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpMenu()
