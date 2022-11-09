function A = crs_createFromAIJ(rows, cols, vs, varargin)
%crs_createFromAIJ  Create a sparse matrix in CRS-format from AIJ (ijv) format
%
%    A = crs_createFromAIJ(rows, cols, vs [, ni, nj]);
% A is a struct with fields row_ptr, col_ind, val, nrows, and ncols.
%
% See also crs_matrix, crs_createFromSparse

%#codegen -args {coder.typeof(int32(0), [inf,1]),
%#codegen coder.typeof(int32(0), [inf,1]), coder.typeof(0, [inf,1])}
%#codegen crs_create1 -args {coder.typeof(int32(0), [inf,1]),
%#codegen coder.typeof(int32(0), [inf,1]), coder.typeof(0, [inf,1]), int32(0), int32(0)}

if nargin < 4
    nrows = max(rows);
else
    nrows = int32(varargin{1});
end
if nargin < 5
    ncols = max(cols);
else
    ncols = int32(varargin{2});
end

A = struct('row_ptr', zeros(nrows + 1, 1, 'int32'), ...
    'col_ind', zeros(size(cols), 'int32'), ...
    'val', zeros(size(cols), class(vs)), ...
    'nrows', nrows, 'ncols', ncols);

%% Construct A.row_ptr
for i = 1:int32(length(rows))
    A.row_ptr(rows(i) + 1) = A.row_ptr(rows(i) + 1) + 1;
end

A.row_ptr(1) = 1;
for i = 1:nrows
    A.row_ptr(i + 1) = A.row_ptr(i) + A.row_ptr(i + 1);
end

%% Construct A.col_ind and A.val
% Check whether row indices are in ascending order
ascend = true;
for i = 2:length(rows)
    if rows(i) < rows(i - 1)
        ascend = false;
        break;
    end
end

if ascend
    % if rows is already in ascending order, simply return cols as
    % A.col_ind and vs as A.val.
    A.col_ind = int32(cols);
    A.val = vs;
else
    % Construct A.col_ind and A.val
    A.col_ind = coder.nullcopy(zeros(length(cols), 1, 'int32'));
    A.val = coder.nullcopy(zeros(length(cols), 1, class(vs)));

    for i = 1:length(rows)
        j = A.row_ptr(rows(i));
        A.val(j) = vs(i);
        A.col_ind(j) = cols(i);
        A.row_ptr(rows(i)) = A.row_ptr(rows(i)) + 1;
    end

    % Recover A.row_ptr
    for i = length(A.row_ptr):-1:2
        A.row_ptr(i) = A.row_ptr(i - 1);
    end
    A.row_ptr(1) = 1;
end
