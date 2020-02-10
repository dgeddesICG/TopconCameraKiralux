global tlCamera
global tlCameraSDK
global serialNumber
global keepg

    if ishandle(s)
           delete(s)
           delete(findall(findall(gcf,'Type','axe'),'Type','text'))
    end

set(PreviewStopButton, 'Enable', 'on')
set(PreviewStartButton, 'Enable', 'off')
set(CaptureImageButton, 'Enable', 'off')
keepg = 1;


tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
serialNumber=tlCameraSDK.DiscoverAvailableCameras; %Discover Camera by Serial Number
%end

disp('Starting Preview')
if (serialNumber.Count > 0) 
    tlCamera = tlCameraSDK.OpenCamera(serialNumber.Item(0), false); %opens camera
    tlCamera.OperationMode=Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered; %sets camera to software triggered mode
    tlCamera.FramesPerTrigger_zeroForUnlimited=0; %Captures a single frame per trigger
    tlCamera.Arm; %Prepares camera for capturing images
   
    
    %% Capture Live Image for Preview
    
    while keepg==1
    
    fexpos=str2num(get(fexposureString,'String')); %Get exposure value from text box input in GUI
    fgain=str2num(get(fgainString,'String')); %Get gain value from text box input in GUI
        
         
    tlCamera.ExposureTime_us = fexpos*1e6; %Set exposure time using UI textbox (measured in microseconds
    tlCamera.Gain = fgain; %Set gain
    tlCamera.IssueSoftwareTrigger; %capture frame
    maxPixelIntensity = double(2^tlCamera.BitDepth-1);
    
    numberOfFramesToAcquire = 1;
    frameCount=0;
    while frameCount < numberOfFramesToAcquire
        if (tlCamera.NumberOfQueuedFrames > 0)
           
            PreviewFrame = tlCamera.GetPendingFrameOrNull; %Poll camera for next available frame
                if ~isempty(PreviewFrame)
                        frameCount = frameCount + 1;
                        
                        PreviewData = uint16(PreviewFrame.ImageData.ImageData_monoOrBGR); %Restructure frame data
                        
                        
                        imageHeight = PreviewFrame.ImageData.Height_pixels;
                        imageWidth = PreviewFrame.ImageData.Width_pixels;
                        
                        PreviewImage = reshape(PreviewData, [imageWidth, imageHeight]); %Further restructuring
                        PreviewDisp=(PreviewImage'-DarkImage); 
                        
                        %plot image
                        figure(1);
                        s = imagesc(PreviewDisp);
                        axis off
                        colormap(gray)
                        
                        title({['Preview For Focus'], ['Exposure=' num2str(fexpos) ' secs. Maximum value=' num2str(max(PreviewImage(:)))]})
                end
                delete(PreviewFrame); %Clear frame variable for next iteration
        end
       drawnow;

    
    end

    end

  
end




