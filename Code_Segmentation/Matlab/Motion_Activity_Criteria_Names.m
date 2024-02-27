function Mot_Activ_Crit = Motion_Activity_Criteria_Names
% Folder names in a string Array
%Convert an array of java.lang.String objects into a MATLAB cell array.
strArray = java_array('java.lang.String', 9);
%SIM: 6 datasets 
strArray(1)  =java.lang.String('original');
strArray(2)  =java.lang.String('diffused');
strArray(3)  =java.lang.String('st_gradient');
strArray(4)  =java.lang.String('regions_diffused');
strArray(5)  =java.lang.String('regions_st_gradient');
strArray(6)  =java.lang.String('regions_active_pixels');
strArray(7)  =java.lang.String('regions_st_laplace');
strArray(8)  =java.lang.String('regions_st_moments');
strArray(9)  =java.lang.String('regions_st_hessian');
strArray(10)  =java.lang.String('regions_sp_hessian_tempo_deriv');
Mot_Activ_Crit   = cell(strArray);
