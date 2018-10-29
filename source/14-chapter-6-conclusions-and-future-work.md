
#Conclusions and Future Work

\todo{is this list summarised in this section? Can we think of additional contributions?}

* extension of Dwarfs
* development of AIWC analysis tool
* addition of new metrics
* feature space analysis of all dwarfs and potential clustering of application types
* detailed data gathering for dwarfs on range of hardware
* analysis to determine if feature space types map to particular hardware


The development of EOD results in a reliable benchmark suite with multiple problem sizes and high precision measurements.
This allows for reproducible results to be generated quickly, and over a range of heterogeneous accelerator devices.
For this thesis 15 devices were used -- and tested on -- to produce a full set of execution times and other performance metrics over all 12 applications and 42 kernels.
The performance metrics allow direct evaluation of devices.

Examining the performance of the benchmark suite over a range of devices allows a direct comparison to be made between these devices on a per application basis.
As a by-product of this comparison, the suitably of OpenCL is shown as a hardware agnostic language.

Separately, the Architecture Independent Workload Characterisation was developed and is capable of identifying the fundamental characteristics of programs free from any specific device.
Architecture Independent Workload Characterisation (AIWC) tool is capable of analysing kernels in order to extract a set of predefined features or characteristics.
The tool can be used in diversity analysis -- which is essential when assembling benchmark suites and justifying the inclusion of an application.
Furthermore, these metrics are used for creating the prediction model to evaluate the performance of OpenCL kernels on different hardware devices and settings.
Such a model is then applied as a prognosis tool to predict the performance of an application for any given platform without additional instrumentation.
This prediction adds information that can be incorporated into existing HPC schedulers and has no run-time overhead -- codes are examined one time by the developer when instrumenting with AIWC and these, in turn, are embedded into the header of each kernel code to be evaluated by the scheduler at the time of scheduling.


<!-- Begin verbatim from the EOD paper chapter -->
## Extended OpenDwarfs

We have performed essential curation of the OpenDwarfs benchmark suite.
We improved coverage of spectral methods by adding a new Discrete Wavelet Transform benchmark, and replacing the previous inadequate `fft` benchmark.
All benchmarks were enhanced to allow multiple problem sizes; in this paper we report results for four different problem sizes, selected according to the memory hierarchy of CPU systems as motivated by Marjanović's findings [@marjanovic2016hpc].
These can now be easily adjusted for next generation accelerator systems using the methodology outlined in Section~\ref{ssec:setting_sizes}.

We ran many of the benchmarks presented in the original OpenDwarfs [@krommydas2016opendwarfs] paper on current hardware.
This was done for two reasons, firstly to investigate the original findings to the state-of-the-art systems and secondly to extend the usefulness of the benchmark suite.
Re-examining the original codes on range of modern hardware showed limitations, such as the fixed problem sizes along with many platform-specific optimizations (such as local work-group size).
In the best case, such optimizations resulted in sub-optimal performance for newer systems (many problem sizes favored the original GPUs on which they were originally run).
In the worst case, they resulted in failures when running on untested platforms or changed execution arguments.

Finally a major contribution of this work was to integrate LibSciBench into the benchmark suite, which adds a high precision timing library and support for statistical analysis and visualization.
This has allowed collection of PAPI, energy and high resolution (sub-microsecond) time measurements at all stages of each application, which has added value to the analysis of OpenCL program flow on each system, for example identifying overheads in kernel construction and buffer enqueuing.
The use of LibSciBench has also increased the reproducibility of timing data for both the current study and on new architectures in the future.

<!--###Future Work-->

We plan to complete analysis of the remaining benchmarks in the suite for multiple problem sizes.
In addition to comparing performance between devices, we would also like to develop some notion of "ideal" performance for each combination of benchmark and device, which would guide efforts to improve performance portability.
Additional architectures such as FPGA, DSP and Radeon Open Compute based APUs -- which further breaks down the walls between the CPU and GPU -- will be considered.

