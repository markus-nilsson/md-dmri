function ps = step0_define_paths()
% function ps = step0_define_paths()
%
% Before you begin, download the data from here 
% https://github.com/filip-szczepankiewicz/Szczepankiewicz_DIB_2019
%
% Then set the paths below accordingly
%
% Output: A paths structure


% Connect to the data (bp - base path, ip - input path, op - output path)
ps.bp = 'Szczepankiewicz_DIB_2019'; % <- download from Github, see above
ps.ip = fullfile(ps.bp, 'DATA', 'brain', 'NII'); % <- actual input data
ps.op = fullfile(ps.bp, 'processed', 'brain'); % <- store output here
ps.zp = fullfile(ps.bp, 'tmp'); % <- store temporary files here

if ((~exist(ps.bp, 'dir')) || ...
        (~exist(ps.ip, 'dir')))
    error('Data not found at specified folder. See instructions in header.')
end


msf_mkdir(ps.op); 
msf_mkdir(ps.zp); 
