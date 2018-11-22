function ut_run(do_save_report)
% function ut_run

if (nargin == 0), do_save_report = 0; end

rd = fullfile(fileparts(mfilename('fullpath')), '..', '..');
pd = fileparts(mfilename('fullpath'));

packages = {...
    'mdm', ...
    'mio', ...
    'mio/elastix', ...
    'msf', ...
    'methods/dti_nls',...
    'methods/dti_lls',...
    'methods/quick_dti',...
    'methods/dtd_codivide',...
    'methods/dtd_covariance',...
    'methods/dtd_pa',...
    'methods/dki_pa',...
    'methods/dti_euler',...
    'methods/dtd_pake',...
    'methods/dtd_saupe',...
    'methods/dtd_ndi',...
    'methods/dtd_gamma',...
    'methods/fexi11',...
    'methods/vasco16',...
    'tools/tensor_maths', ...
    'tools/uvec', ...
    'tools/gwf', ...
    'tools/mplot', ...
    'tools/mgui', ...
    'tools/man', ...
    };


if (do_save_report)
    date_str = datestr(now, 'yyyy_mm_dd_HH_MM_SS');
    
    log_fn = fullfile(pd, 'ut_report', sprintf('ut_%s.txt', date_str));
    msf_mkdir(fileparts(log_fn));
    fid = fopen(log_fn, 'w');
    
    if (fid == -1)
        error('Could not open file for writing: %s', log_fn);
    end
else
    clc;
    fid = -1;
end

c_err = 0;


% Basic information
my_fprintf(fid, 'BASIC INFO\n');
my_fprintf(fid, '---------------------------------\n');
my_fprintf(fid, 'Matlab version: %s\n', version);
my_fprintf(fid, 'Computer: %s\n', computer);
my_fprintf(fid, '\n');


for c = 1:numel(packages)
    
    
    d = dir(fullfile(rd, packages{c}, 'ut_*.m'));
    
    my_fprintf(fid, 'PACKAGE: %s (%i ut_*.m files)\n', packages{c}, numel(d));
    my_fprintf(fid, '---------------------------------\n');
    
    
    for c_file = 1:numel(d)
        
        m_fn = d(c_file).name(1:end-2);
        
        try
            n_ut = eval(m_fn);
        catch me
            n_ut = 0;
            disp(me.message);
        end
        
        my_fprintf(fid, 'Executing %i unit tests in %s.m\n', n_ut, m_fn);
        
        for c_ut = 1:n_ut
            try
                txt = ['OK  for ' feval(m_fn, c_ut)];
            catch me
                txt = ['ERR with ' me.message];
                c_err = c_err + 1;
            end
            
            my_fprintf(fid, 'Test %2.0f, %s\n', c_ut, txt);
            
        end
        
    end
    
    my_fprintf(fid, '\n');
    
end

my_fprintf(fid, 'Total errors: %i\n', c_err);

if (fid ~= -1), fclose(fid); end

end

function my_fprintf(fid, str, varargin)

str = sprintf(str, varargin{:});
fprintf(str);

if (fid ~= -1)
    fprintf(fid, str);
end

end