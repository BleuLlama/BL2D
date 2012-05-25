#!/usr/bin/perl
#
# copyTemplate.pl
#
#	(c) Scott Lawrence 2011
#
#	Scans a set of template directories, and allows you to copy over
#	the project, tailored for your needs.
#
#	Note: "templates" are sample projects that are compilable as-is
#	      without modification.  They are not exclusively Xcode projcts
#		but rather, inclusively Xcode projects.  This means that
#		these can be used for other build systems as well.
#
#
# v1.0 -- 2011-Nov-7
#	Basic functionality

$| = 0;


########################################
# directory scanning

sub scanDirForTemplates
{
	my( @dlist, $templateDir );
	$templateDir = shift;

	if( !-d $templateDir ) {
		printf( "%s: Not a valid template directory\n", $templateDir );
		return( @dlist );
	}

	printf( "Directory for templates: %s\n", $templateDir );

	opendir ID, $templateDir;
	foreach $fn (readdir ID)
	{
		# skip dot-directories
		next if( $fn eq "." );
		next if( $fn eq ".." );

		# skip non-directories
		next if( !-d $fn );

		# okay, we've got a valid directory. check for template file
		$tfp = $fn . "/template.txt";
		next if( !-e $tfp );

		push( @dlist, $fn );
	}
	closedir( ID );

	return( @dlist );
}


########################################
# template file accessing

sub getValueForKey
{
	my $dn = shift;		# directory name
	my $key = shift;	# key
	my $value = "";

	# load in the template
	$dn .= "/template.txt";
	open FILE, $dn;
	my @fc = <FILE>;
	close FILE;
	
	# iterate through the list for the value we need
	my $line;
	foreach $line ( @fc ) {
		chomp $line;
		my @bits = split( '==', $line );
		if( scalar @bits > 1 ) {
			if( $bits[0] eq $key ) {
				return $bits[1];
			}
		}
	}
	
	return $value;
}


########################################
# user input stuff

sub getTextSelection
{
	printf "%s ", shift;
	my $inline = <STDIN>;
	chomp $inline;
	return( $inline );
}


sub getNumberSelection
{
	$v = getTextSelection( shift );

	if ($v =~ /^[+-]?\d+$/ ) {
		return int( $v );
	}

	return -1;
}


########################################
# file and directory manips

sub mkpath
{
	my $path = shift;
	my @pb = split "/", $path;
	my @tp;

	# break down the path, and build it back up, mkdir as we go

	foreach $p ( @pb )
	{
		push( @tp, $p );
		my $tfp = join "/", @tp;

		mkdir( $tfp );
	}
}

sub renameSubsituteRecursive
{
	my $path = shift;
	my $search = shift;
	my $replace = shift;
	my $fn;

	# 1. rename
	opendir ID, $path;
	foreach $fn (readdir ID)
	{
		next if( $fn eq "." );
		next if( $fn eq ".." );

		my $sfn = $path . "/" . $fn;
		my $mfn = $fn;
		$mfn =~ s/$search/$replace/g;
		my $dfn = $path . "/" . $mfn;

		rename( $sfn, $dfn );
	}
	closedir ID;

	# 2. recurse down each subdir
	opendir ID, $path;
	foreach $fn (readdir ID)
	{
		next if( $fn eq "." );
		next if( $fn eq ".." );

		my $fp = $path . "/" . $fn;

		if( -d $fp ) {
			# recurse down directories
			renameSubsituteRecursive( $fp, $search, $replace );
		}

		else {
			# replace in files
			my $tempfp = $fp . ",,,temp.txt";
			open IF, $fp;
			open OF, ">" . $tempfp;
			while( my $ll = <IF> ) {
				$ll =~ s/$search/$replace/g;
				print OF $ll;
			}
			close OF;
			close IF;

			# copy it over
			unlink( $fp );
			rename( $tempfp, $fp );
		}
	}
	closedir ID
}


########################################
# main - handle main loop stuff
sub main
{
	$templateDir = ".";
	# 1. check args
	if( scalar @ARGV > 0 ) {
		$templateDir = $ARGV[0];
	}
	
	# 2. get a list of template directories
	@dirList = scanDirForTemplates( $templateDir );

	if( scalar @dirList == 0 ) {
		printf( "No valid templates found.\nExiting.\n" );
		return;
	}

	# 3. display a list of templates to source from
	printf( "\n" );
	printf( "Source templates:\n" );
	$i = 0;
	foreach $td ( @dirList )
	{
		printf( "   %d: %s - %s\n", $i, 
			getValueForKey( $td, "name" ),
			getValueForKey( $td, "description" ));
		
		$i++;
	}

	printf( "   e: exit\n" );

	my $idx = getNumberSelection( "\nEnter selection:" );

	if( $idx < 0 || $idx > scalar @dirList ) {
		printf( "%d: invalid selection.\nExiting.\n", $idx );
		return;
	}

	# 4. prompt for the destination
	my $destName = getTextSelection( "\nNew Project Name:" );
	if( $destName eq "" ) { 
		printf "Project name required.\nExiting.\n";
		return;
	}

	my $destPath = getTextSelection( "\nNew Project Folder:" );
	if( $destPath eq "" ) { $destPath = "."; }
	printf( "\n" );

	# 5. sanity check the destination
	$destFullPath = $destPath . "/" . $destName;
	$destFullPath =~ s/\/+/\//g;
	if( -e $destFullPath || -d $destFullPath ) {
		printf( "%s: Already exists.\nExiting.\n", $destFullPath );
		return;
	}

	# 6. Display user selections
	printf( "Source project : \"%s\"\n", $dirList[$idx] );
	printf( "   New project : \"%s\"\n", $destName );
	printf( "     Dest path : \"%s\"\n", $destFullPath );

	# 7. make the directories
	mkpath( $destFullPath );

	# 8. copy the files
	my $sourcePath = $dirList[$idx] . "/contents/\*";
	`cp -Rf $sourcePath $destFullPath`;

	# 9. search and destroy!
	my $basename = getValueForKey( $dirList[$idx], "basename" );
	#printf( "About to replace \"%s\" with \"%s\"\n", $basename, $destName );

	# 10. rename directores and files, and change their contents
	renameSubsituteRecursive( $destFullPath, $basename, $destName );

	# 11. remove any xcuserdata directories (start clean)
	printf( "\nCleaning up...\n" );
	print `find $destFullPath -name xcuserdata | xargs rm -r`;

	printf( "\nDone.  Your new project is in %s\n\n", $destFullPath );
}


########################################
&main;
