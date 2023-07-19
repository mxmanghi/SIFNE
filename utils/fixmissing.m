function cell_array_sifne=fixmissing(cell_array_sifne)
%
% -- fixmissing
%
%   I haven't found a way to fix a cell array's missing
%   elements without checking every element with a double
%   for loop


    [nrows,ncolumns]=size(cell_array_sifne);
    cnt=0;
    for r=[1:1:nrows]
        cnt=cnt+1;
        fprintf(".");
        if (mod(cnt,50)==0) 
            fprintf("\n");
        end

        for c=[1:1:ncolumns]
            if (ismissing(cell_array_sifne{r,c}))
                cell_array_sifne{r,c}=0;
                fprintf("x");
            end
            
        end
    end
    fprintf("\n");

end
