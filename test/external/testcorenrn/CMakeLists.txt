# Set up the tests from the testcorenrn external repository
include(NeuronTestHelper)
set(direct_tests netstimdirect)
set(spike_comparison_tests
    bbcore
    gf
    patstim
    vecplay
    watch
    vecevent)

set(modfiles mod/Gfluct3.mod mod/hhwatch.mod mod/nacum.mod mod/vecevent.mod)
if(NOT CORENRN_ENABLE_NMODL OR NOT CORENRN_ENABLE_GPU)
  # These .mod files cannot be compiled with NMODL + OpenACC/GPU because of
  # https://github.com/BlueBrain/nmodl/issues/311
  list(APPEND modfiles mod/hhderiv.mod mod/hhkin.mod)
  # These tests depend on the modfiles on the line above.
  list(APPEND spike_comparison_tests conc deriv kin)
endif()

# Set the number of MPI ranks to use for each test. Assume 1 if not explicitly specified.
set(mpi_ranks_gf 2)
set(mpi_ranks_watch 2)
set(mpi_ranks_patstim 2)
set(mpi_ranks_vecplay 2)
set(mpi_ranks_vecevent 4)
set(mpi_ranks_netstimdirect 2)

# Flag which tests include `insert hh` and may, therefore, be sensitive to differences between
# NEURON and CoreNEURON when neither CoreNEURON nor modfile compatibility is enabled
set(test_gf_neuron_requirements mod_compatibility)
set(test_patstim_neuron_requirements mod_compatibility)
set(test_vecplay_neuron_requirements mod_compatibility)

# Flag which tests make use of Random123 and cannot, therefore, be run on the CPU in a GPU-enabled
# build (see https://github.com/BlueBrain/CoreNeuron/issues/345).
set(test_gf_coreneuron_cpu_conflicts gpu) # CoreNEURON-on-CPU test conflicts with GPU being enabled
                                          # in the build

if(${CORENRN_ENABLE_GPU})
  set(gpu_args_online -c arg_coreneuron_gpu=1)
  set(gpu_args_offline --gpu)
