# TopconCameraKiralux
MATLAB GUI to capture images using TOPCON TRC50DX fundus camera with a Thorlabs Kiralux camera and synced flash

This code should also work for similar Thorlabs camera's which communicate with MATLAB through its .NET compiler although different dll file may be required.

This series of files creates a GUI in MATLAB to control a THORLABS KIRALUX camera with a synced flash powered by a NI 6501 USB interface. 
The dll files need to be in the same directory as the ".m" files. Otherwise MATLAB will not be able to see them.

You will need to change the directory used in the "TopconGUI.m" script to the location of the ".m" files.

The Gain setting is not normalised and you will need to establish what the gain range is for your particular Thorlabs Camera. 
For the KIRALUX 8.9MP monochrome it is 248
