function [distr, ...
          distr_q, ...
          p_zips, ...
          q_zips] = appliance_population(time_res, ...
                                     n_occ, ...
                                     tv_stuff, ...
                                     settop_box, ...
                                     printer, ...
                                     music, ...
                                     router, ...
                                     phone, ...
                                     cooking, ...
                                     iron, ...
                                     vacuum, ...
                                     shower, ...
                                     dishwasher, ...
                                     washingmachine, ...
                                     clothesdrier, ...
                                     gamesconsole, ...
                                     computers, ...
                                     monitors, ...
                                     heating, ...
                                     cold_loads, ...
                                     ev)

% Generate household loads. Appliances are selected based on the ownership
% statistics defined in the input configuration files. Each appliance is
% assigned relevant electrical characteristics, which include: operating
% power, power factor, standby power and electrical load model.
% Auxililiary/dependent loads, e.g. computer monitors, are only assigned if
% the primary load is present. Loads with operating cycles, i.e. wet loads,
% are given a unique operating cycle to introduce further diversity in the
% appliance set. The power and duration of each stage of the operating
% cycle is selected from a uniform distribution from the given input data.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   n_occ (int) [-]: The number of occupants in the household;
%   tv_stuff (array) [-]: TV load specification;
%   settop_box (array) [-]: Set-top box load specification;
%   printer (array) [-]: Printer load specification;
%   music (array) [-]: Music player load specification;
%   router (array) [-]: Router load specification;
%   phone (array) [-]: Phone load specification;
%   cooking (array) [-]: Cooking loads specification;
%   iron (array) [-]: Iron load specification;
%   vacuum (array) [-]: Vacuum cleaner load specification;
%   shower (array) [-]: Shower load specification;
%   dishwasher (array) [-]: Dishwasher load specification;
%   washingmachine (array) [-]: Washing machine load specification;
%   clothesdrier (array) [-]: Clothes drier load specification;
%   gamesconsole (array) [-]: Games console loads specification;
%   computers (array) [-]: Computer loads specification;
%   monitors (array) [-]: Monitor loads specification;
%   heating (array) [-]: Heating loads specification;
%   cold_loads (array) [-]: Cold loads specification;
%   ev (array) [-]: EV load specification.
%
% Returns:
%   distr (cell) []: DataStructure to hold the active power characteristics
%       of household appliances;
%   distr_q (cell) []: DataStructure to hold the reactive power 
%       characteristics of household appliances;
%   p_zips (cell) []: DataStructure to hold the active power ZIP models for
%       household appliances
%   q_zips (cell) []: DataStructure to hold the reactive power ZIP models
%       for household appliances

% Initiliase this var here
distr = cell(1,35);
distr{1} = zeros(n_occ,1);
distr{2} = distr{1};

distr_q = cell(1,35);
distr_q{1} = zeros(n_occ,1);
distr_q{2} = distr_q{1};

p_zips=cell(1,35);

q_zips=cell(1,35);

%% Wet loads
% app 3 is washing machine p col 6
% app 4 is tumble drier p col 27
% app5 is dishwasher p col 4
wet_cycles = cell(3,1);
wet_cycles_q = cell(3,1);
for app = {'dishwasher', 'washingmachine', 'clothesdrier'}
    
    wetload = app{1};
    switch wetload
        case 'dishwasher'
            cycle_stages_power_min = dishwasher(:,1);
            cycle_stages_power_max = dishwasher(:,2);
            cycle_stages_duration_min = dishwasher(:,3);
            cycle_stages_duration_max = dishwasher(:,4);
            wet_model = dishwasher(:,6:11);
            cycle_stages_pfs =dishwasher(:,5);
            n_stages = size(cycle_stages_pfs);
            app_id = 5;
            app_id2 = 4;
        case 'washingmachine'
            cycle_stages_power_min = washingmachine(:,1);
            cycle_stages_power_max = washingmachine(:,2);
            cycle_stages_duration_min = washingmachine(:,3);
            cycle_stages_duration_max = washingmachine(:,4);
            wet_model = washingmachine(:,6:11);
            cycle_stages_pfs =washingmachine(:,5);
            n_stages = size(cycle_stages_pfs);
            app_id = 3;
            app_id2 = 6;
        case 'clothesdrier'
            cycle_stages_power_min = clothesdrier(:,1);
            cycle_stages_power_max = clothesdrier(:,2);
            cycle_stages_duration_min = clothesdrier(:,3);
            cycle_stages_duration_max = clothesdrier(:,4);
            wet_model = clothesdrier(:,6:11);
            cycle_stages_pfs =clothesdrier(:,5);
            n_stages = size(cycle_stages_pfs);
            app_id = 4;
            app_id2 = 27;
    end
    
    wet_load_p = [];
    wet_load_q = [];
    wet_load_models = [];
    
    x=0;
    
    for i = 1 : n_stages
        
        stage_duration = randi([cycle_stages_duration_min(i), ...
            cycle_stages_duration_max(i)]);
        stage_power = randi([cycle_stages_power_min(i), ...
            cycle_stages_power_max(i)]);
        
        stage_pf = cycle_stages_pfs(i);
        stage_models = wet_model(i,:);
        stage_q_power = stage_power * tan(acos(stage_pf));
        
        wet_load_p(x+1:x+stage_duration) = stage_power;
        wet_load_q(x+1:x+stage_duration) = stage_q_power;
        
        for j = x+1:x+stage_duration
            wet_load_models(j,:) = stage_models;
        end
        
        x = x + stage_duration;
        
    end
    
    wet_cycles{app_id-2,1}(:,1) = wet_load_p;
    wet_cycles_q{app_id-2,1}(:,1) = wet_load_q;

    % assign model to correct idx
    
    p_zips{app_id2} = wet_load_models(:, 1:3);
    q_zips{app_id2} = wet_load_models(:, 4:6);
    
end

distr{16}{1,1} = wet_cycles;

distr_q{16} = wet_cycles_q;

%% TV
tv_type1_probability = tv_stuff(1,2); % These are cumulative probabilities
tv_type2_probability = tv_stuff(2,2); 
tv_type3_probability = tv_stuff(3,2); 
tv_type4_probability = tv_stuff(4,2);

