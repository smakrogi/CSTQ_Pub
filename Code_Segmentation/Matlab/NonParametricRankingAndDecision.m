function region_ids = NonParametricRankingAndDecision(Joint_Measure, cdf_threshold, Params)

% Use MAM and Area to determine the background.
motion_activity = Joint_Measure(:,2);
[~, idx_sorted_motion_activity] = sort(motion_activity);

area = Joint_Measure(:,1);
[~, idx_sorted_area] = sort(area);

motion_field_mag = Joint_Measure(:,3);
[~, idx_sorted_motion_field_mag] = sort(motion_field_mag);

% Rank and compute cdf.
motion_activity_rank = zeros(size(idx_sorted_motion_activity));
area_rank = zeros(size(idx_sorted_motion_activity));
for ii=1:numel(idx_sorted_motion_activity)
    motion_activity_rank(idx_sorted_motion_activity(ii)) = ii;
    area_rank(idx_sorted_area(ii)) = ii;
    motion_field_mag_rank(idx_sorted_motion_field_mag(ii)) = ii;
end

% Percentiles.
motion_activity_rank_percentile = motion_activity_rank /  ...
    numel(idx_sorted_motion_activity);

area_rank_percentile = area_rank /  ...
    numel(idx_sorted_motion_activity);

motion_field_mag_percentile = motion_field_mag_rank / ...
    numel(idx_sorted_motion_field_mag);

% % Combine criteria: low MAM and larger area.
motion_activity_test_foreground = (motion_activity_rank_percentile > cdf_threshold);
area_test_foreground = (area_rank_percentile <= cdf_threshold);
motion_field_mag_test_foreground = (motion_field_mag_percentile > cdf_threshold);
region_ids = (motion_activity_test_foreground & area_test_foreground & motion_field_mag_test_foreground);

% Apply joint cdf test.
% joint_percentile = motion_activity_rank_percentile .* area_rank_percentile;
% region_ids = (joint_percentile > cdf_threshold);

end