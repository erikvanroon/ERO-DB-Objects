prompt ===>  ot_ero_callstack
create or replace type ot_ero_callstack force as object
(dynamic_depth           integer
,lexical_depth           integer
,owner                   varchar2(128)
,containing_object       varchar2(128)
,subprogram_name         varchar2(128)
,subprogram_fullname     varchar2(32767)
,line_number             integer
,n_subprogram_hierarchy  nt_ero_identifier

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
-- * Name module : ot_ero_callstack
-- * Version     : 01.00
-- * Author      : Erik van Roon
-- * Function    : Recordtype for a callstack
-- *********************************************************************************

,constructor function ot_ero_callstack
 return self as result
);
/
sho err

create or replace type body ot_ero_callstack is

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
-- * Name module : ot_ero_callstack
-- * Version     : 01.00
-- * Author      : Erik van Roon
-- *********************************************************************************

  -- constructor, initialising all attributes as null
  constructor function ot_ero_callstack
  return self as result
  is
  begin
    dynamic_depth          := null;
    lexical_depth          := null;
    owner                  := null;
    containing_object      := null;
    subprogram_name        := null;
    subprogram_fullname    := null;
    line_number            := null;
    n_subprogram_hierarchy := nt_ero_identifier();

    return;
  end ot_ero_callstack;
end;
/
sho err

