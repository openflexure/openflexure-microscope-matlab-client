function outputArg = is_a_task(task)
    outputArg =  contains(task_href(task),'/api/v2/tasks/');
end
