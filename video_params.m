function varargout = video_params(varargin)
% VIDEO_PARAMS MATLAB code for video_params.fig
%      VIDEO_PARAMS, by itself, creates a new VIDEO_PARAMS or raises the existing
%      singleton*.
%
%      H = VIDEO_PARAMS returns the handle to a new VIDEO_PARAMS or the handle to
%      the existing singleton*.
%
%      VIDEO_PARAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIDEO_PARAMS.M with the given input arguments.
%
%      VIDEO_PARAMS('Property','Value',...) creates a new VIDEO_PARAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before video_params_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to video_params_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help video_params

% Last Modified by GUIDE v2.5 10-Apr-2014 15:12:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @video_params_OpeningFcn, ...
                   'gui_OutputFcn',  @video_params_OutputFcn, ...
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


% --- Executes just before video_params is made visible.
function video_params_OpeningFcn(hObject, eventdata, handles, varargin)
xmar0=20;
xmar1=245;
xmar2=20;
ymar0=50;
ymar1=60;
ymar2=100;

moviefile=getappdata(0,'moviefile');
cbparams=getappdata(0,'cbparams');
visdata=getappdata(0,'visdata');
BG=getappdata(0,'BG');
roidata=getappdata(0,'roidata');

f=cbparams.track.firstframetrack;
trx=visdata.trx(:,f);
nflies=length(trx);
scr_size=get(0,'ScreenSize');
scrw=scr_size(3);
scrh=scr_size(4);
maxaxesw=scrw-2*xmar0-xmar1-xmar2;
maxaxesh=scrh-2*ymar0-ymar1-ymar2;
[readframe] = get_readframe_fcn(moviefile);
im=uint8(readframe(f));
[imh,imw]=size(im);

movie_params=cbparams.results_movie;
nzoomc=movie_params.nzoomc;
nzoomr=movie_params.nzoomr;
if ~isnumeric(nzoomr) || isempty(nzoomr) || ~isnumeric(nzoomc) || isempty(nzoomc),    
  if isnumeric(nzoomr) && ~isempty(nzoomr),
    nzoomc = round(nflies/nzoomr);
  elseif isnumeric(nzoomc) && ~isempty(nzoomc),
    nzoomr = round(nflies/nzoomc);
  else
    nzoomr = ceil(sqrt(nflies));
    nzoomc = round(nflies/nzoomr);
  end
end
nzoom=nzoomr*nzoomc;
figpos=movie_params.figpos;
if ~isnumeric(figpos) || isempty(figpos),  
    rowszoom = floor(imh/nzoomr);
    figpos = [1,1,imw+rowszoom*nzoomc,imh];
end
set_vidw=figpos(3);
set_vidh=figpos(4);
rowszoom=floor(imh/nzoomr);
vidw=imw+nzoomc*rowszoom;
vidh=imh;
axesw=set_vidw;
axesh=set_vidh;
if axesw>maxaxesw || axesh>maxaxesh
    rescw=maxaxesw/axesw;
    resch=maxaxesh/axesh;
    resc=min(rescw,resch);
else
    resc=1;
end
axesw=axesw*resc;
axesh=axesh*resc;
axesx=xmar1;
axesy=ymar1+(maxaxesh-axesh)/2;
guiw=axesw+xmar1+xmar2;
guih=maxaxesh+ymar1+ymar2;
guix=xmar0;
guiy=ymar0;

set(hObject,'Units','pixels','Position',[guix,guiy,guiw,guih])
handles.axes_vid=axes('Parent',hObject,'Units','pixels');
hold on
handles.vid_img=imagesc(im,'Parent',handles.axes_vid);
axis(handles.axes_vid,[0.5,vidw+0.5,0.5,vidh+0.5]);
colormap('gray')

debugdata.vis=8; debugdata.DEBUG=0; debugdata.track=0; debugdata.vid=1; 
[~,trx]=TrackWingsSingle_GUI(trx,BG.bgmed,roidata.inrois_all,cbparams.wingtrack,readframe(f),debugdata);
doplotwings = cbparams.track.dotrackwings && all(isfield(trx,{'xwingl','ywingl','xwingr','ywingr'}));
scalefactor = movie_params.scalefactor;
max_a=max([trx.a]);
max_b=max([trx.b]);
max_scalefactor = rowszoom/(4*sqrt(max_a^2+max_b^2)-1);
scalefactor=min(max_scalefactor,scalefactor);
boxradius = round(0.5*(rowszoom/scalefactor)-1);
zoomflies=1:nzoom;
colors=jet(nflies);
if nflies<nzoom
    zoomflies(nflies+1:end)=nan;    
