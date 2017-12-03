#!/usr/local/bin/perl
require "cgi_handlers.pl";

&get_request;
%input = %rqpairs;
&html_header("testing");
print ("<H1>Here's what you sent:</H1>");
while (($key,$value) = each (%input)) {
	print ("<B>",$key,":  </B>",$value,"<p>");
        }
print ("<HR>Your forms data has been successfully processed.");
&html_trailer;
