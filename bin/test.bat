@goto invoke_perl
#!/usr/bin/perl -w
######################################################################
#
#
######################################################################

# use packages -------------------------------------------------------
use File::Basename;
use File::Path;
use Cwd;
use Config;
use strict;

sub usage()
{
    print("Usage: test [options] <testgroup>\n\n",
          "Options:\n",
          "  --config <release|debug>       Run the tests in release or debug configuration.\n",
          "  --verbose                      Show all output from test, not only the summary for each test.\n",
          "  --help                         Show this help screen\n" );
    exit(0);
    
}

my $qtdir = $ENV{"QTDIR"};
my @user_groups;
my $config = "debug";
my $filter = 1;
while ( @ARGV ) {
    my $arg = shift @ARGV;
    if (substr("$arg", 0, 1) eq "-") {
        if ($arg eq "--config") {
            $config = shift @ARGV;
        } elsif ($arg eq "--verbose") {
            $filter = 0;
        } elsif ($arg eq "--help") {
            usage();
        } else {
            print("unknown option $arg");
        }
    } else {
        push(@user_groups, $arg);
    }
}

my %test_groups = (
    "graphicslayout" => [ "qgraphicslayout", 
                "qgraphicslayoutitem", 
                "qgraphicslinearlayout", 
                "qgraphicsgridlayout"],
    "graphicsview" => [ "qgraphicsitem", 
                "qgraphicsscene",
                "qgraphicsview"],
    "woc" => [  ":graphicslayout", 
                ":graphicsview",
                "qgraphicswidget",
                "qgraphicsproxywidget" ],
    "animation" => [  "qpropertyanimation", 
                "qanimationgroup",
                "qparallelanimationgroup",
                "qsequentialanimationgroup" ],
    );

if (scalar(@user_groups) eq 0) {
    print "available test groups:\n";
    my $test_group; 
    for $test_group ( keys %test_groups ) {
        print "  $test_group\n";
    }
} else {
    foreach my $group(@user_groups) {
        my @tests = testsForGroup($group);
        foreach my $test(@tests) {
            my $cmd = "$qtdir/tests/auto/$test/$config/tst_$test.exe";
            $cmd =~ tr,/,\\,;
            print("$cmd\n");
            if ($filter eq 1) {
                my $output = `$cmd`;
                my @outp = split(/\n/, $output);
                my @out = grep {/(Start testing|Totals:)/} @outp;
                print join("\n", @out) . "\n";
            } else {
                system($cmd);
            }
        }
    }
}

sub testsForGroup
{
    my ($testGroup) = @_;
    my @tests;
    my @groups = ("$testGroup");
    my $i = 0;
    while (scalar(@groups) > 0) {
        my $tg = pop(@groups);
        for $i ( 0 .. $#{ $test_groups{$tg} } ) {
            my $test = $test_groups{$tg}[$i];
            if (substr($test, 0, 1) eq ":") {
                push(@groups, substr($test, 1, length($test) - 1));
            } else {
                push(@tests, "$test");
            }
        }
    }
    return @tests;
}

__END__

:invoke_perl
@perl -x -S %~nx0 %*
