----------------------------------------
BleuLlama2D Engine (BL2D) version 2.0
2012-June-04
yorgle@gmail.com


----------------------------------------

This is a simple GLES1-based tilemap and sprite engine for iOS.

It should work on all current iOS devices (iPad, iPod Touch, iPhone) 

It should work on all iOS versions from 3.0 through 5.1

This is shared under an MIT License.

--------------------------------------------------------------------------------

NOTE: if the BL2DClasses files are red, delete the "BL2DClasses" yellow 
folder from this project, and re-drag in the BL2DClasses folder over, 
"[x] create groups" and it should work fine.  You may need to do this 
with the "Graphics" content as well.

--------------------------------------------------------------------------------
The basic engine is in the BL2DClasses folder.  Drop this into your project
Be sure to add the CoreGraphics framework.

When layers (tilemaps, sprites) are instantiated through the BL2D engine class,
they are added to an internal list which is rendered when the engine instance's
render method is called.  This means that all you have to do is:

1. instantiate the BL2DGraphics objects per each tileset
2. instantiate the tilemaps you want to define
3. instantiate the sprite you want to define
4. instantiate the poly layers you want to define

Then in your frame update code, just set the parameters as you need 
to (sprite position, flip, tile index, etc.) and call the engine's render,
and it'll take care of setting up the GL settings, and getting each layer
rendered.

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

    Thanks to Nyarla for the original code this was initially based on.
    
    Thanks to Madgarden for the original Turtle code.
    
    Thanks to Trilobyte Games for being awesome and letting me reuse some code I had written for them
    
    Thanks to everyone else!
