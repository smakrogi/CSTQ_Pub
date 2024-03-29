function plotting(Nom,Dice_Res_k,seg,Ref_data_marker,iter_to_converge,ST_diff) 
  figure,subplot(3,1,1);imagesc(Ref_data_marker);axis ('image','off');
  
  subplot(3,1,2);imagesc(ST_diff);axis ('image','off');
  subplot(3,1,3);       imagesc(seg);
  titlestring     = ['Ref, ST and ST_CV   ', Nom,' DICE =  ',num2str(Dice_Res_k),iter_to_converge];
  title(titlestring,'color','k');
  axis ('image','off');
end
