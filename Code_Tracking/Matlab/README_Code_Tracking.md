# Cell_Segm_Track_Quant_MIVIC
## Code_Tracking 
This part of the algorithm will run the complete process of cell tracking. This can be only performed post segmentation. 
To run this stage individually

Go to folder Code_Tracking/Matlab
In Script_Tracking_Main.m

Line 16>> work_folder = fullfile('Home Directory', 'Documents', 'Data'); 

This is the path to your data directory. This path needs to be set at 'work_folder' based on the operating system of the user. The example here is for Windows OS.

In Cell_Tracking_MIVICLAB_Main.m
Line 20>> Params.display = false;

This is the default value. Set it to true for visualization cell tracking stages.

Run Script_Tracking_Main.m

## New data
Copy the corresponding csv file to the working directory with new data name and values
To read the new data from the csv file, make the following changes

1. Go to Code_Tracking/Matlab
In Script_Cell_Tracking_Main.m

Line 24>> Dataset_Names = Parameter_Table.Dataset_Name(1:26);

Change the indices accordingly to read the corresponding data from the csv file.
The new dataset's name should be generated in the menu list. 
