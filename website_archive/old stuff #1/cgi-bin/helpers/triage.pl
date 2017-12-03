#!/usr/bin/perl
require "dr.cgi_handlers.pl";
require "office_tools.pl";



&html_header("Doctor's Office Triage Area");


print ("<center>\n<img src=\"/~ken/dr.office/doctor.gif\">",
	"<img src=\"/~ken/dr.office/triage.top.gif\"><br>\n",
	"<H3>Welcome to the Doctor's Office, Doctor \u$ENV{'REMOTE_USER'}!</H3>\n</center>\n\n",
	"Here is the list of all the questions that need to be dealt with. \n",
	"It does not include questions marked \"done.\"<br>\n");
	"Eventually, there will be password verification controlling",
	"access to this page.<br><br>\n\n",
	"Click on a question to view or answer it.<br><br>";


#make the list of questions and answers
dbmopen (doctspecs, "dbm.files/doctor_specs", 0664);
&get_problem_list;
dbmclose (doctspecs);


&make_std_buttons;

print ("<center><a href=\"triage.pl?view_mode=show_handles\"><h3>Display File Handles</h3></a></center>\n");
print ("<center><a href=\"move_threads.pl\"><h3>Correct the Threading of the Problems</h3></center></a>\n");
&make_search_field ($ENV{'REMOTE_USER'});


&html_trailer($ENV{'REMOTE_USER'});



sub get_problem_list {
	opendir (PROBDIR, "../../office.problems") || die ("can't open the problems directory\n");
	$counter=0; 
	dbmopen (problems, "/usr/users/ken/public_html/cgi-bin/dr.office/problems", 0666);
	while ($filename = readdir(PROBDIR)) {
		$filename =~ /^\D+(\d+)/;
		if ($problems{$1,"done_flag"} eq "no") {
			$files[$counter] = $filename;
			$counter++;
		}
	}
	dbmclose (problems);

	@sorted = sort(@files);
	print "<ul>";
	foreach $file (@sorted) {
		if ($file =~ /^\D+\d+$/) {
			&make_link($file, "std");
		}
		if ($file =~ /^\D+\d+_/) {
			&make_link($file, "indent");
		}
	}
	print "</ul>";
}
					 


