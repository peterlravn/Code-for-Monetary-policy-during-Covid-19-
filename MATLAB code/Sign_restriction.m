% Replication of the monetary VAR in Uhligh (2005, JME).
% Figure 6, page 397.
%==========================================================================
% The VAR Toolbox 3.0 is required to run this code. To get the 
% latest version of the toolboxes visit: 
% https://github.com/ambropo/VAR-Toolbox
%==========================================================================
% Ambrogio Cesa Bianchi, November 2020
% ambrogio.cesabianchi@gmail.com

addpath(genpath("C:\Users\Peter\Documents\MATLAB\VAR-Toolbox-main\v3dot0"))


%% PRELIMINARIES
% =======================================================================
clear all; clear session; close all; clc
warning off all

%% DATA
% =======================================================================
% Load data 
[xlsdata, xlstext] = xlsread('Corona_data.xlsx','Sheet1');
dates = xlstext(3:end,1);
vnames_long = xlstext(1,2:end);
vnames = xlstext(2,2:end);
nvar = length(vnames);
data   = Num2NaN(xlsdata);
for ii=1:7
    DATA.(vnames{ii}) = data(:,ii)*100;
end

year = str2double(xlstext{3,1}(1:4));
month = str2double(xlstext{3,1}(6));
nobs = size(data,1);


%% VAR ESTIMATION
% =======================================================================
% Define variables 
Xvnames      = vnames;
Xvnames_long = vnames_long;
Xnvar        = length(Xvnames)-1;
% Construct endo
X = nan(nobs,Xnvar);
EXOG = DATA.(Xvnames{7})

for ii=1:Xnvar
    X(:,ii) = DATA.(Xvnames{ii});
end
% Set deterministics for the VAR
det = 1;
% Set number of nlags
nlags = 2;
% Estimate VAR
[VAR, VARopt] = VARmodel(X,nlags,det,EXOG,0);


%% SIGN RESTRICTIONS
% =======================================================================
% Set options
VARopt.vnames = Xvnames_long;
VARopt.vnames_ex = ['corona_dummy'];
VARopt.nsteps = 24;
VARopt.snames = {'ASSETS'};
VARopt.ndraws = 10000;
VARopt.quality = 1;
VARopt.FigSize = [26,8];
VARopt.firstdate = year+(month-1)/12;
VARopt.frequency = 'm';
VARopt.figname= 'graphics/Uhlig_';
VARopt.impact    = 0;


% Define sign restrictions : positive 1, negative -1, unrestricted 0
SIGN = [ 0,0,0,0,0,0;  % GDP
         -1,0,0,0,0,0;  % CISS
         1,0,0,0,0,0;  % ASSETS
         -1,0,0,0,0,0;  % EONIA
         1,0,0,0,0,0;  % HICP
         0,0,0,0,0,0]; % MRO
     

% Define the number of steps the restrictions are imposed for:
VARopt.sr_hor = 2;

% Set options the credible intervals
VARopt.pctg = 95;

% Run sign restrictions routine
SRout = SR(VAR,SIGN,VARopt);

%% Plot
% Plot
FigSize(20,24)
idx = [1 3 5 2 4 6];
for ii=1:Xnvar
    subplot(3,2,idx(ii))
    PlotSwathe(SRout.IRmed(:,ii,1),[SRout.IRinf(:,ii,1) SRout.IRsup(:,ii,1)]); hold on
    PlotSwathe(SRout.IRmed(:,ii,1),[SRout.IRinf2(:,ii,1) SRout.IRsup2(:,ii,1)]); hold on
    plot(zeros(VARopt.nsteps),'--k');
    title(vnames_long{ii})
    xlabel("Months")
    ylabel("Percent")
    axis padded
end

% Save
SaveFigure('Sign VAR figure',1)

disp(eig(VAR.Fcomp))