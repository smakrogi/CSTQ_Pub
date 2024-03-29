function New_seg= Swap_Resize(I, seg)
% Swap foreground/background if needed.
  s = min(size(seg,1),size(seg,2))/min(size(I,1),size(I,2));
  if s<1
      resized_I = imresize(I,s);
  end
  foreground_indices = find(seg == 1);
  background_indices = find(seg == 0);
  mean_foreground = mean(resized_I(foreground_indices));
  mean_background = mean(resized_I(background_indices));
  if mean_background >= mean_foreground
      New_seg = ~seg;
  else
      New_seg = seg;
  end
end