end
zoomflies=reshape(zoomflies,[nzoomr,nzoomc]);
% corners of zoom boxes in plotted image coords
x0 = imw+(0:nzoomc-1)*rowszoom+1;
y0 = (0:nzoomr-1)*rowszoom+1;
x1 = x0 + rowszoom - 1;
y1 = y0 + rowszoom - 1;
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            handles.himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings,
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                handles.hzoomwing(i,j) = plot(xwing,ywing,'.-','color',colors(fly,:));
            end
            handles.hzoom(i,j) = drawflyo(x,y,theta,a,b);
            handles.htextzoom(i,j) = text((x0(j)+x1(j))/2,.80*y0(i)+.20*y1(i),s,...
                'color',colors(fly,:),'horizontalalignment','center',...
                'verticalalignment','bottom','fontweight','bold','Clipping','on');
            set(handles.hzoom(i,j),'color',colors(fly,:));
        else
            handles.himzoom(i,j)=nan;
            handles.hzoomwing(i,j)=nan;
            handles.hzoom(i,j)=nan;
            handles.htextzoom(i,j)=nan;
        end
    end
end
set(handles.axes_vid,'Xtick',[],'Ytick',[])
set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh],'Color',[204/255 204/255 204/255])
axis(handles.axes_vid,'equal');


% Plot unzoomed flies
for fly = 1:nflies,
  handles.htri(fly) = drawflyo(trx(fly),1);
  set(handles.htri(fly),'color',colors(fly,:));
  if doplotwings,
    xwing = [trx(fly).xwingl,trx(fly).x,trx(fly).xwingr];
    ywing = [trx(fly).ywingl,trx(fly).y,trx(fly).ywingr];
    handles.hwing(fly) = plot(xwing,ywing,'.-','color',colors(fly,:));
  end
end


% Create uiobjects
handles.text_resc=uicontrol('Style','text','Units','Pixels',...
    'Position',[xmar1,guih-ymar2,axesw,ymar2/2],'FontUnits','Pixels',...
    'FontSize',18,'HorizontalAlignment','center');
if resc<1
    resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc); 
else
    resc_s={''};
end  
set(handles.text_resc,'String',resc_s);

handles.panel_set=uipanel('Units','pixels','Title','Video Parameters',...
    'Position',[10,ymar1,xmar1-20,maxaxesh+6],'FontUnits','pixels','FontSize',12);
handles.panel_end=uipanel('Units','pixels','Position',[(guiw-250)/2,10,250,40],...
    'FontUnits','pixels','FontSize',14);

uiend_name={'pushbutton_cancel';'pushbutton_accept'};
uiend_style={'pushbutton';'pushbutton'};
uiend_string={'Cancel';'Accept'};
uiend_x=[21;140];
uiend_y=[4;3];
uiend_w=[90;90];
uiend_h=[34;34];
uiend_pos=[uiend_x uiend_y uiend_w uiend_h];
uiend_alignment={'center','center'};
uiend_enable={'on';'on'};
uiend_callback={@pushbutton_cancel_Callback;@pushbutton_accept_Callback;};
for i=1:numel(uiend_name)
    handles.(uiend_name{i})=uicontrol('Parent',handles.panel_end,...
        'Style',uiend_style{i},'Units','pixels','String',uiend_string{i},...
        'HorizontalAlignment',uiend_alignment{i},'Position',uiend_pos(i,:),...
        'FontUnits','pixels','FontSize',14,'Enable',uiend_enable{i},...
        'Callback',uiend_callback{i});
end

