function [tv_p, tv_q, ...
          pc_p, pc_q, ...
          monitor_p, monitor_q, ...
          printer_p, printer_q, ...
          music_p, music_q, ...
          phone_p, phone_q, ...
          console_p, console_q, ...
          video_tv_p, video_tv_q] = ce_ict_loads(...
            time_res, activ, distr, distr_q, i, u_beh)

% Convert activities into CE and ICT loads. This covers pcs, laptops,
% consoles, tvs and secondary devices and stereos. As these loads are
% associated with a specific user activity, the activity profile is
% directly converted into active and reactive power demand using the
% appliance data. The user standby behaviour defines the power demand in-
% between active periods.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   activ (array) [-]: Activity profile of the load;
%   distr (cell) [-]: DataStructure to hold the active power
%       characteristics of household appliances;
%   distr_q (cell) [-]: DataStructure to hold the reactive power
%       characteristics of household appliances;
%   i (int) [-]: Household occupant identifier;
%   u_beh (int) [-] : User behaviour type.
%
% Returns:
%   tv_p (array) [W]:  Active power profile of tv load;
%   tv_q (array) [var]:  Reactive power profile of tv load;
%   pc_p (array) [W]:  Active power profile of pc load;
%   pc_q (array) [var]:  Reactive power profile of pc load;
%   monitor_p (array) [W]:  Active power profile of monitor load;
%   monitor_q (array) [var]:  Reactive power profile of monitor load;
%   printer_p (array) [W]:  Active power profile of printer load;
%   printer_q (array) [var]:  Reactive power profile of printer load;
%   music_p (array) [W]:  Active power profile of music player load;
%   music_q (array) [var]:  Reactive power profile of music player load;
%   phone_p (array) [W]:  Active power profile of phone load;
%   phone_q (array) [var]:  Reactive power profile of phone load;
%   game_console_p (array) [W]:  Active power profile of games console
%       load;
%   game_console_q (array) [var]:  Reactive power profile of games console
%       load;
%   video_tv_p (array) [W]:  Active power profile of video/dvd load;
%   video_tv_q (array) [var]:  Reactive power profile of video/dvd load.
        
if ~(u_beh==2)
    stbm = u_beh;
else
    stbm = 1;
end

%% PC-Monitor-Printer
pc_p = zeros(time_res, 1);
pc_q = zeros(time_res, 1);
monitor_p = zeros(time_res, 1);
monitor_q = zeros(time_res, 1);
printer_p = zeros(time_res, 1);
printer_q = zeros(time_res, 1);

start_time = find(activ(:,10), 1, 'first');
end_time = find(activ(:,10), 1, 'last');

pc_p_rated_on = distr{5}(i,1);
pc_q_rated_on = distr_q{5}(i,1);

if distr{5}(i,3)==1
    pc_q_rated_on = -pc_q_rated_on;
end

pc_p_rated_standby = distr{6}(i,1)*stbm;
pc_q_rated_standby = distr_q{6}(i,1)*stbm;

monitor_p_rated_standby = distr{8}(i,1)*stbm;
monitor_q_rated_standby = distr_q{8}(i,1)*stbm;
printer_p_rated_standby = distr{21}(1,2)*stbm;
printer_q_rated_standby = -distr_q{21}(1,2)*stbm;

monitor_p_rated_on = distr{7}(i,1);
monitor_q_rated_on = distr_q{7}(i,1);

printer_p_rated_on = distr{21}(1,1);
printer_q_rated_on = -distr_q{21}(1,1);

for j = start_time:end_time
    switch activ(j, 10)
        case 1
            pc_p(j) = pc_p_rated_on;
            pc_q(j) = pc_q_rated_on;
            monitor_p(j) = monitor_p_rated_on;
            monitor_q(j) = monitor_q_rated_on;
            printer_p(j) = printer_p_rated_on;
            printer_q(j) = -printer_q_rated_on;
        case 0
            pc_p(j) = pc_p_rated_standby;
            pc_q(j) = pc_q_rated_standby;
            monitor_p(j) = monitor_p_rated_standby;
            monitor_q(j) = monitor_q_rated_standby;
            printer_p(j) = printer_p_rated_standby;
            printer_q(j) = printer_q_rated_standby;
    end
end

%% TV
tv_p = zeros(time_res, 1);
tv_q = zeros(time_res, 1);

tv_p_rated_on = distr{1}(i,1);
tv_q_rated_on = distr_q{1}(i,1);

if distr{1}(i,2) == 1
    tv_q_rated_on = -1*tv_q_rated_on;
end

tv_p_rated_standby = distr{2}(i,1)*stbm;
tv_q_rated_standby = distr_q{2}(i,1)*stbm;

if distr{1}(i,2)==1
    tv_q_rated_standby = tv_q_rated_standby*-1;
end

start_time = find(activ(:,12),1,'first');
end_time = find(activ(:,12),1,'last');

for j = start_time:end_time
    switch activ(j, 12)
        case 1
            tv_p(j) = tv_p_rated_on;
            tv_q(j) = tv_q_rated_on;
        case 0
            tv_q(j) = tv_p_rated_standby;
            tv_q(j) = tv_q_rated_standby;
    end
end

%% Game consoles 

console_p = (distr{23} + distr{1}(i,1))*activ(:,11);
console_q = (distr_q{23} + distr_q{1}(i,1))*activ(:,11);

% Video

video_p = zeros(time_res, 1);
video_q = zeros(time_res, 1);
video_tv_p = zeros(time_res, 1);
video_tv_q = zeros(time_res, 1);

video_p_rated_on = distr{3};
video_q_rated_on = -distr_q{3};

video_tv_p_rated_on = distr{1}(i,1);
video_tv_q_rated_on = distr_q{1}(i,1);

if distr{1}(i,2)==1
    video_tv_q_rated_on=-video_tv_q_rated_on;
end

video_p_rated_standby = distr{4}*stbm;
video_q_rated_standby = distr_q{4}*stbm;
video_tv_p_rated_standby = distr{2}(i,1)*stbm;
video_tv_q_rated_standby = distr_q{2}(i,1)*stbm;

if distr{1}(i,2)==1
    video_tv_q_rated_standby = -video_tv_q_rated_standby;
end

start_time = find(activ(:,13),1,'first');
end_time = find(activ(:,13),1,'last');

for j = start_time:end_time
    switch activ(j, 13)
        case 1
            video_p(j) = video_p_rated_on;
            video_q(j) = video_q_rated_on;
            video_tv_p(j) = video_tv_p_rated_on;
            video_tv_q(j) = video_tv_q_rated_on;
        case 0
            video_p(j) = video_p_rated_standby;
            video_q(j) = video_q_rated_standby;
            video_tv_p(j) = video_tv_p_rated_standby;
            video_tv_q(j) = video_tv_q_rated_standby;
    end
end

%% Music
music_p = zeros(time_res, 1);
music_q = zeros(time_res, 1);

music_p_rated_on = distr{9};
music_q_rated_on = distr_q{9};
music_p_rated_standby = distr{10}*stbm;
music_q_rated_standby =  distr_q{10}*stbm;

start_time = find(activ(:,14),1,'first');
end_time = find(activ(:,14),1,'last');

for j = start_time:end_time
    switch activ(j,14)
        case 1
            music_p(j) = music_p_rated_on;
            music_q(j) = music_q_rated_on;
        case 0
            music_p(j) = music_p_rated_standby;
            music_q(j) = music_q_rated_standby;
    end
end

%% Phone-FAX
phone_p = distr{22};
phone_q = distr_q{22};

end
