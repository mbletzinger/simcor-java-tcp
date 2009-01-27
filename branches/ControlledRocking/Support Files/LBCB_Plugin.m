function varargout = LBCB_Plugin(varargin)
% MLOOP M-file for MLoop.fig
%      MLOOP, by itself, creates a new MLOOP or raises the existing
%      singleton*.
%
%      H = MLOOP returns the handle to a new MLOOP or the handle to
%      the existing singleton*.
%
%      MLOOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MLOOP.M with the given input arguments.
%
%      MLOOP('Property','Value',...) creates a new MLOOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MLoop_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MLoop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help MLoop

% Last Modified by GUIDE v2.5 20-May-2008 14:03:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MLoop_OpeningFcn, ...
                   'gui_OutputFcn',  @MLoop_OutputFcn, ...
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


% --- Executes just before MLoop is made visible.
function MLoop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MLoop (see VARARGIN)

handles = Plugin_Initialize(handles,1); 				% Initialize values
handles.output = hObject;	% Choose default command line output for MLoop
guidata(hObject, handles);	% Update handles structure
% UIWAIT makes MLoop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MLoop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% *************************************************************************************************
% *************************************************************************************************
% Push Buttons
% *************************************************************************************************
% *************************************************************************************************

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_LBCB_Connect. 
% -------------------------------------------------------------------------------------------------
function PB_LBCB_Connect_Callback(hObject, eventdata, handles)

disp('Connecting to Operations Manager ............................');

handles.MDL.InputPort 		= str2num(get(handles.Edit_PortNo,  	'String'));
handles.MDL.InputFile 		= get(handles.Edit_File_Path,       	'String');
handles.MDL.IP 			= get(handles.Edit_LBCB_IP,	    	'String');
handles.MDL.Port 		= str2num(get(handles.Edit_LBCB_Port,	'String'));

% Connect to the Operations Manager
handles.MDL.Comm_obj = tcpip(handles.MDL.IP,handles.MDL.Port);            % create TCPIP obj(objInd)ect
set(handles.MDL.Comm_obj,'InputBufferSize', 1024*100);                    % set buffer size
handles.MDL = open(handles.MDL);
disp('Connection is established with Operations Manager.');
guidata(hObject, handles);

% Run_Simulation runs the control algorithm.
Run_Simulation(hObject, eventdata, handles);


% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_LBCB_Disconnect.
% -------------------------------------------------------------------------------------------------
function PB_LBCB_Disconnect_Callback(hObject, eventdata, handles)

button = questdlg('Disconnect from Operations Manager? All variables will be initialized.','Disconnect','Yes','No','Yes');
switch button
	case 'Yes'
		disp('Test has successfully completed.                              ');
		close(handles.MDL);
		disp('Connection to remote site is closed.                                ');
		
		handles = readGUI(handles);
		handles = Plugin_Initialize(handles,2); 				% Initialize values
		
		guidata(hObject, handles);
	case 'No'
end


% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_Load_File.
% -------------------------------------------------------------------------------------------------
function PB_Load_File_Callback(hObject, eventdata, handles)

[file,path] = uigetfile({'*.txt';'*.dat';'*.m';'*.mdl';'*.mat';'*.*'},'Load displacement history.');
if file ~= 0
	set(handles.Edit_File_Path, 'String',[path file]);
	handles.MDL.InputFile = [path file];
	guidata(hObject, handles);
end

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_Load_Config.
% -------------------------------------------------------------------------------------------------
function PB_Load_Config_Callback(hObject, eventdata, handles)

[file,path] = uigetfile('*.mat','Load Configuration');
if file ~= 0 
	load([path file]);
	handles.MDL = MDL;
	handles = Plugin_Initialize(handles, 2);
	guidata(hObject, handles);
end

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_Load_Default.
% -------------------------------------------------------------------------------------------------
function PB_Load_Default_Callback(hObject, eventdata, handles)

button = questdlg('All variables will be reset to default values. Proceed?','Load default configuration.','Yes','No','Yes');
switch button
	case 'Yes'
		handles = Plugin_Initialize(handles,1);
	case 'No'
