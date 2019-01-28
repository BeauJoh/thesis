---
title: "Characterizing and Predicting Scientific Workloads for Heterogeneous Computing Systems"
author: Beau Johnston
institute: The Australian National University
date: 29 January, 2019 #\today
---

#Supercomputers 101

* Used in computationally intensive tasks and are a critical component in current scientific research.
* Essential in simulations for quantum mechanics, weather forecasting, climate research, oil and gas exploration and molecular modeling, etc.
* However require huge amounts of electricity to operate – the Summit, currently number one in the TOP500, requires 8.8 MW to power, which is in the capacity of a small coal power plant.
* To reduce this large energy footprint supercomputers are becoming increasingly heterogeneous.

#Trends in Supercomputing -- A view from the Top500

<!-- 40 mins + 20 mins questions -->

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{enumerate}
\item Summit -- GV100
\item \textcolor{alertblue}{Sunway TaihuLight}
\item Sierra -- GV100
\item \textcolor{alertblue}{Tianhe-2A}
\item ABCI -- V100
\item Piz Daint -- P100
\item Titan -- K20x
\item \textcolor{alertblue}{Sequoia}
\item Trinity -- Phi
\item Cori -- Phi
\end{enumerate}
\end{column}
\begin{column}{0.5\textwidth} \pause
\begin{itemize}
\item As of June 2018
\item 7 / 10 use accelerators
\item Newest is Summit -- based on IBM Power9 with NVLINK and CAPI
\item All devices have an OpenCL runtime
\item Reliance on accelerators is increasing
\item Scheduling to the most appropriate device is an open problem
\end{itemize}
\end{column}
\end{columns}

<!--
For reasons of both performance and energy efficiency, high perfor- mance computing (HPC) hardware is becoming increasingly hetero- geneous. The OpenCL framework supports portable programming across a wide range of computing devices and is gaining influence in programming next-generation accelerators. To characterize the performance of these devices across a range of applications requires a diverse, portable and configurable benchmark suite, and OpenCL is an attractive programming model for this purpose.
We present an extended and enhanced version of the Open- Dwarfs OpenCL benchmark suite, with a strong focus placed on the robustness of applications, curation of additional benchmarks with an increased emphasis on correctness of results and choice of problem size. Preliminary results and analysis are reported for eight benchmark codes on a diverse set of architectures – three Intel CPUs, five Nvidia GPUs, six AMD GPUs and a Xeon Phi.
-->

#Trends in Supercomputing -- Accelerator Use

\begin{figure*}[t]
    \centering
    \includegraphics[width=0.8\textwidth,height=0.8\textheight]{../analysis/top500_percentage_of_supercomputers_with_accelerators.pdf}
    \caption{The percentage of accelerators in use and the contributions of cores found on systems with accelerators in the Top500.}
    \label{fig:top500-percentage-of-supercomputers-using-accelerators}
\end{figure*}

#Trends in Supercomputing -- Accelerator Energy

\begin{figure*}[t]
    \centering
    \includegraphics[width=0.8\textwidth,height=0.8\textheight]{../analysis/top500_GFlops_per_Watt_of_supercomputers_with_and_without_accelerators.pdf}
    \caption{Power efficiency (GFlops/Watt) of using accelerators in the Top500 supercomputers over time.}
    \label{fig:top500-gflops-per-watt-with-and-without-accelerators-in-supercomputers}
\end{figure*}

# Schedulers and the Importance of Prediction

* Increasingly heterogeneous at a node level.
* Schedulers responsible for choosing the right tool for the job.
* Accelerator aware schedulers include StarPU \footnote{C. Augonnet, S. Thibault, R. Namyst, and P.-A. Wacrenier, “StarPU: A unified platform for task scheduling on heterogeneous multicore architectures,” Concurrency and Computation: Practice and Experience, vol. 23, no. 2, pp. 187–198, 2011.}, Ompss \footnote{A. Duran et al., “Ompss: A proposal for programming heterogeneous multi-core architectures,” Parallel Processing Letters, vol. 21, no. 02, pp. 173–193, 2011.} and CoreTSAR \footnote{T. R. Scogland, W.-c. Feng, B. Rountree, and B. R. de Supinski, “Coretsar: Adaptive worksharing for heterogeneous systems,” in International supercomputing conference, 2014, pp. 172–186.}.

