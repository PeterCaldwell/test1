#! /bin/csh -fe

### This script was created 2015-11-15 by Philip Cameron-Smith (pjc@llnl.gov) and Peter Caldwell
### and incorporates some features originally from Hui Wan, Kai Zhang, and Balwinder Singh.
###
set first_argument = $1
if ( $first_argument != '' ) then
 echo 'This script does everything needed to configure/compile/run a case. As such, it'
 echo 'provides complete provenance for each run and makes sharing with newbies easy. Future'
 echo 'users should make sure that everything required for a run is in this script, the ACME' 
 echo 'git repo, or the inputdata svn repo.'
 echo '** This script accepts no arguments. Please edit the script as needed and resubmit without arguments. **'
 exit 5
endif
###===================================================================
### THINGS USERS USUALLY CHANGE (SEE END OF SECTION FOR GUIDANCE)                 
###===================================================================

### BASIC INFO ABOUT RUN
set run_name   = run_acme_example      
set compset    = A_B1850           # !!!!!! CHANGE BEFORE ARCHIVING to A_B1850  !!!!!!!
set resolution = ne30_m120         # !!!!!! CHANGE BEFORE ARCHIVING to ne30_m120 !!!!!!!
set machine    = titan             # !!!!!! CHANGE BEFORE ARCHIVING to edison   !!!!!!!
setenv project   cli112   #note project must be an *environment* variable on some systems.  # !!!!!! CHANGE BEFORE ARCHIVING to acme   !!!!!!!

### LENGTH OF SIMULATION, RESTARTS, AND ARCHIVING
set stop_units           = ndays
set stop_num             = 1
set restart_units        = $stop_units
set restart_num          = $stop_num
set num_resubmits        = 0
set do_short_term_archiving = false
set do_long_term_archiving  = false

### SIMULATION OPTIONS
set atm_output_freq              =  1
set records_per_atm_output_file  = 40

### SOURCE CODE OPTIONS
set fetch_code = true    # !!!!! CHANGE BEFORE ARCHIVING to true !!!!!!!
set acme_tag   = master  # !!!!! CHANGE BEFORE ARCHIVING to ??????   !!!!!!!
set tag_name   = run_acme_tag_example   # !!!!!  CHANGE BEFORE ARCHIVING to run_acme_tag_example !!!!!!!

### BUILD OPTIONS
set debug_compile          = false     # !!!!! CHANGE BEFORE ARCHIVING to false !!!!!!!
set old_executable         = false     # !!!!! CHANGE BEFORE ARCHIVING to false !!!!!!!

### SUBMIT OPTIONS
set submit_run             = true      # !!!!! CHANGE BEFORE ARCHIVING to true !!!!!!!
set debug_queue            = true      # !!!!! CHANGE BEFORE ARCHIVING to true !!!!!!!

### AUTOMATIC DELETION OPTIONS
set seconds_before_delete_source_dir = 10   # !!!!!!! CHANGE BEFORE ARCHIVING to -1 !!!!!!
set seconds_before_delete_case_dir   =  3
set seconds_before_delete_bld_dir    = 10
set seconds_before_delete_run_dir    = -1

### !!!! OPTIONS BELOW HERE NORMALLY SHOULDN'T BE CHANGED !!!!
### ----------------------------------------------------------
### PROCESSOR CONFIGURATION
set processor_config = M       # !!!!!!! CHANGE BEFORE ARCHIVING to M !!!!!!

### STARTUP TYPE
set model_start_type = initial       # options: initial, continue, branch.

### DIRECTORIES
set code_root_dir  = ~/ACME_code/
set run_root_dir   = default    # defaults known for many machines. If yours isn't known, please add it!
set short_term_archive_root_dir = default #       ""                                              ""

#EXPLANATION FOR VARIABLES ABOVE:
#==================================
#run_name: the run will be named: ${tag_name}.${compset}.${resolution}.${machine}.${run_name}.  run_name is to explain the 
#    purpose of the run (e.g. run_name=ParallelPhysDyn) or just to ensure the run name is unique (e.g. run_name=test1).
#compset: indicates which model components and forcings to use. List choices by typing `create_newcase -list compsets`.
#    An (outdated?) list of options is available at http://www.cesm.ucar.edu/models/cesm1.0/cesm/cesm_doc_1_0_4/a3170.html 
#resolution: Model resolution to use. Type `create_newcase -list grids` for a list of options or see 
#    http://www.cesm.ucar.edu/models/cesm1.0/cesm/cesm_doc_1_0_4/a3714.htm. Note that ACME always uses ne30 or ne120 in the atmosphere.
#machine: what machine you are going to run on. Must be a machine listed in $ACMEROOT/cime/machines-acme/config_machines.xml  
#    (which can also be listed via `create_newcase -list machines`).
#project: what bank to charge for your run time. May not be needed on some machines.

#fetch_code: If True, downloads code from github. If False, code is assumed to exist already.
#    NOTE: it is assumed that you have access to the ACME git repository.  To get access, see:
#    https://acme-climate.atlassian.net/wiki/display/Docs/Installing+the+ACME+Model
#acme_tag: ACME tagname in github. Can be 'master', a git hash, a tag, or a branch name. Only used if fetch_code=True.     
#    NOTE: If acme_tag=master, then this script will provide the latest master version, but detach from the head, 
#          to minimize the risk of a user pushing something to master.
#tag_name: Short name for the ACME branch used. If fetch_code=True, this is a shorter replacement for acme_tag 
#    (which could be a very long hash!). Otherwise, this is a short name for the branch used. You can
#    choose TAG_NAME to be whatever you want.

#stop_units: The units for the length of run, eg nhours, ndays, nmonths, nyears.
#stop_num: The simulation length for each batch submission, in units of $stop_units.
#restart_units: The units for how often restart files are written, eg nhours, ndays, nmonths, nyears.
#restart_num: How often restart files are written, in units of $restart_units.
#num_resubmits: After a batch job finishes successfully, a new batch job will automatically be submitted to 
#    continue the simulation.
#do_short_term_archiving: If TRUE, then move simulation output to the archive directory in your scratch directory.
#do_long_term_archiving : If TRUE, then move simulation output from the short_term_archive to the local mass storage system.

#debug_compile: If TRUE, then compile with debug flags 
#    Compiling in debug mode will stop the run at the actual location an error occurs, and provide more helpful output.
#    However, it runs about 10 times slower, and is not bit-for-bit the same because some optimizations make tiny change to the
#    numerics.
#old_executable: If FALSE then build a new executable (using any already compiled files). If you want a clean build then
#    set seconds_before_delete_bld_dir>=0.   If TRUE then skip the build step entirely.
#    If this is a path to an executable, then copy that executable into the current case instead.
#    NOTE: The executable that will be copied should be the same as would be created by compiling (for provenance).
#    NOTE: The path should either be an absolute path, or a path relative to the case_scripts directory.
#    NOTE: old_executable=true is a risk to provenance, so this feature may be removed in the future.
#          However the build system currently rebuilds a few files every time which takes several minutes.
#          When this gets fixed the cost of deleting this feature will be minor.

