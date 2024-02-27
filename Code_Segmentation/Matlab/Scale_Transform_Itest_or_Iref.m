function I_Trans= Scale_Transform_Itest_or_Iref(I,Iref,Itest,GlobalMax,GlobalMin, LocalMin)
    I0=GlobalMin; I0prime=LocalMin;
    slope = (Iref-I0) / (Itest-I0prime);
    I_Trans    = ( slope * (I-I0prime) ) + I0;
    % Can be optional
    I_Trans=I_Trans-GlobalMin;
    I_Trans = 255 * (I_Trans / (GlobalMax-GlobalMin));

