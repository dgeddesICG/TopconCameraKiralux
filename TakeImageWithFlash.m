global tlCamera
global tlCameraSDK
global serialNumber
global dio




%set gain and exposure time
expos=str2num(get(fexposureString,'String'));
gain=str2num(get(fgainString,'String'));
% set(src,'NormalizedGain',gain)
% set(src,'Exposure',expos);
%file name and save directory
Patient=get(patString,'String');
Operator=get(opString,'String');

Tm=clock;
Tm=Tm(2:end);
TmStr=[num2str(Tm(2)) '-' num2str(Tm(1)) '_' num2str(round(Tm(3))) num2str(Tm(4))];
%Tm(1) = month, Tm(2) = day, Tm(3) = hour, Tm(4) = minute, Tm(5) = seconds 

flnm=['Flash_' Patient '_' Operator '_' 'Exposure-' num2str(expos*1e3) 'ms_Gain_' num2str(gain) '_Time-' TmStr ];
dir=get(dirString,'String');



 flasherror=0;
   
 try
    outputSingleScan(dio, 0);
    
 catch
        msgbox('NI USB-6501 could not be reached. Check that it is connected.','Warning','Error')
        flasherror=1;
 end

 if ~flasherror
     
    tlCameraSDK = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
    serialNumber=tlCameraSDK.DiscoverAvailableCameras; %Discover Camera by Serial Number
    
    if (serialNumber.Count > 0)
        % Open the first TLCamera using the serial number.
        
        tlCamera = tlCameraSDK.OpenCamera(serialNumber.Item(0), false);

        % Set exposure time and gain of the camera.
        tlCamera.ExposureTime_us = expos*1e6;
        % Check if the camera supports setting "Gain"
        gainRange = tlCamera.GainRange;
        if (gainRange.Maximum > 0)
            tlCamera.Gain = gain;
        end

        % Set the FIFO frame buffer size. Default size is 1.
        tlCamera.MaximumNumberOfFramesToQueue = 1;
        figure(1)

        % Start continuous image acquisition
        
        tlCamera.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
        tlCamera.FramesPerTrigger_zeroForUnlimited = 1;
        tlCamera.Arm;

         %turn on flash
         
 %Fiddle With this

%pause(0);
outputSingleScan(dio,1);
pause(0.1)
tlCamera.IssueSoftwareTrigger;

pause(0.2);

outputSingleScan(dio,0); %turn off flash

        %maxPixelIntensity = double(2^tlCamera.BitDepth - 1);

        numberOfFramesToAcquire = 1;
        frameCount = 0;
        while frameCount < numberOfFramesToAcquire
            % Check if image buffer has been filled
            if (tlCamera.NumberOfQueuedFrames > 0)

                % If data processing in Matlab falls behind camera image
                % acquisition, the FIFO image frame buffer could overflow,
                % which would result in missed frames.


                % Get the pending image frame.
                FlashFrame = tlCamera.GetPendingFrameOrNull;
                if ~isempty(FlashFrame)
                    frameCount = frameCount + 1;

                    % Get the image data as 1D uint16 array
                    FlashData = uint16(FlashFrame.ImageData.ImageData_monoOrBGR);

                    

                    % TODO: custom image processing code goes here
                    imageHeight = FlashFrame.ImageData.Height_pixels;
                    imageWidth = FlashFrame.ImageData.Width_pixels;
                    FlashImage = reshape(FlashData, [imageWidth, imageHeight]);
                    FlashDisp = (FlashImage'-DarkImage);
                    figure(1)
                   
                    s=imagesc(FlashDisp);
                    axis off
                    disp('Image Captured and saved to directory')
                end

                % Release the image frame
                delete(FlashFrame);
            end
            drawnow;
        end

        % Stop continuous image acquisition
        
        tlCamera.Disarm;

        % Release the TLCamera
       
        tlCamera.Dispose;
        delete(tlCamera)
    end
 end

 tlCameraSDK.Dispose
 delete(tlCameraSDK)


% title({['Maximum value=' num2str(max(Icap(:))) ' / 4095']})
% if max(Icap(:))>4094
%     msgbox('Image is saturated','Warning','Error')
%     beep
% end


%save image
fmts=get(formatMenu,'String');
fmtval=get(formatMenu,'Value');
fmt=char(fmts(fmtval));

save([dir '/' flnm '.mat'],'FlashDisp');
imwrite(mat2gray(FlashDisp),[dir '/' flnm fmt]);


