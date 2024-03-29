# Cell_Segm_Track_Quant_MIVIC
## Code_Segmentation 
This part of the algorithm will run the complete process of cell segmentation.
To run this part of the code individually

In folder Code_Segmentation/Matlab
In Script_Cell_Segmentation_Main.m

Line 24>> work_folder =  fullfile('Home Directory', 'Documents', 'Data'); 

This is the path to your data directory. This path needs to be set at 'work_folder' based on the operating system of the user. The example here is for Windows OS.

In Cell_Segmentation_MIVICLAB_Main.m
Line 84>> Params.display = true;  

This is the default value, it will display the different stages of cell segmentation. Set it to false for no visualization.

Run Script_Cell_Segmentation_Main.m

## New data
Copy the corresponding csv file to the working directory with new data names and values
To read the new data and its values from the csv file, make the following changes

Go to Code_Segmentation/Matlab
In Script_Cell_Segmentation_Main.m

Line 32>> Dataset_Names = Parameter_Table.Dataset_Name(1:26);

And

In Cell_Segmentation_MIVICLAB_Main.m

Line 21>> DatasetExcelNames = Parameter_Table.Dataset_Name(1:26);

Change the indices accordingly to read the corresponding data from the csv file.
The new dataset's name should be generated in the menu list.
