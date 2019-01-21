function [total_power, ...
          total_q_power,...
          bulbsdb, ...
          lighting_q, ...
          lamp_types, ...
          lamp_p_zip, ...
          lamp_q_zip] = lighting_loads(time_res, ...
                                       irr, ...
                                       lighting_data, ...
                                       hh_occ)

% Calculate household lighting demand. The power demand of is dependent on
% the presence of people in house and a comparison between the external and
% required illumination conditions. The external irradiance is compared
% with a threshold at each time step to determine whether artificial light 
% is needed. When artificial lighting is needed, the code checks the
% occupancy profile at each time point and if there is at least one active
% occupant then the possibility of turning on the lights increases. Then,
% the demand for artificial light is converted into power demand.
% Additionally, the model provides the probability of turning on any light
% even when it is not required.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   irr (array) [W/m^{2}]: Solar irradiance for the given month;
%   lighting_data (array) [-]: Lighting load data;
%   hh_occ (array) [-]:DataStructure to hold the overall household
%   occupancy data.
%
% Returns:
%   total_power (array) [W]: Active power profile of the lighting load;
%   total_q_power (array) [var]: Reactive power profile of the lighting 
%       load;
%   bulbsdb (cell) [W]: Active power profile of each individual lamp;
%   lighting_q (cell) [var]: Reactive power profile of each individual
%       lamp;
%   lamp_types (array) [-]: Lamp type of each individual lamp;
%   lamp_p_zip (array) [-]: Active power zip models for each lamp;
%   lamp_q_zip (array) [-]: Reactive power zip models for each lamp.

%% Declare local vars here
calsc = 0.0081537; % calibration scalar
cbd = [ 1,  1,      0.11111;
        2,  2,      0.22222;
        3,  4,      0.33333;
        5,  8,      0.44444;
        9,  16,     0.55555;
        17, 27,     0.66666;
        28, 49,     0.77777;
        50, 91,     0.88888;
        92, 259,    1]; % duration cumulative probability

irr_threshold_mu = 60;
irr_threshold_sigma = 10;

n_lamp_types = size(lighting_data,1);

lamp1_min = lighting_data(1,5);
lamp1_max = lighting_data(1,6);
lamp1_pf = lighting_data(1,7);
lamp1_p_zip_z = lighting_data(1,10);
lamp1_p_zip_i = lighting_data(1,11);
lamp1_p_zip_p = lighting_data(1,12);
lamp1_q_zip_z = lighting_data(1,13);
lamp1_q_zip_i = lighting_data(1,14);
lamp1_q_zip_p = lighting_data(1,15);
lamp1_p_zip = [lamp1_p_zip_z,lamp1_p_zip_i,lamp1_p_zip_p];
lamp1_q_zip = [lamp1_q_zip_z,lamp1_q_zip_i,lamp1_q_zip_p];

lamp2_min = lighting_data(2,5);
lamp2_max = lighting_data(2,6);
lamp2_pf = lighting_data(2,7);
lamp2_p_zip_z = lighting_data(2,10);
lamp2_p_zip_i = lighting_data(2,11);
lamp2_p_zip_p = lighting_data(2,12);
lamp2_q_zip_z = lighting_data(2,13);
lamp2_q_zip_i = lighting_data(2,14);
lamp2_q_zip_p = lighting_data(2,15);
lamp2_p_zip = [lamp2_p_zip_z,lamp2_p_zip_i,lamp2_p_zip_p];
lamp2_q_zip = [lamp2_q_zip_z,lamp2_q_zip_i,lamp2_q_zip_p];

lamp3_min = lighting_data(3,5);
lamp3_max = lighting_data(3,6);
lamp3_pf = lighting_data(3,7);
lamp3_p_zip_z = lighting_data(3,10);
lamp3_p_zip_i = lighting_data(3,11);
lamp3_p_zip_p = lighting_data(3,12);
lamp3_q_zip_z = lighting_data(3,13);
lamp3_q_zip_i = lighting_data(3,14);
lamp3_q_zip_p = lighting_data(3,15);
lamp3_p_zip = [lamp3_p_zip_z,lamp3_p_zip_i,lamp3_p_zip_p];
lamp3_q_zip = [lamp3_q_zip_z,lamp3_q_zip_i,lamp3_q_zip_p];

