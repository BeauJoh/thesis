












\begin{figure*}
\centering
\iftoggle{ACM-BUILD}{
%acm
\includegraphics[width=2\columnwidth]{./figure/draw_stacked_plots-1.pdf}
}{}
\iftoggle{IEEE-BUILD}{
%ieee
\includegraphics[width=1.98\columnwidth]{./figure/draw_stacked_plots-1.pdf}
}{}
\iftoggle{LNCS-BUILD}{
%llncs
\includegraphics[width=0.95\textwidth,height=0.95\textheight,keepaspectratio]{./figure/draw_stacked_plots-1.pdf}
}{}
\caption{Selected AIWC metrics from each category over all kernels and 4 problem sizes.}
\label{fig:stacked_plots} 
\end{figure*}













\begin{figure*}
    \centering
    \newcommand{\plotwidth}{0.66\textwidth}
    \includegraphics[width=\plotwidth]{./figure/draw_lud_diagonal_internal_all_kiviat-1.pdf}
    \caption{A) and B) show the AIWC features of the \texttt{diagonal} and \texttt{internal} kernels of the LUD application over all problem sizes.}
    \label{fig:kiviat}
\end{figure*}

\begin{figure*}
    \centering
    \newcommand{\plotwidth}{0.66\textwidth}
    \includegraphics[width=\plotwidth]{./figure/draw_lud_diagonal_perimeter_lmae_all_kiviat-1.pdf}
    \caption{A) shows the AIWC features of the \texttt{perimeter} kernel of the LUD application over all problem sizes. B) shows the corresponding Local Memory Address Entropy for the \texttt{perimeter} kernel over the tiny problem size.}
    \label{fig:kiviat2}
\end{figure*}

##Detailed Analysis of LU Decomposition Benchmark

We now proceed with a more detailed investigation of one of the benchmarks, **lud**, which performs decomposition of a matrix into upper and lower triangular matrices.
Following Shao and Brooks [@shao2013isa], we present the AIWC metrics for a kernel as a Kiviat or radar diagram, for each of the problem sizes.
Unlike Shao and Brooks, we do not perform any dimensionality reduction but choose to present all collected metrics.
The ordering of the individual spokes is not chosen to reflect any statistical relationship between the metrics, however, they have been grouped into four main categories: green spokes represent metrics that indicate *parallelism*, blue spokes represent *compute* metrics, beige spokes represent *memory* metrics and purple spokes represent *control* metrics.
For clarity of visualization, we do not present the raw AIWC metrics but instead, normalize or invert the metrics to produce a scale from 0 to 1.
The parallelism metrics presented are the inverse values of the metrics collected by AIWC, i.e. **granularity** =  $1 / \textbf{work-items}$ ; **barriers per instruction** $= 1 / \textbf{mean ITB}$ ; **instructions per operand** $= 1 / \sum \textbf{SIMD widths}$.

Additionally, a common problem in parallel applications is load imbalance -- or the overhead introduced by unequal work distribution among threads.
A simple measure to quantify imbalance can be achieved using a subset of the existing AIWC metrics and is included as a further derived parallelism metric by computing **load imbalance** = **max IPT** $-$ **min IPT**.

All other values are normalized according to the maximum value measured across all kernels examined -- and on all problem sizes.
This presentation allows a quick value judgement between kernels, as values closer to the centre (0) generally have lower hardware requirements, for example, smaller entropy scores indicate more regular memory access or branch patterns, requiring less cache or branch predictor hardware; smaller granularity indicates higher exploitable parallelism; smaller barriers per instruction indicates less synchronization; and so on.

The **lud** benchmark application comprises three major kernels, **diagonal**, **internal** and **perimeter**, corresponding to updates on different parts of the matrix.
The AIWC metrics for each of these kernels are presented -- superimposed over all problem sizes -- in [Figure @fig:kiviat] A) B) and [Figure @fig:kiviat2] A) respectively.
Comparing the kernels, it is apparent that the diagonal and perimeter kernels have a large number of branch instructions with high branch entropy, whereas the internal kernel has few branch instructions and low entropy.
This is borne out through inspection of the OpenCL source code: the internal kernel is a single loop with fixed bounds, whereas diagonal and perimeter kernels contain doubly-nested loops over triangular bounds and branches which depend on thread id.
Comparing between problem sizes (moving across the page), the large problem size shows higher values than the tiny problem size for all of the memory metrics, with little change in any of the values.

