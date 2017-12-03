#!/usr/bin/perl

#This program extracts data fields from the TOC files and makes index files out
#of them.  It also puts the associated text files in the right FTP directories.


require ("/usr/users/ken/bin/dr.smock.params");
require ("/usr/users/ken/bin/dr.math.lib.pl");
require ("ctime.pl");


print STDERR ("\nThe TOC files will be found in $TOCdir\n");
print STDERR ("The text files will be found in $TEXTdir\n");
print STDERR ("The FTP files will be put in $FTPdir\n");
print STDERR ("The HTML problem files will be put in $HTMLdir\n");
print STDERR ("The header for the problem files will be $head\n");
print STDERR ("The footer for the problem files will be $foot\n");
print STDERR ("The searcher document will be $searcher\n");
print STDERR ("The error log will be $error_log_file\n");
print STDERR ("Everything in the FTP and HTML directories will be erased.\n");


if ($TOCdir eq "" || $funcTOCdir eq "" || $TEXTdir eq "" || $FTPdir eq "" || 
	$HTMLdir eq "" || $funcHTMLdir eq "" || $head eq "" || $foot eq "" || 
	$searcher eq "") {
	die ("\nError: One of the parameters has an empty value, which is not allowed.\n",
		  "You can change the parameters in the file ~ken/bin/dr.smock.params.\n",
		  "Aborting Dr. Smock.\n\n");
}


if (-e $error_log_file) {
	print ("\nError: the error log file already exists, and running this program\n",
			 "would overwrite it.  Please rename the error log \n($error_log_file) ",
			 "if you want to save its contents, \nor remove it if you ",
			 "don't need it anymore.\n\n",
			 "Aborting Dr. Smock.\n\n");
	exit(1);
}
			

print STDERR ("\nIs this okay? (type y or n): ");
if (&testanswer) {
	print ("\nCreating FTP and HTML files...\n");
} else {
	die ("\nAborting Dr. Smock.  To change the above parameters,\n",
		  "edit the file ~ken/bin/dr.smock.params\n\n");
}


#make a list of all the files currently in the problems directory
opendir (PROBLEMDIR, "$HTMLdir") || die ("Couldn't make a list of the files previously in the problems directory\n");
@old_problems = readdir (PROBLEMDIR);
closedir (PROBLEMDIR);

($sec,$min,$hr,$dy,$mo,$yr,$wd,$yd,$ds) = localtime (time);

print STDERR ("Backing up $HTMLdir\n");
system ("tar cf /usr/new/lib/httpd/documents/dr.math/tar/dr.math.$mo"."_"."$dy"."_"."$yr.$hr:$min.tar $HTMLdir"); # || die ("can't back up the problems\n");
system ("gzip /usr/new/lib/httpd/documents/dr.math/tar/dr.math.$mo"."_"."$dy"."_"."$yr.$hr:$min.tar");
print STDERR ("Erasing contents of $FTPdir\n");
system ("rm -fr $FTPdir*");
print STDERR ("Erasing contents of $HTMLdir\n");
system ("rm -fr $HTMLdir");
print STDERR ("Erasing searcher file...\n");
system ("rm -f $searcher");
open (SEARCHDOC, ">$searcher");

print STDERR ("Processing files:\n");


@date = ("<address>".&ctime(time)."</address><br>\n");

open (ERRORS, ">$error_log_file");

