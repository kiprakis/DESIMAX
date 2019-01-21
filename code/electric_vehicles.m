function [p, q] = electric_vehicles(time_res, distr, distr_q, hh_occ)

% Calculate the household electric vehicle demand. This sets an
% uncontrolled/unoptimised charging profiles which assumes that the car is
% charged from the last continuous occupancy period of the day. The
% required charging duration is calculated from the battery state of
% charge, the battery capacity and the rating of the charger. It is assumed
% that the charger will always fully charge unless disconnected.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   distr (cell) [-]: Specification of active power characteristics of
%   household appliances;
%   distr_q  (cell) [-]: Specification of reactive power characteristics of
%   household appliances;
%   hh_occ (array) [-]: DataStructure to hold the overall household
%   occupancy data.
%
% Returns:
%   p (array) [W]: Active power profile of the EV load;
%   q (array) [var]: Reactive power profile of the EV load.

ev_power = distr{34}(1,1);
ev_battery_capacity = distr{34}(2,1);
ev_battery_soc = distr{34}(3,1);
ev_q_power = distr_q{34}(1,1);

p = zeros(time_res,1);
q = zeros(time_res,1);

hh = hh_occ(:,1);

occupied_times = find(hh);
diffs = diff(occupied_times);
n = find(diffs~=1, 1, 'last');

% set first possible start time
ev_start_time = occupied_times(n+1)*10;

% estimate charging time
battery_soc_kWh = ev_battery_soc * ev_battery_capacity;
required_charging_time = ...
    round((ev_battery_capacity - battery_soc_kWh)/ev_power*60);
end_time = required_charging_time + ev_start_time;

if end_time > 1440
    end_time = end_time - 1440;
    p(1:end_time,:) = ev_power;
    p(ev_start_time:1440,:) = ev_power;
    q(1:end_time,:) = ev_q_power;
    q(ev_start_time:1440,:) = ev_q_power;
else
    p(ev_start_time:end_time) = ev_power;
    q(ev_start_time:end_time) = ev_q_power;
end

end