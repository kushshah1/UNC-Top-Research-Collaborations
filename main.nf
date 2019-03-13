#!/usr/bin/env nextflow

params.file_dir = 'data/abstracts/*'
params.file_dir2 = 'data/institutions/*'

params.out_dir = '.'

abs_channel = Channel.fromPath( params.file_dir )
inst_channel = Channel.fromPath( params.file_dir2 )
inst_channel2 = Channel.fromPath( params.file_dir2 )

process create_df {
	container 'rocker/tidyverse:3.5'
	
	input:
    file f from abs_channel
    
    output:
	file 'parsed_abstract.csv' into df
	file 'parsed_abstract.csv' into df2
	
	script:
    """
    Rscript $baseDir/bin/parse_collaborators.R $f
    """
}

process create_df2_combined {
	container 'rocker/tidyverse:3.5'
	publishDir params.out_dir, mode: 'copy'
	
	input:
	file f from df.collectFile(name: 'df.csv', newLine: true)
	file g from inst_channel
	
	output:
	file 'df2_combined.csv' into df2_combined
	
	script:
	"""
	Rscript $baseDir/bin/collaborators_list.R $f $g
	"""
}

process create_top_institutions {
	container 'rocker/tidyverse:3.5'
	publishDir params.out_dir, mode: 'copy'
	
	input:
	file f from df2.collectFile(name: 'df.csv', newLine: true)
	file g from inst_channel2
	
	output:
	file 'top_institutions.csv' into top_institutions
	
	script:
	"""
	Rscript $baseDir/bin/topinstitutions_list.R $f $g
	"""	
}