function [APower, ...
          RePower, ...
          distr, ...
          light_pzip, ...
          light_qzip, ...
          light_qs, ...
          wet_starts, ...
          wet_ends] = activity_to_power(time_res, ...
                                        Profiles, ...
                                        month, ...
                                        day, ...
                                        u_beh, ...
                                        lighting_data, ...
                                        set_temp, ...
                                        irr, ...
                                        hh_occ, ...
                                        distr, ...
                                        distr_q, ...
                                        n_occ)

% Convert the user activity into electrical appliance use. Each user 
% activity is converted by a specific subroutine and this function acts as
% a control to handle the data flow by calling each subroutine in sequence.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   Profiles (cell) [-]: DataStructure to hold the user activity profiles.
%       Each user is represented by a 144x17 array;
%   month (int) []:  Month of year;
%   day (int) []:  Type of day; 1 =  weekday, 2 = weekend;
%   u_beh (int) []:  User behaviour type;
%   lighting_data (array; 7x15) []: Lighting loads specification.
%   set_temp (array) [Degree C]: Cumulative probability of
%       temperature set-point;
%   irr (array; time_res, 1) [W/m2]: Solar irradiance for the given month.
%   hh_occ array) [-]: DataStructure to hold the overall household
%      occupancy data. Each household is represented by a 1x144 array, with
%      the integer value indicating the number of active occupants.
%   distr (cell, 1x35) []: Specification of active power characteristics of
%      household appliances.
%   distr_q (cell, 1x35) []: Specification of reactive power
%       characteristics of household appliances. 
%   n_occ (int) [-]: The number of occupants in the household.
%
% Returns:
%   APower (cell; 1, Noccup+3) [W]: DataStructure to hold the active power
%      profiles of every household load for every occupant. Locations:
%       Noccup+1: lighting, Noccup+2: heating, Noccup+3: ev.
%   RePower (cell; 1, Noccup+3) [var]: DataStructure to hold the reactive
%       power profiles of every household load for every occupant.
%       Locations: Noccup+1: lighting, Noccup+2: heating, Noccup+3: ev.
%   distr (cell, 1x35) []: Specification of active power characteristics of
%      household appliances.
%   light_pzip (array; n_lamps x 3): Active power zip models for lamps.
%   light_qzip (array; n_lamps x 3): Reactive power zip models for lamps.
%   light_qs (array; time_res x n_lamps): Reactive power profiles for
%       lamps.
%   wet_starts (array) [-]: Start times of wet loads.
%   wet_ends (array) [-]: End times of wet loads.
%

APower = cell(1,n_occ+3);
RePower = cell(1,n_occ+3);

cooking_app_use = zeros(1440,5);

wet_starts = zeros(2,n_occ);
wet_ends = zeros(2,n_occ);

