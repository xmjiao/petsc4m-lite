function mmex(varargin)
%MEX   MATLAB-compatible mex wrapper function for Octave
%
%   Usage:
%       mmex [options ...] file [files ...]
%
%   Description:
%       MEX compiles and links source files into a shared library called a
%       MEX-file, executable from within MATLAB or Octave. It can also build
%       executable files for standalone MATLAB engine and MAT-file applications.
%
%   Command Line Options Available on All Platforms:
%       -c
%           Compile only. Creates an object file but not a MEX-file.
%       -client engine
%           Not supported. Ignored with warning.
%       -compatibleArrayDims
%           Not supported. Ignored without warning.
%       -D<name>
%           Define a symbol name to the C preprocessor. Equivalent to a
%           '#define <name>' directive in the source. Do not add a space
%           after this switch.
%       -D<name>=<value>
%           Define a symbol name and value to the C preprocessor. Equivalent
%           to a '#define <name> <value>' directive in the source. Do not
%           add a space after this switch.
%       -f <optionsfile>
%           Not supported. Ignored with warning.
%       -g
%           Create a MEX-file containing additional symbolic information for
%           use in debugging. This option disables MEX's default behavior of
%           optimizing built object code (see the -O option).
%       -h[elp]
%           Display this message.
%       -I<pathname>
%           Add <pathname> to the list of directories to search for #include
%           files. Do not add a space after this switch.
%       -l<name>
%           Link with object library. On Windows, <name> expands to
%           '<name>.lib' or 'lib<name>.lib'. On Linux, to 'lib<name>.so'.
%           On Mac, to 'lib<name>.dylib'. Do not add a space after this
%           switch.
%       -L<folder>
%           Add <folder> to the list of folders to search for
%           libraries specified with the -l option. Do not add a space
%           after this switch.
%       -largeArrayDims
%           Not supported. Ignored without warning.
%       -n
%           No execute mode. Display commands that MEX would otherwise
%           have executed, but do not actually execute any of them.
%       -O
%           Optimize the object code. Optimization is enabled by default and
%           by including this option on the command line. If the -g option
%           appears without the -O option, optimization is disabled.
%       -outdir <dirname>
%           Not supported. Use -output instead.
%       -output <resultname>
%           Create MEX-file named <resultname>. The appropriate MEX-file
%           extension is automatically appended. Overrides MEX's default
%           MEX-file naming mechanism.
%       -setup <lang>
%           This option is not supported and will be ignored.
%       -silent
%           Suppress informational messages. The mex function still reports
%           errors and warnings, even when you specify -silent.
%       -U<name>
%           Remove any initial definition of the C preprocessor symbol
%           <name>. (Inverse of the -D option.) Do not add a space after
%           this switch.
%       -v
%           Verbose mode. Display the values for important internal
%           variables after all command line arguments are considered.
%           Displays each compile step and final link step fully evaluated.
%       <name>=<value>
%           Override default setting for variable <name>. The supported
%           variable names include CC, CXX, CFLAGS, CPPFLAGS, CXXFLAGS,
%           COPTIMFLAGS, COPTIMFLAGS, CXXOPTIMFLAGS, CDEBUGFLAGS, CXXDEBUGFLAGS
%           LD, LDXX, LDFLAGS, LINKLIBS
%
%   Command Line Options Available Only on Windows Platforms:
%       @<rspfile>
%           Include contents of the text file <rspfile> as command line
%           arguments to MEX.
%
%   For more information, see
%           http://www.mathworks.com/help/matlab/ref/mex.html

%% Look for mkoctfile
if exist('__octave_config_info__', 'builtin')
  % octave_config_info is depreciated in 4.2.1
  octave_config_info = @__octave_config_info__; %#ok<BADCH>
end

bindir = octave_config_info('bindir');
ext = octave_config_info('EXEEXT');

shell_script_ver = fullfile(bindir, ...
    sprintf ('mkoctfile-%s%s', OCTAVE_VERSION, ext));

if exist(shell_script_ver, 'file')
    shell_script = shell_script_ver;
else
    shell_script = fullfile (bindir, sprintf ('mkoctfile%s', ext));

    if ~exist(shell_script, 'file')
        error('m2c:mkoctfile', ['Could not locate %s or %s. If you used a package manager ' ...
            'to install octave, make sure octave-devel or liboctave-devl is also installed.'], ...
            shell_script, shell_script_ver);
    end
end

defs = struct('CC', '', 'CXX', '', 'CFLAGS', '', 'COPTIMFLAGS', '', ...
    'CPPFLAGS', '', 'CXXFLAGS', '', 'CXXOPTIMFLAGS', '', 'CDEBUGFLAGS', '', ...
    'CXXDEBUGFLAGS', '', 'LDFLAGS', '', 'LINKLIBS', '');

cmd = ['"' shell_script '" --mex -DMATLAB_MEX_FILE -DOCTAVE_MEX_FILE '];

dryrun = false;
verbose = false;
target = '';