uiset_name={'checkbox_dovideo';'text_FPS';'edit_FPS';'text_nzoom';'text_nr';...
    'edit_nr';'text_nc';'edit_nc';'text_zoom';'slider_zoom';'edit_zoom';...
    'text_tailL';'edit_tailL';'text_nframes';'text_nframesI';...
    'edit_nframesI';'text_nframesM';'edit_nframesM';'text_nframesF';...
    'edit_nframesF';'text_size';'text_vidw';'edit_vidw';'text_vidh';'edit_vidh'};
uiset_style={'checkbox';'text';'edit';'text';'text';'edit';'text';'edit';...
    'text';'slider';'edit';'text';'edit';'text';'text';'edit';'text';...
    'edit';'text';'edit';'text';'text';'edit';'text';'edit'};
uiset_string={'Make resutls video';'Frames per second';num2str(movie_params.fps);...
    'Number of zoomed flies';'Rows';num2str(nzoomr);...
    'Columns';num2str(nzoomc);'Zoom';'';num2str(scalefactor,'%.2f');...
    'Tail lenght';num2str(movie_params.taillength);...
    'Number of frames';'Initial';num2str(movie_params.nframes(1));...
    'Middle';num2str(movie_params.nframes(2));'End';num2str(movie_params.nframes(3));...
    'Video size';'Width';num2str(set_vidw);'Height';num2str(set_vidh)};
uiset_value={movie_params.dovideo;[];[];[];[];[];[];[];[];scalefactor;[];[];...
    [];[];[];[];[];[];[];[];[];[];[];[];[]};
uiset_x=[15;25;175;25;30;55;130;155;25;25;175;25;175;25;30;30;95;95;160;160;25;30;55;130;155];
uiset_y=[guih-ymar2-35;guih-ymar2-70;guih-ymar2-65;guih-ymar2-110;...
    guih-ymar2-130;guih-ymar2-150;guih-ymar2-130;guih-ymar2-150;...
    guih-ymar2-195;guih-ymar2-220;guih-ymar2-190;guih-ymar2-260;...
    guih-ymar2-255;guih-ymar2-295;guih-ymar2-315;guih-ymar2-335;...
    guih-ymar2-315;guih-ymar2-335;guih-ymar2-315;guih-ymar2-335;...
    guih-ymar2-380;guih-ymar2-400;guih-ymar2-420;guih-ymar2-400;...
    guih-ymar2-420];
if uiset_y(1)-uiset_y(end)>maxaxesh-50
    uiset_y_new=uiset_y*(axesh-50)/(uiset_y(1)-uiset_y(end)); uiset_y=uiset_y_new+uiset_y(1)-uiset_y_new(1);
end
uiset_w=[175;150;50;175;100;50;100;50;100;200;50;100;50;150;50;50;50;50;50;50;150;100;50;100;50];
uiset_h=[25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25;25];
uiset_pos=[uiset_x uiset_y uiset_w uiset_h];
uiset_alignment={'left','left','center','left','center','center','center',...
    'center','left','center','center','left','center','left',...
    'center','center','center','center','center','center','left','center',...
    'center','center','center'};
uiset_fs=repmat(14,[numel(uiset_name),1]); uiset_fs(1)=16;
uiset_BG=repmat([0.929 0.929 0.929],[numel(uiset_name),1]); uiset_BG(strcmp(uiset_style,'edit'),:)=1;
if movie_params.dovideo
    uiset_enable={'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';...
        'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';'on';...
        'on'};
else
    uiset_enable={'on';'off';'off';'off';'off';'off';'off';'off';'off';'off';...
        'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';'off';...
        'off';'off';'off';'off'};
end
uiset_callback={@checkbox_dovideo_Callback;@text_FPS_Callback;...
    @edit_FPS_Callback;@text_zoom_Callback;@text_nr_Callback;...
    @edit_nr_Callback;@text_nc_Callback;@edit_nc_Callback;...
    @text_zoom_Callback;@slider_zoom_Callback;@edit_zoom_Callback;...
    @text_tailL_Callback;@edit_tailL_Callback;@text_nframes_Callback;...
    @text_nframesI_Callback;@edit_nframesI_Callback;...
    @text_nframesM_Callback;@edit_nframesM_Callback;...
    @text_nframesF_Callback;@edit_nframesF_Callback;...
    @text_size_Callback;@text_vidw_Callback;@edit_vidw_Callback;...
    @text_vidh_Callback;@edit_vidh_Callback};
