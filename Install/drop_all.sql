-------------------------------------------------------------------------
--                                                                     --
--       _/_/_/_/              _/_/_/      _/_/      _/_/_/    _/_/_/  --
--      _/        _/      _/  _/    _/  _/    _/  _/        _/         --
--     _/_/_/    _/      _/  _/_/_/    _/    _/  _/          _/_/      --
--    _/          _/  _/    _/    _/  _/    _/  _/              _/     --
--   _/_/_/_/      _/      _/    _/    _/_/      _/_/_/  _/_/_/        --
--                                                                     --
-------------------------------------------------------------------------

set feedback off
declare
  subtype st_maxchar              is varchar2(32767);
  subtype st_identifier_name      is varchar2(128)   ;

  cn_function        constant  st_identifier_name := 'FUNCTION'      ;
  cn_javaclass       constant  st_identifier_name := 'JAVA CLASS'    ;
  cn_package         constant  st_identifier_name := 'PACKAGE'       ;
  cn_procedure       constant  st_identifier_name := 'PROCEDURE'     ;
  cn_public_synonym  constant  st_identifier_name := 'PUBLIC SYNONYM';
  cn_sequence        constant  st_identifier_name := 'SEQUENCE'      ;
  cn_table           constant  st_identifier_name := 'TABLE'         ;
  cn_type            constant  st_identifier_name := 'TYPE'          ;

  e_no_table     exception;
  e_no_sequence  exception;
  e_no_object    exception;
  e_no_synonym   exception;
  pragma exception_init (e_no_table   , -942);
  pragma exception_init (e_no_sequence,-2289);
  pragma exception_init (e_no_object  ,-4043);  -- bij packages en types
  pragma exception_init (e_no_synonym ,-1432);

  type rt_error is record (ddl          st_maxchar
                          ,error_msg    st_maxchar
                          );
  r_error       rt_error;

  type at_error is table of rt_error index by pls_integer;
  a_error    at_error;

  type rt_object_to_drop is record (object_type  st_identifier_name
                                   ,object_name  st_identifier_name
                                   );

  type at_object_to_drop is table of rt_object_to_drop index by pls_integer;
  a_object_to_drop    at_object_to_drop;

  v_max_len_type   integer  := 0;
  v_max_len_name   integer  := 0;



  procedure pl
  (pi_line  in  varchar2  default ''
  )
  is
  begin
    dbms_output.put_line (pi_line);
  end pl;


  procedure trash
  (p_object   in  rt_object_to_drop
  )
  is
    v_stmnt    st_maxchar;

    procedure notexist_msg
    is
    begin
      pl (rpad(p_object.object_type , v_max_len_type)  ||' '||
          rpad(p_object.object_name , v_max_len_name)  ||' '||
          'does not exist, nothing to drop'
         );
    end notexist_msg;

  begin
    v_stmnt := 'drop '||p_object.object_type||' '||p_object.object_name;
    execute immediate (v_stmnt);
    pl (rpad(p_object.object_type , v_max_len_type)  ||' '||
        rpad(p_object.object_name , v_max_len_name)  ||' '||
        'dropped'
       );
  exception
    when e_no_table
      or e_no_sequence
      or e_no_object
      or e_no_synonym
    then
      notexist_msg;

    when others
    then
      r_error.ddl       := v_stmnt;
      r_error.error_msg := substr(sqlerrm,1,32767);

      a_error (a_error.count + 1) := r_error;
  end trash;


  procedure show_errors
  is
  begin
    if a_error.count > 0
    then
      pl;
      pl;
      pl ('##############################################################');
      pl (to_char(a_error.count)||' UNSUCCESFUL DROP STATEMENTS:');
      pl ('##############################################################');

      for i_err in 1 .. a_error.count
      loop
        pl ('Statement: '||a_error(i_err).ddl);
        pl ('Error    : '||substr(a_error(i_err).error_msg,1,32767));
        pl;
      end loop;
      pl ('##############################################################');
    end if;
  end show_errors;


  procedure init_object_list
  is
    procedure add_object
    (p_object_type  in  st_identifier_name
    ,p_object_name  in  st_identifier_name
    )
    is
      r_object_to_drop    rt_object_to_drop;
    begin
      -- The public synonym for the object
      r_object_to_drop.object_type := cn_public_synonym;
      r_object_to_drop.object_name := p_object_name;
      a_object_to_drop(a_object_to_drop.count + 1)  := r_object_to_drop;

      -- The object itself
      r_object_to_drop.object_type := p_object_type;
      r_object_to_drop.object_name := p_object_name;
      a_object_to_drop(a_object_to_drop.count + 1)  := r_object_to_drop;

      -- Record the largest object name and object type, for alignment of later reporting
      v_max_len_type := greatest (v_max_len_type , coalesce(length(p_object_type) , 0) , length(cn_public_synonym));
      v_max_len_name := greatest (v_max_len_name , coalesce(length(p_object_name) , 0));
    end add_object;

  begin
    add_object (cn_procedure , 'erolog'                   );
    add_object (cn_procedure , 'ero_tabledata_bulkinserts');
                             
    add_object (cn_package   , 'ero_settings'             );
    add_object (cn_package   , 'ero_callstack'            );
    add_object (cn_package   , 'ero_directory'            );
    add_object (cn_package   , 'ero_email'                );
    add_object (cn_package   , 'ero_error'                );
    add_object (cn_package   , 'ero_file'                 );
    add_object (cn_package   , 'ero_fill'                 );
    add_object (cn_package   , 'ero_kalender'             );
    add_object (cn_package   , 'ero_logging'              );
    add_object (cn_package   , 'ero_periods'              );
    add_object (cn_package   , 'ero_pl'                   );
    add_object (cn_package   , 'ero_ranges'               );
    add_object (cn_package   , 'ero_session'              );
    add_object (cn_package   , 'ero_stopwatch'            );
    add_object (cn_package   , 'ero_timing'               );
    add_object (cn_package   , 'ero_trace'                );
    add_object (cn_package   , 'ero_utl'                  );
    add_object (cn_package   , 'ero_const'                );
    add_object (cn_package   , 'ero_types'                );

    add_object (cn_javaclass , '"EroDirList"'             );

    add_object (cn_table     , 'ero_setting_values'       );
    add_object (cn_table     , 'ero_gtt_dir_list'         );
    add_object (cn_table     , 'ero_log'                  );
                             
    add_object (cn_type      , 'nt_ero_dir_contents'      );
    add_object (cn_type      , 'nt_ero_distribution_chr'  );
    add_object (cn_type      , 'nt_ero_distribution_dat'  );
    add_object (cn_type      , 'nt_ero_distribution_num'  );
    add_object (cn_type      , 'nt_ero_errorstack'        );
    add_object (cn_type      , 'nt_ero_identifier'        );
    add_object (cn_type      , 'nt_ero_maxchar'           );
                             
    add_object (cn_type      , 'ot_ero_distribution_chr'  );
    add_object (cn_type      , 'ot_ero_distribution_dat'  );
    add_object (cn_type      , 'ot_ero_distribution_num'  );
    add_object (cn_type      , 'ot_ero_errorstack'        );
    add_object (cn_type      , 'ot_ero_file_properties'   );

    add_object (cn_type      , 'nt_ero_callstack'         );
    add_object (cn_type      , 'ot_ero_callstack'         );
                             
    add_object (cn_sequence  , 'ero_log_seq'              );
  end  init_object_list;


begin
  init_object_list;

  for i_obj in 1 .. a_object_to_drop.count
  loop
    trash (a_object_to_drop(i_obj));
  end loop;

  show_errors;
end;
/

set feedback on

