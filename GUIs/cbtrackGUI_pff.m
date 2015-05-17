function varargout = cbtrackGUI_pff(varargin)
    % CBTRACKGUI_PFF MATLAB code for cbtrackGUI_pff.fig
    %      CBTRACKGUI_PFF, by itself, creates a new CBTRACKGUI_PFF or raises the existing
    %      singleton*.
    %
    %      H = CBTRACKGUI_PFF returns the handle to a new CBTRACKGUI_PFF or the handle to
    %      the existing singleton*.
    %
    %      CBTRACKGUI_PFF('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in CBTRACKGUI_PFF.M with the given input arguments.
    %
    %      CBTRACKGUI_PFF('Property','Value',...) creates a new CBTRACKGUI_PFF or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before cbtrackGUI_pff_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to cbtrackGUI_pff_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help cbtrackGUI_pff

    % Last Modified by GUIDE v2.5 17-Dec-2014 18:41:00

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @cbtrackGUI_pff_OpeningFcn, ...
                       'gui_OutputFcn',  @cbtrackGUI_pff_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT


function cbtrackGUI_pff_OpeningFcn(hObject, eventdata, handles, varargin)
    params = varargin{1};    
    cbparams = getappdata(0,'cbparams');

    perframefns = params.perframefns;

    %  Fcns tree
    pfffncx_temp(perframefns,cbparams.track.dotrack,cbparams.track.dotrackwings,handles)

    % Other parameters
    uiset_name = {'checkbox_dopff';'text_fov';'edit_fov';...
        'text_max_dnose2ell_anglerange';'edit_max_dnose2ell_anglerange';...
        'text_nbodylengths_near';'edit_nbodylengths_near'};
    uiset_style = {'checkbox';'text';'edit';'text';'edit';'text';'edit'};
    uiset_string = {'Compute perframe features';'Field of view';num2str(params.fov);...
        'max_dnose2ell_anglerange';num2str(params.max_dnose2ell_anglerange);...
        'nbodylengths_near';num2str(params.nbodylengths_near)};
    uiset_value = {params.dopff;[];[];[];[];[];[]};
    uiset_x = [320;330;540;330;540;330;540];
    uiset_y = [535;490;495;455;460;415;420];
    uiset_w = [175;175;50;180;50;175;50];
    uiset_h = [25;25;25;25;25;25;25];
    uiset_pos = [uiset_x uiset_y uiset_w uiset_h];
    uiset_alignment = {'left','left','center','left','center','left','center'};
    uiset_fs = repmat(14,[numel(uiset_name),1]); uiset_fs(1)=16;
    uiset_BG = repmat([0.929 0.929 0.929],[numel(uiset_name),1]); uiset_BG(strcmp(uiset_style,'edit'),:)=1;
    uiset_callback = {@checkbox_dopff_Callback;@text_fov;@edit_fov;...
        @text_max_dnose2ell_anglerange;@edit_max_dnose2ell_anglerange;...
        @text_nbodylengths_near;@edit_nbodylengths_near};
    for i=1:numel(uiset_style)
        handles.(uiset_name{i}) = uicontrol('Style',uiset_style{i},'Units','pixels',...
        'String',uiset_string{i},'Value',uiset_value{i},...
        'HorizontalAlignment',uiset_alignment{i},'Position',uiset_pos(i,:),...
        'FontUnits','pixels','FontName','Arial','FontSize',uiset_fs(i),...
        'BackgroundColor',uiset_BG(i,:),'Callback',uiset_callback{i});
    end
    if ~cbparams.track.dotrack
        set(handles.checkbox_dopff,'Value',false,'Enable','off')
        params.dopff = 0;
    end

    % Accep and cancel buttons
    handles.panel_end = uipanel('Units','pixels','Position',[175,10,250,40],...
        'FontUnits','pixels','FontSize',14);
    handles.pushbutton_cancel = uicontrol('Parent',handles.panel_end,...
            'Style','pushbutton','Units','pixels','String','Cancel',...
            'HorizontalAlignment','center','Position',[21 3 90 34],...
            'FontUnits','pixels','FontName','Arial','FontSize',14,...
            'Callback',@pushbutton_cancel_Callback);
    handles.pushbutton_accept = uicontrol('Parent',handles.panel_end,...
            'Style','pushbutton','Units','pixels','String','Accept',...
            'HorizontalAlignment','center','Position',[140 3 90 34],...
            'FontUnits','pixels','FontName','Arial','FontSize',14,...
            'Callback',@pushbutton_accept_Callback);

    handles.output = hObject;

    % Update handles structure
    set(handles.pushbutton_accept,'UserData',params)
    guidata(hObject, handles);

    uiwait(handles.figure1)
end


function varargout = cbtrackGUI_pff_OutputFcn(hObject, eventdata, handles)
    varargout{1} = get(handles.pushbutton_accept,'UserData');
    delete(hObject)
end


function pfffncx_temp(fns,doT,doTW,handles)    
pff_defs

icons={'unchecked.gif','checked.gif','semichecked.gif'};
jicon = cell(numel(icons),1);
for i = 1:numel(icons)
    [im,map] = imread(icons{i});
    jicon{i} = im2java(im,map);
end

% Root node
if all(pff_on)
    all_on = 2; %all selected
elseif ~any(pff_on)
    all_on = 1; %none selected
else
    all_on = 3; %some selected
end
root = uitreenode('v0', 'all', 'Perframe functions', fullfile(pwd,icons{all_on}), false);
pff_all.all = struct('tree',root,'names',{pff_type_names},'field_names',{pff_field_names},'pff_names',{pff_names},'is_on',pff_on,'all_on',all_on);

% other nodes
for t=1:numel(pff_type_names)
    idx=find(cellfun(@(x) any(x==t), pff_type));
    names = pff_names(idx);
    descr = pff_description(idx);
    is_on = pff_on(idx);

    if all(is_on)
        all_on = 2; %all selected
    elseif ~any(is_on)
        all_on = 1; %none selected
    else
        all_on = 3; %some selected
    end
    tree = uitreenode('v0', pff_field_names{t}, pff_type_names{t}, fullfile(pwd,icons{all_on}), false);

    for i=1:numel(idx)
        tree.add(uitreenode('v0',names{i},names{i},fullfile(pwd,icons{is_on(i)+1}), true));
    end
    pff_all.(pff_field_names{t}) = struct('tree',tree,'names',{names},'description',{descr},'is_on',is_on,'idx',idx,'all_on',all_on);
    root.add(tree);
end
set(handles.figure1,'UserData',pff_all)

% Tree
mtree = uitree('v0', 'Root', root);
mtree.Position=[10 60 300 500];
mtree.expand(root)
jtree = handle(mtree.getTree,'CallbackProperties');
set(jtree, 'MousePressedCallback', {@mousePressedCallback},'mouseMovedCallback', {@mouseMovedCallback,mtree});

    function mousePressedCallback(hTree, eventData) %,additionalVar)
        % if eventData.isMetaDown % right-click is like a Meta-button
        % if eventData.getClickCount==2 % how to detect double clicks

        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        treePath = hTree.getPathForLocation(clickX, clickY);
        % check if a node was clicked
        if ~isempty(treePath)
          % check if the checkbox was clicked
          if clickX <= (hTree.getPathBounds(treePath).x+16)
            node = treePath.getLastPathComponent;
            level = node.getLevel;
            for j=1:numel(pff_type_names)
                parentValue = pff_field_names{j};
                parentNode = pff_all.(parentValue).tree;
                namesCurr = pff_all.(parentValue).names;
                switch level
                    case 0 % if "all" is clicked, and some are cecked it hbehaves as if all where checked
                        nodeValue = pff_all.(parentValue).names;
                        if pff_all.all.all_on == 3 
                            pff_all.(parentValue).is_on(:) = true;
                        end
                    case 1
                        nodeValue = pff_all.(node.getValue).names;
                        if pff_all.(node.getValue).all_on == 3 
                            pff_all.(node.getValue).is_on(:) = true;
                        end
                    case 2
                        nodeValue = node.getValue;
                end

                [~,selected_all]= intersect(namesCurr,nodeValue);
                if isempty(selected_all)
                    continue
                end
                for k = 1:numel(selected_all)
                    selected = selected_all(k);
                    % Change clicked icon and is_on value
                    nodeCurr = parentNode.getChildAt(selected-1);
                    idCurr = pff_all.(parentValue).idx(selected);
                    is_onCurr = pff_all.(parentValue).is_on;
                    is_onCurr(selected) = ~is_onCurr(selected);
                    nodeCurr.setIcon(jicon{is_onCurr(selected)+1});

                    % Change icons from parent node
                    if all(is_onCurr)
                        all_onCurr = 2; %all selected
                    elseif ~any(is_onCurr)
                        all_onCurr = 1; %none selected
                    else
                        all_onCurr = 3; %some selected
                    end
                    parentNode.setIcon(jicon{all_onCurr});

                    % Save changes in pff_all
                    pff_all.(parentValue).tree = parentNode;
                    pff_all.(parentValue).is_on = is_onCurr;
                    pff_all.(parentValue).all_on = all_onCurr;

                    % Update pff_all.all.ison
                    pff_all.all.is_on(idCurr) = is_onCurr(selected);
                end
            end
            % Change icons from main node and
            if all(pff_all.all.is_on)
                all_onCurr = 2; %all selected
            elseif ~any(pff_all.all.is_on)
                all_onCurr = 1; %none selected
            else
                all_onCurr = 3; %some selected
            end
            pff_all.all.all_on = all_onCurr;
            parentTree = parentNode.getParent;
            parentTree.setIcon(jicon{all_onCurr});
            mtree.reloadNode(parentNode)
            % as the value field is the selected/unselected flag,
            % we can also use it to only act on nodes with these values
          end
        end
        set(handles.figure1,'UserData',pff_all)
    end

    function mouseMovedCallback(jTree,eventData,hTree)
        % Get the hover poistion
        hoverX = eventData.getX;
        hoverY = eventData.getY;
        treePath = jTree.getPathForLocation(hoverX, hoverY);
        % check if a node was clicked
        if ~isempty(treePath)
            node = treePath.getLastPathComponent;
            level = node.getLevel;
            if level ==2
                parentNode = node.getParent;
                pffCurr = pff_all.(parentNode.getValue);
                selected = strcmp(node.getName,pffCurr.names);
                tool_str = pff_description{pffCurr.idx(selected)};
                tool_str = textwrap(tool_str,100);
                tool_str = sprintf('%s<br />',tool_str{:});
                tool_str = ['<html>',tool_str(1:end-6),'</html>'];
            else
                tool_str = '';                
            end
            jTree.setToolTipText(tool_str)
        end
    end

    function pff_defs
        pff_names={'a_mm';'absanglefrom1to2_nose2ell';'absdtheta';'absdv_cor';...
            'absphidiff_anglesub';'absphidiff_nose2ell';'absthetadiff_anglesub';...
            'absthetadiff_nose2ell';'angle_biggest_wing';'angle_smallest_wing';...
            'angle2wall';'anglefrom1to2_anglesub';'anglefrom1to2_nose2ell';...
            'angleonclosestfly';'anglesub';'area';'area_inmost_wing';...
            'area_outmost_wing';'arena_angle';'arena_r';'b_mm';...
            'closestfly_anglesub';'closestfly_center';'closestfly_ell2nose';...
            'closestfly_nose2ell';'corfrac_maj';'corfrac_min';'da';...
            'dangle_biggest_wing';'dangle_smallest_wing';'dangle2wall';...
            'danglesub';'darea';'darea_inmost_wing';'darea_outmost_wing';...
            'db';'dcenter';'ddcenter';'ddist2wall';'decc';'dell2nose';...
            'dist2wall';'dmax_wing_angle';'dmax_wing_area';'dmin_wing_angle';...
            'dmin_wing_area';'dnose2ell';'dnose2ell_angle_30tomin30';...
            'dnose2ell_angle_min20to20';'dnose2ell_angle_min30to30';...
            'dnose2tail';'dnwingsdetected';'dphi';'dtheta';'du_cor';'du_ctr';...
            'du_tail';'dv_cor';'dv_ctr';'dv_tail';'dwing_angle_diff';...
            'dwing_angle_imbalance';'ecc';'flipdv_cor';'magveldiff_anglesub';...
            'magveldiff_nose2ell';'max_absdwing_angle';'max_absdwing_area';...
            'max_dwing_angle_in';'max_dwing_angle_out';'max_wing_angle';...
            'max_wing_area';'mean_wing_angle';'mean_wing_area';...
            'min_absdwing_angle';'min_absdwing_area';'min_dwing_angle_in';...
            'min_dwing_angle_out';'min_wing_angle';'min_wing_area';...
            'nflies_close';'nwingsdetected';'phi';'phisideways';'velmag';...
            'velmag_ctr';'velmag_nose';'velmag_tail';'veltoward_anglesub';...
            'veltoward_nose2ell';'wing_angle_diff';'wing_angle_imbalance';'yaw'};

        pff_description={{'Quarter major axis length (mm).This feature was not used for mice.';'Transformation: none, abs.'};...
            {'Absolute difference between direction to closest animal based on dnose2ell and current animal''s orientation (rad).';'Transformations: none.'};...
            {'Angular speed (rad/s) |dtheta|.';'Transformations: relative.'};...
            {'Sideways speed of the animal''s center of rotation (defined by corfrac_maj and corfrac_min) (mm/s).';'Transformations: relative.'};...
            {'Absolute difference in velocity direction between current animal and closest animal based on anglesub (rad).';'Transformations: none.'};...
            {'Absolute difference in velocity direction between current animal and closest animal based on dnose2ell (rad).';'Transformations: none.'};...
            {'Absolute difference in orientation between current animal and closest animal based on anglesub (rad).';'Transformations: none.'};...
            {'Absolute difference in orientation between this animal and closest animal based on dnose2ell (rad).';'Transformations: none.'};...
            {'Angle of the bigger wing. The bigger wing is decided based on the detected area of the wings.';'Transformations: none.'};...
            {'Angle of the smaller wing. The smaller wing is decided based on the detected area of the wings.';'Transformations: none.'};...
            {'Angle to closest point on the arena wall from animal''s center, relative to the animal''s orientation (rad).';'Transformations: flip,abs.'};...
            {'Angle to closest (based on angle subtended) animal''s centroid in current animal''s coordinate system. Metric that encodes the position of the closest animal relative to the current animal.';'Transformations: flip, abs.'};...
            {'Angle to closest (based on distance from nose to ellipse) animal''s centroid in current animal''s coordinate system. Metric that encodes the position of the closest animal relative to the current animal.';'Transformations: flip, abs.'};...
            {'Angle of the current animal''s centroid in the closest (based on distance from nose to ellipse) animal''s coordinate system. Metric that encodes the position of the closest animal relative to the current animal.';'Transformations: flip, abs.'};...
            {'Maximum total angle of animal''s field of view (fov) occluded by another animal (rad). The parameter fov that can be set, and for our classifier''s we set it to &pi radians.';'Transformations: none.'};...
            {'Area of the ellipse (mm<sup>2</sup>).';'Transformations: none, relative.'};...
            {'Area of the wing that is closer to the body.';'Transformations: none, relative.'};...
            {'Area of the wing that is further away from the body.';'Transformations: none, relative.'};...
            {'Animal''s angular position in the arena measured as angle from x-axis.';'Transformations: none.'};...
            {'Distance of animal''s center from arena''s center.';'Transformations: none.'};...
            {'Quarter minor axis length (mm).';'Transformations: none, abs.'};...
            {'Identity of closest animal, based on anglesub, which is the total angle of animal''s eld of view (fov) occluded by the other animal (rad). The parameter fov that can be set, and for our classifier''s we set it to  radians.';'Transformations: none.'};...
            {'Identity of closest animal, based on dcenter.';'Transformations: none.'};...
            {'Identity of closest animal, based on dell2nose.';'Transformations: none.'};...
            {'Identity of closest animal, based on dnose2ell.';'Transformations: none.'};...
            {'Projection of the center of rotation on the animal''s major axis (no units). This is a measure of the point on the animal that translates least from one frame to the next. It is 0 at the center of the animal, 1 at the forward tip of the major axis, and -1 and the backward tip of the major axis.';'Transformations: none, abs.'};...
            {'Projection of the center of rotation on the animal''s minor axis (no units). This is a measure of the point on the animal that translates least from one frame to the next. It is 0 at the center of the animal, 1 at the right tip of the minor axis, and -1 and the backward tip of the minor axis.';'Transformations: flip, abs.'};...
            {'Change in quarter major axis length from frame t to t+1 (mm/s).';'Transformations: none, abs.'};...
            {'Change in the angle of the bigger wing. The bigger wing is decided based on the detected area of the wings.';'Transformations: none, abs, flip.'};...
            {'Change in the angle of the smaller wing. The smaller wing is decided based on the detected area of the wings.';'Transformations: none, abs, flip.'};...
            {'Change in the angle to closest point on the arena wall to animal''s center, relative to the animal''s orientation (rad).';'Transformations: flip, abs.'};...
            {'Change in maximum total angle of animal''s view occluded by another animal (rad/s).';'Transformations: none, abs.'};...
            {'Change in area from frame t to t+1 (mm/s).';'Transformations: none, abs.'};...
            {'Change in the area of the wing that is closer to the body.';'Transformations: none, abs, relative.'};...
            {'Change in the area of the wing that is more away from the body.';'Transformations: none, abs, relative.'};...
            {'Change in quarter minor axis length from frame t to t+1 (mm/s).';'Transformations: none, abs.'};...
            {'Minimum distance from this animal''s center to other animal''s center.';'Transformations: none, relative.'};...
            {'Change in minimum distance between this animal''s center and other flies'' centers (mm/s).';'Transformations: none, abs.'};...
            {'Change in the distance to arena wall (mm/s).';'Transformations: none.'};...
            {'Change in the eccentricity of the ellipse from frame t to t+1 (1/s).';'Transformations: none, abs.'};...
            {'Minimum distance from any point of this animal''s ellipse to the nose of other flies.';'Transformations: none, relative.'};...
            {'Distance to the arena wall from the animal''s center (mm).';'Transformations: none, relative.'};...
            {'Change in the angle of the larger wing angle.';'Transformations: none, abs.'};...
            {'Change in the area of the larger wing.';'Transformations: none, abs, relative.'};...
            {'Change in the angle of the smaller the wing angle.';'Transformations: none, abs.'};...
            {'Change in the are of the smaller wing.';'Transformations: none, abs, relative.'};...
            {'Minimum distance from any point of this animal''s nose to the ellipse of other flies.';'Transformations: none, relative.'};...
            {'Minimum distance from this animal''s nose to the ellipse of other flies. The distance to flies that lie within the cone of -30� to 30� are multiplied by a factor greater than 1 dependent on the angle. This feature is used to find distance to flies that are close but not in front of the animal.';'Transformations: none.'};...
            {'Minimum distance from this animal''s nose to the ellipse of other flies. The distance to flies that lie outside the -20� to 20� cone in front of the animal are multiplied by a factor greater than 1 depending on the angle. This feature is used to find distance to flies that are close and in front of the animal.';'Transformations: none.'};...
            {'Minimum distance from this animal''s nose to the ellipse of other flies. The distance to flies that lie outside the -30� to 30� cone in front of the animal are multiplied by a factor greater than 1 depending on the angle. This feature is used to find distance to flies that are close and in front of the animal.';'Transformations: none.'};...
            {'Minimum distance from any point of this animal''s nose to the tail of other flies.';'Transformations: none, relative.'};...
            {'Change in nwingsdetected.';'Transformations: none, abs.'};...
            {'Change in the velocity direction (rad/s).';'Transformations: none, abs.'};...
            {'Angular velocity (rad/s).';'Transformations: flip, abs.'};...
            {'Sideways velocity of the animal''s center of rotation (mm/s). This is the projection of the change in the position of the center of rotation on the animal onto the direction orthogonal to the animal''s orientation.';'Transformations: none, abs and relative.'};...
            {'Forward velocity of the animal''s center (mm/s). This is the projection of the animal''s velocity on its orientation direction.';'Transformations: none, abs and relative.'};...
            {'Forward velocity of the backmost point on the animal (mm/s).';'Transformations: none, abs and relative.'};...
            {'Sideways velocity of the animal''s center of rotation (mm/s). This is the projection of the change in the position of the center of rotation on the animal onto the direction orthogonal to the animal''s orientation.';'Transformations: flip and abs.'};...
            {'Sideways velocity of the animal''s center (mm/s). This is the projection of the animal''s velocity on the direction orthogonal to the orientation.';'Transformations: flip and abs.'};...
            {'Sideways velocity of the backmost point on the animal (mm/s).';'Transformations: flip and abs.'};...
            {'Change in wing_angle_diff.';'Transformations: none, abs.'};...
            {'Change in wing_angle_imbalance.';'Transformations: none, abs.'};...
            {'Eccentricity of the ellipse (no units).';'Transformations: none, abs.'};...
            {'Sideways velocity of the animal''s center of rotation, sign-normalized so that if the animal''s orientation is turning right, then flipdv_cor is positive if the animal''s center of rotation is also translating to the right (dv_cor x signdtheta) (mm/s).';'Transformations: relative.'};...
            {'Magnitude of difference in velocity of this animal and velocity of closest animal based on anglesub (mm/s).';'Transformations: none, relative.'};...
            {'Magnitude of difference in velocity of this animal and velocity of closest animal based on dnose2ell (mm/s).';'Transformations: none, relative.'};...
            {'Maximum of the largest absolute change in the wing angles.';'Transformations: none.'};...
            {'Maximum of the largest absolute change in the wing areas.';'Transformations: none, relative.'};...
            {'Change in the angle of the wing that moves in the most.';'Transformations: none.'};...
            {'Change in the angle of the wing that moves out the most.';'Transformations: none.'};...
            {'Maximum of the wing angles.';'Transformations: none.'};...
            {'Maximum of the wing areas.';'Transformations: none, relative.'};...
            {'Mean of the angles of the wings.';'Transformations: none.'};...
            {'Mean of the areas of the wings.';'Transformations: none, relative.'};...
            {'Minimum of the largest absolute change in the wing angles.';'Transformations: none.'};...
            {'Minimum of the largest absolute change in the wing areas.';'Transformations: none, relative.'};...
            {'Change in the angle of the wing that moves in the least.';'Transformations: none.'};...
            {'Change in the angle of the wing that moves out the least.';'Transformations: none.'};...
            {'Minimum of the wing angles.';'Transformations: none.'};...
            {'Minimum of the wing areas.';'Transformations: none, relative.'};...
            {'Number of flies within 2 body lengths (4a).';'Transformations: none.'};...
            {'Number of wings detected by the wing tracker. It can be either 0, 1 or 2.';'Transformations: none.'};...
            {'Velocity direction (rad).';'Transformations: none.'};...
            {'Difference between velocity direction and the animal''s orientation.';'Transformations: none.'};...
            {'Speed of the center of rotation (mm/s).';'Transformations: none and relative.'};...
            {'Speed of the fitted ellipse''s center(mm/s).';'Transformations: none and relative.'};...
            {'Speed of the animal''s nose (mm/s).';'Transformations: none and relative.'};...
            {'Speed of the animal''s tail (mm/s).';'Transformations: none and relative.'};...
            {'Velocity of this animal in the direction towards the closest animal (closest animal being defined based on anglesub) (mm/s).';'Transformations: none, relative.'};...
            {'Velocity of this animal in the direction towards the closest animal (closest animal being defined based on dnose2ell) (mm/s).';'Transformations: none, relative.'};...
            {'Angle between the right wing and the left wing.';'Transformations: none.'};...
            {'Difference of the right wing angle and the left wing angle.';'Transformations: none.'};...
            {'Difference between velocity direction and orientation (rad).';'Transformations: flip and abs.'}};

        pff_type_names = {'Fly appearance';'Fly locomotion';'Social';'Fly identity';...
            'Arena';'Fly position';'Wing appearance';'Wing movement'};

        pff_field_names = {'app';'loc';'soc';'id';'are';'pos';'Wapp';'Wmov'};

        pff_type = {1;3;2;2;3;3;3;3;7;7;5;3;3;3;3;1;7;7;6;[5,6];1;4;4;4;4;2;2;1;8;...
            8;5;3;1;8;8;1;3;3;5;1;3;5;8;8;8;8;3;3;3;3;3;7;[2,6];2;2;2;2;2;2;2;8;...
            8;1;2;3;3;8;8;8;8;7;7;7;7;8;8;8;8;7;7;3;7;6;2;2;2;2;2;3;3;7;7;2};

        pff_on=ismember((pff_names(:)),fns);
    end
