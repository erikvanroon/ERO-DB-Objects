prompt ===> ot_ero_file_properties

create or replace type ot_ero_file_properties force as object
 (pathname        varchar2(255)
 ,directory       varchar2(255)
 ,filename        varchar2(255)
 ,filetype        varchar2(4)
 ,bytes           integer
 ,filesize        varchar2(12)
 ,lastmodified    date

  -------------------------------------------------------------------------
  --                                                                     --
  --       _/_/_/_/              _/_/_/      _/_/      _/_/_/    _/_/_/  --
  --      _/        _/      _/  _/    _/  _/    _/  _/        _/         --
  --     _/_/_/    _/      _/  _/_/_/    _/    _/  _/          _/_/      --
  --    _/          _/  _/    _/    _/  _/    _/  _/              _/     --
  --   _/_/_/_/      _/      _/    _/    _/_/      _/_/_/  _/_/_/        --
  --                                                                     --
  -------------------------------------------------------------------------
  
  
  -- *********************************************************************************
  -- * Name module : ot_ero_file_properties
  -- * Version     : 01.00
  -- * Author      : Erik van Roon
  -- * Function    : Recordtype for properties of an object (file/directory) in a 
  -- *               filesystem directory
  -- *********************************************************************************

 ,constructor function ot_ero_file_properties 
  return self as result
 
 ,constructor function ot_ero_file_properties
  (p_pathname      in  varchar2
  ,p_filetype      in  varchar2
  ,p_filebytes     in  integer
  ,p_lastmodified  in  date
  )
  return self as result

 )
/
sho err

create or replace type body ot_ero_file_properties 
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
  
  
  -- *********************************************************************************
  -- * Name module : ot_ero_file_properties
  -- * Version     : 01.00
  -- * Author      : Erik van Roon
  -- * Function    : Recordtype for properties of an object (file/directory) in a 
  -- *               filesystem directory
  -- *********************************************************************************

  constructor function ot_ero_file_properties
  return self as result
  is
  begin
    self.pathname     := null;
    self.directory    := null;
    self.filename     := null;
    self.filetype     := null;
    self.bytes        := null;
    self.filesize     := null;
    self.lastmodified := null;

    return;
  end;

  constructor function ot_ero_file_properties
  (p_pathname      in  varchar2
  ,p_filetype      in  varchar2
  ,p_filebytes     in  integer
  ,p_lastmodified  in  date
  )
  return self as result
  is
  begin
    self.pathname     := p_pathname;
    self.directory    := case p_filetype
                           when 'DIR'
                           then p_pathname
                           else substr(p_pathname
                                      ,1
                                      ,instr(p_pathname
                                            ,sys_context ('userenv','platform_slash')
                                            ,-1
                                            ,1
                                            ) - 1
                                      )
                         end;
    self.filename     := case p_filetype
                           when 'DIR'
                           then null
                           else substr(p_pathname
                                      ,instr(p_pathname
                                            ,sys_context ('userenv','platform_slash')
                                            ,-1
                                            ,1
                                            ) + 1
                                      )
                         end;
    self.filetype     := p_filetype;
    self.bytes        := p_filebytes;
    self.filesize     := case
                           when p_filebytes >= power(1024,4) then lpad(to_char(p_filebytes/power(1024,4),'99999999999990d0','nls_numeric_characters = ''.,''')||' TB',12)
                           when p_filebytes >= power(1024,3) then lpad(to_char(p_filebytes/power(1024,3),          '9990d0','nls_numeric_characters = ''.,''')||' GB',12)
                           when p_filebytes >= power(1024,2) then lpad(to_char(p_filebytes/power(1024,2),          '9990d0','nls_numeric_characters = ''.,''')||' MB',12)
                           when p_filebytes >= power(1024,1) then lpad(to_char(p_filebytes/power(1024,1),          '9990d0','nls_numeric_characters = ''.,''')||' KB',12)
                           else                                   lpad(to_char(p_filebytes/power(1024,0),            '9990','nls_numeric_characters = ''.,''')||'  B',12)
                         end;
    self.lastmodified := p_lastmodified;

    return;
  end;
end;
/
sho err
