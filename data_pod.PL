#!/usr/bin/perl -w

use MP3::Tag::ID3v2;

$filename=shift || "./Tag/ID3v2-Data.pod";

open(POD, ">$filename");
$std = select(POD);

print <<"INTRO";

=head1 NAME 

MP3::Tag::ID3v2-Data - GetFrame() Data Format

=head1 DESCRIPTION 

This document describes how to use the results of the GetFrame function of 
MP3::Tag::ID3v2, thus the data format of frames retrieved with 
MP3::Tag::ID3v2::GetFrame().

=head2 Calling GetFrame()

You have to call GetFrame() like this: 

(\$info, \$long) = GetFrame(\$id);    # or

(\$info, \$long) = GetFrame(\$id, 'raw');

\$id has to be a name of a frame like "APIC". The names of all frames found
in a tag can be retrieved with the L<GetFrameIDs()|MP3::Tag::ID3v2> function.

=head2 Using the returned data

In the ID3v2.3 specifications $#frames frames are defined, which can contain very
different information. That means also that GetFrame returns the information
found in a frame in different ways.

=over 4

=item Simple Frames

A lot of the tags contain only a text string and encoding information. If
you call (\$info, \$long) = GetFrame(\$id) for such a frame, \$info will contain
the text string and \$long will contain the english name of the frame.
 
Example:
  getFrame("TIT2");     # returns

  ("Birdhouse In Your Soul", "Title/songname/content description")

=item Complex Frames

For more complex frames the returned \$info is a reference to a hash, where
each entry of the hash decribes a part of the information found in the
frame. The key of a hash entry contains the name of this part, the according
value contains the information itself.
 
Example:
  getFrame("APIC");     # returns
  
  ( { "Description" => "Flood", 
      "MIME Type" => "/image/jpeg", 
      "Picture Type" => "Cover (front)",
      "_Data" => "..data of jpeg picture (binary).."
     },
   "Attached Picture");

=item Other Frames

Some frames are not supported at the moment, ie the data found in the frame
is not returned in a descriptive way. But you can read the data of this
frames (and also of all other frames too) in raw mode. Then the complete
data field of the frame is returned, without any modifications. This means
that the returned data will be almost binary data.

Example:
  getFrame("TIT2", 'raw');    # returns

  ("\\x00Birdhouse In Your Soul", "Title/songname/content description")

=back
  
INTRO

@frames = keys %MP3::Tag::ID3v2::long_names;
@other = ();
@text = ();
@complex = ();

foreach (@frames) {
  $data = MP3::Tag::ID3v2::what_data("", $_);
  if (ref $data) {
    if ($#$data == 0) {
      push @text, $_;
    } else {
      push @complex, $_;
    }
  } else {
    push @other, $_;
  }
}

print "\n\n=head2 List of Simple Frames\n\nFollowing Frames are supported 
and return a single string (text). In the List you can find the frame IDs 
and the long names of the frames as returned by GetFrame():\n\n=over 4\n\n";
foreach (sort @text) {
  $long = $MP3::Tag::ID3v2::long_names{$_};
  print "\n=item $_ : $long\n";
}
print "\n=back\n\n";

print "\n\n=head2 List of Complex Frames\n\n";
print "Following frames are supported and return a reference to a hash. The
list shows which keys can be found in the returned hash:\n";
print "\n=over 4\n\n";
foreach (sort @complex) {
  $long = $MP3::Tag::ID3v2::long_names{$_};
  print "\n=item $_ : $long\n\n";
  $data = MP3::Tag::ID3v2::what_data("", $_);
  print "  Keys: ", join(", ",@$data), "\n";
}
print "\n=back\n\n";

print "\n\n=head2 List of Other Frames\n\n";
print "Following frames are only supported in raw mode:\n";
print "\n=over 4\n\n";
foreach (sort @other) {
  $long = $MP3::Tag::ID3v2::long_names{$_};
  print "\n=item $_ : $long\n";
}
print "\n=back\n\n";

print <<END;

=head1 SEE ALSO

L<MP3::Tag>, L<MP3::Tag::ID3v2>

END

select($std);
close POD;