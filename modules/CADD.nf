process CADD_score {
  label "CADD_score"
  //label "process_micro"
  publishDir "${params.chr}/${vcf_n}", mode: "copy", overwrite: true
   maxForks 30
  input:
  tuple val(chrx), val(vcf_n), file(vcfFile),path(cadd_),path(ccds)
      
  //val cadd_param = params.cadd_
  output:
  tuple val(chrx), path("p1.vcf"), path("wes_${chrx}.tsv.gz"), path("wes_${chrx}.tsv.gz.tbi"), val(vcf_n), file(vcfFile), emit: pre_proc_1
  path("input.vcf.gz"), emit: input_vcf
  script:
    """
    echo "Iman"
    REAL_PATH1=\$(readlink -f ${cadd_})
    ln -sf \$REAL_PATH1 /opt/CADD-scripts-CADD1.6/data/annotations/GRCh38_v1.6
    tabix -p vcf ${vcfFile}
    bcftools norm -m+any ${vcfFile} -Oz -o input.vcf.gz
    tabix -p vcf input.vcf.gz
    ############################
    bcftools view -G input.vcf.gz -Ov  --threads $task.cpus -o p1.vcf
    ## awk -F"\t" '\$1 ~/#/ || length(\$4)>1||length(\$5)>1' p1.vcf | sed '2680,\$s/chr//g' p1.vcf > ${chrx}.p11.vcf
    st=\$(awk '\$0 !~ /^#/ {print NR; exit}' p1.vcf)
    awk -F"\t" '\$1 ~ /^#/ || length(\$4)>1 || length(\$5)>1' p1.vcf | sed "\${st},\\\$s/chr//g" > ${chrx}.p11.vcf
    CADD.sh -c $task.cpus -o wes1_${chrx}.tsv.gz ${chrx}.p11.vcf
    zcat wes1_${chrx}.tsv.gz | awk 'BEGIN {FS="\t"} /^#/ {print} \$0 !~ /^#/ && \$NF >= 15' | bgzip > wes_${chrx}.tsv.gz
    tabix -p vcf wes_${chrx}.tsv.gz  
    """
}
