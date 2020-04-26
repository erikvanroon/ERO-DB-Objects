prompt ===> ero_log
create or replace trigger ero_log_bri
before insert
on ero_log
for each row
declare

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
  -- * Name module : ero_log_bri
  -- * Version     : 02.00
  -- * Author      : Erik van Roon
  -- *********************************************************************************
begin
  :new.id        := coalesce (:new.id
                             ,ero_log_seq.nextval
                             );
  :new.logged_by := coalesce(:new.logged_by,user   );
  :new.logged_at := coalesce(:new.logged_at,sysdate);
  :new.logtype   := upper(:new.logtype);
end;
/
sho err
