function files = grep_files(filepat, pattern)
%Find files that match a given regular expression in a new line.
%
%     files = grep_files(filepat, pattern)
%
% Parameters
% ----------
% filepat:   A file pattern recognizable by `dir`.
% pattern:   A regular expression pattern to be found in a line.
%
% Returns
% -------
% files:     A cell array of files with full path.
%
% See also dir

files = {};
filelist = dir(filepat);

for i = 1:length(filelist)
    fullname = fullfile(filelist(i).folder, filelist(i).name);

    fid = fopen(fullname, 'rt');
    if fid < 0; continue; end
    str = fread(fid, '*char')';
    fclose(fid);

    if ~isempty(regexp(str, ['[^\n]*' pattern '[^\n]*\n'], 'once', 'match'))
        files = [files, fullname]; %#ok<AGROW>
    end
end
end
