#!/usr/bin/perl

#this is the page that lets people change things like their password, their
#e-mail address, their real name, stuff like that.

require "dr.cgi_handlers.pl";
require "office_tools.pl";

&html_header("Doctor's Office Administrative Wing");

dbmopen (doctspecs, "dbm.files/doctor_specs", 0664);



print ("<center><h3>The Administrative Wing</h3><hr>\n",
		 "This is the form that you can use to change your personal \n",
		 "information.</center>\n\n");

print ("<center><b>Attributes for Doctor \u$ENV{'REMOTE_USER'}</b>:</center>",
		 "<form action=\"change_info.pl\" method=\"post\">\n",
		 "I'm changing my name<input type=\"checkbox\" name=\"name_change\" value=\"yes\"><br>\n",
		 " <pre>              Your real name:<input type=\"text\" size=50 name=\"real_name\" value=\"$doctspecs{$ENV{'REMOTE_USER'},'name'}\"></pre>\n",
		 "I'm changing my address<input type=\"checkbox\" name=\"adds_change\" value=\"yes\"><br>\n",
		 " <pre>         Your e-mail address:<input type=\"text\" size=50 name=\"email_address\"value=\"$doctspecs{$ENV{'REMOTE_USER'},'address'}\"></pre>\n",
		 "I'm changing my password<input type=\"checkbox\" name=\"pass_change\" value=\"yes\"><br>\n",
		 " <pre>           Your new password:<input type=\"password\" name=\"password\" size=50></pre>\n",
		 " <pre>   Your new password retyped:<input type=\"password\" name=\"confirmed_password\" size=50></pre>\n",
		 "<center><input type=\"submit\" name=\"S\" value =\"Submit Changes\">\n",
		 "<input type=\"hidden\" name=\"doctor_name\" value=\"$ENV{'REMOTE_USER'}\">\n",
		 "</form><hr>\n\n");

print ("<a href=\"list_doct.pl\"><h3>View other doctors' names, addresses, and usernames</h3></a></center><br>");

print ("<a href=\"make_archives.pl\"><center>Create the archive documents</a> ",
		 "if you are a member of the archiving staff.</center><br>");


dbmclose (doctspecs);

&make_std_buttons;
&html_trailer("$ENV{'REMOTE_USER'}");
