@echo off
REM Run all segmentation and tracking experiments:
REM Prerequisities: MATLAB 2021a (x64), Python 3.8

REM FOR %x IN (*.bat) DO call "%x"

REM call "Fluo-N2DH-SIM-01.bat"

call "Fluo-C2DL-MSC-01.bat"
call "Fluo-C2DL-MSC-02.bat"
call "Fluo-N2DH-GOWT1-01.bat"
call "Fluo-N2DH-GOWT1-02.bat"
call "Fluo-N2DL-HeLa-01.bat"
call "Fluo-N2DL-HeLa-02.bat"
call "Fluo-N2DH-SIM+-01.bat"
call "Fluo-N2DH-SIM+-02.bat"
call "Fluo-C2DL-Huh7-01.bat"
call "Fluo-C2DL-Huh7-02.bat"
call "PhC-C2DH-U373-01.bat"
call "PhC-C2DH-U373-02.bat"
call "PhC-C2DL-PSC-01.bat"
call "PhC-C2DL-PSC-02.bat"


REM call "DIC-C2DH-HeLa-01.bat"
REM call "DIC-C2DH-HeLa-02.bat"
REM call "BF-C2DL-HSC-01.bat"
REM call "BF-C2DL-HSC-02.bat"
REM call "BF-C2DL-MuSC-01.bat"
REM call "BF-C2DL-MuSC-02.bat"
