% Copyright (c) 2016.
% All rights reserved. Please read the 'license.txt' for license terms.
% 
% Developers: Zhen Zhang, Pakorn Kanchanawong
% Contact: biekp@nus.edu.sg
function varargout = LFT_OFT(varargin)
% LFT_OFT MATLAB code for LFT_OFT.fig
%      LFT_OFT, by itself, creates a new LFT_OFT or raises the existing
%      singleton*.
%
%      H = LFT_OFT returns the handle to a new LFT_OFT or the handle to
%      the existing singleton*.
%
%      LFT_OFT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LFT_OFT.M with the given input arguments.
%
%      LFT_OFT('Property','Value',...) creates a new LFT_OFT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LFT_OFT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LFT_OFT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LFT_OFT

% Last Modified by GUIDE v2.5 23-Nov-2015 10:55:02

    % Begin initialization code - DO NOT EDIT

    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @LFT_OFT_OpeningFcn, ...
                       'gui_OutputFcn',  @LFT_OFT_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);

    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    else
        fprintf('no arguments passed to LFT_OFT\n');
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end


% --- Executes just before LFT_OFT is made visible.
function LFT_OFT_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB\
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LFT_OFT (see VARARGIN)

    % Choose default command line output for LFT_OFT
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes LFT_OFT wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = LFT_OFT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end


function R_input_Callback(hObject, eventdata, handles)
% hObject    handle to R_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R_input as text
%        str2double(get(hObject,'String')) returns contents of R_input as a double
end

% --- Executes during object creation, after setting all properties.
function R_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in Preview_FT.
function Preview_FT_Callback(hObject, eventdata, handles)
% hObject    handle to Preview_FT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %handles
    %eventdata
    warning off;
    close(figure(1));

    % Determine the number of Angles and radius from the GUI controls

    R = str2num(get(handles.R_input,'String'));
    NofOrientations_FT = str2num(get(handles.NumberofAnglesInput,'String'));

    % loading the image data stashed away

    load(fullfile(tempdir,'data','OriginImg.mat'));
    I = OriginImg;
    [H W] = size(I);

    %
    % padding OriginImg by R pixels all around
    %
    %    +-R-+-----W-----+-R-+
    %    R                   R
    %    +   +-----------+   +
    %    |   |           |   |
    %    |   |           |   |
    %    H   | OriginImg |   H
    %    |   |           |   |
    %    |   |           |   |
    %    +   +-----------+   +
    %    R                   R
    %    +-R-+-----W-----+-R-+
    %  

    mask = uint8(zeros(H+R+R,W+R+R));
    mask(R+1:H+R,R+1:W+R) = I;
    ROI_Mask = ones(size(mask));
    save(fullfile(tempdir,'data','ROI_Mask.mat'),'ROI_Mask');
    save(fullfile(tempdir,'data','R.mat'),'R');
    save(fullfile(tempdir,'data','NofOrientations_FT.mat'),'NofOrientations_FT');
    [H W] = size(mask);
    AngleList = 0:pi/NofOrientations_FT:pi-pi/NofOrientations_FT;
    PtsSide1 = [(R*cos(AngleList)+round(W/2))'      (R*sin(AngleList)+round(H/2))'];
    PtsSide2 = [(R*cos(AngleList+pi)+round(W/2))'   (R*sin(AngleList+pi)+round(H/2))'];

    PtsAll = [PtsSide1;PtsSide2;PtsSide1(1,1) PtsSide1(1,2)];
    figure('name','Check Parameters before Filter Transform');

    % we store the handle of the image because, as one of the Matlab developers said,
    % 'They are called handles, because you are supposed to hold on to them'

    ImgH=imshow(mask);

    % For some reasons on Linux and Mac the subsequent plot calls are not directed to the figure
    % where 'mask' was displayed. Likely the mouse interaction with the LFT window's 'Preview'
    % button switches the graphic context.

    % Determining the graphic context from the ImgH graphic handle, assuming ImgH is an Image
    % type handle which is a direct child of an Axes type object, which in turn is a direct
    % child of the Figure object we need in order to switch context

    figure(get(get(ImgH,'Parent'),'Parent'));
    hold on;axis off;

    % Plotting the orientations dial

    plot(PtsAll(:,2),PtsAll(:,1),'color','r');
    for i = 1:length(AngleList)
        plot([PtsSide1(i,2) PtsSide2(i,2)],[PtsSide1(i,1) PtsSide2(i,1)],'color','r');
    end
end

