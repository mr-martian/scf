#!/usr/local/bin/perl
require "dr.cgi_handlers.pl";
require "office_tools.pl";


&get_request;
%input = %rqpairs;

#put the default values here, for when the page is loaded 
#straight and not from a form.
if ($input{'doctor_name'} eq "") {
	$input{'doctor_name'} = $ENV{'REMOTE_USER'};
}

&html_header("Doctor's Office Post-Op Area");



if ($input{'do_what'} eq "clear_post_op") {
	open (RCFILE, ">$input{'doctor_name'}.rcfile") ||
		die ("cannot open $input{'doctor_name'}rcfile");
	close (RCFILE);

} elsif ($input{'do_what'} eq "reconstruct") {
	open (OLDRCFILE, "$input{'doctor_name'}.rcfile") || 
		print ("Can't find your rcfile<br>\n");
	@old_threads = <OLDRCFILE>;
	chop (@old_threads);
	close (OLDRCFILE);

	#get rid of threads that aren't in the problem directory anymore
	for ($counter = 0; $counter < @old_threads; $counter++) {
		if (-e "/usr/users/ken/public_html/office.problems/$old_threads[$counter]") {
			#do nothing
		} else {
			#remove the list item
			splice (@old_threads, $counter, 1);
			$counter--;
		}
	}

	#print the remaining old threads to the rcfile
	open (NEWRCFILE, ">$input{'doctor_name'}.rcfile");
	foreach $oldthread (@old_threads) {
		print NEWRCFILE ("$oldthread\n");
	}

	#print the new threads to the rcfile
	while (($key, $value) = each(%input)) {
		if ($value eq "no") {
			print NEWRCFILE ("$key\n");
		}
	}
	close (NEWRCFILE);
}

#now make the post-op page:


print ("<center>\n<img src=\"/~ken/dr.office/post-op.top.gif\"><br>\n",
		 "<H3>The \"Done\" Questions</H3>\n</center>\n\n",
		 "When these question were answered, the Doctor who answered them assigned ",
		 "them \"done\" status.  This means that the Doctor feels that no more ",
		 "needs to be done on the question, and the question no longer shows up ",
		 "in the Triage Area.<br><br>\n\n",
		 "Please look over the questions, and when you're convinced that the ",
		 "question was answered satisfactorily, check the box next to it and ",
		 "throw it away.  When you throw something away, it does not affect ",
		 "the other Doctors' lists.<br><br>\n\n",
		 "If you have something to add to a question, you can click on the ",
		 "question and answer it.  If you see an Error (ooh) in the question, ",
		 "the nice thing to do is click on the Doctor's name and tell them ",
		 "what you think is wrong.<br><br>\n\n",
		 "Enjoy!<br><br>\n\n");

&read_rcfile($input{'doctor_name'});
	
dbmopen (doctspecs, "dbm.files/doctor_specs", 0664);
&get_problem_list;
dbmclose (doctspecs);
	
&make_std_buttons;



print ("<center><a href=\"move_threads.pl\"><h3>Correct the Threading of the Problems</h3></a></center>\n");
&make_search_field ($input{'doctor_name'});


&html_trailer($input{'doctor_name'});

#------------------------begin---subroutines-----------------------------

sub read_rcfile {
	local ($doct_name) = @_;
	if (-e "$doct_name.rcfile") {
		#if it exists, read it
		open (RCFILE, "$doct_name.rcfile")  || print "can't open rcfile";
		@thrown_problems = <RCFILE>;
		chop (@thrown_problems);
		close (RCFILE);
	} else {
		#if it does not exist, make a blank one
		open (RCFILE, ">$doct_name.rcfile");
		close (RCFILE);
	}
}


sub get_problem_list {
	opendir (PROBDIR, "../../office.problems") || die ("can't open the problems directory\n");
	$counter=0; 
	dbmopen (problems, "/usr/users/ken/public_html/cgi-bin/dr.office/problems", 0666);
	while ($filename = readdir(PROBDIR)) {
		if (&is_in_rcfile($filename)) {
			next;
		}
		$filename =~ /^\D+(\d+)/;
		if ($problems{$1,"done_flag"} eq "yes") {
			$files[$counter] = $filename;
			$counter++;
		}
	}
	dbmclose(problems);

	@sorted = sort(@files);
	
	print "<form action=\"post-op.pl\" ",
		"method=post><p><ul>\n";
	foreach $file (@sorted) {
		if ($file =~ /^\D+\d+$/) {
			&make_link($file, "cbox");
		}
		if ($file =~ /^\D+\d+_/) {
			&make_link($file, "indent");
		}
	}
	print ("<br><center><input type=\"submit\" value=\"Throw away checked items\">\n",
			 "<input type=\"hidden\" name=\"doctor_name\" value=\"$input{'doctor_name'}\">\n",
			 "<input type=\"hidden\" name=\"do_what\" value=\"reconstruct\">\n",
			 "<input type=\"reset\" value=\"Reset checkboxes\">\n",
			 "</form>\n\n");

	print ("<form action=\"post-op.pl\" method=post> \n",
			 "<input type=\"hidden\" name=\"doctor_name\" value=\"$input{'doctor_name'}\">\n",
			 "<input type=\"hidden\" name=\"do_what\" value=\"clear_post_op\">\n",
			 "<input type=\"submit\" value=\"Restore full list\">\n</center></ul>\n",
			 "</form>\n\n");
}


sub is_in_rcfile {
	local ($filenom) = @_;
	$return_val = 0;
	foreach $thrown_problem (@thrown_problems) {
		if ($filenom =~ /$thrown_problem/) {
			$return_val = 1;
		}
	}
	$return_val;
}
