function varargout = run_petscSolveCRS_exe(varargin)

% Invoke EXE file by passing variables through MAT files.
filebase = tempname;
infile = [filebase '_petscSolveCRS_in.mat'];
outfile = [filebase '_petscSolveCRS_out.mat'];

cleanup = onCleanup(@()delete([filebase  '*.mat']));

mdir = fileparts(which('run_petscSolveCRS_exe.m'));
if isequal(mdir, pwd)
    mdir = './';
else
    mdir = [mdir '/'];
end

% Export input arguments into MAT file
m = struct();

for i = 1:nargin
    try
        m.(['input_' int2str(i)]) = varargin{i};
    catch
        error(['Failed to write out input variable ' int2str(i)]);
    end
end
save(infile, '-struct', 'm', '-v7');

% Call executable using the system command
cmd = ['LD_LIBRARY_PATH= ' mdir 'petscSolveCRS.' exeext ' ' ...
    int2str(nargin) ' ' infile ' ' int2str(nargout) ' ' outfile ' '];

[status, result] = system(cmd, '-echo');
if status
    error('%s', result);
end

% Import output arguments from MAT file
varargout = cell(1, nargout);
m = load(outfile);

for i = 1:nargout
    try
        varargout{i} = m.(['output_' int2str(i)]);
    catch
        clear('m');
        error(['Failed to read in output variable ' int2str(i)]);
    end
end

end
