%%
close all; clc;

% Root folder for data.
%workFolder          = 'C:\Users\fboukari\ownCloud\Fatima_Boukari\New data\';
 workFolder          = 'C:\Users\fboukari\ownCloud\Fatima_Boukari\Data\';

% workFolder          = 'C:\Users\sokratis\ownCloud\Fatima_Boukari\New data\';
%workFolder          = 'C:\Users\sokratis\ownCloud\Fatima_Boukari\Data\';

%Folder that contains all the masks on desktop for testing;
%workFolder='C:\Users\fboukari\Desktop\Tracking_Masks_Results\';
%workFolder='C:\Users\Public\data_02_19_2015\______BEST MASKS Keep Hela_2Motion_sig20_lambda0.1_TSRatio100\';
%Binary masks of each dataset is at:   0nb_Msk
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-C2DL-MSC\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-GOWT1\';
%workFolder     = 'C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\';
% workFolder          = 'C:\Users\fboukari\ownCloud\Fatima_Boukari\New data\Fluo-N2DH-SIM\';
% workFolder='C:\Users\sokratis\ownCloud\Fatima_Boukari\New data\Fluo-N2DL-HeLa\';
% workFolder='C:\Users\sokratis\ownCloud\Fatima_Boukari\New data\Fluo-N2DH-GOWT1\';
% workFolder='C:\Users\sokratis\ownCloud\Fatima_Boukari\New data\Fluo-C2DL-MSC\';

DatasetNames      = Data_Names; % For now we have SIM04= 4 and Hela2 =10
% %Data_Nb           = menu('Dataset name:' ,'Fluo-N2DH-SIM\01' ,'Fluo-N2DH-SIM\02',...
%       'Fluo-N2DH-SIM\03' ,'Fluo-N2DH-SIM\04' ,'Fluo-N2DH-SIM\05',...
%       'Fluo-N2DH-SIM\06' ,'Fluo-C2DL-MSC\01' ,'Fluo-C2DL-MSC\02',...
%       'Fluo-N2DL-HeLa\01','Fluo-N2DL-HeLa\02','Fluo-N2DH-GOWT1\01',...
%       'Fluo-N2DH-GOWT1\02');


% Data_Nb=10;
%for Data_Nb=7:length(DatasetNames)
for Data_Nb=10:length(DatasetNames)
    dataset_name          =   DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
    Sequence_Name         = strcat(dataset_name(1:end-3),dataset_name(end-1:end));
    
    %local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
    %C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\01_Msk
    %toshiba hard drive   F:\datasets\C2DL-MSC
    Mask_Name           = [dataset_name, '_GT\SEG\'];        %  name of folder containing the 1`112d masks (input)
    Label_Name          = [dataset_name, '_GT\TRA\'];  % name of foler that will contain the lable masks (output)
    Image_Name          = dataset_name;
    Mask_Folder         = strcat(workFolder,Mask_Name);
    Label_Folder         = strcat(workFolder,Label_Name);
    Orig_Folder         = strcat(workFolder,Image_Name);
    Glob_Folder         = [workFolder, dataset_name, '_RES_GT\'];
    
    
% % % % %     %% Create movie from original images
% % % % %     [Original_Images, Nb_orig] = Get_Original(Orig_Folder);
% % % % %     moviename = strcat(Sequence_Name,'_Movie.avi');  %...
% % % % %     Frames(1:Nb_orig) = struct('cdata', [],'colormap', []);
% % % % %     % all frames.
% % % % %     for k = 1:Nb_orig;
% % % % %         figure,imagesc(Original_Images{k});colormap gray;axis tight; axis off; hold on;
% % % % %         Frames(k)=getframe(gcf);
% % % % %     end
% % % % %     movie2avi( Frames(1:Nb_orig), moviename, 'fps', 7 );%new
    close all;
    %% Plot some quantif measures eccentricity, shape solidity size ...number of cells per frame all sets
         
   frame_number_position=10;
    [Label_Maps, Nb_labeled] = Get_Binary_Masks(Label_Folder, frame_number_position); 
   
     Nb_Cells_Per_Frame=zeros(Nb_labeled,1);
     for k = 1:Nb_labeled;
        CC_Structure     = bwconncomp(Label_Maps{k}, 4);
        Nb_Cells_Per_Frame(k) = CC_Structure.NumObjects;
     end;
     x=1:30:Nb_labeled*30;
     YAxis=0:max(Nb_Cells_Per_Frame(:,1));
     figure,plot(x,Nb_Cells_Per_Frame(:,1),'--gs','LineWidth',1,'MarkerSize',4,'MarkerEdgeColor','b',...
    'MarkerFaceColor','b');


 

end;
% %     % Call main tracking function.
% %     % Optional input: parameter structure.
% %    % Tracking_Structure = Cell_Tracking_Main(Orig_Folder, Label_Folder, Sequence_Name, Glob_Folder);
% %     
% %       Tracking_Structure = Cell_Tracking_For_Figure(Orig_Folder, Label_Folder, Sequence_Name, Glob_Folder);
% % %end
% % 
% % % To validate:
% % % start cygwin X-server
% % % start xterm
% % % cd '/cygdrive/c/Users/fboukari/ownCloud/Fatima_Boukari/From_Fatima/CODE_06_2015/Code_Tracking/EvaluationSoftware'
% % % ./Win/TRAMeasure.exe "C:\Users\fboukari\ownCloud\Fatima_Boukari\New data\Fluo-N2DH-SIM" 01
