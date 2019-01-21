function[stateone] = initial_condition(IC, r)

% Sets the initial condition of the user.
%
% Arguments:
%   IC (array) [-]: Probability array of initial condititions;
%   r (float) [-]: A random number.
%
% Returns:
%   stateone (int) [-]: Initial user activity state.

for n = 1:16
    if r <= sum(IC(1:n,1))
        stateone = n;
        break
    end
end
end