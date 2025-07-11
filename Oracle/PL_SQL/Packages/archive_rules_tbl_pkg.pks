create or replace package archive_rules_tbl_pkg
as
    g_archive_table_prefix CONSTANT VARCHAR2(5) := 'ARCH_'

    procedure reset_archive_parm_table;
    
    procedure archive_rules_preanalysis(p_number_of_runs in NUMBER, p_partitioned_flag IN partition_table_parm.partitioned%type);
                                       
                                       
    procedure remove_from_archive_rules(p_table_owner        IN archive_rules.table_owner%type
                                      , p_table_name         IN archive_rules.table_name%type);
                                      
    procedure partitioned_append_to_archive(p_src_owner          in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type 
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_key_column         in archive_rules.archive_column_key%type);
                                          
    procedure unpartitioned_append_to_archive(p_src_owner        in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_key_column       in archive_rules.archive_column_key%type);
                                            
                                            
                                            
    procedure partitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type 
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_bulk_limit         in integer default 250000);
                                          
    procedure unpartitioned_collect_to_archive(p_src_owner       in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_bulk_limit       in integer default 250000);

end archive_rules_tbl_pkg;
