#!/usr/bin/perl

#This is Ken's attempt at a Perl script to replace the Applescript by Helen.

require "cgi_handlers.pl";
require "ctime.pl";

#get the field data
&get_request;
%input = %rqpairs;

$date = &get_date;

&html_header ("Form Results");

$return_msg = "";


while (($key, $value) = each (%input)) {
	if ($key eq "inquiry") {
		$email_subject = "$value\n";
		$log_body .= "<PRE><B>$key:</B> $value</PRE>\n";		
	} elsif ($key eq "to_address") {
		$to_address = $value;
		$log_body .= "<PRE><B>$key:</B> $value</PRE>\n";
	} elsif ($key eq "From") {
		$sender_name = $value;
		$log_body .= "<PRE><B>$key:</B> $value</PRE>\n";
	} elsif ($key eq "from_address") {
		$from_address = $value;
		unless ($from_address =~ /\S@\S/) {
			$return_msg .= "<center><h3>Sorry, E-mail has not been sent.</h3></center>\n";
			$return_msg .= "Your e-mail address is not in a recognizable format.".
				"It must look like \"username\@address\".  You must include your\n".
				"<strong>complete</strong> address, including everything after the \"@\"\n".
				"in order for us to get back to you.<p>\n";
			$send_mail = "no";
		}
		$log_body .= "<PRE><B>$key:</B> $value</PRE>\n";		
	} elsif ($key eq "response") {
		$response = $value;
	} elsif ($key eq "logfile") {
		$logfile = $value;
	} elsif ($key eq "S") {
		#ignore it.  That's the Submit button.
	} else {
		$email_body .= "$key:\n$value\n\n";
		$log_body .= "<PRE><B>$key:</B> $value</PRE>\n";
	}
}



unless ($to_address eq "" || $send_mail eq "no") {
	open (MAILING, "| /usr/lib/sendmail -f\"$from_address\" -F\"$sender_name\" \"$to_address\"");
	print MAILING ("To: $to_address\n",
						"Subject: $email_subject\n",
						"\n",
						"$email_body\n.\n");
	close (MAILING);
	$return_msg .= "E-mail has been sent to $to_address.<P>";
}


unless ($logfile eq "") {
	open (LOGFILE, ">>$logfile");
	print LOGFILE ("\n\n<B> $date </B>");
	print LOGFILE ("$log_body\n<hr>");
	close (LOGFILE);
	$return_msg .= "A log entry has been made.<P>";
}

if ($send_mail ne "no") {
	$return_page .= "$response\n<hr>\n$return_msg\n<hr>\n\n";
} else {
	$return_page .= "$return_msg\n<hr>\n\n";
}

print ("$return_page");

&html_trailer;


sub get_date {
	local ($sec,$min,$hr,$daymn,$mon,$yr,$daywk,$dayyr,$isdst) = localtime (time);
	$datenow = "$mon/$daymn/$yr at $hr:$min:$sec";
}	
