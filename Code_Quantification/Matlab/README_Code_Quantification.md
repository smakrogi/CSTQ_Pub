# Cell_Segm_Track_Quant_MIVIC
## Code_Quantification
This part of the algorithm is performed post tracking. It quantifies and visualizes the dynamic cell characteristics along with the cell tracks.

In folder Code_Quantification/Matlab
In Script_Cell_Quantification_Main

Line 10>> work_folder = fullfile('Home Directory', 'Documents', 'Data');

This is the path to your data directory. This path needs to be set at 'work_folder' based on the operating system of the user. The example here is for Windows OS.

Run Script_Cell_Quantification_Main

Line 36>> pixel_resolutions and Line 37>> time_resolutions (Time step) have been preset for Cell Tracking Challenge data. The values can be added/edited based on user's data.
The order of the values correspond to the order of datasets on Parameters.csv/Challenge_Parameters.csv file.