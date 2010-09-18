----------------------------------------
BleuLlama2D Engine (BL2D) version 1.0
2010-September-17
yorgle@gmail.com


----------------------------------------

This is a simple GLES1-based tilemap and sprite engine for iOS.

It should work on all current iOS devices (iPad, iPod Touch, iPhone) 

It should work on all iOS versions from 3.0 to 4.2.

This is shared under an MIT License.


--------------------------------------------------------------------------------
The basic engine is in the BL2DClasses folder.  Drop this into your project
Be sure to add the CoreGraphics framework.

It is currently set in BLGLInterface.h for 16 graphics textures, in 16 layers.
This should be plenty for most projects.

BL2D.h defines two layers for use; one for tilemaps, one for sprites. This may 
be more flexible in the future.

BL2DDemo is a project showing its use.


----------------------------------------
NOTES:

- Look in the ..ViewController.m and .h file for the actual tilemap/sprite code added.

- This is OpenGLES 1 *ONLY* (No GLES2 support is planned)

- PNG files must be RGB, can have transparency


----------------------------------------
Changes needed to be made to use this in your project:

- In EAGLView, the color format needs to be changed from kEAGLColorFormatRGBA8 to kEAGLColorFormatRGB565

- add CoreGraphics framework - for loading png files


----------------------------------------
For 3.0 compatibility:

- application:didFinishLaunchingWithOptions added to the AppDelegate file

- deployment Target needs to be set to iOS 3.0

- remove the connection via IB in MainWindow.xib to rootViewController


----------------------------------------
Thanks:

Many thanks to Nyarla et al.!
