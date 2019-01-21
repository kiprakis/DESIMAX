function [p] = heating_loads(time_res, ...
                             distr, ...
                             month, ...
                             set_temperature, ...
                             irradiance, ...
                             hh_occ)

% Calculate household heating demand. Two types of heating system are
% allowed: direct heating and storage heating. For direct heating the power
% demand is dependent on the presence of people in house and a comparison
% between the external and required internal temperature conditions. A
% thermal model of the house is considered to represent the heat transfer
% between the internal and external environments. For storage heating, a
% look-up table is consulted to define the storage required for the given
% month.
%
% Arguments:
%   time_res (int) [min]: Simulation time step;
%   distr (cell) [-]: DataStructure to hold the active power
%       characteristics of household appliances;
%   month (int) [-]: Month of the year;
%   set_temperature (array) [Degree C]: Cumulative probability of
%       temperature set-point;
%   irradiance (array) [W/m^{2}]: Solar irradiance for the given month;
%   hh_occ (array) [-]: DataStructure to hold the overall household
%       occupancy data.
%
% Returns:
%   p (array) [W]: Active power profile of the heating load.

%% Declare all vars here
% House related values
area_ceiling_mu = 860;
area_ceiling_sigma = 20;
area_ceiling_max = 1620;
area_ceiling_min = 530;

rval_ceiling_min = 38;
rval_ceiling_max = 60;
rval_wall_min = 13;
rval_wall_max = 15;
rval_window_min = 0.8;
rval_window_max = 1;

% Limits
ambient_temp_max = ...
    [5.9, 6.3, 8.5, 11.1, 14.5, 17.3, 18.8, 18.6, 16.2, 12.6,  8.6, 6.6];

ambient_temp_min = ...
    [0.6, 0.5, 1.6, 3.1, 5.7, 8.5, 10.4, 0.4, 8.5, 5.9, 2.9, 1.3];

heat_need = ...
    [1, 0.97, 0.82, 0.63, 0.39, 0.19, 0.09, 0.1, 0.27, 0.52, 0.81, 0.95];

p = zeros(time_res,1);

if distr{35}(1,1) == 2
    
    Pr = distr{35}(2,1);
    charger = randi([5,10])/10;
    s = randi([1,210]);
    dur = randi([360, 420]);
    p(s:s+dur,1) = heat_need(month)*charger*Pr*((square(s:s+dur,75)+1)/2);
    p(:,1) = circshift(p(:,1),[-120,0]);
    p(:,1) = circshift(p(:,1),[randi([-21,22]),0]);
    
else

    activ = kron(hh_occ, ones(10,1));

    binary_occupancy = hh_occ;
    binary_occupancy(hh_occ~=0) = 1;
    binary_occupancy = kron(binary_occupancy, ones(10,1)); 
    occup = circshift(binary_occupancy,[10,0]);

    t1440 = (-pi-(60*2*pi/1440)):(2*pi/1440):(pi-(61*2*pi/1440));
    
    temp_max = ambient_temp_max(month);
    temp_min = ambient_temp_min(month);
    temp_air = 1 + temp_min + (temp_max - temp_min)*cos(t1440);
    temp_air = (9*temp_air/5)+32;
    
    temp = rand(1);
    
    for i=1:15
        if temp < set_temperature(i,2)
            ts = set_temperature(i,1);
            break
        end
    end
    
    Ts = (9*ts/5)+32;
    Tmarg = randi([5,10])/100;
    
    area_ceiling = round(randn(1)*area_ceiling_sigma + area_ceiling_mu);
    area_ceiling(area_ceiling<area_ceiling_min) = area_ceiling_min;
    area_ceiling(area_ceiling>area_ceiling_max) = area_ceiling_max;
    
    Rval_ceiling = randi([rval_ceiling_min, rval_ceiling_max]);
    area_wall = sqrt(area_ceiling)*4*10;
    Rval_wall = randi([rval_wall_min, rval_wall_max]);
    area_window = area_ceiling*0.1;
    Rval_window = randi([rval_window_min*100, rval_window_max*100])/100;
    
    V = area_ceiling*10;
    nac = 0.06*60/V;
    SHGC = randi([6,8])/10;
    Hp = 100;
    
    Dt = 1/60;
    Pr = distr{35}(2,1);
    Ch = distr{35}(3,1);
    Cair = 0.0195;
    Dc = Cair*V;
    
    Wac = zeros(time_res,1);
    
    if rand(1)<0.5
        Wac(1,1)=1;
    end
    
    G = zeros(time_res,1);
    T = zeros(time_res,1);
    T(1,1) = Ts;
    i = 1;
    
    heat_constant_1 = area_ceiling/Rval_ceiling+area_wall/Rval_wall+...
        area_window/Rval_window+11.77*nac*V;
    heat_constant_2 = SHGC*(area_window/4)*3.412/10.76;

    while i<1440
        i=i+1;
        G(i-1,1) = heat_constant_1*(temp_air(1,i-1)-T(i-1,1))+ ...
            heat_constant_2*irradiance(i-1)+Hp*activ(i-1,1);

        T(i,1) = T(i-1,1) + (Dt*G(i-1,1)/Dc) + (Dt*Ch/Dc)*Wac(i-1,1);

        if occup(i-1,1)==1
            if T(i,1)<(Ts-Ts*Tmarg)
                Wac(i,1)=1;
            elseif T(i,1)>(Ts+Ts*Tmarg)
                Wac(i,1)=0;
            else
                Wac(i,1)=Wac(i-1,1);
            end
        end
    end

    p = Wac*Pr*(randi([4,8])/100);
    p(:,1) = circshift(p(:,1),[randi([-15,15]),0]);

end
end