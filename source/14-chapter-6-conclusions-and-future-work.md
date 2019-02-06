
#Conclusions and Future Directions

The contents of this thesis fall into the areas of benchmarking, workload characterization, high-performance computing, predictive modelling, software engineering and performance evaluation.
Its main goal is, however, improving the performance of large HPC systems by providing useful scheduling information of scientific applications to the most appropriate accelerator.
We hope this work will modestly contribute to the increasing interaction between domain sciences and high-performance computing.
As tool builders for domain sciences, computer scientists face a challenging task imposed by increasingly complex computer architectures.

This thesis demonstrates that architecture-independent features are sufficient to characterize codes and to predict performance so as to schedule the optimal device.
We proposed an extended benchmark suite which supports diverse accelerators and demonstrated the performance of these devices over a large number of codes/kernels.
We developed the Architecture-Independent Workload Characterization Tool (AIWC) to examine the structural characteristics<!--, the degree of optimization--> and implementation constraints of kernels to offer an understanding of the algorithm without having to consider the hardware.
Finally, we used these AIWC metrics to identify the most suitable device for each kernel using a predictive regression model.

The extended OpenDwarf suite provides a reliable benchmark suite with multiple problem sizes and high precision measurements.
Reproducible results can be generated quickly and over a range of heterogeneous accelerator devices.
A full set of execution times and other performance metrics were generated using 15 devices over 12 benchmarks and 42 kernels.
The energy and hardware events metrics allowed direct performance evaluations to be made between devices.

The exploration of the differences in the characteristics of codes is used to examine this variation in performance between heterogeneous devices.
To this end, AIWC was developed and is capable of identifying the fundamental characteristics of programs free from any specific device.
AIWC allowed extraction of a set of pre-defined features or characteristics for analysis of kernels.
The tool was used in diversity analysis -- see Appendix \ref{appendix:diversity-analysis} -- which is essential when assembling benchmark suites and justifying the inclusion of a benchmark.
These AIWC metrics were used for creating a predictive model of the performance of OpenCL kernels on different hardware devices and settings.
This model can be incorporated into existing HPC schedulers and has no run-time overhead -- a code is instrumented once only using AIWC and the resulting features are embedded into the header of each kernel code to be used by the scheduler at runtime.

The use of accelerators is pervasive in HPC and will become more so in the future.
We showed that AIWC and the predictive model support a methodology to achieve better performance on HPC systems composed of heterogeneous accelerators.
Fine-grained scheduling decisions could be supported with the high accuracy of predictions, which we expect will lead to more efficient scheduling of HPC workloads.

The contributions of each chapter are now discussed in greater detail, concluding with a summary of the future directions currently being pursued as a result of this thesis.

## Extended OpenDwarfs -- EOD

We have performed essential curation of the OpenDwarfs benchmark suite in Chapter 3.
We selected OpenDwarfs as the basis for our extensions as it:

1) solely focused on an OpenCL implementation, which avoids the fragmentation and different optimizations between language codes common to the SHOC and Rodinia Suites,
2) existing benchmarks had already been classified according to the Dwarf Taxonomy to justify each addition, and,
3) this work was current with the latest use as an evaluation of OpenCL for FPGA devices [@krommydas2016opendwarfs].

We removed hardware specific optimizations from codes that would either diminish performance or crash the application on other devices, these optimizations adversely affect the general-purpose nature which is critical to a benchmark suite.
We improved coverage of spectral methods by adding a new Discrete Wavelet Transform benchmark and replacing the previous inadequate `fft` benchmark.
All benchmarks were enhanced to allow multiple problem sizes; in Chapter 3 we reported results for four different problem sizes, selected according to the memory hierarchy of CPU systems as motivated by Marjanović's findings [@marjanovic2016hpc].
These can now be easily adjusted for next-generation accelerator systems using the methodology outlined in Section\ \ref{sec:setting_sizes}.

All of the benchmarks presented in the most recent (2016) OpenDwarfs [@krommydas2016opendwarfs] paper were rerun on current hardware.
This was done for two reasons, firstly to attempt to replicate the original findings to the modern systems and secondly to extend the usefulness of the benchmark suite.
Re-examining the original codes on a range of modern hardware showed limitations, such as the fixed problem sizes along with many platform-specific optimizations (such as local work-group size).
In the best case, such optimizations resulted in sub-optimal performance for newer systems (many problem sizes favoured the original GPUs on which they were originally run).
In the worst case, they resulted in failures when running on untested platforms or changed execution arguments.
We fixed these issues in the Extended OpenDwarfs benchmark suite to support multiple devices, over multiple problem sizes -- so it can be applied to embedded systems as well as top end
scientific processors -- and added the DWT and a stable FFT implementation to allow the benchmarks to span as many of the Dwarfs as possible.