end

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_Save_Config.
% -------------------------------------------------------------------------------------------------
function PB_Save_Config_Callback(hObject, eventdata, handles)

[file,path] = uiputfile('*.mat','Save Configuration As');
if file ~= 0
	handles = readGUI(handles);
	MDL = handles.MDL;	% copy internal variables
	
	MDL.M_Disp        	= [];                       % Measured displacement at each step, Num_DOFx1
	MDL.M_Forc        	= [];                       % Measured force at each step, Num_DOFx1
	MDL.T_Disp_0      	= [];                       % Previous step's target displacement, Num_DOFx1
	MDL.T_Disp        	= [];                       % Target displacement, Num_DOFx1
	MDL.T_Forc_0      	= [];                       % Previous step's target displacement, Num_DOFx1
	MDL.T_Forc        	= [];                       % Target displacement, Num_DOFx1
	MDL.Comm_obj      	= {};                       % communication object

	% Following six variables are only used GUI mode to plot history of data
	MDL.tDisp_history     	= [];                   	% History of target   displacement in global system, total step numbet x Num_DOF, in HSF space
	MDL.tForc_history     	= [];                   	% History of target   displacement in global system, total step numbet x Num_DOF, in HSF space
	MDL.mDisp_history     	= [];                   	% History of measured displacement in global system, total step numbet x Num_DOF, in HSF space
	MDL.mForc_history     	= [];                   	% History of measured force in global system, total step numbet x Num_DOF, in HSF space
	MDL.TransM		= [];
	MDL.TransID           	= '';                  		% Transaction ID
	MDL.curStep       	= 0;                        	% Current step number for this module
	MDL.totStep       	= 0;                        	% Total number of steps to be tested
	MDL.curState      	= 0;                        	% Current state of simulation

	save([path file], 'MDL')
end

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in PB_Pause.
% -------------------------------------------------------------------------------------------------
function PB_Pause_Callback(hObject, eventdata, handles)


% *************************************************************************************************
% *************************************************************************************************
% Check Boxes
% *************************************************************************************************
% *************************************************************************************************

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in CB_MovingWindow.
% -------------------------------------------------------------------------------------------------
function CB_MovingWindow_Callback(hObject, eventdata, handles)

if get(hObject,'value')
	set(handles.Edit_Window_Size, 'enable', 	'on');
else
	set(handles.Edit_Window_Size, 'enable', 	'off');
end


% -------------------------------------------------------------------------------------------------
% --- Executes on button press in CB_Disp_Limit.
% -------------------------------------------------------------------------------------------------
function CB_Disp_Limit_Callback(hObject, eventdata, handles)

% handles.MDL.CheckLimit_DispTot = get(hObject,'Value');
if get(hObject,'Value')

else
	set(handles.Edit_DLmin_DOF1, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmin_DOF2, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmin_DOF3, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmin_DOF4, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmin_DOF5, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmin_DOF6, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmax_DOF1, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmax_DOF2, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmax_DOF3, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmax_DOF4, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmax_DOF5, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLmax_DOF6, 'backgroundcolor',[1 1 1]);
end                                       
% guidata(hObject, handles);

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in CB_Forc_Limit.
% -------------------------------------------------------------------------------------------------
function CB_Forc_Limit_Callback(hObject, eventdata, handles)

% handles.MDL.CheckLimit_ForcTot = get(hObject,'Value');
if get(hObject,'Value')

else
	set(handles.Edit_FLmin_DOF1, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmin_DOF2, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmin_DOF3, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmin_DOF4, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmin_DOF5, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmin_DOF6, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmax_DOF1, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmax_DOF2, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmax_DOF3, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmax_DOF4, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmax_DOF5, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_FLmax_DOF6, 'backgroundcolor',[1 1 1]);
end  
% guidata(hObject, handles);

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in CB_Disp_Inc.
% -------------------------------------------------------------------------------------------------
function CB_Disp_Inc_Callback(hObject, eventdata, handles)

% handles.MDL.CheckLimit_DispInc = get(hObject,'Value');
if get(hObject,'Value')

