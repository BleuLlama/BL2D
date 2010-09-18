//
//  Shader.vsh
//  BL2DDemo
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