tv_type1_mean = tv_stuff(1,3);
tv_type1_sigma = tv_stuff(1,4);
tv_type1_min = tv_stuff(1,5);
tv_type1_max = tv_stuff(1,6);
tv_type1_pf = tv_stuff(1,7);
tv_type1_standby_min = tv_stuff(1,8);
tv_type1_standby_max = tv_stuff(1,9);
tv_type1_p_zip(1,1) = tv_stuff(1,10);
tv_type1_p_zip(1,2) = tv_stuff(1,11);
tv_type1_p_zip(1,3) = tv_stuff(1,12);
tv_type1_q_zip(1,1) = tv_stuff(1,13);
tv_type1_q_zip(1,2) = tv_stuff(1,14);
tv_type1_q_zip(1,3) = tv_stuff(1,15);

tv_type2_mean = tv_stuff(2,3);
tv_type2_sigma = tv_stuff(2,4);
tv_type2_min = tv_stuff(2,5);
tv_type2_max = tv_stuff(2,6);
tv_type2_pf = tv_stuff(2,7);
tv_type2_standby_min = tv_stuff(2,8);
tv_type2_standby_max = tv_stuff(2,9);
tv_type2_p_zip(1,1) = tv_stuff(2,10);
tv_type2_p_zip(1,2) = tv_stuff(2,11);
tv_type2_p_zip(1,3) = tv_stuff(2,12);
tv_type2_q_zip(1,1) = tv_stuff(2,13);
tv_type2_q_zip(1,2) = tv_stuff(2,14);
tv_type2_q_zip(1,3) = tv_stuff(2,15);

tv_type3_mean = tv_stuff(3,3);
tv_type3_sigma = tv_stuff(3,4);
tv_type3_min = tv_stuff(3,5);
tv_type3_max = tv_stuff(3,6);
tv_type3_pf = tv_stuff(3,7);
tv_type3_standby_min = tv_stuff(3,8);
tv_type3_standby_max = tv_stuff(3,9);
tv_type3_p_zip(1,1) = tv_stuff(3,10);
tv_type3_p_zip(1,2) = tv_stuff(3,11);
tv_type3_p_zip(1,3) = tv_stuff(3,12);
tv_type3_q_zip(1,1) = tv_stuff(3,13);
tv_type3_q_zip(1,2) = tv_stuff(3,14);
tv_type3_q_zip(1,3) = tv_stuff(3,15);

tv_type4_mean = tv_stuff(4,3);
tv_type4_sigma = tv_stuff(4,4);
tv_type4_min = tv_stuff(4,5);
tv_type4_max = tv_stuff(4,6);
tv_type4_pf = tv_stuff(4,7);
tv_type4_standby_min = tv_stuff(4,8);
tv_type4_standby_max = tv_stuff(4,9);
tv_type4_p_zip(1,1) = tv_stuff(4,10);
tv_type4_p_zip(1,2) = tv_stuff(4,11);
tv_type4_p_zip(1,3) = tv_stuff(4,12);
tv_type4_q_zip(1,1) = tv_stuff(4,13);
tv_type4_q_zip(1,2) = tv_stuff(4,14);
tv_type4_q_zip(1,3) = tv_stuff(4,15);

for i=1:n_occ
    tv=rand(1);
    if tv <= tv_type1_probability
        
        tv1_power = randn(1)*tv_type1_sigma + tv_type1_mean; % sets the P
        tv1_power(tv1_power<tv_type1_min) = tv_type1_min; % cap min
        tv1_power(tv1_power>tv_type1_max) = tv_type1_max; % cap max
        tv1_power_standby = randi([tv_type1_standby_min, ...
            tv_type1_standby_max]);
        tv1_q_power = tv1_power * tan(acos(tv_type1_pf));
        tv1_q_power_standby = tv1_power_standby * tan(acos(tv_type1_pf));
        
        distr{1}(i,1) = tv1_power;
        distr{1}(i,3) = tv_type1_pf;
        
        distr{2}(i) = tv1_power_standby;
        
        distr_q{1}(i,1) = tv1_q_power;
        distr_q{1}(i,1) = tv1_q_power_standby;
        
        p_zips{18+i}(1:3) = tv_type1_p_zip;
        q_zips{18+i}(1:3) = tv_type1_q_zip;
        
    elseif tv <= tv_type2_probability
        
        tv2_power = randn(1)*tv_type2_sigma + tv_type2_mean; % sets the P
        tv2_power(tv2_power<tv_type2_min) = tv_type2_min; % cap min
        tv2_power(tv2_power>tv_type2_max) = tv_type2_max; % cap max
        tv2_power_standby = randi([tv_type2_standby_min, ...
            tv_type2_standby_max]);
        
        distr{1}(i,1) = tv2_power;
        distr{2}(i,1) = tv2_power_standby;
        distr{1}(i,3) = tv_type2_pf;
        
        tv2_q_power = tv2_power * tan(acos(tv_type2_pf));
        tv2_q_power_standby = tv2_power_standby * tan(acos(tv_type2_pf));
        
        distr_q{1}(i,1) = tv2_q_power;
        distr_q{2}(i,1) = tv2_q_power_standby;
        
        p_zips{18+i}(1:3) = tv_type2_p_zip;
        q_zips{18+i}(1:3) = tv_type2_q_zip;
        
    elseif tv <= tv_type3_probability
        
        tv3_power = randn(1)*tv_type3_sigma + tv_type3_mean; % sets the P
        tv3_power(tv3_power<tv_type3_min) = tv_type3_min; % cap min
        tv3_power(tv3_power>tv_type3_max) = tv_type3_max; % cap max
        tv3_power_standby = randi([tv_type3_standby_min, ...
            tv_type3_standby_max]);
        
                distr{1}(i,1) = tv3_power;
                distr{2}(i,1) = tv3_power_standby;

        tv3_q_power = tv3_power * tan(acos(tv_type3_pf));
        tv3_q_power_standby = tv3_power_standby * tan(acos(tv_type3_pf));
        
        distr{1}(i,3) = tv_type3_pf;
        distr_q{1}(i,1) = tv3_q_power;
        distr_q{2}(i,1) = tv3_q_power_standby;
        p_zips{18+i}(1:3) = tv_type3_p_zip;
        q_zips{18+i}(1:3) = tv_type3_q_zip;
        
    else
        
        tv4_power = randn(1)*tv_type4_sigma + tv_type4_mean; % sets the P
        tv4_power(tv4_power<tv_type4_min) = tv_type4_min; % cap min
        tv4_power(tv4_power>tv_type4_max) = tv_type4_max; % cap max
        tv4_power_standby = randi([tv_type4_standby_min, ...
            tv_type4_standby_max]);
        
        tv4_q_power = tv4_power * tan(acos(tv_type4_pf));
        tv4_q_power_standby = tv4_power_standby * tan(acos(tv_type4_pf));
        
        distr{1}(i,1) = tv4_power;
        distr{1}(i,3) = tv_type4_pf;
        distr{2}(i) = tv4_power_standby;
        
        distr_q{1}(i,1) = tv4_q_power;
        distr_q{2}(i,1) = tv4_q_power_standby;
        p_zips{18+i}(1:3) = tv_type4_p_zip;
        q_zips{18+i}(1:3) = tv_type4_q_zip;
    end