#submit_run:  If True, then submit the batch job to start the simulation.
#debug_queue: If True, then use the debug queue, otherwise use the queue specified in the section on QUEUE OPTIONS. 

#atm_output_freq (the namelist variable is nhtfrq) : The frequency with which the atmosphere writes its output.   
#    0=monthly, +N=every N timesteps,  -N=every N hours 
#    For more information:   http://www.cesm.ucar.edu/models/atm-cam/docs/usersguide/node45.html          
#records_per_atm_output_file (the namelist variable is mfilt):  The number of time records in each netCDF output file 
#    from the atmosphere model. If atm_output_freq=0, then there will only be one time record per file.
#NOTE: If there will be more than one 'history tape' defined in the atm namelist, then 
#    atm_output_freq and records_per_atm_output_file should be a comma-separated list of numbers 
#    (specifying the option for each history tape).  

#seconds_before_delete_source_dir : If seconds_before_delete_source_dir>=0 and fetch_code=true, this script automatically deletes 
#    the old source code directory after waiting seconds_before_delete_source_dir seconds (to give you the opportunity to cancel 
#    by pressing ctrl-C). To turn off the deletion (default behavior), set $num_seconds_before_deleting_source_dir to be negative.
#seconds_before_delete_case_dir : Similar to above, but remove the old case_scripts directory. Since create_newcase dies whenever 
#    the case_scripts directory exists, it only makes sense to use $seconds_before_delete_case_dir<0 if you want to be extra careful and 
#    only delete the case_scripts directory manually.
#seconds_before_delete_bld_dir : As above, but force the code to recompile by removing the old compiled files.
#seconds_before_delete_run_dir : As above, but the old run directory will be deleted.  This makes for a clean start.

#processor_config: Indicates what processor configuration to use.
#    1=single processor, S=small, M=medium, L=large, X1=very large, X2=very very large, CUSTOM=defined below.
#    The actual configurations for S,M,L,X1,X2 are dependent on the machine.
#model_start_type:  Specify how this script should initialize the model:  initial, continue, branch. 
#    These options are not necessarily related to the CESM run_type options.
#    'initial' means the intial files will be copied into the run directory, 
#    and the ACME run_type can be 'initial', 'hybrid', or 'restart', as specified by this script below.
#    'continue' will do a standard restart, and assumes the restart files are already in the run directory. 
#    'branch' is almost the same, but will set RUN_TYPE='branch', and other options as specified by this script below.
#    NOTE: To continue an existing simulation, it may be easier to edit env_run and [case].run manually in the 
#    case_scripts directory.  The biggest difference is that doing it with this script 
#    may delete the previous case_scripts directory, and will provide a way to pass a simulation to someone else.
#
#code_root_dir: The directory that contains (or will contain) the source code and other code files. (formerly $CCSMROOT)
#     If fetch_code=false, this is the location where the code already resides. 
#     If fetch_code=true, this is where to put the code.
#run_root_dir:  The directory which will be used for the simulation. (Replaces $CASEROOT and $CESMSCRATCHROOT in old scripts)
#     It will contain the files for setting up the simulation (case_scripts), the compiled files (build), and
#     the files used to initialize the run as well as the output of the run (run).
#     If run_root_dir is set to 'default' then this script will make an intelligent guess based on the machine.
#short_term_archive_root_dir:  The directory to put short-term archived data in (if do_short_term_archiving=true). If set to 
#     'default', this script will make an intelligent guess based on the machine.
#
# Notes: 
# 1. capitalization doesn't matter on most of the variables above because we lowercase variables before using them. 
# 2. most of the code below does things you probably never want to change. However, users will often make settings
#    in the "USER_NL" and "RUN CONFIGURATION OPTIONS" sections below.

### PROGRAMMING GUIDELINES
#
# +) The exit error numbers are sequential through the code:   
#        0-099 are before create_newcase  
#      100-199 are between create_newcase and cesm_setup
#      200-299 are between cesm_setup and case_scripts.build
#      300-399 are between case_scripts.build and case_scripts.submit
#      400-499 are after case_scripts.submit
#    If this script dies, then print out the exit code. 
#    (in csh: use 'echo $status' immediatedly after the script exits)

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#  END OF COMMON OPTIONS - you may need to change things below here to access advanced 
#  capabilities, but if you do you should know what you're doing.
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#===========================================
# DOCUMENT WHICH VERSION OF THIS SCRIPT IS BEING USED:
#===========================================
set script_ver = 1.0.19

echo ''
echo 'run_acme: ++++++++ run_acme starting ('`date`'), version '$script_ver' ++++++++'

#===========================================
# DEFINE THINGS NEEDED LATER:
#===========================================

set this_script_dir = `pwd`      #needed later to copy this run script to the run directory
alias lowercase "echo \!:1 | tr '[A-Z]' '[a-z]'"  #make function which lowercases any strings passed to it.
alias uppercase "echo \!:1 | tr '[a-z]' '[A-Z]'"  #make function which uppercases any strings passed to it.


# BASIC ERROR CHECKING
#===========================================

### Check that $machine is consistent with the machine being run on, ie $HOST.  
### The hostname often contains both machine and node names, so the following just checks that $machine appears somewhere in the name. 

set lower_case_host    = `echo "$HOST"    | tr '[A-Z]' '[a-z]'`
set lower_case_machine = `echo "$machine" | tr '[A-Z]' '[a-z]'`
if ! ( $lower_case_host =~ '*'$lower_case_machine'*' ) then
  echo 'run_acme ERROR: You requested to run on $machine='$machine' but $HOST returns '$HOST
  echo '                    If you think $machine is set correctly, please edit this script to allow this behavior.'
  echo ''
  exit 10
endif

if ( $seconds_before_delete_source_dir >= 0 && `lowercase $old_executable` == true ) then
  echo 'run_acme.csh ERROR: It is unlikely that you want to delete the source code and then use the existing compiled executable.'
  echo '                    Hence, this script will abort to avoid making a mistake.'
  echo '                    $seconds_before_delete_source_dir = '$seconds_before_delete_source_dir'      $old_executable = '$old_executable
  exit 15
endif

if ( $seconds_before_delete_bld_dir >= 0 && `lowercase $old_executable` == true ) then
  echo 'run_acme.csh ERROR: It makes no sense to delete the source-compiled code and then use the existing compiled executable.'
  echo '                    Hence, this script will abort to avoid making a mistake.'
  echo '                    $seconds_before_delete_bld_dir = '$seconds_before_delete_bld_dir'      $old_executable = '$old_executable
  exit 17
