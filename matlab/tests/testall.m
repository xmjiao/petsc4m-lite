function testall(varargin)
%TESTALL  Test files with test blocks
%
%  testall [file1] [file2] ...
%
%  It will test a list of files. Without any argument, it will test all
%  the MATLAB files with a built-in test block.

olddir = pwd;
cleanup = onCleanup(@()cd(olddir));
cd(petsc4m_root);

if ~exist('mtest.m', 'file') || ~exist('grep_file.m', 'file')
    addpath ../../momp2cpp/utils
end

if isempty(varargin)
    files = grep_files('./*.m', '\n%!test');
else
    files = varargin;
end

for i = 1:length(files)
    fprintf(1, 'Testing %s:\n', files{i});
    [srcdir, ~] = fileparts(files{i});
    if ~isempty(srcdir); cd(srcdir); end
    mtest(files{i});
end

end
