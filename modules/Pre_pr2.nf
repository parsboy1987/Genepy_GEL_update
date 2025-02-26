process Pre_processing_2 {
  publishDir "${params.output}/${vcf_n}", mode: "copy", overwrite: true
  //maxForks 10
  label "Pre_processing_2"
  label "process_micro"
  input:
  tuple file("f5.vcf.gz"), val(vcf_n), val(chrx) 
  path(header_meta)
  path(IBD_gwas_bed)
  path(Genecode_p50_bed)
  path(templates)
  output:
  tuple path("c1"), path("c2"), path("c3"), path("c4"),path("c5"),path("c5a"),path("c5b"),path("gene.lst"),path("f5.vcf.gz"),path("header.meta"), val(vcf_n) , val(chrx) 
  
  shell:
    """
    cat ${header_meta} > meta_CADD_head
    cat ${IBD_gwas_bed} > IBD.bed
    cat ${Genecode_p50_bed} > p50.bed
    ## bgzip -c "f5.vcf" > f5.vcf.gz
    bcftools view -h f5.vcf.gz | grep -v "##" | cut -f 10- >p
    ${template("pre_1.sh")}
    """
}
