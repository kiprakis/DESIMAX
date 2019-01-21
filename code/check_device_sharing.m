function[current] = check_device_sharing(current, n_occ, devicesharing)

% Check for device sharing and update activity profiles accordingly. For
% multiple occupancy households, there is a probability that certain
% appliances will be used by more than one occupant at any given time. The 
% algorithm identifies every time period when multiple users have the same 
% activity and uses the device sharing probability to determine if the 
% activity is shared or not. If the activity is shared then the activity 
% occurence is removed from the secondary user to avoid double counting of 
% the load use.
%
% Arguments:
%   current (array; 144, hh_size) [-]: Activity profile of the household 
%       users.
%   n_occ (int) [-]: The number of occupants in the household.
%   devicesharing (array; 15, 144) [pu]: Array of probabilities of activity
%       sharing for the given user type.
%
% Returns:
%   current (array; 144, hh_size) [-]: Updated activity profile of the 
%       household users.

% Generate random numbers
a = 0;
b = 1;
r = a + (b-a).*rand(144,1);

% Algorithm
if n_occ == 2
    % check activity five
    countuser15 = 0;
    countuser25 = 0;
    for tcheck5 = 1:144
        if current(tcheck5,1) == 5;
            countuser15 = countuser15 + 1;
        end
        if current(tcheck5,2) == 5;
            countuser25 = countuser25 + 1;
        end
    end
    if (countuser15 >= countuser25)
        for tdelete5 = 1:144
            if current(tdelete5,2) == 5;
                current(tdelete5,2) = 1;
            end
        end
    elseif (countuser25 > countuser15)
        for tdelete5 = 1:144
            if current(tdelete5,1) == 5;
                current(tdelete5,1) = 1;
            end
        end
    end
    % check activity eight
    countuser18 = 0;
    countuser28 = 0;
    for tcheck8 = 1:144
        if current(tcheck8,1) ==8;
            countuser18 = countuser18+1;
        end
        if current(tcheck8,2) ==8;
            countuser28 = countuser28+1;
        end
    end
    if (countuser18 >= countuser28)
        for tdelete8 = 1:144
            if current(tdelete8,2) ==8;
                current(tdelete8,2) = 1;
            end
        end
    elseif (countuser28 > countuser18)
        for tdelete8 = 1:144
            if current(tdelete8,1) ==8;
                current(tdelete8,1) = 1;
            end
        end
    end
    
    for t = 1:144
        if current(t,1) == current(t,2)
            activity = current(t,1);
            if activity == 1
                current(t,1) = 1;
            elseif activity == 3
                current(t,1) = 3;
            elseif activity == 4
                current(t,2) = 1;
            elseif activity == 5
                current(t,2) = 1;
            elseif activity == 6
                current(t,2) = 1;
            elseif activity == 7
                current(t,2) = 1;
            elseif activity == 8
                current(t,2) = 1;
            elseif activity == 9
                current(t,2) = 1;
            elseif activity == 16
                current(t,1) = 16;
            elseif r(t,1) <= devicesharing(activity,t)
                current(t,2) = 1;
            end
        end
    end
    
