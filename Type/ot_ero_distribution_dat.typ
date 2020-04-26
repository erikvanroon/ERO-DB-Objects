prompt ===> ot_ero_distribution_dat
create or replace type ot_ero_distribution_dat as object
(process_nr       integer
,key_start        date
,key_end          date
,rec_count        integer

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
-- * Name module : ot_ero_distribution_dat
-- * Version     : 02.00
-- * Author      : Erik van Roon
-- * Function    : Recordtype for distributions of records into subprocessses 
-- *               based upon a date key column
-- *********************************************************************************

,constructor function ot_ero_distribution_dat
 return self as result
);
/
sho err

create or replace type body ot_ero_distribution_dat is

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
-- * Name module : ot_ero_distribution_dat
-- * Version     : 02.00
-- * Author      : Erik van Roon
-- *********************************************************************************

  -- constructor, initialising all attributes as null
  constructor function ot_ero_distribution_dat
  return self as result
  is
  begin
    process_nr := null;
    key_start  := null;
    key_end    := null;
    rec_count  := null;
    return;
  end ot_ero_distribution_dat;
end;
/
sho err

