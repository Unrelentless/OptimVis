function varargout = Draw_TCS(varargin)
% DRAW_TCS MATLAB code for Draw_TCS.fig
%      DRAW_TCS, by itself, creates a new DRAW_TCS or raises the existing
%      singleton*.
%
%      H = DRAW_TCS returns the handle to a new DRAW_TCS or the handle to
%      the existing singleton*.
%
%      DRAW_TCS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAW_TCS.M with the given input arguments.
%
%      DRAW_TCS('Property','Value',...) creates a new DRAW_TCS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Draw_TCS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Draw_TCS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Draw_TCS

% Last Modified by GUIDE v2.5 09-Jul-2013 13:56:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Draw_TCS_OpeningFcn, ...
                   'gui_OutputFcn',  @Draw_TCS_OutputFcn, ...
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


% --- Executes just before Draw_TCS is made visible.
function Draw_TCS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Draw_TCS (see VARARGIN)

% Choose default command line output for Draw_TCS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

TCS = varargin{1};
colour_metric = varargin{2};
TCS_sRGB = varargin{3};

drawTCS(TCS, colour_metric, TCS_sRGB, handles, hObject);

% UIWAIT makes Draw_TCS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Draw_TCS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function drawTCS(TCS, colour_metric, TCS_sRGB, handles, hObject)
invTCS_sRGB = TCS_sRGB';
    if colour_metric == 1   %if CQS is selected  
        TCS_names = importdata('CQS_ColourSamples.txt');
        if size(TCS) == [401, 16]
        xGrid = 380:1:780;
        else    
        xGrid = 380:5:780;
        end
        axes(handles.axes_TCS);
            for i=1:15
            mydata.plotLine(i) = plot(xGrid,TCS(:, i),'Color',invTCS_sRGB(i, 1:3),'LineWidth',2);
            hold on        
            j = strcat('checkbox',num2str(i)); %Dynamically create variables with identical name as test colour samples.
            text_handle = findobj('Tag',j); %convert the above string to a handle.
            set(text_handle,'String',TCS_names(i, 1)); %Dynamically update the munsell hue/chroma/value names
            set(text_handle,'Backgroundcolor',[TCS_sRGB(1,i),TCS_sRGB(2,i),TCS_sRGB(3,i)]); %colour the sample.
            set(text_handle, 'Value', 1);
            end
        hold off  
        title('CQS Test Colour Samples Reflectance Curve');
        xlabel('Wavelength')
        ylabel('Magnitude')
    else %else CRI is selected
        TCS_names = importdata('CRI_ColourSamples.txt');
        if size(TCS) == [401, 16]
        xGrid = 380:1:780;
        else    
        xGrid = 380:5:780;
        end        
        axes(handles.axes_TCS);
        set(handles.checkbox15, 'visible', 'off');     
            for i=1:14
            mydata.plotLine(i) = plot(xGrid,TCS(:, i),'Color',invTCS_sRGB(i, 1:3),'LineWidth',2);
            hold on       
            j = strcat('checkbox',num2str(i)); %Dynamically create variables with identical name as test colour samples.
            text_handle = findobj('Tag',j); %convert the above string to a handle.
            set(text_handle,'String',TCS_names(i, 1)); %Dynamically update the munsell hue/chroma/value names
            set(text_handle,'Backgroundcolor',[TCS_sRGB(1,i),TCS_sRGB(2,i),TCS_sRGB(3,i)]); %colour the sample.
            set(text_handle, 'Value', 1);
            end
        hold off
        title('CRI Test Colour Samples Reflectance Curve');
        xlabel('Wavelength')
        ylabel('Magnitude')
    end
   
    setappdata(hObject,'mydata',mydata);



% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox1, 'Value') == 1
    set(mydata.plotLine(1),'Visible','on');
else
    set(mydata.plotLine(1),'Visible','off');
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox2, 'Value') == 1
    set(mydata.plotLine(2),'Visible','on');
else
    set(mydata.plotLine(2),'Visible','off');
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox3, 'Value') == 1
    set(mydata.plotLine(3),'Visible','on');
else
    set(mydata.plotLine(3),'Visible','off');
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox4, 'Value') == 1
    set(mydata.plotLine(4),'Visible','on');
else
    set(mydata.plotLine(4),'Visible','off');
end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox5, 'Value') == 1
    set(mydata.plotLine(5),'Visible','on');
else
    set(mydata.plotLine(5),'Visible','off');
end

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox6, 'Value') == 1
    set(mydata.plotLine(6),'Visible','on');
else
    set(mydata.plotLine(6),'Visible','off');
end

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox7, 'Value') == 1
    set(mydata.plotLine(7),'Visible','on');
else
    set(mydata.plotLine(7),'Visible','off');
end

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox8, 'Value') == 1
    set(mydata.plotLine(8),'Visible','on');
else
    set(mydata.plotLine(8),'Visible','off');
end

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox9, 'Value') == 1
    set(mydata.plotLine(9),'Visible','on');
else
    set(mydata.plotLine(9),'Visible','off');
end

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox10, 'Value') == 1
    set(mydata.plotLine(10),'Visible','on');
else
    set(mydata.plotLine(10),'Visible','off');
end

% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox11, 'Value') == 1
    set(mydata.plotLine(11),'Visible','on');
else
    set(mydata.plotLine(11),'Visible','off');
end

% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox12, 'Value') == 1
    set(mydata.plotLine(12),'Visible','on');
else
    set(mydata.plotLine(12),'Visible','off');
end

% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox13, 'Value') == 1
    set(mydata.plotLine(13),'Visible','on');
else
    set(mydata.plotLine(13),'Visible','off');
end

% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox14, 'Value') == 1
    set(mydata.plotLine(14),'Visible','on');
else
    set(mydata.plotLine(14),'Visible','off');
end

% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mydata = getappdata(handles.figure1,'mydata');

if get(handles.checkbox15, 'Value') == 1
    set(mydata.plotLine(15),'Visible','on');
else
    set(mydata.plotLine(15),'Visible','off');
end
