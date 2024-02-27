function [result_array,result_size]=Util_Combination()
%List<String[]> list = new arrayList<>();
%arrayList
arrayList={};

% Get Params Arrange
Params_Arrange=Util_Get_Params_Arrange_V29_02;

arrayList{1}=length(Params_Arrange.Frame_Modulo);
arrayList{2}=length(Params_Arrange.Noise_Filter_Type);
arrayList{3}=length(Params_Arrange.CLAHE_tile_num)
arrayList{4}=length(Params_Arrange.CLAHE_clip_lim)
arrayList{5}=length(Params_Arrange.ST_Diff_Type)
arrayList{6}=length(Params_Arrange.Lambda_Tempo)
arrayList{7}=length(Params_Arrange.TS_Ratio)
arrayList{8}=length(Params_Arrange.ST_Diff_Iter)
arrayList{9}=length(Params_Arrange.Kappa)
arrayList{10}=length(Params_Arrange.WSEG_ID)
arrayList{11}=length(Params_Arrange.ParzenSigma)
arrayList{12}=length(Params_Arrange.ImHMin)
arrayList{13}=length(Params_Arrange.CDF_Thres)
arrayList{14}=length(Params_Arrange.LS_ID)
arrayList{15}=length(Params_Arrange.LS_Iter)
arrayList{16}=length(Params_Arrange.LS_mu)
arrayList{17}=length(Params_Arrange.ImHMin_SDT)
arrayList{18}=length(Params_Arrange.Mot_Act_Meas_ID)
arrayList{19}=length(Params_Arrange.FB_ID)
arrayList{20}=length(Params_Arrange.FB_Sigma)

arrayList_lenth=size(arrayList,2);
%Initialize ArrayList
% Get All Parameters from the Params Arrange. Save to ArrayList(i)
for i=1:arrayList_lenth
    arrayList{i}=linspace(1,arrayList{i},arrayList{i});
    arrayList{i}=num2str(arrayList{i});
    %split by 2 space
    arrayList{i}=split(arrayList{i},'  ');
    %arrayList{i}=num2str(arrayList{i});
end

% Combine all ArrayList and save the combination result to the last item
for i = 1: arrayList_lenth-1
    arrayList{i + 1}=Util_Combine2Array(arrayList{i}, arrayList{i + 1});
    %arrayList{i + 1}=arrayList{i}+" "+ arrayList{i + 1};
end

%save ultimate result
result_array=arrayList{arrayList_lenth};
disp('Total Experiment Parameters Numbers is : ')
result_size=size(result_array,2)

 

