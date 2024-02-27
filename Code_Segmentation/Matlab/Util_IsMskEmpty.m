function isMskEmpty=Util_IsMskEmpty(mskdir)
    files = dir(fullfile(mskdir, '*.tif'));
    % if have tif files then return 0
    if length(files)==0
        isMskEmpty=1;
    else
        isMskEmpty=0;
    end
end