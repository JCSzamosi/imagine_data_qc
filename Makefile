cleaned/ps_full.Rdata cleaned/seqs_full.Rdata :scripts/make_ps_full.R data/seqtab_nochim_transposed_IMG1-4164-Aug2023_v34.csv data/taxa_IMG1-4164-Aug2023_v34_silva138wsp.csv cleaned/mapfile_sequenced.csv
	Rscript scripts/make_ps_full.R

cleaned/ps_samfilt.Rdata cleaned/seqs_samfilt.Rdata :scripts/make_ps_samfilt.R cleaned/ps_full.Rdata
	Rscript scripts/make_ps_samfilt.R

intermed/aln_samfilt.Rdata:scripts/make_aln_samfilt.R cleaned/ps_samfilt.Rdata
	Rscript scripts/make_aln_samfilt.R

intermed/dmat_samfilt.Rdata:scripts/make_dmat_samfilt.R intermed/aln_samfilt.Rdata
	Rscript scripts/make_dmat_samfilt.R

intermed/clst_samfilt.Rdata:scripts/make_clst_samfilt.R intermed/dmat_samfilt.Rdata
	Rscript scripts/make_clst_samfilt.R
