function [Displacement_Field_Mag, UV] = Compute_and_Apply_Displacement_Field_Mag(Previous_Frame, Current_Frame, frame_index, Params)

Params.display = false;

[~, UV] = Compute_and_Apply_Displacement_Field(Previous_Frame, ...
    Current_Frame, [], [], frame_index, Params);

Displacement_Field_Mag = sum(UV.^2, 3);
Displacement_Field_Mag = sqrt(Displacement_Field_Mag);
Displacement_Field_Mag = Displacement_Field_Mag /max(Displacement_Field_Mag(:));

end