endif


#===========================================
# DOWNLOAD SOURCE CODE IF NEEDED:
#===========================================

### NOTE: you must be setup with access to the ACME repository before you can clone the repository. For access, see
###       https://acme-climate.atlassian.net/wiki/display/Docs/Installing+the+ACME+Model


if ( `lowercase $fetch_code` == true ) then
  if ( -d $code_root_dir/$tag_name ) then 
    if ( $seconds_before_delete_source_dir >= 0 ) then
      set num_seconds_until_delete = $seconds_before_delete_source_dir
      echo ''
      echo 'run_acme: Removing old code directory '$code_root_dir/$tag_name' in '$num_seconds_until_delete' seconds.'
      echo 'To abort, press ctrl-C'
      while ( ${num_seconds_until_delete} > 0 )
 	echo '  '${num_seconds_until_delete}'  seconds until deletion.'
 	sleep 1
 	@ num_seconds_until_delete = ${num_seconds_until_delete} - 1
      end
     #ls -ld $code_root_dir/$tag_name   # For testing this script.
      rm -fr $code_root_dir/$tag_name
      echo 'run_acme: Deleted '$code_root_dir/$tag_name
    else
      echo 'run_acme: ERROR: $code_root_dir = '${code_root_dir}' and seconds_before_delete_source_dir<0, '
      echo '          so dying instead of overwriting.'
      exit 20
    endif #$seconds_before_delete_source_dir >=0
  endif #$code_root_dir exists

  echo 'run_acme: Cloning repository into $tag_name = '$tag_name'  under $code_root_dir = '$code_root_dir
  mkdir -p $code_root_dir
  cd $code_root_dir
  git clone git@github.com:ACME-Climate/ACME.git $tag_name     # This will put repository, with all code, in directory $tag_name 
  cd $tag_name
  git submodule update --init

  if ( `lowercase $acme_tag` == master) then
    echo ''
    echo 'run_acme: Detaching from the master branch to avoid accidental changes to master by user.'
    git checkout --detach
  else
    echo ''
    echo 'run_acme: Checking out branch ${acme_tag} = '${acme_tag}
    git checkout ${acme_tag}       
  endif
endif

#===========================================
# SET RUN_ROOT_DIR VARIABLE
#===========================================

set case_name = ${tag_name}.${compset}.${resolution}.${machine}.${run_name}

echo ''
echo 'run_acme: $case_name        = '$case_name

#Note: Most of the time we probably want to set $run_root_dir to $RUNDIR/.. as defined in 
#cime/machines-acme/config_machines.xml. We manually specify it here because create_newcase 
#needs $run_root_dir to be passed to it in order to pre-stage the codes which use config_machines.xml. 
#Perhaps $run_root_dir could be set automatically in the future (when desired) by a clever grep of 
#config_machines.xml?

if ( `lowercase $run_root_dir` == 'default' ) then
  if ( $machine == 'edison' || $machine == 'hopper' ) then
    set run_root_dir = $SCRATCH/ACME_simulations/${case_name}
  else if (  $machine == 'titan' ) then
    set run_root_dir = ${PROJWORK}/${project}/${USER}/ACME_simulations/${case_name}
  else if (  $machine == 'cab' ) then
    set    user_name = `whoami`
    set run_root_dir = /p/lscratchd/${user_name}/ACME_simulations/${case_name}
  else
    echo 'run_acme ERROR: Default run_root_dir for  '${machine}' is unspecified. Please add specification to this script'
    exit 30
  endif
endif

if ( `lowercase $short_term_archive_root_dir` == 'default' ) then
  if ( $machine == 'edison' || $machine == 'hopper' ) then
    set short_term_archive_root_dir = $SCRATCH/archive/${case_name}
  else if (  $machine == 'titan' ) then
    set short_term_archive_root_dir = ${PROJWORK}/${project}/${USER}/archive/${case_name}
  else if (  $machine == 'cab' ) then
    set    user_name = `whoami`
    set short_term_archive_root_dir = /p/lscratchd/${user_name}/archive/${case_name}
  else
    echo 'run_acme ERROR: Default short_term_archive_root_dir for  '${machine}' is unspecified. Please add specification to this script'
    exit 32
  endif
endif


set case_scripts_dir = $run_root_dir/case_scripts
set case_build_dir   = $run_root_dir/build
set case_run_dir     = $run_root_dir/run

echo 'run_acme: $run_root_dir     = '$run_root_dir
echo 'run_acme: $case_scripts_dir = '$case_scripts_dir
echo 'run_acme: $case_build_dir   = '$case_build_dir
echo 'run_acme: $case_run_dir     = '$case_run_dir
echo ''

#===========================================
# DELETE PREVIOUS DIRECTORIES (IF REQUESTED)
#============================================

### Remove existing case_scripts directory (so it doesn't have to be done manually every time)
### Note: To turn off the deletion, set $num_seconds_until_delete to be negative.
###       To delete immediately, set $num_seconds_until_delete to be zero.

if ( -d $case_scripts_dir ) then
  if ( ${seconds_before_delete_case_dir} >= 0 ) then
    set num_seconds_until_delete = $seconds_before_delete_case_dir
    echo ''
    echo 'run_acme: Removing old $case_scripts_dir directory for '${case_name}' in '${num_seconds_until_delete}' seconds.'
    echo 'To abort, press ctrl-C'
    while ( ${num_seconds_until_delete} > 0 )
      echo '  '${num_seconds_until_delete}'  seconds until deletion.'
      sleep 1
      @ num_seconds_until_delete = ${num_seconds_until_delete} - 1
    end
 #  ls -ld $case_scripts_dir     # For testing this script.
    rm -fr $case_scripts_dir
    echo 'run_acme:  Deleted $case_scripts_dir directory for : '${case_name} 
  else
    echo 'run_acme: WARNING: $case_scripts_dir='$case_scripts_dir' exists '
    echo '          and is not being removed because seconds_before_delete_case_dir<0.'
    echo '          But create_newcase always fails when the case directory exists, so this script will now abort.'
    echo '          To fix this, either delete the case_scripts directory manually, or change seconds_before_delete_case_dir'
    exit 35
  endif
endif

### Remove existing build directory (to force a clean compile).  This is good for a new run, but not usually necessary while developing.

if ( -d $case_build_dir ) then
  if ( ${seconds_before_delete_bld_dir} >= 0 ) then
    set num_seconds_until_delete = $seconds_before_delete_bld_dir
    echo ''
    echo 'run_acme: Removing old $case_build_dir directory '${case_name}' in '${num_seconds_until_delete}' seconds.'
    echo 'To abort, press ctrl-C'
    while ( ${num_seconds_until_delete} > 0 )
      echo '  '${num_seconds_until_delete}'  seconds until deletion.'
      sleep 1
      @ num_seconds_until_delete = ${num_seconds_until_delete} - 1
    end
