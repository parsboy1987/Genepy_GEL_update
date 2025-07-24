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
     
        
       chromosomeList = params.chromosomes
       println "START :)"
       println "Chromosome list: $chromosomeList"
     // def regionPatterns = ['chr22_1_10848253', 'chr22_21129938_21349068', 'chr22_21349069_22141767', 'chr22_22141768_23984312','chr22_38483936_40850931','chr22_40850932_42981587']  // Define allowed patterns

        chrx = Channel.fromPath("${params.vcf}/*_${params.chromosomes}_*.vcf.gz")
            .map { file -> 
                def filename = file.baseName
                return [chromosomeList, filename, file, "${params.annotations_cadd}", "${params.ccds_region}" ]
            }
            .view()
      CADD_score(chrx)
      VEP_score(CADD_score.out.pre_proc_1,params.homos_vep,params.vep_plugins,params.plugin1,params.plugin2,params.genomad_indx1,params.genomad_indx2)
      Pre_processing_1(VEP_score.out,params.ethnicity,params.xgen_bed)
      Pre_processing_2(Pre_processing_1.out.main,params.header_meta,params.IBD_gwas_bed,params.Genecode_p50_bed,params.templates)
      Pre_processing_3(Pre_processing_2.out.main,params.templates)     
     // def meta15 = Pre_processing_3.out.meta_files15.collect().map { genes_list -> ["15",chromosomeList, genes_list] }
      def meta15 = Pre_processing_3.out.meta_files15.collect().map {genes_list -> ["15",chromosomeList, genes_list] }.view()

      def meta20 = Pre_processing_3.out.meta_files20.collect().map { genes_list -> ["20",chromosomeList, genes_list] }
      def metaALL = Pre_processing_3.out.meta_filesALL.collect().map { genes_list -> ["ALL",chromosomeList, genes_list] }
      x_combo= meta15.concat(meta20).concat(metaALL)
      x_combo
      Reatt_Genes(x_combo)
      def results = Reatt_Genes.out.path_.map{ mainfolder -> mainfolder.listFiles()
              .findAll { it.isDirectory() }.map{ path ->
            path1 = path.toString()
            println "path: $path1"
            def chromosome =  chromosomeList
            def cadd_score = (path1.contains('metafilesALL')) ? 'ALL' :
                             (path1.contains('metafiles20')) ? '20' :
                             (path1.contains('metafiles15')) ? '15' : 'ALL'
            [path, chromosome, cadd_score,"${params.genepy_py}","${params.kary}"]
        }}
      results.view()
  //    Genepy_score(result)
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

                      
