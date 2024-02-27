function classifier_model = TrainForegroundBackgroundClassifier(Nom,Params)
% Authors:
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

Params.data_preproc_method = 'z-scores'; % options: {'none','z-scores','normalize'}
classifier_type = 'nnet';
reduce_class_imbalance = true;

feature_table = readtable(strcat('ST-feature-computation-',Nom,'.csv'));

Joint_Measure = table2array(feature_table(:,1:end-1));
labels = table2array(feature_table(:,end));

% Prepare the data
switch Params.data_preproc_method
    case 'normalize'
        % Normalize the vector lengths.
        Joint_MeasureT = Joint_Measure';
        Joint_MeasureT = normcols(Joint_MeasureT);
        Joint_Measure = Joint_MeasureT';
    case 'z-scores'
        % Center and scale data to compute z-scores.
        Joint_MeasureT = Joint_Measure';
        mean_vector = mean(Joint_MeasureT, 2);
        Joint_MeasureT = (Joint_MeasureT - mean_vector);
        Joint_MeasureT = Joint_MeasureT ./ std(Joint_MeasureT,0,2);
        Joint_Measure = Joint_MeasureT';
    case 'none'
end

if reduce_class_imbalance
    % Reduce class imbalance.
    [Joint_Measure, labels] = ReduceClassImbalance(Joint_Measure, labels);
end

% Train classifier.
classifier_filename = strcat('fb_classifier.mat');
classifier_model = matlab.lang.makeValidName(strcat('fb_model_',Nom));

if isfile(classifier_filename)
    load(classifier_filename, 'classifier_struct');
end

switch classifier_type
    case 'lda'
        classifier_struct.(classifier_model) = fitcdiscr(Joint_Measure,labels); %, ...
%             'OptimizeHyperparameters','auto',...
%             'HyperparameterOptimizationOptions',struct('Holdout',0.3,...
%             'AcquisitionFunctionName','expected-improvement-plus'));
    case 'qlda'
        classifier_struct.(classifier_model) = fitcdiscr(Joint_Measure,labels, ...
            'DiscrimType','quadratic');
    case 'tree'
        classifier_struct.(classifier_model) = fitctree(Joint_Measure,labels);
    case 'svm'
        classifier_struct.(classifier_model) = fitcsvm(Joint_Measure,labels, ...
        'KernelFunction', 'gaussian', ...
            'PolynomialOrder', [], ...
            'KernelScale', 0.5600000000000001, ...
            'BoxConstraint', 1, ...
            'Standardize', true, ...
            'ClassNames', [0; 1]);
    case 'nnet'
        rng("default") % For reproducibility
        classifier_struct.(classifier_model) = fitcnet(...
            Joint_Measure, ...
            labels, ...
            'LayerSizes', [12 6], ...
            'Activations', 'relu', ...
            'Lambda', 0, ...
            'IterationLimit', 1000, ...
            'Standardize', true, ...
            'ClassNames', [0; 1]);
end

classifier_struct.(classifier_model) = compact(classifier_struct.(classifier_model));
save(classifier_filename, 'classifier_struct');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Balanced_Joint_Measure, balanced_labels] = ReduceClassImbalance(Joint_Measure, labels)

% Cluster data.
sample_cluster_idx = dbscan(Joint_Measure, 0.5, 5, 'Distance', 'Mahalanobis');
cluster_idx = unique(sample_cluster_idx);
cluster_size = histcounts(sample_cluster_idx,cluster_idx);
[sorted_cluster_size, sort_idx] = sort(cluster_size);

% Stratify classes by reducing the samples from the most populous class.
max_cluster_size = sorted_cluster_size(end-1);
max_cluster_idx = find(sample_cluster_idx == cluster_idx(sort_idx(end)));
perm_max_cluster_idx = randperm(sorted_cluster_size(end));

% Remove entries from the data matrix.
Balanced_Joint_Measure = Joint_Measure;
balanced_labels = labels;
id_remove = zeros(1,sorted_cluster_size(end) - max_cluster_size);
count = 0;
for ii = max_cluster_size+1:sorted_cluster_size(end)
    count = count + 1;
    id_remove(count) = max_cluster_idx(perm_max_cluster_idx(ii));
end
Balanced_Joint_Measure(id_remove,:) = [];
balanced_labels(id_remove) = [];

end