function[profiles, ...
         hh_occ] = activity_profile_generation(n_occ, ...
                                               n_working, ...
                                               day, ...
                                               agg_size, ...
                                               TM, ...
                                               IC, ...
                                               Sharing)

% Generate household occupant activity profiles.
%
% Arguments:
%   n_occ (int) [-]: The number of occupants in the household;
%   n_working (int) [-]: The number of working occupants in the household;
%   day (int) [-]: Day identifier;
%   agg_size (int) [-]: The total number of households to be created;
%   TM (cell) [-]: DataStructure to hold the transition matrix
%       probabilities;.
%   IC (cell) [-]: DataStructure to hold the transition matrix
%       probabilities;
%   Sharing (cell) [-]: DataStructure to hold the transition matrix
%       probabilities.
%
% Returns:
%   profiles (cell) [-]: DataStructure to hold the user activity profiles;
%   hh_occ (array) [-]: DataStructure to hold the overall household
%      occupancy data.

% Generate all random numbers
a = 0;
b = 1; % set limits
rtot = a + (b-a).*rand(144, agg_size*n_occ);

% Get transition matrix, initial conditions and sharing probabilities
transition_matrix = TM{1,n_occ}{n_working+1,day};
initial_conditions = IC{1,n_occ}{n_working+1,day};

if n_occ > 1
    device_sharing = Sharing{1,n_occ}{1,n_working+1}{1,day};
end

% Initiate return vars
profiles = cell(agg_size,1);
hh_occ = zeros(144,agg_size);

% Algorithm
if n_occ == 1
    for e = 1:agg_size
        current = zeros(144,1);
        UserProfile = zeros(144,17);
        rv = rtot(1,e);
        r = rtot;
        [nextvalue] = initial_condition(initial_conditions,rv);
        current(1,1) = nextvalue;
        UserProfile(1,current(1,1)) = UserProfile(1,current(1,1)) +1 ;
        if ((UserProfile(1,2) == 1) || (UserProfile(1,15) == 1) || ...
                (UserProfile(1,16) == 1))
            UserProfile(1,17) = UserProfile(1,17) + 0;
        else
            UserProfile(1,17) = UserProfile(1,17) + 1;
        end
        for d = 1:143
            CurrentMatrix = cell2mat(transition_matrix(d));
            var = current(d,1);
            for nextvar = 1:16
                if r(d+1,e) <= sum(CurrentMatrix(var,1:nextvar))
                    current(d+1,1)=nextvar;
                    UserProfile(d+1,current(d+1,1)) = ...
                        UserProfile(d+1,current(d+1,1)) + 1;
                    if ((UserProfile(d+1,2) == 1) || ...
                            (UserProfile(d+1,15) == 1) || ...
                            (UserProfile(d+1,16) == 1))
                        UserProfile(d+1,17) = UserProfile(d+1,17) + 0;
                    else
                        UserProfile(d+1,17) = UserProfile(d+1,17) + 1;
                    end
                    break
                end
            end
        end
        profiles{e}{1,1} = UserProfile;
        hh_occ(:, e) = UserProfile(:,17);
    end
else
    randomcounter = 1;
    for n = 1:agg_size
        current = zeros(144,n_occ);
        for e = 1:n_occ
            rv = rtot(1,randomcounter);
            r = rtot(:,randomcounter);
            [nextvalue] = initial_condition(initial_conditions,rv);
            current(1,e) = nextvalue;
            for d = 1:143
                CurrentMatrix = cell2mat(transition_matrix(d));
                var = current(d,e);
                for nextvar = 1:16
                    if r(d+1,1) <= sum(CurrentMatrix(var,1:nextvar))
                        current(d+1,e) = nextvar;
                        break
                    end
                end
            end
            randomcounter = randomcounter + 1;
        end
        [current] = check_device_sharing(current, n_occ, device_sharing);
        for b = 1:n_occ
            UserProfile = zeros(144,17);
            for t = 1:144
                UserProfile(t,current(t,b)) = ...
                    UserProfile(t,current(t,b)) + 1;
                if ((UserProfile(t,2) == 1) || (UserProfile(t,15) == 1)...
                        || (UserProfile(t,16) == 1))
                    UserProfile(t,17) = UserProfile(t,17) + 0;
                else
                    UserProfile(t,17) = UserProfile(t,17) + 1;
                end
            end
            profiles{n}{b,1} = UserProfile;
            hh_occ(:, n) = hh_occ(:, n) + UserProfile(:,17);
        end
    end
end
end