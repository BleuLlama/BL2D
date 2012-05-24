//
//  Shader.fsh
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
