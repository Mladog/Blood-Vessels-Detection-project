classdef eye_pattern < matlab.mixin.SetGet
    
    properties 
        original_image
        processed_image
        resized_image
        path
    end  
    
    methods
        function set.original_image(obj, val)
            obj.original_image = val;
        end
        
        function set.resized_image(obj, val)
            obj.resized_image = val;
        end
        
        function set.processed_image(obj, val)
            obj.processed_image = val;
        end
        
        function im = get.original_image(obj)
            im = obj.original_image;
        end
        
        function im = get.resized_image(obj)
            im = obj.resized_image;
        end
        
        function im = get.processed_image(obj)
            im = obj.processed_image;
        end
        
        %konstruktor
        function obj = eye_pattern
            obj.importData;
%             obj.binarize;
%             obj.crop;
        end
        
        function get_final_eye_pattern(obj)
            obj.binarize;
            obj.crop;            
        end
        
        %update
        function update(obj)
            obj.importData;
            obj.binarize;
            obj.crop;
        end
        
        % cropping
        function crop(obj) %funkcja przycinajaca odpowiednio obraz
            edged_image = edge(obj.processed_image, 'canny'); %detecting the edges from image

            [x,y] = find(edged_image==1); %finding detected area
            min_row = min(x);
            max_row = max(x);
            min_column = min(y);
            max_column = max(y);

           cropped_image = obj.processed_image(min_row:max_row, min_column:max_column, :);
           obj.resized_image = imresize(cropped_image, [584 565]);
        end   
    end
    
    methods (Access = 'private')

        
        function importData(obj) %function to import photo from user's computer
            [file,pt] = uigetfile('C:\Users\');
            if isnumeric(file) || isnumeric(pt) %if there is no path given
                error('path not given')
            end
            [~,~, ext] = fileparts(file);
            fullpath = {pt, file};
            obj.path = strjoin(fullpath, '');

            if (string(ext) ~= '.mat' && string(ext) ~= '.jpg' && string(ext) ~= '.png') %input file must have .mat extension
                error('wrong extension')
            end
            imported = imread([pt, file]);
            obj.original_image = imported;
        end
    end
    
    methods %private
        function binarize(obj) %funkjcja sprawdzająca poprawność kolorystyczna
            [~, ~, numberOfColorChannels] = size(obj.original_image);
            if numberOfColorChannels > 1 %means it's not binary, 
                error('wrong picture color')
            end
            image_info = imfinfo(obj.path);
            bits = image_info.BitDepth;
            
            if bits == 2
                binary_image = obj.original_image;
                %cleaning noise
                obj.processed_image = bwareaopen(binary_image, 80);
            elseif bits < 10 %if BitDepth < 10 -> image is binary, but lost quality while compresion
                binary_image = imbinarize(obj.original_image);
                %cleaning noise
                obj.processed_image = bwareaopen(binary_image, 80);
            else
                error('image is not black-white')
            end

        end
    end
    
end
