---
title: OpenCL Performance Prediction using Architecture-Independent Features
author: Beau Johnston$^1$, Greg Falzon$^2$, Josh Milthorpe$^1$
institute: The Australian National University$^1$ \& The University of New England$^2$
date: July 17, 2018 #\today
---

#Trends in Supercomputing -- A view from the Top500

<!-- 20 mins + 5 mins questions -->

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
\item 7 / 10 use accelerators
\item All devices have an OpenCL runtime
\item Newest is Summit -- based on IBM Power9 with NVLINK and CAPI
\end{itemize}
\end{column}
\end{columns}

<!--
Abstract: OpenCL is an attractive programming model for heterogeneous high-performance computing systems, with wide support from hardware vendors and significant performance portability.
To support efficient scheduling on HPC systems it is necessary to perform accurate performance predictions for OpenCL workloads on varied compute devices, which is challenging due to diverse computation, communication and memory access characteristics which result in varying performance between devices.

The Architecture Independent Workload Characterization (AIWC) tool can be used to characterize OpenCL kernels according to a set of architecture-independent features.
This work presents a methodology where AIWC features are used to form a model capable of predicting accelerator execution times.
We used this methodology to predict execution times for a set of 37 computational kernels running on 15 different devices representing a broad range of CPU, GPU and MIC architectures.
The predictions are highly accurate, differing from the measured experimental run-times by an average of only 1.2\%, and correspond to actual execution time mispredictions of 9 $\mu$s to 1 sec according to problem size.
A previously unencountered code can be instrumented once and the AIWC metrics embedded in the kernel, to allow performance prediction across the full range of modelled devices.
The results suggest that this methodology supports correct selection of the most appropriate device for a previously unencountered code, which is highly relevant to the HPC scheduling setting.
-->

# OpenCL -- The Language of Heterogeneous Computing

* Open Computing Language (OpenCL) is an open standard.
* Allows computationally intensive codes -- kernels -- to be written once and run on any compliant accelerator.
* Most vendors are compliant to basic standards.
* Application code can be written directly in OpenCL, and
* Can be used as a back-end for higher level languages -- OpenMP runtime implemented for TI Keystone II DSP architecture\footnote{Mitra, G. et al. 2014. Implementation and optimization of the OpenMP accelerator model for the TI Keystone II architecture. International workshop on openmp (2014), 202–214.}.
* Increased relevancy for FPGA programming

# Extended Open Dwarfs Benchmark Suite

* Extended Open Dwarfs (EOD) Benchmark Suite
* Based off the OpenDwarfs benchmark suite\footnote{Krommydas, K. {OpenDwarfs}: Characterization of dwarf-based benchmarks on fixed and reconfigurable architectures. Journal of Signal Processing Systems, vol. 85, no. 3, pp. 373-392, 2016}
* Benchmarks selected following diversity analysis and 13 Berkeley Dwarfs taxonomy
* Built in OpenCL
* Purpose of OpenDwarfs was a to characterize a diverse set of parallel applications and architectures using a common language, but had deficiencies...

# EOD Extensions

* Diverse:
    - 4 different problem sizes per application
    - Added applications -- currently 11 <!--fft and dwt--> and 37 kernels
* Reproducible: Minimum of 2 sec runs per benchmark
* Precise:
    - High resolution timers with LibSciBench <!--TODO: cite -->
    - Reported with one cycle resolution and roughly 6 ns of overhead
* Portable:
    - Based on an OpenCL backend
    - Tested on a wide range of hardware

<!-- so we can measure short running kernel codes -->

# Applications

\begin{table}
\centering
\caption{List of Extended OpenDwarfs Applications and their respective dwarfs}
\begin{adjustbox}{max width=0.7\textwidth}
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

<!--
%slides from tpr
#Dwarfs on Accelerators -- Extending the OpenDwarfs Benchmark Suite

