package Quran::Image::Page;

use strict;
use warnings;

use Data::Dumper;
use Mojo::Log;
use base qw/Quran Quran::Image/;

my $log = new Mojo::Log;
sub generate {
	my $self = shift;
	my %opts = @_;

	$self->{_pages}   = $opts{page}   || $opts{pages} || [1..604],
	$self->{_width}   = $opts{width}  || 1024,
	$self->{_output}  = $opts{output} || Quran::ROOT_DIR .'/images/pages/'. $self->{_width} .'/',
	$self->{_gd_text} = new GD::Text or die GD::Text::error;

	my $output  = $self->{_output};
	my $width = $self->{_width};

	# reset the bounding box table before re-running
	$self->db->reset_bounding_box_table();
	if (ref($self->{_pages}) eq 'ARRAY') {
		for my $page (reverse @{ $self->{_pages} }) {
			if ($page >= 1 and $page <= 604) {
				my $image = $self->create($page, $width);
				$self->image->write($output, $page, $image);
			}
		}
	}
	elsif ($self->{_pages} =~ /^[\d]+$/) {
		my $page = $self->{_pages};
		if ($page >= 1 and $page <= 604) {
			my $image = $self->create($page, $width);
			$self->image->write($output, $page, $image);
		}
	}

	return $self;
}

