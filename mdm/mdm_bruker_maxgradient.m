function Gmax = mdm_bruker_maxgradient(NMRacqus)
% function Gmax = mdm_bruker_maxgradient(NMRacqus)
%
% NMRacqus: Bruker acquistion parameter structure
% NMRacqus.probhd: probehead name

% Max gradients for the Bruker imaging probes in Lund 
Gmax = 3; % default for Bruker MIC-5
if any(strcmp(NMRacqus.probhd,{'5 mm BBO BB-1H/D XYZ-GRD Z107255/0001',...
        '5 mm TXI 1H/D-13C/15N XYZ-GRD Z8588/0006'})) == 1
    Gmax = 0.5; % Bruker high-resolution probes
elseif any(strcmp(NMRacqus.probhd,{'Z11111_0001 (MIC)'})) == 1
    Gmax = 1.5; % Bruker MIC-2.5
end
