#!/usr/bin/perl

require "dr.cgi_handlers.pl";
require "office_tools.pl";

&html_header("Doctor's Office Fun Links!");

$body = "<center><img src=\"/~ken/dr.office/fun.link.top.gif\"></center>

<h3>This week's Fun Link:</h3><br>
<a href=\"http://www.harold.com\">Harold's Page of impressive CGI</a><br>

<hr>
Here are all the Fun Links we've ever had:<br><br>

blah blah blah........";


print $body;
&make_std_buttons;
&html_trailer("$ENV{'REMOTE_USER'}");
