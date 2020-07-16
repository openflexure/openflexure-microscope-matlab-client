%Test the stage movement
pos = microscope.position_as_matrix;
starting_pos = pos;
pos(1) = pos(1) + 100;
microscope.move(pos);
disp(isequal(microscope.position_as_matrix,starting_pos));
pos(1) = pos(1) - 100;
microscope.move(pos);
disp(isequal(microscope.position_as_matrix,starting_pos));

%Test the autofocus
ret = microscope.autofocus();

%Acquire an image
image = microscope.grab_image();
figure;
imagesc(image);

%List the extensions
disp("Active microscope extensions");
disp(microscope.extensions);