# The Problem

* Schedulers track dependencies within tasks and schedule to minimize, compute time/energy, compute bandwidth and latency.
* Scheduling work to the most appropriate accelerator at the granularity of function call level or the work inside a single parallel region.
* Better manage resources of supercomputers by keeping codes running on the best accelerator.
* *But* current approaches run every new code on all available accelerators to determine initial performance $\rightarrow$ wasteful!

# Thesis Statement

"Scientific high performance computer systems are becoming increasingly heterogeneous because certain applications are more suitable to particular accelerators. The architecture-independent characteristics of a program are sufficient to predict its performance which will allow the efficient scheduling of work to the most appropriate accelerator."

# Talk Structure

1) Benchmarking & Gauging the Performance of HPC Accelerators
2) Workload Characterization
3) Making Predictions
4) Use in the Scheduler Setting
4) Conclusions and Future Work

# OpenCL -- The Language of Heterogeneous Computing

* Open Computing Language (OpenCL) is an open standard.
* Allows computationally intensive codes -- kernels -- to be written once and run on any compliant accelerator.
* Most vendors are compliant to basic standards.
* Application code can be written directly in OpenCL, and
* Can be used as a back-end for higher level languages -- OpenMP runtime implemented for TI Keystone II DSP architecture\footnote{Mitra, G. et al. 2014. Implementation and optimization of the OpenMP accelerator model for the TI Keystone II architecture. International workshop on openmp (2014), 202–214.}.
* Increased relevancy for FPGA programming

<!-- EOD SECTION -->

# Dwarfs and the Diversity of Scientific Computing

* Large pool of applications but how to know they are diverse and compare devices under a real-world scientific load?
* Instead of traditional benchmarks, use 13 “Dwarfs” to design and evaluate parallel programming models and architectures.\footnote{K. Asanovic et al., "The landscape of parallel computing research: A view from Berkeley," EECS Department, University of California, Berkeley, UCB/EECS-2006-183, 2006.}
* A dwarf is an algorithmic method that captures a pattern of computation and communication.
* e.g., Dense Linear Algebra applications generally use unit-stride memory accesses to read data from rows and strided accesses to read data from columns, while Map Reduce calculations depend on
statistical results of repeated random trials and are considered embarrassingly parallel.

# Benchmarking

* Examine the performance characteristics of scientific codes -- and the suitability of different accelerators.
* 3 OpenCL suites were considered:
    1) SHOC -- focused on micro-kernels rather than complete applications
    2) Rodinia -- targets language comparison and not all dwarfs covered
    3) **OpenDwarfs** -- selected since it offers the widest range of benchmarks covering all dwarfs

# Extended Open Dwarfs Benchmark Suite

* Extended Open Dwarfs (EOD) Benchmark Suite
* Based off the OpenDwarfs benchmark suite\footnote{Krommydas, K. {OpenDwarfs}: Characterization of dwarf-based benchmarks on fixed and reconfigurable architectures. Journal of Signal Processing Systems, vol. 85, no. 3, pp. 373-392, 2016}
* Benchmarks selected following diversity analysis and 13 Berkeley Dwarfs taxonomy
* Built in OpenCL
* Purpose of OpenDwarfs was a to characterize a diverse set of parallel applications and architectures using a common language, but had deficiencies...

# OpenDwarfs Deficiencies

* Architecture specific hard-coded optimizations -- both structural and parameters
* Fixed problem sizes

# EOD Extensions

* Selection of problem size critically affects HPC benchmarking
* Highest impact on CPU architectures.
* A major contribution of the work is facilitating 4 different problem sizes for all applications presented in the suite.
* Selected according to levels of cache
    - **tiny** : < 32 KiB L1
    - **small**: < 256 KiB L2
    - **medium**: < 8192 KiB L3
    - **large**: > 8192 KiB L3

# EOD Extensions II

* Diverse:
    - 4 different problem sizes per application
    - Added `dwt` and `fft` applications -- currently 11 benchmarks and 37 kernels
    - Real scientific applications