opendir (TOCDIR, $TOCdir) || die ("$TOCdir cannot be opened.\n");
@fields = ();
while ($filename = readdir(TOCDIR) ){
	if ($filename eq ".") {
		next;
	}
	if ($filename eq "..") {
		next;
	}
	open (TOCFILE, $TOCdir.$filename) || print ERRORS ("Cannot read TOC file $filename: are the permissions correct?\n\n");
	@file = <TOCFILE>;
	
	#extract the right fields
	chop @file;
	$joined = join("", @file);
	$joined =~ /<!--\s*ftp\s*directory:\s*(\S*)\s*-->/i;
	$FTPsub = $1;
	$joined =~ /<!--\s*parent\s*web\s*page\s*url\s*:\s*(\S*)\s*\(\s*(.*)\s*\)\s*-->/i;
	$parentURL = $1;
	$parentURLtitle = $2;
	$joined =~ m#([^>]*)</h\d>#i;
	$name = $1;
	print ("\n$FTPsub\n");
	@threads = split (/<li>/i, $joined);
	
	&makedirs ($FTPdir, $FTPsub);

	$FTPfile = "$FTPdir"."$FTPsub"." INDEX";
	
	foreach $threadtext (@threads) {
		
		#get the fields for processing
		if ($threadtext =~ /^\s*<html>/i) {
			next;
		}
		if ($threadtext =~ /^\s*<a href=\"?\.\.\/problems\/(.*)\.html\"?>\s*(.*)\s*<\/a>\s*\[(.*),\s*(.*)\]\s*<br>(.*)<p>/i) {
			
			$textfile = $1;
			$descript =  $2;
			$author = $3;
			$date = $4;
			$longdescript = $5;
			#should be right, right?
			$longdescript =~ s#<p>.*##ig;
#			$longdescript =~ s#<p>\s*</ul>.*##ig;
			$longdescript2 = $longdescript;


			#get the header & footer files
			open (HEADER, "$head");
			@head = <HEADER>;
			foreach $line (@head) {
				$line =~ s/###meta statements go here###/<META NAME=\"title\" CONTENT=\"$descript\">\n\n<META NAME=\"description\" CONTENT=\"$longdescript\">\n/;
			}
			close(HEADER);

			open (FOOTER, "$foot");
			@foot = <FOOTER>;
			close(FOOTER);



			#write to the FTP index
			open (INDEX, ">>$FTPfile") || print ERRORS ("Cannot create $filename\n\n");
			select (INDEX);
			$~ = "INDEXFORMAT";
			write (INDEX);
			select (STDOUT);

			#put the textfile version in the FTP directory
			open (FROMFILE, $TEXTdir.$textfile.".txt") || print ERRORS ("\nCannot read/find textfile $textfile.  Relevant TOC is $filename.\n\n");
			open (TOFILE, ">$FTPdir".$FTPsub.$textfile.".txt") || print ERRORS ("\nCannot create $textfile.txt in FTP site. Relevant TOC is $filename\n");
			while ($line = <FROMFILE>) {
				print TOFILE $line;
			}
			close (FROMFILE);
			close (TOFILE);
			
			#create the searcher document
			print SEARCHDOC ("\n\nFrom <a \n",
				"href=\"http://forum.swarthmore.edu/dr.math/dr-math.html\">Ask Dr. \n",
				"Math</a>, a Forum special outreach project  <a \n",
				"href=\"$parentURL\">\($parentURLtitle\)</a> \n",
				"<li><a href=\"http://forum.swarthmore.edu$funcHTMLdir$textfile.html\">$descript</a> [$author, $date] \n",
				"<br>$longdescript2<br><P><P>\n\n");


			#make an HTML version of the textfile
			@html_lines = ();
			open (FROMFILE, $TEXTdir.$textfile.".txt");
			$linecount = 0;
			while ($line = <FROMFILE>) {
				chop($line);
				$line =~ s/</&lt;/g;
				$line =~ s/>/&gt;/g;
				if ($line =~ /\S/ && $linecount == 0) {
					$line = "";
					$linecount++;
				} elsif ($line =~ /\S/ && $linecount == 1) {
					$line = "<UL><H3>".$line."</H3>\n<pre>";
					$linecount++;
				} elsif ($line =~ /^\s*\~{10,1000}\s*$/) {
					$line = "</pre>\n</UL>\n\n<hr>\n\n<UL>\n<pre>\n";
					$linecount++;
				}
				unless ($line =~ s#&lt;(http|gopher|ftp)(:[^;]*.gif)&gt;#<img src="$1$2">#ig) {
					$line =~ s#&lt;(http|gopher|ftp|telnet|file)(:[^;]*)&gt;#<a href="$1$2">$1$2</a>#ig;
				}
				push (@html_lines, "$line"."\n");
			}

			push (@html_lines, "</pre>\n</UL>\n\n");
			close (FROMFILE);

			
			#make the upper navigation bar
			@navig_bar = ("<CENTER>\n",
				"<img src=\"../forum.blueline.gif\" ",
				"ALT=\"_____________________________________________\"><br>\n\n",
				"<a href=\"http://forum.swarthmore.edu"."$funcTOCdir"."$filename\">",
				"Back to $name</a> ||\n\n",
				"<a href=\"http://forum.swarthmore.edu/dr.math/dr-math.html\">All Levels</a><br>\n\n",
				"<img src=\"../forum.blueline.gif\" ",
				"ALT=\"_____________________________________________\"><br>\n\n",
				"</CENTER>"); 

			
			#write to the HTML file in the HTML directory
			@final_text = (@head, @navig_bar, @html_lines, @foot, @date);
			open (TO2FILE, ">$HTMLdir".$textfile.".html") || print ERRORS ("Cannot create the problem file $textfile.html: are the permissions correct?\n\n");
			print STDERR ("$textfile\n");
			while ($line = shift(@final_text)) {
				print TO2FILE ("$line");
			}
			print TO2FILE ("</BODY>\n</HTML>\n");
			close(TO2FILE);
		} else {
			print ERRORS ("Didn't find fields in $filename:\n $threadtext\n\n");
		}
	}
}

#run the diagnostic tests
#make a list of all the files currently in the problems directory
opendir (PROBLEMDIR, "$HTMLdir");
@new_problems = readdir (PROBLEMDIR);
closedir (PROBLEMDIR);

open (TESTLINKSFILE, ">$testlinksfile");
print TESTLINKSFILE ("<html><head><title>Testing the new Dr. Math Links</title><head>\n\n",
							"<body><h3>These are the new links that have been added since the last ",
							"time that Dr. Smock was run:</h3>");

#find out which ones are new
foreach $new_problem (@new_problems) {
	$is_it_new = "yes";
	$counter = 0;
	while ($counter <= @old_problems) {
		if ($new_problem eq $old_problems[$counter]) {
			$is_it_new = "no";
			last;
		}
		$counter++;
	}
	if ($is_it_new eq "yes") {
		print TESTLINKSFILE ("<a href=\"http://forum.swarthmore.edu",
				"$funcHTMLdir", "$new_problem\">$new_problem</a><br>\n");
	}
}
print TESTLINKSFILE ("\n\n</body></html>\n\n");


close (ERRORS);
close (TESTLINKSFILE);

print ("\nArchiving successful.\n\n",
		 "To see the list of errors, view the file $error_log_file.\n",
		 "To test the relevant links, use the URL \nhttp://forum.swarthmore.edu$func_testlinksfile\n");


sub makedirs {
	local ($path, $subpath) = @_;
	chop $path;
	@subdirs = split (/\//, $subpath);
	foreach $directory (@subdirs) {
		mkdir ($path."/".$directory, 0755);
		$path = $path."/".$directory;
	}
}


format INDEXFORMAT=
____________________________________________________________________________
@||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
$descript

Textfile: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$textfile.".txt"
Author: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$author
Date: @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$date

Description:
~~ ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$longdescript


.


