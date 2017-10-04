context("Format of the returned object and output files")


# Prepare testing data
library(mpea)
gmt <- read.GMT('test.gmt')
dat <- read.table('test.dat')
rownames(dat) <- dat$Gene
dat <- as.matrix(dat[, -1])
dat[is.na(dat)] <- 1

file.names <- paste(c('terms', 'groups', 'smallgmt'), '.txt', sep="")

test_that("Column names of data.table is correct", {
    expect_equal(colnames(mpea(dat, gmt, cytoscape.filenames=NULL, contribution=FALSE, significant=1)), 
                 c('term.id', 'term.name', 'p.val', 'term.size', 'overlap'))
    expect_equal(colnames(mpea(dat, gmt, cytoscape.filenames=NULL, contribution=TRUE, significant=1)),
                 c('term.id', 'term.name', 'p.val', 'term.size', 'overlap', 'CDS', 'promCore', 'X5UTR', 'X3UTR', 'enhancer'))
})

test_that("All results or only significant ones are returned", {
    expect_true(all(mpea(dat, gmt, cytoscape.filenames=NULL, contribution=FALSE, 
                         cutoff=1, significant=0.9)$p.val < 0.9))
    expect_equal(nrow(mpea(dat, gmt, cytoscape.filenames=NULL, contribution=FALSE, 
                           return.all=TRUE, cutoff=1, significant=0.9)), length(gmt))
})

test_that("No significant results are found", {
    expect_error(res1 <- mpea(dat, gmt, cytoscape.filenames=NULL, contribution=FALSE, 
                      significant=0, return.all=FALSE), "No significant terms were found", fixed=TRUE)
    expect_false(exists('res1'))
    expect_warning(res2 <- mpea(dat, gmt, cytoscape.filenames=NULL, contribution=FALSE, 
                        significant=0, return.all=TRUE), "No significant terms were found", fixed=TRUE)
    expect_true(exists('res2'))
})

test_that("Cytoscape files are written", {
    suppressWarnings(file.remove(file.names))
    mpea(dat, gmt, cytoscape.filenames=file.names, contribution=TRUE, significant=0.9, cutoff=1)
    expect_equal(file.exists(file.names), c(TRUE, TRUE, TRUE))
    
    suppressWarnings(file.remove(file.names))
    suppressWarnings(mpea(dat, gmt, cytoscape.filenames=file.names, contribution=FALSE, significant=0.9, cutoff=1))
    expect_equal(file.exists(file.names), c(TRUE, FALSE, TRUE))
    
    suppressWarnings(file.remove(file.names))
    suppressWarnings(mpea(dat, gmt, cytoscape.filenames=file.names, contribution=TRUE, significant=0, return.all=TRUE))
    expect_equal(file.exists(file.names), c(FALSE, FALSE, FALSE))
})