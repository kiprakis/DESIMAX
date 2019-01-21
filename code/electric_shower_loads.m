function [p,...
          q] = electric_shower_loads(time_res, ...
                                     activ, ...
                                     rated_power, ...
                                     rated_q_power, ...
                                     ownership)

% Convert activity into Shower loads. Three sets of statistics are applied:
% one to determine if the load is used or not, another to set the start
% time of the appliance and another to set the duration.
%
% Arguments:
%   time_res (int) [min]: Simulation time step.
%   activ (cell) [-]: DataStructure to hold the user activity profiles;
%   rated_power (float) [W]: Active power of the load;
%   rated_q_power (float) [var]: Reactive power of the load;
%   ownership (float) [-]: Ownership probability.
%
% Returns:
%   p (array) [W]: Active power profile of the shower load;
%   q (array) [var]: Reactive power profile of the shower load.

% initialise vars here
p = zeros(time_res, 1);
q = zeros(time_res, 1);

duration_mean = 8; % in mins
duration_sigma = 2; % in mins
duration_min = 3; % in mins
duration_max = 15; % in mins

prob_bounds = [0, 0.5; 0.50, 0.60; 0.60, 0.95; 0.95, 1];
time_bounds = [31, 60; 61, 102; 103, 144; 1, 30];

if (rand(1) >= ownership)
    
    duration = round(randn(1)*duration_sigma + duration_mean);
    duration(duration<duration_min) = duration_min; % cap min
    duration(duration>duration_max) = duration_max; % cap max
    
    sh=rand(1);
    
    if (sh > prob_bounds(1,1) && sh <= prob_bounds(1,2))
        
        sh2 = find(activ(time_bounds(1,1):time_bounds(1,2)));
        
        if ~isempty(sh2)
            
            sh2start = randsample(sh2,1);
            start_time = (time_bounds(1,1)-1)*10+sh2start*10+randi([0 9]);
            p(start_time:start_time+duration-1,1) = rated_power;
            q(start_time:start_time+duration-1,1) = rated_q_power;
        end
        
    elseif (sh > prob_bounds(2,1) && sh <= prob_bounds(2,2))
        
        sh2=find(activ(time_bounds(2,1):time_bounds(2,2)));
        
        if ~isempty(sh2)
            
            sh2start = randsample(sh2,1);
            
            start_time = (time_bounds(2,1)-1)*10+sh2start*10+randi([0 9]);
            p(start_time:start_time+duration-1,1) = rated_power;
            q(start_time:start_time+duration-1,1) = rated_q_power;
        end
        
    elseif (sh > prob_bounds(3,1) && sh <= prob_bounds(4,1))
        
        sh2=find(activ(time_bounds(3,1):time_bounds(3,2)));
        
        if ~isempty(sh2)
            
            sh2start = randsample(sh2,1);
            l = (time_bounds(3,1)-1)*10+sh2start*10+randi([0 9]);
            
            if l+duration>time_res
                p(l:time_res,1) = rated_power;
                p(1:(l+duration-1)-time_res,1) = rated_power;
                q(l:time_res,1) = rated_q_power;
                q(1:(l+duration-1)-time_res,1) = rated_q_power;
            else
                p(l:l+duration-1,1) = rated_power;
                q(l:l+duration-1,1) = rated_q_power;
            end
        end
    else
        
        sh2=find(activ(time_bounds(4,1): time_bounds(4,2)));
        
        if ~isempty(sh2)
            
            sh2start = randsample(sh2,1);
            start_time = sh2start*10+randi([0 9]);
            p(start_time:start_time+duration-1,1) = rated_power;
            q(start_time:start_time+duration-1,1) = rated_q_power;
        end
    end
end
end