#!/usr/bin/perl -w
use Tk;
use Tk::JPEG;
use Tk::DialogBox;
use Tk::BrowseEntry;
use POSIX;
use strict;
use MP3::Tag;

use vars qw/$tktag $VERSION %element %var/;

$VERSION="0.01";

$var{dir}= shift || "/mp3/unsorted";

$tktag = MainWindow->new(); #main window
create_window();

MainLoop;

exit 0;

####################################

###### tk subs

sub create_window {
  $element{leftFrame}  = $tktag->Frame();
  $element{rightFrame} = $tktag->Frame();

  # create menu
  $element{menu} = create_menu($tktag);

  # special fonts
  $tktag->fontCreate('C_big', -family => 'courier', -weight => 'bold', -size => 18);

  # create Filelist
  $element{filelist} = $element{leftFrame}->Scrolled("Listbox", -width=>20, 
						     -selectmode=>"browse", 
						     -scrollbars=>"osre",
						     -takefocus=>1,);
  $element{filelist}->bind("<Double-1>" => \&select);
  $element{filelist}->bind("<Key-Return>" => \&select);

  # create filename-area
  my $fn1area = $element{rightFrame}->Frame();
  my $fn2area = $element{rightFrame}->Frame();
  my ($l);
  $element{filenamelabel} = $fn1area->Label(-text=>"Filename:")->pack(-side=>"left", anchor=>"w");
  $fn1area->Entry(-textvariable=>\$var{filename}, -validate=>"key",
		 -vcmd=>val_sh($element{filenamelabel}))
    ->pack(-side=>"left", -fill=>"x", -expand=>"yes", -anchor=>"w");
  $fn1area->Button(-text=>"Save changes", -command=>\&save)->pack(-side=>"left", -anchor=>"w");
  $element{setfilename} = $fn2area->Menubutton(qw/-underline 0 -relief raised/,
					       -text => "Set Filename  --", -direction => "below");
  $element{setfilename}->configure(-menu => $element{setfilename}->menu);
  $element{setfilename}->command(-label => "from ID3v1 Tag");
  $element{setfilename}->command(-label => "from ID3v2 Tag");
  $element{setfilename}->pack(-side=>"left", anchor=>"n", -padx=>15);

  $element{setid3v1} = $fn2area->Menubutton(qw/-underline 0 -relief raised/,
					       -text => "Set ID3v1  --", -direction => "below");
  $element{setid3v1}->configure(-menu => $element{setid3v1}->menu);
  $element{setid3v1}->command(-label => "from Filename");
  $element{setid3v1}->command(-label => "from ID3v2 Tag");
  $element{setid3v1}->pack(-side=>"left", anchor=>"n", -padx=>15);

  $element{setid3v2} = $fn2area->Menubutton(qw/-underline 0 -relief raised/,
					       -text => "Set ID3v2  --", -direction => "below");
  $element{setid3v2}->configure(-menu => $element{setid3v2}->menu);
  $element{setid3v2}->command(-label => "from Filename");
  $element{setid3v2}->command(-label => "from ID3v1 Tag");
  $element{setid3v2}->pack(-side=>"left", anchor=>"n", -padx=>15);

  $element{removebutton} = $fn2area->Menubutton(qw/-underline 0 -relief raised/,
					       -text => "Remove  --", -direction => "below");
  $element{removebutton}->configure(-menu => $element{removebutton}->menu);
  $element{removebutton}->command(-label => "File");
  $element{removebutton}->command(-label => "ID3v1 Tag");
  $element{removebutton}->command(-label => "ID3v2 Tag");
  $element{removebutton}->pack(-side=>"left", anchor=>"n", -padx=>15);

  # create ID3v1 area
  my $v1area = $element{rightFrame}->Frame();
  my $v1caption = $v1area->Frame(-background=>"red");
  my $v1labels = $v1area->Frame();
  my $v1entries = $v1area->Frame();
  my $v2apic = $v1area->Frame();
  $element{v1caption}=$v1caption->Label(-text=>"ID3v1.1", -font=>"C_big", 
					-background=>"red", -relief=>"ridge")
    ->pack(-side=>"top", -anchor=>"c", -expand=>"yes", -fill=>"x");
  $l = $v1labels->Label(-text=>"Song:")->pack(-side=>"top", -anchor=>"e");
  $v1entries->Entry(-textvariable=>\$var{v1song}, -width=>30, 
		    -validate=>"key", -vcmd=>val_text($l,30))
    ->pack(-side=>"top", -anchor=>"w");
  $l = $v1labels->Label(-text=>"Artist:")->pack(-side=>"top", -anchor=>"e", -pady=>2);  
  $v1entries->Entry(-textvariable=>\$var{v1artist}, -width=>30,
		    -validate=>"key", -vcmd=>val_text($l,30))
    ->pack(-side=>"top", -anchor=>"w");
  $l = $v1labels->Label(-text=>"Album:")->pack(-side=>"top", -anchor=>"e");
  $v1entries->Entry(-textvariable=>\$var{v1album}, -width=>30,
		    -validate=>"key", -vcmd=>val_text($l,30))
    ->pack(-side=>"top", -anchor=>"w");
  $l = $v1labels->Label(-text=>"Comment:")->pack(-side=>"top", -anchor=>"e", -pady=>1);
  $v1entries->Entry(-textvariable=>\$var{v1comment}, -width=>30,
		    -validate=>"key", -vcmd=>val_text($l,28))
    ->pack(-side=>"top", -anchor=>"w");
  $element{genrelabel} = $v1labels->Label(-text=>"Genre:")->pack(-side=>"top", -anchor=>"e");
  my $genres = ["", sort @{MP3::Tag::genres()}];
  $v1entries->BrowseEntry(-variable => \$var{v1genre}, -choices => $genres, 
			  -state=>"readonly", -browsecmd=> 
			  sub { $element{genrelabel}->configure(-background=>"yellow");
				$element{v1caption}->configure(-background=>"yellow");
				push @{$var{labels}}, $element{genrelabel} })
    ->pack(-side=>"top", -anchor=>"w");
  $l = $v1labels->Label(-text=>"Year:")->pack(-side=>"top", -anchor=>"e");
  $v1entries->Entry(-textvariable=>\$var{v1year}, -width=>4,
		    -validate=>"key", -vcmd=>val_num($l,4))
    ->pack(-side=>"top", -anchor=>"w");
  $l = $v1labels->Label(-text=>"Track:")->pack(-side=>"top", -anchor=>"e", -pady=>2);
  $v1entries->Entry(-textvariable=>\$var{v1track}, -width=>4,
		    -validate=>"key", -vcmd=>val_num($l,3))
    ->pack(-side=>"top", -anchor=>"w");
  $element{apic} = $v2apic->Photo('apic');
  $element{apic}->blank;
  $v2apic->Label(-image=>'apic', -height=>150, -width=>180)->pack(-side=>"top", -anchor=>"center");
  $element{apictext}=$v2apic->Label(-text=>"")->pack(-side=>"top", -anchor=>"center");
  $v1caption->pack(-side=>"top", -expand=>"yes", -fill=>"x");
  $v1labels->pack(-side=>"left");
  $v1entries->pack(-side=>"left");
  $v2apic->pack(-side=>"right");

  # ID3v2 area
  my $v2area = $element{rightFrame}->Frame();
  my $v2caption = $v2area->Frame();
  my $v2top = $v2area->Frame();
  my $v2right = $v2area->Frame();
  my $v2buttons = $v2top->Frame();
  my $v2labent = $v2top->Frame();
  my $v2labels = $v2labent->Frame();
  my $v2entries = $v2labent->Frame();
  my $v2parea = $v2right->Frame();
  my $v2iarea = $v2right->Frame();
  $element{v2caption}=$v2caption->Label(-text=>"ID3v2.3", -font=>"C_big", -background=>"red", -relief=>"ridge")
    ->pack(-side=>"top", -anchor=>"c", -fill=>"x", -expand=>"yes");
  $l = $v2labels->Label(-text=>"Song:")->pack(-side=>"top", -anchor=>"e");
  $v2entries->Entry(-textvariable=>\$var{v2song}, -width=>40, -validate=>"key",
		    -vcmd=>val_sh($element{v2caption},$l))->pack(-side=>"top", -anchor=>"w");
  $l = $v2labels->Label(-text=>"Artist:")->pack(-side=>"top", -anchor=>"e", -pady=>1);  
  $v2entries->Entry(-textvariable=>\$var{v2artist}, -width=>40, -validate=>"key",
		    -vcmd=>val_sh($element{v2caption},$l))->pack(-side=>"top", -anchor=>"w");
  $l = $v2labels->Label(-text=>"Album:")->pack(-side=>"top", -anchor=>"e");
  $v2entries->Entry(-textvariable=>\$var{v2album}, -width=>40, -validate=>"key",
		    -vcmd=>val_sh($element{v2caption},$l))->pack(-side=>"top", -anchor=>"w");
  $v2buttons->Button(-text=>"Add Frame")->pack(-side=>"left", -anchor=>"c");
  $v2buttons->Button(-text=>"Delete Frame(s)")->pack(-side=>"left", -anchor=>"c");
  $element{frames} = $v2iarea->Optionmenu(-options => ["No frames"], -command=>\&show_frame)
    ->pack(-side=>"left");
  $v2iarea->Label(-textvariable=>\$var{longname})->pack(-side=>"left");
  $element{frameinfo} = $v2parea;
  $v2labels->pack(-side=>"left");
  $v2entries->pack(-side=>"left");
  $v2labent->pack(-side=>"left", -anchor=>"nw");
  $v2buttons->pack(-side=>"left", -fill=>"y", -expand=>"yes");
  $v2iarea->pack(-side=>"top", -fill=>"x", -expand=>"yes", -anchor=>"nw");
  $v2parea->pack(-side=>"top", -fill=>"both", -expand=>"yes", -anchor=>"nw");
  $v2caption->pack(-side=>"top", -expand=>"yes", -fill=>"x");
  $v2top->pack(-side=>"top", -fill=>"x", -expand=>"yes", -anchor=>"n");
  $v2right->pack(-side=>"left", -fill=>"both", -expand=>"yes", -anchor=>"n");

  # pack left Frame
  $element{filelist}->pack(-side=>"top", -fill=>"y", -expand=>"yes");

  # pack right Frame
  $fn1area->pack(-side=>"top", -anchor=>"nw", -expand=>"yes", -fill=>"x");
  $fn2area->pack(-side=>"top", -anchor=>"nw", -expand=>"yes", -fill=>"x");
  $v1area->pack(-side=>"top", -anchor=>"nw", -expand=>"yes", -fill=>"x", -pady=>10);
  $v2area->pack(-side=>"top", -anchor=>"nw", -expand=>"yes", -fill=>"x");
  $v2parea->pack(-side=>"top", -anchor=>"nw", -expand=>"yes", -fill=>"x");

  # pack main window
  $element{menu}->pack(-side=>"top", -fill=>"x", anchor=>"nw");
  $element{leftFrame}->pack(-side=>"left", -fill=>"y", anchor=>"w");
  $element{rightFrame}->pack(-side=>"left",-fill=>"both",-expand=>"yes", anchor=>"nw");

  #prepare open dialog window
  $element{open} = $tktag->DialogBox(-title=>"Open directory", -buttons=>["Open", "Cancel"]);
  $element{open}->add("Label", -text=>"Directory:")->pack();
  $element{open}->add("Entry", -width=>35, -textvariable=>\$var{dir})->pack();
}