Each OpenCL kernel presented in this paper has been inspected using the Architecture Independent Workload Characterization (AIWC).
Analysis using AIWC helps understand how the structure of kernels contributes to the varying runtime characteristics between devices that are presented in this work, and will be published in the future.

Certain configuration parameters for the benchmarks, e.g. local workgroup size, are amenable to auto-tuning.
We plan to integrate auto-tuning into the benchmarking framework to provide confidence that the optimal parameters are used for each combination of code and accelerator.

The original goal of this research was to discover methods for choosing the best device for a particular computational task, for example to support scheduling decisions under time and/or energy constraints.
Until now, we found the available OpenCL benchmark suites were not rich enough to adequately characterize performance across the diverse range of applications and computational devices of interest.
Now that a flexible benchmark suite is in place and results can be generated quickly and reliably on a range of accelerators, we plan to use these benchmarks to evaluate scheduling approaches.
<!-- End verbatim from the EOD paper chapter -->

<!-- Begin verbatim from the AIWC paper chapter -->
We have presented the Architecture-Independent Workload Characterization tool (AIWC), which supports the collection of architecture-independent features of OpenCL application kernels.
It is the first workload characterization tool to support multi-threaded or parallel workloads.
These features can be used to predict the most suitable device for a particular kernel, or to determine the limiting factors for performance on a particular device, allowing OpenCL developers to try alternative implementations of a program for the available accelerators -- for instance, by reorganizing branches, eliminating intermediate variables et cetera.
In addition, the architecture independent characteristics of a scientific workload will inform designers and integrators of HPC systems, who must ensure that compute architectures are suitable for the intended workloads.

Caparrós Cabezas and Stanley-Marbell [@CaparrosCabezas:2011:PDM:1989493.1989506] examine the Berkeley dwarf taxonomy by measuring instruction-level parallelism (ILP), thread-level parallelism (TLP), and data movement.
They propose a sophisticated metric to assess ILP by examining the data dependency graph of the instruction stream.
Similarly, TLP was measured by analysing the block dependency graph.
While we propose alternative metrics to evaluate ILP and TLP -- using the max, mean and standard deviation statistics of SIMD and barrier metrics respectively -- a quantitative evaluation of the dwarf taxonomy using these metrics is left as future work.
<!-- killing dwarfs -->
We expect that the AIWC metrics will generate a comprehensive feature-space representation which will permit cluster analysis and comparison with the dwarf taxonomy.

We believe AIWC will also be useful in guiding device-specific optimization by providing feedback on how particular optimizations change performance-critical characteristics.
To identify which AIWC characteristics are the best indicators of opportunities for optimization, we are currently looking at how individual characteristics change for a particular code through the application of best-practice optimizations for CPUs and GPUs (as recommended in vendor optimization guides).

A major limitation of running large applications under AIWC is the high memory footprint.
Memory access entropy scores require a full recorded trace of every memory access during a kernel's execution.
However, a graceful degradation in performance is preferable to an abrupt crash in AIWC if virtual memory is exhausted.
For this reason, work is currently being undertaken for an optional build of AIWC with low memory usage by writing these traces to disk.
The coverage of characteristics and the suitability AIWC metrics can now be assessed.
This is performed in in the next [Chapter @sec:chapter-5-accelerator-predictions] where these AIWC metrics -- from the collection over all EOD applications and over all problem sizes -- are used as predictor variables to form a model with the aim of performing execution time predictions.
Which could in turn be directly used to schedule devices in the HPC mult-accelerator node setting.
The feature-space collected from AIWC is also evaluated -- if accurate model predictions are achieved, relative to the actual measured execution times presented in [Chapter @sec:chapter-3-ode], then the metrics selected during the design of AIWC are valid -- since all significant components that depict an applications execution time on any accelerator have been measured.
<!-- End verbatim from the AIWC paper chapter -->


<!-- Begin verbatim from the predicting paper chapter -->

A highly accurate model has been presented that is capable of predicting execution times of OpenCL kernels on specific devices based on the computational characteristics captured by the AIWC tool.
A real-world scheduler could be developed based on the accuracy of the presented model.

