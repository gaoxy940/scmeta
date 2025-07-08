#### SET HELP ####
help.snp <- fluidPage(
  fixedRow(
        class = "scrollable-container",
    column(width = 11,
           h3('SNP & Subspecies'), br(),
           
           p(style = 'word-break:break-word',
             '
             SNP analysis of microbial samples was conducted using Snippy (version 4.6.0).
             Snippy can rapidly detect single-nucleotide polymorphisms (SNPs) and insertion-deletion mutations (indels) by comparing a reference genome to next-generation sequencing (NGS) reads. 
             Developed by Torsten Seemann at the University of Melbourne, Australia, Snippy is widely utilized in genomic variation analysis, particularly in the fields of microbial genomics and pathogen genomic variation studies.
             '
           ),
           p(style = 'word-break:break-word',
             '
             SNP analysis is based on the results of the Species Annotation module. Please select the corresponding species samples. If no samples are found, an error message will appear: "Unable to find the corresponding annotation information. Please run the \"Species Annotation\" module first!"
             '
           ),
           p(style = 'word-break:break-word',
             '
             We provide a demo example to help users become more quickly acquainted with the operation and functionality of this module. Click "Upload the SNP Exemplar" for a demonstration.
             '
           ),
           
           hr(),
           
           tags$ol(
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_ui_01.png'), br(), br(),
             tags$li(tags$b('Select the species for SNP analysis:'), br(),
                     '
                     The species to be analyzed must be identified prior to conducting SNP analysis. 
                     Choose a different species hierarchy, and the following text box will automatically display the species names, from which the user can select one.
                     '
                     ), br(),

             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_ui_02.png'), br(), br(),
             tags$li(tags$b('Upload the Reference Genome:'), br(),
                     'There are two options available. The first is to use the demo we have provided, which is designed to help users quickly become familiar with the operation and functions of the module. 
                     The second option is to upload the reference genome downloaded from databases such as GenBank locally.'), br(),
             tags$li(tags$b('Run SNP Analysis:'), br(),
                     'Click the button to execute the operation.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_ui_03.png'), br(), br(),
             tags$li(tags$b('Show Sample SNP Sites:'), br(),
                     'The distribution of SNPs in individual bacterial genomes is visualized using circular plots to intuitively compare mutational differences among bacterial samples.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_ui_04.png'), br(), br(),
             tags$li(tags$b('Subspecies Identification:'), br(),
                     'Subspecies identification of microbial samples can be achieved through hierarchical clustering based on Core SNPs. 
                     This approach elucidates the genetic structure of microbial populations by calculating genetic distances between samples and grouping them into distinct subgroups.'), br(),
             tags$li(tags$b('Selection of genetic distance methods:'), br(),
                     'The genetic distance between samples was calculated based on Core SNPs for clustering. Here are three methods to calculate it:
                        A. Bray-Curtis Distance of 5-mers: The set of 5-mers derived from base strings for each sample mutation site was calculated. The distance matrix is computed using the vegdist function from the R package vegan (method: Bray).
                        B. Jaccard Distance of 5-mers: The distance matrix is calculated using the VEGDIST function from the R package vegan (method: Jaccard) based on the set of 5-mers.
                        C. BLAST Scoring Matrix: The BLAST scoring matrix is a widely used tool for evaluating DNA substitutions. It is derived from a substantial number of comparisons, assigning a score of +2 for matches and -3 for mismatches. The distance matrix is calculated by the dist function (method: Manhattan) .'), br(),
             tags$li(tags$b('Please enter the number of clusters:'), br(),
                     'user can customize the number of clusters.'), br(),
             tags$li(tags$b('Clustering & Show HeatMAP:'), br(),
                     'Perform clustering analysis and present the results in the form of a heatmap.'), br(),

             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_ui_05.png'), br(), br(),
             tags$li(tags$b('Difference Analysis Based on HeatMAP-Clusters:'), br(),
                     'Analyzing the differences in cluster results between groups.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_ui_06.png'), br(), br(),
             tags$li(tags$b('Construct the Phylogenetic Tree:'), br(),
                     'Phylogenetic trees were constructed by comparing multiple samples to a single reference genome.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_genome_circle.png'), br(), br(),
             tags$li(tags$b('Genome Circle:'), br(),
                     'A Circle graph illustrating the density of single nucleotide polymorphisms (SNPs) at various locations in the reference genome for all samples. 
                     From the outside to the inside, the first circle displays the reference genome sequence information, including the sequence name (ID) and the positional scale. 
                     The second circle represents the GC content curve of the reference genome sequence, with a dotted line indicating the average GC content. 
                     The third circle depicts the SNP density distribution, utilizing a 2000 bp sliding window across the genome to statistically calculate the total number of SNPs in each interval; darker colors indicate a higher density of SNPs. 
                     The legend provides basic information about the reference genome, along with a brief summary of the SNP detection results, including the types and numbers of base substitutions, the base conversion/transversion ratio, and additional relevant statistics.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_sample_circle.png'), br(), br(),
             tags$li(tags$b('Sample Circle:'), br(),
                     'A Circle graph illustrating the distribution of mutation sites across samples. Up to three samples can be plotted simultaneously for comparison. 
                     The points on the graph represent single nucleotide polymorphisms (SNPs) or insertion-deletion (InDel) loci, with colors indicating different variant types (for example, A>C|T>G substitutions for SNPs). 
                     Each point corresponds to a scale on the outer circle, which indicates the position of the mutation site on the genome, while the value on the longitudinal axis reflects the quality of the mutation site.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_snp_heatmap.png'), br(), br(),
             tags$li(tags$b('HeatMAP:'), br(),
                     'The heatmap primarily illustrates the mutation status of the sample genomes, with mutated sites indicated in red and non-mutated sites in blue.
                     The color changes in the heatmap allow users to easily compare mutation patterns among different samples, identify similarities and differences, and quickly pinpoint mutation hotspots, thereby understanding which genomic locations are frequently mutated. 
                     Clustering heatmaps can reveal clusters with similar characteristics, potentially highlighting the generalizability of certain mutations within specific sample clusters. This information may serve as potential biomarkers and enhance the effectiveness of follow-up analyses.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_snp_tree.png'), br(), br(),
             tags$li(tags$b('Tree:'), br(),
                     'The phylogenetic tree was constructed using FastTree (version 2.1.11), and the tree grouping was based on heat map clustering.
                     Tree maps visually represent the evolutionary distances and affinities between different microbial samples, revealing clustering patterns and helping to identify specific microbial groups or taxa.'), br(),
             
             ####
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_snp_matrix.png'), br(), br(),
             tags$li(tags$b('SNP Matrix:'), br(),
                     '
                     The SNP matrix for samples includes the following components: 
                     CHR, which denotes the chromosome number of the reference genome; 
                     POS, which indicates the specific location of the mutation on the chromosome; 
                     and REF, which represents the base on the reference genome. 
                     Each subsequent column corresponds to the base of each sample, allowing for a comparison with REF to determine whether a mutation has occurred at this location.
                     The last column contains detailed mutation information for each sample. 
                     '), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_heatmap_cluster.png'), br(), br(),
             tags$li(tags$b('Heatmap Cluster Table:'), br(),
                     'Clustering Information for Samples.'), br(),
             br(), br(), img(class='img-thumbnail', src = 'help_image/snp/image_cluster_diff.png'), br(), br(),
             tags$li(tags$b('DiffAnalysis Table:'), br(),
                     'Analysis of inter-cluster differences.'), br(),

           )
    )
  )
)
