function outputArg = task_href(task)
    %task_href Return the href of the task.
    try
        outputArg = task.links.self.href;
    catch
        outputArg  = '';
    end
end