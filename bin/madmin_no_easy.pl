#! /usr/bin/perl
use Tk;
use Tk::Spinbox;
use Tk::BrowseEntry;
no warnings 'utf8';
use Encode qw(decode is_utf8);

# Declarations
# TODO: Make $Min_Val a function of operator, possibly moving into @Ops config.
# How: Add min to sym/chk.
our $Min_Val = 4;
our $Max_Val = 9;
our $Op = '+';
our $Num_Rows = 10;
our @Ops = (
	{
		sym => '+',
		chk => 1,
	},
	{
		sym => '-',
		chk => 0,
	},
	{
		sym => 'x',
		chk => 0,
	},
);

our (@Probno, @Arg1, @Op, @Arg2);

# Definitions
use constant {
	NUM_OPS       => 3,
	PROBS_PER_ROW => 10
};

our $mw = MainWindow->new;
$mw->configure(-title => 'Amy\'s Academy\'s "Mad Minutes"');

our $f_range = $mw->Frame->pack(-side => top, -fill => x);
our $f_op = $mw->Frame->pack(-side => top, -fill => x);
our $f_btn = $mw->Frame->pack(-side => top, -fill => x);
$f_range->Label(-text => "Operand range: $Min_Val to ")->pack(
	-side => left
);
our $spin_maxval = $f_range->Spinbox(
	-from => 1, -to => 100, -increment => 1, -textvariable => \$Max_Val, -width => 3,
)->pack(
	-side => left
);
$f_range->Label(-text => '# of rows (10 per row):')->pack(
	-side => left
);
our $spin_numrows = $f_range->Spinbox(
	-from => 1, -to => 100, -increment => 1, -textvariable => \$Num_Rows, -width => 3,
)->pack(
	-side => left
);
$f_range->Label(-text => 'Operator:')->pack(-side => left);
$f_range->Checkbutton(
	-text => $_->{sym}, -variable => \$_->{chk}, -width => 3,
	-command => \&validate_chk_btns,
)->pack(-side => left) foreach (@Ops);
=skip
$f_range->Radiobutton(-text => '+', -variable => \$Op, -value => '+', -width => 3)->pack(-side => left);
$f_range->Radiobutton(-text => '-', -variable => \$Op, -value => '-', -width => 3)->pack(-side => left);
$f_range->Radiobutton(-text => 'x', -variable => \$Op, -value => 'x', -width => 3)->pack(-side => left);
$f_range->Radiobutton(-text => '/', -variable => \$Op, -value => '/', -width => 3)->pack(-side => left);
=cut
=skip
$s = chr(0xF7);
#$st =~ tr/\0-\xff//;
#$su = Unicode::String::utf8($s);
$ss = "\xf7";
$ss = decode('utf8', "\xf7");
print "is_utf8: ", is_utf8($ss);
$f_range->Radiobutton(-text => $ss, -variable => \$Op, -value => $ss, -width => 3)->pack(-side => left);
=cut

# Now for a print button
our $b_print = $f_btn->Button(
	-text => 'Print',
	-command => \&cmd_print
)->pack(
	-side => right,
	-expand => 1,
	-fill => x
);
# Now that the print button exists, we can set up validation for the spin
# boxes
our %vld_ctls = (
	maxval  => 1,
	numrows => 1,
	ops     => 1,
);
$spin_maxval->configure(
	-validate => key,
	-validatecommand => [ \&validate_num, 'maxval' ],
);
$spin_numrows->configure(
	-validate => key,
	-validatecommand => [ \&validate_num, 'numrows' ],
);