else
	set(handles.Edit_DLinc_DOF1, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLinc_DOF2, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLinc_DOF3, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLinc_DOF4, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLinc_DOF5, 'backgroundcolor',[1 1 1]);
	set(handles.Edit_DLinc_DOF6, 'backgroundcolor',[1 1 1]);
end      




% *************************************************************************************************
% *************************************************************************************************
% EDIT BOXES 
% *************************************************************************************************
% *************************************************************************************************

% -------------------------------------------------------------------------------------------------
function Edit_PortNo_Callback(hObject, eventdata, handles)
function Edit_File_Path_Callback(hObject, eventdata, handles)
function Edit_LBCB_IP_Callback(hObject, eventdata, handles)
function Edit_LBCB_Port_Callback(hObject, eventdata, handles)
function Edit_K_low_Callback(hObject, eventdata, handles)
function Edit_Iteration_Ksec_Callback(hObject, eventdata, handles)
function Edit_K_factor_Callback(hObject, eventdata, handles)
function Edit_Max_Itr_Callback(hObject, eventdata, handles)
function Edit_Disp_SF_Callback(hObject, eventdata, handles)
function Edit_Rotation_SF_Callback(hObject, eventdata, handles)
function Edit_Forc_SF_Callback(hObject, eventdata, handles)
function Edit_Moment_SF_Callback(hObject, eventdata, handles)
function Edit_DLmin_DOF1_Callback(hObject, eventdata, handles)
function Edit_DLmin_DOF2_Callback(hObject, eventdata, handles)
function Edit_DLmin_DOF3_Callback(hObject, eventdata, handles)
function Edit_DLmin_DOF4_Callback(hObject, eventdata, handles)
function Edit_DLmin_DOF5_Callback(hObject, eventdata, handles)
function Edit_DLmin_DOF6_Callback(hObject, eventdata, handles)
function Edit_DLmax_DOF1_Callback(hObject, eventdata, handles)
function Edit_DLmax_DOF2_Callback(hObject, eventdata, handles)
function Edit_DLmax_DOF3_Callback(hObject, eventdata, handles)
function Edit_DLmax_DOF4_Callback(hObject, eventdata, handles)
function Edit_DLmax_DOF5_Callback(hObject, eventdata, handles)
function Edit_DLmax_DOF6_Callback(hObject, eventdata, handles)
function Edit_DLinc_DOF1_Callback(hObject, eventdata, handles)
function Edit_DLinc_DOF2_Callback(hObject, eventdata, handles)
function Edit_DLinc_DOF3_Callback(hObject, eventdata, handles)
function Edit_DLinc_DOF4_Callback(hObject, eventdata, handles)
function Edit_DLinc_DOF5_Callback(hObject, eventdata, handles)
function Edit_DLinc_DOF6_Callback(hObject, eventdata, handles)
function Edit_FLmin_DOF1_Callback(hObject, eventdata, handles)
function Edit_FLmin_DOF2_Callback(hObject, eventdata, handles)
function Edit_FLmin_DOF3_Callback(hObject, eventdata, handles)
function Edit_FLmin_DOF4_Callback(hObject, eventdata, handles)
function Edit_FLmin_DOF5_Callback(hObject, eventdata, handles)
function Edit_FLmin_DOF6_Callback(hObject, eventdata, handles)
function Edit_FLmax_DOF1_Callback(hObject, eventdata, handles)
function Edit_FLmax_DOF2_Callback(hObject, eventdata, handles)
function Edit_FLmax_DOF3_Callback(hObject, eventdata, handles)
function Edit_FLmax_DOF4_Callback(hObject, eventdata, handles)
function Edit_FLmax_DOF5_Callback(hObject, eventdata, handles)
function Edit_FLmax_DOF6_Callback(hObject, eventdata, handles)

