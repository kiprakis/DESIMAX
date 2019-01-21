function[N_hh_final] = round_hh_composition(N_hh_composition_step1,error, type)

% Round the household composition numbers to equal
% the total population size.
%
% Arguments:
%   N_hh_composition_step1 (array) [-]: Unrounded values;
%   error (num) [-]: Size of the difference between the unrounded values
%       and the defined aggregate size;
%   type (int) [-]: Identify if the unrounded values are over or under the
%       defined aggregate size.
%
% Returns:
%   N_hh_final (array) [-]: Corrected values.

dim = size(N_hh_composition_step1);

j=1;
for i=1:dim(1)
    A_temp(j:j+dim(2)-1) = N_hh_composition_step1(i,:);
    j=j+dim(2);
end

integ = zeros(1, dim(1)*dim(2));
A = zeros(1, dim(1)*dim(2));

for x = 1:(dim(1)*dim(2))
    integ(1,x) = floor(A_temp(1,x));
    A(1,x) = A_temp(1,x) - integ(1,x);
end
A(2,:)=1:(dim(1)*dim(2));

if type == 1
    
    [~,I]=sort(A(1,:));
    B=A(:,I);
    
    n=0;
    
    for m = 1:(dim(1)*dim(2))
        if n < error
            if B(1,m) >= 0.5
                B(1,m) = 0;
                n=n+1;
            end
        else
            break
        end
    end
    
elseif type == 2
    [~,I]=sort(A(1,:),'descend');
    B=A(:,I);
    
    n=0;
    
    for m = 1:(dim(1)*dim(2))
        if n < error
            if B(1,m) <= 0.5
                if B(2,m) ~= [3,4,5,9,10,15]
                    B(1,m) = 1;
                    n=n+1;
                end
            end
        else
            break
        end
    end
else
    disp('errore')
end

for z = 1:(dim(1)*dim(2))
    switch B(2,z)
        case 1
            N_hh_final(1,1) = B(1,z);
        case 2
            N_hh_final(1,2) = B(1,z);
        case 3
            N_hh_final(1,3) = B(1,z);
        case 4
            N_hh_final(1,4) = B(1,z);
        case 5
            N_hh_final(1,5) = B(1,z);
        case 6
            N_hh_final(2,1) = B(1,z);
        case 7
            N_hh_final(2,2) = B(1,z);
        case 8
            N_hh_final(2,3) = B(1,z);
        case 9
            N_hh_final(2,4) = B(1,z);
        case 10
            N_hh_final(2,5) = B(1,z);
        case 11
            N_hh_final(3,1) = B(1,z);
        case 12
            N_hh_final(3,2) = B(1,z);
        case 13
            N_hh_final(3,3) = B(1,z);
        case 14
            N_hh_final(3,4) = B(1,z);
        case 15
            N_hh_final(3,5) = B(1,z);
        case 16
            N_hh_final(4,1) = B(1,z);
        case 17
            N_hh_final(4,2) = B(1,z);
        case 18
            N_hh_final(4,3) = B(1,z);
        case 19
            N_hh_final(4,4) = B(1,z);
        case 20
            N_hh_final(4,5) = B(1,z);
    end
end

z=1;
for a = 1:dim(1)
    for b = 1:dim(2)
        N_hh_final(a,b)= N_hh_final(a,b)+integ(1,z);
        z=z+1;
    end
end

N_hh_final = round(N_hh_final);