sub val_sh {
  my ($label1, $label2, $change) = @_;
  return 
    sub {
      if ($_[4] == -1) {
	$change=0;
	return 1;
      }
      return 1 if $change++;
      $label1->configure(-background=>"yellow");
      if (defined $label2) {
	$label2->configure(-background=>"yellow");
	push @{$var{labels}}, $label2;
      }
      return 1;
    }
}

sub val_text {
  my ($label, $length, $change) = @_;
  return 
    sub {
      my ($pro, undef, undef, undef, $type) = @_; 
      return 0 if $type == 1 && length($pro) > $length;
      if ($type == -1) {
	$change=0;
	return 1;
      }
      return 1 if $change++;
      $label->configure(-background=>"yellow");
      $element{v1caption}->configure(-background=>"yellow");
      push @{$var{labels}}, $label;
      return 1;
    }
}

sub val_num {
  my ($label, $length, $change) = @_;
  return 
    sub {
      my ($pro, undef, undef, undef, $type) = @_; 
      return 0 if $type == 1 && !($pro =~ /^\d{0,$length}$/o);
      if ($type == -1) {
	$change=0;
	return 1;
      }
      return 1 if $change++;
      $label->configure(-background=>"yellow");
      $element{v1caption}->configure(-background=>"yellow");
      push @{$var{labels}}, $label;
      return 1;
    }
}

