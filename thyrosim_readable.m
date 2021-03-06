%--------------------------------------------------
% FILE:         thyrosim.m
% AUTHOR:       Simon X. Han
% DESCRIPTION:
%   THYROSIM stand alone MATLAB version.
%
%   THYROSIM implmentation based on:
%   All-Condition Thyroid Simulator Eqns 2015-06-29.pdf
%
%   The stand alone version runs fine, but lack the ability to easily add/chain
%   inputs.
% RUN:          >> thyrosim

%-------------------------------------------------- 
% PROJECT: Thyrosim Sensitivity Analysis
% DATE: 3/12/19
% PREPARED BY: Jeannie Huang for CS185
% CHANGES: Created a vary parameters function and helper measure function
% COMMENTS: Parameter descriptions commented by Cymfenee Dean-Phifer, 
%           Eva Wang, Jeannie Huang and Christina De Cesaris
%--------------------------------------------------

% Main function
function thyrosim

% Clean workspace
clc; clear all;

% Initialize variables
initIC;     % Initial conditions
initInputs; % Inputs
initParams; % Parameters

% Sensitivity analysis
varyParams;

% Solve ODE
global tspan ic;
[t,q] = ode45(@ODEs, tspan, ic);

% Graph results
graph(t,q);
end

% Initialize initial conditions
function initIC
global ic
ic(1) = 0.322114215761171;
ic(2) = 0.201296960359917;
ic(3) = 0.638967411907560;
ic(4) = 0.00663104034826483;
ic(5) = 0.0112595761822961;
ic(6) = 0.0652960640300348;
ic(7) = 1.78829584764370;
ic(8) = 7.05727560072869;
ic(9) = 7.05714474742141;
ic(10) = 0;
ic(11) = 0;
ic(12) = 0;
ic(13) = 0;
ic(14) = 3.34289716182018;
ic(15) = 3.69277248068433;
ic(16) = 3.87942133769244;
ic(17) = 3.90061903207543;
ic(18) = 3.77875734283571;
ic(19) = 3.55364471589659;
end

% Initialize inputs
function initInputs
global inf1 inf4 dial tspan
inf1 = 0;               % Infusion into plasma T4
inf4 = 0;               % Infusion into plasma T3
% [T4 Secretion, T4 Absorption, T3 Secretion, T3 Absorption]
dial = [1, 0.88, 1, 0.88];
tspan = [0, 120];       % NOTE: this is hours, not days
end

% Initialize parameter values
function initParams
global inf1 inf4 dial
global u1 u4 kdelay d p
u1 = inf1;
u4 = inf4;
kdelay = 5/8;           %(n-1)/k = t; n comps, t = 8hr
d(1) = dial(1);
d(2) = dial(2);
d(3) = dial(3);
d(4) = dial(4);