* Reproducible: Minimum of 2 sec runs per benchmark
* Precise:
    - High-resolution timers with LibSciBench\footnote{T. Hoefler and R Belli. "Scientific benchmarking of parallel computing systems: Twelve ways to tell the masses when reporting performance results," in Proceedings of the International Conference for High Performance Computing, Networking, Storage and Analysis, 2015. ACM, 73.}
    - Reported with one cycle resolution and roughly 6 ns of overhead
    - Also allows collection of energy and hardware events

# EOD Extensions III

* Portable:
    - Based on an OpenCL backend
    - Tested on a wide range of hardware
    - Consistent tuning -- i.e. workgroup size arguments

# Applications

\begin{table}
\centering
\caption{List of Extended OpenDwarfs Applications and their respective dwarfs}
\begin{adjustbox}{max width=0.7\textwidth,max height=0.8\textheight}
\begin{tabular}{@{}ll@{}}
\hline {Dwarf} & {Extended OpenDwarfs Application}\\\hline

Dense Linear Algebra & LU Decomposition\\
Sparse Linear Algebra & Compressed Sparse Row\\
Spectral Methods & DWT2D, FFT\\
N-Body Methods & Gemnoui\\
Structured Grid & Speckle Reducing Anisotropic Diffusion\\
Unstructured Grid & Computational Fluid Dynamics\\
Map Reduce & K-Means\\
Combinational Logic & Cyclic-Redundancy Check\\
Graph Traversal & Breadth First Search\\
Dynamic Programming & Smith-Waterman\\
Backtrack and Branch and Bound & N-Queens\\
Graphical Methods & Hidden Markov Models\\
Finite State Machines & Temporal Data Mining\\

\hline

\end{tabular}
\end{adjustbox}
\end{table}


# Experimental Setup

\begin{table}
\caption{Hardware used for the EOD evaluation.}
\vspace{-0.3cm}
\begin{adjustbox}{center, width=.65\textwidth}
\begin{threeparttable}
    \centering
    \begin{tabular}{l|c|c|c|r|c|c|r|c}
        Name         & Vendor   & Type  & Series    & \multicolumn{1}{m{1cm}|}{\centering Core Count} & \multicolumn{1}{m{2.5cm}|}{\centering Clock Frequency (\si{\mega\hertz}) (min/max/turbo)}  &\multicolumn{1}{m{2.1cm}|}{\centering Cache (\SI{}{\kibi\byte}) (L1/L2/L3)} & \multicolumn{1}{m{.8cm}|}{\centering TDP (\SI{}{\watt})} &  \multicolumn{1}{m{1cm}}{\centering Launch  Date} \\ \hline
        Xeon E5-2697 v2  & Intel    & CPU   &Ivy Bridge & 24$\ast$ &1200/2700/3500 & 32/256/30720 & 130 & Q3 2013\\
        i7-6700K & Intel    & CPU   &Skylake & 8$\ast$ & 800/4000/4300 & 32/256/8192& 91 & Q3 2015\\
        i5-3550  & Intel    & CPU   & Ivy Bridge & 4$\ast$ & 1600/3380/3700 & 32/256/6144& 77 & Q2 2012\\
        Titan X & Nvidia & GPU & Pascal & 3584\textdagger & 1417/1531/-- & 48/2048/-- & 250 & Q3 2016\\
        GTX 1080 & Nvidia & GPU & Pascal & 2560\textdagger & 1607/1733/-- & 48/2048/-- & 180 & Q2 2016\\
        GTX 1080 Ti & Nvidia & GPU & Pascal & 3584\textdagger & 1480/1582/-- & 48/2048/-- & 250 & Q1 2017\\
        K20m & Nvidia & GPU & Kepler & 2496\textdagger & 706/--/-- & 64/1536/-- & 225 & Q4 2012\\
        K40m & Nvidia & GPU & Kepler & 2880\textdagger & 745/875/-- & 64/1536/-- & 235 & Q4 2013\\
        FirePro S9150 & AMD & GPU & Hawaii & 2816$\|$ & 900/--/-- & 16/1024/-- & 235 & Q3 2014\\
        HD 7970       & AMD & GPU & Tahiti & 2048$\|$ & 925/1010/-- & 16/768/-- & 250 & Q4 2011\\
        R9 290X       & AMD & GPU & Hawaii & 2816$\|$ & 1000/--/-- & 16/1024/--& 250 & Q3 2014\\
        R9 295x2      & AMD & GPU & Hawaii & 5632$\|$ & 1018/--/-- & 16/1024/--& 500 & Q2 2014\\
        R9 Fury X     & AMD & GPU & Fuji   & 4096$\|$ & 1050/--/-- & 16/2048/--& 273 & Q2 2015\\
        RX 480        & AMD & GPU & Polaris& 4096$\|$ & 1120/1266/-- & 16/2048/-- & 150 & Q2 2016\\
        Xeon Phi 7210 & Intel & MIC & KNL & 256\textdaggerdbl & 1300/1500/-- & 32/1024/-- & 215 & Q2 2016\\
    \end{tabular}
    %\begin{tablenotes}
    %\item [$\ast$] HyperThreaded cores
    %\item [\textdagger] CUDA cores
    %\item [$\|$] Stream processors
    %\item [\textdaggerdbl] Each physical core has 4 hardware threads per core, thus 64 cores
    %\end{tablenotes}