for i=1:numel(uiset_style)
    handles.(uiset_name{i})=uicontrol('Style',uiset_style{i},'Units','pixels',...
    'String',uiset_string{i},'Value',uiset_value{i},...
    'HorizontalAlignment',uiset_alignment{i},'Position',uiset_pos(i,:),...
    'FontUnits','pixels','FontSize',uiset_fs(i),'Enable',uiset_enable{i},...
    'BackgroundColor',uiset_BG(i,:),'Callback',uiset_callback{i});
end

 % Set sliders
set(handles.slider_zoom,'Min',1e-6,'Max',max_scalefactor)
fcn_slider_zoom= get(handles.slider_zoom,'Callback');
hlisten_frame=addlistener(handles.slider_zoom,'ContinuousValueChange',fcn_slider_zoom); %#ok<NASGU>



handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

movie_params.scalefactor=scalefactor;
movie_params.nzoomr=nzoomr;
movie_params.nzoomc=nzoomc;
movie_params.figpos=figpos;
vid.maxaxesw=maxaxesw;
vid.maxaxesh=maxaxesh;
vid.trx=trx;
vid.zoomflies=zoomflies;
vid.rowszoom=rowszoom;
vid.boxradius=boxradius;
vid.colors=colors;
vid.im=im;
vid.mar=[xmar0,ymar0;xmar1,ymar1;xmar2,ymar2];
vid.x0=x0;
vid.y0=y0;
vid.doplotwings=doplotwings;
set(handles.panel_set,'UserData',movie_params);
set(handles.axes_vid,'UserData',vid);

function varargout = video_params_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


function figure1_CreateFcn(hObject, eventdata, handles)


function slider_zoom_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

scalefactor=get(handles.slider_zoom,'Value');
set(handles.edit_zoom,'String',num2str(scalefactor,'%.2f'))
nzoomc=movie_params.nzoomc;
nzoomr=movie_params.nzoomr;
rowszoom=vid.rowszoom;
boxradius = round(0.5*(rowszoom/scalefactor)-1);
trx=vid.trx;
zoomflies=vid.zoomflies;
colors=vid.colors;
im=vid.im;
x0=vid.x0;
y0=vid.y0;
doplotwings=vid.doplotwings;

