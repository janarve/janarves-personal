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

sub printprintGroup
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

my $testsDir = `qmake -query QT_INSTALL_TESTS`;
$testsDir =~ tr,\\,/,;
$testsDir =~ s/^\s+|\s+$//g;

my @user_groups;
my $config = "debug";
my $filter = 1;
my $verbose = 0;
my $opt = "";
my $makeprog = "nmake";

while ( @ARGV ) {
    my $arg = shift @ARGV;
    if (substr("$arg", 0, 1) eq "-") {
        if ($arg eq "--config") {
            $config = shift @ARGV;
        } elsif ($arg eq "--verbose") {
            $filter = 0;
            $verbose = 1;
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
                printf("BUILDING %-30s\n", $test);
                runMake($test, $config, $rebuild);
            }
            
            # Now run all tests
            my $passed = 0;
            my $failed = 0;
            my $skipped = 0;
            printf("RUNNING  %29s |PASS|FAIL|SKIP|\n", " ");
            foreach my $test(@tests) {
                my $ri = rindex($test, "/");
                my $exeqtable = "";
                if ($ri eq -1)  {
                    $exeqtable = $test;
                } else {
                    $exeqtable = substr($test, $ri + 1);
                }
                my $cmd = "$testsDir/auto/$test/$config/tst_$exeqtable.exe";
                if (-e $cmd) {
                    printf("RUNNING  %-30s", $exeqtable);
                    if ($filter eq 1) {
                        my $_ = `$cmd`;
                        if (/Totals: (\d+) passed, (\d+) failed, (\d+) skipped/) {
                            $passed = $passed + $1;
                            $failed = $failed + $2;
                            $skipped = $skipped + $3;
                            printf("|%4d|%4d|%4d|\n",$1,$2,$3);
                        }
                    } else {
                        system($cmd);
                    }
                }
            }
            printf("SUMMARY  %29s |%4d|%4d|%4d|\n", " ", $passed, $failed, $skipped)
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

    my $ri = rindex($testName, "/");
    my $exeqtable = "";
    if ($ri eq -1)  {
        $exeqtable = $testName;
    } else {
        $exeqtable = substr($testName, $ri + 1);
    }

    my $cmd = "$testsDir/auto/$testName/$config/tst_$exeqtable.exe";
    if (! $rebuild) {
        if (! -e $cmd) {
            print ("Could not find $testName, rebuilding");
            chdir("$testsDir/auto/$testName");
            system("qmake");
            `$makeprog debug`;
        } else {
            system("qmake");
            if ($verbose) {
                `$makeprog debug`;
            } else {
                `$makeprog debug 2>NUL`;
            }
        }
    }

    if (! -e $cmd || $rebuild) {
        if ($verbose) {
            `$makeprog distclean`;
        } else {
            `$makeprog distclean 2>NUL`;
        }
        `qmake`;
        if ($verbose) {
            `$makeprog debug`;
        } else {
            `$makeprog debug 2>NUL`;
        }
    }
    if (-e $cmd) {
        print("OK");
    }
    print("\n");
}
