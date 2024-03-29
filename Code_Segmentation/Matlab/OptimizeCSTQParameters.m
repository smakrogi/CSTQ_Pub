function [x_opt, max_opt] = OptimizeCSTQParameters(data_nb, work_folder, dataset_name, ...
    parameters)
% Optimize CSTQ parameters.
% input:
% output:
% S. Makrogiannis, MIVICLAB, DSU, 11/2023.

% Define optimization function and initial point.
    function score = RBDMObjectiveFunction(x)
        local_params = parameters;
        local_params.CLAHE_clip_lim = x(1);
        local_params.TS_Ratio = x(2);
        local_params.ST_Diff_Iter = x(3);
        local_params.ParzenSigma = x(4);
        local_params.LS_Iter = x(5);

        [~, ~, mean_Jaccard, ~] = ...
            Cell_Segmentation_All_Frames(data_nb, work_folder,...
            dataset_name,local_params);

        score = 1 - mean_Jaccard;
    end

    function score = RBDMObjectiveFunctionBayes(x)
        local_params = parameters;
        local_params.CLAHE_clip_lim = x.clahe_clip_lim;
        local_params.TS_Ratio = x.ts_ratio;
        local_params.ST_Diff_Iter = x.st_diff_iter;
        local_params.ParzenSigma = x.parzen_sigma;
        local_params.LS_Iter = x.ls_iter;

        [~, ~, mean_Jaccard, ~] = ...
            Cell_Segmentation_All_Frames(data_nb, work_folder,...
            dataset_name,local_params);

        score = 1 - mean_Jaccard;
    end

% Choose solver method.
solver_method = 'bayes';

% CLAHE_clip_lim 
% TS_Ratio 
% ST_Diff_Iter 
% ParzenSigma 
% ImHMin 
% LS_Iter 

% Set params to be tuned.
x0 = [parameters.CLAHE_clip_lim, parameters.TS_Ratio, parameters.ST_Diff_Iter, ...
    parameters.ParzenSigma, parameters.LS_Iter];

% Optimize ACC using BBLL threshold.
switch solver_method
    case 'no_search'
        x_opt = x0;
    case 'grid_search'
        % Grid search
    case 'evolutionary'
    case 'fminunc'
        % Derivative-based.
        myoptOptions = optimoptions('fminunc', 'FiniteDifferenceType', 'central', 'DiffMinChange', 5e-8, ...
            'DiffMaxChange', 0.1, 'Display', 'iter', 'PlotFcns', @optimplotfval);
        [x_opt, score_opt] = fminunc(@RBDMObjectiveFunction, x0, myoptOptions);
    case 'fmincon'
        % Derivative-based.
        myoptOptions = optimoptions('fmincon', 'FiniteDifferenceType', 'central', 'DiffMinChange', 5e-8, ...
            'DiffMaxChange', 0.1, 'Display', 'iter', 'PlotFcns', @optimplotfval);
        [x_opt, score_opt] = fmincon(@RBDMObjectiveFunction, x0, [], [], [], [], ...
        [parameters.CLAHE_clip_lim_range(1), parameters.TS_Ratio_range(1), parameters.ST_Diff_Iter_range(1), ...
        parameters.ParzenSigma_range(1), parameters.LS_Iter_range(1)], ...
            [parameters.CLAHE_clip_lim_range(2), parameters.TS_Ratio_range(2), parameters.ST_Diff_Iter_range(2), ...
            parameters.ParzenSigma_range(2), parameters.LS_Iter_range(2)], ...
            [], myoptOptions);
    case 'simplex'
        % Non-derivative-based.
        myoptOptions = optimset('Display','iter','PlotFcns',@optimplotfval, 'TolX', 0.001, 'TolFun', 0.001);
        [x_opt, score_opt] = fminsearch(@RBDMObjectiveFunction, x0, myoptOptions);
    case 'bayes'
        % Bayesian optimization framework.
        rng default;

        clahe_clip_lim = optimizableVariable('clahe_clip_lim',...
            [parameters.CLAHE_clip_lim_range(1),parameters.CLAHE_clip_lim_range(2)], ...
            'Transform','log');
        
        ts_ratio = optimizableVariable('ts_ratio',...
            [parameters.TS_Ratio_range(1),parameters.TS_Ratio_range(2)], 'Type', 'integer');
        
        st_diff_iter = optimizableVariable('st_diff_iter',...
            [parameters.ST_Diff_Iter_range(1),parameters.ST_Diff_Iter_range(2)], 'Type', 'integer');

        parzen_sigma = optimizableVariable('parzen_sigma', ...
            [parameters.ParzenSigma_range(1),parameters.ParzenSigma_range(2)], ...
            'Type', 'integer');

        ls_iter = optimizableVariable('ls_iter',...
            [parameters.LS_Iter_range(1),parameters.LS_Iter_range(2)], 'Type', 'integer');
        
        results = bayesopt(@RBDMObjectiveFunctionBayes, [clahe_clip_lim, ts_ratio, st_diff_iter, parzen_sigma, ls_iter], ...
            'Verbose', 1, 'IsObjectiveDeterministic', true, 'AcquisitionFunctionName','expected-improvement-plus', ...
             'UseParallel', true, 'MaxObjectiveEvaluations', 100, 'InitialX', ...
             table(parameters.CLAHE_clip_lim, parameters.TS_Ratio, parameters.ST_Diff_Iter, ...
             parameters.ParzenSigma, parameters.LS_Iter));
        
        output_table = results.XTrace;
        score_opt = results.ObjectiveTrace;
        output_table = addvars(output_table, score_opt);

        opt_table = results.XAtMinObjective;
        x_opt = table2array(opt_table);
        score_opt = results.MinObjective;
        opt_table = addvars(opt_table, score_opt);
        
        output_table =[output_table; opt_table];
        if ismac || isunix
            dataset_name = strrep(dataset_name,'/','_');
        elseif ispc
            dataset_name = strrep(dataset_name,'\','_');
        else
            disp('Platform not supported')
        end
        writetable(output_table, ['Optim_X_F_', dataset_name, '.csv'])
end

% score_opt = RBDMObjectiveFunction(x_opt);
max_opt = 1 - score_opt;

fprintf('Opt. X: ');
fprintf(' %d\t', x_opt);
fprintf('\nMax. Opt. F: %d\n', max_opt);
end



