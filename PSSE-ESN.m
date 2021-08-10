clear; clc;

rand( 'seed', 42 );

%% Load the data
load('normaloperation.mat');
load('suddenloadchange.mat');

%% Scenario: normal operation, sudden load change
scenario = 2; % 1 normal operation, 2 suddenloadchange
if scenario==1
    input = in_normaloperation;
    out = out_normaloperation;
end
if scenario==2
    input = in_suddenloadchange;
    out = out_suddenloadchange;
end
input(12:13,:) = [];


%% Noise
noise_type = 1; % 1 gaussian noise, 2 laplacian noise
ng_v = 0.01; % Noise std for voltage magnitude
ng_p = 0.02; % Noise std for powers 
n_bus = 14;

if noise_type == 2
    input(1:5,:) = input(1:5,:) + ng_v*laprnd(5,size(input,2),0,1);
    input(6:end,:) = input(6:end,:) + ng_p*laprnd(size(input,1)-5,size(input,2),0,1);
end


%% Inputs normalization
input = input./repmat(sqrt(sum(input.^2)),[size(input,1) 1]);


%% Output assignment
output = out';
output1 = output(:,1); 
output2 = output(:,n_bus+1);
ytrue1 = output1'; % True values of the slack bus' angle
ytrue2 = output2'; % True values of the slack bus' voltage magnitude


%% ESN for angle estimation - Parameters
biasScaling = 1*0.75e3;
inScaling = 1*1e-5;
outScaling = 1e-5;
reg = 1e-9; % Ridge regression regularization constant
a = 1.63e-2; % Leaking rate
resSize = 21; % Reservoir's size


%% ESN for voltage magnitude estimation - Parameters
biasScaling2 = 0.6;
inputScaling2 = 1*1e-5;
outputScaling2 = 1e-5;
reg2 = 1.5e-5; % Ridge regression regularization constant
a2 = 2e-1; % Leaking rate
resSize = 21; % Reservoir's size


%% Input, output, bias and reservoir weight matrices generation
outSize1 = size(output1,2);
outSize2 = size(output2,2);
inSize = size(input,1);
Wout1 = outScaling*((rand(outSize1,1+inSize+resSize)).* 2 - 1); % Output weight matrix for the ESN for angle estimation
Wout2 = outputScaling2*((rand(outSize2,1+inSize+resSize)).* 2 - 1); % Output weight matrix for the ESN for voltage magnitude estimation
Win = ((rand(resSize,inSize)).* 2 - 1);
Win2 = inputScaling2*Win; % Input weight matrix
Win = inScaling*Win;
W = sprand(resSize,resSize,0.01);
W_mask = (W~=0); 
W(W_mask) = (W(W_mask)*2-1);
Wb = (rand(resSize, 1) * 2 - 1);
Wb2 = biasScaling2 * Wb;
Wb = biasScaling * Wb;


%% Setting spectral radius less than 1
rho = abs(eigs(W,1)); % Largest eigenvalue
rho = 0.05;
W = W .* (rho / rho);


%% Reservoir's states initialization
x = zeros(resSize,1);
x2 = zeros(resSize,1);


tic
for t = 1:ceil(1*size(input,2))
	u = input(:,t);
    
    % State reservoir for the angle estimation
	x = (1-a)*x + a*tanh( Win*[u] + W*x + Wb);
    X(:,t) = [1;u;x];
    
    
    % State reservoir for the voltage magnitude estimation
	x2 = (1-a2)*(x2) + a2*tanh(Win*[u] + W*x2 + Wb2); % TOOK OFF THE TANH HERE
    X2(:,t) = ([1;u;x2]); 
    
    
    % Angle estimation for slack bus
    yhat1(:,t) = Wout1*X(:,t);
    error1(:,t) = ytrue1(:,t) - yhat1(:,t);
    ytar_xt1 = ytrue1(:,t)*X(:,t)';
    x_xt = X(:,t)*X(:,t)';
    Wout1 = (x_xt + reg*eye(size(x_xt)))'\ytar_xt1';
    Wout1 = Wout1';
    
    
    % Voltage magnitude estimation for slack bus
    m_Wout2(t,:) = Wout2;
    yhat2(:,t) = (Wout2*X2(:,t));
    error2(:,t) = ytrue2(:,t) - yhat2(:,t);
    ytar_xt2 = ytrue2(:,t)*X2(:,t)';
    x_xt2 = X2(:,t)*X2(:,t)';
    eta = 1*0.5e-2; % LESS, HELP TO DECREASE THE OSCILLATIONS
    Wout2 = ((x_xt2 + reg2*eye(size(x_xt2)))'\ytar_xt2')' + eta*error2(:,t)*X2(:,t)';
end

time = toc;
disp(time)