#df indicates the list of data frames of the contigs
#call is the how to call the clonotype - based on genes, CDR3 nt, or CDR3 aa sequence
#colorBy is the column ID to group
#' @export
clonalDiversity <- function(df,
                            call = c("gene", "nt", "aa", "gene+nt"),
                            colorBy = "samples") {
    if (call == "gene") {
        call <- "CTgene"
    } else if(call == "nt") {
        call <- "CTnt"
    } else if (call == "aa") {
        call <- "CTaa"
    } else {
        call <- "CTstrict"

    }

    mat <- NULL
    if (colorBy == "samples") {
        for (i in seq_along(df)) {
            data <- as.data.frame(table(df[[i]][,call]))
            w <- vegan::diversity(data[,"Freq"], index = "shannon")
            x <- vegan::diversity(data[,"Freq"], index = "invsimpson")
            y <- vegan::estimateR(data[,"Freq"])[2] #Chao
            z <- vegan::estimateR(data[,"Freq"])[4] #ACE
            out <- c(w,x,y,z)
            mat <- rbind.data.frame(mat, out)

        }
        colnames(mat) <- c("Shannon", "Inv.Simpson", "Chao", "ACE")
        rownames(mat) <- names(df)
        mat$samples <- rownames(mat)
        melt <- reshape2::melt(mat, id.vars = "samples")
        plot <- ggplot2::ggplot(melt, aes(x, y=value)) +
            geom_jitter(shape=21, size=3, width=0.2, aes(fill=melt[,colorBy]))

    } else {
        for (i in seq_along(df)) {
            data <- as.data.frame(table(df[[i]][,call]))
            color <- df[[i]][1,colorBy]
            w <- vegan::diversity(data[,"Freq"], index = "shannon")
            x <- vegan::diversity(data[,"Freq"], index = "invsimpson")
            y <- vegan::estimateR(data[,"Freq"])[2] #Chao
            z <- vegan::estimateR(data[,"Freq"])[4] #ACE
            out <- c(w,x,y,z,color)
            mat <- rbind(mat, out)
        }
        mat <- as.data.frame(mat)
        colnames(mat) <- c("Shannon", "Inv.Simpson", "Chao", "ACE", colorBy)
        rownames(mat) <- names(df)
        mat$samples <- rownames(mat)
        melt <- reshape2::melt(mat, id.vars = c("samples", colorBy))
        plot <-ggplot2::ggplot(melt, aes(x=melt[,colorBy], y=as.numeric(value))) +
            geom_boxplot(aes(fill=melt[,colorBy]), outlier.alpha = 0) +
            geom_jitter()

    }
    col <- length(unique(melt[,colorBy]))

    plot <- plot +
        ylab("Index Score") +
        scale_fill_manual(name = colorBy, values = colorblind_vector(col)) +
        facet_wrap(~variable, scales = "free", ncol = 4) +
        theme_classic() +
        theme(axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank())

    return(plot)
}
