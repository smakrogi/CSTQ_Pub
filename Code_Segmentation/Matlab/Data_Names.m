function DataNames = Data_Names
% Folder names in a string Array
%Convert an array of java.lang.String objects into a MATLAB cell array.
strArray = java_array('java.lang.String', 26);
%SIM: 6 datasets 
strArray(1)  =java.lang.String(['Fluo-N2DH-SIM',filesep,'01']);
strArray(2)  =java.lang.String(['Fluo-N2DH-SIM',filesep, '02']);
strArray(3)  =java.lang.String(['Fluo-N2DH-SIM',filesep,'03']);
strArray(4)  =java.lang.String(['Fluo-N2DH-SIM',filesep,'04']);
strArray(5)  =java.lang.String(['Fluo-N2DH-SIM',filesep, '05']);
strArray(6)  =java.lang.String(['Fluo-N2DH-SIM',filesep,'06']);
%  MSC:   2 datasets
strArray(7)  =java.lang.String(['Fluo-C2DL-MSC',filesep,'01']);
strArray(8)  =java.lang.String(['Fluo-C2DL-MSC',filesep,'02']);
% Hela: 2 datasets
strArray(9)  =java.lang.String(['Fluo-N2DL-HeLa',filesep,'01']);
strArray(10)  =java.lang.String(['Fluo-N2DL-HeLa',filesep,'02']);
% GOWT1:  2 datasets
strArray(11)  =java.lang.String(['Fluo-N2DH-GOWT1',filesep,'01']);
strArray(12)  =java.lang.String(['Fluo-N2DH-GOWT1',filesep,'02']);
% Fluo-N2DH-SIM+ 2 datasets
strArray(13)  =java.lang.String(['Fluo-N2DH-SIM+',filesep,'01']);
strArray(14)  =java.lang.String(['Fluo-N2DH-SIM+',filesep,'02']);
% Phc-C2DH-U373 2 datasets
strArray(15)  =java.lang.String(['PhC-C2DH-U373',filesep,'01']);
strArray(16)  =java.lang.String(['PhC-C2DH-U373',filesep,'02']);
% PhC-C2DL-PSC 2 datasets
strArray(17)  =java.lang.String(['PhC-C2DL-PSC',filesep,'01']);
strArray(18)  =java.lang.String(['PhC-C2DL-PSC',filesep,'02']);
% DIC-C2DH-HeLa 2 datasets
strArray(19)  =java.lang.String(['DIC-C2DH-HeLa',filesep,'01']);
strArray(20)  =java.lang.String(['DIC-C2DH-HeLa',filesep,'02']);
% BF-C2DL-HSC 2 datasets
strArray(21)  =java.lang.String(['BF-C2DL-HSC',filesep,'01']);
strArray(22)  =java.lang.String(['BF-C2DL-HSC',filesep,'02']);
% BF-C2DL-MuSC 2 datasets
strArray(23)  =java.lang.String(['BF-C2DL-MuSC',filesep,'01']);
strArray(24)  =java.lang.String(['BF-C2DL-MuSC',filesep,'02']);
% Fluo-C2DL-Huh7 2 datasets
strArray(25)  =java.lang.String(['Fluo-C2DL-Huh7',filesep,'01']);
strArray(26)  =java.lang.String(['Fluo-C2DL-Huh7',filesep,'02']);
% A549-Monolayer-24hrs datasets modified 11/01/2022
strArray(27)  =java.lang.String(['A549-Monolayer-24hrs',filesep,'01']);
% A549-Monolayer-24hrs datasets modified 11/01/2022
strArray(28)  =java.lang.String(['CCA',filesep,'01']);
% A549-Monolayer-24hrs datasets modified 11/01/2022
strArray(29)  =java.lang.String(['Control',filesep,'01']);
% A549-Monolayer-24hrs datasets modified 11/01/2022
strArray(30)  =java.lang.String(['ECA',filesep,'01']);
% A549-Monolayer-24hrs datasets modified 11/01/2022
strArray(31)  =java.lang.String(['Empty',filesep,'01']);
DataNames   = cell(strArray);
