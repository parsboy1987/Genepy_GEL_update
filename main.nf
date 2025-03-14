#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Check input path parameters to see if they exist
def checkPathParamList = [ 
    params.vcf
]

include { CADD_score } from "./modules/CADD"  
include { VEP_score } from "./modules/VEP"  
include { Pre_processing_1 } from "./modules/Pre_pr1"  
include { Pre_processing_2 } from "./modules/Pre_pr2"  
include { Pre_processing_3 } from "./modules/Pre_pr3"  
include { Reatt_Genes } from "./modules/Gene_reattach"
include { Genepy_score } from "./modules/Genepy"




// Define workflow
workflow {

sch= Channel.fromPath("${params.annotations_cadd}")
   // .map { it.name }
   // .collect()
  //  .view { "CADD Subfolders: ${it.join(', ')}" }
//Channel.fromPath(params.annotations_cadd)
//    .filter{is.
//    .map { it.name }
//    .collect()
//    .view { "CADD Subfolders: ${it.join(', ')}" }

    println """\
         G E N E P Y           P I P E L I N E
          ===================================
     G E N O M I C --------------- M E D I C I N E 
                         UoS
                   Sarah Ennis Lab
                     Iman Nazari
          ===================================
         Samples         : ${params.vcf}
         params.cadd     : ${params.annotations_cadd}
         """.stripIndent()
     
        homos_vep = Channel.fromPath("${params.homos_vep}")
        vep_plugins = Channel.fromPath("${params.vep_plugins}")
        header_meta  = Channel.fromPath("${params.header_meta}")
        genepy_py = Channel.fromPath("${params.genepy_py}")
        gene_code_bed = Channel.fromPath("${params.gene_code_bed}")
        templates = Channel.fromPath("${params.templates}")
        xgen_bed = Channel.fromPath("${params.xgen_bed}")
        IBD_gwas_bed = Channel.fromPath("${params.IBD_gwas_bed}")
        Genecode_p50_bed = Channel.fromPath("${params.Genecode_p50_bed}")
        plugin1 = Channel.fromPath("${params.plugin1}")
        plugin2 = Channel.fromPath("${params.plugin2}")
        ethnicity = Channel.fromPath("${params.ethnicity}")
       // def chromosomeList = params.chromosomes.split(',').collect { it.trim().replaceAll('"', '') }
       chromosomeList = params.chromosomes
       println "Chromosome list: $chromosomeList"
       chrx = channel.fromPath("${params.vcf}/*_${params.chromosomes}_*.vcf.gz").map { file -> 
                      def filename = file.baseName  // Extracts filename without the .vcf.gz extension
                      return [chromosomeList,filename,file]       // Returns a tuple with [full path, base filename]
                      }.view()
      //com_ch= chrx.combine(sch).view()
      CADD_score(chrx,sch)
      VEP_score(CADD_score.out.pre_proc_1,homos_vep,vep_plugins,plugin1,plugin2)
      Pre_processing_1(VEP_score.out,ethnicity,xgen_bed)
      Pre_processing_2(Pre_processing_1.out,header_meta,IBD_gwas_bed,Genecode_p50_bed,templates)
      Pre_processing_3(Pre_processing_2.out.main,templates)     
      def meta15 = Pre_processing_3.out.meta_files15.collect().map { genes_list -> ["15",chromosomeList, genes_list] }
      def meta20 = Pre_processing_3.out.meta_files20.collect().map { genes_list -> ["20",chromosomeList, genes_list] }
      def metaALL = Pre_processing_3.out.meta_filesALL.collect().map { genes_list -> ["ALL",chromosomeList, genes_list] }
      x_combo= meta15.concat(meta20).concat(metaALL)
      Reatt_Genes(x_combo)
      Reatt_Genes.out.path_.view()
      def result = Reatt_Genes.out.path_.flatten().map{[it]}.map { path ->
            path1 = path.toString()
             println "path: $path1"
            def chromosome =  chromosomeList
            def cadd_score = (path1.contains('metafilesALL')) ? 'ALL' :
                             (path1.contains('metafiles20')) ? '20' :
                             (path1.contains('metafiles15')) ? '15' : 'ALL'
            [path, chromosome, cadd_score,"${params.genepy_py}"]
        }
      result.view()
      Genepy_score(result)

}

workflow.onComplete {
   println ( workflow.success ? """
       Pipeline execution summary
       ---------------------------
       Completed at: ${workflow.complete}
       Duration    : ${workflow.duration}
       Success     : ${workflow.success}
       workDir     : ${workflow.workDir}
       exit status : ${workflow.exitStatus}
       """ : """
       Failed: ${workflow.errorReport}
       exit status : ${workflow.exitStatus}
       """
   )
}
//workflow.onError {
//  file(params.output).deleteDir()
//}

                      