end

%% Set-top box
set_top_box_power_min = settop_box(1, 5);
set_top_box_power_max = settop_box(1, 6);
set_top_box_standby_power_min = settop_box(1, 8);
set_top_box_standby_power_max = settop_box(1, 9);
set_top_box_pf = settop_box(1, 7);
set_top_box_p_zip(1,1) = settop_box(1, 10);
set_top_box_p_zip(1,2) = settop_box(1, 11);
set_top_box_p_zip(1,3) = settop_box(1, 12);

set_top_box_q_zip(1,1) = settop_box(1, 13);
set_top_box_q_zip(1,2) = settop_box(1, 14);
set_top_box_q_zip(1,3) = settop_box(1, 15);

set_top_box_power = randi([set_top_box_power_min, set_top_box_power_max]);
set_top_box_standby_power = randi([set_top_box_standby_power_min, ...
    set_top_box_standby_power_max]);

set_top_box_q_power = set_top_box_power * tan(acos(set_top_box_pf));
set_top_box_standby_q_power = ...
    set_top_box_standby_power * tan(acos(set_top_box_pf));

distr{3}(1) = set_top_box_power;
distr{4}(1) = set_top_box_standby_power;
distr_q{3}(1) = set_top_box_q_power;
distr_q{4}(1) = set_top_box_standby_q_power;
p_zips{23}(1:3) = set_top_box_p_zip;
q_zips{23}(1:3) = set_top_box_q_zip;

%% PCs and monitors
pc_val1 = computers(1,2);

laptop_val1 = computers(2,2);
laptop_val2 = computers(3,2);
laptop_val3 = computers(4,2);

pc_load_mean = computers(1,16); % in percent
pc_load_sigma = computers(1,17); % in percent
pc_load_min = computers(1,18); % in percent
pc_load_max = computers(1,19); % in percent
pc_rated_power = computers(1,3);
pc_standby_power_min = computers(1,8); 
pc_standby_power_max = computers(1,9);
pc_p_zip = computers(1,10:12);
pc_q_zip = computers(1,13:15);
pc_power_factor = computers(1,7);

for i = 1:n_occ
    
    if rand(1) > pc_val1
        
        monitor = 1; % True
        
        pc_load = randn(1)*pc_load_sigma + pc_load_mean; % sets the power
        pc_load(pc_load<pc_load_min) = pc_load_min; % cap min
        pc_load(pc_load>pc_load_max) = pc_load_max; % cap max
        
        pc_power = pc_load * pc_rated_power/100; %move below - or all 500W?
        distr{5}(i,1) = pc_power;
        distr{5}(i,3) = pc_power_factor;

        pc_standby_power = randi([pc_standby_power_min, ...
            pc_standby_power_max]);
        distr{6}(i,1) = pc_standby_power;
        
        pc_q_power = pc_power * tan(acos(pc_power_factor));
        pc_q_power_standby = pc_standby_power * tan(acos(pc_power_factor));
        
        distr_q{5}(i,1) = pc_q_power;
        distr_q{6}(i,1) = pc_q_power_standby;
        p_zips{7+i}(1:3) = pc_p_zip;
        q_zips{7+i}(1:3) = pc_q_zip;
        
    else
        
        monitor = 0; % False
        lap = rand(1);
        laptop_power_mean = 58;
        laptop_power_sigma = 20;
        
        if lap < laptop_val1
            
            Plow = computers(2,5);
            Phigh = computers(2,6);
            Plow_standby = computers(2,8);
            Phigh_standby = computers(2,9);
            pf = computers(2,7);
            pc_p_zip = computers(2,10:12);
            pc_q_zip = computers(2,13:15);

        elseif lap < laptop_val2
            
            Plow = computers(3,5);
            Phigh = computers(3,6);
            Plow_standby = computers(3,8);
            Phigh_standby = computers(3,9);
            pf = computers(3,7);
            pc_p_zip = computers(3,10:12);
            pc_q_zip = computers(3,13:15);

        else
            
            Plow = computers(4,5);
            Phigh = computers(4,6);
            Plow_standby = computers(4,8);
            Phigh_standby = computers(4,9);
            pf = computers(4,7);
            pc_p_zip = computers(4,10:12);
            pc_q_zip = computers(4,13:15);

        end
        
        laptop_power = randn(1)*laptop_power_sigma + laptop_power_mean;
        laptop_power(laptop_power<Plow) = Plow; % cap min
        laptop_power(laptop_power>Phigh) = Phigh; % cap max
        laptop_standby_power = randi([Plow_standby, Phigh_standby]);
        distr{5}(i,1) = laptop_power;
        distr{5}(i,3) = pf;

        distr{6}(i,1) = laptop_standby_power;
        
        laptop_q_power = laptop_power * tan(acos(pf));
        laptop_q_standby_power = laptop_standby_power * tan(acos(pf));
        
        distr_q{5}(i,1) = laptop_q_power;
        distr_q{6}(i,1) = laptop_q_standby_power;
        p_zips{7+i}(1:3) = pc_p_zip;
        q_zips{7+i}(1:3) = pc_q_zip;
    end
    
    if monitor == 1
        
        monitor_val1 = monitors(1,2);
        
        if (rand(1) < monitor_val1)
            
            monitor_power_mean = monitors(1,3);
            monitor_power_sigma = monitors(1,4);
            monitor_power_min = monitors(1,5);
            monitor_power_max = monitors(1,6);
            monitor_standby_min = monitors(1,8);
            monitor_standby_max = monitors(1,9);
            monitor_pf = monitors(1,7);
            monitor_p_zip = monitors(1,10:12);
            monitor_q_zip = monitors(1,13:15);
            
        else
            
            monitor_power_mean = monitors(2,3);
            monitor_power_sigma = monitors(2,4);
            monitor_power_min = monitors(2,5);
            monitor_power_max = monitors(2,6);
            monitor_standby_min = monitors(2,8);
            monitor_standby_max = monitors(2,9);
            monitor_pf = monitors(2,7);
            monitor_p_zip = monitors(2,10:12);
            monitor_q_zip = monitors(2,13:15);
        end
        
        monitor_power = randn(1)*monitor_power_sigma + monitor_power_mean;
        monitor_power(monitor_power<monitor_power_min) = monitor_power_min;
        monitor_power(monitor_power>monitor_power_max) = monitor_power_max;
        
        monitor_standby_power = randi([monitor_standby_min, ...
            monitor_standby_max]);
        
        distr{7}(i,1) = monitor_power;
        distr{8}(i,1) = monitor_standby_power;
        p_zips{11+i}(1:3) = monitor_p_zip;
        q_zips{11+i}(1:3) = monitor_q_zip;
        
        monitor_q_power = monitor_power * tan(acos(monitor_pf));
        monitor_q_power_standby = ...
            monitor_standby_power * tan(acos(monitor_pf));
        
        distr_q{7}(i,1) = monitor_q_power;
        distr_q{8}(i,1) = monitor_q_power_standby;
        
        
    else % set all as zero
        
        distr{7}(i,1) = 0;
        distr{7}(i,2) = 0;
        distr{8}(i,1) = 0;
        
        distr_q{7}(i,1) = 0;
        distr_q{8}(i,1) = 0;
        
    end
