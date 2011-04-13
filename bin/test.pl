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
            
            # Check if the test exist, if not build it
            my $rebuild = ($opt eq "rebuild" ? 1 : 0);
            foreach my $test(@tests) {
                printf("BUILDING %-30s", $test);
                runMake($test, $config, $rebuild);
            }
            
            # Now run all tests
            my $passed = 0;
            my $failed = 0;
            my $skipped = 0;
            foreach my $test(@tests) {
                my $cmd = "$qtdir/tests/auto/$test/$config/tst_$test.exe";
                if (-e $cmd) {
                    printf("RUNNING  %-30s", $test);
                    if ($filter eq 1) {
                        my $_ = `$cmd`;
                        if (/Totals: (\d+) passed, (\d+) failed, (\d+) skipped/) {
                            $passed = $passed + $1;
                            $failed = $failed + $2;
                            $skipped = $skipped + $3;
                            printf("(%2d/%2d/%2d)\n",$1,$2,$3);
                        }
                    } else {
                        system($cmd);
                    }
                }
            }
            printf("SUMMARY  %29s (%3d/%2d/%2d)", " ", $passed, $failed, $skipped)
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

sub runMake
{
    my $testName = shift;
    my $config = shift;
    my $rebuild = shift;
    my $cmd = "$qtdir/tests/auto/$testName/$config/tst_$testName.exe";
    if (! $rebuild) {
        if (! -e $cmd) {
            print ("Could not find $testName, rebuilding");
            chdir("$qtdir/tests/auto/$testName");
            system("qmake");
            `$makeprog debug`;
            #system("$makeprog debug");
            $cmd = "$qtdir/tests/auto/$testName/$config/tst_$testName.exe";
        }
    }

    if (! -e $cmd || $rebuild) {
        #system("$makeprog distclean");
        #system("qmake");
        #system("$makeprog debug");
        `$makeprog distclean 2>NUL`;
        `qmake`;
        `$makeprog debug 2>NUL`;
    }
    if (-e $cmd) {
        print("OK");
    }
    print("\n");
}
