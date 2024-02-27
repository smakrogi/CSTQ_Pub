function h = DisplayTensor(InputTensor)

tensorSize = size(InputTensor);
CompositeMatrix = cell(numel(tensorSize), 1);
for i=1:tensorSize(3)
    for j=1:tensorSize(4)
        CompositeMatrix{sub2ind([3 3], j, i)} = InputTensor(:,:,i,j);
    end
end
h = figure; imagesc(imtile(CompositeMatrix)); colorbar; axis image;
end