\end{threeparttable}
\label{tab:hardware}
\end{adjustbox}
\end{table}

# EOD Evaluation

<!--Regenerate by running ~/Documents/2018/dwarfs-on-accelerators/analysis_tools/bar_charts_csr.R-->
\begin{figure}
    \includegraphics[width=0.8\textwidth]{figures/generate_sample_csr_row_bandwplot}
    \caption{Comparison of performance on 2 sizes of csr application.}
\end{figure}


# EOD Evaluation -- Continued

* Just a sample of 1 of 11 applications
* Similar breakdown of 37 kernels
* 15 devices
* Time, performance events and energy (x50)
* Many more results and discussions presented in the thesis

# What now?

* Small benchmark suite
* Wide diversity of scientific application codes
* Forms a large range of result times (on 6 years of hardware)

\pause
Now, forms a test-bed to examine:

1) workload characterization
2) performance prediction
3) scheduling

\pause
First, how do we characterize a workload?

<!-- AIWC SECTION -->
# Workload Characterization

* Many heterogeneous accelerators running OpenCL in current and future supercomputers, and this trend is continuing
* **But** their performance is as diverse as each accelerators hardware configuration
* An architecture-independent method to characterize OpenCL codes allows us to:
    + measure inherent program behaviour
    + perform accurate performance predictions for scheduling

# Workload characterization with AIWC

* Architecture-Independent Workload Characterization (AIWC)
* Plugin for OclGrind -- an Extensible OpenCL device simulator\footnote{J. Price and S. McIntosh-Smith, “Oclgrind: An extensible opencl device simulator,” in Proceedings of the 3rd International Workshop on OpenCL, 2015, p. 12.}
* Beta available -- <https://github.com/BeauJoh/Oclgrind> -- and will be merged into default OclGrind

# Overview of AIWC

* Simulation of OpenCL kernels occur on LLVM IR -- SPIR
* AIWC tracks and measures hardware agnostic events
* Metrics carefully selected and collected during simulator execution
* Large number of metrics collected (28)
* Over a wide spectrum computation, thread communication and memory access patterns
* Supports parallel workloads
* Accessible -- as part of OclGrind
* High-accuracy -- full resolution, not interrupt/sample driven

# AIWC Example

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item Four major classes: Compute, Parallelism, Memory, Control
\item Different statistics per metric – distributions, entropy and absolute counts
%\item See right for a visual sample of the AIWC feature-space -- reduced and normalised:
\end{itemize}
\end{column}
\begin{column}{0.5\textwidth}
\begin{center}
%<!--Regenerate by running ~/Documents/2018/grinding-dwarfs-and-examining-the-remains/analysis_tools/standalone_for_slides.R-->
\begin{figure}
    \includegraphics[width=1\textwidth]{figure/draw_lud_perimeter_all_kiviat-1.pdf}
    \stepcounter{figure}
\end{figure}
\end{center}
\end{column}
\end{columns}

# AIWC Example II

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item Local Memory Address Entropy
\item Kernel launched 4 times -- over different problem sizes
\item Starting entropy changes with problem size, but same gradient $\rightarrow$ memory access patterns are the same regardless of actual problem size
\item Steeper descent $\rightarrow$ more localised memory access $\rightarrow$ better cache utilization
%\item See right for a visual sample of the AIWC feature-space -- reduced and normalised:
\end{itemize}
\end{column}
\begin{column}{0.5\textwidth}
\begin{center}
%<!--Regenerate by running ~/Documents/2018/grinding-dwarfs-and-examining-the-remains/analysis_tools/standalone_for_slides.R-->
\begin{figure}
    \includegraphics[width=1\textwidth]{figure/draw_lud_perimeter_lmae_tiny_kiviat-1.pdf}
    \stepcounter{figure}