#   ls -ld $case_build_dir     # For testing this script.
    rm -fr $case_build_dir     
    echo 'run_acme:  Deleted $case_build_dir directory for '${case_name} 
  else
    echo 'run_acme: WARNING $case_build_dir='$case_build_dir' exists '
    echo '          and is not being removed because seconds_before_delete_bld_dir<0.'
  endif
endif

### Remove existing run directory (for a clean start).  This is good for a new run, but often not usually necessary while developing.

if ( -d $case_run_dir ) then
  if ( ${seconds_before_delete_run_dir} >= 0 ) then
    set num_seconds_until_delete = $seconds_before_delete_run_dir
    echo ''
    echo 'run_acme: Removing old $case_run_dir directory for '${case_name}' in '${num_seconds_until_delete}' seconds.'
    echo 'To abort, press ctrl-C'
    while ( ${num_seconds_until_delete} > 0 )
     echo '  '${num_seconds_until_delete}'  seconds until deletion.'
     sleep 1
     @ num_seconds_until_delete = ${num_seconds_until_delete} - 1
    end
   #ls -ld $case_run_dir     # For testing this script.
    rm -fr $case_run_dir     
    echo 'run_acme:  Deleted $case_run_dir directory for '${case_name} 
  else
    echo 'run_acme WARNING: $case_run_dir='$case_run_dir' exists '
    echo '         and is not being removed because seconds_before_delete_run_dir<0.'
  endif
endif

#=============================================================
# HANDLE STANDARD PROCESSOR CONFIGURATIONS
#=============================================================
# NOTE: Some standard PE configurations are available (S,M,L,X1,X2).  
#       If the requested configuration is 1 or CUSTOM, then set to M here, and handle later.

set lower_case = `lowercase $processor_config`
switch ( $lower_case )
  case 's':
    set std_proc_configuration = 'S'
    breaksw
  case 'm':
    set std_proc_configuration = 'M'
    breaksw
  case 'l':
    set std_proc_configuration = 'L'
    breaksw
  case 'x1':
    set std_proc_configuration = 'X1'
    breaksw
  case 'x2':
    set std_proc_configuration = 'X2'
    breaksw
  case '1':
    set std_proc_configuration = 'M'
    breaksw
  case 'custom':
    # Note: this is just a placeholder so create_newcase will work. 
    #       The actual configuration should be set under 'CUSTOMIZE PROCESSOR CONFIGURATION'
    set std_proc_configuration = 'M'
    breaksw
  default:
    echo 'run_acme ERROR: $processor_config='$processor_config' is not recognized'
    exit 40
    breaksw
endsw

#=============================================================
# HANDLE BOTH PRE-CIME AND POST-CIME CODE VERSIONS:
#=============================================================
# "cime" refers to a code restructuring. It doesn't affect our run script much because 
# the scripts called by this program generally know where to look for the codes they need.
# It does affect the location of create_newcase (requiring the logical below) and the
# amount of space before #PBS or #MSUB commands which we seek to modify via sed. 

if ( -f $code_root_dir/$tag_name/cime/scripts/create_newcase ) then    # ACME version uses CIME
    set cime_space='  '
    set shortterm_archive_script = case_scripts.st_archive
    set longterm_archive_script =  case_scripts.lt_archive
    cd $code_root_dir/$tag_name/cime/scripts
else if ( -f $code_root_dir/$tag_name/scripts/create_newcase ) then    # pre-CIME version of ACME
    set cime_space=' '
    set shortterm_archive_script = st_archive
    set longterm_archive_script = case_scripts.l_archive
    cd $code_root_dir/$tag_name/scripts/
else                                                                   # No version of create_newcase found
  echo 'run_acme ERROR: create_newcase script cannot be found in '
  echo '               '$code_root_dir/$tag_name/cime/scripts
  echo '               or '$code_root_dir/$tag_name/scripts
  echo '                This is most likely because fetch_code should be true.'
  echo '                At the moment, $fetch_code = '$fetch_code
  exit 45  
endif 

#=============================================================
# CREATE CASE_SCRIPTS DIRECTORY AND POPULATE WITH NEEDED FILES
#=============================================================

echo ''
echo 'run_acme: -------- Starting create_newcase --------'
echo ''

./create_newcase -case $case_scripts_dir  \
		 -mach $machine           \
		 -compset $compset        \
		 -res $resolution         \
		 -project $project        \
		 -pecount $std_proc_configuration

cd $case_scripts_dir

echo ''
echo 'run_acme: -------- Finished create_newcase --------'
echo ''

#NOTE: Details of the configuration setup by create_newcase are in $case_scripts_dir/env_case.xml, which should NOT be edited.  
#      It will be used by cesm_setup (formerly 'configure -case'). 
#NOTE: To get verbose output from create_newcase, add '-v' to the argument list. 

#============================================
# COPY THIS SCRIPT TO THE CASE DIRECTORY TO ENSURE PROVENANCE
#============================================
#NOTE: $0 contains the name of this script, and is a feature of csh.

mkdir -p $case_scripts_dir/build_and_run_script_provenance
set script_provenance_name = $0.`date +%F_%T_%Z`
cp -f $this_script_dir/$0 $case_scripts_dir/build_and_run_script_provenance/$script_provenance_name

#============================================
# SPECIFY BUILD AND RUN DIRECTORIES
#============================================

# NOTE: env_build.xml is used by cesm_setup (despite the name), so set the directories here.

./xmlchange -file env_build.xml -id EXEROOT -val "${case_build_dir}"
./xmlchange -file env_run.xml -id RUNDIR -val "${case_run_dir}"

#=============================================
# CUSTOMIZE PROCESSOR CONFIGURATION
# ============================================
#NOTE: Changes to the processor configuration should be done by an expert.  \
#      Not all possible options will work. 

if ( `lowercase $processor_config` == '1' ) then

  # NOTE: xmlchange won't work with shell variables for the id, so we have to write it out in full.
  set ntasks = 1
  set nthrds = 1
  foreach ntasks_name (  NTASKS_ATM  NTASKS_LND  NTASKS_ICE  NTASKS_OCN  NTASKS_CPL  NTASKS_GLC  NTASKS_ROF  NTASKS_WAV )
    ./xmlchange -file env_mach_pes.xml -id $ntasks_name  -val $ntasks
  end

  foreach nthrds_name (  NTHRDS_ATM  NTHRDS_LND  NTHRDS_ICE  NTHRDS_OCN  NTHRDS_CPL  NTHRDS_GLC  NTHRDS_ROF  NTHRDS_WAV )
    ./xmlchange -file env_mach_pes.xml -id $nthrds_name  -val $nthrds
  end

