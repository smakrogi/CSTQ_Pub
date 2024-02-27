function[im1_Trans,im2_Trans,im3_Trans]= Histogram_Transform(im1,im2,im3,Iref,Itest,GlobalMax,GlobalMin,LocalMin)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

im1 = double(im1);
im2 = double(im2);
im3 = double(im3);

I0=GlobalMin; I0prime=LocalMin;

slope = (Iref-I0) / (Itest-I0prime);
im1_Trans   = ( slope *  (im1-I0prime) ) + I0;
im2_Trans   = ( slope *  (im2-I0prime) ) + I0;
im3_Trans   = ( slope *  (im3-I0prime) ) + I0;

% Can be optional
im1_Trans=im1_Trans - GlobalMin;
im2_Trans=im2_Trans - GlobalMin;
im3_Trans=im3_Trans - GlobalMin;
im1_Trans = 255 * ( im1_Trans / (GlobalMax - GlobalMin) );
im2_Trans = 255 * ( im2_Trans / (GlobalMax - GlobalMin) );
im3_Trans = 255 * ( im3_Trans / (GlobalMax - GlobalMin) );

% scale This global max of all glob min *255

