#!/usr/bin/perl
use Getopt::Long;
use Cwd;
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
    "isa"           => \$isa,      # string
    "d=s"           => \@rtl_defines,
    "cd=s"          => \@c_defines,
    "c_comp=s"      => \@c_comp,
    "comp=s"        => \@vcs_comp,
    "sim=s"         => \@sim_comp,
    "no_case"       => \$no_case,
    "fl=s"          => \$filelist
) or die("Error in command line arguments\n");

$proj_path = $ENV{"PROJ_PATH"};
print "$proj_path \n";

#================================================================
#c case compile
#================================================================
my $dir = getcwd;

if( defined($isa) ){
    $isa_dir = "$proj_path/riscv_riscv-tests/isa";
    chdir($isa_dir) or die "can't cd' $isa_dir , $!";;
    system("make -f $isa_dir/Makefile_cn PROGRAM=$case clean ");
    system("make -f $isa_dir/Makefile_cn PROGRAM=$case ");
    `cp  -rf $case.* $dir`;
    system("make -f $isa_dir/Makefile_cn PROGRAM=$case clean ");

    chdir($dir) or die "can't cd' $dir , $!";;
}else{
    $case_dir ="$proj_path/c_sim"; 
    chdir($case_dir) or die "can't cd' $case_dir , $!";;
    system("make -f $case_dir/Makefile PROGRAM_DIR=$module PROGRAM=$case clean ");
    system("make -f $case_dir/Makefile PROGRAM_DIR=$module PROGRAM=$case");
    `cp -rf $case.* $dir`;
    system("make -f $case_dir/Makefile PROGRAM_DIR=$module PROGRAM=$case clean ");

    chdir($dir) or die "can't cd' $dir , $!";;
}

if(-e "$pwd/instr_data.dat"){ `rm -rf $pwd/instr_data.dat`; }

system("dump_hex.pl -base 0x0 -length 0x10000 -i $case.hex");

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

if( ! defined($filelist) ){ $filelist = "$proj_path/sim/sim.lst"; `cp $filelist $dir`; }

system("vcs -f $filelist $vcs_option 2>&1 | tee -a ./vcs.log");
`echo "vcs -f $filelist $vcs_option 2>&1 | tee -a ./vcs.log" > run_command.log`;

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


