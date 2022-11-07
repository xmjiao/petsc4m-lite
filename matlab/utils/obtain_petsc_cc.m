function [PCC, CXX, INC, CFLAGS, CXXFLAGS, LIBDIR, LIBEXT, LIBEXTRA] = obtain_petsc_cc
% Obtain the PCC and CXX commands from the petscvariables file

if ispc
    error('PETSC4M-LITE is only supported on Linux or Mac. See petsc4m-lite/README.md for help.');
elseif ~isempty(getenv('PETSC_DIR'))
    PETSC_DIR = getenv('PETSC_DIR');
elseif isfolder([getenv('CONDA_PREFIX') '/lib/petsc/conf'])
    PETSC_DIR = getenv('CONDA_PREFIX');
elseif isfolder('/usr/lib/petsc')
    PETSC_DIR = '/usr/lib/petsc';
else
    error('Could not find PETSc installation. See petsc4m-lite/README.md for help.');
end

filename = [PETSC_DIR '/lib/petsc/conf/petscvariables'];

str = readFile(filename);
pat = '\nPCC\s*=\s*([^\n]+)\n';

def = regexp(str, pat, 'match', 'once');

if ~isempty(def)
    PCC = strtrim(regexprep(def, pat, '$1'));
else
    PCC = '';
end

pat = '\nCXX\s*=\s*([^\n]+)\n';

def = regexp(str, pat, 'match', 'once');

if ~isempty(def)
    CXX = strtrim(regexprep(def, pat, '$1'));
else
    CXX = '';
end

if exist('petscroot', 'file')
    INC = ['-I' petscroot '/include '];
else
    INC = '';
end

pat = 'PETSC_CC_INCLUDES\s*=\s*([^\n]+)\n';
def = regexp(str, pat, 'match', 'once');

if ~isempty(def)
    INC = [INC strtrim(regexprep(def, pat, '$1'))];
end

CFLAGS = '';
pat = '\nCC_FLAGS\s*=\s*([^\n]+)\n';
def = regexp(str, pat, 'match', 'once');

if ~isempty(def)
    CFLAGS = strtrim(regexprep(def, pat, '$1'));
end

CXXFLAGS = '';
pat = 'CXX_FLAGS\s*=\s*([^\n]+)\n';
def = regexp(str, pat, 'match', 'once');

if ~isempty(def)
    CXXFLAGS = strtrim(regexprep(def, pat, '$1'));
end

LIBDIR = [PETSC_DIR, '/lib'];

LIBEXT = '';
pat = 'PETSC_LIB_EXT\s*=\s*([^\n]+)\n';
def = regexp(str, pat, 'match', 'once');

if ~isempty(def)
    LIBEXT = strtrim(regexprep(def, pat, '$1'));
end

if ~isempty(strfind(PETSC_DIR, 'conda'))
    PCC = 'cc';
    CXX = 'c++';
    LIBEXTRA = '';
else
    LIBEXTRA = '-lcurl';
end

end

function str = readFile(filename)
% Read an ASCII file into a string

fid = fopen(filename, 'rt');
if fid >= 0
    str = fread(fid, inf, '*char')';
    fclose(fid);
else
    warning('m2c:CannotOpenFile', 'Could not open file %s\n', filename);
    str = '';
end
end
