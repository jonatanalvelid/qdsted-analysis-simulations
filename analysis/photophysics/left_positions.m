function [left_p] = left_positions(len,excluded)
%LEFT_POSITION Returns the position indexes which are not excluded
%   Excluded represents the position of elements of an array which are excluded,
%   len is the length of the array itself. The function returns the
%   complementary list of the position of the elements which are not
%   excluded

left_p=zeros(1,len-length(excluded));
n=1;
for i=1:len
    if sum(excluded==i)==0
        left_p(n)=i;
        n=n+1;
    end
end

end

