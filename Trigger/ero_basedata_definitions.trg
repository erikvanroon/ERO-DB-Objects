prompt ===> ero_basedata_definitions
create or replace trigger ero_bdt_brui
before insert
or     update
on ero_basedata_definitions
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
  -- * Name module : ero_bdt_brui
  -- * Version     : 02.00
  -- * Author      : Erik van Roon
  -- *********************************************************************************
  r_bdt   ero_basedata_definitions%rowtype;
begin

  :new.name     := upper(:new.name    );
  :new.datatype := upper(:new.datatype);

  r_bdt.name          := :new.name         ;
  r_bdt.datatype      := :new.datatype     ;
  r_bdt.datalength    := :new.datalength   ;
  r_bdt.dataprecision := :new.dataprecision;
  r_bdt.fmt           := :new.fmt          ;
  r_bdt.basevalue     := :new.basevalue    ;
  r_bdt.description   := :new.description  ;

  ero_basedata.check_datatype (p_bdt_row => r_bdt);

end;
/
sho err
