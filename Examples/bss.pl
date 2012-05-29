#!/opt/local/bin/perl
#
#  BleuLlama's Sprite Sheet Builder
#  		takes in an output filename, and a list of source directories
#  		it generates output.h containing the struct definition, and struct of tiles
#  		it generates output.png containing the necessary sprite sheet image
#
#  Adapted from a version of this that I originally created for the
#  Trilobyte game "The 7th Guest: Infection".  Although it was created
#  under their paycheck, they very graciously allowed me to release it
#  for general consumption into the wild.
#
#  This is considered to be under a MIT license.
#
#  V 0.02 - 2012 May 29		.PLIST generation for BL2D
#
#  V 0.01 - 2011 Jan 01		SL basic functionality
#           (c) 2011 Scott Lawrence, Trilobyte
#

# this is written in perl.  sorry about that.


$padding = 1;	# 1px padding per image
$maxWidth = 1024;	# max width for the sheet

# in case there's an issue, print usage and return
sub usageExit
{
	printf( "BLSSB - BleuLlama's Sprite Sheet Builder\n" );
	printf( "        a part of the BL2D engine package\n" );
	printf( "        Scott Lawrence, yorgle\@gmail.com\n" );
	printf( "\n" );
	printf( "Usage:\n" );
	printf( "     bss.pl OUTPUT DIR0 DIR1 ... \n" );
	printf( "\n" );
	printf( " Generates OUTPUT.PNG, OUTPUT.PLIST, OUTPUT.H, using source content in DIR...\n\n" );
	printf( " NOTE: current implementation does an image \"newline\" on a new directory.\n" );
	printf( "       Plan accordingly.\n" );
	exit( shift );
}

# if we have too few, just return
if( scalar @ARGV < 2 ) {
	usageExit( -1 );
}
$outputFN = $ARGV[0];


# build the list of source files.
for( $i=1 ; $i< scalar @ARGV ; $i++ )
{
	if( !-d $ARGV[$i] ) {
		printf( "ERROR: %s: Directory does not exist!\n", $ARGV[$i] );
		usageExit( -2 );
	}
	push @sourceList, $ARGV[$i];
}

# okay, now, we have a destination file, as well as a list of source directories.
printf( "Generating sprite sheet: %s\n", $outputFN );
printf( "Using: %s\n", join " ", @sourceList );



# subfunction to return a file list of a directory as an array
sub dirlist {
        my $dir = shift;
        my @filelist;
        opendir(DIR, $dir) or die "can't opendir $dir: $!";
        while (defined(my $file = readdir(DIR))) {

                # Skip "." and ".."
                next if ($file =~ /^\.\.?$/);
		# skip dot files
                next if ($file =~ /^\./);
                push(@filelist, $file);
	}
        closedir(DIR);
        return @filelist;
}


# determine the resolution of the destination image
# build a list of files and their grid locations
$totalHeightNeeded = 0;
$maxWidthNeeded = 0;

@tiles = ();

$baseX = 0;
$baseY = 0;

@rowHeights = ();

$row = 0;

foreach $sourceDir ( @sourceList )
{
	@dirList = dirlist( $sourceDir );
	sort @dirList; # sort, just in case

	#printf( "Directory %s contents:\n%s\n", $sourceDir, (join "\n    ", @dirList) );

	@wid = ();
	@hig = ();
	$col = 0;

	foreach $f ( @dirList )
	{
		# run ImageMagick's 'identify' command to get the resolution of the image
		$cmd = sprintf( "identify %s/%s", $sourceDir, $f );
		$o = `$cmd`;
		@oe = split " ", $o;

		($w, $h) = split "x", $oe[2];  # element [2] is the resolution eg:  "100x100" -- split it!
		$w += $padding;
		$h += $padding;

		# total width
		if( $wid[$row]+$w > $maxWidth ) {
			$row++;
			$col = 0;
		}
		$wid[$row] += $w;

		# max height
		if( $h > $hig[$row] ) {
			$hig[$row] = $h;
		}

		# store aside the data we need for the command build loop below...
		push @tiles, sprintf "%02d %02d %s/%s %d %d", $row, $col, $sourceDir, $f, $w, $h;

		$col++;
	}
	$row++;

	# accumulate rows and such
	foreach $rw ( @wid )
	{
		if( $rw > $maxWidthNeeded ) { $maxWidthNeeded = $rw; }
	}

	foreach $rh ( @hig )
	{
		$totalHeightNeeded += $rh;
		if( $rh ) { push @rowHeights, $rh; }
	}

}


