#!/usr/bin/perl
use Getopt::Long;
#================================================================
#   Copyright (C) 2021 Sangfor Ltd. All rights reserved.
#   
#   Filename   ：run_sim.pl
#   Auther     ：cnan
#   Creat_Data ：2021.03.28
#
#================================================================
my $module;
my $case;
my @rtl_defines;
my @c_defines;
my @vcs_comp;
my @sim_comp;

GetOptions (
    "module=s"      => \$module,    # numeric
    "case=s"        => \$case,      # string
    "d=s"           => \@rtl_defines,
    "cd=s"          => \@c_defines,
    "c_comp=s"      => \@c_comp,
    "comp=s"        => \@vcs_comp,
    "sim=s"         => \@sim_comp,
    "no_case"       => \$no_case,
    "filelist=s"    => \$filelist
) or die("Error in command line arguments\n");

$proj_path = $ENV{"PROJ_HOME"};

#================================================================
#c case compile
#================================================================
#TODO

#================================================================
#vcs compile
#================================================================
my $vcs_option;
my $defines;
my $NOVAS_HOME = $ENV{"NOVAS_HOME"};

foreach (@rtl_defines){
    $defines .= "+define+$_ ";
}

$vcs_option .= "-full64 -cpp g++-4.8 -cc gcc-4.8 ";
$vcs_option .= "-LDFLAGS -Wl,-no-as-needed ";
$vcs_option .= "-notice +v2k +vcs+lic+wait +vcsd -line -debug_all ";
$vcs_option .= "-P $NOVAS_HOME/share/PLI/VCS/LINUX64/novas.tab $NOVAS_HOME/share/PLI/VCS/LINUX64/pli.a ";
$vcs_option .= "-sverilog ";
$vcs_option .= "$defines ";
$vcs_option .= "$vcs_option ";

if(-e simv){ `rm -r simv`;}
if(-e simv.daidir){ `rm -rf simv.daidir`; }

if( ! defined($filelist) ){ $filelist = "rtl_sim.f"; }

system("vcs -f $filelist $vcs_option 2>&1 | tee -a ./vcs.log");

#================================================================
#sim
#================================================================ 
my $sim_option;

foreach (@sim_comp){
    $sim_option .= "$_ ";
}

system("./simv $sim_option 2>&1 | tee -a ./sim.log");

#================================================================
#done
#================================================================
print ">>>>>>>>>>> SIM DONE <<<<<<<<<<<<<<<\n";


