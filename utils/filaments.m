function [filaments_x,filaments_y]=filaments(xlsifne)
%
%
%
%
    disp('Detecting import options...');
    opts=detectImportOptions(xlsifne,'Sheet',1);
    disp('Reading matrix...');
    xlmatrix=readmatrix(xlsifne,opts);
    mnans=isnan(xlmatrix);
    xlmatrix(mnans)=0;

%
%
%

    skipf=[1:2:size(xlmatrix,1)];
    xlmatrix=xlmatrix(skipf,:);

    fcoords=xlmatrix(:,11:end);

    skipx=[1:2:size(fcoords,2)-1];
    x=transpose(fcoords(:,skipx));
    y=transpose(fcoords(:,skipx+1));

%
%   Masking away invalid (zero) pixel values
%

    x(x==0)=NaN;
    y(y==0)=NaN;
    filaments_x=x;
    filaments_y=y;

end
