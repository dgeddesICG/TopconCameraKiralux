global tlCamera
global tlCameraSDK
global serialNumber
global keepg

set(PreviewStopButton, 'Enable', 'off')
set(PreviewStartButton, 'Enable', 'on')
set(CaptureImageButton, 'Enable', 'on')

 
if tlCamera.IsArmed == 1
    keepg = 0;
    tlCamera.Disarm
   
    
    tlCamera.Dispose
    delete(tlCamera);
    
    delete(serialNumber)
    
    tlCameraSDK.Dispose
    delete(tlCameraSDK)
    
    disp('Preview Ended')
end


if ishandle(s)
    delete(s)
    delete(findall(findall(gcf,'Type','axe'),'Type','text'))
end

    