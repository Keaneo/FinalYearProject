function plot_spikes(region, region_name, s, start_time, end_time, row_offset)
    line_data = [];

    field_names = fieldnames(region);
    for k = 1:numel(field_names)
        cluster_struct = region.(field_names{k});
        cluster_field_names = fieldnames(cluster_struct);
    
        cluster_name = cluster_field_names{2};
        cluster_vector = cluster_struct.(cluster_name);

        num_elements = numel(cluster_vector);
        for i = 1:num_elements
            if cluster_vector(i) >= start_time && cluster_vector(i) <= end_time
                line_data = [line_data; cluster_vector(i) k + row_offset k + 1 + row_offset];
            end
        end
    end

    plot([line_data(:, 1) line_data(:, 1)]', [line_data(:, 2) line_data(:, 3)]', 'k-');

    
end
