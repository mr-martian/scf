#!/usr/local/bin/perl

open (FILE, flash) || print("nothin there");

@list = <FILE>;

#chop @list;
$flash = join("",@list);

@group = split (/~~/, $flash);

	print("

		<title>Flash</title>
		<body bgcolor=\"#111899\" text=\"#eeeeee\">
		<center>
		<h1><font size=9>The Flash</font></h1>
		</center>
		<table border=2 cellspacing=4 cellpadding=4>
		<tr>
		<td>
		<center>
		<h2><font size=7>And Now Here's the News</font></h2>
		</center>
		</td>
		</tr>
		");

for($counter=1;$counter<@group;$counter++){
	
	
	print("<tr><td>\n");
	print("<pre>");
	print("$group[$counter]\n");
	print("</pre>\n</td>\n</tr>\n");
	
}

print("</table>\n\n");