* Having shown the suitability of OpenCL, the need for a diverse, portable and configurable benchmark suite was identified.
* Specifically for the long term autonomous scheduling goal!
* A comparative study was made between:
    + Rodinia
    + SHOC
    + OpenDwarfs
* OpenDwarfs was selected because:
    + focused on OpenCL implementation, SHOC and Rodinia offered several implementations of the same algorithm, which often resulted in the OpenCL implementation lacking functionality,
    + developed after Rodinia and SHOC, as such many applications were taken from them
    + covered a wider range of dwarfs -- only lacking Map Reduce

# Dwarfs on Accelerators -- Extending the OpenDwarfs Benchmark Suite -- Continued...

*Dwarfs on Accelerators: Enhancing OpenCL Benchmarking for Heterogeneous Computing Architectures*
Submitted: November, 2017 for February, 2018 for the 9^th^ International Workshop on Programming Models and Applications for Multicores and Manycores (PMAM 2018), Vösendorf, Austria.

* Present an extended and enhanced version of the OpenDwarfs OpenCL benchmark suite, with a strong focus on:
    + robustness of applications,
    + curation of additional benchmarks with an increased emphasis on correctness of results, and
    + an increased problem size diversity within each application.
* Results and analysis are reported for eight benchmark codes on a representative set of current architectures.


# Dwarfs on Accelerators -- Robustness

* Added testing and support between accelerators and workloads, 
* easily accessed high precision timers important for reproducible research results,
* LibSciBench was added to all applications for accelerator execution times but also hardware events and energy measurements.
* Standardised support of workgroup size arguments was added,

# Problem Size Diversity

* Selection of problem size is critically affects HPC benchmarking.
* Highest impact on CPU architectures.
* A major contribution of the work is facilitating 4 different problem sizes for all applications presented in the suite.
* Selected according to levels of cache
    - **tiny** : < 32 KiB L1
    - **small**: < 256 KiB L2
    - **medium**: < 8192 L3
    - **large**: > 8192 L3
-->

# Hardware

\begin{table}
\begin{adjustbox}{center, width=.7\textwidth}
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
* Forms a large sample of response times

# Overview of AIWC

* Architecture-Independent Workload Characterisation (AIWC)
* Plugin for OclGrind -- an Extensible OpenCL device simulator\footnote{J. Price and S. McIntosh-Smith, “Oclgrind: An extensible opencl device simulator,” in Proceedings of the 3rd International Workshop on OpenCL, 2015, p. 12.}
* Beta available -- <https://github.com/BeauJoh/Oclgrind> -- and will be merged into default OclGrind

# Overview of AIWC -- Continued

* Simulation of OpenCL kernels occur on LLVM IR -- SPIR
* AIWC tracks and measures hardware agnostic events
* Large number of metrics collected (34)
* Over a wide spectrum computation, thread communication and memory access patterns

# Overview of AIWC -- Sample

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item 4 major types: Compute, Parallelism, Memory, Control
\item Various number of metrics per type: based on statistical measurements -- distributions, entropy and absolute counts
%\item See right for a visual sample of the AIWC feature-space -- reduced and normalised:
\end{itemize}
\end{column}
\begin{column}{0.5\textwidth}
\begin{center}
%<!--Regenerate by running ~/Documents/2018/grinding-dwarfs-and-examining-the-remains/analysis_tools/standalone_for_slides.R-->
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/standalone_for_slides}
\end{figure}
\end{center}
\end{column}
\end{columns}

# Modelling -- EOD and AIWC

* Development of a regression model can now occur!
* AIWC's 34 metrics form input variables
* EOD response variables
* R language and Ranger\footnote{M. Wright and A. Ziegler, “ranger: A Fast Implementation of Random Forests for High Dimensional Data in C++ and R,” Journal of Statistical Software, Articles, vol. 77, no. 1, pp. 1–17, 2017.} -- a Random Forest implementation --  was used
* performs recursive partitioning of high dimensional data
* accepts 3 parameters:
    - num.trees -- number of trees grown in forest -- 10-10k by 500
    - mtry -- number of features tried to split in a node -- 1-34
    - min.node.size -- minimal size per tree -- 1-50