hvis=get(get(handles.axes_vid,'Parent'),'HandleVisibility');
set(get(handles.axes_vid,'Parent'),'HandleVisibility','on')
hold on
% corners of zoom boxes in plotted image coords
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            set(handles.himzoom(i,j),'cdata',repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings 
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                set(handles.hzoomwing(i,j),'XData',xwing,'YData',ywing,'Color',colors(fly,:));
            end
            updatefly(handles.hzoom(i,j),x,y,theta,a,b);
            set(handles.htextzoom(i,j),'string',s,'color',colors(fly,:));
        else
            handles.himzoom(i,j)=nan;
            handles.hzoomwing(i,j)=nan;
            handles.hzoom(i,j)=nan;
            handles.htextzoom(i,j)=nan;
        end
    end
end
set(get(handles.axes_vid,'Parent'),'HandleVisibility',hvis)

set(handles.panel_set,'UserData',movie_params);

function edit_zoom_Callback(hObject, eventdata)
handles=guidata(hObject);
scalefactor=str2double(get(hObject,'String'));
set(handles.slider_zoom,'Value',scalefactor);
slider_zoom_Callback(handles.slider_zoom, eventdata);


function edit_nc_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

im=vid.im;
[imh,imw]=size(im);

nzoomc=round(str2double(get(hObject,'String')));
set(hObject,'String',num2str(nzoomc,'%i'))
nzoomr=movie_params.nzoomr;
nzoom=nzoomr*nzoomc;
rowszoom=vid.rowszoom;
vidw=imw+nzoomc*rowszoom;
vidh=imh;

axis(handles.axes_vid,[0.5,vidw+0.5,0.5,vidh+0.5]);

trx=vid.trx;
doplotwings = vid.doplotwings;
scalefactor = movie_params.scalefactor;
nflies=length(trx);
zoomflies=1:nzoom;
colors=jet(nflies);
if nflies<nzoom
    zoomflies(nflies+1:end)=nan;    
end
zoomflies=reshape(zoomflies,[nzoomr,nzoomc]);
delete(handles.himzoom(ishandle(handles.himzoom)))
handles.himzoom=[];
delete(handles.htextzoom(ishandle(handles.htextzoom)))
handles.htextzoom=[];
delete(handles.hzoomwing(ishandle(handles.hzoomwing)));
handles.hzoomwing=[];
delete(handles.hzoom(ishandle(handles.hzoom)));
handles.hzoom=[];
hold on

% corners of zoom boxes in plotted image coords
boxradius=vid.boxradius;
rowszoom=vid.rowszoom;
x0 = imw+(0:nzoomc-1)*rowszoom+1;
y0 = (0:nzoomr-1)*rowszoom+1;
x1 = x0 + rowszoom - 1;
y1 = y0 + rowszoom - 1;
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            handles.himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings,
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                handles.hzoomwing(i,j) = plot(xwing,ywing,'.-','color',colors(fly,:));
            end
            handles.hzoom(i,j) = drawflyo(x,y,theta,a,b);
            handles.htextzoom(i,j) = text((x0(j)+x1(j))/2,.80*y0(i)+.20*y1(i),s,...
                'color',colors(fly,:),'horizontalalignment','center',...
                'verticalalignment','bottom','fontweight','bold');
            set(handles.hzoom(i,j),'color',colors(fly,:));
        else
            handles.himzoom(i,j)=nan;
            handles.hzoomwing(i,j)=nan;
            handles.hzoom(i,j)=nan;
            handles.htextzoom(i,j)=nan;
        end
    end
end
axis(handles.axes_vid,'equal');

guidata(hObject, handles);

movie_params.nzoomc=nzoomc;
vid.zoomflies=zoomflies;
vid.colors=colors;
vid.vidpos=[1,1,vidw,vidh];
vid.x0=x0;
vid.y0=y0;
set(handles.panel_set,'UserData',movie_params);
set(handles.axes_vid,'UserData',vid);



function edit_nr_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

im=vid.im;
[imh,imw]=size(im);

nzoomr=round(str2double(get(hObject,'String')));
set(hObject,'String',num2str(nzoomr,'%i'))
nzoomc=movie_params.nzoomc;
nzoom=nzoomr*nzoomc;
rowszoom=floor(imh/nzoomr);
vidw=imw+nzoomc*rowszoom;
vidh=imh;

axis(handles.axes_vid,[0.5,vidw+0.5,0.5,vidh+0.5]);

trx=vid.trx;
doplotwings = vid.doplotwings;
scalefactor = movie_params.scalefactor;
max_a=max([trx.a]);
max_b=max([trx.b]);
max_scalefactor = rowszoom/(4*sqrt(max_a^2+max_b^2)-1);
scalefactor=min(max_scalefactor,scalefactor);
boxradius = round(0.5*(rowszoom/scalefactor)-1);
nflies=length(trx);
zoomflies=1:nzoom;
colors=jet(nflies);
if nflies<nzoom
    zoomflies(nflies+1:end)=nan;    
end
zoomflies=reshape(zoomflies,[nzoomr,nzoomc]);
delete(handles.himzoom(ishandle(handles.himzoom)))
handles.himzoom=[];
delete(handles.htextzoom(ishandle(handles.htextzoom)))
handles.htextzoom=[];
delete(handles.hzoomwing(ishandle(handles.hzoomwing)));
handles.hzoomwing=[];
delete(handles.hzoom(ishandle(handles.hzoom)));
handles.hzoom=[];
hold on

% corners of zoom boxes in plotted image coords
x0 = imw+(0:nzoomc-1)*rowszoom+1;
y0 = (0:nzoomr-1)*rowszoom+1;
x1 = x0 + rowszoom - 1;
y1 = y0 + rowszoom - 1;
for i = 1:nzoomr,
    for j = 1:nzoomc,
        fly = zoomflies(i,j);        
        if ~isnan(fly),
            x = trx(fly).x;
            y = trx(fly).y;
            x_r = round(x);
            y_r = round(y);
            boxradx1 = min(boxradius,x_r-1);
            boxradx2 = min(boxradius,size(im,2)-x_r);
            boxrady1 = min(boxradius,y_r-1);
            boxrady2 = min(boxradius,size(im,1)-y_r);
            box = uint8(zeros(2*boxradius+1));
            box(boxradius+1-boxrady1:boxradius+1+boxrady2,...
                boxradius+1-boxradx1:boxradius+1+boxradx2) = ...
                im(y_r-boxrady1:y_r+boxrady2,x_r-boxradx1:x_r+boxradx2);
            handles.himzoom(i,j) = image([x0(j),x1(j)],[y0(i),y1(i)],repmat(box,[1,1,3]));
        
            % plot the zoomed views
            x = boxradius + (x - x_r)+.5;
            y = boxradius + (y - y_r)+.5;
            x = x * scalefactor;
            y = y * scalefactor;
            x = x + x0(j) - 1;
            y = y + y0(i) - 1;
            a = trx(fly).a*scalefactor;
            b = trx(fly).b*scalefactor;
            theta = trx(fly).theta;
            s = sprintf('%d',fly);
            if doplotwings,
                xwingl = trx(fly).xwingl - round(trx(fly).x) + boxradius + .5;
                ywingl = trx(fly).ywingl - round(trx(fly).y) + boxradius + .5;
                xwingl = xwingl * scalefactor;
                ywingl = ywingl * scalefactor;
                xwingl = xwingl + x0(j) - 1;
                ywingl = ywingl + y0(i) - 1;
                xwingr = trx(fly).xwingr - round(trx(fly).x) + boxradius + .5;
                ywingr = trx(fly).ywingr - round(trx(fly).y) + boxradius + .5;
                xwingr = xwingr * scalefactor;
                ywingr = ywingr * scalefactor;
                xwingr = xwingr + x0(j) - 1;
                ywingr = ywingr + y0(i) - 1;
                xwing = [xwingl,x,xwingr];
                ywing = [ywingl,y,ywingr];
                handles.hzoomwing(i,j) = plot(xwing,ywing,'.-','color',colors(fly,:));
            end
            handles.hzoom(i,j) = drawflyo(x,y,theta,a,b);
            handles.htextzoom(i,j) = text((x0(j)+x1(j))/2,.80*y0(i)+.20*y1(i),s,...
                'color',colors(fly,:),'horizontalalignment','center',...
                'verticalalignment','bottom','fontweight','bold');
            set(handles.hzoom(i,j),'color',colors(fly,:));
        else
            handles.himzoom(i,j)=nan;
            handles.hzoomwing(i,j)=nan;
            handles.hzoom(i,j)=nan;
            handles.htextzoom(i,j)=nan;
        end        
    end
end
axis(handles.axes_vid,'equal');

set(handles.slider_zoom,'Max',max_scalefactor,'Value',scalefactor)
set(handles.edit_zoom,'String',num2str(scalefactor,'%.2f'))

guidata(hObject, handles);

movie_params.scalefactor=scalefactor;
movie_params.nzoomr=nzoomr;
vid.zoomflies=zoomflies;
vid.rowszoom=rowszoom;
vid.boxradius=boxradius;
vid.colors=colors;
vid.vidpos=[1,1,vidw,vidh];
vid.x0=x0;
vid.y0=y0;
set(handles.panel_set,'UserData',movie_params);
set(handles.axes_vid,'UserData',vid);

function edit_vidw_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

xmar1=vid.mar(2,1);
xmar2=vid.mar(3,1);
ymar1=vid.mar(2,2);
ymar2=vid.mar(3,2);

set_vidw=str2double(get(hObject,'String'));
set_vidh=movie_params.figpos(4);
maxaxesw=vid.maxaxesw;
maxaxesh=vid.maxaxesh;
axesw=set_vidw;
axesh=set_vidh;
if axesw>maxaxesw || axesh>maxaxesh
    rescw=maxaxesw/axesw;
    resch=maxaxesh/axesh;
    resc=min(rescw,resch);
else
    resc=1;
end
axesw=axesw*resc;
axesh=axesh*resc;
axesx=xmar1;
axesy=ymar1+(maxaxesh-axesh)/2;
guiw=axesw+xmar1+xmar2;
guih=maxaxesh+ymar1+ymar2;
old_guipos=get(handles.figure1,'Position');
guix=old_guipos(1);
guiy=old_guipos(2);

set(handles.figure1,'Position',[guix,guiy,guiw,guih]);
set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh]);
axis(handles.axes_vid,'equal');
set(hObject,'String',num2str(set_vidw,'%i'))
if resc<1
    resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc); 
