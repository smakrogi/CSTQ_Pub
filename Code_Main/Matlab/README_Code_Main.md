# Cell_Segm_Track_Quant_MIVIC
## Code_Main

This is the main folder that will run the complete process of cell segmentation, tracking and quantification for the sequence selected

In folder Code_Main/Matlab
In Script_Cell_Seg_Track_Main.m

Line 14>>  work_folder =  fullfile('Home Directory', 'Documents', 'Data'); 

This is the path to your data directory. This path needs to be set at 'work_folder' based on the operating system of the user. The example here is for Windows OS.

Run Script_Cell_Seg_Track_Main.m 


## New data
Copy the corresponding csv file to the working directory with new data names and values
To read the new data and its values from the csv file, make the following changes

In Script_Cell_Seg_Track_Main.m

Line 26>> Dataset_Names = Parameter_Table.Dataset_Name(1:26);

Change the indices accordingly to read the corresponding data from the csv file.
The new dataset's name should be generated in the menu list.