global tlCamera
global serialNumber
global tlCameraSDK
global gainRange
% if ishandle(s)
%     delete(s)
%     delete(findall(findall(gcf,'Type','axe'),'Type','text'))
% end

button = questdlg('Is inspection lamp off?');
if strcmp(button,'Yes')
   
    expos=str2num(get(fexposureString,'String'));
    gain=str2num(get(fgainString,'String'));
   
    
    Patient=get(patString,'String');
    Operator=get(opString,'String');
    
%     Tm=clock;
%     Tm=Tm(2:end);
%     TmStr=[num2str(Tm(1)) '_' num2str(Tm(2)) '_' num2str(round(Tm(3))) '_' num2str(round(Tm(4))) '_' num2str(round(Tm(3))) ];
    flnm=['DarkImage_' Patient '_' Operator '_' 'Exposure_' num2str(expos*1e6) 'ms_Gain_' num2str(gain)]; %'_Time_' TmStr ];
    dir=get(dirString,'String');
    tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
    serialNumber=tlCameraSDK.DiscoverAvailableCameras; %Discover Camera by Serial Number
    if (serialNumber.Count > 0)
        % Open the first TLCamera using the serial number
        tlCamera = tlCameraSDK.OpenCamera(serialNumber.Item(0), false);

        % Set exposure time and gain of the camera.
        tlCamera.ExposureTime_us = expos*1e6;

        % Check if the camera supports setting "Gain"
        gainRange = tlCamera.GainRange;
        if (gainRange.Maximum > 0)
            tlCamera.Gain = gain;
        end

        % Set the FIFO frame buffer size. Default size is 1.
        tlCamera.MaximumNumberOfFramesToQueue = 5;

        figure(1)

        % Start image acquisition
        tlCamera.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
        tlCamera.FramesPerTrigger_zeroForUnlimited = 0;
        tlCamera.Arm;
        tlCamera.IssueSoftwareTrigger;
        maxPixelIntensity = double(2^tlCamera.BitDepth - 1);

        numberOfFramesToAcquire = 1;
        frameCount = 0;
        while frameCount < numberOfFramesToAcquire
            % Check if image buffer has been filled
            if (tlCamera.NumberOfQueuedFrames > 0)

                % Get the pending image frame.
                DarkFrame = tlCamera.GetPendingFrameOrNull;
                if ~isempty(DarkFrame)
                    frameCount = frameCount + 1;

                    % Get the image data as 1D uint16 array
                    DarkData = uint16(DarkFrame.ImageData.ImageData_monoOrBGR);

                   
                    % TODO: custom image processing code goes here
                    imageHeight = DarkFrame.ImageData.Height_pixels;
                    imageWidth = DarkFrame.ImageData.Width_pixels;
                    DarkImage = reshape(DarkData, [imageWidth, imageHeight])';

                    figure(1)
                    s = imagesc(DarkImage);
                    axis off
                    title({['Dark frame. Maximum value=' num2str(max(DarkImage(:)))]})
                    %colormap(gray)
                    %colorbar
                    disp('Dark Image Captured and saved to directory')
                end

                % Release the image frame
                delete(DarkFrame);
            end
            drawnow;
        end

        % Stop continuous image acquisition
        
        tlCamera.Disarm;
        
        
        
        set(PreviewStartButton, 'Enable','on')
        set(DarkImageButton, 'Enable','off')
        set(CaptureImageButton,'Enable','on')
        
        % Release the TLCamera
        tlCamera.Dispose;
        
      
    end
    
    save([dir '/' flnm '.mat'],'DarkImage');
    
    fmts=get(formatMenu,'String');
    fmtval=get(formatMenu,'Value');
    fmt=char(fmts(fmtval));
    
    imwrite(mat2gray(DarkImage),[dir '/' flnm fmt]);
    % Release the serial numbers
    delete(serialNumber);

    % Release the TLCameraSDK.
    tlCameraSDK.Dispose;
    delete(tlCameraSDK);

    
else
    
    msgbox('No dark frame was taken.','Warning','Warning');
end