\end{figure}
\end{center}
\end{column}
\end{columns}

# AIWC Example III

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{center}
\begin{figure}
    \includegraphics[width=1\textwidth]{figure/draw_lud_diagonal_all_kiviat-1.pdf}
    \stepcounter{figure}
\end{figure}
\end{center}
\end{column}
\begin{column}{0.5\textwidth}
\begin{center}
\begin{figure}
    \includegraphics[width=1\textwidth]{figure/draw_lud_internal_all_kiviat-1.pdf}
    \stepcounter{figure}
\end{figure}
\end{center}
\end{column}
\end{columns}

# Subset of AIWC Metrics

\begin{table*}[t]
\centering
\caption{Sample of metrics collected by AIWC -- ordered by type.}
\vspace{-0.3cm}
\begin{adjustbox}{max width=0.9\textwidth}

\begin{tabular}{@{}cll@{}}
\toprule

{Type} & {Metric} & {Description}\\\hline

Compute & Opcode & total \# of unique opcodes required to cover 90\% of dynamic
instructions\\
Compute & Total Instruction Count & total \# of instructions executed\\
Parallelism & Work-items & total \# of work-items or threads executed\\
Parallelism & Total Barriers Hit & total \# of barrier instructions\\
Parallelism & Median ITB & median \# of instructions executed until a barrier\\
Parallelism & Max IPT & maximum \# of instructions executed per thread\\
Parallelism & Mean SIMD Width & mean \# of data items operated on during an instruction\\
Memory & Total Memory Footprint & total \# of unique memory addresses accessed\\
Memory & 90\% Memory Footprint & \# of unique memory addresses that cover 90\% of memory accesses\\
Memory & Unique Read/Write Ratio & indication of workload being (unique reads / unique writes) \\
Memory & Reread Ratio & indication of memory reuse for reads (unique reads/total reads)\\
Memory & Global Memory Address Entropy & measure of the randomness of memory addresses\\
Memory & Local Memory Address Entropy & measure of the spatial locality of memory addresses\\
Control & Total Unique Branch Instructions & total \# of unique branch instructions\\
Control & 90\% Branch Instructions & \# of unique branch instructions that cover 90\%
of branch instructions\\
Control & Yokota Branch Entropy & branch history entropy using Shannon's information entropy\\
Control & Average Linear Branch Entropy & branch history entropy score using the
average linear branch entropy\\
\hline
\end{tabular}
\end{adjustbox}
\end{table*}

# AIWC Usage

```
    oclgrind --aiwc ./kmeans -p 0 -d 0 -t 0 -- -g -p 256 -f 30
```

* The collected metrics are logged as text in the command line interface during execution and also in a csv file, stored separately for each kernel and invocation.
* Files can be found in the working directory with the naming convention `aiwc_`$\alpha$`_`$\beta$`.csv`.
* Where $\alpha$ is the kernel name and $\beta$ is the invocation count -- the number of times the kernel has been executed.

# AIWC Overheads

\begin{table*}[t]
\caption{Overhead of the \textbf{AIWC} tool on the {\tt fft} benchmark and the Intel i7-6700K CPU. \label{tbl:aiwc-overhead}}
\centering
\resizebox{0.9\columnwidth}{!}{%
\begin{tabular}{ |l|r|r|r|r|r|r| }
\hline
        & \multicolumn{3}{c|}{time}                                         & \multicolumn{3}{c|}{memory} \\
        & \multicolumn{2}{c|}{usage (ms)}& \multicolumn{1}{c|}{increase}    & \multicolumn{2}{c|}{usage (\si{\mega\byte})}   & \multicolumn{1}{c|}{increase} \\
        & without AIWC  & with AIWC     &                                   & without AIWC   & with AIWC                     & \\
\hline
tiny    & 0.04          & 73.4          & $\approx$1830$\times$             & 80.0           &  85.9                         & 1.07$\times$        \\
small   & 0.2{ }        & 427.8         & $\approx$2800$\times$             & 75.9           &  149.0                        & 1.96$\times$        \\
medium  & 2.9{ }        & 12420{ }{ }   & $\approx$4300$\times$             & 101.4          &  636.8                        & 6.28$\times$        \\
large   & 19.6{ }       & 69300{ }{ }   & $\approx$3540$\times$             & 203.8          &  2213.2                       & 10.86$\times$       \\
\hline
\end{tabular}
}
\end{table*}

