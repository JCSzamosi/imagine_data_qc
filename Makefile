cleaned/mapfile_full.csv cleaned/mapfile_sequenced.csv cleaned/mapfile_full.Rdata:scripts/make_mapfile.R data/active_IMAGINE_metadata_wide.csv data/active_Rossi_info_datasheet.csv
	Rscript scripts/make_mapfile.R

cleaned/ps_full.Rdata cleaned/seqs_full.Rdata:scripts/make_ps_full.R data/active_seqtab_nochim.csv data/active_taxtab_silva138wsp.csv cleaned/mapfile_sequenced.csv
	Rscript scripts/make_ps_full.R

cleaned/ps_samfilt.Rdata cleaned/seqs_samfilt.Rdata:scripts/make_ps_samfilt.R cleaned/ps_full.Rdata
	Rscript scripts/make_ps_samfilt.R

intermed/aln.Rdata:scripts/make_aln.R cleaned/seqs_full.Rdata
	Rscript scripts/make_aln.R

intermed/dmat.Rdata:scripts/make_dmat.R intermed/aln.Rdata
	Rscript scripts/make_dmat.R

intermed/clst.Rdata:scripts/make_clst.R intermed/dmat.Rdata
	Rscript scripts/make_clst.R

intermed/tax_99.Rdata:scripts/assign_tax_99.R intermed/clst.Rdata
	Rscript scripts/assign_tax_99.R
