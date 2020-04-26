create or replace procedure ero_tabledata_bulkinserts
(p_tablename       in  ero_types.st_maxchar
,p_commitsize      in  integer                          default null
,p_include_create  in  boolean                          default false
,p_include_drop    in  boolean                          default false
,p_include_owner   in  boolean                          default false
)
is
  -------------------------------------------------------------------------
  --                                                                     --
  --       _/_/_/_/              _/_/_/      _/_/      _/_/_/    _/_/_/  --
  --      _/        _/      _/  _/    _/  _/    _/  _/        _/         --
  --     _/_/_/    _/      _/  _/_/_/    _/    _/  _/          _/_/      --
  --    _/          _/  _/    _/    _/  _/    _/  _/              _/     --
  --   _/_/_/_/      _/      _/    _/    _/_/      _/_/_/  _/_/_/        --
  --                                                                     --
  -------------------------------------------------------------------------

  -- ********************************************************************************
  -- * Name module : ero_tabledata_bulkinserts
  -- * Version     : 01.00
  -- * Author      : Erik van Roon
  -- * Function    : export data from a table to a data insert script
  -- *********************************************************************************

  -- ######################################################################
  -- TODO:
  -- --> progress in scriptgeneration          ##DONE##
  -- --> progress in script                    ##DONE##
  -- --> add parameter p_include_owner         ##DONE##
  -- --> Quotes in geexporteerde data escapen  ##DONE##
  -- --> Als value is null, dan null, niet ''  ##DONE##
  -- --> include create
  -- --> include drop
  -- --> Evrocs header
  -- --> opnemen in een package
  -- --> tools-script maken dat deze procedure aanroept voor x tabellen (parameter met wildcards), elk gespoold naar eigen spoolfile
  -- ######################################################################


  cn_param_nls_date_fmt           constant  ero_types.st_shortstring     := 'nls_date_format';
  cn_param_nls_num_chars          constant  ero_types.st_shortstring     := 'nls_numeric_characters';
  cn_param_nls_timestamp_fmt      constant  ero_types.st_shortstring     := 'nls_timestamp_format';
  cn_param_nls_timestamp_tz_fmt   constant  ero_types.st_shortstring     := 'nls_timestamp_tz_format';

  cn_nls_date_fmt                 constant  ero_types.st_shortstring     := 'YYYY-MM-DD HH24:MI:SS';
  cn_nls_num_chars                constant  ero_types.st_shortstring     := '.,';  -- don't change this to european style, because we need to distinguish between element separator (comma) and decimal (dot)
  cn_nls_timestamp_fmt            constant  ero_types.st_shortstring     := 'YYYY-MM-DD HH24:MI:SS.FF';
  cn_nls_timestamp_tz_fmt         constant  ero_types.st_shortstring     := 'YYYY-MM-DD HH24:MI:SS.FF TZR';

  cn_datatype_timestamp_template  constant  all_tab_cols.data_type%type  := 'TIMESTAMP%';
  cn_datatype_timezone_template   constant  all_tab_cols.data_type%type  := 'TIMESTAMP%WITH TIME ZONE';

  cn_datatype_char                constant  all_tab_cols.data_type%type  := 'CHAR'     ;
  cn_datatype_varchar2            constant  all_tab_cols.data_type%type  := 'VARCHAR2' ;
  cn_datatype_clob                constant  all_tab_cols.data_type%type  := 'CLOB'     ;
  cn_datatype_nchar               constant  all_tab_cols.data_type%type  := 'NCHAR'    ;
  cn_datatype_nvarchar2           constant  all_tab_cols.data_type%type  := 'NVARCHAR2';
  cn_datatype_nclob               constant  all_tab_cols.data_type%type  := 'NCLOB'    ;
  cn_datatype_number              constant  all_tab_cols.data_type%type  := 'NUMBER'   ;
  cn_datatype_float               constant  all_tab_cols.data_type%type  := 'FLOAT'    ;
  cn_datatype_date                constant  all_tab_cols.data_type%type  := 'DATE'     ;
  cn_datatype_timestamp           constant  all_tab_cols.data_type%type  := 'TIMESTAMP';
  cn_datatype_timezone            constant  all_tab_cols.data_type%type  := 'TIMEZONE' ;
  cn_datatype_rowid               constant  all_tab_cols.data_type%type  := 'ROWID'    ;

  cn_handler_chr                  constant  ero_types.st_shortstring     := 'AlphaNumeric';
  cn_handler_num                  constant  ero_types.st_shortstring     := 'Numeric';
  cn_handler_dat                  constant  ero_types.st_shortstring     := 'Date';
  cn_handler_timestamp            constant  ero_types.st_shortstring     := 'Timestamp';
  cn_handler_timezone             constant  ero_types.st_shortstring     := 'Timestamp With Timezone';
  cn_handler_rowid                constant  ero_types.st_shortstring     := 'RowID';
  cn_wrong_datahandler            constant  ero_types.st_shortstring     := chr(0);

  cn_stage_run                    constant  ero_types.st_shortstring     := 'STAGE_RUN';
  cn_stage_end                    constant  ero_types.st_shortstring     := 'STAGE_END';


  type rt_column     is record (column_name             all_tab_cols.column_name%type
                               ,data_type               all_tab_cols.data_type  %type
                               ,nullable                all_tab_cols.nullable   %type
                               ,max_columnname_length   integer
                               );
  type rt_value_list is record (value_list              ero_types.st_maxchar
                               ,total_rows              integer    
                               );

  type at_columns      is table of rt_column                 index by pls_integer                ;
  type at_datatype     is table of ero_types.st_shortstring  index by all_tab_cols.data_type%type;
  type at_value_lists  is table of rt_value_list             index by pls_integer                ;

  a_columns                      at_columns    ;
  a_datatype_handler             at_datatype   ;
  a_value_lists                  at_value_lists;

  v_owner                        all_tab_cols.owner     %type;
  v_tablename                    all_tab_cols.table_name%type;
  v_source_tablename             ero_types.st_maxchar;
  v_target_tablename             ero_types.st_maxchar;

  v_record_attribute_list        ero_types.st_maxchar;
  v_insert_column_list           ero_types.st_maxchar;
  v_insert_values_list           ero_types.st_maxchar;
  v_procedure_parameter_list     ero_types.st_maxchar;
  v_select_values_list           ero_types.st_maxchar;
  v_proc_record_assign_list      ero_types.st_maxchar;

  v_query                        ero_types.st_maxchar;
  v_cursor                       sys_refcursor;

  v_progress_rindex              pls_integer;
  v_progress_slno                pls_integer;
  v_extracted                    integer        := 0;


  function indent
    (p_amount   in  integer
    )
    return ero_types.st_maxchar
    is
    begin   -- indent
      return (rpad (ero_const.cn_space
                   ,p_amount
                   ,ero_const.cn_space
                   )
             );
    end indent;


  procedure init_datatype_handler
    is
    begin   -- init_datatype_handler

      a_datatype_handler (cn_datatype_char     ) := cn_handler_chr;
      a_datatype_handler (cn_datatype_varchar2 ) := cn_handler_chr;
      a_datatype_handler (cn_datatype_clob     ) := cn_handler_chr;
      a_datatype_handler (cn_datatype_nchar    ) := cn_handler_chr;
      a_datatype_handler (cn_datatype_nvarchar2) := cn_handler_chr;
      a_datatype_handler (cn_datatype_nclob    ) := cn_handler_chr;

      a_datatype_handler (cn_datatype_number   ) := cn_handler_num;
      a_datatype_handler (cn_datatype_float    ) := cn_handler_num;

      a_datatype_handler (cn_datatype_date     ) := cn_handler_dat;

      a_datatype_handler (cn_datatype_timestamp) := cn_handler_timestamp;
      a_datatype_handler (cn_datatype_timezone ) := cn_handler_timezone;

      a_datatype_handler (cn_datatype_rowid    ) := cn_handler_rowid;

    end init_datatype_handler;


  procedure set_nls_preferences
    (p_stage  in  ero_types.st_shortstring
    )
    is
    begin   -- set_nls_preferences
      case p_stage
        when cn_stage_run then ero_session.set_nls_parameter
                                             (pi_parameter_name => cn_param_nls_date_fmt
                                             ,pi_setting        => cn_nls_date_fmt
                                             );
                               ero_session.set_nls_parameter
                                             (pi_parameter_name => cn_param_nls_num_chars
                                             ,pi_setting        => cn_nls_num_chars
                                             );
                               ero_session.set_nls_parameter
                                             (pi_parameter_name => cn_param_nls_timestamp_fmt
                                             ,pi_setting        => cn_nls_timestamp_fmt
                                             );
                               ero_session.set_nls_parameter
                                             (pi_parameter_name => cn_param_nls_timestamp_tz_fmt
                                             ,pi_setting        => cn_nls_timestamp_tz_fmt
                                             );
        when cn_stage_end then ero_session.reset_nls_parameter
                                             (pi_parameter_name => cn_param_nls_date_fmt
                                             );
                               ero_session.reset_nls_parameter
                                             (pi_parameter_name => cn_param_nls_num_chars
                                             );
                               ero_session.reset_nls_parameter
                                             (pi_parameter_name => cn_param_nls_timestamp_fmt
                                             );
                               ero_session.reset_nls_parameter
                                             (pi_parameter_name => cn_param_nls_timestamp_tz_fmt
                                             );
        else                   ero_utl.rae ('invalid stage: '||p_stage);
      end case;
    end set_nls_preferences;


  procedure split_tablename
    is
      v_dot_location   integer;
      v_at_location    integer;


      procedure conditional_upper
        (p_identifier   in out  ero_types.st_maxchar
        )
        is
        begin   -- conditional_upper

          -- If the identifier is enclosed by double quotes leave it as it is, otherwise uppercase it
          if substr(p_identifier, 1, 1) <> ero_const.cn_doublequote
          or substr(p_identifier, -1)   <> ero_const.cn_doublequote
          then
            p_identifier := upper(p_identifier);
          end if;

        end conditional_upper;


    begin   -- split_tablename
      v_at_location  := instr(p_tablename
                             ,ero_const.cn_at
                             );
      v_dot_location := instr(p_tablename
                             ,ero_const.cn_dot
                             );

      if v_at_location <> 0
      then
        ero_utl.rae ('Retrieval of data through database link not supported by this functionality');
      end if;

      if v_dot_location = 0
      then
        v_owner     := user;
        v_tablename := p_tablename;
      else
        v_owner     := trim (substr(p_tablename
                                   ,1
                                   ,v_dot_location - 1
                                   )
                            );
        v_tablename := trim (substr(p_tablename
                                   ,v_dot_location + 1
                                   )
                            );
      end if;

      v_target_tablename := case 
                              when p_include_owner
                              then p_tablename
                              else v_tablename
                            end;
      
      v_source_tablename := case instr(p_tablename,ero_const.cn_doublequote)
                              when 0
                              then lower (trim (both ero_const.cn_doublequote from p_tablename))
                              else p_tablename
                            end;
      
      
      conditional_upper (v_owner    );
      conditional_upper (v_tablename);

    end split_tablename;


  function table_columns
    return at_columns
    is
      cn_no                           constant  ero_types.st_shortstring     := 'NO';
      cn_yes                          constant  ero_types.st_shortstring     := 'YES';

      cursor c_col (cp_owner      all_tab_cols.owner     %type
                   ,cp_tablename  all_tab_cols.table_name%type
                   )
      is
      select case atc.column_name
               when upper(atc.column_name)
               then lower(atc.column_name)       --no doublequotes needed if column is in all uppercae
               else ero_const.cn_doublequote||atc.column_name||ero_const.cn_doublequote
             end                                       column_name
      ,      case
               when atc.data_type like cn_datatype_timezone_template
               then cn_datatype_timezone
               when atc.data_type like cn_datatype_timestamp_template
               then cn_datatype_timestamp
               else atc.data_type
             end                                       data_type
      ,      atc.nullable
      ,      max(length(atc.column_name)+2) over ()    max_columnname_length
      from   all_tab_cols  atc
      where  atc.owner           = cp_owner
        and  atc.table_name      = cp_tablename
        and  atc.virtual_column  = cn_no
        and  atc.user_generated  = cn_yes
      order by atc.column_id
      ;

      a_result   at_columns;

    begin   -- table_columns
      open c_col (cp_owner     => trim (both ero_const.cn_doublequote from v_owner    )
                 ,cp_tablename => trim (both ero_const.cn_doublequote from v_tablename)
                 );
      fetch c_col
      bulk collect
      into  a_result;
      close c_col;

      if a_result.count = 0
      then
        ero_utl.rae ('No insertable columns found for table '||v_source_tablename);
      end if;

      return (a_result);
    end table_columns;


  procedure process_columns
    is
      cn_record_attribute_indent     constant   integer   := 30;
      cn_insert_column_indent        constant   integer   := 17;
      cn_insert_values_indent        constant   integer   := 17;
      cn_procedure_parameter_indent  constant   integer   :=  2;
      cn_select_values_indent        constant   integer   :=  7;
      cn_proc_record_assign_indent    integer   :=  4;

      v_padded_columnname      ero_types.st_maxchar;


      procedure check_datatype_handler
      (pr_column  in  rt_column
      )
      is
      begin   -- check_datatype_handler
        if not a_datatype_handler.exists (pr_column.data_type)
        then
          ero_utl.rae ('Requested table '||v_source_tablename||' contains a column ('||pr_column.column_name||') with unsupported datatype: '||pr_column.data_type);
        end if;
      end check_datatype_handler;


      procedure check_handled
      (pr_column         in  rt_column
      ,p_function_call   in  ero_types.st_shortstring
      )
      is
      begin   -- check_handled
        if p_function_call = cn_wrong_datahandler
        then
          ero_utl.rae ('Datatype '||pr_column.data_type||' should be handled as '||coalesce(a_datatype_handler(pr_column.data_type),ero_const.cn_nullstring)||' but this handler isn''t implemented.');
        end if;
      end check_handled;


      function column_value
        (pr_column  in  rt_column
        )
        return ero_types.st_maxchar
        is
          v_function_call       ero_types.st_shortstring;
          v_function_end        ero_types.st_shortstring;
        begin   -- column_value
          check_datatype_handler (pr_column);

          v_function_call := case a_datatype_handler (pr_column.data_type)
                               when cn_handler_chr       then null
                               when cn_handler_num       then 'to_char ('
                               when cn_handler_dat       then 'to_char ('
                               when cn_handler_timestamp then 'to_char ('
                               when cn_handler_timezone  then 'to_char ('
                               when cn_handler_rowid     then 'rowidtochar ('
                               else                           cn_wrong_datahandler
                             end;

          check_handled (pr_column       => pr_column
                        ,p_function_call => v_function_call
                        );

          if v_function_call is not null
          then
            v_function_end := ')';
          end if;

          return ('case when ' || pr_column.column_name ||
                  ' is null then ' || ero_utl.quoted('null') ||
                  ' else '||ero_utl.quoted(ero_const.cn_quote) || 
                  ero_const.cn_concat || 'replace(' || v_function_call || pr_column.column_name || v_function_end || 
                  ero_const.cn_comma || ero_utl.quoted(ero_const.cn_quote) || 
                  ero_const.cn_comma || ero_utl.quoted(ero_const.cn_quote||ero_const.cn_quote) || 
                  ero_const.cn_parenthesis_close  || 
                  ero_const.cn_concat || ero_utl.quoted(ero_const.cn_quote) ||
                  ' end '
                 );

        end column_value;


      function record_assign
        (pr_column  in  rt_column
        )
        return ero_types.st_maxchar
        is
          v_function_call       ero_types.st_shortstring;
          v_function_end        ero_types.st_shortstring;
        begin   -- record_assign
          check_datatype_handler (pr_column);

          v_function_call := case a_datatype_handler (pr_column.data_type)
                               when cn_handler_chr       then null
                               when cn_handler_num       then 'to_number ('
                               when cn_handler_dat       then 'to_date ('
                               when cn_handler_timestamp then 'to_timestamp ('
                               when cn_handler_timezone  then 'to_timestamp_tz ('
                               when cn_handler_rowid     then 'chartorowid ('
                               else                           cn_wrong_datahandler
                             end;

          check_handled (pr_column       => pr_column
                        ,p_function_call => v_function_call
                        );

          if v_function_call is not null
          then
            v_function_end := ')';
          end if;

          return ('r_table.' || v_padded_columnname || ':= ' || v_function_call || 'add_data.' || pr_column.column_name || v_function_end || ';'
                 );

        end record_assign;


    begin   -- process_columns

      for i_col in 1 .. a_columns.count
      loop

        v_padded_columnname := rpad (a_columns(i_col).column_name
                                    ,a_columns(i_col).max_columnname_length + 2
                                    );

        if i_col > 1
        then
          v_record_attribute_list    := v_record_attribute_list    || ero_const.cn_eol || indent(cn_record_attribute_indent   ) ||ero_const.cn_comma;
          v_insert_column_list       := v_insert_column_list       || ero_const.cn_eol || indent(cn_insert_column_indent      ) ||ero_const.cn_comma;
          v_insert_values_list       := v_insert_values_list       || ero_const.cn_eol || indent(cn_insert_values_indent      ) ||ero_const.cn_comma;
          v_procedure_parameter_list := v_procedure_parameter_list || ero_const.cn_eol || indent(cn_procedure_parameter_indent) ||ero_const.cn_comma;
          v_proc_record_assign_list  := v_proc_record_assign_list  || ero_const.cn_eol || indent(cn_proc_record_assign_indent );

          v_select_values_list       := v_select_values_list       || ero_const.cn_concat || ero_const.cn_eol || indent(cn_select_values_indent) || ero_utl.quoted(ero_const.cn_comma) || ero_const.cn_concat;
        end if;

        v_record_attribute_list    := v_record_attribute_list    || v_padded_columnname || v_target_tablename || ero_const.cn_dot || a_columns(i_col).column_name || '%type';
        v_insert_column_list       := v_insert_column_list       || a_columns(i_col).column_name;
        v_insert_values_list       := v_insert_values_list       || 'a_table(i_tab).' || a_columns(i_col).column_name;
        v_procedure_parameter_list := v_procedure_parameter_list || v_padded_columnname || 'in   st_maxchar';
        v_proc_record_assign_list  := v_proc_record_assign_list  || record_assign (a_columns(i_col));

        v_select_values_list       := v_select_values_list       || column_value (a_columns(i_col));
      end loop;

    end process_columns;


  procedure build_query
    is
    begin   -- build_query

      v_query := 'select '||v_select_values_list           ||ero_const.cn_eol||
                 ',       count(*) over ()    total_rows'  ||ero_const.cn_eol||
                 '  from '|| v_source_tablename;

    end build_query;


  procedure print_script
    is

      procedure add_data_rows
      is
        cn_add_values_indent  constant   integer  := 2;

        v_fetch_count         integer    := 0;

      begin   -- add_data_rows
 
        -- Uncomment for debugging of generated query
        -- ero_pl.pl('#################################################################');
        -- ero_pl.pl(v_query);
        -- ero_pl.pl('#################################################################');
        
        open v_cursor for v_query;
        loop
          if p_commitsize is null
          then
            -- No intermediate commits, so fetch and process it all

            if v_fetch_count = 0
            then
              -- No fetches have been performed yet, so the "fetch it all" needs ro be done now
              fetch v_cursor
              bulk collect
              into  a_value_lists
              ;
            else
              -- We have already been here, so data has already been fetched and processed
              -- In case of processing all in one go, this code would result in an endless loop if we don't
              -- explicitely clear the collection here
              a_value_lists.delete;
            end if;

          else
            -- Commitsize is set, so fetch and process max commitsize records at a time
            fetch v_cursor
            bulk collect
            into  a_value_lists
            limit p_commitsize
            ;
          end if;

          v_fetch_count  := v_fetch_count  + 1;

          exit when a_value_lists.count = 0;

          if v_fetch_count = 1
          then
            ero_pl.pl ('  v_total_rows := '||to_char(a_value_lists(a_value_lists.first).total_rows)||';');
            ero_pl.pl;
          end if;
        
          for i_lst in 1 .. a_value_lists.count
          loop
            ero_pl.pl (indent(cn_add_values_indent) || 'add_data ' || ero_const.cn_parenthesis_open || a_value_lists(i_lst).value_list || ero_const.cn_parenthesis_close || ero_const.cn_semicolon);
          end loop;
          
          v_extracted := v_extracted + a_value_lists.count;

          dbms_application_info.set_session_longops
            (rindex      => v_progress_rindex
            ,slno        => v_progress_slno
            ,op_name     => 'Retrieve Table Data'
            ,sofar       => v_extracted
            ,totalwork   => a_value_lists(a_value_lists.first).total_rows
            ,target_desc => v_source_tablename
            ,units       => 'Rows extracted'
            );

          ero_pl.pl (  '  insert_records;');
          ero_pl.pl;

        end loop;
        close v_cursor;

      end add_data_rows;

    begin   -- print_script
      ero_pl.pl (  'set define off');
      ero_pl.pl;
      ero_pl.pl (  'declare');
      ero_pl.pl (  '  subtype st_maxchar              is varchar2(32767);');
      ero_pl.pl (  '  subtype st_singlechar           is varchar2(10)   ;');
      ero_pl.pl (  '  subtype st_format               is varchar2(30)   ;');
      ero_pl.pl;
      ero_pl.pl (  '  cn_commitsize        constant   integer        := '||coalesce (to_char(p_commitsize),'null')||';');
      ero_pl.pl (  '  cn_insert_always     constant   integer        := 0;');
      ero_pl.pl (  '  cn_values_org        constant   integer        := 1;');
      ero_pl.pl (  '  cn_values_temp       constant   integer        := 2;');
      ero_pl.pl (q'[  cn_integer_fmt       constant   st_format      := 'fm999g999g999g999g999g999';]');
      ero_pl.pl;
      ero_pl.pl (  '  type rt_table     is record ('||v_record_attribute_list);
      ero_pl.pl (  '                              );');
      ero_pl.pl (  '  type rt_parameter is record (org_value    nls_session_parameters.value%type');
      ero_pl.pl (  '                              ,temp_value   nls_session_parameters.value%type');
      ero_pl.pl (  '                              );');
      ero_pl.pl;
      ero_pl.pl (  '  type at_table     is table of rt_table      index by pls_integer;');
      ero_pl.pl (  '  type at_parameter is table of rt_parameter  index by nls_session_parameters.parameter%type;');
      ero_pl.pl;
      ero_pl.pl (  '  a_table        at_table;');
      ero_pl.pl (  '  a_parameter    at_parameter;');
      ero_pl.pl;
      ero_pl.pl (  '  v_total_rows                   integer;');
      ero_pl.pl (  '  v_progress_rindex              pls_integer;');
      ero_pl.pl (  '  v_progress_slno                pls_integer;');
      ero_pl.pl (  '  v_inserted                     integer   := 0;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '  procedure pl');
      ero_pl.pl (q'[  (pi_line  in  varchar2  default '']');
      ero_pl.pl (  '  )');
      ero_pl.pl (  '  is');
      ero_pl.pl (  '  begin');
      ero_pl.pl (  '    dbms_output.put_line (pi_line);');
      ero_pl.pl (  '  end pl;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '  procedure rae');
      ero_pl.pl (  '  (pi_msg  in  varchar2');
      ero_pl.pl (  '  )');
      ero_pl.pl (  '  is');
      ero_pl.pl (  '  begin');
      ero_pl.pl (  '    raise_application_error (-20000');
      ero_pl.pl (  '                            ,pi_msg');
      ero_pl.pl (  '                            );');
      ero_pl.pl (  '  end rae;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '  procedure get_parameter_values');
      ero_pl.pl (  '  is');
      ero_pl.pl (  '    cn_param_nls_date_fmt           constant  nls_session_parameters.parameter%type   := '||ero_utl.quoted(cn_param_nls_date_fmt        )||';');
      ero_pl.pl (  '    cn_param_nls_num_chars          constant  nls_session_parameters.parameter%type   := '||ero_utl.quoted(cn_param_nls_num_chars       )||';');
      ero_pl.pl (  '    cn_param_nls_timestamp_fmt      constant  nls_session_parameters.parameter%type   := '||ero_utl.quoted(cn_param_nls_timestamp_fmt   )||';');
      ero_pl.pl (  '    cn_param_nls_timestamp_tz_fmt   constant  nls_session_parameters.parameter%type   := '||ero_utl.quoted(cn_param_nls_timestamp_tz_fmt)||';');
      ero_pl.pl;
      ero_pl.pl (  '    cn_nls_date_fmt                 constant  nls_session_parameters.value%type       := '||ero_utl.quoted(cn_nls_date_fmt        )||';');
      ero_pl.pl (  '    cn_nls_num_chars                constant  nls_session_parameters.value%type       := '||ero_utl.quoted(cn_nls_num_chars       )||';');
      ero_pl.pl (  '    cn_nls_timestamp_fmt            constant  nls_session_parameters.value%type       := '||ero_utl.quoted(cn_nls_timestamp_fmt   )||';');
      ero_pl.pl (  '    cn_nls_timestamp_tz_fmt         constant  nls_session_parameters.value%type       := '||ero_utl.quoted(cn_nls_timestamp_tz_fmt)||';');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '    function current_value');
      ero_pl.pl (  '    (parameter_name  in  nls_session_parameters.parameter%type');
      ero_pl.pl (  '    )');
      ero_pl.pl (  '    return nls_session_parameters.value%type');
      ero_pl.pl (  '    is');
      ero_pl.pl (  '      v_result   nls_session_parameters.value%type;');
      ero_pl.pl (  '    begin   -- current_value');
      ero_pl.pl (  '      select prm.value');
      ero_pl.pl (  '      into   v_result');
      ero_pl.pl (  '      from   nls_session_parameters   prm');
      ero_pl.pl (  '      where  prm.parameter = upper (current_value.parameter_name)');
      ero_pl.pl (  '      ;');
      ero_pl.pl;
      ero_pl.pl (  '      return (v_result);');
      ero_pl.pl (  '    exception');
      ero_pl.pl (  '      when no_data_found');
      ero_pl.pl (  '      then');
      ero_pl.pl (q'[        rae ('No parameter with name "'||parameter_name||'" can be found in view nls_session_parameters');]');
      ero_pl.pl (  '    end current_value;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '    procedure store_parameter');
      ero_pl.pl (  '    (parameter_name  in  nls_session_parameters.parameter%type');
      ero_pl.pl (  '    ,temp_setting    in  nls_session_parameters.value%type');
      ero_pl.pl (  '    )');
      ero_pl.pl (  '    is');
      ero_pl.pl (  '      r_parameter   rt_parameter;');
      ero_pl.pl (  '    begin   -- store_parameter');
      ero_pl.pl (  '      r_parameter.org_value  := current_value (parameter_name);');
      ero_pl.pl (  '      r_parameter.temp_value := temp_setting;');
      ero_pl.pl;
      ero_pl.pl (  '      a_parameter (parameter_name) := r_parameter;');
      ero_pl.pl (  '    end store_parameter;');
      ero_pl.pl;
      ero_pl.pl (  '  begin   -- get_parameter_values');
      ero_pl.pl (  '    store_parameter (cn_param_nls_date_fmt         , cn_nls_date_fmt        );');
      ero_pl.pl (  '    store_parameter (cn_param_nls_num_chars        , cn_nls_num_chars       );');
      ero_pl.pl (  '    store_parameter (cn_param_nls_timestamp_fmt    , cn_nls_timestamp_fmt   );');
      ero_pl.pl (  '    store_parameter (cn_param_nls_timestamp_tz_fmt , cn_nls_timestamp_tz_fmt);');
      ero_pl.pl (  '  end get_parameter_values;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '  procedure set_parameter_values');
      ero_pl.pl (  '  (desired_values   in  nls_session_parameters.value%type');
      ero_pl.pl (  '  )');
      ero_pl.pl (  '  is');
      ero_pl.pl (q'[    cn_quote     constant    st_singlechar   := '''';]');
      ero_pl.pl;
      ero_pl.pl (  '    v_parameter  nls_session_parameters.parameter%type;');
      ero_pl.pl (  '    v_stmnt      st_maxchar;');
      ero_pl.pl;
      ero_pl.pl (  '  begin   -- set_parameter_values');
      ero_pl.pl (  '    v_parameter := a_parameter.first;');
      ero_pl.pl (  '    while v_parameter is not null');
      ero_pl.pl (  '    loop');
      ero_pl.pl (q'[      v_stmnt := 'alter session set '||v_parameter||' = '||cn_quote]');
      ero_pl.pl (  '                                                         ||case desired_values');
      ero_pl.pl (  '                                                             when cn_values_org  then a_parameter (v_parameter).org_value');
      ero_pl.pl (  '                                                             when cn_values_temp then a_parameter (v_parameter).temp_value');
      ero_pl.pl (  '                                                           end');
      ero_pl.pl (  '                                                         ||cn_quote;');
      ero_pl.pl (  '      execute immediate v_stmnt;');
      ero_pl.pl (  '      v_parameter := a_parameter.next (v_parameter);');
      ero_pl.pl (  '    end loop;');
      ero_pl.pl (  '  end set_parameter_values;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '  procedure insert_records');
      ero_pl.pl (  '  is');
      ero_pl.pl (  '  begin   -- insert_records');
      ero_pl.pl (  '    if a_table.count > 0');
      ero_pl.pl (  '    then');
      ero_pl.pl (  '      forall i_tab in 1 .. a_table.last');
      ero_pl.pl (  '          insert');
      ero_pl.pl (  '          into   '||v_target_tablename);
      ero_pl.pl (  '                 ('||v_insert_column_list);
      ero_pl.pl (  '                 )');
      ero_pl.pl (  '          values ('||v_insert_values_list);
      ero_pl.pl (  '                 );');
      ero_pl.pl;
      ero_pl.pl (  '      commit;');
      ero_pl.pl;
      ero_pl.pl (  '      v_inserted := v_inserted + a_table.count;');
      ero_pl.pl;
      ero_pl.pl (  '      dbms_application_info.set_session_longops');
      ero_pl.pl (  '        (rindex      => v_progress_rindex');
      ero_pl.pl (  '        ,slno        => v_progress_slno');
      ero_pl.pl (q'[        ,op_name     => 'Insert Table Data']');
      ero_pl.pl (  '        ,sofar       => v_inserted');
      ero_pl.pl (  '        ,totalwork   => v_total_rows');
      ero_pl.pl (  '        ,target_desc => '||ero_utl.quoted(v_target_tablename));
      ero_pl.pl (q'[        ,units       => 'Rows inserted']');
      ero_pl.pl (  '        );');
      ero_pl.pl;
      ero_pl.pl (  '      a_table.delete;');
      ero_pl.pl (  '    end if;');
      ero_pl.pl (  '  end insert_records;');
      ero_pl.pl;
      ero_pl.pl;
      ero_pl.pl (  '  procedure add_data');
      ero_pl.pl (  '  ('||v_procedure_parameter_list);
      ero_pl.pl (  '  )');
      ero_pl.pl (  '  is');
      ero_pl.pl (  '    r_table     rt_table;');
      ero_pl.pl (  '  begin   -- add_data');
      ero_pl.pl (  '    '||v_proc_record_assign_list);
      ero_pl.pl;
      ero_pl.pl (  '    a_table (a_table.count + 1) := r_table;');
      ero_pl.pl;
      ero_pl.pl (  '  end add_data;');
      ero_pl.pl;
      ero_pl.pl (  'begin');
      ero_pl.pl (q'[  pl ('===> table: ]'||v_target_tablename||q'[');]');
      ero_pl.pl;
      ero_pl.pl (q'[  dbms_application_info.set_module('Insert Data Into Table']');
      ero_pl.pl (q'[                                  ,'Table: ]'||v_target_tablename||q'[']');
      ero_pl.pl (  '                                  );');
      ero_pl.pl (  '  v_progress_rindex := dbms_application_info.set_session_longops_nohint;');
      ero_pl.pl;
      ero_pl.pl (  '  get_parameter_values;');
      ero_pl.pl (  '  set_parameter_values (cn_values_temp);');
      ero_pl.pl;

      add_data_rows;

      ero_pl.pl;
      ero_pl.pl (  '  set_parameter_values (cn_values_org);');
      ero_pl.pl;
      ero_pl.pl (q'[  pl ('Inserted rows: '||to_char(v_inserted ,cn_integer_fmt));]');
      ero_pl.pl (  '  pl;');
      ero_pl.pl;
      ero_pl.pl (  '  dbms_application_info.set_module(null,null);');
      ero_pl.pl;
      ero_pl.pl (  'exception');
      ero_pl.pl (  '  when others');
      ero_pl.pl (  '  then');
      ero_pl.pl (  '    rollback;');
      ero_pl.pl (  '    set_parameter_values (cn_values_org);');
      ero_pl.pl (q'[    pl ('### Error occured during data load');]');
      ero_pl.pl;
      ero_pl.pl (  '    case v_inserted');
      ero_pl.pl (  '      when 0');
      ero_pl.pl (q'[      then pl ('## NO data has been loaded into table');]');
      ero_pl.pl (q'[      else pl ('## WARNING: Load may NOT be complete, '||to_char(v_inserted ,cn_integer_fmt)||' rows have been succesfully loaded');]');
      ero_pl.pl (  '    end case;');
      ero_pl.pl;
      ero_pl.pl (  '    dbms_application_info.set_module(null,null);');
      ero_pl.pl;
      ero_pl.pl (  '    raise;');
      ero_pl.pl (  'end;');
      ero_pl.pl (  '/');
      ero_pl.pl;
      ero_pl.pl (  'set define on');
      ero_pl.pl;

    end print_script;


begin   -- ero_tabledata_bulkinserts
  dbms_application_info.set_module('Create Data Insert Script'
                                  ,'Table: '||v_source_tablename
                                  );
  v_progress_rindex := dbms_application_info.set_session_longops_nohint;

  if p_commitsize <= 0
  then
    ero_utl.rae ('Commitsize should be null (meaning 1 commit at end) or greater than 0, not '||p_commitsize);
  end if;

  ero_pl.set_linelength;

  init_datatype_handler;
  set_nls_preferences (cn_stage_run);

  split_tablename;

  a_columns := table_columns;

  process_columns;
  build_query;

  print_script;

  set_nls_preferences (cn_stage_end);

  dbms_application_info.set_module(null,null);
exception
  when others
  then
    set_nls_preferences (cn_stage_end);

    if v_cursor%isopen
    then
      close v_cursor;
    end if;

    dbms_application_info.set_module(null,null);

    raise;

end ero_tabledata_bulkinserts;
/
sho err