sub create {
	my ($self, $page) = @_;

	$page = {
		number => $page
	};

	print "Page: ". $page->{number} ."\n";

	my $fontfactor = 20.1;    # 21 is the default
	my $fontdelta = 1; #(21 - abs(21 - $fontfactor)) / 21;

    my @pagesWith10 = (189);
    my %pagesWith10Hash = map {$_ => 1} @pagesWith10;

    my @pagesWith20 = (210,216,336);
    my %pagesWith20Hash = map {$_ => 1} @pagesWith20;

	my @pagesWith25 = (224,291,345,446,520,526,585);
    my %pagesWith25Hash = map {$_ => 1} @pagesWith25;

    my @pagesWith30 = (6,17,107,164,165,198,209,213,273,281,298,323,338,423,455,457,521,527,535,577,584,586,601);
    my %pagesWith30Hash = map {$_ => 1} @pagesWith30;

	my @pagesWith40 = (37,135,153,174,178,190,193,194,211,214,230,259,260,262,264,265,269,272,274,285,289,293,294,308,342,349,367,369,372,376,403,407,413,433,435,440,441,444,449,450,452,497,507,519,522,523,532,533,567,575,578,582,591,595,597);
    my %pagesWith40Hash = map {$_ => 1} @pagesWith40;

	my @pagesWith50 = (16,105,140,150,156,161,175,185,186,235,244,255,256,261,263,266,267,268,278,284,286,287,290,297,313,314,320,324,337,346,347,353,354,365,368,373,374,375,377,401,404,409,412,430,431,434,437,451,453,456,477,483,484,490,492,493,525,528,529,534,537,558,565,569,581,583,589,599);
    my %pagesWith50Hash = map {$_ => 1} @pagesWith50;

	my @pagesWith60 = (27,100,111,117,120,125,134,137,162,169,180,184,187,188,191,192,195,197,199,231,249,251,254,276,277,282,283,288,292,311,312,317,332,333,348,351,355,370,405,410,411,416,417,418,419,426,438,443,447,448,461,465,476,481,486,487,491,500,504,508,518,530,543,559,566,568,570,574,576,579,580,587,588,590,592,594);
    my %pagesWith60Hash = map {$_ => 1} @pagesWith60;

	my @pagesWith90 = (30,52,57,61,63,76,78,92,96,98,101,102,103,115,116,118,119,121,122,124,126,128,138,141,147,149,151,159,181,202,204,207,208,212,217,232,238,240,241,242,250,280,302,304,309,319,322,325,329,352,357,361,380,386,389,392,399,402,406,414,415,421,424,439,445,454,460,463,464,468,472,475,478,489,495,499,502,505,506,511,512,513,517,536,540,545,560,562,564,571,572,600);
    my %pagesWith90Hash = map {$_ => 1} @pagesWith90;

	my @pagesWith100 = (4,5,14,15,19,20,21,22,23,24,25,26,31,32,34,35,39,45,47,49,51,53,62,64,65,66,67,68,73,74,75,81,83,91,93,95,99,109,136,139,142,143,144,145,155,157,167,182,183,203,223,229,236,237,243,248,310,331,340,356,360,381,382,383,388,391,393,395,396,398,400,428,436,458,459,467,480,498,510,514,538,542,546,547,551,554,556,561,563,598,602,603);
    my %pagesWith100Hash = map {$_ => 1} @pagesWith100;

	my @pagesWith110 = (28,29,36,38,40,41,43,46,48,59,60,69,79,80,88,97,131,132,148,160,227,305,306,307,330,366,397,473,474,541,548,550,553,555,596,604);
    my %pagesWith110Hash = map {$_ => 1} @pagesWith110;

	my @pagesWith120 = (44,82,84,163,394,539,557);
    my %pagesWith120Hash = map {$_ => 1} @pagesWith120;

	my @pagesWith130 = (13);
    my %pagesWith130Hash = map {$_ => 1} @pagesWith130;

	my @pagesWith140 = (3);
    my %pagesWith140Hash = map {$_ => 1} @pagesWith140;

	# page 270 font is slightly larger so it goes off the page
	if ($page->{number} < 3) {
		$fontfactor = 17.0;
	} elsif ($page->{number} == 270) {
		$fontfactor = 20.5;
	} elsif (exists $pagesWith10Hash{$page->{number}}) {
        $fontfactor = 21.2;
	} elsif (exists $pagesWith20Hash{$page->{number}}) {
        $fontfactor = 21.1;
	} elsif (exists $pagesWith25Hash{$page->{number}}) {
		$fontfactor = 20.9;
	} elsif (exists $pagesWith30Hash{$page->{number}}) {
        $fontfactor = 20.7;
	} elsif (exists $pagesWith40Hash{$page->{number}}) {
		$fontfactor = 20.5;
    } elsif (exists $pagesWith50Hash{$page->{number}}) {
        $fontfactor = 20.4;
	} elsif (exists $pagesWith60Hash{$page->{number}}) {
        $fontfactor = 20.3;
	} elsif (exists $pagesWith90Hash{$page->{number}}) {
		$fontfactor = 19.9;
	} elsif (exists $pagesWith100Hash{$page->{number}}) {
		$fontfactor = 19.7;
	} elsif (exists $pagesWith110Hash{$page->{number}}) {
		$fontfactor = 19.6;
	} elsif (exists $pagesWith120Hash{$page->{number}}) {
		$fontfactor = 19.5;
	} elsif (exists $pagesWith130Hash{$page->{number}}) {
		$fontfactor = 19.3;
	} elsif (exists $pagesWith140Hash{$page->{number}}) {
		$fontfactor = 19.0;
    } else {
		$fontfactor = 20.1;
	}

	$page->{width}   = $self->{_width};
	$page->{height}  = 6090; #$self->{_width} * Quran::Image::PHI * $fontdelta;
	$page->{ptsize}  = int($self->{_width} / $fontfactor);
	$page->{margin_top} = 113 + 100; # + $page->{ptsize} / 2;
	$page->{coord_y} = $page->{margin_top};
	$page->{font}    = Quran::Image::FONT_DEFAULT; # TODO: determine font size algorithmically and trim page height to fit or force fit
	$page->{image} = GD::Image->new($page->{width}, $page->{height});
	$page->{color} = {
		#debug => $page->{image}->colorAllocate(225,225,225),
		white => $page->{image}->colorAllocateAlpha(255,255,255,127),
		black => $page->{image}->colorAllocate(0,0,0),
		black_traceable => $page->{image}->colorAllocateAlpha(0, 0, 0, 100),
		#red   => $page->{image}->colorAllocate(127,11,19)
		red   => $page->{image}->colorAllocate(19,50,112),
		green   => $page->{image}->colorAllocate(0,200,0)
	};

	$page->{image}->alphaBlending(1);
	$page->{image}->interlaced('true');
	$page->{image}->setAntiAliased( $page->{color}->{black} );
	$page->{image}->transparent(    $page->{color}->{white} );

	$page->{lines} = $self->db->get_page_lines($page->{number});

	for (my $i = 0; $i < @{ $page->{lines} }; $i++) {
		my $line = $page->{lines}->[$i];

		$line->{page} = $page;

		$line->{box} = $self->_get_box($line);


	    if ($page->{number} < 3) {
			$page->{coord_y} += 136 / 3;
		} elsif ($page->{number} == 270) {
			$page->{coord_y} += 116.5 / 3;
		} elsif (exists ($pagesWith10Hash{$page->{number}})) {
        	$page->{coord_y} += 143.75 / 3;
		} elsif (exists ($pagesWith20Hash{$page->{number}})) {
         	$page->{coord_y} += 142 / 3;
		} elsif (exists $pagesWith25Hash{$page->{number}}) {
			$page->{coord_y} += 140.25 / 3;
		} elsif (exists ($pagesWith30Hash{$page->{number}})) {
        	$page->{coord_y} += 138.25 / 3;
		} elsif (exists ($pagesWith40Hash{$page->{number}})) {
			$page->{coord_y} += 136.25 / 3;
        } elsif (exists ($pagesWith50Hash{$page->{number}})) {
        	$page->{coord_y} += 134.5 / 3;
		} elsif (exists ($pagesWith60Hash{$page->{number}})) {
        	$page->{coord_y} += 131.75 / 3;
		} elsif (exists $pagesWith90Hash{$page->{number}}) {
			$page->{coord_y} += 128 / 3;
		} elsif (exists $pagesWith100Hash{$page->{number}}) {
			$page->{coord_y} += 126.25 / 3;
		} elsif (exists $pagesWith110Hash{$page->{number}}) {
			$page->{coord_y} += 124.5 / 3;
		} elsif (exists $pagesWith120Hash{$page->{number}}) {
			$page->{coord_y} += 122.5 / 3;
		} elsif (exists $pagesWith130Hash{$page->{number}}) {
			$page->{coord_y} += 120.75 / 3;
		} elsif (exists $pagesWith140Hash{$page->{number}}) {
			$page->{coord_y} += 116 / 3;
        } else {
		    $page->{coord_y} += 130 / 3;
        }

		$page->{coord_y} -= $line->{box}->{min_y}
		if $page->{coord_y} <= $page->{margin_top} and $line->{box}->{min_y} < 0;

		$line->{previous_w} = 0;
		$page->{coord_x} = 0;

		for (my $j = 0; $j < @{ $line->{glyphs} }; $j++) {
			my $glyph = $line->{glyphs}->[$j];

         my $type_id = $glyph->{type_id};
			$glyph->{line} = $line;
			$glyph->{box} = $self->_get_box($glyph);

			if ( $line->{type} ne 'sura' and grep { $page->{number} eq $_ } qw/1 2/  ) {
				$glyph->{use_coord_y} = 1;
				$glyph->{box}{coord_y} += 100;
				$glyph->{y_offset} = 100;
				#         $log->info( 'hmm' );
				#         $log->info( Dumper $page );
				#         exit 0;
			}

			if ($glyph->{position} == 1 and $line->{type} eq 'sura') {
				my $glyph = $self->db->get_ornament_glyph('header-box');
				$glyph->{line} = $line;
            $glyph->{type_id} = $type_id;

				$glyph->{ptsize} = $page->{ptsize} * 1.8;

				$glyph->{box} = $self->_get_box($glyph);

				$glyph->{use_coords} = 1;

				$glyph->{box}->{coord_y} = $page->{coord_y};
				$glyph->{box}->{coord_y} -= $glyph->{box}->{char_down};

				$self->_set_box($glyph);
			}

			$page->{coord_x} = $page->{coord_x} ?
			$page->{coord_x} + $line->{previous_w} :
			$line->{box}->{coord_x};

			$line->{previous_w} = $glyph->{box}->{max_x};

			if ($line->{type} eq 'sura') {
				$glyph->{use_coord_y} = 1;
				$glyph->{box}->{coord_y} = $page->{coord_y};
				$glyph->{box}->{coord_y} += $line->{box}->{height} / 7;
			}

         $glyph->{type_id} = $type_id;
			$glyph->{box} = $self->_set_box($glyph);

			$line->{box} = $self->_get_max_box($glyph->{box}, $line->{box});
		}

		$page->{coord_y} -= $line->{box}->{char_down};

		if ($page->{number} == 1 || $page->{number} == 2) {
			$page->{coord_y} += Quran::Image::PHI * $line->{box}->{char_up};
		}
		else {
			$page->{coord_y} += 2 * $line->{box}->{char_up};
		}
	}

	return $page->{image};
}