end

%% Printers
printer_on_min = printer(1,5);
printer_on_max = printer(1,6);
printer_standby_min = printer(1,8);
printer_standby_max = printer(1,9);
printer_pf = printer(1,7);
printer_p_zip(1,1) = printer(1,10);
printer_p_zip(1,2) = printer(1,11);
printer_p_zip(1,3) = printer(1,12);

printer_q_zip(1,1) = printer(1,13);
printer_q_zip(1,2) = printer(1,14);
printer_q_zip(1,3) = printer(1,15);

printer_on_power = randi([printer_on_min, printer_on_max]);
printer_standby_power = randi([printer_standby_min, printer_standby_max]);

printer_on_q_power = printer_on_power * tan(acos(printer_pf));
printer_standby_q_power = printer_standby_power * tan(acos(printer_pf));

distr{21}(1,1) = printer_on_power;
distr{21}(1,2) = printer_standby_power;
distr_q{21}(1,1) = printer_on_q_power;
distr_q{21}(1,2) = printer_standby_q_power;
p_zips{16}(1:3) = printer_p_zip;
q_zips{16}(1:3) = printer_q_zip;

%% Music
music_power_mean = music(1,3); 
music_power_sigma = music(1,4);
music_power_min = music(1,5);
music_power_max = music(1,6);
music_standby_power_min = music(1,8);
music_standby_power_max = music(1,9);
music_pf = music(1,7);
music_p_zip(1,1) = music(1,10);
music_p_zip(1,2) = music(1,11);
music_p_zip(1,3) = music(1,12);
music_q_zip(1,1) = music(1,13);
music_q_zip(1,2) = music(1,14);
music_q_zip(1,3) = music(1,15);

music_power = randn(1)*music_power_sigma + music_power_mean; % sets the P
music_power(music_power<music_power_min) = music_power_min; % cap min
music_power(music_power>music_power_max) = music_power_max; % cap max
music_standby_power = ...
    randi([music_standby_power_min, music_standby_power_max]);

music_on_q_power = music_power * tan(acos(music_pf));
music_standby_q_power = music_standby_power * tan(acos(music_pf));

distr{9}(1) = music_power;
distr{10}(1) = music_standby_power;
distr_q{9}(1) = music_on_q_power;
distr_q{10}(1) = music_standby_q_power;
p_zips{24}(1:3) = music_p_zip;
q_zips{24}(1:3) = music_q_zip;

%% Iron
iron_power_mean = iron(1,3);
iron_power_sigma = iron(1,4);
iron_power_min = iron(1,5);
iron_power_max = iron(1,6);
iron_pf = iron(1,7);
iron_p_zip(1,1) = iron(1,10);
iron_p_zip(1,2) = iron(1,11);
iron_p_zip(1,3) = iron(1,12);
iron_q_zip(1,1) = iron(1,13);
iron_q_zip(1,2) = iron(1,14);
iron_q_zip(1,3) = iron(1,15);

iron_power = randn(1)*iron_power_sigma + iron_power_mean; % sets the power
iron_power(iron_power<iron_power_min) = iron_power_min; % cap min
iron_power(iron_power>iron_power_max) = iron_power_max; % cap max

iron_q_power = iron_power * tan(acos(iron_pf));

distr{11}(1) = iron_power * 10;
distr_q{11}(1) = iron_q_power * 10;
p_zips{7}(1:3) = iron_p_zip;
q_zips{7}(1:3) = iron_q_zip;

%% Vacuum cleaner
vacuum_cleaner_val1 = 0.063;
vacuum_cleaner_val2 = 0.85;
vacuum_cleaner_combined = vacuum_cleaner_val1 *vacuum_cleaner_val2;

vacuum_cleaner_prob = vacuum(1,2);

