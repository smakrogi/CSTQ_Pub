function h = subplottight(n,m,i)
    [c,r] = ind2sub([m n], i);
    ax = subplot('Position', [(c-1)/m+0.025, 1-(r/n)+0.05, 1/(m+1), 1/(n+1)]);
    if(nargout > 0)
      h = ax;
    end
end