i=1;
while i<=nargin
    if isequal(varargin{i}, '-output')
        cmd = [cmd ' --output']; %#ok<*AGROW>
        if i < nargin
            target = varargin{i+1};
            cmd = [cmd ' ' varargin{i+1}]; %#ok<*AGROW>
            i = i + 1;
        else
            error('Argument -output must follow a file name.');
        end
    elseif isequal(varargin{i}, '-O')
        defs.COPTIMFLAGS = [defs.COPTIMFLAGS ' -O2 -DNDEBUG'];
        defs.CXXOPTIMFLAGS = [defs.CXXOPTIMFLAGS ' -O2 -DNDEBUG'];
    elseif varargin{i}(1)~='-' && ~isempty(strfind(varargin{i}, '='))
        index = strfind(varargin{i}, '=');
        var = varargin{i}(1:index(1)-1);
        val = varargin{i}(index(1)+1:end);

        if ~isempty(val) && val(1) == '''' && (length(val)==1 || val(end) ~= '''')
            % Append additional args
            while i<length(varargin)
                val = [val ' ' varargin{i+1}];
                i = i + 1;
                if varargin{i}(end) == ''''
                    break;
                end
            end
        end

        if isfield(defs, var)
            if ~isempty(val) && (val(1)=='"' || val(1)=='''')
                val(1)=[];
            end
            if ~isempty(val) && (val(end)=='"' || val(end)=='''')
                val(end)=[];
            end
            if ~isempty(val)
                defs.(var) = [defs.(var) ' ' val];
            end
        else
            error('Unsupported variable %s.', var);
        end
    elseif isequal(varargin{i}, '-n')
        dryrun = true;
    elseif isequal(varargin{i}, '-v')
        verbose = true;
        cmd = [cmd ' "' varargin{i} '"']; %#ok<*AGROW>
    elseif isequal(varargin{i}, '-compatibleArrayDims') || ...
            isequal(varargin{i}, '-largeArrayDims')
        % Ignore without any warning
    elseif isequal(varargin{i}, '-client') || isequal(varargin{i}, '-f')
        warning('Argument %s is not supported and will be ignored.', varargin{i});
        i = i + 1;
    elseif isequal(varargin{i}, '-outdir')
        error('Option -outdir is not supported. Please use -output instead.');
    elseif length(varargin{i})>=2 && isequal(varargin{i}(1:2), '-U')
        error('Argument -U is not supported.');
    elseif isequal(varargin{i}, '-setup')
        error('Argument -setup is not supported.');
    else
        cmd = [cmd ' "' varargin{i} '"']; %#ok<*AGROW>
    end

    i = i + 1;
end

%% Process all the definitions
macros = '';

if ~isempty(defs.CC)
    macros = ['export CC=''' strtrim(defs.CC) '''; '];
elseif contains(getenv('OCTAVE_HOME'), 'conda') && ...
    exist([getenv('OCTAVE_HOME') '/bin/x86_64-conda-linux-gnu-cc'], 'file')
    setenv('CC', [getenv('OCTAVE_HOME') '/bin/x86_64-conda-linux-gnu-cc']);
end
if ~isempty(defs.CXX)
    macros = [macros 'export CXX=''' strtrim(defs.CXX) '''; '];
elseif contains(getenv('OCTAVE_HOME'), 'conda') && ...
    exist([getenv('OCTAVE_HOME') '/bin/x86_64-conda-linux-gnu-c++'], 'file')
    setenv('CXX', [getenv('OCTAVE_HOME') '/bin/x86_64-conda-linux-gnu-c++']);
end
if ~isempty(defs.CPPFLAGS)
    macros = [macros 'export CPPFLAGS=''' strtrim(defs.CPPFLAGS) '''; '];
end
if ~isempty(defs.CFLAGS) || ~isempty(defs.COPTIMFLAGS) || ~isempty(defs.CDEBUGFLAGS)
    macros = [macros 'export CFLAGS=''' strtrim(defs.COPTIMFLAGS) ' ' ...
        strtrim(strrep(defs.CFLAGS, '$CFLAGS', '')) ' ' ...
        strtrim(defs.CDEBUGFLAGS) '''; '];
end
if ~isempty(defs.CXXFLAGS) || ~isempty(defs.CXXOPTIMFLAGS) || ~isempty(defs.CXXDEBUGFLAGS)
    macros = [macros 'export CXXFLAGS=''' strtrim(defs.CXXOPTIMFLAGS) ' ' ...
        strtrim(strrep(defs.CXXFLAGS, '$CXXFLAGS', '')) ' ' ...
        strtrim(defs.CXXDEBUGFLAGS) '''; '];
elseif ~isempty(defs.CFLAGS)
    macros = [macros 'export CXXFLAGS=''' strtrim(defs.CFLAGS) '''; '];
end

if ~isempty(defs.CXX)
    macros = [macros 'export DL_LD=''' strtrim(defs.CXX) '''; '];
elseif ~isempty(defs.CC) && strfind(defs.CC, 'mpicc')
    macros = [macros 'export DL_LD=''' strtrim(strrep(defs.CC, 'mpicc', 'mpicxx')) '''; '];
end

if ~isempty(defs.LDFLAGS)
    macros = [macros 'export LDFLAGS=''' strtrim(strrep(defs.LDFLAGS, '$LDFLAGS', '')) '''; '];
end
if ~isempty(defs.LINKLIBS)
    cmd = [cmd ' ' strtrim(strrep(defs.LINKLIBS, '$LINKLIBS', ''))];
end

%%
cmd = [macros cmd];

if dryrun
    disp(cmd);
    return;
else
    if verbose
        disp(cmd);
    end
    [status, ~] = unix(cmd, '-echo');
    if status || target && ~exist(target, 'file')
        error('mkoctfile failed');
     end
end

end