The visual representation provided from the Kiviat diagrams allows the characteristics of OpenCL kernels to be readily assessed and compared.

Finally, we examine the linear memory access entropy (LMAE) presented in the Kiviat diagrams in greater detail.
[Figure @fig:kiviat2] B) presents a sample of the linear memory access entropy, in this instance of the LUD Perimeter kernel collected over the tiny problem size.
The kernel is launched 4 separate times during a run of the tiny problem size, this is application specific and in this instance, each successive invocation operates on a smaller data set per iteration.
Note there is a steady decrease in starting entropy, and each successive invocation of the LU Decomposition Perimeter kernel the lowers the starting entropy.
However, the descent in entropy -- which corresponds to more bits being skipped, or bigger the strides or the more localized the memory access -- shows that the memory access patterns are the same regardless of actual problem size.
In general, for cache-sensitive workloads -- such as LU-Decomposition -- a steeper descent between increasing LMAE distances indicates more localized memory accesses, and this corresponds to better cache utilisation when these applications are run on physical OpenCL devices.
It is unsurprising that applications with a smaller working memory footprint would exhibit more cache reuse with highly predictable memory access patterns.

<!-- OpenCL Performance Prediction using Architecture-Independent Features HPCS-DRSN -->
Recently, AIWC has been used for predictive modelling on a set of 15 compute devices including CPUs, GPUs and MIC.
The AIWC metrics generated from the full set of Extended OpenDwarfs kernels were used as input variables in a regression model to predict kernel execution time on each device. [@johnston18predicting]
The model predictions differed from the measured experimental results by an average of 1.1%, which corresponds to actual execution time mispredictions of 8 $\mu$s to 1 second according to problem size.
From the accuracy of these predictions, we can conclude that while our choice of AIWC metrics is not necessarily optimal, they are sufficient to characterize the behaviour of OpenCL kernel codes and identify the optimal execution device for a particular kernel.


#Conclusions and Future Work

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
<!--If Oclgrind is compiled with levelDB -- a lightweight open-source database library for persistence -- the memory-light version of AIWC is used.-->

<!--\todo[inline]{
However the memory light work is still under-development but is very close to being finished. It can be completed in time for the camera-ready.
\todo[inline]{*Josh* had an idea that AIWC could be used to show cache sensitive vs cache oblivious workloads -- this could be mentioned in future work}

\todo[inline]{several typos and missing commas -- run grammarly}
\todo[inline]{discuss the considerations of how these metrics were chosen differ from Shao, what do we add to the theory about instrumenting parallel workloads?}
\todo[inline]{include a jupyter artefact}

\todo[inline]{Open review questions still to address:}
\todo[inline]{*Josh* Where should we address reviewer 1s question: How would you generalize the normalization of the metrics with the max over all measured applications? What would this be for a larger (or unknown) set of applications?}
\todo[inline]{motivate why these metrics and not others are relevant}
\todo[inline]{why the selected configuration parameters are chosen and not others.}
\todo[inline]{Especially given that the measured metrics show a significant change with respect to problem size and likely also with the parallelism involved (number of processing elements), what insights can be gained from their analysis?}
\todo[inline]{Is any beahvior simulated generalizable or must each separate configuration be analyzed on its own?}
\todo[inline]{A further concern is whether this methodology only works on small kernels or on real applications as well.}
\todo[inline]{Would the increased complexity from a real HPC application preclude, inhibit, or otherwise affect the use of AIWC? A case study with a real application would help me alleviate these concerns.}
\todo[inline]{It is not clear to this reviewer how such claims can be made about kernels based primarily on branching metrics, as most processors, including GPUs, can perform well even when code contains branching (this may have been different in the past). In this reviewer's experience, rarely is branching the determining factor as to whether an application is suitable for an accelerator, so I feel the paper needs to attempt to convince the audience otherwise.}
\todo[inline]{This paper could be greatly improved if there was more extensive work on use cases for the tool, for instance discussing the metrics of larger or more diverse kernels, or those notoriously challenging for manual analysis. This would also need to be backed up with more quantitative and objective analysis of the metrics.}
\todo[inline]{This approach is of course a suggestion and there might be other ways to present the work, but as it stands it appears to lack novel contribution beyond the implementation. Implementing a tool to collect metrics is useful; however, proving the tool can provide insights for modern HPC applications would make solid research suitable for the conference audience.}
-->

#References

