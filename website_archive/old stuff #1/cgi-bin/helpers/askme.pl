#!/usr/bin/perl

require "cgi_handlers.pl";


&get_request;
%input = %rqpairs;

&html_header("test");


#while (($key, $value) = each (%input)) {
#	if ($key eq "inquiry") {
#		$logbody .= "<PRE><B>".$key.":</B> ".$value."</PRE>\n";
#	} elsif ($key eq "to_address") {
#		$logbody .= "<PRE><B>".$key.":</B> ".$value."</PRE>\n";
#	} elsif ($key eq "from_address") {
#		$logbody .= "<PRE><B>".$key.":</B> ".$value."</PRE>\n";
#	} else {
#		$email_body .= $key.": $value\n\n";
#		$log_body   .= "<PRE><B>".$key.":</B> ".$value."</PRE>\n";
#	}
#}

#if ($to_address ne "") {
#	open (MAILPIPE, "| mail -s $inquiry $to_address");
#		print MAILPIPE ("$email_body");
#	close (MAILPIPE);
#
#	$return_mesg = "E-mail has been sent to $to_address.<P>";
#} else {
#	$return_mesg = "E-mail was not sent.  You must specify a recipient.";
#}

#($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime;

#$mname = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", 
#	"Oct", "Nov", "Dec")[$mon];
#$dname = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")[$wday];


#if ($logfile ne "") {
#	open (LOGFILE, ">>$logfile");
#	print LOGFILE ("<B><P>$mname $mday $year GMT</B><HR> ");
#	print LOGFILE ("$logbody");
#	close (LOGFILE);
#}

#$return_page .= $response."<HR>".$return_mesg."<HR>";

print ("$return_page");
&html_trailer;
	
