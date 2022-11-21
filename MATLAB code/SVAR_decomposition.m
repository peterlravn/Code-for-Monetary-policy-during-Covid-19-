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
[xlsdata, xlstext] = xlsread('Corona_data','Sheet1');
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


%% COMPUTE IRF AND FEVD
% =======================================================================
% Set options some options for IRF calculation
VARopt.nsteps = 24;
VARopt.ident = 'short';
VARopt.vnames = vnames_long;
VARopt.frequency = 'm';
VARopt.FigSize = [26,12];

% Set options the credible intervals
VARopt.pctg = 95;

% Compute IR
[IR, VAR] = VARir(VAR,VARopt);
% Compute error bands
[IRinf,IRsup,IRmed,IRbar,IRinf2,IRsup2] = VARirband(VAR,VARopt);

%% 
test = ["Assets → GDP", "Assets → CISS", "Assets → Asset", "Assets → EONIA-MRO Spread", "Assets → HICP", "Assets → MRO"]

set(gcf,'color','w');

FigSize(20,24)
idx = [1 3 5 2 4 6];
for ii=1:Xnvar
    subplot(3,2,idx(ii))
    PlotSwathe(IRmed(:,ii,3),[IRinf(:,ii,3) IRsup(:,ii,3)]); hold on 
    PlotSwathe(IRmed(:,ii,3),[IRinf2(:,ii,3) IRsup2(:,ii,3)]); hold on
    plot(zeros(VARopt.nsteps),'--k');
    title(test{ii})
    xlabel("Months")
    ylabel("Percent")
    axis padded
end

max(eig(VAR.Fcomp))