% status indicator
function Edit_Waiting_CMD_Callback(hObject, eventdata, handles)
function Edit_Disp_Itr_Callback(hObject, eventdata, handles)
function Edit_Force_Itr_Callback(hObject, eventdata, handles)
function Edit_Step_Reduction_Callback(hObject, eventdata, handles)
function Edit_Propose_Callback(hObject, eventdata, handles)
function Edit_Execute_Callback(hObject, eventdata, handles)
function Edit_Querying_Callback(hObject, eventdata, handles)

function Edit_Sample_Size_Callback(hObject, eventdata, handles)
function Edit_Window_Size_Callback(hObject, eventdata, handles)

% *************************************************************************************************
% *************************************************************************************************
% Radio Buttons
% *************************************************************************************************
% *************************************************************************************************

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in RB_Source_Network.
% -------------------------------------------------------------------------------------------------
function RB_Source_Network_Callback(hObject, eventdata, handles)

set(handles.RB_Source_Network,	'value',	1);
set(handles.Edit_PortNo,	'enable',	'on');

set(handles.RB_Source_File,	'value',	0);
set(handles.Edit_File_Path,	'enable',	'off');
set(handles.PB_Load_File,	'enable',	'off');


% -------------------------------------------------------------------------------------------------
% --- Executes on button press in RB_Source_File.
% -------------------------------------------------------------------------------------------------
function RB_Source_File_Callback(hObject, eventdata, handles)

set(handles.RB_Source_Network,	'value',	0);
set(handles.Edit_PortNo,	'enable',	'off');

set(handles.RB_Source_File,	'value',	1);
set(handles.Edit_File_Path,	'enable',	'on');
set(handles.PB_Load_File,	'enable',	'on');


% -------------------------------------------------------------------------------------------------
% --- Executes on button press in RB_Disp_Ctrl.
% -------------------------------------------------------------------------------------------------
function RB_Disp_Ctrl_Callback(hObject, eventdata, handles)

set(handles.RB_Disp_Ctrl,		'value',	1);
set(handles.RB_Forc_Ctrl,		'value',	0);

set(handles.PM_Frc_Ctrl_DOF,		'enable',	'off');
set(handles.Edit_K_low,			'enable',	'off');
set(handles.Edit_Iteration_Ksec,	'enable',	'off');
set(handles.Edit_K_factor,		'enable',	'off');
set(handles.Edit_Max_Itr,		'enable',	'off');

% -------------------------------------------------------------------------------------------------
% --- Executes on button press in RB_Forc_Ctrl.
% -------------------------------------------------------------------------------------------------
function RB_Forc_Ctrl_Callback(hObject, eventdata, handles)

set(handles.RB_Disp_Ctrl,		'value',	0);
set(handles.RB_Forc_Ctrl,		'value',	1);

set(handles.PM_Frc_Ctrl_DOF,		'enable',	'on');
set(handles.Edit_K_low,			'enable',	'on');
set(handles.Edit_Iteration_Ksec,	'enable',	'on');
set(handles.Edit_K_factor,		'enable',	'on');
set(handles.Edit_Max_Itr,		'enable',	'on');


% *************************************************************************************************
% *************************************************************************************************
% Popup Menus
% *************************************************************************************************
% *************************************************************************************************

% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_Model_Coord.
% -------------------------------------------------------------------------------------------------
function PM_Model_Coord_Callback(hObject, eventdata, handles)

handles.MDL.ModelCoord = get(hObject,'Value') ;
axes(handles.axes_model);
load Resources;
switch handles.MDL.ModelCoord
	case 1
		image(ModelCoord01); % Read the image file banner.bmp)		
	case 2
		image(ModelCoord02); % Read the image file banner.bmp)		
end
set(handles.axes_model, 'Visible', 'off');
guidata(hObject, handles);


% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_LBCB_Coord.
% -------------------------------------------------------------------------------------------------
function PM_LBCB_Coord_Callback(hObject, eventdata, handles)

handles.MDL.LBCBCoord = get(hObject,'Value') ;
load Resources;
axes(handles.axes_LBCB);
switch handles.MDL.LBCBCoord;
	case 1
		image(LBCB_R_Coord01); % Read the image file banner.bmp
	case 2
		image(LBCB_R_Coord02); % Read the image file banner.bmp
	case 3
		image(LBCB_R_Coord03); % Read the image file banner.bmp
	case 4
		image(LBCB_R_Coord04); % Read the image file banner.bmp