elseif n_occ == 3
    % check activity five
    countuser15 = 0; 
    countuser25 = 0;
    countuser35 = 0;
    for tcheck5 = 1:144
        if current(tcheck5,1) == 5;
            countuser15 = countuser15 + 1;
        end
        if current(tcheck5,2) == 5;
            countuser25 = countuser25 + 1;
        end
        if current(tcheck5,3) == 5;
            countuser35 = countuser35+1;
        end
    end
    if (countuser15 >= countuser25) && (countuser15 >= countuser35)
        for tdelete5 = 1:144
            if current(tdelete5,2) == 5;
                current(tdelete5,2) = 1;
            end
            if current(tdelete5,3) == 5;
                current(tdelete5,3) = 1;
            end
        end
    elseif (countuser25 >= countuser15) && (countuser25 >= countuser35)
        for tdelete5 = 1:144
            if current(tdelete5,1) == 5;
                current(tdelete5,1) = 1;
            end
            if current(tdelete5,3) == 5;
                current(tdelete5,3) = 1;
            end
        end
    elseif (countuser35 >= countuser15) && (countuser35 >= countuser25)
        for tdelete5 = 1:144
            if current(tdelete5,1) == 5;
                current(tdelete5,1) = 1;
            end
            if current(tdelete5,2) == 5;
                current(tdelete5,2) = 1;
            end
        end
    end
    %check activity eight
    countuser18=0;
    countuser28=0;
    countuser38=0;
    for tcheck8 = 1:144
        if current(tcheck8,1) == 8;
            countuser18 = countuser18 + 1;
        end
        if current(tcheck8,2) == 8;
            countuser28 = countuser28 + 1;
        end
        if current(tcheck8,3) == 8;
            countuser38 = countuser38 + 1;
        end
    end
    if (countuser18 >= countuser28) && (countuser18 >= countuser38)
        for tdelete8 = 1:144
            if current(tdelete8,2) == 8;
                current(tdelete8,2) = 1;
            end
            if current(tdelete8,3) == 8;
                current(tdelete8,3) = 1;
            end
        end
    elseif (countuser28 >= countuser18) && (countuser28 >= countuser38)
        for tdelete8 = 1:144
            if current(tdelete8,1) == 8;
                current(tdelete8,1) = 1;
            end
            if current(tdelete8,3) == 8;
                current(tdelete8,3) = 1;
            end
        end
    elseif (countuser38 >= countuser18) && (countuser38 >= countuser28)
        for tdelete8 = 1:144
            if current(tdelete8,1) == 8;
                current(tdelete8,1) = 1;
            end
            if current(tdelete8,2) == 8;
                current(tdelete8,2) = 1;
            end
        end
    end
    actcount = zeros(16,144);
    for t = 1:144
        for activity = 1:16
            for users = 1:3
                if current(t,users) == activity
                    actcount(activity,t) = actcount(activity,t) + 1;
                end
            end
        end
        for activity = 1:15
            if actcount(activity,t) == 2
                if  devicesharing{2,1}(activity,t) <= ...
                        devicesharing{2,2}(activity,t)
                    
                    Prob(1,1) = devicesharing{2,1}(activity,t);
                    Prob(1,2) = 1;
                    Prob(2,1) = devicesharing{2,2}(activity,t);
                    Prob(2,2) = 2; 
                else
                    Prob(1,1) = devicesharing{2,2}(activity,t);
                    Prob(1,2) = 2; 
                    Prob(2,1) = devicesharing{2,1}(activity,t);
                    Prob(2,2) = 1; 
                end
                if activity == 3
                    current(t,1) = 3;
                elseif activity == 16;
                    current(t,1) = 16;
                elseif activity ==1;
                    current(t,1) = 1;
                elseif activity == 2;
                    current(t,1) = 2; 
                elseif current(t,1) == current(t,2)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1 
                            current(t,2) = 1; 
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1 
                            current(t,2) = 1;
                        end
                    end
                elseif current(t,1) == current(t,3)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1 
                            current(t,3) = 1; 
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1 
                            current(t,3) = 1; 
                        end
                    end
                elseif current(t,2) == current(t,3)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1 
                            current(t,3) = 1; 
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1
                            current(t,3) = 1; 
                        end
                    end
                end
            end
            if actcount(activity,t) == 3
                val1 = devicesharing{1,1}(activity,t);
                val2 = devicesharing{1,2}(activity,t);
                val3 = devicesharing{1,3}(activity,t);
                if val1 <= val2 && val1 <= val3 && val2 <= val3
                     
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2;  
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3;  
                elseif val1 <= val2 && val1 <=val3 && val3 <=val2
                    
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2;  
                elseif val2 <= val1 && val2 <=val3 && val1 <=val3
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1;  
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3;  
                elseif val2 <= val1 && val2 <= val3 && val3 <= val1
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1;  
                elseif val3 <= val1 && val3 <= val2 && val1 <= val2
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3;  
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1; 
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2; 
                elseif val3 <=val1 && val3 <= val2 && val2 <= val1
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3; 
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2; 
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1; 
                end
                if activity ==1
                    current(t,1) = 1; 
                elseif activity ==2;
                    current(t,1) = 2; 
                elseif activity == 3
                    current(t,1) = 3; 
                elseif activity ==16;
                    current(t,1) = 16;  
                elseif (current(t,1) == current(t,2)) && ...
                        (current(t,1) == current(t,3))
                    
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                        elseif Prob(1,2) == 2
                            current(t,3) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                        elseif Prob(2,2) == 2;
                            current(t,3) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1) + Prob(3,1)
                        if Prob(3,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                        elseif Prob(3,2) == 2;
                            current(t,3) = 1;
                        end
                    end
                end
            end
        end
    end
    
elseif n_occ == 4
    
    % check activity five
    countuser15=0;
    countuser25=0;
    countuser35=0;
    countuser45=0;

    for tcheck5 = 1:144
        if current(tcheck5,1) == 5;
            countuser15 = countuser15 + 1;
        end
        if current(tcheck5,2) == 5;
            countuser25 = countuser25 + 1;
        end
        if current(tcheck5,3) == 5;
            countuser35 = countuser35 + 1;
        end
        if current(tcheck5,4) == 5;
            countuser45 = countuser45 + 1;
        end
    end

    if (countuser15 >= countuser25) && (countuser15 >= countuser35) && ...
            (countuser15 >= countuser45)

        for tdelete5 = 1:144
            if current(tdelete5,2) == 5;
                current(tdelete5,2) = 1;
            end
            if current(tdelete5,3) == 5;
                current(tdelete5,3) = 1;
            end
            if current(tdelete5,4) == 5;
                current(tdelete5,4) = 1;
            end
        end
    
    elseif (countuser25 >= countuser15) && (countuser25 >= countuser35) ...
            && (countuser25 >= countuser45)

        for tdelete5 = 1:144
            if current(tdelete5,1) == 5;
                current(tdelete5,1) = 1;
            end
            if current(tdelete5,3) == 5;
                current(tdelete5,3) = 1;
            end
            if current(tdelete5,4) == 5;
                current(tdelete5,4) = 1;
            end
        end
    
    elseif (countuser35 >= countuser15) && (countuser35 >= countuser25) ...
            && (countuser35 >= countuser45)

        for tdelete5 = 1:144
            if current(tdelete5,1) == 5;
                current(tdelete5,1) = 1;
            end
            if current(tdelete5,2) == 5;
                current(tdelete5,2) = 1;
            end
            if current(tdelete5,4) == 5;
                current(tdelete5,4) = 1;
            end
        end
    
    elseif (countuser45 >= countuser15) && (countuser45 >= countuser25) ...
            && (countuser45 >= countuser35)

        for tdelete5 = 1:144
            if current(tdelete5,1) == 5;
                current(tdelete5,1) = 1;
            end
            if current(tdelete5,2) == 5;
                current(tdelete5,2) = 1;
            end
            if current(tdelete5,3) == 5;
                current(tdelete5,3) = 1;
            end
        end
    end
    
    % check activity eight
    countuser18=0;
    countuser28=0;
    countuser38=0;
    countuser48=0;

    for tcheck8 = 1:144
        if current(tcheck8,1) == 8;
            countuser18 = countuser18 + 1;
        end
        if current(tcheck8,2) == 8;
            countuser28 = countuser28 + 1;
        end
        if current(tcheck8,3) == 8;
            countuser38 = countuser38 + 1;
        end
        if current(tcheck8,4) == 8;
            countuser48 = countuser48 + 1;
        end
    end

    if (countuser18 >= countuser28) && (countuser18 >= countuser38) && ...
            (countuser18 >= countuser48)

        for tdelete8 = 1:144
            if current(tdelete8,2) == 8;
                current(tdelete8,2) = 1;
            end
            if current(tdelete8,3) == 8;
                current(tdelete8,3) = 1;
            end
            if current(tdelete8,4) == 8;
                current(tdelete8,4) = 1;
            end
        end
    
    elseif (countuser28 >= countuser18) && (countuser28 >= countuser38) ...
            && (countuser28 >= countuser48)

        for tdelete8 = 1:144
            if current(tdelete8,1) == 8;
                current(tdelete8,1) = 1;
            end
            if current(tdelete8,3) == 8;
                current(tdelete8,3) = 1;
            end
            if current(tdelete8,4) == 8;
                current(tdelete8,4) = 1;
            end
        end
    
    elseif (countuser38 >= countuser18) && (countuser38 >= countuser28) ...
            && (countuser38 >= countuser48)

        for tdelete8 = 1:144
            if current(tdelete8,1) == 8;
                current(tdelete8,1) = 1;
            end
            if current(tdelete8,2) == 8;
                current(tdelete8,2) = 1;
            end
            if current(tdelete8,4) == 8;
                current(tdelete8,4) = 1;
            end
        end

    elseif (countuser48 >= countuser18) && (countuser48 >= countuser28) ...
            && (countuser48 >= countuser38)

        for tdelete8 = 1:144
            if current(tdelete8,1) == 8;
                current(tdelete8,1) = 1;
            end
            if current(tdelete8,2) == 8;
                current(tdelete8,2) = 1;
            end
            if current(tdelete8,3) == 8;
                current(tdelete8,3) = 1;
            end
        end
    end
    actcount = zeros(16,144);
    for t = 1:144
        for activity = 1:16
            for users = 1:n_occ
                if current(t,users) == activity
                    actcount(activity,t) = actcount(activity,t) + 1;
                end
            end
        end
        for activity = 1:15
            if actcount(activity,t) == 2 
                if  devicesharing{3,1}(activity,t) <= ...
                        devicesharing{3,2}(activity,t)

                    Prob(1,1) = devicesharing{3,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{3,2}(activity,t);
                    Prob(2,2) = 2;  
                else
                    Prob(1,1) = devicesharing{3,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{3,1}(activity,t);
                    Prob(2,2) = 1;  
                end
                if activity == 3
                    current(t,1) = 3;  
                elseif activity == 16;
                    current(t,1) = 16;  
                elseif activity == 1;
                    current(t,1) = 1;  
                elseif activity == 2;
                    current(t,1) = 2;  
                elseif current(t,1) == current(t,2)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1  
                            current(t,2) = 1;  
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1  
                            current(t,2) = 1;  
                        end
                    end
                elseif current(t,1) == current(t,3)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1  
                            current(t,3) = 1;  
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1  
                            current(t,3) = 1;  
                        end
                    end
                elseif current(t,1) == current(t,4)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1  
                            current(t,4) = 1;  
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1  
                            current(t,4) = 1;  
                        end
                    end
                elseif current(t,2) == current(t,3)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1  
                            current(t,3) = 1;  
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1  
                            current(t,3) = 1;  
                        end
                    end
                elseif current(t,2) == current(t,4)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1  
                            current(t,4) = 1;  
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1  
                            current(t,4) = 1;  
                        end
                    end
                elseif current(t,3) == current(t,4)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1  
                            current(t,4) = 1;  
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1  
                            current(t,4) = 1;  
                        end
                    end
                end
            end
            if actcount(activity,t) == 3
                val1 = devicesharing{2,1}(activity,t);
                val2 = devicesharing{2,2}(activity,t);
                val3 = devicesharing{2,3}(activity,t);
                if val1 <= val2 && val1 <= val3 && val2 <= val3
                    Prob(1,1) = devicesharing{2,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{2,2}(activity,t);
                    Prob(2,2) = 2;  
                    Prob(3,1) = devicesharing{2,3}(activity,t);
                    Prob(3,2) = 3;  
                elseif val1 <= val2 && val1 <= val3 && val3 <= val2
                    Prob(1,1) = devicesharing{2,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{2,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{2,2}(activity,t);
                    Prob(3,2) = 2;  
                elseif val2 <= val1 && val2 <= val3 && val1 <= val3
                    Prob(1,1) = devicesharing{2,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{2,1}(activity,t);
                    Prob(2,2) = 1;  
                    Prob(3,1) = devicesharing{2,3}(activity,t);
                    Prob(3,2) = 3;  
                elseif val2 <= val1 && val2 <= val3 && val3 <= val1
                    Prob(1,1) = devicesharing{2,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{2,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{2,1}(activity,t);
                    Prob(3,2) = 1;  
                elseif val3 <= val1 && val3 <= val2 && val1 <= val2
                    Prob(1,1) = devicesharing{2,3}(activity,t);
                    Prob(1,2) = 3;  
                    Prob(2,1) = devicesharing{2,1}(activity,t);
                    Prob(2,2) = 1;  
                    Prob(3,1) = devicesharing{2,2}(activity,t);
                    Prob(3,2) = 2;  
                elseif val3 <= val1 && val3 <= val2 && val2 <= val1
                    Prob(1,1) = devicesharing{2,3}(activity,t);
                    Prob(1,2) = 3;  
                    Prob(2,1) = devicesharing{2,2}(activity,t);
                    Prob(2,2) = 2;  
                    Prob(3,1) = devicesharing{2,1}(activity,t);
                    Prob(3,2) = 1;  
                end
                if activity == 1
                    current(t,1) = 1;  
                elseif activity == 2;
                    current(t,1) = 2;  
                elseif activity == 3
                    current(t,1) = 3;  
                elseif activity == 16;
                    current(t,1) = 16;
                elseif (current(t,1) == current(t,2)) && ...
                        (current(t,1) == current(t,3))
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                        elseif Prob(1,2) == 2
                            current(t,3) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                        elseif Prob(2,2) == 2;
                            current(t,3) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1) + Prob(3,1)
                        if Prob(3,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                        elseif Prob(3,2) == 2;
                            current(t,3) = 1;
                        end
                    end
                elseif (current(t,1) == current(t,2)) && ...
                        (current(t,1) == current(t,4))
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1
                            current(t,2) = 1;
                            current(t,4) = 1;
                        elseif Prob(1,2) == 2
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1
                            current(t,2) = 1;
                            current(t,4) = 1;
                        elseif Prob(2,2) == 2;
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1) + Prob(3,1)
                        if Prob(3,2) == 1
                            current(t,2) = 1;
                            current(t,4) = 1;
                        elseif Prob(3,2) == 2;
                            current(t,4) = 1;
                        end
                    end
                elseif (current(t,1) == current(t,3)) && ...
                        (current(t,1) == current(t,4))
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(1,2) == 2
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(2,2) == 2;
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1) + Prob(3,1)
                        if Prob(3,2) == 1
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(3,2) == 2;
                            current(t,4) = 1;
                        end
                    end
                elseif (current(t,2) == current(t,3)) && ...
                        (current(t,2) == current(t,4))
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(1,2) == 2
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(2,2) == 2;
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1) + Prob(3,1)
                        if Prob(3,2) == 1
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(3,2) == 2;
                            current(t,4) = 1;
                        end
                    end
                end
            end
            if actcount(activity,t) == 4
                val1 = devicesharing{1,1}(activity,t);
                val2 = devicesharing{1,2}(activity,t);
                val3 = devicesharing{1,3}(activity,t);
                val4 = devicesharing{1,4}(activity,t);
                if val1 <= val2 && val2 <= val3 && val3 <= val4
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2;
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3;
                    Prob(4,1) = devicesharing{1,4}(activity,t);
                    Prob(4,2) = 4;
                elseif val1 <= val2 && val2 <= val4 && val4 <= val3
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2;
                    Prob(3,1) = devicesharing{1,4}(activity,t);
                    Prob(3,2) = 4;
                    Prob(4,1) = devicesharing{1,3}(activity,t);
                    Prob(4,2) = 3;
                elseif val1 <= val3 && val3 <= val2 && val2 <= val4
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2;  
                    Prob(4,1) = devicesharing{1,4}(activity,t);
                    Prob(4,2) = 4;  
                elseif val1 <= val3 && val3 <= val4 && val4 <= val2
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{1,4}(activity,t);
                    Prob(3,2) = 4;  
                    Prob(4,1) = devicesharing{1,2}(activity,t);
                    Prob(4,2) = 2;  
                elseif val1 <= val4 && val4 <= val2 && val2 <= val3
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{1,4}(activity,t);
                    Prob(2,2) = 4;
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2;
                    Prob(4,1) = devicesharing{1,3}(activity,t);
                    Prob(4,2) = 3;
                elseif val1 <= val4 && val4 <= val3 && val3 <= val2
                    Prob(1,1) = devicesharing{1,1}(activity,t);
                    Prob(1,2) = 1;  
                    Prob(2,1) = devicesharing{1,4}(activity,t);
                    Prob(2,2) = 4;  
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3;  
                    Prob(4,1) = devicesharing{1,2}(activity,t);
                    Prob(4,2) = 2;  
                elseif val2 <= val1 && val1 <= val3 && val3 <= val4
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2; 
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1; 
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3;  
                    Prob(4,1) = devicesharing{1,4}(activity,t);
                    Prob(4,2) = 4;  
                elseif val2 <= val1 && val1 <= val4 && val4 <= val3
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2; 
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1; 
                    Prob(3,1) = devicesharing{1,4}(activity,t);
                    Prob(3,2) = 4;  
                    Prob(4,1) = devicesharing{1,3}(activity,t);
                    Prob(4,2) = 3;  
                elseif val2 <= val3 && val3 <= val1 && val1 <= val4
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2; 
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1;  
                    Prob(4,1) = devicesharing{1,4}(activity,t);
                    Prob(4,2) = 4;  
                elseif val2 <= val3 && val3 <= val4 && val4 <= val1
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3;  
                    Prob(3,1) = devicesharing{1,4}(activity,t);
                    Prob(3,2) = 4;  
                    Prob(4,1) = devicesharing{1,1}(activity,t);
                    Prob(4,2) = 1;  
                elseif val2 <= val4 && val4 <= val1 && val1 <= val3
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{1,4}(activity,t);
                    Prob(2,2) = 4;  
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1;  
                    Prob(4,1) = devicesharing{1,3}(activity,t);
                    Prob(4,2) = 3;  
                elseif val2 <= val4 && val4 <= val3 && val3 <= val1
                    Prob(1,1) = devicesharing{1,2}(activity,t);
                    Prob(1,2) = 2;  
                    Prob(2,1) = devicesharing{1,4}(activity,t);
                    Prob(2,2) = 4;  
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3;  
                    Prob(4,1) = devicesharing{1,1}(activity,t);
                    Prob(4,2) = 1;  
                elseif val3 <= val1 && val1 <= val2 && val2 <= val4
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3;  
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1;  
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2;  
                    Prob(4,1) = devicesharing{1,4}(activity,t);
                    Prob(4,2) = 4;  
                elseif val3 <= val1 && val1 <= val4 && val4 <= val2
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3;  
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1;  
                    Prob(3,1) = devicesharing{1,4}(activity,t);
                    Prob(3,2) = 4;  
                    Prob(4,1) = devicesharing{1,2}(activity,t);
                    Prob(4,2) = 2;  
                elseif val3 <= val2 && val2 <= val1 && val1 <= val4
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3;  
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2;  
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1;  
                    Prob(4,1) = devicesharing{1,4}(activity,t);
                    Prob(4,2) = 4;  
                elseif val3 <= val2 && val2 <= val4 && val4 <= val1
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3; 
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2;  
                    Prob(3,1) = devicesharing{1,4}(activity,t);
                    Prob(3,2) = 4;  
                    Prob(4,1) = devicesharing{1,1}(activity,t);
                    Prob(4,2) = 1;  
                elseif val3 <= val4 && val4 <= val1 && val1 <= val2
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3; 
                    Prob(2,1) = devicesharing{1,4}(activity,t);
                    Prob(2,2) = 4;
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1;
                    Prob(4,1) = devicesharing{1,2}(activity,t);
                    Prob(4,2) = 2;
                elseif val3 <= val4 && val4 <= val2 && val2 <= val1
                    Prob(1,1) = devicesharing{1,3}(activity,t);
                    Prob(1,2) = 3;
                    Prob(2,1) = devicesharing{1,4}(activity,t);
                    Prob(2,2) = 4;
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2;
                    Prob(4,1) = devicesharing{1,1}(activity,t);
                    Prob(4,2) = 1;
                elseif val4 <= val1 && val1 <= val2 && val2 <= val3
                    Prob(1,1) = devicesharing{1,4}(activity,t);
                    Prob(1,2) = 4; 
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1; 
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2; 
                    Prob(4,1) = devicesharing{1,3}(activity,t);
                    Prob(4,2) = 3; 
                elseif val4 <= val1 && val1 <= val3 && val3 <= val2
                    Prob(1,1) = devicesharing{1,4}(activity,t);
                    Prob(1,2) = 4; 
                    Prob(2,1) = devicesharing{1,1}(activity,t);
                    Prob(2,2) = 1; 
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3; 
                    Prob(4,1) = devicesharing{1,2}(activity,t);
                    Prob(4,2) = 2; 
                elseif val4 <= val2 && val2 <= val1 && val1 <= val3
                    Prob(1,1) = devicesharing{1,4}(activity,t);
                    Prob(1,2) = 4; 
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2; 
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1; 
                    Prob(4,1) = devicesharing{1,3}(activity,t);
                    Prob(4,2) = 3;
                elseif val4 <= val2 && val2 <= val3 && val3 <= val1
                    Prob(1,1) = devicesharing{1,4}(activity,t);
                    Prob(1,2) = 4; 
                    Prob(2,1) = devicesharing{1,2}(activity,t);
                    Prob(2,2) = 2; 
                    Prob(3,1) = devicesharing{1,3}(activity,t);
                    Prob(3,2) = 3; 
                    Prob(4,1) = devicesharing{1,1}(activity,t);
                    Prob(4,2) = 1; 
                elseif val4 <= val3 && val3 <= val1 && val1 <= val2
                    Prob(1,1) = devicesharing{1,4}(activity,t);
                    Prob(1,2) = 4; 
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3; 
                    Prob(3,1) = devicesharing{1,1}(activity,t);
                    Prob(3,2) = 1; 
                    Prob(4,1) = devicesharing{1,2}(activity,t);
                    Prob(4,2) = 2; 
                elseif val4 <= val3 && val3 <= val2 && val2 <= val1
                    Prob(1,1) = devicesharing{1,4}(activity,t);
                    Prob(1,2) = 4; 
                    Prob(2,1) = devicesharing{1,3}(activity,t);
                    Prob(2,2) = 3; 
                    Prob(3,1) = devicesharing{1,2}(activity,t);
                    Prob(3,2) = 2; 
                    Prob(4,1) = devicesharing{1,1}(activity,t);
                    Prob(4,2) = 1; 
                end
                if activity ==1
                    current(t,1) = 1; 
                elseif activity == 2;
                    current(t,1) = 2; 
                elseif activity == 3
                    current(t,1) = 3; 
                elseif activity == 16;
                    current(t,1) = 16; 
                elseif current(t,1) == current(t,2) && ...
                        current(t,1) == current(t,3) && ...
                        current(t,1) == current(t,4)
                    if r(t,1) <= Prob(1,1)
                        if Prob(1,2) == 1 
                            current(t,2) = 1;
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(1,2) == 2 
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(1,2) == 3 
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1)
                        if Prob(2,2) == 1 
                            current(t,2) = 1;
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(2,2) == 2; 
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(2,2) == 3; 
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= Prob(1,1) + Prob(2,1) + Prob(3,1)
                        if Prob(3,2) == 1
                            current(t,2) = 1;
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(3,2) == 2; 
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(3,2) == 3; 
                            current(t,4) = 1;
                        end
                    elseif r(t,1) <= ...
                            (Prob(1,1) + Prob(2,1) + Prob(3,1) + Prob(4,1))
                        if Prob(4,2) == 1 
                            current(t,2) = 1;
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(4,2) == 2; 
                            current(t,3) = 1;
                            current(t,4) = 1;
                        elseif Prob(4,2) == 3; 
                            current(t,4) = 1;
                        end
                    end
                end
            end
        end
    end
end
end