----------------------------------------
BleuLlama2D Engine (BL2D) version 1.0
2010-September-17
yorgle@gmail.com


----------------------------------------

This is a simple GLES1-based tilemap and sprite engine for iOS.

It should work on all current iOS devices (iPad, iPod Touch, iPhone) 

It should work on all iOS versions from 3.0 to 4.2.


----------------------------------------
NOTES:

- Look in the ..ViewController.m file for the actual tilemap/sprite code added.

- This is OpenGLES 1 *ONLY* (No GLES2 support is planned)

- PNG files must be RGB, can have transparency


----------------------------------------
Changes needed to be made to an iOS 4.x template GL project:

- In EAGLView, the color format needs to be changed from kEAGLColorFormatRGBA8 to kEAGLColorFormatRGB565

- all source should be Objective-C++ .mm (since the core engine is C++)
  (for now.)

- added CoreGraphics framework - for loading png and sticking it in a texture


----------------------------------------
For 3.0 compatibility:

- application:didFinishLaunchingWithOptions added to the AppDelegate file

- deployment Target needs to be set to iOS 3.0

- remove the connection via IB in MainWindow.xib to rootViewController


----------------------------------------
Thanks:

Many thanks to Nyarla et al.!