end
set(handles.axes_LBCB, 'Visible', 'off');
guidata(hObject, handles);

% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_Frc_Ctrl_DOF.
% -------------------------------------------------------------------------------------------------
function PM_Frc_Ctrl_DOF_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_Axis_X1.
% -------------------------------------------------------------------------------------------------
function PM_Axis_X1_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_Axis_X2.
% -------------------------------------------------------------------------------------------------
function PM_Axis_X2_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_Axis_Y1.
% -------------------------------------------------------------------------------------------------
function PM_Axis_Y1_Callback(hObject, eventdata, handles)

% -------------------------------------------------------------------------------------------------
% --- Executes on selection change in PM_Axis_Y2.
% -------------------------------------------------------------------------------------------------
function PM_Axis_Y2_Callback(hObject, eventdata, handles)



% --- Executes on button press in CB_UpdateMonitor.
function CB_UpdateMonitor_Callback(hObject, eventdata, handles)
handles.MDL.UpdateMonitor = get(handles.CB_UpdateMonitor, 'value');
if handles.MDL.UpdateMonitor
	set(handles.PM_Axis_X1,		'enable',	'on');
	set(handles.PM_Axis_Y1,		'enable',	'on');
	set(handles.PM_Axis_X2,		'enable',	'on');
	set(handles.PM_Axis_Y2,		'enable',	'on');
	set(handles.CB_MovingWindow,	'enable',	'on');
	set(handles.Edit_Window_Size,	'enable',	'on');
else
	set(handles.PM_Axis_X1,		'enable',	'off');
	set(handles.PM_Axis_Y1,		'enable',	'off');
	set(handles.PM_Axis_X2,		'enable',	'off');
	set(handles.PM_Axis_Y2,		'enable',	'off');
	set(handles.CB_MovingWindow,	'enable',	'off');
	set(handles.Edit_Window_Size,	'enable',	'off');
end



% --- Executes on selection change in PM_Axis_Y3.
function PM_Axis_Y3_Callback(hObject, eventdata, handles)
% hObject    handle to PM_Axis_Y3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PM_Axis_Y3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PM_Axis_Y3


% --- Executes during object creation, after setting all properties.
function PM_Axis_Y3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM_Axis_Y3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PM_Axis_X3.
function PM_Axis_X3_Callback(hObject, eventdata, handles)
% hObject    handle to PM_Axis_X3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PM_Axis_X3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PM_Axis_X3


% --- Executes during object creation, after setting all properties.
function PM_Axis_X3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM_Axis_X3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CB_Noise_Compensation.
function CB_Noise_Compensation_Callback(hObject, eventdata, handles)



function Edit_Dtol_DOF1_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dtol_DOF1 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dtol_DOF1 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dtol_DOF1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dtol_DOF2_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dtol_DOF2 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dtol_DOF2 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dtol_DOF2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dtol_DOF3_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dtol_DOF3 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dtol_DOF3 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dtol_DOF3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dtol_DOF4_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dtol_DOF4 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dtol_DOF4 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dtol_DOF4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dtol_DOF5_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dtol_DOF5 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dtol_DOF5 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dtol_DOF5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dtol_DOF6_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dtol_DOF6 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dtol_DOF6 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dtol_DOF6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dtol_DOF6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dsub_DOF1_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dsub_DOF1 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dsub_DOF1 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dsub_DOF1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dsub_DOF2_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dsub_DOF2 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dsub_DOF2 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dsub_DOF2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dsub_DOF3_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dsub_DOF3 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dsub_DOF3 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dsub_DOF3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dsub_DOF4_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dsub_DOF4 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dsub_DOF4 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dsub_DOF4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dsub_DOF5_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dsub_DOF5 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dsub_DOF5 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dsub_DOF5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Dsub_DOF6_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Dsub_DOF6 as text
%        str2double(get(hObject,'String')) returns contents of Edit_Dsub_DOF6 as a double