% See SR4 in auxiliary. SR4(t) = S4*TSH(t-tau), where S4 is a linear
%coefficent representing the secretion in response to plasma TSH
p(1) = 0.00174155;      %S4
p(2) = 8;               %tau; for a time delay. used in SR3(t) and SR4(t)
p(3) = 0.868;           %k12; conversion rate from fast pool of T4 to free plasma T4 in Figure 3
p(4) = 0.108;           %k13; conversion rate from slow pool of T4 to free plasma T4 in Figure 3
p(5) = 584;             %k31free; conversion rate from free plasma T4 to slow pool of T4 in Figure 3
p(6) = 1503;            %k21free; conversion rate from free plasma T4 to fast pool of T4 in Figure 3
% free plasma hormone is expressed as a function of plasma total hormone
% concentrations in Figure 3. A,B,C,D are estimated coefficients determined
% by fitting the model to known equilibrium relationships. 
% FT4 = (A + BT4 + CT4^2+DT4^3)T4
p(7) = 0.000289;        %A
p(8) = 0.000214;        %B
p(9) = 0.000128;        %C
p(10) = -8.83*10^-6;    %D
p(11) = 0.88;           %k4absorb; originally 0.881, mean L-T4 absorption is 88%, pg.1290
p(12) = 0.0189;         %k02; conversion rate from the fast T4 pool to compartment 0
p(13) = 0.00998996;     %VmaxD1fast; amount of seconds in the equation for converting t4 to t3 from fast pool
p(14) = 2.85;           %KmD1fast; a conversion rate t4 to t3 -> KmD1=1.9 microM
p(15) = 6.63*10^-4;     %VmaxD1slow; amount of seconds in the equation for converting t4 to t3 from the slow pool
p(16) = 95;             %KmD1slow; a conversion rate t4 to t3 -> KmD1=1.9 microM
p(17) = 0.00074619;     %VmaxD2slow; amount of seconds in the equation for converting t4 to t3 from the slow pool
p(18) = 0.075;          %KmD2slow; a conversion rate t4 to t3 -> KmD2=1.9 nanoM
p(19) = 3.3572*10^-4;   %S3; secretory response to plasma TSH concentrations, manifested through the TSH receptor
p(20) = 5.37;           %k45; rate constant in t3 leak from 5(fast) to 4(plasma) in linear model
p(21) = 0.0689;         %k46; rate constant in t3 leak from 4(plasma) to 6(slow) in linear model
p(22) = 127;            %k64free; hormone uptake rate constant in nonlinear model
p(23) = 2043;           %k54free; hormone uptake rate constant in nonlinear model
% free plasma hormone is expressed as a function of plasma total hormone
% concentrations in Figure 3. a,b,c,and d d are estimated coefficients determined
% by fitting the model to known equilibrium relationships. 
% FT3 = (a + bT4 + cT4^2+dT4^3)T3
p(24) = 0.00395;        %a; the constant in the expression of plasma free T3 conc. as affected by protein binding of T3; pg1283 [4]
p(25) = 0.00185;        %b; the coef. of T4*T3 in the expression of plasma free T3 conc. as affected by protein binding of T3
p(26) = 0.00061;        %c; the coef. of T4^2*T3 in the expression of plasma free T3 conc. as affected by protein binding of T3
p(27) = -0.000505;      %d; the coef. of T4^3*T3 in the expression of plasma free T3 conc. as affected by protein binding of T3
p(28) = 0.88;           %k3absorb; originally 0.882 #T3 absorption rate in the gut?
p(29) = 0.207;          %k05, elimination rate of T3, distribution and elimination (D&E) submodel
p(30) = 1166;           %Bzero, the basal TSH secretion rate with no TH, Lumped hypothalamo-pituitary TSH secretion submodel [PMID:18844475]
p(31) = 581;            %Azero, the magnitude of circadian oscillations
p(32) = 2.37;           %Amax ? 
p(33) = -3.71;          %phi, the TSH secretion circadian phase 
p(34) = 0.53;           %kdegTSH-HYPO rate of degredation of TSH in Hypothalamus
p(35) = 0.037;          %VmaxTSH ?
p(36) = 23;             %K50TSH ?
p(37) = 0.118;          %k3; unspecified rate constant
p(38) = 0.29;           %T4P-EU; peripheral plasama concentrations for T4 based on source and sink seperation 
p(39) = 0.006;          %T3P-EU; peripheral plasama concentrations for T3 based on source and sink seperation
p(40) = 0.037;          %KdegT3B; T3 degration rate constant 
p(41) = 0.0034;         %KLAG-HYPO; assumed to be hypothalmus related time delay(?)
p(42) = 5;              %KLAG; assumed to be a slowing or time delayed constant
p(43) = 1.3;            %k4dissolve; rate constant possibly to model T4 dissolve into blood rate
p(44) = 0.12*d(2);      %k4excrete; originally 0.119; assumed to be excretion rate of T4 from body
p(45) = 1.78;           %k3dissolve; assumed to be rate at which T3 is dissolved in to the blood 
p(46) = 0.12*d(4);      %k3excrete; originally 0.118; assumed to be (bodily) excretion rate of T3
% p47 and p48 are only used in converting mols to units. Since unit conversion
% is done in THYSIM->postProcess(), make sure you change p47 and p48 there if
% you need to change these values.
p(47) = 3.2;            %Vp; linerization constant for michaelis menten  
p(48) = 5.2;            %VTSH; linerization constant for michaelis menten relating to TSH
end

