function[hh_type] = hh_user_type(user_type_pu, agg_size)

% Randomly distribute user behaviour.
%
% Arguments:
%   user_type_pu (array) [-]: Proportion of each user type in the aggregate
%       population;
%   agg_size (int) [-]: The total number of households to be created.
%
% Returns:
%   hh_type (array) [-]: Type of each husehold.

User_type = user_type_pu.*agg_size;
User_type_step2 = round(User_type);
User_type_step3 = sum(sum(User_type_step2));

if User_type_step3 > agg_size
    error = User_type_step3 - agg_size;
    [U_hh_final] = RoundDown(User_type,error);
elseif User_type_step3 < agg_size
    error = agg_size - User_type_step3;
    [U_hh_final] = RoundUp(User_type,error);
else
    U_hh_final =User_type_step2;
end

N = agg_size;

r=randperm(N);

count = 1;
hh_type = zeros(N,1);
for a = 1:N
    index = r(1,a);
    if count <= (U_hh_final(1,1))
        hh_type(index,1) = 0; % User type - 
        count = count+1;
    elseif count <= (U_hh_final(1,2)+U_hh_final(1,1))
        hh_type(index,1) = 1; % User type - 
        count = count+1;
    else
        hh_type(index,1) = 2; % User type - 
        count = count+1;
    end
end
end