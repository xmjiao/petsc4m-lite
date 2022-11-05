function varargout = crs_matrix(varargin) %#codegen
%crs_matrix  Create a sparse matrix in CRS-format
%
%    A = crs_matrix(row_ptr, col_ind, val [, nrows, ncols])
% wraps the row_ptr, col_ind and val given in a cell array into a structure.
%
%    A = crs_matrix(sp) or
%    [row_ptr, col_ind, val, nrows, ncols] = crs_matrix(sp) creates a
% matrix from the MATLAB sparse format. This mode is incompatible with
% MATLAB Coder. It is provided for convenience of writing test programs.
%
%    A = crs_matrix(m, n);
% Create an empty sparse matrix with m rows and n columns.
%
% Note: In the special case where A.val has size (m*n,1), it is a dense
% matrix and then row_ptr and col_ind are ignored.
%
% See also crs_createFromAIJ, crs_createFromSparse
%
% Note: This function does not support multithreading. If there is no input,
%   this function creates a type declaration to be used with codegen.

if nargin==0
    varargout{1} = coder.cstructname(struct('row_ptr', coder.typeof(int32(0), [inf,1]), ...
        'col_ind', coder.typeof(int32(0), [inf,1]), ...
        'val', coder.typeof(0, [inf,1]), 'nrows', int32(0), 'ncols', int32(0)), 'CRS_Matrix');
    return;
elseif issparse(varargin{1})
    A = crs_createFromSparse(varargin{1});
elseif nargin==2
    A = crs_createFromAIJ(zeros(0, 1, 'int32'), zeros(0,1,'int32'), ...
        zeros(0, 1), int32(varargin{1}), int32(varargin{2}));
    coder.varsize('A.row_ptr', 'A.col_ind', 'A.val', [inf,1]);
elseif iscell(varargin{1})
    A.row_ptr = int32(varargin{1}{1});
    A.col_ind = int32(varargin{1}{2});
    A.val = double(varargin{1}{3});

    if nargin > 1
        A.nrows = int32(varargin{2});
    else
        A.nrows = int32(length(A.row_ptr)-1);
    end
    if nargin > 2
        A.ncols = int32(varargin{3});
    else
        A.ncols = int32(max(A.col_ind));
    end
    coder.varsize('A.row_ptr', 'A.col_ind', 'A.val', [inf,1]);
else
    A.row_ptr = int32(varargin{1});
    A.col_ind = int32(varargin{2});
    A.val = double(varargin{3});

    if nargin > 3
        A.nrows = int32(varargin{4});
    else
        A.nrows = int32(length(A.row_ptr)-1);
    end
    if nargin > 4
        A.ncols = int32(varargin{5});
    else
        A.ncols = int32(max(A.col_ind));
    end

    coder.varsize('A.row_ptr', 'A.col_ind', 'A.val', [inf,1]);
end

if nargout<=1
    varargout{1} = A;
else
    varargout{1} = A.row_ptr;
    varargout{2} = A.col_ind;
    if nargout>2; varargout{3} = A.val; end
    if nargout>3; varargout{4} = A.nrows; end
    if nargout>4; varargout{5} = A.ncols; end
end
