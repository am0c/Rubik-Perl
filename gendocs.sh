# should have used some module fro stripping out the filename ... but didn't have time for that ..
rm -rf ./html;

mkdir html ;

find -name *.pm | perl -ne 'chomp $_;   $new = $_; $new =~ s/\.pm/.html/;  $new =~ s/^.*\///; $new="html/$new"; `perl ./pod2html.pl $_ > $new`;   print "$new\n"'

cp -r images/ html/
