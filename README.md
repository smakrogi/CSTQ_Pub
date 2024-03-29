# Cell_Segm_Track_Quant_MIVIC
Cell segmentation, quantification and tracking

# Source Code
Install version R2021b (x64) of Matlab desktop application to be able to run the code on user's platform.

1. Cell_Segm_Track_Quant_MIVIC_Install.m
This script will install the all the codes along with its dependencies. 

2. Go to Code_Main/Matlab
This directory contains codes to run all the stages of cell segmentation, tracking and quantification.

Line 11>>  work_folder =  fullfile('Home Directory', 'Documents', 'Data'); 

This is the path to your data directory. This path needs to be set at 'work_folder' based on the operating system of the user. The example here is for Windows OS.

Run Script_Cell_Seg_Track_Main.m 


## To train the classifier 
Go to Code_Segmentation/Matlab/Cell_Segmentation_MIVICLAB_Main.m

Line 87>> Params.training_mode = false;

To train the classifier, it needs to be set to true. 
After training the classifier it should be set to false to perform cell segmentation for the target image sequence.


## Automatic tuning of parameters for segmentation
Go to Code_Segmentation/Matlab/Cell_Segmentation_MIVICLAB_Main.m

Line 88>> Params.tuning = false;

This can be set true. It will automatically tune the parameters applied for segmentation of the cells from target sequence. 

## Manual tuning of parameters for segmentation
The algorithm includes two sheets that are used for parameter tuning of the data for segmentation 
1. Parameters.xlsx present at Code_Segmentation/Matlab/Parameters.xlsx
This sheet was used to tune the training data from Cell Tracking Challenge. The values present here are the best parameters obtained to get good segmentation results for training data

2. Challenge_Parameters.xlsx present at Code_CTC/Challenge_Parameters.xlsx
This sheet was used to tune the challenge data from Cell Tracking Challenge. The values present here are the best parameters obtained to get good segmentation results for challenge data.
These values were submitted along with the code to the Cell Tracking Challenge organizers for evaluation of the algorithm's performance on challenge data.

User can use any of the sheets for segmentation of the datasets.

## Adding new data
New data can be added to the Parameters.xlsx or Challenge_Parameters.xlsx sheet. After adding the name for the new data and initializing the parameters with values. 
It can be automatically observed on the generated menu list to select the target sequence. When selected the target sequence, the algorithm will read the dataset name and corresponding parameters values from the corresponding sheets. To allow this process, user needs to make the following changes:

1. For Segmentation only part of the algorithm
Go to Code_Segmentation/Matlab/
In Script_Cell_Segmentation_Main.m

Line 28>> [~, ~, DatasetNames] = xlsread(param_excel_path, 1, 'A2:A27');

Change the indices corresponding to the indices on the excel sheet for the dataset

In Cell_Segmentation_MIVICLAB_Main.m

Line 23>> [~, ~, DatasetExcelNames] = xlsread(Param_Excel_Path, 1, 'A2:A27');

Change the indices corresponding to the indices on the excel sheet for the dataset

2. For all other parts of the algorithm 
Go to Code_Segmentation/Matlab/Data_Names

Line 52>> DataNames   = cell(strArray);

Before this line add the new data following the syntax used for the other datasets.
For example: strArray(27)  =java.lang.String(['My dataset name',filesep,'sequence number']);



# Executables

Cell_Segmentation_MIVICLAB_Main Executable present in folder Code_CTC/Matlab

1. Prerequisites for Deployment 

Verify that version 9.10 (R2021b) (x64) of the MATLAB Runtime is installed.

If not, you can run the MATLAB Runtime installer.
To find its location, enter
  
    >>mcrinstaller
      
at the MATLAB prompt.
NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

Alternatively, download and install the Windows version of the MATLAB Runtime for R2021b 
from the following link on the MathWorks website:

    https://www.mathworks.com/products/compiler/mcr/index.html
   
For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
"Distribute Applications" in the MATLAB Compiler documentation  
in the MathWorks Documentation Center.

2. Files to Deploy and Package

Files to Package for Standalone 
================================
- Cell_Segmentation_MIVICLAB_Main.exe
- MCRInstaller.exe 
    Note: if end users are unable to download the MATLAB Runtime using the
    instructions in the previous section, include it when building your 
    component by clicking the "Runtime included in package" link in the
    Deployment Tool.
-This readme file 
- 'Challenge_Parameters.csv' parameter file in the same folder with the executable files.


3. Definitions

For information on deployment terminology, go to
https://www.mathworks.com/help and select MATLAB Compiler >
Getting Started > About Application Deployment >
Deployment Product Terms in the MathWorks Documentation
Center.

4. Example of Folder structure to run the executables

myFolder/CSTQ/
              Fluo-C2DL-MSC/
                            01
                            01_GT
                            01_Msk_CSTQ
                            01_RES
                            01_ST
                            02                                
                            02_GT
                            02_Msk_CSTQ
                            02_RES
                            02_ST
                   DESU-US/  
                            Cell_Segmentation_MIVICLAB_Main.exe
                            Cell_Tracking_MIVICLAB_Main.exe
                            Challenge_Parameters.xlsx
                            Fluo-C2DL-Huh7-01.bat
                            Fluo-C2DL-Huh7-02.bat
                            .
                            .
