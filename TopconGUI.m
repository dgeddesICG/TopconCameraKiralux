clear all
close all



if exist('hFig')
    close(hFig)
    clear hFig
    clear
end

  if ~exist('FlashData', 'dir')
       mkdir('FlashData')
  end


NET.addAssembly([pwd, '\Thorlabs.TSI.TLCamera.dll']); %Loads dll files for camera
disp('Dot NET assembly loaded.')


dio = daq.createSession('ni');
       
addDigitalChannel(dio,'Dev1','Port1/Line7','OutputOnly');
   


  %create window
        scrsz = get(0,'ScreenSize');
        global hFig;
        hFig = figure(      'NumberTitle','Off',...
            'Position',[60 60 scrsz(3)/1.2 scrsz(4)/1.5],...
            'Name','Topcon Capture','Toolbar','figure');
        hImage1=axes('Position',[0.1300    0.1800    0.750    0.77]);
        axis off
        colormap(gray)
        drawnow
        
        
               %Set directory button
        dirString=uicontrol('Style','edit', 'String',[pwd,'\FlashData'],... 
            'Units','normalized','HorizontalAlignment','left',...
            'Position',[0.15 0.1 .35 .03]);
        setDirButton=uicontrol('String', 'Set directory',...
            'Callback', 'SetDirectoryCallback',...
            'Units','normalized',...
            'Position',[0.5 0.1 .05 .03]);  
        setDirLabel=uicontrol('Style','text','Units','normalized','String','Directory',...
            'HorizontalAlignment','left','Position',[0.105 0.1 .04 .029]);
        
        
        % Set image format to be saved menu
        formatMenu=uicontrol('Style','popupmenu','String',{'.tiff';'.png'},...
            'Units','normalized','HorizontalAlignment','left','Position',[0.7 0.1 .1 .03]); 
        formatLabel=uicontrol('Style','text','String',{'Additional Image format'},...
            'Units','normalized','HorizontalAlignment','left','Position',[0.60 0.1 .1 .029]);
        
        %Patient string
        patString=uicontrol('Style','edit', 'String','Patient1',...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[0.15 0.065, .15 .03]);
        patLabel=uicontrol('Style','text','Units','normalized','string',{'Patient'},...
            'HorizontalAlignment','left','Position',[0.105 0.065 .04 .029]);
        
        %Operator string
        opString=uicontrol('Style','edit', 'String','DG',...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[0.15 0.03 .05 .03]);
        opLabel=uicontrol('Style','text','Units','normalized','string',{'Operator'},...
            'HorizontalAlignment','left','Position',[0.105 0.03 .04 .029]);
        
    
         %Focus exposure and gain settings
        fexposureString=uicontrol('Style','edit', 'String','0.1',...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[0.90 0.89 .03 .035]);
        fexposureLabel=uicontrol('Style','text','Units','normalized','String','Exposure Time','FontSize',14,...
            'HorizontalAlignment','left','Position',[0.90 0.93 .2 .03]);
        uicontrol('Style','text','Units','normalized','String','secs',...
            'HorizontalAlignment','left','Position',[0.94 0.89 .06 .03]);
        fgainString=uicontrol('Style','edit', 'String','100',...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[0.9 0.79 .045 .035]);
        fgainLabel=uicontrol('Style','text','Units','normalized','String','Gain','FontSize',14,...
            'HorizontalAlignment','left','Position',[0.90 0.83 .15 .04]);
       
        
        
        PreviewStartButton = uicontrol('String','Start Image Preview','Callback', 'PreviewStartCallback',...
            'HorizontalAlignment','left','Units','normalized',...
            'Position',[0.10 0.14 .2 .04]);
            
        
        PreviewStopButton=uicontrol('String','Stop Preview',...
            'Callback', 'PreviewStopCallback','Units','normalized',...
            'Position',[0.30 0.14 .2 .04]);
       
        %capture image button

        DarkImageButton = uicontrol('String', 'Take Dark Image',...
            'Callback','TakeDarkImage','Units','normalized',...
            'Position',[0.50 0.14 0.2 0.04]);
        
        CaptureImageButton = uicontrol('String','Capture Image',...
            'Callback','TakeImageWithFlash','Units','normalized',...
            'Position',[0.70 0.14 0.2 0.04]);
        
       
        
         set(PreviewStopButton, 'Enable', 'off')
         set(PreviewStartButton, 'Enable', 'off')
         set(CaptureImageButton, 'Enable', 'off')
         
      