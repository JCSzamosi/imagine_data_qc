data/current/taxtab_nochim_IMG1-5525-April2024_v34.rds:scripts/assign_taxonomy.R data/current/seqtab_nochim_transposed_IMG1-5525-April2024_v34.rds
	Rscript scripts/assign_taxonomy.R

cleaned/seqtab_cleaned.csv:scripts/make_clean_seqtab.R data/current/seqtab_nochim_transposed_IMG1-5525-April2024_v34.csv
	Rscript scripts/make_clean_seqtab.R

intermed/missing_from_seqtab.csv:scripts/check_sequenced_runs.R data/active_Rossi_info_datasheet.csv data/active_seqtab_nochim.csv
	Rscript scripts/check_sequenced_runs.R

intermed/mapfile_full.csv cleaned/mapfile_sequenced.csv cleaned/mapfile_clean.csv:scripts/make_mapfile.R data/active_IMAGINE_metadata_wide.csv data/active_Rossi_info_datasheet.csv
	Rscript scripts/make_mapfile.R

cleaned/ps_full.Rdata cleaned/seqs_full.Rdata:scripts/make_ps_full.R data/active_seqtab_nochim.csv data/active_taxtab_silva138wsp.rds cleaned/mapfile_sequenced.csv
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

cleaned/ps_99.Rdata:scripts/make_ps_99.R cleaned/ps_full.Rdata intermed/tax_99.Rdata intermed/clst.Rdata cleaned/seqs_full.Rdata
	Rscript scripts/make_ps_99.R

cleaned/ps_99_samfilt.Rdata:scripts/make_ps_99_samfilt.R cleaned/ps_samfilt.Rdata cleaned/ps_99.Rdata
	Rscript scripts/make_ps_99_samfilt.R
