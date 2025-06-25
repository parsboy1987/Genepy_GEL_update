process Pre_processing_2 {
  publishDir "${params.chr}", mode: "copy", overwrite: true
  //maxForks 10
  label "Pre_processing_2"
 // label "process_micro"
  

  input:
  tuple file("f5.vcf.gz"), val(vcf_n), val(chrx) 
  path(header_meta)
  path(IBD_gwas_bed)
  path(Genecode_p50_bed)
  path(template)
  output:
  tuple file("c1"), file("c2"), file("c3"), file("c4"),file("c5"),file("c5a"),file("c5b"),file("gene.lst"),file("f5.vcf.gz"),file("header_meta"), val(vcf_n) , val(chrx) ,emit: main 
  path("c_u") 
  path("p1_u")
  path("p1_1")
  path("p1_2")
  path("p1_order")
  path("p1") 
  path("c")
  path("csq")
  path("p1_s")
  path("p1_m")
  path("p1_re")
  path("alt_re")
  path("csq_re")
  path("order_re")
  path("order")
  shell:
    """
    REAL_PATH1=\$(readlink -f ${template})
    ls \$REAL_PATH1
    cp \$REAL_PATH1/pre_1.sh ./pre_1.sh
    chmod +x ./pre_1.sh
    cat ${header_meta} > meta_CADD_head
    cat ${IBD_gwas_bed} > IBD.bed
    cat ${Genecode_p50_bed} > p50.bed
    ## bgzip -c "f5.vcf" > f5.vcf.gz
    bcftools view -h f5.vcf.gz --threads $task.cpus | grep -v "##" | cut -f 10- >p
    ./pre_1.sh
    """
}
