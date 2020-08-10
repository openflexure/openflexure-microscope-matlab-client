function outputArg = poll_task(task)
    %poll_task Get the status of a task running on the microscope.
    assert(is_a_task(task),'poll_task must be called with a struct representation of a task');
    while contains(task.status,['running','idle'])
        disp('here');
        options = weboptions('Timeout',30);
        task =  webread(task_href(task), options);
    end
    try
        outputArg = task.return;
    catch
        warning('Task endpoint was missing a return value.');
        outputArg = {};
    end
 end