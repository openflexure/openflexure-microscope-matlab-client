classdef OFMClient < handle
    %OFMClient Simple client code for the OpenFlexure Microscope in
    %MATLAB
    %   This MATLAB class makes it easy to connect and control an
    %   OpenFlexure Microscope over a network. You are able to move the
    %   microscope and get the images from the microscope, as well as run
    %   extensions.
    %
    %OFMClient Properties:
    %   host - The microscope's hostname or IP address.
    %   port - The microscope's port.
    %   extensions - A struct of the microscope's currently loaded
    %   extensions.
    %
    %OFMClient Methods:
    %   base_uri - Return the microscope base URI.
    %   get_json - Make an HTTP GET request and return the response.
    %   post_json - Make an HTTP POST request and return the response.
    %   populate_extensions - Get a struct of the extensions and store in
    %   obj.extensions.
    %   position - Return the position of the stage as a struct.
    %   position_as_matrix - Return the position of the stage as a matrix.
    %   move - Move the stage to a given position.
    %   move_rel - Move the stage by a given amount.
    %   query_background_task - Request the status of a background task.
    %   capture_image - Capture an image and return it (TODO)
    %   grab_image - Grab an image from the stream and return it.
    %   calibrate_xy - Move the stage in X and Y to calibrate stage
    %   movements vs camera movements.
    %   autofocus - Run the fast autofocus routine.
    %
    %   See also: MicroscopeExtension, is_a_task, poll_task, replace_dots_dashes.
    
    properties (SetAccess = protected)
        host        %The microscope's hostname or IP address. (char or string)
        port        %The microscope's port. (char or string)
        extensions  %The microscope's currently loaded extensions. (struct of MicroscopeExtension)
    end
    
    methods
        function obj = OFMClient(host, port)
            %OFMClient Construct an instance of this class
            %   
            
            arguments
                host char
                port char = '5000'
            end
            obj.host = host;
            obj.port = port;

            disp('Connecting to microscope:') 
            fprintf('<a href = "http://%s:%s">%s:%s</a>\n',obj.host,obj.port,obj.host,obj.port);
            obj.populate_extensions()
        end
        
        function outputArg = base_uri(obj)
            %base_uri Return the microscope base URI.
            %
            outputArg = sprintf('http://%s:%s/api/v2', obj.host,obj.port);
        end
        
        function outputArg = get_json(obj, path)
            %get_json Make an HTTP GET request and return the response.
            if ~startsWith(path,'http')
                path = [obj.base_uri() path];
            end
            options = weboptions('Timeout',30);
            outputArg =  webread(path, options);         
        end
        
        function outputArg = post_json(obj, path, payload,waitOnTask,headerFields)
            %post_json Make an HTTP POST request and return the response.
            %
            arguments
                obj;
                path char;
                payload struct  = struct;
                waitOnTask char = 'auto';             
                headerFields cell = {' ' ' '};
            end

            if ~startsWith(path,'http')
                path = [obj.base_uri() path];
            end
            options = weboptions('Timeout',Inf, 'RequestMethod', 'post','HeaderFields',headerFields);
            r = webwrite(path, payload, options);
            
            if (strcmp(waitOnTask,'auto'))
                waitOnTask = is_a_task(r);
            end
            if waitOnTask
                outputArg = poll_task(r);
            else
                outputArg = r;
            end
            
        end
            
        function populate_extensions(obj)
            %populate_extensions Get a struct of the extensions and store in obj.extensions.
            %
            extensions_struct  = obj.get_json('/extensions/');
            for i = 1: numel(extensions_struct)
                title = extensions_struct(i).title;
                obj.extensions.(replace_dots_dashes(title)) = MicroscopeExtension(extensions_struct(i));
            end
        end
        
        function outputArg = position(obj)
            %position Return the position of the stage as a struct.
            outputArg = obj.get_json('/instrument/state/stage/position');
        end

        function outputArg = position_as_matrix(obj)
            %position_as_matrix Return the position of the stage as a matrix.
            %
            pos = obj.position();
            outputArg = [pos.x, pos.y, pos.z];
        end
        
        function move(obj,position, absolute)
            %move Move the stage to a given position.
            
            arguments
               obj
               position
               absolute logical = true;
            end    
           
            if isa(position,'struct')
                pos = position;
            else
                pos.x = position(1);
                pos.y = position(2);
                pos.z = position(3);
            end
            pos.absolute = absolute;
            obj.post_json('/actions/stage/move',pos,'auto');
        end
        
        function move_rel(obj, position)
            %move_rel Move the stage by a given amount.
            obj.move(position,false);
        end
        
        function outputArg = query_background_task(obj, task)
            %query_background_task Request the status of a background task.
            %
            outputArg = obj.get_json(task.links.self.href);
        end
        
        function outputArg = capture_image(obj)
            %capture_image Capture an image and return it 
            payload.use_video_port = true;
            payload.bayer = false;
            headerFields = {'Accept' 'image/jpeg'};
            outputArg   = obj.post_json('/actions/camera/ram-capture',payload, 'auto', headerFields);
            
        end
        
        function outputArg = grab_image(obj)
            %grab_image Grab an image from the stream and return it.
            %
            outputArg =  obj.get_json('/streams/snapshot');
        end
        
        function outputArg = calibrate_xy(obj)
            %calibrate_xy Move the stage in X and Y to calibrate stage movements vs camera movements.
            %
            outputArg = obj.extensions.org_DOT_openflexure_DOT_camera_stage_mapping.calibrate_xy.post_json();
        end
        
        function outputArg = autofocus(obj)
            %autofocus Run the fast autofocus routine.
            outputArg  = obj.extensions.org_DOT_openflexure_DOT_autofocus.fast_autofocus.post_json();
        end    
    end
end