* large problems, may exmaine fewer iterations, or run on machines with more virtual memory.
* Envisaged use is that AIWC is only run once, for instance, to examine the characteristics of the kernel in order to identify suitability for accelerators or verify that a high degree of SIMD vectorization had been achieved.

# AIWC Example IV

\begin{center}
%<!--Regenerate by running ~/Documents/2018/grinding-dwarfs-and-examining-the-remains/analysis_tools/standalone_for_slides.R-->
\begin{figure}
    \includegraphics[width=0.7\textwidth]{../figures/chapter-4/hmm.pdf}
    \caption{Highlighting the variance in features between kernels in the {\texttt hmm} benchmark.}
\end{figure}
\end{center}

# A larger AIWC Corpus

* Just a sample of 2 of 11 applications
* Similar breakdown of 37 more kernels from the remainder of EOD suite
* Presented in a [docker & jupyter artefact](https://github.com/BeauJoh/aiwc-opencl-based-architecture-independent-workload-characterization-artefact)

# Sample of the AIWC Corpus
\vspace{-0.2cm}
\begin{figure}
    \centering
    \includegraphics[height=0.9\textheight,width=0.8\textwidth]{figures/draw_stacked_plots-1.pdf}
    \vspace{-0.2cm}
    \caption{Selected AIWC metrics from each category over all kernels and 4 problem sizes.}
\end{figure}

# What now?

* AIWC tracks and measures hardware agnostic events
* Large number of metrics collected (28)
* Over a wide spectrum computation, thread communication and memory access patterns
* EOD provides large set of execution times
* AIWC on EOD gives workload characteristics of the same benchmarks
* Forms a large range of result times with matched AIWC feature-spaces
* Can they be coupled together for a predictive model?

# Performance Prediction -- Combining EOD and AIWC

* Regression model from AIWC was developed
* Predictor variables: 28 AIWC metrics
* Response variable: time or energy of kernel execution
* R language and Ranger -- a Random Forest implementation --  was used
<!--\footnote{M. Wright and A. Ziegler, “ranger: A Fast Implementation of Random Forests for High Dimensional Data in C++ and R,” Journal of Statistical Software, Articles, vol. 77, no. 1, pp. 1–17, 2017.} -- a Random Forest implementation --  was used -->
* Performs recursive partitioning of high dimensional data
* Accepts 3 parameters:
    - num.trees -- number of trees grown in forest -- 10-10k by 500
    - mtry -- number of features tried to split in a node -- 1-34
    - min.node.size -- minimal size per tree -- 1-50
* Optimal model needs careful tuning

# min.node.size

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/full-variation-in-min-node-size-1}
    \stepcounter{figure}
\end{figure}
\end{column}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item Full coverage of min.node.size with fixed tuning parameters: num.trees = 300 and mtry = 30
\item Smallest out-of-bag prediction error for values < 15
\item Selection made to fix min.node.size = 9
\end{itemize}
\end{column}
\end{columns}

# num.trees and mtry

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item {\texttt optim\_sa} function used to find global minimum
\item Full coverage achieved -- 4 outer-most points and 8 random starting internal points
\item intermediate results used and interpolation performed -- using {\texttt akima}
\item Model performance varies significantly for last 2 variables
\item mtry > 25, offers good fit
\item num.trees less impact -- fewer trees are computed faster
\end{itemize}
\end{column}
\begin{column}{0.5\textwidth}
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/full-scan-random-sampled-heatmap-1}
    \stepcounter{figure}
\end{figure}
\end{column}
\end{columns}

# Choosing Parameters for the Future

* num.trees=500, mtry=32, and min.node.size=9 look good
* train on a random selection of N kernels and test on remainder
* see thesis for details but final values are num.trees = 505, mtry = 30 and min.node.size = 9

