
\addappheadtotoc
\appendixpage
\appendixtitleon
\appendixtitletocon

\begin{appendices}
\chapter{Time Results}

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
