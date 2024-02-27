function mean_dice_jaccard=Get_Mean_dice_jaccard(dice_jaccard_name)
    mean_dice=0;
    mean_jaccard=0;
    % if excel exist
    if exist(dice_jaccard_name) ==2
        T = readtable(dice_jaccard_name,'ReadRowNames',false);
    
        %Cal mean dice
        mean_dice=mean(nonzeros(table2array(T(:,1))));
        %Cal mean jaccard
        mean_jaccard=mean(nonzeros(table2array(T(:,2))));
    % not exist mean_dice mean jacard
    else
        disp('no mean dice jaccard found');
    end
    %Result
    mean_dice_jaccard={mean_dice,mean_jaccard};
end