lamp4_min = lighting_data(4,5);
lamp4_max = lighting_data(4,6);
lamp4_pf = lighting_data(4,7);
lamp4_p_zip_z = lighting_data(4,10);
lamp4_p_zip_i = lighting_data(4,11);
lamp4_p_zip_p = lighting_data(4,12);
lamp4_q_zip_z = lighting_data(4,13);
lamp4_q_zip_i = lighting_data(4,14);
lamp4_q_zip_p = lighting_data(4,15);
lamp4_p_zip = [lamp4_p_zip_z,lamp4_p_zip_i,lamp4_p_zip_p];
lamp4_q_zip = [lamp4_q_zip_z,lamp4_q_zip_i,lamp4_q_zip_p];

lamp5_min = lighting_data(5,5);
lamp5_max = lighting_data(5,6);
lamp5_pf = lighting_data(5,7);
lamp5_p_zip_z = lighting_data(5,10);
lamp5_p_zip_i = lighting_data(5,11);
lamp5_p_zip_p = lighting_data(5,12);
lamp5_q_zip_z = lighting_data(5,13);
lamp5_q_zip_i = lighting_data(5,14);
lamp5_q_zip_p = lighting_data(5,15);
lamp5_p_zip = [lamp5_p_zip_z,lamp5_p_zip_i,lamp5_p_zip_p];
lamp5_q_zip = [lamp5_q_zip_z,lamp5_q_zip_i,lamp5_q_zip_p];

lamp6_min = lighting_data(6,5);
lamp6_max = lighting_data(6,6);
lamp6_pf = lighting_data(6,7);
lamp6_p_zip_z = lighting_data(6,10);
lamp6_p_zip_i = lighting_data(6,11);
lamp6_p_zip_p = lighting_data(6,12);
lamp6_q_zip_z = lighting_data(6,13);
lamp6_q_zip_i = lighting_data(6,14);
lamp6_q_zip_p = lighting_data(6,15);
lamp6_p_zip = [lamp6_p_zip_z,lamp6_p_zip_i,lamp6_p_zip_p];
lamp6_q_zip = [lamp6_q_zip_z,lamp6_q_zip_i,lamp6_q_zip_p];

lamp7_min = lighting_data(7,5);
lamp7_max = lighting_data(7,6);
lamp7_pf = lighting_data(7,7);
lamp7_p_zip_z = lighting_data(7,10);
lamp7_p_zip_i = lighting_data(7,11);
lamp7_p_zip_p = lighting_data(7,12);
lamp7_q_zip_z = lighting_data(7,13);
lamp7_q_zip_i = lighting_data(7,14);
lamp7_q_zip_p = lighting_data(7,15);
lamp7_p_zip = [lamp7_p_zip_z,lamp7_p_zip_i,lamp7_p_zip_p];
lamp7_q_zip = [lamp7_q_zip_z,lamp7_q_zip_i,lamp7_q_zip_p];

% Effective occupancy
activity = hh_occ';
effocc=zeros(1,144);
for i=1:144
    switch activity(1,i)
        case 0
            effocc(1,i)=0;
        case 1
            effocc(1,i)=1;
        case 2
            effocc(1,i)=1.528;
        case 3
            effocc(1,i)=1.694;
        case 4
            effocc(1,i)=1.983;
        case 5
            effocc(1,i)=2.094;
    end
end

% make 1440
effocc = kron(effocc, ones(1,10));

irr_threshold = randn(1)*irr_threshold_sigma + irr_threshold_mu;

n_lamps_mu = 16;
n_lamps_sigma = 5;
n_lamps_min = 11;
n_lamps_max = 21;

n_lamps = round(randn(1)*n_lamps_sigma + n_lamps_mu);

n_lamps(n_lamps<n_lamps_min) = n_lamps_min; % cap min
n_lamps(n_lamps>n_lamps_max) = n_lamps_max; % cap max

% Make a single table based on cumulative probability
lamp_probabilities = lighting_data(:,2);
cpd = zeros(n_lamp_types,1);
for i = 1:n_lamp_types
    cpd(i,1) = sum(lamp_probabilities(1:i));
end

rand_var = rand(n_lamps, 1);
lamp_types = zeros(n_lamps, 1);

for lamp = 1:n_lamps
    i = 1;
    while (rand_var(lamp) > cpd(i,1))
        i=i+1;
    end
    lamp_types(lamp) = i;