if rand(1) >= vacuum_cleaner_prob
    
    vacuum_cleaner_mean = vacuum(1,3); 
    vacuum_cleaner_power_sigma = vacuum(1,4);
    vacuum_cleaner_power_min = vacuum(1,5);
    vacuum_cleaner_power_max = vacuum(1,6);
    vacuum_cleaner_pf = vacuum(1,7);
    vacuum_cleaner_p_zip(1,1) = vacuum(1,10);
    vacuum_cleaner_p_zip(1,2) = vacuum(1,11);
    vacuum_cleaner_p_zip(1,3) = vacuum(1,12);
    vacuum_cleaner_q_zip(1,1) = vacuum(1,13);
    vacuum_cleaner_q_zip(1,2) = vacuum(1,14);
    vacuum_cleaner_q_zip(1,3) = vacuum(1,15);
    
    vacuum_cleaner_power = ...
        randn(1)*vacuum_cleaner_power_sigma + vacuum_cleaner_mean; % sets P
    vacuum_cleaner_power(vacuum_cleaner_power<vacuum_cleaner_power_min)=...
        vacuum_cleaner_power_min; % cap min
    vacuum_cleaner_power(vacuum_cleaner_power>vacuum_cleaner_power_max)=...
        vacuum_cleaner_power_max; % cap max
    
    vacuum_cleaner_q_power = ...
        vacuum_cleaner_power * tan(acos(vacuum_cleaner_pf));
    
    distr{12}(1) = vacuum_cleaner_power * 100; 
    distr_q{12}(1) = vacuum_cleaner_q_power * 100;
    p_zips{5}(1:3) = vacuum_cleaner_p_zip;
    q_zips{5}(1:3) = vacuum_cleaner_q_zip;
    
else
    distr{12}(1) = 0;
    distr_q{12}(1) = 0;
end

%% Router
router_val = router(1,2);

if rand(1) >= router_val
    
    router_power_mean = router(1,3);
    router_power_sigma = router(1,4);
    router_power_min = router(1,5);
    router_power_max = router(1,6);
    router_pf = router(1,7);
    router_p_zip(1,1) = router(1,10);
    router_p_zip(1,2) = router(1,11);
    router_p_zip(1,3) = router(1,12);
    router_q_zip(1,1) = router(1,13);
    router_q_zip(1,2) = router(1,14);
    router_q_zip(1,3) = router(1,15);
    
    router_power = randn(1)*router_power_sigma + router_power_mean; % set P
    router_power(router_power<router_power_min) = router_power_min; % min
    router_power(router_power>router_power_max) = router_power_max; % max
    
    router_q_power = router_power * tan(acos(router_pf));
    
    distr{13}(1) = router_power;
    distr_q{13}(1) = router_q_power;
    p_zips{25}(1:3) = router_p_zip;
    q_zips{25}(1:3) = router_q_zip;
    
else
    distr{13}(1) = 0;
    distr_q{13}(1) = 0;
end

%% Electric shower
shower_power_mean = shower(1,3); 
shower_power_sigma = shower(1,4);
shower_power_min = shower(1,5); 
shower_power_max = shower(1,6);
shower_pf = shower(1,7);
shower_p_zip(1,1) = shower(1,10);
shower_p_zip(1,2) = shower(1,11);
shower_p_zip(1,3) = shower(1,12);
shower_q_zip(1,1) = shower(1,13);
shower_q_zip(1,2) = shower(1,14);
shower_q_zip(1,3) = shower(1,15);

shower_power = randn(1)*shower_power_sigma + shower_power_mean; % sets P
shower_power(shower_power<shower_power_min) = shower_power_min; % cap min
shower_power(shower_power>shower_power_max) = shower_power_max; % cap max

shower_power = 4000 + shower_power*500;
shower_q_power = shower_power * tan(acos(shower_pf));
distr{14}(1) = shower_power;
distr_q{14}(1) = shower_q_power;
p_zips{1}(1:3) = shower_p_zip;
q_zips{1}(1:3) = shower_q_zip;

%% Cold loads
cold_p = zeros(time_res/10,6);
cold_q = zeros(time_res/10,6);

t144=1:144;

cold_var1 = 0.207;
cold_var2 = 0.244;
cold_var3 = 0.8;
cold_var4 = 0.31;
cold_var5 = 0.15;

cold_base_power = 9;

cold1_power_fixed = 30.2;

cold1_power_mean = cold_loads(1,3);
cold1_power_sigma = cold_loads(1,4);
cold1_power_min = cold_loads(1,5);
cold1_power_max = cold_loads(1,6);
cold1_pf = cold_loads(1,7);

% Upright freezer
cold2_power_mean = cold_loads(2,3);
cold2_power_sigma = cold_loads(2,4);
cold2_power_min = cold_loads(2,5);
cold2_power_max = cold_loads(2,6);
cold2_pf = cold_loads(2,7);

%Chest freezer
cold5_power_mean = cold_loads(3,3);
cold5_power_sigma = cold_loads(3,4);
cold5_power_min = cold_loads(3,5);
cold5_power_max = cold_loads(3,6);
cold5_pf = cold_loads(3,7);

cold_p_zip = cold_loads(1,10:12);
cold_q_zip = cold_loads(1,13:15);

square_wave = square(t144*2*pi*0.3333,33.333); 
cold_cycle = (1+square_wave)/2;

if rand(1) <= cold_var1
    
    % Number ONE
    cold_p(:,1) = (cold_base_power + cold1_power_fixed*cold_cycle)';
    cold_q(:,1) = cold1_power_fixed*cold_cycle*tan(acos(cold1_pf));
    
else
    % Number TWO
    cold1_power = randn(1)*cold1_power_sigma + cold1_power_mean; % sets P
    cold1_power(cold1_power<cold1_power_min) = cold1_power_min; % cap min
    cold1_power(cold1_power>cold1_power_max) = cold1_power_max; % cap max
    cold1_power = cold1_power - cold_base_power;
    
    cold_p(:,1) = (cold_base_power + cold1_power*cold_cycle)';%0.25,25
    cold_q(:,1) = cold1_power*cold_cycle*tan(acos(cold1_pf))';
    
end