# Increased Training Data

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/rmse_vs_kernel_count-1}
    \stepcounter{figure}
\end{figure}
\end{column}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item Prediction error across all benchmarks for models trained with varying numbers of kernels.
\item How many kernels to add for training -- what's enough?
\item Another study performed to see how error changes w.r.t. number of kernels in training
\item Uses random selection for each random count -- again see thesis for full details
\item Error tapers off for more kernels!
\item gradient still significant at 37 kernels $\rightarrow$ could still benefit from more.
%<!--item However, the model proposed is a proof of concept and suggests that a general purpose model is attainable and may not require many more kernels. -->
\end{itemize}
\end{column}
\end{columns}

# Prediction Accuracy
\vspace{-0.2cm}
\begin{figure}
    \includegraphics[width=0.7\textwidth,height=0.9\textheight]{figures/actual-vs-predicted-size-plot-1}
    \vspace{-0.2cm}
    \caption{Predicted vs. measured execution time for all kernels.}
\end{figure}

# Prediction Accuracy -- Continued
\vspace{-0.2cm}
\begin{figure}
    \centering
    \includegraphics[width=0.75\textwidth,height=0.9\textheight]{figures/predictive-heatmap-percentage-1-rot}
    \vspace{-0.2cm}
    \caption{Error in predicted execution time for each kernel invocation over all problem sizes.}
\end{figure}

# Predicting for Scheduling

\begin{columns}
\begin{column}{0.75\textwidth}
\begin{figure}
    \includegraphics[width=\textwidth]{figures/large-predicted-vs-measured-1}
    \stepcounter{figure}
\end{figure}
\end{column}
\begin{column}{0.25\textwidth}
\begin{itemize}
%\item Mean measured kernel execution times compared against mean predicted kernel execution times to perform a selection of kernels on large problem sizes across 15 accelerator devices.
\item Mean measured vs predicted kernel execution
\item 4 selected kernels on large problem size
\item square $\rightarrow$ mean measured time
\item diamond $\rightarrow$ mean predicted time
\item order is important!
\end{itemize}
\end{column}
\end{columns}

# Prediction & Schedulers

* Proposed workflow:
    1) Developer uses Oclgrind to debug, optimize and confirm functionality of a kernel,
    2) Rerun Oclgrind with AIWC to acquire the metrics for the final kernel (with the program settings) that will be used at runtime,
    3) Metrics are included as a comment into the kernel -- either in source or SPIR form.
    4) Scheduler extracts metrics at runtime and evaluates them with the model to make performance predictions on the nodes available devices.

# Prediction & Schedulers -- Considerations

* Modern schedulers (StarPU, Ompss and CoreTSAR) run a new kernel on all devices $\rightarrow$ Wasteful!
* Our methodology only requires measurements to be taken once -- with AIWC -- at the time of development
* Model only needs to be retrained when the HPC system is updated, e.g. a new accelerator device, updated driver or compiler.
* Model training is also largely automatic following our prediction methodology, and can use an online corpus -- potentially updated by the community of accelerator manufacturers.

\pause

But wait! What about: Autotuning and Different problem sizes?

\pause

Schedulers have to deal with incorrectly configured kernels and we **only** target the low-hanging-fruit.
If predictions deviate significantly from the measured performance, can fall back to the old run-anywhere approach for given kernel.

# Conclusions -- EOD

* Completed essential curation of the OpenDwarfs benchmark suite:
    + Increased application diversity
    + Tested on 15 devices
    + High precision measurements of time, energy and hardware events
    + Laid ground work for autotuning

# Future Work -- EOD

* Autotuner integration -- others \footnote{N. Chaimov, B. Norris, and A. Malony, “Toward multi-target autotuning for accelerators,” ICPADS, 2014, pp. 534–541.} \footnote{C. Nugteren and V. Codreanu, “CLTune: A generic auto-tuner for OpenCL kernels,” MCSoC, 2015, pp. 195–202.} \footnote{J. Price and S. McIntosh-Smith, “Analyzing and improving performance portability of opencl applications via auto-tuning,” IWOCL, 2017, p. 14.} have shown good performance. 
* What does that mean for the scheduling workflow?
* Use the predictive model for synthetic benchmark study

# Conclusions -- AIWC