# simple function to return if a value is a power of 2 or not
sub isPowerOfTwo
{
	$value = shift;
	return ($value & -$value) == $value;
}

# gets the next power of two based on the value passed in
sub nextPowerOfTwo
{
	$next_pow = shift;
	$next_pow--;
	$next_pow = ($next_pow >> 1) | $next_pow;
	$next_pow = ($next_pow >> 2) | $next_pow;
	$next_pow = ($next_pow >> 4) | $next_pow;
	$next_pow = ($next_pow >> 8) | $next_pow;
	$next_pow = ($next_pow >> 16) | $next_pow;
	$next_pow++; # Val is now the next highest power of 2.
	return $next_pow;
}

# returns the current number if it's a power of 2 otherwise returns the next power of two
sub p2
{
	$val = shift;
	if( isPowerOfTwo( $val ) ) { return $val; }
	return nextPowerOfTwo( $val );
}


# target image size calculations (power of 2, for OpenGL)
$targW = p2( $maxWidthNeeded );
$targH = p2( $totalHeightNeeded );

printf( "Sprite sheet size: %s x %s  (pad to %s x %s)\n", $maxWidthNeeded, $totalHeightNeeded, $targW, $targH );

#printf( "items: \n   %s\n", join "\n   ", @tiles );

$line = sprintf " infile.png -geometry +0+85 -composite ";
$end = sprintf " output.png";

# okay.  We could have done this up above, but i decided to shove it here instead.
# Let's now build the 'convert' command string to do all of this for us!

$dotH = "";

$command = sprintf "convert -size %dx%d xc:transparent ", $targW, $targH;
$topx = 0;
$topy = 0;
# compute y offsets
@yoffs = ();
$acc = 0;
foreach $rh ( @rowHeights )
{
	push @yoffs, $acc;
	$acc += $rh;
}

$lr = -1;
$xoffs = 0;
$idx = 0;
foreach $tile ( @tiles )
{
	# extract out the bits we stashed aside
	($r, $c, $sourcePNG, $w, $h) = split " ", $tile;
	# adjust for rows
	if( $r != $lr ) { $xoffs = 0; }

	# add the bit to the command to build the sprite sheet PNG
	$command .= sprintf "%s -geometry +%d+%d -composite ", $sourcePNG, $xoffs, $yoffs[$r];

	# compute the coordinates of the corners.
	$x0 = sprintf "%d.0f/%d.0f", $xoffs, $targW;
	$x1 = sprintf "%d.0f/%d.0f", $xoffs + $w-$padding, $targW;
	$y0 = sprintf "%d.0f/%d.0f", $yoffs[$r], $targH;
	$y1 = sprintf "%d.0f/%d.0f", $yoffs[$r] + $h-$padding, $targH;

	# now, create the bit for the .h structure (Backwards N)
	#  x0, y0,  x0, y1,  x1, y0,  x1, y1
	$dotH .= sprintf "    %13s, %13s,  %13s, %13s,  %13s, %13s,  %13s, %13s,   /* %3d: %s */\n",
			$x0, $y0,  $x0, $y1,  $x1, $y0,  $x1, $y1,  
			$idx++, $sourcePNG;

	push @widths, $w;
	push @heights, $h;

	push @xoffsA, $xoffs;
	push @yoffsA, $yoffs[$r];

	$xoffs += $w;
	$lr = $r;
}

$command .= sprintf " %s.png", $outputFN;
# and build the png!
printf "About to use ImageMagick's 'convert' to build the output spritesheet\n";
`$command`;


######################################################################
# now we generate a plist file containing the reference data

$plistfn = sprintf "%s.plist", $outputFN;

$plist = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
$plist .= "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n";
$plist .= "<plist version=\"1.0\">\n";
$plist = "<dict>\n";

$plist .= "  <key>Metadata</key>\n";
$plist .= "  <dict>\n";
$plist .= "    <key>generator</key><string>bss v0.02</string>\n";
$plist .= "    <key>monkeys</key><integer>7</integer>\n";
$plist .= "  </dict>\n";