% --- Executes during object creation, after setting all properties.
function Edit_Dsub_DOF6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Dsub_DOF6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Edit_Processing_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_Processing as text
%        str2double(get(hObject,'String')) returns contents of Edit_Processing as a double


% --- Executes during object creation, after setting all properties.
function Edit_Processing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Edit_Processing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RB_Disp_Mesurement_LBCB.
function RB_Disp_Mesurement_LBCB_Callback(hObject, eventdata, handles)
% hObject    handle to RB_Disp_Mesurement_LBCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RB_Disp_Mesurement_LBCB



function Target_DX_Callback(hObject, eventdata, handles)
% hObject    handle to Target_DX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Target_DX as text
%        str2double(get(hObject,'String')) returns contents of Target_DX as a double


% --- Executes during object creation, after setting all properties.
function Target_DX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Target_DX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit110_Callback(hObject, eventdata, handles)
% hObject    handle to edit110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit110 as text
%        str2double(get(hObject,'String')) returns contents of edit110 as a double


% --- Executes during object creation, after setting all properties.
function edit110_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit110 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit111_Callback(hObject, eventdata, handles)
% hObject    handle to edit111 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit111 as text
%        str2double(get(hObject,'String')) returns contents of edit111 as a double


% --- Executes during object creation, after setting all properties.
function edit111_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit111 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit112_Callback(hObject, eventdata, handles)
% hObject    handle to edit112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit112 as text
%        str2double(get(hObject,'String')) returns contents of edit112 as a double


% --- Executes during object creation, after setting all properties.
function edit112_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit112 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Target_MY_Callback(hObject, eventdata, handles)
% hObject    handle to Target_MY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Target_MY as text
%        str2double(get(hObject,'String')) returns contents of Target_MY as a double


% --- Executes during object creation, after setting all properties.
function Target_MY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Target_MY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Target_RZ_Callback(hObject, eventdata, handles)
% hObject    handle to Target_RZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Target_RZ as text
%        str2double(get(hObject,'String')) returns contents of Target_RZ as a double


% --- Executes during object creation, after setting all properties.
function Target_RZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Target_RZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in PauseBut.
function PauseBut_Callback(hObject, eventdata, handles)
% hObject    handle to PauseBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PauseBut










%---------------------------------------------------------------------------------------------------------
% AUX modules, 11/27/2007, Sung Jig Kim
%---------------------------------------------------------------------------------------------------------

% --- Executes on button press in AUXModule_Connect.
function AUXModule_Connect_Callback(hObject, eventdata, handles)
% hObject    handle to AUXModule_Connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Connect Each module
GUI_tmp_str ='Connecting to Camera and DAQ ................';
disp(GUI_tmp_str);
% UpdateStatusPanel(handles.ET_GUI_Process_Text,GUI_tmp_str,1); 
handles.AUX = open(handles.AUX,1);

% Enable LBCB Connection
%set(handles.PB_LBCB_Connect,	'enable',	'on');

GUI_tmp_str ='Connection is established with Camera and DAQ ...';
disp(GUI_tmp_str);
% UpdateStatusPanel(handles.ET_GUI_Process_Text,GUI_tmp_str,1); 

% set(handles.AUXModule_Disconnect,	'enable',	'on');
% set(handles.AUXModule_Connect,	'enable',	'off');

guidata(hObject, handles);

% --- Executes on button press in AUXModule_Disconnect.
function AUXModule_Disconnect_Callback(hObject, eventdata, handles)
% hObject    handle to AUXModule_Disconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


button = questdlg('Disconnect from Camera and DAQ? ','Disconnect','Disconnect All','Select Module','No','Select Module');
switch button
	case 'Disconnect All'
		button2 = questdlg('Is simulation completed?','Disconnect','Yes','No','No');
		if strcmp(button2,'Yes')
			GUI_tmp_str ='Simulation has successfully completed.      ';
			disp(GUI_tmp_str);
