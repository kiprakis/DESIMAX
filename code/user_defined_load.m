function[new_load_locs, new_load] = user_defined_load(agg_size,...
                                                 data_dir, ...
                                                 new_load_data, ...
                                                 filename)

% Add a user defined load. Two different user definitions are accounted
% for: 1 - one load profile with power demand defined from uniform
% distribution and a set penetration level, 2 - multiple individual load
% profiles. The new loads are randomly allocated within the total
% population.
%
% Args:
%   agg_size (int) [-]: The total number of households to be created.
%   data_dir (str) [-]: Path to the data directory.
%   new_load_data (array) [-]: Overview of the new load electrical data.
%   filename (str) [-]: Filename of load definition.
%
% Returns:
%   new_load_locs (array) [-]: Household number to which the new load is
%      assigned.
%   new_load (cell) [-]: DataStructure to carry all new load electrical
%       characteristics.

new_load_type = new_load_data(1);

if new_load_type == 1
   
    new_load_electrical_data = xlsread(...
    strjoin({data_dir, filename},''),  'electrical', 'B3..I1442');
    
    % how many loads
    new_load_penetration = new_load_data(2);
    
    n_new_loads = round(agg_size*new_load_penetration);
    
    default_p = new_load_electrical_data(:,1);
    default_q = new_load_electrical_data(:,2);

    % make it fuzzy
    new_load_fuzzy_p_min = new_load_data(3);
    new_load_fuzzy_p_max = new_load_data(4);
    new_load_fuzzy_q_min = new_load_data(5);
    new_load_fuzzy_q_max = new_load_data(6);

    r_p = new_load_fuzzy_p_min + ...
        (new_load_fuzzy_p_max-new_load_fuzzy_p_min).*rand(n_new_loads,1);
    r_q = new_load_fuzzy_q_min + ...
        (new_load_fuzzy_q_max-new_load_fuzzy_q_min).*rand(n_new_loads,1);

    new_load = cell(n_new_loads,1);

    for i = 1:n_new_loads
        new_loads_data(:,1) = default_p.*r_p(i);
        new_loads_data(:,2) = default_q.*r_q(i);
        new_loads_data(:,3:5) = new_load_electrical_data(:,3:5);
        new_loads_data(:,6:8) = new_load_electrical_data(:,6:8);
        new_load{i} = new_loads_data;
    end

elseif new_load_type == 2

    [~, sheets] = xlsfinfo(strjoin({data_dir, 'new_load_two.xlsx'},'')); 
    % find electrical sheets
    idx = strfind(sheets, 'electrical');
    idx = find(not(cellfun('isempty', idx)));
    n_new_loads = length(idx);

    new_load = cell(n_new_loads,1);
    
    i = 1;
    for a = idx
        new_load{i} = xlsread(...
    strjoin({data_dir, 'new_load_two.xlsx'},''),  sheets{a}, 'B2..I1441');
    i=i+1;
    end
end

% randomly assign to household
new_load_locs = sort(randperm(agg_size, n_new_loads));

end