end


function checkbox_dopff_Callback(hObject, eventdata)
end


function edit_fov(hObject, eventdata)
end


function edit_max_dnose2ell_anglerange(hObject, eventdata)
end


function edit_nbodylengths_near(hObject, eventdata)
end


function figure1_CreateFcn(hObject, eventdata, handles)
end


function pushbutton_cancel_Callback(hObject, eventdata)
    handles = guidata(hObject);
    uiresume(handles.figure1)
end


function pushbutton_accept_Callback(hObject, eventdata)
    handles = guidata(hObject);
    params = get(handles.pushbutton_accept,'UserData');
    pff_all = get(handles.figure1,'UserData');
    
    params.dopff = get(handles.checkbox_dopff,'Value');
    params.fov = str2double(get(handles.edit_fov,'String'));
    params.max_dnose2ell_anglerange = str2double(get(handles.edit_max_dnose2ell_anglerange,'String'));
    params.nbodylengths_near = str2double(get(handles.edit_nbodylengths_near,'String'));
    params.perframefns = pff_all.all.pff_names(pff_all.all.is_on);
    
    set(handles.pushbutton_accept,'UserData',params)
    
    uiresume(handles.figure1)
end


function figure1_CloseRequestFcn(hObject, eventdata, handles)
    pushbutton_cancel_Callback(hObject, eventdata);
end