function NumberofAnglesInput_Callback(hObject, eventdata, handles)
% hObject    handle to NumberofAnglesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberofAnglesInput as text
%        str2double(get(hObject,'String')) returns contents of NumberofAnglesInput as a double
end

% --- Executes during object creation, after setting all properties.
function NumberofAnglesInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberofAnglesInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in RunFTmexFunctionButton.
function RunFTmexFunctionButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunFTmexFunctionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(figure(1));

    load(fullfile(tempdir,'data','R.mat'),'R');
    load(fullfile(tempdir,'data','NofOrientations_FT.mat'),'NofOrientations_FT');
    load(fullfile(tempdir,'data','ROI_Mask'));

    load(fullfile(tempdir,'data','OriginImg.mat'));
    [H W] = size(OriginImg);

    %
    % padding OriginImg by R pixels all around
    %
    %    +-R-+-----W-----+-R-+
    %    R                   R
    %    +   +-----------+   +
    %    |   |           |   |
    %    |   |           |   |
    %    H   | OriginImg |   H
    %    |   |           |   |
    %    |   |           |   |
    %    +   +-----------+   +
    %    R                   R
    %    +-R-+-----W-----+-R-+
    %  

    OriginImg_Margin = uint8(zeros(H+R+R,W+R+R));
    OriginImg_Margin(R+1:H+R,R+1:W+R) = OriginImg;

    [OFT_Img, LFT_Img, LFT_Orientations] = LFT_OFT_mex(double(OriginImg_Margin),double(R),double(NofOrientations_FT),double(ROI_Mask));
    msgbox('Transformation Done !');
    save(fullfile(tempdir,'data','OFT_Img.mat'),'OFT_Img');
    save(fullfile(tempdir,'data','LFT_Img.mat'),'LFT_Img');
    save(fullfile(tempdir,'data','LFT_Orientations.mat'),'LFT_Orientations');
    figure('name','Check the Enhanced Image');
    imshow(mat2gray(OFT_Img));axis off;
end

% --- Executes on button press in NextStepDoSegmentButton.
function NextStepDoSegmentButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextStepDoSegmentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    R_input = str2num(get(handles.R_input,'String'));
    NumberofAnglesInput = str2num(get(handles.NumberofAnglesInput,'String'));

    mkdir(fullfile(gethome,'UserSettings'));
    % save','user settings
    fileID = fopen(fullfile(gethome,'UserSettings','FilterTransformSettings.txt'),'w');
    fprintf(fileID,['Radius for Transform (pixels):  ',num2str(R_input),'\r\n']);
    fprintf(fileID,['Number of Rotations:            ',num2str(NumberofAnglesInput),'\r\n']);

    % go to next user interface
    close all;
    SegmentB4Grouping;
end

% --- Executes on button press in BACKbtn.
function BACKbtn_Callback(hObject, eventdata, handles)
% hObject    handle to BACKbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close all;
    LoadImg;
end

% --- Executes on button press in ROIpolyBtn.
function ROIpolyBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ROIpolyBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    R = str2num(get(handles.R_input,'String'));
    NofOrientations_FT = str2num(get(handles.NumberofAnglesInput,'String'));
    save(fullfile(tempdir,'data','R.mat'),'R');
    save(fullfile(tempdir,'data','NofOrientations_FT.mat'),'NofOrientations_FT');
    load(fullfile(tempdir,'data','OriginImg'));
    close(figure(1));

    I = zeros(size(OriginImg,1)+2*R,size(OriginImg,2)+2*R,class(OriginImg));
    I(R+1:R+size(OriginImg,1),R+1:R+size(OriginImg,2)) = OriginImg;
    
    fprintf(1,"OriginImg: %d,%d (%s)\n",size(OriginImg,1),size(OriginImg,2),class(OriginImg));
    fprintf(1,"I: %d,%d (%s)\n",size(I,1),size(I,2),class(I));
    %max(I(:))
    %min(I(:))

    % See the Preview callback function for explanation

    current_figure=figure('name','Please Select the Region of Interest');
    ImgH=imshow(I);
    figure(get(get(ImgH,'Parent'),'Parent'));
    
    D = I(R+1:R+size(OriginImg,1),R+1:R+size(OriginImg,2)) - mat2gray(OriginImg);
    numel(find(D(:) > 0))

    ROI_Mask = roipoly;
    %ROI_Mask = ones(R+1:R+size(OriginImg,1),R+1:R+size(OriginImg,2));
    save(fullfile(tempdir,'data','ROI_Mask.mat'),'ROI_Mask');
    msgbox('ROI Selected !');
    close(figure(1));

end
