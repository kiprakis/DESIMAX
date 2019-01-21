function [p_cooking, ...
          q_cooking, ...
          appliance_use] = cooking_loads(time_res, ...
                                         activ144, ...
                                         month, ...
                                         day, ...
                                         appliance_p, ...
                                         appliance_q, ...
                                         appliance_use)

% Converts the cooking activity into electrical appliance use. Five 
% appliances are defined: oven, hob (plus extractor fan), microwave, kettle
% and toaster. The use of each load is governed by time varying 
% probabilities. Use is not mutually exclusive and multiple cooking 
% appliances can be used simultaneously.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   activ144 (cell) [-]: DataStructure to hold the user activity profiles;
%   month (int) []:  Month of year;
%   day (int) []:  Type of day; 1 =  weekday, 2 = weekend;
%   appliance_p (array) [W]: Rated active power of the cooking appliances;
%   appliance_q (array) [var]: Rated reactive power of the cooking 
%       appliances;
%   appliance_use (array) [-]: Activity profile of cooking appliance use.
%
% Returns:
%   p_cooking (array) [W]: Active power profile of the cooking loads;
%   q_cooking (array) [var]: Reactive power profile of the cooking loads;
%   appliance_use (array) [-]: Activity profile of cooking appliance use.

MonWeight = [1.137,...
             1.059,...
             0.994,...
             0.937,...
             0.896,...
             0.871,...
             0.862,...
             0.868,...
             0.890,...
             0.929,...
             0.977,...
             1.046];

AppUseProb{1,1} = [0.221 0.229 0.069 0.355 0.127;
                   0.271 0.335 0.079 0.263 0.052;
                   0.444 0.337 0.058 0.140 0.022;
                   0.344 0.372 0.080 0.182 0.022;
                   0.278 0.156 0.137 0.383 0.046;
                   0.278 0.156 0.137 0.383 0.046;];

AppUseProb{2,1} = [0.202 0.302 0.063 0.323 0.111;
                   0.344 0.365 0.063 0.188 0.040;
                   0.388 0.436 0.044 0.115 0.018;
                   0.306 0.456 0.064 0.158 0.016;
                   0.269 0.220 0.136 0.342 0.033;
                   0.269 0.220 0.136 0.342 0.033;];

CookChance = [0.214 0.214;
              0.175 0.175;
              0.214 0.214;
              0.282 0.282;
              0.117 0.117;
              0.117 0.117;];

use_probability(:,1) = ...
    AppUseProb{day,1}(:,1).*CookChance(:,day)*MonWeight(1,month);
use_probability(:,2) = ...
    AppUseProb{day,1}(:,2).*CookChance(:,day)*MonWeight(1,month);
use_probability(:,3) = ...
    AppUseProb{day,1}(:,3).*CookChance(:,day)*MonWeight(1,month);
use_probability(:,4) = ...
    AppUseProb{day,1}(:,4).*CookChance(:,day)*MonWeight(1,month);
use_probability(:,5) = ...
    AppUseProb{day,1}(:,5).*CookChance(:,day)*MonWeight(1,month);

p_app_1 = appliance_p(1,1); % Oven
p_app_2 = appliance_p(2,1); % hob
p_app_2_fan = appliance_p(3,1); % fan % assign to col 6
p_app_3 = appliance_p(4,1); % Microwave
p_app_4 = appliance_p(5,1); % Kettle
p_app_5 = appliance_p(6,1); % Toaster

q_app_1 = appliance_q(1,1);
q_app_2 = appliance_q(2,1);
q_app_2_fan = appliance_q(3,1); % assign to col 6
q_app_3 = appliance_q(4,1);
q_app_4 = appliance_q(5,1);
q_app_5 = appliance_q(6,1);

% merge back
cooking_powers(1,1) = p_app_1;
cooking_powers(2,1) = p_app_2;
cooking_powers(3,1) = p_app_3;
cooking_powers(4,1) = p_app_4;
cooking_powers(5,1) = p_app_5;
cooking_powers(6,1) = p_app_2_fan;

cooking_q_powers(1,1) = q_app_1;
cooking_q_powers(2,1) = q_app_2;
cooking_q_powers(3,1) = q_app_3;
cooking_q_powers(4,1) = q_app_4;
cooking_q_powers(5,1) = q_app_5;
cooking_q_powers(6,1) = q_app_2_fan;

cooking_app1_dur_min = 30;
cooking_app1_dur_max = 90;
cooking_app2_dur_min = 15;
cooking_app2_dur_max = 60;
cooking_app3_dur_min = 5;
cooking_app3_dur_max = 20;
cooking_app4_dur_min = 3;
cooking_app4_dur_max = 8;
cooking_app5_dur_min = 2;
cooking_app5_dur_max = 10;

