library(ggplot2)

#Define some global variables.

plink_path = "/home/ssharma454/miniconda3/envs/stable/bin/plink"
genome_bed_file_prefix = "/home/ssharma454/BIOL8803/class-notebooks/shinyAppPCA/1KGP/extractedChrAll.Pruned"
default_eigenvec_prefix = "/home/ssharma454/BIOL8803/class-notebooks/shinyAppPCA/1KGP/extractedChrAll.Pruned.PCA.eigenvec"
temp_dir_path = "/home/ssharma454/BIOL8803/class-notebooks/shinyAppPCA/1KGP/tmp/"


##############################################################################################################################
#Read the default eigen vector file and keep it in a df.
default_eigenvec <- read.table(default_eigenvec_prefix, header = F, sep = ' ')

#Get the samples names and pops out.
default_eigenvec_left = default_eigenvec[,1:2]
colnames(default_eigenvec_left) = c("Pop", "SampleID")

#Get the PCs values out.
default_eigenvec_right = default_eigenvec[,3:ncol(default_eigenvec)]
colnames(default_eigenvec_right) <- paste('PC', c(1:10), sep = '')
default_eigenvec = cbind(default_eigenvec_left, default_eigenvec_right)

default_eigenvec = within(default_eigenvec, ContinentalPopulation <- 
                          ifelse(Pop %in% c("GIH","STU","ITU","BEB","PJL"), "SouthAsian", 
                             ifelse(Pop %in% c("CHB","JPT","KHV","CDX","CHS"), "EastAsian", 
                                             ifelse(Pop %in% c("GBR","CEU","FIN","TSI","IBS"), "European",
                                                     ifelse(Pop %in% c("ESN","YRI","GWD","MSL","LWK"), "African",
                                                                ifelse(Pop %in% c("CLM","PEL","MXL","ACB","ASW","PUR"), "Amerindian", "NotSelected"))))))

colors = c("SouthAsian" = "red3", "EastAsian" = "seagreen4", "European" = "orange", "African" = "blue4", "Amerindian" = "turquoise1", "NotSelected" = "gray60")


##############################################################################################################################
##############################################################################################################################

#Simple utility function to split a string. R shiny return a string from the server for checkboxes.
split_ancestries <- function (string_variable){
    if (is.null(string_variable)) {
        return(c())
    }
    else {
        return(strsplit(string_variable, " "))
    }
}

#Run plink commands on subset data.
run_plink_commands <- function (ancestries_selected) {
    
    #Define file names used for plink processing.
    pops_selected_path = paste0(temp_dir_path, "popsSelected.txt")
    subset_genome_bed_file_prefix = paste0(temp_dir_path, "subsetExtractedChrAll")
    subset_eigenvec_prefix = paste0(temp_dir_path, "subsetExtractedChrAll.PCA")
    subset_eigenvec_file_path = paste0(temp_dir_path, "subsetExtractedChrAll.PCA.eigenvec")

    #Write the ancestries selected in a simple file.
    write(unlist(ancestries_selected), sep = "\n", file = pops_selected_path)

    #Define the plink command which subsets individuals belonging to selected population groups.
    plink_keep_fam_command = paste(plink_path,
                                  "--bfile",
                                  genome_bed_file_prefix,
                                  "--keep-fam",
                                  pops_selected_path,
                                  "--make-bed",
                                  "--out",
                                  subset_genome_bed_file_prefix)

    system(plink_keep_fam_command, intern = TRUE)

    #Define the plink command which runs PCA on selected population groups.
    plink_pca_command = paste(plink_path,
                                  "--bfile",
                                  subset_genome_bed_file_prefix,
                                  "--pca 10",
                                  "--out",
                                  subset_eigenvec_prefix)

    system(plink_pca_command, intern = TRUE)
    
    #Return the eigenvector file path for the subset data.
    return(subset_eigenvec_file_path)
}


#Process the subset eigen vector file created.
process_eigenvec_file <- function (eigenvec_file_path) {
    eigenvec <- read.table(eigenvec_file_path, header = F, sep = ' ')

    #Get the samples names and pops out.
    eigenvec_left = eigenvec[,1:2]
    colnames(eigenvec_left) = c("Pop", "SampleID")

    #Get the PCs values out.
    eigenvec_right = eigenvec[,3:ncol(eigenvec)]
    colnames(eigenvec_right) <- paste('PC', c(1:10), sep = '')
    eigenvec = cbind(eigenvec_left, eigenvec_right)
    eigenvec = within(eigenvec, ContinentalPopulation <- 
                              ifelse(Pop %in% c("GIH","STU","ITU","BEB","PJL"), "SouthAsian", 
                                 ifelse(Pop %in% c("CHB","JPT","KHV","CDX","CHS"), "EastAsian", 
                                                 ifelse(Pop %in% c("GBR","CEU","FIN","TSI","IBS"), "European",
                                                         ifelse(Pop %in% c("ESN","YRI","GWD","MSL","LWK"), "African",
                                                                    ifelse(Pop %in% c("CLM","PEL","MXL","ACB","ASW","PUR"), "Amerindian", "NotSelected"))))))
    return(eigenvec)

}
##############################################################################################################################
##############################################################################################################################

server <- function(input, output) {
    output$distPlot <- renderPlot({
        #Gather the ancestry groups selected.
        if (is.null(input$african_ancestry) & is.null(input$european_ancestry) & is.null(input$south_asian_ancestry) & is.null(input$east_asian_ancestry)) {
            
            #Plotting PCA plot for the top two PCs.
            ggplot(default_eigenvec, aes(x=PC1, y=PC2, fill=ContinentalPopulation)) + 
            scale_fill_manual(values = colors) +
            labs(subtitle = "",
                 x = "PC1", y = "PC2") +
            geom_point(size = 7, pch = 21, color = "black", stroke = 2) +
            theme_classic(base_size = 32) + theme(legend.position="bottom")

        }
        else {            
            #Split each input ancestry group and make a vectors of ancestries selected.
            african_ancestries_selected = split_ancestries(input$african_ancestry)
            european_ancestries_selected = split_ancestries(input$european_ancestry)
            south_asian_ancestries_selected = split_ancestries(input$south_asian_ancestry)
            east_asian_ancestries_selected = split_ancestries(input$east_asian_ancestry)
            amerindian_ancestries_selected = split_ancestries(input$amerindian_ancestry)
            
            
            #Combine all the vectors to get a final list of ancestries selected.
            ancestries_selected = c(amerindian_ancestries_selected,
                                    african_ancestries_selected,
                                    european_ancestries_selected,
                                    south_asian_ancestries_selected,
                                    east_asian_ancestries_selected)
            
            subset_eigenvec_file_path = run_plink_commands(ancestries_selected)
            eigenvec = process_eigenvec_file(subset_eigenvec_file_path)
           
            #Plotting PCA plot for the top two PCs.
            ggplot(eigenvec, aes(x=PC1, y=PC2, fill=ContinentalPopulation)) + 
            scale_fill_manual(values = colors) +
            labs(subtitle = "",
                 x = "PC1", y = "PC2") +
            geom_point(size = 7, pch = 21, color = "black", stroke = 2) +
            theme_classic(base_size = 32) + theme(legend.position="bottom")

        }        
    })
}