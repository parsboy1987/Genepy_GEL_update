process CADD_score {
  label "CADD_score"
  label "process_micro"
  publishDir "${params.chr}", mode: "copy", overwrite: true
  //maxForks 10
  input:
  tuple val(chrx), val(vcf_n), file(vcfFile)
  path(cadd_)    
  //val cadd_param = params.cadd_
  output:
  tuple val(chrx), path("p1.vcf"), path("wes_${chrx}.tsv.gz"), path("wes_${chrx}.tsv.gz.tbi"), val(vcf_n), file(vcfFile), emit: pre_proc_1
  
  script:
    """
    ls ${cadd_}
    ln -s ${cadd_} /opt/CADD-scripts-CADD1.6/data/annotations/
    ls -R /opt/CADD-scripts-CADD1.6/data/annotations/GRCh38_v1.6/
   
   
    echo "test"
    bcftools view -G ${vcfFile} -Ov -o p1.vcf
    
    awk -F"\t" '\$1 ~/#/ || length(\$4)>1||length(\$5)>1' p1.vcf | sed '3383,\$s/chr//g' p1.vcf > ${chrx}.p11.vcf
    CADD.sh -c 8 -o wes1_${chrx}.tsv.gz ${chrx}.p11.vcf
    zcat wes1_${chrx}.tsv.gz | awk 'BEGIN {FS="\t"} /^#/ {print} \$0 !~ /^#/ && \$NF >= 15' | bgzip > wes_${chrx}.tsv.gz
    ##bgzip wes1_${chrx}.tsv
    tabix -p vcf wes_${chrx}.tsv.gz
   ##bcftools filter -i 'PHRED >= 15' wes1_${chrx}.tsv.gz -Oz -o wes_${chrx}.tsv.gz
   ##tabix -p vcf wes_${chrx}.tsv.gz
    
    """
}
