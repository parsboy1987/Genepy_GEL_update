process VEP_score {
    publishDir "${params.chr}", mode: "copy", overwrite: true
   //maxForks 10
  label "VEP_score"
  label "process_micro"

  
  input:
  tuple val(chrx), path("p1.vcf"), path("wes.tsv.gz"), path("wes.tsv.gz.tbi"), val(vcf_n) , file(vcfFile)
  path(homos_vep)
  path(vep_plugins)
  path(plugin1)
  path(plugin2)
  
  output:
   tuple path("${chrx}.p1.vep.vcf"), val(vcf_n), file(vcfFile), val(chrx) ,emit: vep_out
  
  script:
  
    """
    vep  -i "p1.vcf" --offline --assembly GRCh38 --vcf --fork 10 --cache --force_overwrite --pick_allele --plugin CADD,${plugin1},${plugin2},"wes.tsv.gz"  --af_gnomade --af_gnomadg --fields "Allele,Consequence,SYMBOL,Gene,gnomADg_AF,gnomADg_NFE_AF,gnomADe_AF,gnomADe_NFE_AF,CADD_RAW,gnomadRF_RF_flag" -o "${chrx}.p1.vep.vcf" --dir_cache ${homos_vep} --dir_plugins ${vep_plugins}
    
    """
}
