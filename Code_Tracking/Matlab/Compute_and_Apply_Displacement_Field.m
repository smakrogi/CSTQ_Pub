function [Warped_Label_Map, UV] = Compute_and_Apply_Displacement_Field(Previous_Frame, Current_Frame, ...
    Previous_Label_Map, Current_Label_Map, frame_index, parameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute motion models from current and previous frames.
% uv = estimate_flow_interface(Original_Images{k-1}, Original_Images{k}, 'hs');
UV = Call_OF_Ce_Liu(Previous_Frame, Current_Frame);

% Apply motion field to original frame and segmented frame.
% First, create meshgrid.
[rows, columns] = size(Previous_Frame);
x = 1:columns;
y = 1:rows;
[XX,YY]=meshgrid(x,y);

% Then use optical flow vectors to create displacement field.
XX_Predicted = XX - UV(:,:,1);
YY_Predicted = YY - UV(:,:,2);

% Apply bilinear interpolation to original image.
%Warped_Original_Image = linint2D2(XX_Predicted, YY_Predicted, Original_Images{k-1});
Warped_Original_Image = interp2(XX,YY, Previous_Frame, ...
    XX_Predicted, YY_Predicted);
i_nan = isnan(Warped_Original_Image);
Warped_Original_Image(i_nan) = 0;

% Apply nearest neighbor interpolation to label image.
if  ~isempty(Previous_Label_Map)
    Warped_Label_Map = interp2(XX, YY, Previous_Label_Map, ...
        XX_Predicted, YY_Predicted, 'nearest');
    i_nan = isnan(Warped_Label_Map);
    Warped_Label_Map(i_nan) = 0;
else
    Warped_Label_Map = [];
end
% Display results.
if parameters.display
    figure(1); LineColor = 'w';
    set(gcf, 'Units','Normalized','OuterPosition',[0 0 0.8 0.8]);
    subplot(231), imagesc(Previous_Frame); axis('image', 'off');
    colormap gray; title(['Frame #', num2str(frame_index-1)]); hold on;
    [Ox,Oy] = vis_flow(UV(:,:,1),UV(:,:,2)); axis('image', 'off');
    
    subplot(232), imagesc(Current_Frame); axis('image', 'off');
    colormap gray; title(['Frame #', num2str(frame_index)]); hold on;
    %[Ox,Oy] = vis_flow(UV(:,:,1),UV(:,:,2)); axis('image', 'off');
    
    subplot(233), imagesc(Warped_Original_Image); axis('image', 'off');
    colormap gray; title(['Warped frame #', num2str(frame_index-1)]); hold on;
    %[Ox,Oy] = vis_flow(UV(:,:,1),UV(:,:,2)); axis('image', 'off');

    subplot(234); imagesc(uint8(flowToColor(UV))); axis('image' , 'off');
    title('Middlebury color coding');
    if ~(isempty(Previous_Label_Map) || isempty(Current_Label_Map))
        subplot(235), imagesc(Current_Label_Map-Previous_Label_Map), axis('image', 'off');  colormap gray;
        title('Reference motion');
        subplot(236), imagesc(Warped_Label_Map-Previous_Label_Map), axis('image', 'off');  colormap gray;
        title('Computed motion');
    end
end
end