else if ( `lowercase $processor_config` == 'custom' ) then

  echo 'run_acme: Setting custom processor configuration, because $processor_config = '$processor_config 
###   This space is to allow a custom processor configuration to be defined. 
###   If your layout will be useful to other people, then please get it added to the standard 
###   configurations in the ACME repository.

echo 'run_acme: This processor configuration is for the A_B1850 compset on titan (2015-11-25)'
cat <<EOF > env_mach_pes.xml
<?xml version="1.0"?>

<config_definition>

<!-- ========================================================================== -->
<!--                                                                            -->
<!--      These variables CANNOT be modified once cesm_setup has been           -->
<!--      invoked without first invoking cesm_setup -clean.                     -->
<!--                                                                            -->
<!-- component task/thread settings                                             -->
<!-- if the user wants to change the values below after ./cesm_setup, run       -->
<!--    ./cesm_setup -clean                                                     -->
<!--    ./cesm_setup                                                            -->
<!--  to reset the pes for the run                                              -->
<!--                                                                            -->
<!--  NTASKS are the total number of MPI tasks                                  -->
<!--  NTHRDS are the number of OpenMP threads per MPI task                      -->  
<!--  ROOTPE is the global mpi task associated with the root task               -->
<!--         of that component                                                  -->     
<!--  PSTRID is the stride of MPI tasks across the global                       -->
<!--         set of pes (for now this is set to 1)                              -->
<!--  NINST is the number of instances of the component (will be spread         -->
<!--        evenly across NTASKS)                                               -->
<!--                                                                            -->
<!--  for example, for a setting with                                           -->  
<!--    NTASKS = 8                                                              -->
<!--    NTHRDS = 2                                                              -->
<!--    ROOTPE = 32                                                             -->
<!--    NINST  = 2                                                              -->
<!--  the MPI tasks would be placed starting on global pe 32                    -->
<!--  and each pe would be threaded 2-ways for this component.                  -->  
<!--  These tasks will be divided amongst both instances (4 tasks each).        -->
<!--                                                                            -->
<!--  Note: PEs that support threading never have an MPI task associated        -->
<!--    with them for performance reasons.  As a result, NTASKS and ROOTPE      -->
<!--    are relatively independent of NTHRDS and they determine                 -->
<!--    the layout of mpi processors between components.  NTHRDS is used        -->
<!--    to determine how those mpi tasks should be placed across the machine.   -->
<!--                                                                            -->
<!--  The following values should not be set by the user since they'll be       --> 
<!--  overwritten by scripts.                                                   -->
<!--    TOTALPES                                                                -->
<!--    CCSM_PCOST                                                              -->
<!--    CCSM_ESTCOST                                                            -->
<!--    PES_LEVEL                                                               -->
<!--    MAX_TASKS_PER_NODE                                                      -->
<!--    PES_PER_NODE                                                            -->
<!--    CCSM_TCOST                                                              -->
<!--    CCSM_ESTCOST                                                            -->
<!--                                                                            -->
<!--  The user can copy env_mach_pes.xml from another run, but they'll need to  -->
<!--  do the following                                                          -->
<!--    ./cesm_setup -clean                                                     -->
<!--    ./cesm_setup                                                            -->
<!--    ./CASE.build                                                            -->
<!--                                                                            -->
<!-- ========================================================================== -->

<entry id="NTASKS_ATM"   value="675"  />    
<entry id="NTHRDS_ATM"   value="2"  />    
<entry id="ROOTPE_ATM"   value="0"  />    
<entry id="NINST_ATM"   value="1"  />    
<entry id="NINST_ATM_LAYOUT"   value="concurrent"  />    

<entry id="NTASKS_LND"   value="164"  />    
<entry id="NTHRDS_LND"   value="2"  />    
<entry id="ROOTPE_LND"   value="512"  />    
<entry id="NINST_LND"   value="1"  />    
<entry id="NINST_LND_LAYOUT"   value="concurrent"  />    

<entry id="NTASKS_ICE"   value="512"  />    
<entry id="NTHRDS_ICE"   value="2"  />    
<entry id="ROOTPE_ICE"   value="0"  />    
<entry id="NINST_ICE"   value="1"  />    
<entry id="NINST_ICE_LAYOUT"   value="concurrent"  />    

<entry id="NTASKS_OCN"   value="128"  />    
<entry id="NTHRDS_OCN"   value="2"  />    
<entry id="ROOTPE_OCN"   value="676"  />    
<entry id="NINST_OCN"   value="1"  />    
<entry id="NINST_OCN_LAYOUT"   value="concurrent"  />    

<entry id="NTASKS_CPL"   value="512"  />    
<entry id="NTHRDS_CPL"   value="2"  />    
<entry id="ROOTPE_CPL"   value="0"  />    

<entry id="NTASKS_GLC"   value="1"  />    
<entry id="NTHRDS_GLC"   value="2"  />    
<entry id="ROOTPE_GLC"   value="512"  />    
<entry id="NINST_GLC"   value="1"  />    
<entry id="NINST_GLC_LAYOUT"   value="concurrent"  />    

<entry id="NTASKS_ROF"   value="164"  />    
<entry id="NTHRDS_ROF"   value="2"  />    
<entry id="ROOTPE_ROF"   value="512"  />    
<entry id="NINST_ROF"   value="1"  />    
<entry id="NINST_ROF_LAYOUT"   value="concurrent"  />    

<entry id="NTASKS_WAV"   value="512"  />    
<entry id="NTHRDS_WAV"   value="2"  />    
<entry id="ROOTPE_WAV"   value="0"  />    
<entry id="NINST_WAV"   value="1"  />    
<entry id="NINST_WAV_LAYOUT"   value="concurrent"  />    

<entry id="PSTRID_ATM"   value="1"  />    
<entry id="PSTRID_LND"   value="1"  />    
<entry id="PSTRID_ICE"   value="1"  />    
<entry id="PSTRID_OCN"   value="1"  />    
<entry id="PSTRID_CPL"   value="1"  />    
<entry id="PSTRID_GLC"   value="1"  />    
<entry id="PSTRID_ROF"   value="1"  />    
<entry id="PSTRID_WAV"   value="1"  />    

<entry id="TOTALPES"   value="1608"  />    
<entry id="PES_LEVEL"   value="0"  />    
<entry id="MAX_TASKS_PER_NODE"   value="16"  />    
<entry id="PES_PER_NODE"   value="\$MAX_TASKS_PER_NODE"  />    
<entry id="COST_PES"   value="0"  />    
<entry id="CCSM_PCOST"   value="-3"  />    
<entry id="CCSM_TCOST"   value="0"  />    
<entry id="CCSM_ESTCOST"   value="1"  />    