# TODO: Figure out why I can't output latin1 above 128
#print "\x{223B}:\n";
#print "\x{2A09}:\n";
$mw->MainLoop();
sub validate_num
{
	my ($ctl, $n) = @_;
	# Let user enter whatever he likes, but disable Print button if it's not
	# a valid number
	config_btn($ctl, $n =~ /^\s*[1-9][0-9]*\s*$/);
	return 1;
}
sub validate_chk_btns
{
	config_btn('ops', scalar grep { $_->{chk} } @Ops);
}
sub config_btn
{
	$vld_ctls{$_[0]} = $_[1];
	$b_print->configure(
		-state =>
		(grep { !$_ } values %vld_ctls)
			? 'disabled'
			: 'normal'
	);
}
sub gen_probs
{
	# Clear out arrays and rebuild with current settings
	@Probno = @Arg1 = @Arg2 = @Op = ();
	my $np = 0;
	my %dups; # used only for $uniq_mode eq 'uniq'
	# Determine the operators to be used
	my @ops = map { $_->{sym} } grep { $_->{chk} } @Ops;
	# Proceed no further if no operator selected
	my $num_uniq = @ops * $Max_Val * $Max_Val;
	# Make any necessary adjustment for '-'
	if (grep { $_ eq '-' } @ops) {
		$num_uniq -= (($Max_Val * $Max_Val) - $Max_Val) / 2;
	}
	my $num_probs = $Num_Rows * PROBS_PER_ROW;
	my $uniq_mode = $num_uniq >= $num_probs
		? 'uniq'
		: $num_uniq > 4
			? 'near'
			: 'none'
	;
	while ($np < $num_probs) {
		my ($a, $op, $b) = (
			sprintf("%0.0f", rand($Max_Val - $Min_Val + 1)) + $Min_Val,
			$ops[int(rand @ops)],
			sprintf("0.0f", rand($Max_Val - $Min_Val + 1)) + $Min_Val,
		);
		# No subtractions with neg. results
		next if $op eq '-' and $a < $b;
		if ($uniq_mode eq 'uniq') {
			next if exists $dups{"$a,$op,$b"};
			$dups{"$a,$op,$b"}++;
		} elsif ($uniq_mode eq 'near') {
			# Check only certain nearby problems
			my ($above, $left, $diagl, $diagr) = (
				$np < PROBS_PER_ROW ? undef : $np - PROBS_PER_ROW,
				$np % PROBS_PER_ROW == 0 ? undef : $np - 1,
				$np < PROBS_PER_ROW || $np % PROBS_PER_ROW == 0 ? undef : $np - PROBS_PER_ROW - 1,
				$np % PROBS_PER_ROW == PROBS_PER_ROW - 1 || $np < PROBS_PER_ROW
					? undef
					: $np - PROBS_PER_ROW + 1
			);
			next if
				defined($above) and "$Arg1[$above],$Op[$above],$Arg2[$above]" eq "$a,$op,$b" or
				defined($left) and "$Arg1[$left],$Op[$left],$Arg2[$left]" eq "$a,$op,$b" or
				defined($diagl) and "$Arg1[$diagl],$Op[$diagl],$Arg2[$diagl]" eq "$a,$op,$b" or
				defined($diagr) and "$Arg1[$diagr],$Op[$diagr],$Arg2[$diagr]" eq "$a,$op,$b";
		}
		$np++;
		push @Arg1, $a;
		push @Arg2, $b;
		push @Probno, $np;
		push @Op, $op;
	}
}

format ROW =
   @>      @>      @>      @>      @>      @>      @>      @>      @>      @>
{
   shift(@Arg1),
          shift(@Arg1),
                 shift(@Arg1),
                        shift(@Arg1),
                               shift(@Arg1),
                                      shift(@Arg1),
                                             shift(@Arg1),
                                                    shift(@Arg1),
                                                           shift(@Arg1),
                                                                  shift(@Arg1),
}
 @ @>    @ @>    @ @>    @ @>    @ @>    @ @>    @ @>    @ @>    @ @>    @ @>
{
 shift(@Op),
   shift(@Arg2),
        shift(@Op),
          shift(@Arg2),
               shift(@Op),
                 shift(@Arg2),
                      shift(@Op),
                        shift(@Arg2),
                             shift(@Op),
                               shift(@Arg2),
                                    shift(@Op),
                                      shift(@Arg2),
                                           shift(@Op),
                                             shift(@Arg2),
                                                  shift(@Op),
                                                    shift(@Arg2),
                                                         shift(@Op),
                                                           shift(@Arg2),
                                                                shift(@Op),
                                                                  shift(@Arg2),
}
 ____    ____    ____    ____    ____    ____    ____    ____    ____    ____
.

sub cmd_print
{
	# Fill the arrays
	gen_probs();
	my $dbg = 0;
	if ($dbg) {
		open PRINTER, ">&STDOUT";
	} else {
		open PRINTER, "|-", "lpr -h -T 'mad minutes'" or
			print STDERR "Couldn't open default printer for printing mad minutes: $!\n";
	}
	# Set the format to be used for PRINTER filehandle
	select(
		(
		select(PRINTER),
		$~ = "ROW"
		)[0]
	);
	my $row = 0;
	for (my $row = 0; $row < $Num_Rows; $row++) {
		write PRINTER;
		print PRINTER "\n\n\n";
	}
	close PRINTER;
}

# vim:ts=4:sw=4:tw=78:fdm=marker:fmr=<<<,>>>