else
    resc_s={''};
end  
set(handles.text_resc,'String',resc_s);



function edit_vidh_Callback(hObject, eventdata)
handles=guidata(hObject);
movie_params=get(handles.panel_set,'UserData');
vid=get(handles.axes_vid,'UserData');

xmar1=vid.mar(2,1);
xmar2=vid.mar(3,1);
ymar1=vid.mar(2,2);
ymar2=vid.mar(3,2);

set_vidw=movie_params.figpos(3);
set_vidh=str2double(get(hObject,'String'));
maxaxesw=vid.maxaxesw;
maxaxesh=vid.maxaxesh;
axesw=set_vidw;
axesh=set_vidh;
if axesw>maxaxesw || axesh>maxaxesh
    rescw=maxaxesw/axesw;
    resch=maxaxesh/axesh;
    resc=min(rescw,resch);
else
    resc=1;
end
axesw=axesw*resc;
axesh=axesh*resc;
axesx=xmar1;
axesy=ymar1+(maxaxesh-axesh)/2;
guiw=axesw+xmar1+xmar2;
guih=maxaxesh+ymar1+ymar2;
old_guipos=get(handles.figure1,'Position');
guix=old_guipos(1);
guiy=old_guipos(2);

set(handles.figure1,'Position',[guix,guiy,guiw,guih]);
set(handles.axes_vid,'Position',[axesx,axesy,axesw,axesh]);
axis(handles.axes_vid,'equal');
set(hObject,'String',num2str(set_vidh,'%i'))
if resc<1
    resc_s=textwrap({['The final video will be ',num2str(1/resc,'%.2f'),' times bigger']},handles.text_resc); 
