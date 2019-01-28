
\addappheadtotoc
\appendixpage
\appendixtitleon
\appendixtitletocon

\begin{appendices}
\chapter{Time Results}

The results are colored according to accelerator type: purple for CPU devices, blue for consumer GPUs, green for HPC GPUs, and yellow for the KNL MIC.
Execution times for \texttt{crc} are lowest on CPU-type architectures, probably due to the low floating-point intensity of the CRC computation\[Ch. 6\][@joshi2016thesis].
Excluding \texttt{crc}, all the other benchmarks perform best on GPU type accelerators; furthermore, the performance on the KNL is poor due to the lack of support for wide vector registers in Intel's OpenCL SDK.
We, therefore, omit results for KNL for the remaining benchmarks.

Figures\ \ref{fig:tiny-and-small-time},\ \ref{fig:medium-and-large-time},\ \ref{fig:tiny-and-small-time2} and\ \ref{fig:medium-and-large-time2} shows the distribution of kernel execution times for the remaining benchmarks.
The **tiny** and **small** sizes for the `kmeans`, `lud`, `csr` and `dwt` benchmarks are presented in Figure\ \ref{fig:tiny-and-small-time} results, the **medium** and **large** problem sizes are presented in Figure\ \ref{fig:medium-and-large-time}.
Similarly, the final three applications which support multiple problem sizes -- \texttt{fft}, \texttt{srad} and \texttt{nw} -- display the time results for **tiny** and **small** in Figure\ \ref{fig:tiny-and-small-time2}, and **medium** and **large** times are shown in Figure\ \ref{fig:medium-and-large-time2}.
Some benchmarks execute more than one kernel on the accelerator device; the reported iteration time is the sum of all compute time spent on the accelerator for all kernels.
Each benchmark corresponds to a particular dwarf: 
From Figures\ \ref{fig:tiny-and-small-time} and \ref{fig:medium-and-large-time} (a) (\texttt{kmeans}) represents the MapReduce dwarf,
(b) (\texttt{lud}) represents the Dense Linear Algebra dwarf,
(c) (\texttt{csr}) represents Sparse Linear Algebra, 
(d)  (\texttt{dwt}) and from Figures\ \ref{fig:tiny-and-small-time2}\ (a) and \ref{fig:medium-and-large-time2}\ (a) (\texttt{fft}) represent Spectral Methods,
(b) (\texttt{srad}) represents the Structured Grid dwarf and (c) (\texttt{nw}) represents Dynamic Programming.

Finally, Figure \ref{fig:time3} presents results for the four applications with restricted problem sizes and only one problem size is shown.
The N-body Methods dwarf is represented by (\texttt{gem}) and the results are shown in Figure \ref{fig:time3}\ (a), the Backtrack \& Branch and Bound dwarf is represented by the (\texttt{nqueens}) application in Figure \ref{fig:time3}\ (b), (\texttt{hmm}) results from Figure \ref{fig:time3}\ (c) represent the Graphical Models dwarf and (\texttt{swat}) from Figure \ref{fig:time3}\ (d) also depicts the Dynamic Programming dwarf.

Examining the transition from tiny to large problem sizes in Figures \ref{fig:tiny-and-small-time2}\ (b) and \ref{fig:medium-and-large-time2}\ (b) shows the performance gap between CPU and GPU architectures widening for \texttt{srad} -- indicating codes representative of structured grid dwarfs are well suited to GPUs.

In contrast, \texttt{nw} -- (b) from Figures\ \ref{fig:tiny-and-small-time2} and\ \ref{fig:medium-and-large-time2} -- shows that the Intel CPUs and NVIDIA GPUs perform comparably for all problem sizes, whereas all AMD GPUs exhibit worse performance as size increases. This suggests that performance for this Dynamic Programming problem cannot be explained solely by considering accelerator type and may be tied to micro-architecture or OpenCL runtime support.

For most benchmarks, the variability in execution times is greater for devices with a lower clock frequency, regardless of accelerator type.
While execution time increases with problem size for all benchmarks and platforms, the modern GPUs (Titan X, GTX1080, GTX1080Ti, R9 Fury X and RX 480) performed relatively better for large problem sizes, possibly due to their greater second-level cache size compared to the other platforms. A notable exception is \texttt{kmeans} for which CPU execution times were comparable to GPU, which reflects the relatively low ratio of floating-point to memory operations in the benchmark.

Generally, the HPC GPUs are older and were designed to alleviate global memory limitations amongst consumer GPUs of the time.
(Global memory size is not listed in Table \ref{tbl:hardware}.)
Despite their larger memory sizes, the clock speed of all HPC GPUs is slower than all evaluated consumer GPUs.
While the HPC GPUs (devices 7-9, in green) outperformed consumer GPUs of the same generation (devices 4-6 and 10-13, in blue) for most benchmarks and problem sizes, they were always beaten by more modern GPUs.
This is no surprise since all selected problem sizes fit within the global memory of all devices.

A comparison between CPUs (devices 1-3, in purple) indicates the importance of examining multiple problem sizes.
Medium-sized problems were designed to fit within the L3 cache of the i7-6700K system, and this conveniently also fits within the L3 cache of the Xeon E5-2697 v2.
However, the older i5-3550 CPU has a smaller L3 cache and exhibits worse performance when moving from small to medium problem sizes, and is shown in (b),(d) and (e) in Figures\ \ref{fig:tiny-and-small-time} and\ \ref{fig:medium-and-large-time}, and in (a) from Figures\ \ref{fig:tiny-and-small-time2} and \ref{fig:medium-and-large-time2}.

Increasing problem size also hinders the performance in certain circumstances for GPU devices.
For example, (b) from Figures\ \ref{fig:tiny-and-small-time2} and \ref{fig:medium-and-large-time2} shows a widening performance gap over each increase in problem size between AMD GPUs and the other devices.

