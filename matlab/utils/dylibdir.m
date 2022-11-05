function str = dylibdir(dir)
%dylibdir - Specify dynamic loaded path

str = ['-L' dir];

if ~exist('OCTAVE_VERSION', 'builtin') || ~strncmp(OCTAVE_VERSION, '3', 1)
    % Use rpath only for Octave 4.0 or higher
    if ismac
        concat = ',';
    else
        concat = '=';
    end
    str = [str, ' -Wl,-rpath' concat dir];
end
end