$plist .= "  <key>Image</key>\n";
$plist .= "  <dict>\n";
$plist .= sprintf "    <key>base</key><string>%s</string>\n", $outputFN;
$plist .= sprintf "    <key>file</key><string>%s.png</string>\n", $outputFN;
$plist .= sprintf "        <key>w</key><integer>%d</integer>\n", $targW;
$plist .= sprintf "        <key>h</key><integer>%d</integer>\n", $targH;
$plist .= "  </dict>\n";

$plist .= "  <key>Sprites</key>\n";
$plist .= "  <array>\n";

$i = 0;
foreach $tile ( @tiles )
{
	# extract out the bits we stashed aside
	($r, $c, $sourcePNG, $w, $h) = split " ", $tile;

	$plist .= "    <dict>\n";
	$plist .= sprintf "        <key>idx</key><integer>%d</integer>\n", $i;
	$plist .= sprintf "        <key>name</key><string>%s</string>\n", $sourcePNG;
	$plist .= sprintf "        <key>x</key><integer>%d</integer>\n", $xoffsA[$i];
	$plist .= sprintf "        <key>y</key><integer>%d</integer>\n", $yoffsA[$i];
	$plist .= sprintf "        <key>w</key><integer>%d</integer>\n", $widths[$i] - $padding;
	$plist .= sprintf "        <key>h</key><integer>%d</integer>\n", $heights[$i] - $padding;

	$plist .= "    </dict>\n";
	$i++;
}

$plist .= "  </array>\n";

$plist .= "</dict>\n";

$plist .= "</plist>\n";

# dump it to file
open OF, ">$plistfn";
printf OF "%s\n", $plist;
close OF;


######################################################################
# now also export the .h file containig the reference data.
$structname = sprintf "spr_%s[%d * 8]", $outputFN, scalar @tiles;
$wname = sprintf "sprw_%s[%d]", $outputFN, scalar @tiles;
$www = join ", ", @widths;
$hname = sprintf "sprh_%s[%d]", $outputFN, scalar @tiles;
$hhh = join ", ", @heights;
$maxcountname = sprintf "count_%s", $outputFN;
$maxcount = scalar @tiles;

$headerFileText =<<EOB;
/* $outputFN header file
 *  Generated by bss.pl.  Do not edit this file unless you want PAIN
 *  bss.pl is (c)2011 Scott Lawrence, Trilobyte
 *
 *  Include this file in *one* .m file.
 *
 *  Pseudoishcode to render a sprite:

void drawSprite( int idx )
{
	// bounds check the INDEX (sprite number)
	if( idx > $maxcountname || idx < 0 ) return;

	// GL stuff (once per series of sprites)
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, theGLUintOfThePngGeneratedLoadedIn );

	// set the source position in the sheet.
	glTexCoordPointer( 2, GL_FLOAT, 0, &spr_$outputFN\[idx *8] ); // source in sheet

	// build the "backwards N" for the screen: x0, y0, z0,  x1, y1, z1,  etc.
	GLfloat destVerts[12]; // backwards N
	GLfloat w = sprw_$outputFN\[idx];
	GLfloat h = sprh_$outputFN\[idx];

	destVerts[0] = 0.0;             destVerts[1] = 0.0;             destVerts[2] = 0.0;
	destVerts[3] = 0.0;             destVerts[4] = h;               destVerts[5] = 0.0;
	destVerts[6] = w;               destVerts[7] = 0.0;             destVerts[8] = 0.0;
	destVerts[9] = w;               destVerts[10] = h;              destVerts[11] = 0.0;

	// set the pointer
	glVertexPointer( 3, GL_FLOAT, 0, destVerts ); // position on screen

	// draw it!
	glColor4f( 1.0, 1.0, 1.0, 1.0 ); // adjust this to attenuate channels R, G, B, A
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	// GL stuff (once per series of sprites
	glBindTexture(GL_TEXTURE_2D, 0);	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

 *
 */

#define $maxcountname $maxcount

GLfloat $structname = {
$dotH
};

GLfloat $wname = {
$www
};

GLfloat $hname = {
$hhh
};
EOB

$outfn = sprintf "%s.h", $outputFN;
open OF, ">$outfn";
printf OF "%s\n", $headerFileText;
close OF;
