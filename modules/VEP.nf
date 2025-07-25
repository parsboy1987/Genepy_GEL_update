process VEP_score {
    publishDir "${params.chr}/${vcf_n}", mode: "copy", overwrite: true
  // maxForks 20
  label "VEP_score"
  //label "process_medium"
  
  input:
  tuple val(chrx), path("p1.vcf"), path("wes.tsv.gz"), path("wes.tsv.gz.tbi"), val(vcf_n) , file(vcfFile), path("input.vcf.gz")
  path(homos_vep)
  path(vep_plugins)
  path(plugin1)
  path(plugin2)
  path(genomad_indx1)
  path(genomad_indx2)
  
  output:
   tuple path("${chrx}.p1.vep.vcf"), val(vcf_n), file(vcfFile), val(chrx),path("input.vcf.gz") ,emit: vep_out
  
  script:
  
    """
    ls ${genomad_indx1}
    vep  -i "p1.vcf" --offline --assembly GRCh38 --vcf --fork 10 --cache --force_overwrite --pick_allele --plugin CADD,${plugin1},${plugin2},"wes.tsv.gz"  --af_gnomade --af_gnomadg --fields "Allele,Consequence,SYMBOL,Gene,gnomADg_AF,gnomADg_NFE_AF,gnomADe_AF,gnomADe_NFE_AF,CADD_RAW,gnomadRF_RF_flag" -o "${chrx}.p1.vep.vcf" --dir_cache ${homos_vep}  --dir_plugins ${vep_plugins}
    
    """
}
