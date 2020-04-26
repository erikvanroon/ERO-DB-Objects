prompt ===>  ot_ero_distribution_num
create or replace type ot_ero_distribution_num as object
(process_nr       integer
,key_start        number
,key_end          number
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
-- * Name module : ot_ero_distribution_num
-- * Version     : 02.00
-- * Author      : Erik van Roon
-- * Function    : Recordtype for distributions of records into subprocessses 
-- *               based upon a numeric key column
-- *********************************************************************************

,constructor function ot_ero_distribution_num
 return self as result
);
/
sho err

create or replace type body ot_ero_distribution_num is

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
-- * Name module : ot_ero_distribution_num
-- * Version     : 02.00
-- * Author      : Erik van Roon
-- *********************************************************************************

  -- constructor, initialising all attributes as null
  constructor function ot_ero_distribution_num
  return self as result
  is
  begin
    process_nr := null;
    key_start  := null;
    key_end    := null;
    rec_count  := null;
    return;
  end ot_ero_distribution_num;
end;
/
sho err

