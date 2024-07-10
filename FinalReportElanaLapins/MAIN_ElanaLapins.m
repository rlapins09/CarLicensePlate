% CS6210: Final Project - License Plate Detection
% Elana Lapins
clear all; clc;

%Image data Location
direct = dir('plate images');
direct = direct(3:end);

load imgfiledata; %obtained this training set online (in Alpha folder)
for i = 1:length(direct)
    filename = direct(i).folder + "\" + direct(i).name;%filename
    fprintf("Image: %s \n",direct(i).name);
    %load image data and resize so all images same size
    img = imread(filename);
    img = imresize(img,[300 500]); %rectangle plate shape
    %imshow(img)
    
    %1)pre-processing
    gray = rgb2gray(img); %grayscale image
    %imshow(gray)
    
    t = graythresh(gray);
    %t = adaptthresh(gray,0.8); %adaptive threshold value, 0.8 sensitivity
    bin = ~imbinarize(gray,t); %apply to image (now white and black image)
    %imshow(bin)
    
    %remove any noise less than 100 pixels in size
    no_noise = bwareaopen(bin,100);
    %imshowpair(bin,no_noise,'montage')
    
    %locate background
    background = bwareaopen(no_noise,3200);
    %remove background from image
    difference = no_noise - background;
    %imshow(difference)
    
    %remove smaller noise again
    difference2=bwareaopen(difference,260);
    %imshow(difference2)
    charCandidates = difference2;
    
    %visualize
%     figure;
%     imshow(background)
%     figure;
%     imshow(difference)
%     figure;
%     imshow(charCandidates)
    
    %locate objects remaining in image (char candidates)and determine
    %connectivity
    [L,n]=bwlabel(charCandidates);
    props=regionprops(L,'BoundingBox');
%     hold on
%     for ii=1:size(props,1)
%         rectangle('Position',props(ii).BoundingBox,'EdgeColor','r','LineWidth',3)
%     end
%     hold off
    
    %pre-allocate data structures
    final_output=[];
%     figure;
    %loop through characters and compare with template images (via corr2)
    for ii=1:n
        [xx,yy] = find(L==ii);%locate charcter position
        char=no_noise(min(xx):max(xx),min(yy):max(yy)); %index character from image
        char=imresize(char,[42,24]); %resize image to match template sizes
%         imshow(char)%display char
 
        %# of template letters/numbers
        num_temp=size(imgfile,2);
        coefs = zeros(1,num_temp);
        
        %loop through all letters/numbers and correlate to char
        for j=1:num_temp
            corr=corr2(imgfile{1,j},char);%calculate corr. coefficient
            coefs(1,j) = corr;%save coefficient 
        end
        
        %only keep char's with coefficients > 0.5 confidence
        if max(coefs)>.50
            final_char=find(coefs==max(coefs)); %index the final chars
            output=cell2mat(imgfile(2,final_char));%index template value
            final_output=[final_output output]; %final results
        end
    end
    fprintf('Plate: %s\n',final_output);
    
  
    subplot(2,5,i)
    imshow(img)
    tt = "Result: " + final_output;
    title(tt)
    hold on
    
end

%close all;