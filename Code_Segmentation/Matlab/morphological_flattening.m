function Iobrcbr = morphological_flattening(I, se_size)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

se = strel('disk',se_size);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

end