% Sensitivity Analysis
% For every parameter, change it slightly by a range of 0.1x to 10x, or
% p*10^(-1) to p*(10^1). Measure T3, TSH, and T4 output at each variation (averaged over time). 
function varyParams()
global p tspan ic; % semicolons there to suppress output, so you don't really need it here
total_params = size(p,2); %number of parameters 

%param = p*10^(x) where x is [-1,1,0.1] range
initval = -1;
step = .1; 
endval = 1;
num_steps = floor((endval-initval)/step)+1;

%initialize matrices with 48 parameter rows and num_step (currently 20) columns.
%first column will be p*0.1, the last column will be p*10. 
%each value in matrix will be the output averaged over the time period using the new parameter. 
matrixT4 = zeros(total_params,num_steps); %matrix(i,num_steps/2) will be the parameter without any changes (p*1)
matrixT3 = zeros(total_params,num_steps);
matrixTSH= zeros(total_params,num_steps);

for i = 1:total_params %iterates through all parameters, access with p(i)
    %disp(p(i))
    initial_p = p(i);
    
    j =1;
    for v = initval:step:endval   
       p(i)=initial_p*10^(v); %new parameter
       % solve the ODE using the new parameter
       [t,q] = ode45(@ODEs, tspan, ic); 
       % grab measurements for T3,T4,TSH and fill matrices. 
       [avgT4,rangeT4,standT4,avgT3,rangeT3,standT3,avgTSH,rangeTSH,standTSH]= measure(t,q);
       matrixT4(i,j)=avgT4;
       matrixT3(i,j)=avgT3;
       matrixTSH(i,j)=avgTSH;
       j=j+1;
    end
    %disp(p)
   
    p(i) = initial_p %reset current parameter before you iterate to the next parameter
end

%output to csv for data vis options in python, because matlab version doesn't have all the toolboxes
csvwrite('parameter_variationsT4.txt',transpose(matrixT4))
csvwrite('parameter_variationsT3.txt',transpose(matrixT3))
csvwrite('parameter_variationsTSH.txt',transpose(matrixTSH))
%type('parameter_variations.txt') %type displays the file contents in the command window

end

% Syntax for declaring functions in MatLab with input x and output y:
% function [y1,...,yN] = myfuncname(x1,...,xM) 
function [avgT4,rangeT4,standT4,avgT3,rangeT3,standT3,avgTSH,rangeTSH,standTSH]= measure(t,q) 
% from the graph function--some rearranging can be made 
global p;
% Conversion factors
% 777: molecular weight of T4
% 651: molecular weight of T3
% 5.6: (q7 umol)*(28000 mcg/umol)*(0.2 mU/mg)*(1 mg/1000 mcg)
% where 28000 is TSH molecular weight and 0.2 is specific activity
T4conv  = 777/p(47);    % mcg/L
T3conv  = 651/p(47);    % mcg/L
TSHconv = 5.6/p(48);    % mU/L

% Outputs
y1 = q(:,1)*T4conv;     % T4; this grabs all of the 1st column of q (all timepoints for variable q1)
y2 = q(:,4)*T3conv;     % T3; this grabs all of the 4th column of q (all timepoints for variable q4)
y3 = q(:,7)*TSHconv;    % TSH; this grabs all of the 7th column of q (all timepoints for variable q7)
t  = t/24;              % Convert time to days

% calculate std,range,and averages for T3, T4, TSH in case we need these values
avgT4 = mean(y1);
rangeT4 = max(y1)-min(y1);
standT4 = std(y1);

avgT3 = mean(y2);
rangeT3=max(y2)-min(y2);
standT3 = std(y2);

avgTSH = mean(y3);
rangeTSH=max(y3)-min(y3);
standTSH=std(y3);

end

% ODEs, return output dqdt 
function dqdt = ODEs(t, q)

global u1 u4 kdelay d p;

