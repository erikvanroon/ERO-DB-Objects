prompt ===>  ot_ero_errorstack
create or replace type ot_ero_errorstack force as object
(error_depth          integer
,line_number          integer
,unit                 varchar2(257)
,error_number         integer
,error_msg            varchar2(32767)

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
-- * Name module : ot_ero_errorstack
-- * Version     : 01.00
-- * Author      : Erik van Roon
-- * Function    : Recordtype for an errorstack
-- *********************************************************************************

,constructor function ot_ero_errorstack
 return self as result
);
/
sho err

create or replace type body ot_ero_errorstack is

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
-- * Name module : ot_ero_errorstack
-- * Version     : 01.00
-- * Author      : Erik van Roon
-- *********************************************************************************

  -- constructor, initialising all attributes as null
  constructor function ot_ero_errorstack
  return self as result
  is
  begin
    error_depth   := null;
    line_number   := null;
    unit          := null;
    error_number  := null;
    error_msg     := null;

    return;
  end ot_ero_errorstack;
end;
/
sho err

