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
use FindBin;

sub usage()
{
    print("Usage: test [options] <testgroups>\n\n",
          "Options:\n",
          "  --config <release|debug>       Run the tests in release or debug configuration.\n",
          "  --verbose                      Show all output from test, not only the summary for each test.\n",
          "  --list                         list all tests for <testgroups>\n",
          "  --rebuild                      rebuild tests\n",
          "  --help                         Show this help screen\n" );
    exit(0);

}

sub printGroup
{
    my ($test_group, $indent) = @_;
    my @tests = testsForGroup($test_group);
    foreach my $test(@tests) {
        printf("%*s$test\n", $indent, " ");
    }
}

sub findBin()
{
    my $path = $FindBin::Bin;
    return "$path/test.config";
}

## Read configuration file
my $file = findBin();
my %result = do $file;
die "Probable syntax error $file\n" unless (%result);
my %test_groups = %result;

my $qtdir = $ENV{"QTDIR"};
if ($qtdir) {
    $qtdir =~ tr,\\,/,;
}
my @user_groups;
my $config = "debug";
my $filter = 1;
my $opt = "";
my $makeprog = "nmake";

while ( @ARGV ) {
    my $arg = shift @ARGV;
    if (substr("$arg", 0, 1) eq "-") {
        if ($arg eq "--config") {
            $config = shift @ARGV;
        } elsif ($arg eq "--verbose") {
            $filter = 0;
        } elsif ($arg eq "--list") {
            $opt = "list";
        } elsif ($arg eq "--rebuild") {
            $opt = "rebuild";
        } elsif ($arg eq "--help") {
            usage();
        } else {
            print("unknown option $arg");
        }
    } else {
        push(@user_groups, $arg);
    }
}

if (scalar(@user_groups) eq 0) {
    print "available test groups:\n";
    if (!scalar (keys %test_groups)) {
        print("none\n");
    } else {
        my $test_group;
        for $test_group ( keys %test_groups ) {
            print("  * $test_group\n");
            printGroup($test_group, 6);
        }
    }
} else {
    foreach my $group(@user_groups) {
        if ($opt eq "list") {
            printGroup($group, 2);
        } else {
            my @tests = testsForGroup($group);
            if ($opt eq "rebuild") {
                foreach my $test(@tests) {
                    print ("BUILDING $test");
                    chdir("$qtdir/tests/auto/$test");
                    system("$makeprog distclean");
                    system("qmake");
                    system("$makeprog debug");
                    my $cmd = "$qtdir/tests/auto/$test/$config/tst_$test.exe";
                    if (-e $cmd) {
                        print("OK!");
                    }
                }
            }
            
            # Check if the test exist, if not build it
            foreach my $test(@tests) {
                my $cmd = "$qtdir/tests/auto/$test/$config/tst_$test.exe";
                if (! -e $cmd) {
                    print ("Could not find $test, rebuilding");
                    chdir("$qtdir/tests/auto/$test");
                    system("qmake");
                    system("$makeprog debug");
                    my $cmd = "$qtdir/tests/auto/$test/$config/tst_$test.exe";
                    if (! -e $cmd) {
                        system("$makeprog distclean");
                        system("qmake");
                        system("$makeprog debug");
                    }
                    if (-e $cmd) {
                        print("OK");
                    }
                    print("\n");                
                }
            }
            
            # Now run all tests
            foreach my $test(@tests) {
                my $cmd = "$qtdir/tests/auto/$test/$config/tst_$test.exe";
                if (-e $cmd) {
                    #$cmd =~ tr,/,\\,;
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
            if (substr($test, 0, 1) eq "&") {
                push(@groups, substr($test, 1, length($test) - 1));
            } else {
                push(@tests, "$test");
            }
        }
    }
    return @tests;
}
