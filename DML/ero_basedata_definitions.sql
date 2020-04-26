declare

  procedure ins
  (p_name            in  ero_basedata_definitions.name         %type
  ,p_datatype        in  ero_basedata_definitions.datatype     %type
  ,p_datalength      in  ero_basedata_definitions.datalength   %type
  ,p_dataprecision   in  ero_basedata_definitions.dataprecision%type
  ,p_fmt             in  ero_basedata_definitions.fmt          %type
  ,p_basevalue       in  ero_basedata_definitions.basevalue    %type
  ,p_description     in  ero_basedata_definitions.description  %type
  )
  is
    cn_nullstring  constant   varchar2(30)  := '[[Null]]';
  begin   -- ins
    insert
    into   ero_basedata_definitions
           (name         
           ,datatype     
           ,datalength   
           ,dataprecision
           ,fmt          
           ,basevalue    
           ,description  
           )
    values (p_name         
           ,p_datatype     
           ,p_datalength   
           ,p_dataprecision
           ,p_fmt          
           ,p_basevalue    
           ,p_description  
           );

  exception
    when others
    then
      ero_pl.pl ('##################################################################');
      ero_pl.pl ('Probleem bij insert van:');
      ero_pl.pl ('- name          = '||coalesce(p_name          ,cn_nullstring));
      ero_pl.pl ('- datatype      = '||coalesce(p_datatype      ,cn_nullstring));
      ero_pl.pl ('- datalength    = '||coalesce(p_datalength    ,cn_nullstring));
      ero_pl.pl ('- dataprecision = '||coalesce(p_dataprecision ,cn_nullstring));
      ero_pl.pl ('- fmt           = '||coalesce(p_fmt           ,cn_nullstring));
      ero_pl.pl ('- basevalue     = '||coalesce(p_basevalue     ,cn_nullstring));
      ero_pl.pl ('- description   = '||coalesce(p_description   ,cn_nullstring));
      ero_pl.pl ('##################################################################');
      ero_pl.pl ('');
      raise;
  end ins;

begin

    -- name                     , datatype , datalength , dataprecision , fmt  , basevalue , description   
  ins ('DIRLIST_FILE_INDICATOR' , 'C'      , 4          , null          , null , 'File'    , 'Indicator for a file in the dirlisting provided by the ero_directory package'      );
  ins ('DIRLIST_DIR_INDICATOR'  , 'C'      , 4          , null          , null , 'Dir'     , 'Indicator for a directory in the dirlisting provided by the ero_directory package' );

  commit;

end;
/