if rand(1) <= cold_var2
    if rand(1) <= cold_var3
        % Number THREE
        cold_p(:,1) = ...
            cold_p(:,1)+(cold_base_power+cold1_power_fixed*cold_cycle)';
        cold_q(:,1) = cold_q(:,1) + ...
            (cold1_power_fixed*cold_cycle*tan(acos(cold1_pf)))';
    else
        % Number FOUR
        cold1_power = randn(1)*cold1_power_sigma + cold1_power_mean; % P
        cold1_power(cold1_power<cold1_power_min) = cold1_power_min; % min
        cold1_power(cold1_power>cold1_power_max) = cold1_power_max; % max
        cold1_power = cold1_power - cold_base_power;
        
        cold_p(:,1) = cold_p(:,1) + ...
            (cold_base_power + cold1_power*cold_cycle)';
        cold_q(:,1) = cold_q(:,1) + ...
            (cold1_power_fixed*cold_cycle.*tan(acos(cold1_pf)))';
    end
end

% Upright freezer
if rand(1)<= cold_var4
    cold2_power = randn(1)*cold2_power_sigma + cold2_power_mean; % sets P
    cold2_power(cold2_power<cold2_power_min) = cold2_power_min; % cap min
    cold2_power(cold2_power>cold2_power_max) = cold2_power_max; % cap max
    cold2_power = cold2_power - cold_base_power;
    
    cold_p(:,2) = (cold_base_power + cold2_power*cold_cycle)';%
    cold_q(:,2) = cold2_power*cold_cycle*tan(acos(cold2_pf))';
end

% Chest Freezer
if rand(1) <= cold_var5
    cold5_power = randn(1)*cold5_power_sigma + cold5_power_mean; % sets P
    cold5_power(cold5_power<cold5_power_min) = cold5_power_min; % cap min
    cold5_power(cold5_power>cold5_power_max) = cold5_power_max; % cap max
    cold5_power = cold5_power - cold_base_power;
    
    cold_p(:,5) = (cold_base_power + cold5_power*cold_cycle)';
    cold_q(:,5) = cold5_power*cold_cycle*tan(acos(cold5_pf))';
end

frcycle = randperm(4)-1;
for i=1:3
    cold_p(:,i) = circshift(cold_p(:,i), [frcycle(i),0]);
    cold_q(:,i) = circshift(cold_q(:,i), [frcycle(i),0]);
end

coldfactor=1.06;
cold_p(:,1:5) = cold_p(:,1:5)*coldfactor;

cold_p(:,6) = sum(cold_p(:,1:5),2);
cold_q(:,6) = sum(cold_q(:,1:5),2);

% 10-min -> 1-min and save
temp_adam = kron(cold_p(:,6), ones(10,1));
tempq_adam = kron(cold_q(:,6), ones(10,1));

distr{15}{1,1}(:,1) = temp_adam;
distr{15}{1,1}(:,2) = tempq_adam;
distr{15}{1,2} = cold_p(:,:); 
distr{15}{1,3} = cold_q(:,:);

p_zips{26}(1:3) = cold_p_zip;
q_zips{26}(1:3) = cold_q_zip;

%% Cooking appliances

cooking_powers = zeros(7,1);
cooking_q_powers = zeros(7,1);

% Oven
cooking1_prob = cooking(1,1); 
cooking1_mean = cooking(1,2); 
cooking1_sigma = cooking(1,3); 
cooking1_min = cooking(1,4);
cooking1_max = cooking(1,5);
cooking1_pf = cooking(1,6);
cooking1_p_zip(1,1) = cooking(1,9); 
cooking1_p_zip(1,2) = cooking(1,10); 
cooking1_p_zip(1,3) = cooking(1,11);
cooking1_q_zip(1,1) = cooking(1,12); 
cooking1_q_zip(1,2) = cooking(1,13); 
cooking1_q_zip(1,3) = cooking(1,14);

% Hob
cooking2_prob = cooking(2,1); 
cooking2_mean = cooking(2,2); 
cooking2_sigma = cooking(2,3); 
cooking2_min = cooking(2,4);
cooking2_max = cooking(2,5);
cooking2_pf = cooking(2,6);
cooking2_p_zip(1,1) = cooking(2,9); 
cooking2_p_zip(1,2) = cooking(2,10); 
cooking2_p_zip(1,3) = cooking(2,11); 
cooking2_q_zip(1,1) = cooking(2,12); 
cooking2_q_zip(1,2) = cooking(2,13); 
cooking2_q_zip(1,3) = cooking(2,14); 

% Hood
cooking3_prob = cooking(3,1); 
cooking3_min = cooking(3,4);
cooking3_max = cooking(3,5);
cooking3_pf = cooking(3,6);
cooking3_p_zip(1,1) = cooking(3,9); 
cooking3_p_zip(1,2) = cooking(3,10); 
cooking3_p_zip(1,3) = cooking(3,11); 
cooking3_q_zip(1,1) = cooking(3,12); 
cooking3_q_zip(1,2) = cooking(3,13); 
cooking3_q_zip(1,3) = cooking(3,14); 

% Microwave
cooking4_prob = cooking(4,1); 
cooking4_mean = cooking(4,2); 
cooking4_sigma = cooking(4,3); 
cooking4_min = cooking(4,4);
cooking4_max = cooking(4,5);
cooking4_pf  = cooking(4,6);
cooking4_p_zip(1,1) = cooking(4,9); 
cooking4_p_zip(1,2) = cooking(4,10); 
cooking4_p_zip(1,3) = cooking(4,11);
cooking4_q_zip(1,1) = cooking(4,12); 
cooking4_q_zip(1,2) = cooking(4,13);
cooking4_q_zip(1,3) = cooking(4,14);

% Kettle
cooking5_prob = cooking(5,1);
cooking5_mean = cooking(5,2);
cooking5_sigma = cooking(5,3);
cooking5_min = cooking(5,4);
cooking5_max = cooking(5,5);
cooking5_pf = cooking(5,6);
cooking5_p_zip(1,1) = cooking(5,9); 
cooking5_p_zip(1,2) = cooking(5,10);
cooking5_p_zip(1,3) = cooking(5,11); 
cooking5_q_zip(1,1) = cooking(5,12); 
cooking5_q_zip(1,2) = cooking(5,13); 
cooking5_q_zip(1,3) = cooking(5,14);