sub create_menu {
  my $menu = shift->Menu(-type=>"menubar");

  my $file=$menu->cascade(-label=>"File");
  $file->command(-label=>"Open", -command=>\&load_filelist);
  $file->separator();
  $file->command(-label=>"Exit", -command=>sub {exit 0;});

  return $menu;
}

sub tk_question {
  my $text = shift;
  my $ans = $tktag->messageBox(-text=>$text, -title=>"Question", -type=>"YesNo",
			       -default=>"No", -icon=>"question" );
  return $ans eq "Yes" ? 1 : 0;
}

sub tk_warning {
  my $text = shift;
  $tktag->messageBox(-text=>$text, -title=>"Warning", -buttons=>"Ok",
		     -icon=>"warning" );
}

####### file subs

sub load_filelist {
  $element{filelist}->delete("0","end");
  my $answer = $element{open}->Show;
  if ($answer eq "Open") {
    $var{dir} =~ s!/$!!;
    $var{dir} .= "/";
    opendir(DIR, $var{dir}) or die "Can't read directory";
    my (@files, $file);
    while (defined($file = readdir(DIR))) {
      push @files, $file unless $file =~ /^\.\.?$/; 
    }
    closedir DIR;
    $element{filelist}->insert("end", sort @files);
  }
}

sub select {
  $var{filename}=$element{filelist}->get("active","active");
  $var{oldfilename} = $var{filename};
  my $filename = $var{dir}.$var{filename};
  $var{mp3}=MP3::Tag->new($filename);
  $var{mp3}->getTags;
  # remove old things
  foreach (@{$var{fpack}}) {
    $_->packForget();
  }
  $var{fpack} = [];
  $var{longname}="";
  if (exists $var{labels}) {
    while (my $label = shift @{$var{labels}}) {
      $label->configure(-background=>"#d9d9d9");
    }
  }
  if (exists $var{mp3}->{ID3v1}) {
    $element{v1caption}->configure(-background=>"green");
    $var{v1}=$var{mp3}->{ID3v1};
    ($var{v1song},$var{v1artist},$var{v1album},$var{v1year},$var{v1comment},$var{v1track},$var{v1genre})
      = $var{v1}->all();
  } else {
    ($var{v1song},$var{v1artist},$var{v1album},$var{v1year},$var{v1comment},$var{v1track},$var{v1genre})
      = ("","","","","","","");
    $element{v1caption}->configure(-background=>"red");
  }
  if (exists $var{mp3}->{ID3v2}) {
    $element{v2caption}->configure(-background=>"green");
    $var{v2}=$var{mp3}->{ID3v2};
    my $frames = $var{v2}->getFrameIDs;
    $var{v2song} = $var{v2}->getFrame("TIT2");
    $var{v2artist} = $var{v2}->getFrame("TPE1");
    $var{v2album} = $var{v2}->getFrame("TALB");
    if (exists $frames->{"APIC"}) {
      show_picture("APIC");
    } else {
      $element{apic}->blank;
      $element{apictext}->configure(-text=>"");
    }
    my @frames = sort keys %$frames;
    $element{frames}->configure(-options => \@frames);
    show_frame($frames[0]);
  } else {
    ($var{v2song},$var{v2artist},$var{v2album})
      = ("","","");
    $element{v2caption}->configure(-background=>"red");
    $element{frames}->configure(-options => ["No Frames"]);
    $element{apic}->blank;
    $element{apictext}->configure(-text=>"");
  }
}

