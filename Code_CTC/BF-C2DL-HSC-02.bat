@echo off
REM Run the segmentation and tracking routines Cell_Segmentation_MIVICLAB_Main.exe and Cell_Tracking_MIVICLAB_Main.exe:
REM Cell_Segmentation_MIVICLAB_Main.exe root_folder input_sequence parameter_file
REM Cell_Tracking_MIVICLAB_Main.exe root_folder input_sequence
REM Prerequisities: MATLAB 2019b (x64), Python 3.8

Cell_Segmentation_MIVICLAB_Main.exe ..\ BF-C2DL-HSC\02 Challenge_Parameters.csv

Cell_Tracking_MIVICLAB_Main.exe ..\ BF-C2DL-HSC\02
