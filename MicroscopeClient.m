classdef MicroscopeClient <handle
    %MicroscopeClient Simple client code for the OpenFlexure Microscope in
    %Matlab
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        host
        port
        extensions
    end
    
    methods
        function obj = MicroscopeClient(varargin)
            %MicroscopeClient Construct an instance of this class
            %   Detailed explanation goes here
            defaultPort = '5000';
            p = inputParser;
            addRequired(p,'host',@(s) ischar(s) || isstring(s));
            addOptional(p,'port', defaultPort, @(s) ischar(s) || isstring(s));
            parse(p, varargin{:});
            obj.host = p.Results.host;
            obj.port = p.Results.port;
            disp('Connecting to microscope:') 
            fprintf('<a href = "http://%s:%s">%s:%s</a>\n',obj.host,obj.port,obj.host,obj.port);
            obj.populate_extensions()
          
        end
        
        function outputArg = base_uri(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = sprintf('http://%s:%s/api/v2', obj.host,obj.port);
        end

        function outputArg = post_json(obj, path,varargin)
            defaultPayload = struct;
            defaultWaitOnTask = 'auto'; 
            p = inputParser;
            p.StructExpand = false;
            addOptional(p,'payload',defaultPayload, @(s) ischar(s) || isstring(s) || isstruct(s));
            addOptional(p,'waitOnTask',defaultWaitOnTask,@(s) ischar(s) || isstring(s));
            parse(p, varargin{:});
            payload = p.Results.payload;
            waitOnTask = p.Results.waitOnTask;

            if ~startsWith(path,'http')
                path = [obj.base_uri() path];
            end
            options = weboptions('Timeout',Inf, 'RequestMethod', 'post','HeaderFields',{'Expect' ''});
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
        
        function outputArg = get_json(obj, path)
            if ~startsWith(path,'http')
                path = [obj.base_uri() path];
            end
            options = weboptions('Timeout',30);
            outputArg =  webread(path, options);         
        end
        
 
            
        function populate_extensions(obj)
            extensions_struct  = obj.get_json('/extensions/');
            for i = 1: numel(extensions_struct)
                title = extensions_struct(i).title;
                obj.extensions.(replace_dots(title)) = MicroscopeExtension(extensions_struct(i));
            end
        end
        
        function outputArg = position(obj)
            outputArg = obj.get_json('/instrument/state/stage/position');
        end

        function outputArg = position_as_matrix(obj)
            pos = obj.position();
            outputArg = [pos.x, pos.y, pos.z];
        end
        
        function move(obj,position, varargin)
            defaultAbsolute = true;
            p = inputParser;
            addOptional(p,'absolute',defaultAbsolute,@(s) islogical(s));
            parse(p,varargin{:});
            absolute = p.Results.absolute;
            
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
            obj.move(position,false);
        end
        
        function outputArg = query_background_task(obj, task)
            outputArg = obj.get_json(task.links.self.href);
        end
        
        function outputArg = capture_image(obj)
            %TODO
            %payload.use_video_port = true;
            %payload.bayer = false;
            %outputArg   = obj.post_json('/actions/camera/ram-capture',payload);
            
        end
        
        function outputArg = grab_image(obj)
            outputArg =  obj.get_json('/streams/snapshot');
        end
        
        function outputArg = calibrate_xy(obj)
            outputArg = obj.extensions.org_DOT_openflexure_DOT_camera_stage_mapping.calibrate_xy.post_json();
        end
        
        function autofocus(obj)
            obj.extensions.org_DOT_openflexure_DOT_autofocus.fast_autofocus.post_json();
        end    
    end
end

function outputArg = replace_dots(text)
    outputArg = replace(text,'.','_DOT_');
end  