else
    resc_s={''};
end  
set(handles.text_resc,'String',resc_s);



function checkbox_dovideo_Callback(hObject, eventdata)
handles=guidata(hObject);
uiset_name={'checkbox_dovideo';'text_FPS';'edit_FPS';'text_nzoom';'text_nr';...
    'edit_nr';'text_nc';'edit_nc';'text_zoom';'slider_zoom';'edit_zoom';...
    'text_tailL';'edit_tailL';'text_nframes';'text_nframesI';...
    'edit_nframesI';'text_nframesM';'edit_nframesM';'text_nframesF';...
    'edit_nframesF'};
if get(hObject,'Value')
    for i=2:numel(uiset_name)
        set(handles.(uiset_name{i}),'Enable','on')
    end
else
    for i=2:numel(uiset_name)
        set(handles.(uiset_name{i}),'Enable','off')
    end
end
        
function pushbutton_cancel_Callback(hObject, eventdata)
handles=guidata(hObject);
delete(handles.figure1)

function pushbutton_accept_Callback(hObject, eventdata)
handles=guidata(hObject);
cbparams=getappdata(0,'cbparams');
movie_params=get(handles.panel_set,'UserData');

movie_params.dovideo=get(handles.checkbox_dovideo,'Value');
movie_params.fps=str2double(get(handles.edit_FPS,'String'));
movie_params.taillength=str2double(get(handles.edit_tailL,'String'));
movie_params.nframes=[str2double(get(handles.edit_nframesI,'String')),str2double(get(handles.edit_nframesM,'String')),str2double(get(handles.edit_nframesF,'String'))];
movie_params.figpos=[1,1,str2double(get(handles.edit_vidw,'String')),str2double(get(handles.edit_vidh,'String'))];

cbparams.results_movie=movie_params;
setappdata(0,'cbparams',cbparams);

delete(handles.figure1)


function edit_FPS_Callback(hObject, eventdata)


function edit_tailL_Callback(hObject, eventdata)


function edit_nframesI_Callback(hObject, eventdata)


function edit_nframesM_Callback(hObject, eventdata)


function edit_nframesF_Callback(hObject, eventdata)
