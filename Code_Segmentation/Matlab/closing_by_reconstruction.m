function Icbr = closing_by_reconstruction(I, se_size)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

se = strel('disk',se_size);
Id = imdilate(I,se);
Icbr = imreconstruct(imcomplement(Id),imcomplement(I));
Icbr = imcomplement(Icbr);

end
