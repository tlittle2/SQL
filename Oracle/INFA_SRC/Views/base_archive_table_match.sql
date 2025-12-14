create view infa_src.base_archive_table_match
as
  with src_archive as (
           select TABLE_OWNER as base_table_owner, TABLE_NAME as base_table_name
           from archive_rules
           where archive_rules_tbl_pkg.get_arch_prefix_from_tab(TABLE_NAME) <> (select archive_rules_tbl_pkg.get_archive_table_prefix from dual)
    )

    , arch_archive as (
       select TABLE_OWNER as archive_table_owner, TABLE_NAME as archive_table_name
       from archive_rules
       where archive_rules_tbl_pkg.get_arch_prefix_from_tab(TABLE_NAME) = (select archive_rules_tbl_pkg.get_archive_table_prefix from dual)
    )

    select base_table_owner,base_table_name,archive_table_owner,archive_table_name from src_archive src
    left outer join arch_archive arch
    on src.base_table_owner = arch.archive_table_owner
    and src.base_table_name = archive_rules_tbl_pkg.get_base_tab_name_from_archive(arch.archive_table_name);
