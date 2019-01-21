function [agg_zip] = zip_aggregation(p_hh, ...
                                     occ_power, ...
                                     hh_zips, ...
                                     nocc, ...
                                     lightzip, ...
                                     lightload, ...
                                     wet_starts, ...
                                     wet_ends)

% Build the household ZIP model. The aggregate ZIP is obtained by a
% weighted summation of all household loads. First each user is aggregated
% and then lighting, heating, EVs and the user defined load are added.
%
% Arguments:
%   p_hh (array) [W]: Active power demand profile of the household;
%   occ_power (cell [-]: DataStructure to hold the power profiles of every
%       household load for every occupant. This can be either active or
%       reactive power demand;
%   hh_zips (cell) [-]: ZIP models for each household appliance;
%   n_occ (int) [-]: The number of occupants in the household;
%   lightzip (array) [-]: ZIP models for lamps;
%   lightload (cell) [-]: Demand profile of each individual lamp;;
%   wet_starts (array) [min]: Start times of wet loads;;
%   wet_ends (array) [min]: End times of wet loads.
%
% Returns:
%   agg_zip (array) [-]: Aggregate ZIP model of the household.

agg_zip = zeros(1440,3);

for user = 1:nocc
    for appliance = [1,5,7:26, 28:33]
        p_app = occ_power{1,user}(:,appliance);
        if sum(p_app) > 0
            
            p_zip_model = hh_zips{appliance};
            agg_zip = agg_zip + abs(p_app)./p_hh *p_zip_model;
            
        end
    end
    for appliance = [4,6,27]
        if sum(occ_power{1,user}(:,appliance)) > 0
            switch appliance
                case 4
                    idx = 1;
                case 6
                    idx = 2;
                case 27
                    idx = 3;
            end
            wet_zip = zeros(1440,3);
            start_time = wet_starts(idx, user);
            end_time = wet_ends(idx, user);

            if start_time > end_time
                cycle = size(hh_zips{1,appliance},1);
                wet_zip(1:end_time,:) = ...
                    hh_zips{1,appliance}(cycle-end_time+1:cycle,:);
                wet_zip(start_time:1440,:) = ...
                    hh_zips{1,appliance}(1:cycle-end_time,:);
            else
                wet_zip(start_time:end_time,:) = hh_zips{1,appliance};
            end
            
            
            p_wet = abs(occ_power{1,user}(:,appliance))./p_hh;
            agg_zip = agg_zip + bsxfun(@times,wet_zip,p_wet(:));

        end
    end
end

% lighting
for light = 1:size(lightzip,1)
    p_light = lightload{1}(:,light);
    p_zip_model = lightzip(light,:);
    agg_zip = agg_zip + abs(p_light)./p_hh * p_zip_model;
end

% heating
agg_zip = agg_zip + abs(occ_power{1,nocc + 2})./p_hh * hh_zips{35};

% EVs
agg_zip = agg_zip + abs(occ_power{1,nocc + 3})./p_hh * hh_zips{34};

% Spare load space
p_new = abs(occ_power{1,nocc + 4})./p_hh;
agg_zip = agg_zip + bsxfun(@times,hh_zips{36},p_new(:));
end