</config_definition>
EOF

### The following couple of lines are for when no custom configuration is set (eg, in the archived version)
#    echo 'run_acme: Custom processor configuration not defined.  Please edit this script.'
#    exit 150

endif

#============================================
# COMPONENT CONFIGURATION OPTIONS
#============================================

#NOTE:  This section is for making specific component configuration selections.
#NOTE:  CAM_NAMELIST_OPTS should NOT be used.  Instead, use the user_nl section after case_scripts.build

#./xmlchange -file env_build.xml -id CAM_CONFIG_OPTS -val "-phys cam5 -chem linoz_mam3"

#============================================
# CONFIGURE
#============================================

#note configure -case turned into cesm_setup in cam5.2

echo ''
echo 'run_acme: -------- Starting cesm_setup --------'
echo ''

./cesm_setup

echo ''
echo 'run_acme: -------- Finished cesm_setup  --------'
echo ''


#============================================
# SET BUILD OPTIONS
#============================================

if ( `uppercase $debug_compile` != 'TRUE' && `uppercase $debug_compile` != 'FALSE' ) then
  echo 'run_acme ERROR: $debug_compile can be true or false but is instead '$debug_compile
  exit 220
endif

if ( `lowercase $machine` == 'edison' && `uppercase $debug_compile` == 'TRUE' ) then
  echo 'run_acme ERROR: Edison currently has a compiler bug and crashes when compiling in debug mode (Nov 2015)'
  exit 222  
endif

./xmlchange -file  env_build.xml -id DEBUG -val `uppercase $debug_compile`

#Modify/uncomment the next line to change the number of processors used to compile.
#./xmlchange -file  env_build.xml -id GMAKE_J -val 4

#============================================
# SET MODEL INPUT DATA DIRECTORY
#============================================

# The model input data directory should default to the managed location for your system.
# However, if this does not work properly, or if you want to use your own data, then 
# that should be setup here (before case_scripts.build because it checks the necessary files exist)

# NOTE: This code handles the case when the default location is wrong.   
#       If you want to use your own files then this code will need to be modified.
 
#set input_data_dir = '/project/projectdirs/ccsm1/inputdata'    # Hopper
#if ( -d  $input_data_dir ) then
#  ./xmlchange -file env_run.xml -id DIN_LOC_ROOT -val $input_data_dir
#else
#  echo 'run_acme ERROR: User specified input data directory does NOT exist. $input_data_dir = '$input_data_dir
#  exit 270
#endif


#=============================================
# CREATE NAMELIST MODIFICATION FILES (USER_NL)
#=============================================

# Append desired changes to the default namelists generated by the build process.
#
# NOTE: It doesn't matter which namelist an option is in for any given component.  The system will sort it out.
# NOTE: The user_nl files need to be set before the build, because case_scripts.build also checks whether input files exist.
# NOTE: $atm_output_freq and $records_per_atm_output_file are so commonly used, that they are set in the options at the top of this script.
cat <<EOF >> user_nl_cam
 nhtfrq = $atm_output_freq
 mfilt  = $records_per_atm_output_file
EOF

### NOTES ON COMMON NAMELIST OPTIONS ###

### ATMOSPHERE NAMELIST ###

#NHTFRQ : The frequency with which the atmosphere writes its output.   
#    0=monthly, +N=every N timesteps,  -N=every N hours 
#    For more information:   http://www.cesm.ucar.edu/models/atm-cam/docs/usersguide/node45.html 
#MFILT : The number of time records in each netCDF output file from the atmosphere model.
#    If mfilt is 0, then there will only be one time record per file.
#NOTE:  nhtfrq and mfilt can be a comma-separated list of numbers, corresponding to the 'history tapes' defined in the namelist.

#============================================
# BUILD CODE
#============================================

#NOTE: This will either build the code (if needed and $old_executable=false) or copy an existing executable.

echo ''
echo 'run_acme: -------- Starting Build --------'
echo ''

if ( `lowercase $old_executable` == false ) then
    ./case_scripts.build
else if ( `lowercase $old_executable` == true ) then
    if ( -x $case_build_dir/cesm.exe ) then       #use executable previously generated for this case_name.
	echo 'run_acme: Skipping build because $old_executable='$old_executable
        echo ''
	#create_newcase sets BUILD_COMPLETE to FALSE. By using an old executable you're certifying 
	#that you're sure the old executable is consistent with the new case... so be sure you're right!
        #NOTE: This is a risk to provenance, so this feature may be removed in the future [PJC]. 
        #      However the build system currently rebuilds several files every time which takes many minutes.
        #      When this gets fixed the cost of deleting this feature will be minor. 
        #      (Also see comments for user options at top of this file.)
        echo 'run_acme: WARNING: Setting BUILD_COMPLETE = TRUE.  This is a little risky, but trusting the user.'
        ./xmlchange -file env_build.xml -id BUILD_COMPLETE -val TRUE
    else
	echo 'run_acme ERROR: $old_executable='$old_executable' but  $case_build_dir/cesm.exe='$case_build_dir/cesm.exe
	echo '                does not exist or is not an executable'
	exit 297
    endif
else
    if ( -x $old_executable ) then #if absolute pathname exists and is executable.
	#create_newcase sets BUILD_COMPLETE to FALSE. By copying in an old executable you're certifying 
	#that you're sure the old executable is consistent with the new case... so be sure you're right!
        #NOTE: This is a risk to provenance, so this feature may be removed in the future [PJC]. 
        #      However the build system currently rebuilds several files every time which takes many minutes.
        #      When this gets fixed the cost of deleting this feature will be minor. 
        #      (Also see comments for user options at top of this file.)
        echo 'run_acme: WARNING: Setting BUILD_COMPLETE = TRUE.  This is a little risky, but trusting the user.'
        ./xmlchange -file env_build.xml -id BUILD_COMPLETE -val TRUE
        cp -fp $old_executable $case_build_dir/
    else
	echo 'run_acme ERROR: $old_executable='$old_executable' does not exist or is not an executable file.'
	exit 297
    endif
endif

echo ''
echo 'run_acme: -------- Finished Build --------'
echo ''


#============================================
# QUEUE OPTIONS
#============================================
# Edit the default queue and batch job lengths. 

#HINT: To change queue after run submitted, the following works on most machines:
#qalter -lwalltime=00:29:00 <run_descriptor>
#qalter -W queue=debug <run_descriptor>

#NOTE: we are currently not modifying the archiving scripts to run in debug queue when $debug_queue=true
#      under the assumption that if you're debugging you shouldn't be archiving.

#NOTE: there was 1 space btwn MSUB or PBS and the commands before cime and there are 2 spaces
#      in post-cime versions. ${cime_space} handles this difference.

