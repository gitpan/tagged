# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..15\n"; }
END {print "MP3::Tag not loaded :(\n" unless $loaded;}
use MP3::Tag;
$loaded = 1;
$count = 1;
ok(1,"MP3::Tag initialized");

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

#test - getting the tags
$mp3 = MP3::Tag->new("test.mp3");
$mp3->getTags;

$v1 = $mp3->{ID3v1};
ok($v1,"Detecting ID3v1");

$v2 = $mp3->{ID3v2};
ok($v2,"Detecting ID3v2");

#test - reading ID3v1
ok(($v1 && ($v1->song eq "Song") && ($v1->track == 10)),"Reading ID3v1");

#test - reading ID3v2
ok($v2 && $v2->getFrame("COMM")->{short} eq "Test!","Reading ID3v2");

$mp3 = MP3::Tag->new("test2.mp3");
$mp3->newTag("ID3v1");
$v1 = $mp3->{ID3v1};
$mp3->newTag("ID3v2");
$v2 = $mp3->{ID3v2};

#test - creating/changing/writing ID3v1
ok($v1 && join("",$v1->all("New","a","a",2000,"c",10,"Ska")), "Creating new ID3v1");
ok($v1 && $v1->writeTag,"Writing ID3v1");
ok($v1 && $v1->artist("Artist"), "Changing ID3v1");
ok($v1 && $v1->writeTag,"Writing ID3v1");

#test - creating/changing/writing ID3v2
ok($v2 && $v2->add_frame("TLAN","ENG"),"Creating new ID3v2");
ok($v2 && $v2->write_tag,"Writing ID3v2");
ok($v2 && $v2->add_frame("TLAN","GER"),"Changing ID3v2");
ok($v2 && $v2->write_tag,"Writing ID3v2");

$mp3 = MP3::Tag->new("test2.mp3");
$mp3->getTags;
$v1 = $mp3->{ID3v1};
$v2 = $mp3->{ID3v2};

#test 10 - reading new ID3v1
ok($v1 && $v1->song eq "New" && $v1->artist eq "Artist","Checking new ID3v1");

#test 11 - reading new ID3v2
ok($v2 && $v2->getFrame("TLAN") eq "ENG" && $v2->getFrame("TLAN01") eq "GER","Checking new ID3v2");

#back to original tag
open (FH, ">test2.mp3");
print FH "empty";
close FH;

sub ok {
  my ($result, $test) = @_;
  printf ("Test %2d %s %s", $count++, $test, '.' x (28-length($test)));
  print " not" unless $result;
  print " ok\n";
}