Predicted application properties for the various Berkeley Dwarfs are evident in the measured runtime results.
For example, Asanović et al. [@asanovic2006landscape] state that applications from the Spectral Methods dwarf is memory latency limited.
If we examine \texttt{dwt} and \texttt{fft} -- the applications which represent Spectral Methods -- in Figure \ref{fig:medium-and-large-time}\ (d) and Figure\ \ref{fig:medium-and-large-time2}\ (a) respectively, we see that for medium problem sizes the execution times match the higher memory latency of the L3 cache of CPU devices relative to the GPU counterparts.
The trend only increases with problem size: the large size shows the CPU devices frequently accessing main memory while the GPUs' larger memory ensures a lower memory access latency.
It is expected if had we extended this study to an even larger problem size that would not fit on GPU global memory, much higher performance penalties would be experienced over GPU devices, since the PCI-E interconnect has a higher latency than a memory access to main memory from the CPU systems.
As a further example, Asanović et al. [@asanovic2006landscape] state that the Structured Grid dwarf is memory bandwidth limited.
The Structured Grid dwarf is represented by the \texttt{srad} benchmark shown in Figure\ \ref{fig:medium-and-large-time2} (b).
GPUs exhibit lower execution times than CPUs, which would be expected in a memory bandwidth-limited code as GPU devices offer higher bandwidth than a system interconnect.


\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/tiny_and_small_times_for_kmeans_lud_csr_dwt}
    \caption{Kernel execution times for the \textbf{tiny} and \textbf{small} problem sizes of the \texttt{kmeans}, \texttt{lud}, \texttt{csr} and \texttt{dwt} benchmarks on different hardware platforms}
    \label{fig:tiny-and-small-time}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/medium_and_large_times_for_kmeans_lud_csr_dwt}
    \caption{Kernel execution times for the \textbf{medium} and \textbf{large} problem sizes of the \texttt{kmeans}, \texttt{lud}, \texttt{csr} and \texttt{dwt} benchmarks on different hardware platforms}
    \label{fig:medium-and-large-time}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/tiny_and_small_times_for_fft_srad_nw}
    \caption{Kernel execution times for the \textbf{tiny} and \textbf{small} problem sizes of the \texttt{fft}, \texttt{srad} and \texttt{nw} benchmarks on different hardware platforms}
    \label{fig:tiny-and-small-time2}
\end{figure*}

\begin{figure*}
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/chapter-3/medium_and_large_times_for_fft_srad_nw}
    \caption{Kernel execution times for the \textbf{medium} and \textbf{large} problem sizes of the \texttt{fft}, \texttt{srad} and \texttt{nw} benchmarks on different hardware platforms}
    \label{fig:medium-and-large-time2}
\end{figure*}

\chapter{Diversity Analysis}
\label{appendix:diversity-analysis}

A brief overview of the diversity analysis conducted is presented in this appendix.
Features from AIWC are used as the predictor variables in the random forest model -- presented in Chapter 5.
This model was trained from the combined results of all application kernels and all problem sizes.
In this section the predictor variables are examined independently to evaluate the variances between kernels and problem sizes in the AIWC feature-space.

Evaluation uses dimensionality reduction techniques, from Principal Component Analysis (PCA) and t-Distributed Stochastic Neighbor Embedding (t-SNE).
The feature-space reduction methods allows the determination of the loading, or relative contributions, of each component metric.
t-SNE is a machine learning visualization algorithm used to find the optimal projection of high dimensional data into two dimensional point by a way that similar objects are modeled by nearby points and dissimilar objects are modeled by distant points with high probability.
On the t-SNE visualization use k-means clustering to present the grouping between features.

From the PCA biplot in Figure\ \ref{fig:pca-biplot} we can determine that Total Memory Footprint, any of the branch entropy metrics and one of the memory address entropy variables are the 3 most principal components to be used when forming a predictive model.
The proportion of variance of each principal component is presented in Figure\ \ref{fig:pca-variance} and shows these 3 principal components can cover 95\% of the contributions of difference in a 19 dimensional AIWC feature-space, 5 principal components represent \~98\% variance in the data and 6 variables cover more than 99\%.
Similarly, the t-SNE clustering, from Figure \ref{fig:tsne-kmeans}, tell a similar story, namely, 5-6 features convey a majority of the information.
There is clearly a cluster structure in the manifold -- which is good news for prediction -- but there is also 2 interesting linear strings structures (correlations) – which suggests that one method of regression or prediction will not suffice.
The visualization and the same methodology can be used to justify the inclusion of a new benchmark, for instance, if an application kernel extends the coverage in the projection.

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/appendix/generate_pca_biplot-1.pdf}
    \caption{Biplot Principal Components of AIWC metrics over all application kernels and all problem sizes.}
    \label{fig:pca-biplot}
\end{figure*}

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/appendix/generate_pca_contributions-1.pdf}
    \caption{The proportion of explained variance of each Principal Component.}
    \label{fig:pca-variance}
\end{figure*}

\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth,keepaspectratio]{figures/appendix/show_kmeans_result-1.pdf}
    \caption{The t-SNE with k-means cluster results to show Principal Components.}
    \label{fig:tsne-kmeans}
\end{figure*}

%\begin{figure*}[t]
%    \centering
%    \includegraphics[width=\textwidth,keepaspectratio]{figures/appendix/show_hierarchical_result-1.pdf}
%    \caption{The t-SNE with hierarchical clustering to show Principal Components.}
%    \label{fig:tsne-hierarchical}
%\end{figure*}

\end{appendices}

<!--
\appendix

#Runtimes

\appendix

#Diversity and 
-->