set machine = `lowercase $machine`
echo 'Setting batch queue options for $machine = '$machine'  with $debug_queue = '$debug_queue
if ( `lowercase $debug_queue` == 'true' ) then
  if ( $machine == 'cab' ) then
    sed -i /"#MSUB${cime_space}-q"/c"#MSUB  -q pdebug"                     case_scripts.run
    sed -i /"#MSUB${cime_space}-l walltime"/c"#MSUB  -l walltime=00:30:00" case_scripts.run
  else if ( $machine == 'hopper' || $machine == 'edison' ) then
    sed -i /"#PBS${cime_space}-q"/c"#PBS  -q debug"                        case_scripts.run
    sed -i /"#PBS${cime_space}-l walltime"/c"#PBS  -l walltime=00:30:00"   case_scripts.run
  else if ( $machine == 'titan' ) then
    sed -i /"#PBS${cime_space}-q"/c"#PBS  -q debug"                        case_scripts.run
    sed -i /"#PBS${cime_space}-l walltime"/c"#PBS  -l walltime=00:30:00"   case_scripts.run
  else
    echo 'run_acme ERROR: This script does not know name of debug queue or walltime limits on $machine='$machine
    exit  310      
  endif
else #if NOT to be run in debug_queue
  if ( $machine == 'cab' ) then
    sed -i /"#MSUB${cime_space}-q"/c"#MSUB  -q pbatch"                     case_scripts.run
    sed -i /"#MSUB${cime_space}-l walltime"/c"#MSUB  -l walltime=02:00:00" case_scripts.run
  else if ( $machine == 'hopper' || $machine == 'edison' ) then
    sed -i /"#PBS${cime_space}-q"/c"#PBS  -q regular"                      case_scripts.run
    sed -i /"#PBS${cime_space}-l walltime"/c"#PBS  -l walltime=02:00:00"   case_scripts.run
  else if ( $machine == 'titan' ) then
    sed -i /"#PBS${cime_space}-q"/c"#PBS  -q batch"                        case_scripts.run
    sed -i /"#PBS${cime_space}-l walltime"/c"#PBS  -l walltime=02:00:00"   case_scripts.run
  else
    echo 'run_acme WARNING: This script does not have defaults for batch queue and run time on $machine='$machine
    echo '                  Assuming default ACME values.'
  endif
endif

#============================================
# BATCH JOB OPTIONS
#============================================

# Set options for batch scripts (see above for queue and batch time, which are handled separately)

# NOTE: This also modifies the short-term and long-term archiving scripts.
# NOTE: We want the batch job log to go into a sub-directory of case_scripts (to avoid it getting clogged up)

mkdir -p run.output      ### Make directory that stdout and stderr will go into.
 
if ( $machine == 'hopper' || $machine == 'edison' ) then
    sed -i /"#PBS${cime_space}-N"/c"#PBS  -N ${case_name}"                               case_scripts.run
    sed -i /"#PBS${cime_space}-A"/c"#PBS  -A ${project}"                                 case_scripts.run
    sed -i /"#PBS${cime_space}-j oe"/a'#PBS  -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}' case_scripts.run
    
    sed -i /"#PBS${cime_space}-N"/c"#PBS  -N st_archive.${case_name}"                    $shortterm_archive_script
    sed -i /"#PBS${cime_space}-j oe"/a'#PBS  -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}' $shortterm_archive_script
    sed -i /"#PBS${cime_space}-N"/c"#PBS  -N lt_archive.${case_name}"                    $longterm_archive_script
    sed -i /"#PBS${cime_space}-j oe"/a'#PBS  -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}' $longterm_archive_script

else if ( $machine == 'titan' ) then
    sed -i /"#PBS${cime_space}-N"/c"#PBS  -N ${case_name}"                               case_scripts.run
    sed -i /"#PBS${cime_space}-A"/c"#PBS  -A ${project}"                                 case_scripts.run
    sed -i /"#PBS${cime_space}-j oe"/a'#PBS  -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}' case_scripts.run
    
    sed -i /"#PBS${cime_space}-N"/c"#PBS  -N st_archive.${case_name}"                    $shortterm_archive_script
    sed -i /"#PBS${cime_space}-j oe"/a'#PBS  -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}' $shortterm_archive_script
    sed -i /"#PBS${cime_space}-N"/c"#PBS  -N lt_archive.${case_name}"                    $longterm_archive_script
    sed -i /"#PBS${cime_space}-j oe"/a'#PBS  -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}' $longterm_archive_script

else
    echo 'run_acme WARNING: This script does not have batch directives for $machine='$machine
    echo '                  Assuming default ACME values.'
endif

#============================================
# SETUP SHORT AND LONG TERM ARCHIVING
#============================================

./xmlchange -file env_run.xml -id DOUT_S    -val `uppercase $do_short_term_archiving` 

./xmlchange -file env_run.xml -id DOUT_L_MS -val `uppercase $do_long_term_archiving`

./xmlchange -file env_run.xml -id DOUT_S_ROOT -val $short_term_archive_root_dir

# DOUT_L_MSROOT is the directory in your account on the local mass storage system (typically an HPSS tape system)
./xmlchange -file env_run.xml -id DOUT_L_MSROOT -val "ACME_simulation_output/${case_name}"




#============================================
# COUPLER HISTORY OUTPUT
#============================================

#./xmlchange -file env_run.xml -id HIST_OPTION -val ndays
#./xmlchange -file env_run.xml -id HIST_N      -val 1


#=======================================================
# SETUP SIMULATION LENGTH AND FREQUENCY OF RESTART FILES
#=======================================================

#SIMULATION LENGTH
./xmlchange -file env_run.xml -id STOP_OPTION -val `lowercase $stop_units` 
./xmlchange -file env_run.xml -id STOP_N      -val $stop_num

#RESTART FREQUENCY
./xmlchange -file env_run.xml -id REST_OPTION -val `lowercase $restart_units` 
./xmlchange -file env_run.xml -id REST_N      -val $restart_num

#NUMBER OF TIMES TO RESUBMIT SIMULATION
./xmlchange -file env_run.xml -id RESUBMIT    -val $num_resubmits


#============================================
# SETUP SIMULATION INITIALIZATION
#============================================

echo ''
echo 'run_acme: $model_start_type = '${model_start_type}'  (This is NOT necessarily related to RUN_TYPE)'

set model_start_type = `lowercase $model_start_type`
if ( $model_start_type == 'initial' ) then
  ### 'initial' run: cobble together files, with RUN_TYPE= 'startup' or 'hybrid'.
  ./xmlchange -file env_run.xml -id RUN_TYPE -val "startup"
  ./xmlchange -file env_run.xml -id CONTINUE_RUN -val "FALSE"
  
  ### Copy over initial condition files to run directory (if not in the standard set of input files).  
  