sub _set_box {
	my ($self, $glyph) = @_;

	my $line = $glyph->{line}? $glyph->{line} : $glyph;
	my $page = $line->{page};

	my $font   = $glyph->{font}   || $line->{font}   || $page->{font};
	my $ptsize = $glyph->{ptsize} || $line->{ptsize} || $page->{ptsize};

	my $box = $glyph->{box};

	my $color = $page->{color}->{black};

	if ($line->{type} eq 'ayah') {
		#my $gt = $self->db->_get_glyph_type($glyph->{text}, $page->{number});
		#$color = $self->_should_color($glyph->{text}, $page->{number},
		#   $line->{type}, $gt) ?
		#	$page->{color}->{red} : $page->{color}->{black};
	}
	elsif ($line->{type} eq 'sura'){
		#$color = $page->{color}->{red};
	}

   if ($glyph->{type_id} == 2) {
      $color = $page->{color}->{green};
   }

	# begin hack
	my ($coord_x, $coord_y) = $glyph->{use_coords} ? ($glyph->{box}->{coord_x}, $glyph->{box}->{coord_y}) : ($page->{coord_x}, $page->{coord_y});
	$coord_x = $glyph->{box}->{coord_x} if $glyph->{use_coord_x};
	$coord_y = $glyph->{box}->{coord_y} if $glyph->{use_coord_y};
	# end of hack

	if ($line->{type} eq 'ayah') {
		my ($min_x, $max_x, $min_y, $max_y) = (undef, undef, undef, undef);

		$min_x = $page->{coord_x} + $glyph->{box}->{min_x};
		$min_x = int($min_x);
		$max_x = $min_x + ($glyph->{box}->{max_x} - $glyph->{box}->{min_x});
		$max_x = int($max_x + 0.5);

		$min_y = $page->{coord_y} + $glyph->{box}->{min_y};
		$min_y = int($min_y);
		$max_y = $min_y + ($glyph->{box}->{max_y} - $glyph->{box}->{min_y});
		$max_y = int($max_y + 0.5);

		if ($glyph->{y_offset}) {
			# used to ensure coordinates for pages 1 and 2 reflect additional
			# offset added to space sura header and sura text.
			#     $log->info("here with " . $glyph->{y_offset});
			$min_y = $min_y + $glyph->{y_offset};
			$max_y = $max_y + $glyph->{y_offset};
		}

		$self->db->set_page_line_bbox($glyph->{page_line_id}, $page->{width}, $min_x, $max_x, $min_y, $max_y);
	}

	# $page->{image}->setStyle($page->{color}->{black}, gdTransparent, $page->{color}->{black}, gdTransparent);
	$page->{image}->setStyle($page->{color}->{black_traceable}, GD::gdTransparent, $page->{color}->{black_traceable}, GD::gdTransparent);
	$page->{image}->stringFT(GD::gdStyled, $font, $ptsize, 0, $coord_x, $coord_y, $glyph->{text}, {
		resolution => '96,94',
		kerning => 0
	});

	return $box;
}