Finally, a major contribution of this work was to integrate LibSciBench into the benchmark suite, which adds high precision timing and support for statistical analysis and visualization.
This has allowed collection of PAPI, energy and high resolution (sub-microsecond) time measurements at all stages of each benchmark.
The use of LibSciBench has also increased the reproducibility of timing data for both the current study and on new architectures in the future.

The Extended OpenDwarfs Benchmark Suite can be found on Github\footnote{https://github.com/BeauJoh/OpenDwarfs} and a Jupyter artefact demonstrating its usage is also available. \footnote{https://github.com/BeauJoh/Benchmarking-bioinformatics-workloads-and-exploring-suitability-for-heterogeneous-HPC-artefact/blob/master/codes/AIWC\ spaces\ of\ bioinformatics\ workloads.ipynb}


##AIWC

In Chapter 4, we presented the Architecture-Independent Workload Characterization tool (AIWC), which supports the collection of architecture-independent features of OpenCL application kernels.
These features can be used to predict the most suitable device for a particular kernel, or to determine the limiting factors for performance on a particular device, allowing OpenCL developers to try alternative implementations of a program for the available accelerators -- for instance, by reorganizing branches, eliminating intermediate variables et cetera.
The additional architecture independent characteristics of a scientific workload will be beneficial to both accelerator designers and computer engineers responsible for ensuring a suitable accelerator diversity for scientific codes on supercomputer nodes.

Each OpenCL kernel presented in Chapter 3 of EOD was inspected using AIWC.
Analysis using AIWC helps to understand how the structure of kernels contributes to the varying runtime characteristics between devices, it is envisaged that this will be of greater importance in the future when codes will need to be run on a wider range of accelerators.

<!--
The coverage of characteristics and the suitability of AIWC metrics was assessed in Chapter 5, where metrics -- from the collection of all EOD kernels and for all problem sizes -- are used as predictor variables to form a model to accurately predict execution time.
This could, in turn, be directly used to schedule devices in the HPC multi-accelerator node setting.

The feature-space collected from AIWC is also evaluated -- if accurate model predictions are achieved, relative to the actual measured execution times presented in Chapter 3, then the metrics selected during the design of AIWC are valid -- since all significant components that depict an applications execution time on any accelerator have been measured.
-->

AIWC is an additional tool to be used by developers and does not attempt to replace classical device-specific instrumentation and profiling.
It is intended to integrate with existing development workflows, indeed, since AIWC is a plugin into Oclgrind which is an OpenCL device simulator, and is mostly used for debugging, the developer may check for memory leaks and race conditions in their code and use the same tool to examine its architecture-independent workload characteristics.
Optimization could be guided by AIWC metrics but does not exclude the ability to use hardware performance counters, PIN events or vendor-specific profiler tools.
AIWC is available on Github\footnote{https://github.com/BeauJoh/Oclgrind}, there is a Jupyter artefact to demonstrate how metrics are collected on the EOD benchmark suite and how the figures are produced\footnote{https://github.com/BeauJoh/aiwc-opencl-based-architecture-independent-workload-characterization-artefact/blob/master/AIWC-figures.ipynb}, there is also a Binder version of the artefact also available.\footnote{https://mybinder.org/v2/gh/BeauJoh/aiwc-opencl-based-architecture-independent-workload-characterization-artefact/master}


##Performance Prediction

A highly accurate model, capable of predicting execution times of OpenCL kernels on specific devices based on the computational characteristics captured by the AIWC tool was presented in Chapter 5.
A real-world scheduler could be developed based on the accuracy of the presented model.

We do not suppose that we have used a fully representative suite of kernels -- Section 6.4.1 outlines future work to address this -- however, we have shown that this approach can be used in the supercomputer accelerator scheduling setting, and the model can be extended/augmented with additional training kernels using the methodology presented in Chapter 5.

To use this predictive model in a real-world setting, the final metrics collected by AIWC could be embedded as a comment at the beginning of each kernel code.
This approach would allow the high accuracy of the predictive model without any significant overhead -- metrics are only generated and embedded once each kernel was written and could be done automatically with AIWC once a developer was ready for a code to be shipped.
Separately, the training of the model would only need to occur when the HPC system is updated such that a new accelerator device is added, or the drivers, or compiler updated.
The extent of model training is also largely automatic and is based on the measured bias from the recorded runtimes -- if the node were updated the EOD suite would need to be rerun over updated devices and the performance runtimes incorporated into a newly trained regression model.
The runtime results from EOD could also be saved in an online corpus/database with the corresponding devices name allowing the automatic training of one large shared model.

Using the same predictive model for run-times generated over compute devices spanning 6 years and four processor generations shows both that OpenCL has reached a position of maturity and stability, and that the methodology of prediction is sound.
Specifically, performing predictions with a single model generated over a large window of time shows that with each generation the individual device prediction accuracy is good and we expect this same methodology to continue to be equally accurate on future systems.
The model is available as a Jupyter workbook\footnote{https://nbviewer.jupyter.org/github/BeauJoh/opencl-predictions-with-aiwc/blob/master/
OpenCL\ Performance\ Prediction\ using\ Architecture-Independent\ Features.ipynb} which allows users to run new predictions, automatically compare them to the measured runtimes and provides transparency around how each figure in Chapter 5 was generated.


##Future Directions

Each of the lines of investigation described in this thesis has a future -- from examining benchmark diversity to improving the characterization of codes.
The following sections, however, focus on directions that may have the most significant impact in shifting us toward understanding the characteristics of codes and how to best improve the performance on the accelerator rich systems of the future.

<!--
### EOD Future Work 

We plan to complete analysis of the remaining benchmarks in the suite for multiple problem sizes.
In addition to comparing performance between devices, we would also like to develop some notion of "ideal" performance for each combination of benchmark and device, which would guide efforts to improve performance portability.
Additional architectures such as FPGA, DSP and Radeon Open Compute based APUs -- which further breaks down the walls between the CPU and GPU -- will be considered.

Many portions of the suite contain autotuning for workgroup sizes, however, we plan to fully integrate autotuning into the benchmarking framework to provide confidence that the optimal parameters are used for each combination of code and accelerator.
Adding autotuning support for kernel compiler level optimizations, such as level of loop nesting and unrolling, will be performed in the future.
-->

### EOD
<!--The original goal of this research was to discover methods for choosing the best device for a particular computational task, for example, to support scheduling decisions under time and/or energy constraints.
Until now, we found the available OpenCL benchmark suites were not rich enough to adequately characterize performance across the diverse range of applications and computational devices of interest.-->
EOD and the work presented in Chapter 3 resulted in a flexible benchmark suite that can be run quickly and reliably on a range of accelerators and forms a foundation for testing AIWC and the predictive model.
We started to use the OpenTuner[@ansel:pact:2014] autotuning library to achieve the optimal performance of each device on all the benchmarks in EOD but realised that it is beyond the scope of this thesis.
Others [@du2012cuda], [@spafford2010maestro], [@chaimov2014toward], [@nugteren2015cltune], [@Filipovic:2017:AOK:3152821.3152877], [@price2017analyzing] have shown that autotuners offer good performance for configuring OpenCL kernel parameters -- such as local workgroup size -- for the different accelerators and could be readily incorporated into EOD in a consistent manner.
However, the presented execution times do not change the presented methodologies around workload characterization and prediction, individual features and the predictions may change with different tuning arguments but the use case is the same.
The developer needs to instrument a kernel before it is shipped and the most accurate predictions will come from instrumenting under a realistic setting -- tuning arguments included.
Schedulers will need to take autotuning and optimization into account but our prediction methodology offers a good initial performance estimate without having to perform the historic approach of running the same kernel on all the devices.

The `cfd`, `bfs` and `tdm` benchmarks due to the unavailability of external software to generate the datasets lack multiple problem sizes.
It would be nice to have this for completeness of the extensions presented in the EOD benchmark suite, but ultimately, is not the focus of this thesis.

In addition to comparing performance between devices, we would also like to develop some notion of "ideal" performance for each combination of benchmark and device, which would guide efforts to improve performance portability.
This upper-bound for performance could arise from the AIWC analysis on each benchmark.
Additional architectures such as FPGA, DSP and Radeon Open Compute based APUs will be considered.

<!-- AIWC future work -->
### AIWC
Caparrós Cabezas and Stanley-Marbell [@CaparrosCabezas:2011:PDM:1989493.1989506] examine the Berkeley dwarf taxonomy by measuring instruction-level parallelism (ILP), thread parallelism, and data movement.
They propose a sophisticated metric to assess ILP by examining the data dependency graph of the instruction stream.
Similarly, Thread-Level-Parallelism (TLP) was measured by analysing the block dependency graph.
Whilst we propose alternative metrics to evaluate ILP (SIMD width) and the TLP (Total Barriers Hit and Instructions To Barrier) -- a quantitative evaluation of the dwarf taxonomy using these metrics is left as future work.
We expect that the additional AIWC metrics mirroring Caparrós Cabezas and Stanley-Marbells measurements will generate a comprehensive feature-space representation.
This comprehensive feature-space will permit cluster analysis and comparison with the dwarf taxonomy.

A major limitation of running large applications under AIWC is the high memory footprint -- as discussed in Chapter\ \ref{chapter4-aiwc-limitations}.
Memory access entropy scores require a full recorded trace of every memory access during a kernel's execution.
However, graceful degradation in performance is preferable to an abrupt crash in AIWC if virtual memory is exhausted.
For this reason, work is currently being undertaken for an optional build of AIWC with low memory usage by writing these traces to disk.

### Performance Predictions
Our model currently predicts execution time, however, we expect that a similar model could be constructed to predict energy or power consumption.
We have not yet collected the energy measurements over the wide range of devices required to construct such a model.

We have not examined which AIWC features are most important in the predictive model.
Presenting a subset of the metrics may reduce complexity showing only the most important data may be more informative for the developer when making these considerations.
Principal component analysis of these features was considered when evaluating potential modelling approaches and is included in Appendix B.

Kumar et al. [@Kumar:2016:PPE:2925426.2926269] provide an interesting and different use of Shao's [@shao2013isa] ISA-independent features.
They present Peruse, a tool to characterize the features of loops at an IR level to guide a programmer's efforts in locating loops suitable for parallel execution.
In an approach similar to ours, they use machine-learning algorithms directly on ISA metrics to predict the accelerability of loops.
The model they present predicts the speedup of loops with an accuracy of 79%.
It is promising that a similar methodology has been developed based on the same intuition and common set of tools, and is exciting to see if both works could be combined in the form of scheduling abstract for-loops instead of OpenCL kernels.
This would allow a language-agnostic approach to accelerator scheduling -- say on C codes instead of depending on OpenCL specifically.

Following the work presented in this thesis, five additional research topics have become apparent and will be pursued.
They fall outside of the original scope of this thesis but are nonetheless important.

### Finding holes in benchmarks: Evaluating the coverage and corresponding performance predictions for conventional vs synthetic benchmarking
Our prediction methodology can be used to evaluate the coverage/diversity of the benchmarks included in the EOD benchmark suite.
This work is currently focused on augmenting EOD with synthetic benchmarks.
The predictive model is used to make predictions on previously unseen codes against the trained set of EOD runtime results.
These unseen codes are randomly generated using the OpenCL kernel generation framework (CLgen) by Cummins et al. [@cummins2017a] with a training corpus of all OpenCL applications available on GitHub.
The previous success of our model to predict execution times across many devices with high accuracy has led us to believe that the Extended OpenDwarfs Benchmark Suite is a good platform for training – it adequately covers the feature space for many scientific problems typical of the HPC setting.
However, we expect that testing the model with synthetic benchmarking may identify gaps in the coverage provided by the existing suite of benchmarks, which would manifest as poor predictions on particular synthetic kernels.
These poorly predicted kernels could be added back into the EOD benchmark suite -- thus better encompassing the work expected to be run on these accelerator devices.

### AIWC for the Masses: Towards language-agnostic architecture-independent workload characterization

OpenCL was the optimal language for the evaluation of codes on the broadest range of accelerators required for this thesis, however, several other programming systems are commonly used for accelerators in HPC, including CUDA, OpenMP and OpenACC.
The last two offer an accelerator directives approach to offload work to accelerators.
It would be useful to perform the same architecture-independent workload characterization on all these languages.
Thankfully, there exist source-to-source translation tools such as Coriander [@Perkins:2017] which allows a largely automatic conversion from CUDA to OpenCL codes.
Also, LLVM is the common intermediate-representation or backend between OpenMP, OpenACC and OpenCL.
We are currently writing an LLVM pass to generate OpenCL device payloads for AIWC from OpenMP and OpenACC.

### Examining the Characteristics of Scientific Codes in Supercomputing with AIWC
<!--
We are in the early stages of collaborating with colleagues at Shanghai Jiao Tong University’s HPC Center, in examining the performance properties of scientific codes on the
Sunway TaihuLight, Tianhe-2A and future Tianhe-3 supercomputer systems.
Porting large HPC codes, such as those seen in weather forecasting and bioinfomatics, from conventional CPU architectures to accelerators is intensive on the developer.
However, this work must be done to accommodate the transition of supercomputers from the conventional historical many homogeneous CPU cores to multiple accelerators per node.
Thankfully, many of these codes were written in OpenMP -- and more recently with OpenACC -- these directives based approaches support offloading to accelerator devices.
Once the AIWC for the Masses work has been completed, from the previous section, we can perform language-agnostic architecture-independent workload characterization on many of these applications.
Aside from assisting in scheduling the work presented in this thesis, AIWC and the predictive model could be used to identify primary characteristics of codes run on supercomputers.
For instance, if the research institutes which provide access to a supercomputer know that 80% of an application is most suited to a GPU the best theoretical machine could contain 4 GPUs to 1 CPU on a node.
This can be used to suggest optimal configurations of accelerators for the next-generation of supercomputers.
Additionally, the AIWC metrics can be used to inform a developer around general suitability of a kernel to accelerator before devoting a large amount of time optimizing kernels that already perform sufficiently on the current architecture.
We are also pursuing collaboration with some of the US National Laboratories who have expressed interest in using AIWC to examine the characteristics of the codes run on some of the largest supercomputers in the world.
Finally, optimization strategies could be hinted to by AIWC but this is discussed as the next area of future work.
-->

Porting large HPC codes from conventional CPU architectures to accelerators is intensive on the developer.
However, many codes currently run on supercomputer systems are legacy and as these systems increasingly utilize accelerators, more of this porting work will be required.
Many of these codes were written in OpenMP  making them a suitable target for the language-agnostic architecture-independent workload characterization.
In addition to supporting scheduling as presented in this thesis, AIWC and the predictive model could be used to identify the primary characteristics of codes run on supercomputers.
For instance, if the supercomputing centre knows which codes are likely to be frequently executed, by identifying the characteristics of these codes and the most suitable accelerators they can design nodes with the optimal accelerator configurations.


### Guiding Device Specific Optimization using Architecture-Independent Metrics

We believe AIWC will also be useful in guiding device-specific optimization by providing feedback on how particular optimizations change performance-critical characteristics.
To identify which AIWC characteristics are the best indicators of opportunities for optimization, we are currently looking at how individual characteristics change for a particular code through the application of best-practice optimizations for CPUs and GPUs (as recommended in vendor optimization guides).

Metrics from AIWC could be compared after applying device-specific optimizations to see how these features change and could identify performance-critical characteristics.
The selection of best practices such as, “Intel 64 and IA-32 Architectures Optimization Reference Manual” for CPU and “CUDA C Best Practices Guide, Design Guide” for GPU could be taken from their respective source code and ported to OpenCL.
The examination of the change of AIWC feature-spaces after each device specific optimization may suggest accelerator-agnostic optimization strategies.

<!--
Cluster analysis of this feature-space may support the automatic classification of the Berkeley Dwarfs or other taxonomies.
This is outside the scope of this thesis but pursuing this work increases the relevancy of AIWC and the presented predictive methodology.-->

### Faster FPGA development with AIWC and the Predictive Model

Finally, complicated OpenCL codes can take many hours -- if not days -- to compile for FPGA devices.
This makes the trial-and-error approach commonly taken when optimizing code for a device untenable.
Given the accuracy of the predictive model, there is a use-case for AIWC to augment this workflow.
Speculative optimization changes could be made to an OpenCL code, the AIWC metric regenerated and predictive model queried, if the predicted device execution result is better it could indicate a suitable optimization.
This would potentially take seconds instead of the long compile times when evaluating FPGA performance.
The inherent difficulty of predicting application performance on a reconfigurable architecture is the ultimate test for the predictive model outlined in this thesis.

## Closing Remarks

We hope the work presented in this thesis will serve as the basis for the scheduling of HPC workloads as accelerator usage becomes more prevalent in this space.
Our next goal is to incorporate our methodology with AIWC and random forest models into the StarPU accelerator scheduler, this will serve as a prototype scheduler, which we hope will become the norm on the next generation of accelerator-based supercomputers.
We hope our work on benchmarking, workload characterization and prediction has made a modest contribution and that the proposed techniques may help HPC developers make sense of an increasingly complex hardware and software environment.