sub show_frame {
  my $fname = shift;
  return if length($fname) != 4;
  foreach (@{$var{fpack}}) {
    $_->packForget();
  }
  $var{fpack} = [];
  my $info;
  ($info, $var{longname}) = $var{v2}->getFrame($fname);
  if (ref $info) {
    my @frames = sort keys %$info;
    my ($key, $value);
    foreach $key (@frames) {
      $value = $info->{$key};
      my $f = $element{frameinfo}->Frame();
      push @{$var{fpack}}, $f;
      if ($key =~ s/^_//) {
	$f->Label(-text=>"$key:", -justify=>"left")->pack(-side=>"left", -anchor=>"w");
	my $b=$f->Menubutton(qw/-underline 0 -relief raised/,
		       -text => "Data of " .length($value) ." Bytes  --", -direction => "below");
	$b->configure(-menu => $b->menu);
	$b->command(-label => "Save Data");
	$b->command(-label => "Load Data");
	$b->command(-label => "View Data");
	$b->pack(-side=>"left", anchor=>"n");
      } else {
	$f->Label(-text=>"$key:", -justify=>"left")->pack(-side=>"left", -anchor=>"w");
	$var{"frame_$key"} = $f->Text(-height=>2, -width=>40, -wrap=>"word")
	  ->pack(-side=>"right", -anchor=>"e");
	$var{"frame_$key"}->insert("0.0", $value);
      }
      $f->pack(-side=>"top", -anchor=>"w", -fill=>"x", -expand=>"yes");
    }
  } else {
    $var{frame_text} = $element{frameinfo}->Text(-height=>2, -width=>40, -wrap=>"word")
      ->pack(-side=>"top", -anchor=>"n");
    $var{frame_text}->insert("0.0", $info);
    push @{$var{fpack}}, $var{frame_text}; 
  }
}

