use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'MP3::Tag',
    'VERSION_FROM'	=> 'Tag.pm', # finds $VERSION
    'PMLIBDIRS'         => ['Tag', 'MP3::Tag'],
    'AUTHOR'            => '"Thomas Geffert" <thg@users.sourceforge.net>',
    'PREREQ_PM'         => {Compress::Zlib=>0, File::Basename=>0},
    'PL_FILES'          => {'data_pod.PL'=>'ID3v2-Data.pod'},
    'MAN1PODS'          => {'ID3v2-Data.pod'=>'blib/man3/MP3::Tag::ID3v2-Data.3'},
    'clean'             => {FILES => 'ID3v2-Data.pod'},
);