* Presented Architecture-Independent Workload Characterization tool:
    + Supports the collection of architecture-independent features of OpenCL application kernels.
    + First workload characterization tool to support multi-threaded and/or parallel workloads.
* AIWC metrics generate a comprehensive feature-space representation $\rightarrow$ permits cluster analysis and comparison with the dwarf taxonomy.

# Future Work -- AIWC

\smaller

* Features can be used to:
    + predict the most suitable device for a particular kernel -- for scheduling,
    + or to determine the limiting factors for performance,
    + allows developers to try alternative implementations (e.g. by reorganizing branches, eliminating intermediate variables ...).
    + inform accelerator designers & integrators of a scientific workloads -- ensures compute architectures are suitable for intended workloads.
* Large working memory fix -- write traces to disk instead of linked-list on RAM
* Prune features -- redundancy good for random-forests but bad for developers
* Guide a developer to assess:
    + how algorithmic changes $\rightarrow$ broader characteristics -- e.g. no device benefits from more sporadic memory accesses
    + performance portability
    + predicting execution time without having access to these systems (or time to test)
* Language-Agnostic and Architecture-Independent Workload Characterization

\larger

# Conclusions -- Prediction

* Presented highly accurate model for predicting execution times of OpenCL kernels.
* The predictions are highly accurate, differing from the measured experimental run-times by an average of only 1.2%
* Correspond to execution time mispredictions of 9 $\mu$s to 1 sec according to problem size.
* Previously unseen code can be instrumented once, AIWC metrics embedded for quick performance prediction.
* Same methodology could be applied to energy usage and hardware events.

# Future Work -- Scheduling

* Scheduler integration -- StarPU, Ompss, CoreTsar or AutoMatch?
* Potential to be more prescriptive than the Berkeley Dwarf Taxonomy

# Thesis Statement Revisited

"Scientific high performance computer systems are becoming increasingly heterogeneous because certain applications are more suitable to particular accelerators. The architecture-independent characteristics of a program are sufficient to predict its performance which will allow the efficient scheduling of work to the most appropriate accelerator."

# Open Questions, Potential Collaborations and Next Steps

* Do you have unusual/real-world applications:
    + that you think we've missed?
    + large applications that could benefit from predictions?
    + where you think the predictions will fail? 
* Quickly test with Docker & Jupyter artefact.
* Building a prototype scheduler using our predictions?
* Access/Interest in other hardware?
* What does this mean for FPGAs?
* Interested in OpenMP, OpenACC or SYCL evaluation or extensions for AIWC?

# Open Questions, Potential Collaborations and Next Steps -- Continued.

* Have suggestions for more/better AIWC metrics -- or think we've missed some?
* Interested in presenting a reduced feature space?
* Think this descriptive tool to guide developers would be useful? Your input would be appreciated!
* Have applications with weird optimization results? Will changes in metrics show this?
* Anyone an expert in OpenACC back-end -- translation to OpenCL kernels for Oclgrind?
* We should collaborate!

# Publications
\begin{itemize}
\small
\item Johnston B and Milthorpe J ``AIWC: OpenCL-based Architecture-Independent Workload Characterisation'', LLVM-HPC workshop, SC18, Dallas, Texas, USA, 2018.
\item Johnston B and Milthorpe J ``Dwarfs on Accelerators: Enhancing OpenCL Benchmarking for Heterogeneous Computing Architectures'', ICPP, Eugene, Oregon, USA, 2018.
\item Johnston B, Falzon G and Milthorpe J ``OpenCL Performance Prediction using Architecture-Independent Features'', HPCS, Orleans, France, 2018.
\item Johnston B and McCreath E ``Parallel Huffman Decoding: Presenting Fast and Scalable Algorithm for Increasingly Multicore Devices'', Guangzhou, China, ISPA 2017.
\item Johnston B, Lee B and Angove L and Rendell A ``Embedded Accelerators for Scientific High-Performance Computing: An Energy Study of OpenCL Gaussian Elimination Workloads'', Bristol, UK, ICPPW 2017.
\normalsize
\end{itemize}

# Thanks

* The University of Bristol’s High Performance Computing Research group for the use of “The Zoo” Research cluster
* Family, friends and supervisors
* You!

\begin{center}
\href{mailto:beau.johnston@anu.edu.au}{beau.johnston@anu.edu.au}
\end{center}