* optimal model needs careful tuning

# min.node.size

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/full-variation-in-min-node-size-1}
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
\end{figure}
\end{column}
\end{columns}

# Choosing Parameters for the Future

* num.trees=500, mtry=32, and min.node.size=9 look good
* train on a random selection of N kernels and test on remainder
* see paper for details but final values are num.trees = 505, mtry = 30 and min.node.size = 9

# Increased Training Data

\begin{columns}
\begin{column}{0.5\textwidth}
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/rmse_vs_kernel_count-1}
\end{figure}
\end{column}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item How many kernels to add for training -- what's enough?
\item Another study performed to see how error changes w.r.t. number of kernels in training
\item Uses random selection for each random count -- again see paper for full details
\item Error tapers off for more kernels!
\item gradient still significant at 37 kernels -> could still benefit from more.
%<!--item However, the model proposed is a proof of concept and suggests that a general purpose model is attainable and may not require many more kernels. -->
\end{itemize}
\end{column}
\end{columns}

# Prediction Accuracy

\begin{figure}
    \includegraphics[width=0.8\textwidth,height=0.9\textheight]{figures/actual-vs-predicted-size-plot-1}
\end{figure}

<!-- outliers are visually over-represented in this figure as the final mean absolute error is low, at ~0.1 -->

<!--
\begin{columns}
\begin{column}{0.5\textwidth}
\begin{figure}
    \includegraphics[width=1\textwidth]{figures/actual-vs-predicted-size-plot-1}
\end{figure}
\end{column}
\begin{column}{0.5\textwidth}
\begin{itemize}
\item Linear!
\item Linear!
\item gradient still significant at 37 kernels -> could still benefit from more.
\end{itemize}
\end{column}
\end{columns}
-->


# Prediction Accuracy -- Continued

\begin{figure}
    \includegraphics[width=0.85\textwidth,height=0.9\textheight]{figures/predictive-heatmap-percentage-1-rot}
\end{figure}

# Predicting for Scheduling

\begin{columns}
\begin{column}{0.75\textwidth}
\begin{figure}
    \includegraphics[width=\textwidth]{figures/large-predicted-vs-measured-1}
\end{figure}
\end{column}
\begin{column}{0.25\textwidth}
\begin{itemize}
%\item Mean measured kernel execution times compared against mean predicted kernel execution times to perform a selection of kernels on large problem sizes across 15 accelerator devices.
\item 4 random kernels.
\item square $\rightarrow$ mean measured time
\item diamond $\rightarrow$ mean predicted time
\item order is important!
\end{itemize}
\end{column}
\end{columns}

# Conclusions

* A highly accurate model for predicting execution times of OpenCL kernels based on the computational characteristics captured by the AIWC tool.
* A real-world ready: workflow of AIWC, needed for scheduling -- the predictions are accurate enough for this task.
* More applications should be examined to improve model accuracy till plateau.
* Next step: apply same methodology to energy \pause

\begin{itemize}
\item Anyone work with schedulers/runtime-systems? Build them? Help me! A prototype scheduler is needed.
\item What about new hardware -- Especially FPGA? Spare hours on a super-computer? We should collaborate.
\end{itemize}

<!--TODO: goal of the future work should be to develop contacts in community, collaboration with researchers with HPC scheduling expertise, the model and prototype scheduler needs to be evaluated on used for both node-level and up to many nodes as seen in supercomputers, access to HPC hardware to evaluate the new prototype scheduler, increase the adoption of AIWC for other applications -- offers insights into program behaviour which may also useful for compiler optimisations-->

# Thanks

* The University of Bristol’s High Performance Computing Research group for the use of “The Zoo” Research cluster
* Oracle
* ANU VC Travel Grant
* You!

\begin{center}
\href{mailto:beau.johnston@anu.edu.au}{beau.johnston@anu.edu.au}
\end{center}