sub show_picture {
  my $fname = shift;
  my $frame = $var{v2}->getFrame($fname);
  if ($frame->{"MIME type"} =~ /image\/(gif|jpe?g|bmp)/i) { 
    my $type = lc $1;
    $type =~ s/jpg/jpeg/;
    open(TMP, ">/tmp/_tk_temp.jpg");
    binmode TMP;
    print TMP $frame->{_Data};
    close TMP;
    $element{apic}->configure(-format=>$1, -file=>"/tmp/_tk_temp.jpg");
    my $text .= $frame->{"Picture Type"};
    $text = $frame->{Description} if $text eq "Other";
    $text = "ID3v2.3-" . uc($fname) . ": ". $text; 
    $element{apictext}->configure(-text=>$text);
    unlink "/tmp/_tk_temp.jpg";
  }
}

sub save {
  if ($var{filename} ne $var{oldfilename}) {
    if ($var{filename} eq "") {
      if (tk_question("Filename is empty. Do you want to delete $var{oldfilename}?")) {
	if (unlink $var{dir}.$var{oldfilename}) {
	  remove_id3v1();
	  remove_id3v2();
	  $element{filenamelabel}->configure(-background=>"#d9d9d9");
	  $element{v1caption}->configure(-background=>"red");
	  $element{v2caption}->configure(-background=>"red");
	  $element{filelist}->delete("active","active");
	  goto out;
	}
	tk_warning("Cannot delete file.");
      }
      goto bye;
    } elsif (-e $var{dir}.$var{filename}) {
      if (-f _) {
	if (tk_question("Files $var{filename} exists. Do you want to overwrite it?")) {
	  goto re;
	}
      } else {
	tk_warning("$var{filename} exists and it isn't a plain file. Can't rename $var{oldfilename}!");
	goto bye;
      }
    } else {
    re:
      rename $var{dir}.$var{oldfilename}, $var{dir}.$var{filename};
      $var{oldfilename} = $var{filename};
      my $index = $element{filelist}->index("active");
      $element{filelist}->insert("active",$var{filename});
      $element{filelist}->delete("active","active");
      $element{filelist}->activate($index);
      $var{mp3}->{filename}=$var{dir}.$var{filename};
    }
    $element{filenamelabel}->configure(-background=>"#d9d9d9");
  }
  return unless exists $var{labels};

  if ($element{v1caption}->cget("-background") eq "yellow") {
    my @fields;
    for (qw/v1song v1artist v1album v1year v1comment v1track v1genre/) {
      push @fields, $var{$_};
    }
    $var{v1}=$var{mp3}->newTag("ID3v1") unless exists $var{v1};
    $var{v1}->all(@fields);
    $var{v1}->writeTag;
    $var{v1genre}=$var{v1}->genre();
    $element{v1caption}->configure(-background=>"green");
  }
  if ($element{v2caption}->cget("-background") eq "yellow") {
    warn "saving of v1 tag not supported yet";
    $element{v2caption}->configure(-background=>"green");
  }
 out:
  while (my $label = shift @{$var{labels}}) {
    $label->configure(-background=>"#d9d9d9");
  }
 bye:
}

sub remove_id3v1 {
  for (qw/v1song v1artist v1album v1year v1comment v1track v1genre/) {
    $var{$_} = "";
  }
}

sub remove_id3v2 {
  for (qw/v2song v2artist v2album/) {
    $var{$_} = "";
  }
  $element{frames}->configure(-options => ["No frames"]);
  foreach (@{$var{fpack}}) {
    $_->packForget();
  }
  $var{fpack} = [];
  $var{longname}="";
}