endif()
# Run tests that require separate runs of NEURON and CoreNEURON to compare their spikes only
foreach(test ${spike_comparison_tests})
  if(DEFINED mpi_ranks_${test})
    set(num_ranks ${mpi_ranks_${test}})
  else()
    set(num_ranks 1)
  endif()
  nrn_add_test_group(
    NAME testcorenrn_${test}
    SUBMODULE tests/testcorenrn
    MODFILE_PATTERNS ${modfiles}
    SCRIPT_PATTERNS common.hoc defvar.hoc test${test}.hoc
    OUTPUT asciispikes::out${test}.dat)
  # Set up a test that runs the simulation using NEURON.
  nrn_add_test(
    GROUP testcorenrn_${test}
    NAME neuron
    REQUIRES mpi ${test_${test}_neuron_requirements}
    PROCESSORS ${num_ranks}
    COMMAND
      OMP_NUM_THREADS=1 HOC_LIBRARY_PATH=. ${MPIEXEC_NAME} ${MPIEXEC_NUMPROC_FLAG} ${num_ranks}
      ${MPIEXEC_OVERSUBSCRIBE} ${MPIEXEC_PREFLAGS} special ${MPIEXEC_POSTFLAGS} -mpi -c
      arg_tstop=100 test${test}.hoc)
  # Set up tests that run the simulation using CoreNEURON. In principle we run all combinations of
  # [online, offline]*[CPU, GPU], but some of these may be disabled.
  foreach(processor gpu cpu)
    # Set up a test that runs the simulation using CoreNEURON's online mode
    if(NOT "${test}" STREQUAL "patstim")
      # Exclude the patstim test from running via CoreNEURON online mode
      nrn_add_test(
        GROUP testcorenrn_${test}
        NAME coreneuron_${processor}_online
        REQUIRES coreneuron mpi python ${processor}
        CONFLICTS ${test_${test}_coreneuron_${processor}_conflicts}
        PROCESSORS ${num_ranks}
        COMMAND
          OMP_NUM_THREADS=1 HOC_LIBRARY_PATH=. ${MPIEXEC_NAME} ${MPIEXEC_NUMPROC_FLAG} ${num_ranks}
          ${MPIEXEC_OVERSUBSCRIBE} ${MPIEXEC_PREFLAGS} special ${MPIEXEC_POSTFLAGS} -mpi -c
          arg_tstop=100 -c arg_coreneuron=1 ${${processor}_args_online} test${test}.hoc)
    endif()
    # This is a workaround to reduce the number of MPI ranks in the GPU version of the patstim test
    # and, we hope, avoid https://github.com/BlueBrain/CoreNeuron/issues/563
    set(local_mpi_ranks ${num_ranks})
    set(extra_args)
    if("${test}" STREQUAL "patstim")
      list(APPEND extra_args --pattern patstim.spk)
      if("${processor}" STREQUAL "gpu")
        set(local_mpi_ranks 1)
      endif()
    endif()
    # Set up a test that runs the simulation using CoreNEURON's offline mode. First we must run
    # NEURON and tell it to dump the model without simulating it.
    nrn_add_test(
      GROUP testcorenrn_${test}
      NAME coreneuron_${processor}_offline
      REQUIRES coreneuron mpi ${processor}
      CONFLICTS ${test_${test}_coreneuron_${processor}_conflicts}
      PROCESSORS ${local_mpi_ranks}
      PRECOMMAND OMP_NUM_THREADS=1
                 HOC_LIBRARY_PATH=.
                 ${MPIEXEC_NAME}
                 ${MPIEXEC_NUMPROC_FLAG}
                 ${local_mpi_ranks}
                 ${MPIEXEC_OVERSUBSCRIBE}
                 ${MPIEXEC_PREFLAGS}
                 special
                 ${MPIEXEC_POSTFLAGS}
                 -mpi
                 -c
                 arg_tstop=100
                 -c
                 arg_dump_coreneuron_model=1
                 test${test}.hoc
      COMMAND
        OMP_NUM_THREADS=1 ${MPIEXEC_NAME} ${MPIEXEC_NUMPROC_FLAG} ${local_mpi_ranks}
        ${MPIEXEC_OVERSUBSCRIBE} ${MPIEXEC_PREFLAGS} special-core ${MPIEXEC_POSTFLAGS} -d coredat
        --mpi -e 100 ${extra_args} ${${processor}_args_offline}
      OUTPUT asciispikes::out.dat)
  endforeach()
  nrn_add_test_group_comparison(
    GROUP testcorenrn_${test}
    REFERENCE_OUTPUT asciispikes::external/tests/testcorenrn/reference/out_${test}.spk)
endforeach()

# Run the direct_tests that compare internally NEURON and CoreNEURON simulations
foreach(test ${direct_tests})
  if(DEFINED mpi_ranks_${test})
    set(num_ranks ${mpi_ranks_${test}})
  else()
    set(num_ranks 1)
  endif()
  nrn_add_test_group(
    NAME testcorenrn_${test}
    SUBMODULE tests/testcorenrn
    MODFILE_PATTERNS ${modfiles}
    SCRIPT_PATTERNS common.hoc defvar.hoc test${test}.hoc
    OUTPUT asciispikes::out${test}.dat)
  nrn_add_test(
    GROUP testcorenrn_${test}
    NAME direct
    REQUIRES coreneuron mpi python
    PROCESSORS ${num_ranks}
    COMMAND
      HOC_LIBRARY_PATH=. ${MPIEXEC_NAME} ${MPIEXEC_NUMPROC_FLAG} ${num_ranks}
      ${MPIEXEC_OVERSUBSCRIBE} ${MPIEXEC_PREFLAGS} special ${MPIEXEC_POSTFLAGS} -mpi -c
      arg_tstop=100 test${test}.hoc)
  nrn_add_test_group_comparison(
    GROUP testcorenrn_${test}
    REFERENCE_OUTPUT asciispikes::external/tests/testcorenrn/reference/out_${test}.spk)
endforeach()