% merge

cooking_app_dur_min(1,1) = cooking_app1_dur_min;
cooking_app_dur_min(2,1) = cooking_app2_dur_min;
cooking_app_dur_min(3,1) = cooking_app3_dur_min;
cooking_app_dur_min(4,1) = cooking_app4_dur_min;
cooking_app_dur_min(5,1) = cooking_app5_dur_min;

cooking_app_dur_max(1,1) = cooking_app1_dur_max;
cooking_app_dur_max(2,1) = cooking_app2_dur_max;
cooking_app_dur_max(3,1) = cooking_app3_dur_max;
cooking_app_dur_max(4,1) = cooking_app4_dur_max;
cooking_app_dur_max(5,1) = cooking_app5_dur_max;

activ=zeros(time_res,1);

p_cooking = zeros(1440,6);
q_cooking = zeros(1440,6);

time_period_start(1,1) = 361;
time_period_start(2,1) = 601;
time_period_start(3,1) = 841;
time_period_start(4,1) = 1081;
time_period_start(5,1) = 1321;
time_period_start(6,1) = 1;

time_period_end(1,1) = 600;
time_period_end(2,1) = 840;
time_period_end(3,1) = 1080;
time_period_end(4,1) = 1320;
time_period_end(5,1) = 1440;
time_period_end(6,1) = 360;

for np10=1:144
    if activ144(np10,4)==1
        occur = randi([1 10]);
        activ((np10-1)*10+occur,1) = activ144(np10,4);
    end
end

for time_period = 1:6
    start_ = time_period_start(time_period);
    end_ = time_period_end(time_period);
    
    actives = find(activ(start_:end_));
    if actives
        active_idxs = actives + start_ - 1;
        for active = 1:length(active_idxs)
            i = active_idxs(active);
            for cooking_app = 1:5
                if (rand(1) <= use_probability(5,cooking_app)) && ...
                        appliance_use(i,cooking_app) == 0
                    
                    dur = randi([cooking_app_dur_min(cooking_app), ...
                        cooking_app_dur_max(cooking_app)]);
                    
                    if i+dur-1<=1440
                        p_cooking(i:i+dur-1, cooking_app) = ...
                            cooking_powers(cooking_app);
                        q_cooking(i:i+dur-1, cooking_app) = ...
                            cooking_q_powers(cooking_app);
                        appliance_use(i:i+dur-1, cooking_app) = 1;
                    else
                        p_cooking(i:1440, cooking_app) = ...
                            cooking_powers(cooking_app);
                        p_cooking(1:i+dur-1-1440, cooking_app) = ...
                            cooking_powers(cooking_app);
                        q_cooking(i:1440, cooking_app) = ...
                            cooking_q_powers(cooking_app);
                        q_cooking(1:i+dur-1-1440, cooking_app) = ...
                            cooking_q_powers(cooking_app);
                        appliance_use(i:1440, cooking_app) = 1;
                        appliance_use(1:i+dur-1-1440, cooking_app) = 1;
                    end
                end
            end
            cooking_app = 2;
            if (rand(1) <= use_probability(5,cooking_app)) && ...
                    appliance_use(i,cooking_app) == 0
                
                dur = randi([cooking_app_dur_min(cooking_app), ...
                    cooking_app_dur_max(cooking_app)]);
                
                if i+dur-1<=1440
                    p_cooking(i:i+dur-1, cooking_app) = ...
                        cooking_powers(cooking_app);
                    p_cooking(i:i+dur-1, 6) = cooking_powers(6);
                    q_cooking(i:i+dur-1, cooking_app) = ...
                        cooking_q_powers(cooking_app);
                    q_cooking(i:i+dur-1, 6) = cooking_q_powers(6);
                    appliance_use(i:i+dur-1, cooking_app) = 1;
                else
                    p_cooking(i:1440, cooking_app) = ...
                        cooking_powers(cooking_app);
                    p_cooking(1:i+dur-1-1440, cooking_app) = ...
                        cooking_powers(cooking_app);
                    p_cooking(i:1440, 6) = cooking_powers(6);
                    p_cooking(1:i+dur-1-1440, 6) = cooking_powers(6);
                    
                    q_cooking(i:1440, cooking_app) = ...
                        cooking_q_powers(cooking_app);
                    q_cooking(1:i+dur-1-1440, cooking_app) = ...
                        cooking_q_powers(cooking_app);
                    q_cooking(i:1440, 6) = cooking_q_powers(6);
                    q_cooking(1:i+dur-1-1440, 6) = cooking_q_powers(6);
                    appliance_use(i:1440, cooking_app) = 1;
                    appliance_use(1:i+dur-1-1440, cooking_app) = 1;
                end
            end
        end
    end
end

end