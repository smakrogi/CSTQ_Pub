function Dynamic_Cell_Features = Compute_Dynamic_Cell_Features(CentroidX, CentroidY, cell_label)

% Pass the cell label.
Dynamic_Cell_Features.Cell_Label = cell_label;

% For the given cell compute:
% Lifetime.
Dynamic_Cell_Features.Life_Time = length(CentroidX);
nPoints = length(CentroidX);
i_previous=[1,1:nPoints-1];
i=1:nPoints;
D_CentroidX = CentroidX(i) - CentroidX(i_previous);
D_CentroidY = CentroidY(i) - CentroidY(i_previous);
Squared_Distance = D_CentroidX.^2 + D_CentroidY.^2;

% Total distance traveled.
Dynamic_Cell_Features.Total_Traveled_Distance = sum(sqrt(Squared_Distance));

% Net distance traveled.
Dynamic_Cell_Features.Net_Traveled_Distance = ...
    sqrt((CentroidX(end) - CentroidX(1))^2 + (CentroidY(end) - CentroidY(1))^2);

% Confinement.
% Mean squared displacement
Dynamic_Cell_Features.MSD_Function = Compute_MSD(CentroidX, CentroidY);

Dynamic_Cell_Features.Mean_MSD = mean(Dynamic_Cell_Features.MSD_Function);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MSD_Vector = Compute_MSD(CentroidX, CentroidY)
% Calculate MSD for one cell.
nPoints = length(CentroidX);
MSD_Vector = zeros(1, nPoints-1);
i = 1:nPoints;
for alpha=1:nPoints-1
    D_CentroidX = [];
    D_CentroidY = [];
    valid_i_next = (i + alpha) <= nPoints;
    i_next_step = alpha*(valid_i_next);
    i_next = i + i_next_step;
    D_CentroidX = CentroidX(i_next) - CentroidX(i);
    D_CentroidY = CentroidY(i_next) - CentroidY(i);
    Squared_Distance = D_CentroidX.^2 + D_CentroidY.^2;
    MSD_Vector(alpha) = sum(Squared_Distance) / ...
       (nPoints-alpha);
end

end