We do not suppose that we have used a fully representative suite of kernels, however, we have shown that this approach can be used in the supercomputer accelerator scheduling setting, and the model can be extended/augmented with additional training kernels using  the methodology presented in this paper.

We expect that a similar model could be constructed to predict energy or power consumption, where the response variable can be directly swapped for an energy consumption metric -- such as joules -- instead of execution time.
However, we have not yet collected the energy measurements required to construct such a model.
Finally, we show the predictions made are accurate enough to inform scheduling decisions.


<!-- End verbatim from the predicting paper chapter -->


We plan to complete analysis of the remaining benchmarks in the suite for multiple problem sizes.
In addition to comparing performance between devices, we would also like to develop some notion of "ideal" performance for each combination of benchmark and device, which would guide efforts to improve performance portability.
Additional architectures such as FPGA, DSP and Radeon Open Compute based APUs -- which further breaks down the walls between the CPU and GPU -- will be considered.

Each OpenCL kernel presented in this paper has been inspected using the Architecture Independent Workload Characterization (AIWC).
Analysis using AIWC helps understand how the structure of kernels contributes to the varying runtime characteristics between devices that are presented in this work, and will be published in the future.

Certain configuration parameters for the benchmarks, e.g. local workgroup size, are amenable to auto-tuning.
We plan to integrate auto-tuning into the benchmarking framework to provide confidence that the optimal parameters are used for each combination of code and accelerator.

The original goal of this research was to discover methods for choosing the best device for a particular computational task, for example to support scheduling decisions under time and/or energy constraints.
Until now, we found the available OpenCL benchmark suites were not rich enough to adequately characterize performance across the diverse range of applications and computational devices of interest.
Now that a flexible benchmark suite is in place and results can be generated quickly and reliably on a range of accelerators, we plan to use these benchmarks to evaluate scheduling approaches.


##AIWC

We have presented the Architecture-Independent Workload Characterization tool (AIWC), which supports the collection of architecture-independent features of OpenCL application kernels.
These features can be used to predict the most suitable device for a particular kernel, or to determine the limiting factors for performance on a particular device, allowing OpenCL developers to try alternative implementations of a program for the available accelerators -- for instance, by reorganizing branches, eliminating intermediate variables et cetera.
The additional architecture independent characteristics of a scientific workload will be beneficial to both accelerator designers and computer engineers responsible for ensuring a suitable accelerator diversity for scientific codes on supercomputer nodes.

Caparrós Cabezas and Stanley-Marbell [@CaparrosCabezas:2011:PDM:1989493.1989506] examine the Berkeley dwarf taxonomy by measuring instruction-level parallelism, thread parallelism, and data movement.
They propose a sophisticated metric to assess ILP by examining the data dependency graph of the instruction stream.
Similarly, Thread-Level-Parallelism was measured by analysing the block dependency graph.
Whilst we propose alternative metrics to evaluate ILP and TLP -- using the max, mean and standard deviation statistics of SIMD width and the total barriers hit and Instructions To Barrier metrics respectively -- a quantitative evaluation of the dwarf taxonomy using these metrics is left as future work.
We expect that the additional AIWC metrics will generate a comprehensive feature-space representation which will permit cluster analysis and comparison with the dwarf taxonomy.


##Performance Prediction

A highly accurate model has been presented that is capable of predicting execution times of OpenCL kernels on specific devices based on the computational characteristics captured by the AIWC tool.
A real-world scheduler could be developed based on the accuracy of the presented model.

We do not suppose that we have used a fully representative suite of kernels, however, we have shown that this approach can be used in the supercomputer accelerator scheduling setting, and the model can be extended/augmented with additional training kernels using  the methodology presented in this paper.

We expect that a similar model could be constructed to predict energy or power consumption, where the response variable can be directly swapped for an energy consumption metric -- such as joules -- instead of execution time.
However, we have not yet collected the energy measurements required to construct such a model.
Finally, we show the predictions made are accurate enough to inform scheduling decisions.