#  set initial_files_dir = $PROJWORK/cli107/sulfur_DOE_restarts/2deg_1850_0011-01-01-00000
#  cp -fpu $initial_files_dir/* ${case_run_dir}
    
else if ( $model_start_type == 'continue' ) then

  ### This is a standard restart.

  ./xmlchange -file env_run.xml -id CONTINUE_RUN -val "TRUE"

  ### Copy over restart files to run directory (if not already in the run directory).  
  
#  set restart_files_dir = $PROJWORK/cli107/sulfur_DOE_restarts/2deg_1850_0011-01-01-00000
#  cp -fpu $restart_files_dir/* ${case_run_dir}
    
else if ( $model_start_type == 'branch' ) then

  ### Branch runs are the same as restarts, except that the history output can be changed 
  ### (eg to add new variables or change output frequency). 

#  set restart_files_dir = $PROJWORK/cli107/sulfur_DOE_restarts/2deg_1850_0011-01-01-00000
#  cp -fpu $restart_files_dir/* ${case_run_dir}
    
  set rpointer_filename = "${case_run_dir}/rpointer.drv"
  if ( ! -f $rpointer_filename ) then
    echo "run_acme: ERROR rpointer file doesn't exist. It is needed to extract RUN_REFDATE."
    echo "              This may be because you should set model_start_type to 'initial' or 'continue' rather than 'branch'."
    exit 370
  endif 
  set restart_filedate = `cat $rpointer_filename`
  set restart_filedate = ${restart_filedate:r:e:s/-00000//}      # Extract out the date (yyyy-mm-dd).
  echo 'run_acme: $restart_filedate = '$restart_filedate
  
  set restart_case_name = 'CASE_NAME_FOR_RUN_THAT_GENERATED_THE_RESTART_FILES'
  ./xmlchange -file env_run.xml -id RUN_TYPE -val "branch"
  ./xmlchange -file env_run.xml -id RUN_REFCASE -val $restart_case_name   
  ./xmlchange -file env_run.xml -id RUN_REFDATE -val $restart_filedate    # Model date of restart file
  ./xmlchange -file env_run.xml -id CONTINUE_RUN -val "FALSE"
  ./xmlchange -file env_run.xml -id BRNCH_RETAIN_CASENAME -val "FALSE"  ## Only TRUE if you really want to continue the run with the same name!!

else

  echo 'run_acme ERROR: $model_start_type = '${model_start_type}' is unrecognized.   Exiting.'
  exit 380

endif   


#============================================
# RUN CONFIGURATION OPTIONS
#============================================

#NOTE:  This section is for making specific changes to the run options (ie env_run.xml).

#=================================================
# SUBMIT THE SIMULATION TO THE RUN QUEUE
#=================================================
#note: to run the model in the totalview debugger, 
# cd $case_run_dir
# totalview srun -a -n <number of procs> -p <name of debug queue> ../bld/cesm.exe
# where you may need to change srun to the appropriate submit command for your system, etc.


echo ''
echo 'run_acme: -------- Starting Submission to Run Queue --------'
echo ''

if ( `lowercase $submit_run` == 'true' ) then
    ./case_scripts.submit
else
    echo 'run_acme: Run NOT submitted because $submit_run = '$submit_run
endif

echo ''
echo 'run_acme: -------- Finished Submission to Run Queue --------'
echo ''

#=================================================
# DO POST-SUBMISSION THINGS (IF ANY)
#=================================================

# Actions after the run submission go here. 

echo ''
echo 'run_acme: ++++++++ run_acme Completed ('`date`') ++++++++'
echo ''

#**********************************************************************************
### --- end of script - there are no commands beyond here, just useful comments ---
#**********************************************************************************

### -------- Version information --------
# 1.0.0    2015-11-19    Initial version.  Tested on Titan. (PJC)
# 1.0.1    2015-11-19    Fixed bugs and added features  for Hopper. (PJC)
# 1.0.2    2015-11-19    Modified to conform with ACME script standards. PJC)
# 1.0.3    2015-11-23    Modified to include Peter's ideas (PMC)
# 1.0.4    2015-11-23    Additional modification based on discusion with Peter and Chris Golaz. (PJC)
# 1.0.5    2015-11-23    Tweaks for Titan (PJC)
# 1.0.6    2015-11-23    Fixed some error messages, plus some other minor tweaks. (PJC)
# 1.0.7    2015-11-24    Fixed bug for setting batch options (CIME adds an extra space than before). (PJC)
#                        Also, removed GMAKE_J from option list (left it as a comment for users to find).
# 1.0.8    2015-11-24    Merged old_executable stuff and changed to loop over xmlchange statements for 
#                        single proc run (PMC)
# 1.0.9    2015-11-25    Added support for using pre-cime code versions, fixed some bugs (PMC)
# 1.0.10   2015-11-25    Cosmetic changes to the edited batch script, and improved comments. (PJC)                    
# 1.0.11   2015-11-25    Fixed bug with naming of st_archive and lt_archive scripts.  Also cosmetic improvements (PJC).
# 1.0.12   2015-11-25    changed name of variable orig_dir/dir_of_this_script to "this_script_dir" and removed options
#                        for old_executable=true and seconds_before_delete_case_dir<0 because they were provenance-unsafe.(PMC)
# 1.0.13   2015-11-25    Merged changes from PMC with cosmetic changes from PJC.   
#                        Also, reactivated old_executable=true, because the model recompiles many files unnecessarily.  (PJC)
# 1.0.14   2015-11-25    Added custom PE configuration so the ACME pre-alpha code will work on Titan for Chris Golaz.   (PJC)
#                        Fixed $cime_space bug introduced in 1.0.10 (PJC) 
# 1.0.15   2015-11-25    Fixed bug with old_executable=true (PJC)
# 1.0.16   2015-11-30    Added $machine to the case_name (PJC)
# 1.0.17   2015-11-30    Added date to filename when archiving this script (so previous version doesn't get overwritten) (PJC)
# 1.0.18   2015-11-30    Will now automatically use 'git checkout --detach' so users cannot alter master by accident (PJC)

# NOTE:  PJC = Philip Cameron-Smith,  PMC = Peter Caldwell
             
###Example sed commands
#============================
###To delete a line
#sed -i /'fstrat_list'/d $namelists_dir/cam.buildnml.csh

### To replace part of a line
#sed -i s/"#PBS -q regular"/"#PBS -q debug"/ ${case_name}.run

### To replace a whole line based on a partial match
#sed -i /"#PBS -N"/c"#PBS -N ${run_job_name}" ${case_name}.run

### To add a new line:
# sed -i /"PBS -j oe"/a"#PBS -o run.output/${PBS_JOBNAME}.o${PBS_JOBID}" ${case_name}.run

