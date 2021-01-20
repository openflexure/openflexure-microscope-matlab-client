function outputArg = poll_task(task)
    %poll_task Get the status of a task running on the microscope.
    assert(is_a_task(task),'poll_task must be called with a struct representation of a task');        
    log_n=1;
    while (contains(task.status,'running') || contains(task.status,'idle'))
        options = weboptions('Timeout',30);
        task =  webread(task_href(task), options);
            while length(task.log) >log_n
                d = task.log(log_n);
                fprintf('%s: %s\n' , d.levelname, d.message);
                log_n = log_n +1;
            end
    end

    try
        outputArg = task.output;
    catch
        try 
            outputArg = task.return;
        catch
            warning('Task endpoint was missing a return value.');
            outputArg = {};
        end
    end
 end