sub _get_box {
	my ($self, $glyph) = @_;

	my $line = $glyph->{line}? $glyph->{line} : $glyph;
	my $page = $line->{page};

	my $font   = $glyph->{font}   || $line->{font}   || $page->{font};
	my $ptsize = $glyph->{ptsize} || $line->{ptsize} || $page->{ptsize};

	# we recently changed these 3 fonts to fix some artifacts (extra lines or
	# pixels in them). the exported font in fontforge causes char_up and
	# char_down values to be different. i couldn't figure out a way to fix
	# this in the font itself, so in those cases, just read the values from
	# one of the other font files (in this case, BSML.ttf) and use them. the
	# values seem to be the same across all the original fonts.

	my $adjustedUp = 0;
	my $adjustedDown = 0;
	my $shouldAdjust = 0;

	if ($font =~ /P105/ || $font =~ /P237/ || $font =~ /P552/ || $font =~ /P554/) {
		$self->{_gd_text}->set(
		font   => $page->{font},
		ptsize => $ptsize
		);
		$shouldAdjust = 1;
		$adjustedUp = $self->{_gd_text}->get('char_up');
		$adjustedDown = $self->{_gd_text}->get('char_down');
	}

	$self->{_gd_text}->set(
	font   => $font,
	ptsize => $ptsize
	);
	$self->{_gd_text}->set_text( $glyph->{text} );

	my ($space, $char_down, $char_up) = $self->{_gd_text}->get('space', 'char_down', 'char_up');

	# see comment above
	if ($shouldAdjust) {
		$char_up = $adjustedUp;
		$char_down = $adjustedDown;
	}

	# @bbox[0,1]  Lower left corner (x,y)
	# @bbox[2,3]  Lower right corner (x,y)
	# @bbox[4,5]  Upper right corner (x,y)
	# @bbox[6,7]  Upper left corner (x,y)

	my @bbox = GD::Image->stringFT($page->{color}->{black}, $font, $ptsize, 0, 0, 0, $glyph->{text});
	my $min_x = List::Util::min($bbox[0], $bbox[6]);
	my $max_x = List::Util::max($bbox[4], $bbox[2]);
	my $min_y = List::Util::min($bbox[7], $bbox[5]);
	my $max_y = List::Util::max($bbox[1], $bbox[3]);

	my $width = $max_x;# - $min_x;
	my $height = $max_y - $min_y;

	my $coord_x = ($page->{width} - $width) / 2;
	my $coord_y = $page->{coord_y};

	return {
		coord_x   => $coord_x,
		coord_y   => $coord_y,
		min_x     => $min_x,
		max_x     => $max_x,
		min_y     => $min_y,
		max_y     => $max_y,
		space     => $space,
		char_down => $char_down,
		char_up   => $char_up,
		width     => $width,
		height    => $height,
		bbox      => \@bbox,
		corner    => {
			top => {
				left  => [$bbox[6],$bbox[7]],
				right => [$bbox[4],$bbox[5]]
			},
			bottom => {
				left  => [$bbox[0],$bbox[1]],
				right => [$bbox[2],$bbox[3]]
			}
		}
	};
}

sub _get_max_box {
	my $self = shift;
	my ($box_a, $box_b) = @_;
	my $box_c;
	my @lt = qw/min_x min_y char_down coord_x coord_y/;
	my @gt = qw/max_x max_y space char_up width height/;
	for (@lt) {
		$box_c->{$_} = ($box_a->{$_} <= $box_b->{$_})? $box_a->{$_} : $box_b->{$_};
	}
	for (@gt) {
		$box_c->{$_} = ($box_a->{$_} >= $box_b->{$_})? $box_a->{$_} : $box_b->{$_};
	}
	return $box_c;
}

1;
__END__
