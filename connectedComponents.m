clear;clc; 
img = imread('C:\Program Files\MATLAB\R2016a\toolbox\images\imdata\rice.png');
figure, imshow(img), title('Input image');
BW = im2bw(img);
%BW = [0,1,0,1; 1,1,0,1; 0,1,0,0;1,1,0,1;0,1,1,1;0,0,0,0];
[R C] = size(BW);

l = 1;
h = zeros(R , C, 'int16');
eqTable = zeros(max(h(:)),1);

for r = 1 : R
    for c = 1 : C        
        pixel_intensity = BW(r,c);
        if pixel_intensity == 1
            if (r-1==0 && c-1==0)
                h(r,c) = l ;
            elseif (r-1 == 0 && c-1>0)
                left = h(r, c-1);
                if(left ~=0 )
                    h(r,c) = left ;
                else
                    h(r,c) = l;
                    l = l+1;
                end
            elseif (c-1 == 0 && r-1>0)
                top = h(r-1,c);
                if top~= 0
                    h(r,c) = top;
                else
                    h(r,c) = l;
                    l = l+1;
                end
            elseif r-1>0 && c-1>0
                left = h(r,c-1);
                top = h(r-1,c);
                if left == 0 && top == 0  %no fg
                    h(r,c) = l ;
                    l = l+1;
                elseif left >= 1 && top ==0    % one fg
                    h(r,c) = left;
                elseif ( left == 0 && top >=1) || ( left >= 1 && top >=1 && (left == top))
                    h(r,c) = top;
                elseif left >= 1 && top >=1 && (left ~= top)
                    h(r,c) = min(top,left);
                    eqTable(max(top,left)) = min(top,left);
                end
            end
        end
    end
end

for i = 1: size(eqTable)
    if eqTable(i) == 0
        eqTable(i) = i;
    end
end
h1 = h;
eqTable = int16(eqTable);

for i = 1: size(eqTable)
    if i~=eqTable(i)
       eqTable(i)= eqTable(eqTable(i));
    end
end

eq_unique = unique(eqTable);

for i = 1: size(eq_unique)
    value = eq_unique(i);
    [loc] = find(eqTable == value);
    min_loc = min(loc);
    for j = 1: size(loc)
        [index] = find(h == loc(j));
        h(index) = min_loc;
    end
end

h_unique = unique(h);

cmap = rand(size(h_unique, 1), 3);
figure, imshow(h, []),title('CCL output without threshold')
colormap (cmap);


out = [h_unique,histc(h(:),h_unique)];
y = sort (out,1, 'ascend');
x = y(:,2);
mean_x= mean(x);
threshold = mean_x * 0.05;


for i = 1: size(h_unique)
    [loc] = find(h == h_unique(i));
    if length(loc) <= threshold
        h(loc) = 0;
    end
end

h_unique = unique(h);
a = size(h_unique, 1);


threshold = int8(threshold);
titleStr = sprintf('CCL output with threshold %d \n Total objects %d', threshold, a);
figure, imshow(h, []),title(titleStr);
colormap (cmap);

% unique;


% imshow(h);

%[1;2;1;3;4]
