# A MATLAB client for the OpenFlexure Microscope

These MATLAB classes make it easy for you to connect and control an OpenFlexure Microscope over a network. You are able to move the microscope and get the images from the microscope, as well as run extensions.

## Installation

You just need to download/clone this repository and make sure the files are added to your MATLAB path. Once confirmed stable, it will also be available from MathWorks File Exchange.

## Usage

To connect to your microscope, you can either:

* Use `microscope.local`.  
  
    ```matlab
    microscope = OFMClient('microscope.local');
    ```

* Use the microscope's **hostname** or **IP address**.  
  
    ```matlab
    microscope = OFMClient('example.host.name');
    microscope = OFMClient('XXX.XXX.XXX.XXX');
    ```  

If necessary you can also set the port (default is `5000`):  

```matlab
microscope = OFMClient('example.host.name','port');
```

## Check the connection

To test if your connection has worked, you can run the following block (it is also a script in the repository called `check_the_connection.m`.):  

```matlab
%Test the stage movement
pos = microscope.position_as_matrix();
starting_pos = pos;
pos(1) = pos(1) + 100;
microscope.move(pos);
disp("Is the microscope in the starting position?");
disp(isequal(microscope.position_as_matrix(),starting_pos));
pos(1) = pos(1) - 100;
microscope.move(pos);
disp("Is the microscope in the starting position?");
disp(isequal(microscope.position_as_matrix(),starting_pos));

%Test the autofocus
ret = microscope.autofocus();

%Acquire an image
image = microscope.grab_image();
figure;
imagesc(image);

%List the extensions
disp("Active microscope extensions");
disp(microscope.extensions);
```

This will test the stage movement, run the autofocus routine, show a picture taken by the microscope and list the extensions that are on the microscope.

## Basic Commands

The `MicroscopeClient` object has a few basic methods.  If you created an instance of the object with the name `microscope` as above, these are the commands:

| Command | Input arguments | Output arguments | Description |
| --- | --- | --- | --- |
|`microscope.position()` | | A `struct` with fields `x`, `y` and `z`.| The microscope stage's current position.|
|`microscope.position_as_matrix()` | | A `1x3 matrix` of the form `[x y z]`.| The micrscope stage's current position. |
|`microscope.move(position)` | **Either** a `1x3 matrix` of the form `[x y z]` **or** a `struct` with the fields `x`, `y`, `z`. | | Moves the stage to the absolute position. |
|`microscope.move_rel(position)`| **Either** a `1x3 matrix` of the form `[x y z]` **or** a `struct` with the fields `x`, `y`, `z`. | | Moves the stage relative to the current position.|
|`microscope.capture_image()` | | | Work in progress|
|`microscope.grab_image()` | |A `[image_height x image_width x 3] uint8 array` | Gets the next image the camera sends in its MJPEG preview stream.|
|`microscope.calibrate_xy()`| | | Untested.|
|`microscope.autofocus()` | | | Runs the fast autofocus  routine. |


## Extensions

To run methods provided by the microscope extensions, you can use the `extensions` `struct` to make `get` or `post` requests.  

**However**, due to MATLAB struct limitation, you need to replace any `.` in your extension name to `_DOT_` and any `-` to `_DASH`. For example, the extension `org.openflexure.autofocus` should be written as `org_DOT_openflexure_DOT_autofocus`.

For a post request, `data` can be a `struct`, `character vector`, `numeric`, `cell` etc. The full list of supported types for post requests is in the [MATLAB documentation](https://uk.mathworks.com/help/matlab/ref/webwrite.html#buocgv5-data), but they have not all been tested.

```matlab
microscope.extensions.your_DOT_extension_DOT_name.link_name.get();
microscope.extensions.your_DOT_extension_DOT_name.link_name.post(data);
```