% Toaster
cooking6_prob = cooking(6,1);
cooking6_mean = cooking(6,2);
cooking6_sigma = cooking(6,3);
cooking6_min = cooking(6,4);
cooking6_max = cooking(6,5);
cooking6_pf = cooking(6,6);
cooking6_p_zip(1,1) = cooking(6,9);
cooking6_p_zip(1,2) = cooking(6,10);
cooking6_p_zip(1,3) = cooking(6,11);
cooking6_q_zip(1,1) = cooking(6,12);
cooking6_q_zip(1,2) = cooking(6,13);
cooking6_q_zip(1,3) = cooking(6,14); 

% Food processor
cooking7_prob = cooking(7,1);
cooking7_mean = cooking(7,2);
cooking7_sigma = cooking(7,3);
cooking7_min = cooking(7,4);
cooking7_max = cooking(7,5);
cooking7_pf = cooking(7,6);
cooking7_p_zip(1,1) = cooking(7,9);
cooking7_p_zip(1,2) = cooking(7,10);
cooking7_p_zip(1,3) = cooking(7,11);
cooking7_q_zip(1,1) = cooking(7,12);
cooking7_q_zip(1,2) = cooking(7,13);
cooking7_q_zip(1,3) = cooking(7,14);

if rand(1) > cooking1_prob
    
    cooking1_power = round(randn(1)*cooking1_sigma + cooking1_mean); %P
    cooking1_power(cooking1_power<cooking1_min) = cooking1_min; % cap min
    cooking1_power(cooking1_power>cooking1_max) = cooking1_max; % cap max
    
    cooking1_q_power = cooking1_power * tan(acos(cooking1_pf));
    
    cooking_powers(1,1) = cooking1_power;
    cooking_q_powers(1,1) = cooking1_q_power;
    p_zips{28}(1:3) = cooking1_p_zip;
    q_zips{28}(1:3) = cooking1_q_zip;
    
end
if rand(1) > cooking2_prob
    
    cooking2_power = round(randn(1)*cooking2_sigma + cooking2_mean); %P
    cooking2_power(cooking2_power<cooking2_min) = cooking2_min; % cap min
    cooking2_power(cooking2_power>cooking2_max) = cooking2_max; % cap max
    
    cooking2_q_power = cooking2_power * tan(acos(cooking2_pf));
    
    cooking_powers(2,1) = cooking2_power;
    cooking_q_powers(2,1) = cooking2_q_power;
    p_zips{29}(1:3) = cooking2_p_zip;
    q_zips{29}(1:3) = cooking2_q_zip;
    
end
if rand(1) > cooking3_prob
    cooking3_power = randi([cooking3_min, cooking3_max]);
    cooking3_q_power = cooking3_power * tan(acos(cooking3_pf));
    
    cooking_powers(3,1) = cooking3_power;
    cooking_q_powers(3,1) = cooking3_q_power;
    p_zips{33}(1:3) = cooking3_p_zip;
    q_zips{33}(1:3) = cooking3_q_zip;
    
end
if rand(1) > cooking4_prob
    
    cooking4_power = round(randn(1)*cooking4_sigma + cooking4_mean); %P
    cooking4_power(cooking4_power<cooking4_min) = cooking4_min; % cap min
    cooking4_power(cooking4_power>cooking4_max) = cooking4_max; % cap max
    cooking4_q_power = cooking4_power * tan(acos(cooking4_pf));
    
    cooking_powers(4,1) = cooking4_power;
    cooking_q_powers(4,1) = cooking4_q_power;
    p_zips{30}(1:3) = cooking4_p_zip;
    q_zips{30}(1:3) = cooking4_q_zip;
    
end
if rand(1) > cooking5_prob
    
    cooking5_power = round(randn(1)*cooking5_sigma + cooking5_mean); %P
    cooking5_power(cooking5_power<cooking5_min) = cooking5_min; % cap min
    cooking5_power(cooking5_power>cooking5_max) = cooking5_max; % cap max
    
    cooking5_q_power = cooking5_power * tan(acos(cooking5_pf));
    
    cooking_powers(5,1) = cooking5_power;
    cooking_q_powers(5,1) = cooking5_q_power;
    p_zips{31}(1:3) = cooking5_p_zip;
    q_zips{31}(1:3) = cooking5_q_zip;
    
end
if rand(1) > cooking6_prob
    
    cooking6_power = round(randn(1)*cooking6_sigma + cooking6_mean); %P
    cooking6_power(cooking6_power<cooking6_min) = cooking6_min; % cap min
    cooking6_power(cooking6_power>cooking6_max) = cooking6_max; % cap max
    
    cooking6_q_power = cooking6_power * tan(acos(cooking6_pf));
    
    cooking_powers(6,1) = cooking6_power;
    cooking_q_powers(6,1) = cooking6_q_power;
    p_zips{32}(1:3) = cooking6_p_zip;
    q_zips{32}(1:3) = cooking6_q_zip;
    
end
if rand(1) > cooking7_prob
    
    cooking7_power = round(randn(1)*cooking7_sigma + cooking7_mean); %P
    cooking7_power(cooking7_power<cooking7_min) = cooking7_min; % cap min
    cooking7_power(cooking7_power>cooking7_max) = cooking7_max; % cap max
    
    cooking7_q_power = cooking7_power * tan(acos(cooking7_pf));
    
    cooking_powers(7,1) = cooking7_power;
    cooking_q_powers(7,1) = cooking7_q_power;

end

distr{17} = cooking_powers;
distr_q{17} = cooking_q_powers;

%% Phone
phone_var = phone(1,2);
phone_power_min = phone(1,5);
phone_power_max = phone(1,6);
phone_pf = phone(1,7);
phone_p_zip(1,1) = phone(1,10);
phone_p_zip(1,2) = phone(1,11);
phone_p_zip(1,3) = phone(1,12);
phone_q_zip(1,1) = phone(1,13);
phone_q_zip(1,2) = phone(1,14);
phone_q_zip(1,3) = phone(1,15);

if rand(1) >= phone_var
    phone_power = randi([phone_power_min, phone_power_max]);
    phone_q_power = phone_power * tan(cos(phone_pf));
    distr{22} = phone_power;
    distr_q{22} = phone_q_power;
else
    distr{22} = 0;
    distr_q{22} = 0;
    
end
p_zips{17}(1:3) = phone_p_zip;
q_zips{17}(1:3) = phone_q_zip;