% 			UpdateStatusPanel(handles.ET_GUI_Process_Text,GUI_tmp_str,1);
			close(handles.AUX,1);
	
			GUI_tmp_str ='Connection to remote site is closed.     ';
			disp(GUI_tmp_str);
% 			UpdateStatusPanel(handles.ET_GUI_Process_Text,GUI_tmp_str,1);
	
% 			set(handles.AUXModule_Disconnect,	'enable',	'off');
% 			set(handles.AUXModule_Connect,	'enable',	'on');
			
			AUX_Initialized=get(handles.AUXModule_Connect, 'UserData'); 
			AUX_Initialized=AUX_Initialized*0;	
			set(handles.AUXModule_Connect, 'UserData', AUX_Initialized); 		
		end
	case 'Select Module'
		for i=1:length(handles.AUX)
			ListStr{1,i}=handles.AUX(i).name;
		end
		% SelectModule
		[s,v] = listdlg('PromptString','Select AUX modules',...
		                'SelectionMode','Multiple',...
		                'ListSize',[160,100],...
		                'ListString',ListStr);
		if v
			Num_discont_module=length(s);
			close(handles.AUX,Num_discont_module,s);
			
			AUX_Initialized=get(handles.AUXModule_Connect, 'UserData'); 
			for i=1:length(s)
				GUI_tmp_str =sprintf('Connection to %s is closed. ',handles.AUX(s(i)).name );
				AUX_Initialized(s(i))=0;
				disp(GUI_tmp_str);
% 				UpdateStatusPanel(handles.ET_GUI_Process_Text,GUI_tmp_str,1);
			end
			button2 = questdlg('Reconnect modules?','Reconnect','Yes','No','Yes');
			switch button2
				case 'Yes'
					handles.AUX = open(handles.AUX,Num_discont_module,s);
					for i=1:length(s)
						AUX_Initialized(s(i))=1;
					end
				case 'No'
			end
			set(handles.AUXModule_Connect, 'UserData', AUX_Initialized); 
		end
		
	case 'No'
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CRLogo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CRLogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate CRLogo

function Get_TGT_Callback(hObject, eventdata, handles)
% hObject    handle to Get_TGT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Get_TGT as text
%        str2double(get(hObject,'String')) returns contents of Get_TGT as a double


% --- Executes during object creation, after setting all properties.
function Get_TGT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Get_TGT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Iterns_Callback(hObject, eventdata, handles)
% hObject    handle to Iterns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Iterns as text
%        str2double(get(hObject,'String')) returns contents of Iterns as a double


% --- Executes during object creation, after setting all properties.
function Iterns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Iterns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Wait_OM_Callback(hObject, eventdata, handles)
% hObject    handle to Wait_OM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Wait_OM as text
%        str2double(get(hObject,'String')) returns contents of Wait_OM as a double


% --- Executes during object creation, after setting all properties.
function Wait_OM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Wait_OM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Process_Callback(hObject, eventdata, handles)
% hObject    handle to Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Process as text
%        str2double(get(hObject,'String')) returns contents of Process as a double


% --- Executes during object creation, after setting all properties.
function Process_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg('Closing GUI during simulation will interrupt the simulation. Do you want to close GUI?',...
                     'Close Request Function',...
                     'Yes','No','Yes');                 
switch selection,
    case 'Yes',
        if exist('NetwkLog_LBCB.txt')~=0
            copyfile('NetwkLog_LBCB.txt','../Output Files/NetwkLog_LBCB.txt','f');
        end 
        copyfile('Raw.txt','../Output Files/Raw.txt','f');
        copyfile('RunLog.txt','../Output Files/RunLog.txt','f');
        copyfile('TriggerLog.txt','../Output Files/TriggerLog.txt','f');
        cd('..');
        delete(hObject)
   case 'No'
     return
end



function NumPics_Callback(hObject, eventdata, handles)
% hObject    handle to NumPics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumPics as text
%        str2double(get(hObject,'String')) returns contents of NumPics as a double


% --- Executes during object creation, after setting all properties.
function NumPics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumPics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