for i=1:n_occ
    
    p = zeros(time_res, 33);
    q = zeros(time_res, 33);
    
    temp = Profiles{i,1};
    temp2 = zeros(1440,17);
    
    for ac=1:17
        for np10=1:144
            for np1=1:10
                temp2((np10-1)*10+np1,ac)=temp(np10,ac);
            end
        end
    end
    
    activ = temp2;
    activ144 = temp;
    
    [p(:,1), q(:,1)] = electric_shower_loads(time_res, ...
                                             activ144(:,3), ...
                                             distr{14}, ...
                                             distr_q{14}, ...
                                             0.46);
    
    [cook_p, ...
     cook_q, ...
     cooking_app_use] = cooking_loads(time_res, ...
                                      activ144, ...
                                      month, ...
                                      day, ...
                                      distr{17}, ...
                                      distr_q{17}, ...
                                      cooking_app_use);
    
    % distribute cooking into main power vars
    p(:,28:33) = cook_p;
    q(:,28:33) = cook_q;
    
    % dishwasher
    [p(:,4), q(:,4), dw_start, dw_end] = wet_loads(time_res,...
        activ144(:,5),...
        distr{16}{1,1}{3,1}(:,1),...
        distr_q{16}{3,1},...
        1);

    wet_starts(1, i) = dw_start;
    wet_ends(1, i) = dw_end;
    
    % washing machine
    [p(:,6), q(:,6), wm_start, wm_end] = wet_loads(time_res,...
        activ144(:,8),...
        distr{16}{1,1}{1,1}(:,1),...
        distr_q{16}{1,1},...
        2);
        
    wet_starts(2, i) = wm_start;
    wet_ends(2, i) = wm_end;
    
    if sum(p(:,6)) > 0
        [p(:,27), q(:,27), cd_start, cd_end] = clothes_drier(time_res, ...
            month, ...
            wm_end, ...
            distr{16}{1,1}{2,1}(:,1), ...
            distr_q{16}{2,1});
        wet_starts(3, i) = cd_start;
        wet_ends(3, i) = cd_end;
    end

    % vacuum cleaner
    p(:,5) = distr{12}(1,1)*activ(:,6);
    q(:,5) = distr_q{12}(1,1)*activ(:,6);
    
    % iron
    p(:,7) = distr{11}(1)*activ(:,9);
    q(:,7) = distr_q{11}(1)*activ(:,9);
    
    [p(:,18+i), q(:,18+i),  ...
        p(:,7+i), q(:,7+i), ...
        p(:,11+i), q(:,11+i), ...
        p(:,16), q(:,16),  ...
        p(:,24), q(:,24),  ...
        p(:,17), q(:,17), ...
        p(:,18), q(:,18), ...
        p(:,23), q(:,23)] = ce_ict_loads(time_res, ...
                                         activ, ...
                                         distr, ...
                                         distr_q, ...
                                         i, ...
                                         u_beh);
    
    if u_beh == 2
        
        p_val_1 = distr{6}(i,1);
        q_val_1 = distr_q{6}(i,1);
        p_val_2 = distr{8}(i,1);
        q_val_2 = distr_q{8}(i,1);
        p_val_3 = distr{21}(1,2);
        q_val_3 = distr_q{21}(1,2);
        p_val_4 = distr{2}(i,1);
        q_val_4 = distr_q{2}(i,1);
        p_val_5 = distr{4};
        q_val_5 = distr_q{4};
        p_val_6 = distr{10};
        q_val_6 = distr_q{10};
        
        temp_var = p(:,7+i);
        temp_var(p(:,7+i)==0) = p_val_1;
        p(:,7+i) = temp_var;
        temp_var = q(:,7+i);
        temp_var(q(:,7+i)==0) = q_val_1;
        q(:,7+i) = temp_var;
        
        temp_var = p(:,16);
        temp_var(p(:,16)==0) = p_val_3;
        p(:,16) = temp_var;
        temp_var = q(:,16);
        temp_var(q(:,16)==0) = q_val_3;
        q(:,16) = temp_var;
        
        temp_var = p(:,18+i);
        temp_var(p(:,18+i)==0) = p_val_4;
        p(:,18+i) = temp_var;
        temp_var = q(:,18+i);
        temp_var(q(:,18+i)==0) = q_val_4;
        q(:,18+i) = temp_var;
        
        temp_var = p(:,23);
        temp_var(p(:,23)==0) = p_val_5;
        p(:,23) = temp_var;
        temp_var = q(:,23);
        temp_var(q(:,23)==0) = q_val_5;
        q(:,23) = temp_var;
        
        temp_var = p(:,24);
        temp_var(p(:,24)==0) = p_val_6;
        p(:,24) = temp_var;
        temp_var = q(:,24);
        temp_var(q(:,24)==0) = q_val_6;
        q(:,24) = temp_var;

        if ~(size(distr{7}(:,1),1)==1 && distr{7}(i,1)==0)
            temp_var = p(:,11+i);
            temp_var(p(:,11+i)==0) = p_val_2;
            p(:,11+i) = temp_var;
            temp_var = q(:,11+i);
            temp_var(q(:,11+i)==0) = q_val_2;
            q(:,11+i) = temp_var;

        end
    end

    if i==1
        p(:,25) = distr{13};
        q(:,25) = distr_q{13};

        start = randi([0 29]);
        p(:,26)=circshift(distr{15}{1,1}(:,1),[start,0]);
        q(:,26)=circshift(distr{15}{1,1}(:,2),[start,0]);
        
    else
        p(:,25)=0;
        q(:,25)=0;
        p(:,26)=0;
        q(:,26)=0;
    end
    APower{i}=p(:,:);
    RePower{i}=q(:,:);
end

[p_light, ...
 q_light, ...
 distr{1,18}, ...
 light_qs, ...
 distr{1,19}, ...
 light_pzip, ...
 light_qzip] = lighting_loads(time_res, irr, lighting_data, hh_occ);

APower{1,n_occ+1} = p_light;
RePower{1, n_occ+1} = q_light;

if distr{35}(1,1) > 0 % heating identifier
    [p_heat] = heating_loads(time_res, distr, month, set_temp, irr,hh_occ);
else
    p_heat = zeros(time_res, 1);
end

APower{1,n_occ+2} = p_heat;
RePower{1,n_occ+2} = zeros(time_res, 1);

if distr{34}(1,1) > 0 % ev identifier
    [p_ev, q_ev] = electric_vehicles(time_res, distr, distr_q, hh_occ);
else
    p_ev = zeros(time_res, 1);
    q_ev = zeros(time_res, 1);
end

APower{1,n_occ+3} = p_ev;
RePower{1,n_occ+3} = q_ev;

end