%% Games

gamesconsole_var1 = gamesconsole(1,2);
gamesconsole_var2 = gamesconsole_var1 + gamesconsole(2,2);
gamesconsole_var3 = gamesconsole_var2 + gamesconsole(3,2);

gamesconsole1_power = gamesconsole(1,3);
gamesconsole1_pf = gamesconsole(1,7);
gamesconsole1_p_zip = gamesconsole(1,10:12);
gamesconsole1_q_zip = gamesconsole(1,13:15);

gamesconsole2_power = gamesconsole(2,3);
gamesconsole2_pf = gamesconsole(2,7);
gamesconsole2_p_zip = gamesconsole(2,10:12);
gamesconsole2_q_zip = gamesconsole(2,13:15);

gamesconsole3_power = gamesconsole(3,3);
gamesconsole3_pf = gamesconsole(3,7);
gamesconsole3_p_zip = gamesconsole(3,10:12);
gamesconsole3_q_zip = gamesconsole(3,13:15);

gamecons = rand(1);

if gamecons <= gamesconsole_var1
    gamesconsole_power = gamesconsole1_power;
    gamesconsole_pf = gamesconsole1_pf;
    gamesconsole_q_power = gamesconsole_power * tan(acos(gamesconsole_pf));
    gamesconsole_p_zip = gamesconsole1_p_zip;
    gamesconsole_q_zip = gamesconsole1_q_zip;
elseif gamecons <= gamesconsole_var2
    gamesconsole_power = gamesconsole2_power;
    gamesconsole_pf = gamesconsole2_pf;
    gamesconsole_q_power = gamesconsole_power * tan(acos(gamesconsole_pf));
    gamesconsole_p_zip = gamesconsole2_p_zip;
    gamesconsole_q_zip = gamesconsole2_q_zip;
else
    gamesconsole_power = gamesconsole3_power;
    gamesconsole_pf = gamesconsole3_pf;
    gamesconsole_q_power = gamesconsole_power * tan(acos(gamesconsole_pf));
    gamesconsole_p_zip = gamesconsole3_p_zip;
    gamesconsole_q_zip = gamesconsole3_q_zip;
end
distr{23} = gamesconsole_power;
distr_q{23} = gamesconsole_q_power;
p_zips{18}(1:3) = gamesconsole_p_zip;
q_zips{18}(1:3) = gamesconsole_q_zip;

%% heating

heating_ = zeros(3, 1);

storage_heating_ownership = heating(1,2);
instant_heating_ownership = heating(2,2);

tfeh = rand(1);

if tfeh < storage_heating_ownership
    heating_type = 2;   
    heating_mean = heating(2,3);
    heating_sigma = heating(2,4);
    heating_min = heating(2,5);
    heating_max = heating(2,6);
    heating_pf = heating(2,7);
    heating_p_zip = heating(2,10:12);
    heating_q_zip = heating(2,13:15);

elseif tfeh < instant_heating_ownership + storage_heating_ownership
    heating_type = 1;
    heating_mean = heating(2,3);
    heating_sigma = heating(2,4);
    heating_min = heating(2,5);
    heating_max = heating(2,6);
    heating_pf = heating(2,7);
    heating_p_zip = heating(2,10:12);
    heating_q_zip = heating(2,13:15);
else
    heating_type = 0;
    heating_mean = 0;
    heating_min = 0;
    heating_max = 0;
    heating_sigma = 0;
    heating_pf = 0;
    heating_p_zip = [0,0,0];
    heating_q_zip = [0,0,0];
end

heating_power = round(randn(1)*heating_sigma + heating_mean); %P
heating_power(heating_power<heating_min) = heating_min; % cap min
heating_power(heating_power>heating_max) = heating_max; % cap max
heating_q_power = heating_power * tan(acos(heating_pf));

heating_(1,1) = heating_type;
heating_(2,1) = heating_power;
heating_(3,1) =  heating_(2,1)*4;

distr{35} = heating_;
distr_q{35} = heating_q_power;

p_zips{35}(1:3) = heating_p_zip;
q_zips{35}(1:3) = heating_q_zip;

%% Electric vehicle stuff
ev_ownership = ev(1,2); % in pc

if rand(1) < ev_ownership

    ev_power_min = ev(1,5); % W
    ev_power_max = ev(1,6); % W
    ev_pf = ev(1,7);
    ev_charger_eff_min = ev(1,16); % pu
    ev_charger_eff_max = ev(1,17); % pu
    ev_p_zip(1,1) = ev(1,10);
    ev_p_zip(2,1) = ev(1,11);
    ev_p_zip(3,1) = ev(1,12);
    ev_q_zip(1,1) = ev(1,13);
    ev_q_zip(2,1) = ev(1,14);
    ev_q_zip(3,1) = ev(1,15);

    ev_battery_capacity_min = ev(1,20); % Wh
    ev_battery_capacity_max = ev(1,21); % Wh
    ev_battery_soc_mean = ev(1,18); % pu
    ev_battery_soc_sigma = ev(1,19); % pu

    ev_p_power = ev_power_min + (ev_power_max-ev_power_min)*rand(1);
    ev_battery_capacity = randi([ev_battery_capacity_min, ...
                                 ev_battery_capacity_max]);
    ev_q_power = ev_p_power * tan(acos(ev_pf));
    ev_battery_soc = randn(1)*ev_battery_soc_sigma + ev_battery_soc_mean;
    ev_charger_efficiency = ...
        ev_charger_eff_min+(ev_charger_eff_max-ev_charger_eff_min)*rand(1);

else
    ev_p_power = 0;
    ev_battery_capacity = 0;
    ev_q_power = 0;
    ev_charger_efficiency = 0;
    ev_battery_soc = 0;
    ev_p_zip(1:3) = 0;
    ev_q_zip(1:3) = 0;
end

distr{34}(1,1) = ev_p_power;
distr{34}(2,1) = ev_battery_capacity;
distr{34}(3,1) = ev_battery_soc;
distr{34}(4,1) = ev_charger_efficiency;
distr_q{34}(1,1) = ev_q_power;
p_zips{34}(1:3) = ev_p_zip;
q_zips{34}(1:3) = ev_q_zip;

end