end

lamp_powers = zeros(n_lamps, 1);
lamp_reactive_powers = zeros(n_lamps, 1);
lamp_p_zip = zeros(n_lamps, 3);
lamp_q_zip = zeros(n_lamps, 3);

for lamp = 1:n_lamps
    switch lamp_types(i)
        case 1
            lamp_powers(lamp) = randi([lamp1_min, lamp1_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp1_pf));
            lamp_p_zip(lamp,:) = lamp1_p_zip;
            lamp_q_zip(lamp,:) = lamp1_q_zip;
            
        case 2
            lamp_powers(lamp) = randi([lamp2_min, lamp2_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp2_pf));
            lamp_p_zip(lamp,:) = lamp2_p_zip;
            lamp_q_zip(lamp,:) = lamp2_q_zip;
            
        case 3
            lamp_powers(lamp) = randi([lamp3_min, lamp3_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp3_pf));
            lamp_p_zip(lamp,:) = lamp3_p_zip;
            lamp_q_zip(lamp,:) = lamp3_q_zip;
            
        case 4
            lamp_powers(lamp) = randi([lamp4_min, lamp4_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp4_pf));
            lamp_p_zip(lamp,:) = lamp4_p_zip;
            lamp_q_zip(lamp,:) = lamp4_q_zip;
            
        case 5
            lamp_powers(lamp) = randi([lamp5_min, lamp5_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp5_pf));
            lamp_p_zip(lamp,:) = lamp5_p_zip;
            lamp_q_zip(lamp,:) = lamp5_q_zip;
            
        case 6
            lamp_powers(lamp) = randi([lamp6_min, lamp6_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp6_pf));
            lamp_p_zip(lamp,:) = lamp6_p_zip;
            lamp_q_zip(lamp,:) = lamp6_q_zip;

        case 7
            lamp_powers(lamp) = randi([lamp7_min, lamp7_max]);
            lamp_reactive_powers(lamp) = ...
                lamp_powers(lamp) * tan(acos(lamp7_pf));
            lamp_p_zip(lamp,:) = lamp7_p_zip;
            lamp_q_zip(lamp,:) = lamp7_q_zip;

    end
end

lamp_types = lamp_types';

lighting = zeros(time_res, n_lamps);
lighting_q = zeros(time_res, n_lamps);

compare_irr = irr(:) < irr_threshold;

for i = 1:n_lamps

    calruw=-calsc*log(rand(1));
    local_effecoc = effocc.*calruw;

    for j=1:time_res

        rand_compare = rand(1) < 0.05;
        llc = compare_irr(j) || rand_compare;

        if (llc && (rand(1) < local_effecoc(j)))
            rn = rand(1);
            if rn < cbd(1,3)
                duration = randi([cbd(1,1),cbd(1,2)]);
            elseif rn < cbd(2,3)
                duration = randi([cbd(2,1),cbd(2,2)]);
            elseif rn < cbd(3,3)
                duration = randi([cbd(3,1),cbd(3,2)]);
            elseif rn < cbd(4,3)
                duration = randi([cbd(4,1),cbd(4,2)]);
            elseif rn < cbd(5,3)
                duration = randi([cbd(5,1),cbd(5,2)]);
            elseif rn < cbd(6,3)
                duration = randi([cbd(6,1),cbd(6,2)]);
            elseif rn < cbd(7,3)
                duration = randi([cbd(7,1),cbd(7,2)]);
            elseif rn < cbd(8,3)
                duration = randi([cbd(8,1),cbd(8,2)]);
            else
                duration = randi([cbd(9,1),cbd(9,2)]);
            end
            for c = 1:duration
                if j+c < time_res+1
                    if effocc(j+c) == 0
                        break
                    end
                    lighting(j+c,i) = lamp_powers(i,1);
                    lighting_q(j+c,i) = lamp_reactive_powers(i,1);
                else
                    lighting(j+c-time_res,i) = lamp_powers(i,1);
                    lighting_q(j+c-time_res,i) = lamp_reactive_powers(i,1);
                end
            end
        end
    end
end

total_power = sum(lighting, 2);
total_q_power = sum(lighting_q, 2);

Lighting{1}=lighting(:,:);
bulbsdb{1,1}=Lighting;

end