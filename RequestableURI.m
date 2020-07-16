classdef RequestableURI <handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        href
        description
        method_s
    end
    
    methods
        function obj = RequestableURI(link)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            obj.href = link.href;
            obj.description = link.description;
            obj.method_s = link.methods;
        end
        
        function outputArg = get_json(obj)
            options = weboptions('Timeout',60);
            outputArg =  webread(obj.href, options);      
        end

        function outputArg = post_json(obj, varargin)
            defaultPayload = struct;
            defaultWaitOnTask = 'auto'; 
            p = inputParser;
            p.StructExpand = false;
            addOptional(p,'payload',defaultPayload, @(s) ischar(s) || isstring(s) || isstruct(s));
            addOptional(p,'waitOnTask',defaultWaitOnTask,@(s) ischar(s) || isstring(s));
            parse(p, varargin{:});
            payload = p.Results.payload;
            waitOnTask = p.Results.waitOnTask;  
            
            if ~any(strcmp(obj.method_s,"POST"))
                error("This URI does not support POST requests");
            end
                
            
            options = weboptions('Timeout',60, 'RequestMethod', 'post','HeaderFields',{'Expect' ''});
            r = webwrite(obj.href, payload, options);
            
            if (strcmp(waitOnTask,'auto'))
                waitOnTask = is_a_task(r);
            end
            if waitOnTask
                outputArg = poll_task(r);
            else
                outputArg = r;
            end
        end
    end
end

