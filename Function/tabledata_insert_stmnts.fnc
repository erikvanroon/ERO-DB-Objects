create or replace function tabledata_insert_stmnts
(p_tablename   in  ero_types.st_identifier_dubbel
,p_commitsize  in  integer                          default 1000
)
return nt_ero_maxchar
pipelined
is
  cn_stage_run           constant  ero_types.st_shortstring   := 'STAGE_RUN';
  cn_stage_end           constant  ero_types.st_shortstring   := 'STAGE_END';
  cn_nls_num_chars       constant  ero_types.st_shortstring   := ',.';
  cn_nls_timestamp       constant  ero_types.st_shortstring   := 'DD-MON-RR HH24:MI:SS.FF';
  cn_nls_timestamp_tz    constant  ero_types.st_shortstring   := 'DD-MON-RR HH24:MI:SS.FF TZR';
  cn_no                  constant  ero_types.st_shortstring   := 'NO';
  cn_yes                 constant  ero_types.st_shortstring   := 'YES';
                         
  cn_datatype_chr        constant  integer                    := 1;
  cn_datatype_num        constant  integer                    := 2;
  cn_datatype_dat        constant  integer                    := 3;
  cn_datatype_timestamp  constant  integer                    := 4;
  cn_datatype_rowid      constant  integer                    := 5;


  type rt_col is record (column_name  all_tab_cols.column_name%type
                        ,data_type    all_tab_cols.data_type  %type
                        ,nullable     all_tab_cols.nullable   %type
                        );
  type at_col is table of rt_col  index by pls_integer;
  a_col    at_col;

  type at_datatype is table of integer  index by all_tab_cols.datatype%rowtype;
  a_datatype_handler   at_datatype;
  

  v_owner          all_tab_cols.owner     %type;
  v_tablename      all_tab_cols.table_name%type;
  v_column_list    ero_types.st_maxchar        ;
  v_values_list    ero_types.st_maxchar        ;


  procedure rae
  (pi_msg  in  varchar2
  )
  is
  begin
    raise_application_error (-20000
                            ,pi_msg
                            );
  end rae;

  
  procedure init_datatype_handler
    is
    begin   -- init_datatype_handler
      
      a_datatype_handler ('CHAR'     ) := cn_datatype_chr;                          
      a_datatype_handler ('VARCHAR2' ) := cn_datatype_chr;                                
      a_datatype_handler ('CLOB'     ) := cn_datatype_chr;                                
      a_datatype_handler ('NCHAR'    ) := cn_datatype_chr;                          
      a_datatype_handler ('NVARCHAR2') := cn_datatype_chr;                          
      a_datatype_handler ('NCLOB'    ) := cn_datatype_chr;

      a_datatype_handler ('NUMBER'   ) := cn_datatype_num;
      a_datatype_handler ('FLOAT'    ) := cn_datatype_num;

      a_datatype_handler ('DATE'     ) := cn_datatype_dat;

      a_datatype_handler ('TIMESTAMP') := cn_datatype_timestamp;

      a_datatype_handler ('ROWID'    ) := cn_datatype_rowid;
      
    end init_datatype_handler;
  
  
  procedure split_tablename
    is
      v_dot_location   integer;
      v_at_location    integer;
      
      
      procedure conditional_upper
        (p_identifier   in out  ero_const.maxchar
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
      v_at_location  := instr(p_table_name
                             ,ero_const.cn_at
                             );
      v_dot_location := instr(p_table_name
                             ,ero_const.cn_dot
                             );

      if v_at_location <> 0
      then
        rae ('Retrieval of data through database link not supported by this functionality');
      end if;

      if v_dot_location = 0
      then
        v_owner     := user;
        v_tablename := p_table_name;
      else
        v_owner     := trim (substr(p_table_name
                                   ,1
                                   ,v_dot_location - 1
                                   )
                            );
        v_tablename := trim (substr(p_table_name
                                   ,v_dot_location + 1
                                   )
                            );
      end if;
      
      conditional_upper (v_owner    );
      conditional_upper (v_tablename);
      
    end split_tablename;


  procedure set_nls_preferences
    (p_stage  in  ero_types.st_shortstring
    )
    is
    begin   -- set_nls_preferences
      case p_stage
        when cn_stage_run then ero_session.set_nls_parameter
                                             (pi_parameter_name => 'nls_numeric_characters'
                                             ,pi_setting        => cn_nls_num_chars
                                             );
                               ero_session.set_nls_parameter
                                             (pi_parameter_name => 'nls_timestamp_format'
                                             ,pi_setting        => cn_nls_timestamp
                                             );
                               ero_session.set_nls_parameter
                                             (pi_parameter_name => 'nls_timestamp_tz_format'
                                             ,pi_setting        => cn_nls_timestamp_tz
                                             );
        when cn_stage_end then ero_session.reset_nls_parameter
                                             (pi_parameter_name => 'nls_numeric_characters'
                                             );
                               ero_session.reset_nls_parameter
                                             (pi_parameter_name => 'nls_timestamp_format'
                                             );
                               ero_session.reset_nls_parameter
                                             (pi_parameter_name => 'nls_timestamp_tz_format'
                                             );
        else                   rae ('invalid stage: '||p_stage);
      end case;
    end set_nls_preferences;

  
  function table_columns
    return at_col
    is
      cursor c_col (cp_owner      all_user_cols.owner     %type
                   ,cp_tablename  all_user_cols.table_name%type
                   )
      is
      select ero_const.cn_doublequote||column_name||ero_const.cn_doublequote  column_name
      ,      case 
               when datatype like 'TIMESTAMP%'
               then 'TIMESTAMP'
               else datatype
             end           datatype
      ,      nullable
      from   all_user_cols  auc
      where  auc.owner           = cp_owner
        and  auc.table_name      = cp_tablename
        and  auc.virtual_column  = cn_no
        and  auc.user_generated  = cn_yes
      order by auc.column_id
      ;

      a_result   at_col;

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
        rae ('No columns found for table '||p_table_name);
      end if;

      return (a_result);
    end table_columns;

  
  procedure process_columns
    is  
    
      
      function column_value
        (pr_column   in  rt_col
        )
        return ero_types.st_maxchar
        is
          v_result     ero_types.st_maxchar;
        begin   -- column_value
          
          if not a_datatype_handler.exists (pr_column.datatype)
          then
            rae ('Requested table '||p_table_name||' contains a column ('||pr_column.column_name||') with unsupported datatype: '||pr_column.datatype);
          end if;
          
          v_result := case a_datatype_handler (pr_column.datatype)
                        when cn_datatype_chr       then ero_const.cn_quote || ero_const.cn_concat || 'replace' || ero_const.cn_parenthesis_open || pr_column.column_name || ero_const.cn_comma || ero_utl.quoted(ero_const.cn_quote) || ero_const.cn_comma || ero_utl.quoted(ero_const.cn_quote||ero_const.cn_quote) || ero_const.cn_parenthesis_close || ero_const.cn_concat || ero_const.cn_quote
                        when cn_datatype_num       then 'to_char' || ero_const.cn_parenthesis_open || pr_column.column_name || ero_const.cn_parenthesis_close 
                        when cn_datatype_dat       then 'to_char' || ero_const.cn_parenthesis_open || pr_column.column_name || ero_const.cn_parenthesis_close 
                        when cn_datatype_timestamp then 'to_timestamp' || ero_const.cn_parenthesis_open ||to_char("GDB_START_DATE")||')'
                        when cn_datatype_rowid     then 
                        else 
                      end;
          
        end column_value;
      
    
    begin   -- process_columns
      
      v_column_list := ero_const.cn_parenthesis_open;
      v_values_list := ero_const.cn_parenthesis_open;

      for i_col in 1 .. a_col.count
      loop
        v_column_list := v_column_list || ero_const.cn_comma || a_col(i_col).column_name;
        
        v_values_list := v_values_list || ero_const.cn_comma || column_value(a_col(i_col));
        
      end loop;
      
      v_column_list := v_column_list||ero_const.cn_parenthesis_close;
      v_values_list := v_values_list||ero_const.cn_parenthesis_close;

    end process_columns;
    
  

begin
  init_datatype_handler;
  set_nls_preferences (cn_stage_run);

  split_tablename;

  a_col := table_columns;

  process_columns;

  for i in 1 .. 2
  loop
--    exit when ;
    v_return := 'regel '||to_char(i);


    pipe row (v_return);
  end loop;

  set_nls_preferences (cn_stage_end);

exception
  when no_data_needed
  then
    set_nls_preferences (cn_stage_end);

    if c_tab%isopen
    then
      close c_tab;
    end if;
    -- no message because this isn't really an error condition

  when others
  then
    set_nls_preferences (cn_stage_end);
    raise;

end tabledata_insert_stmnts;
/
sho err