% Auxillary equations
q4F = (p(24)+p(25)*q(1)+p(26)*q(1)^2+p(27)*q(1)^3)*q(4);        %FT3p
q1F = (p(7) +p(8) *q(1)+p(9) *q(1)^2+p(10)*q(1)^3)*q(1);        %FT4p
% Brain delay, SR3(t) = S3*TSH(t-tau). a time delay function for the
% secretion rate of T3, based on secretory responses to plasma TSH concentrations
SR3 = (p(19)*q(19))*d(3); 
% Brain delay, SR4(t) = S4*TSH(t-tau). a time delay function for secretion
% rate of T4, based on secretary responses to plasma TSH concentrations
SR4 = (p(1) *q(19))*d(1);                                       
fCIRC = 1+(p(32)/(p(31)*exp(-q(9)))-1)*(1/(1+exp(10*q(9)-55)));
SRTSH = (p(30)+p(31)*fCIRC*sin(pi/12*t-p(33)))*exp(-q(9));
fdegTSH = p(34)+p(35)/(p(36)+q(7));
fLAG = p(41)+2*q(8)^11/(p(42)^11+q(8)^11);
f4 = p(37)+5*p(37)/(1+exp(2*q(8)-7));
NL = p(13)/(p(14)+q(2));

% ODEs
qdot(1) = SR4+p(3)*q(2)+p(4)*q(3)-(p(5)+p(6))*q1F+p(11)*q(11)+u1;       %T4dot
qdot(2) = p(6)*q1F-(p(3)+p(12)+NL)*q(2);                                %T4fast
qdot(3) = p(5)*q1F-(p(4)+p(15)/(p(16)+q(3))+p(17)/(p(18)+q(3)))*q(3);   %T4slow
qdot(4) = SR3+p(20)*q(5)+p(21)*q(6)-(p(22)+p(23))*q4F+p(28)*q(13)+u4;   %T3pdot
qdot(5) = p(23)*q4F+NL*q(2)-(p(20)+p(29))*q(5);                         %T3fast
qdot(6) = p(22)*q4F+p(15)*q(3)/(p(16)+q(3))+p(17)*q(3)/(p(18)+q(3))-(p(21))*q(6);%T3slow
qdot(7) = SRTSH-fdegTSH*q(7);                                           %TSHp
qdot(8) = f4/p(38)*q(1)+p(37)/p(39)*q(4)-p(40)*q(8);                    %T3B
qdot(9) = fLAG*(q(8)-q(9));                                             %T3B LAG
qdot(10)= -p(43)*q(10);                                                 %T4PILLdot
qdot(11)=  p(43)*q(10)-(p(44)+p(11))*q(11);                             %T4GUTdot
qdot(12)= -p(45)*q(12);                                                 %T3PILLdot
qdot(13)=  p(45)*q(12)-(p(46)+p(28))*q(13);                             %T3GUTdot

% Delay ODEs
qdot(14)= -kdelay*q(14) +q(7);                                          %delay1
qdot(15)= kdelay*(q(14) -q(15));                                        %delay2
qdot(16)= kdelay*(q(15) -q(16));                                        %delay3
qdot(17)= kdelay*(q(16) -q(17));                                        %delay4
qdot(18)= kdelay*(q(17) -q(18));                                        %delay5
qdot(19)= kdelay*(q(18) -q(19));                                        %delay6

% ODE vector
dqdt = qdot';
end

% Graph results
function graph(t,q)
global p

% Conversion factors
% 777: molecular weight of T4
% 651: molecular weight of T3
% 5.6: (q7 umol)*(28000 mcg/umol)*(0.2 mU/mg)*(1 mg/1000 mcg)
% where 28000 is TSH molecular weight and 0.2 is specific activity
T4conv  = 777/p(47);    % mcg/L
T3conv  = 651/p(47);    % mcg/L
TSHconv = 5.6/p(48);    % mU/L

% Outputs
y1 = q(:,1)*T4conv;     % T4
y2 = q(:,4)*T3conv;     % T3
y3 = q(:,7)*TSHconv;    % TSH
t  = t/24;              % Convert time to days

% General
figure('Name','Thyrosim Results','NumberTitle','off');

% T4 plot
subplot(3,1,1);
plot(t,y1);
ylabel('T4 mcg/L');
ylim([0 max(y1)*1.2]);


% T3 plot
subplot(3,1,2);
plot(t,y2);
ylabel('T3 mcg/L');
ylim([0 max(y2)*1.2]);

% TSH plot
subplot(3,1,3);
plot(t,y3);
ylabel('TSH mU/L');
ylim([0 max(y3)*1.2]);
xlabel('Days');
end
