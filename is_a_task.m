function outputArg = is_a_task(task)
    %is_a_task Returns whether a reponse struct is a task.
    outputArg =  contains(task_href(task),'/api/v2/tasks/')| contains(task_href(task),'/api/v2/actions/')  ;
end
