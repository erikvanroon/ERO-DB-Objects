prompt ===> erolog
create or replace procedure erolog
(p_message  in  ero_log.message%type
,p_logtype  in  ero_log.logtype%type   default ero_logging.cn_info
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

  -- *********************************************************************************
  -- * Name module : erolog
  -- * Version     : 02.00
  -- * Author      : Erik van Roon
  -- * Function    : Log a message to table ero_log
  -- *********************************************************************************
begin
  case upper(coalesce(p_logtype,ero_logging.cn_info))
    when ero_logging.cn_info       then ero_logging.log_info       (p_message);
    when ero_logging.cn_warning    then ero_logging.log_warning    (p_message);
    when ero_logging.cn_error      then ero_logging.log_error      (p_message);
    when ero_logging.cn_fatalerror then ero_logging.log_fatalerror (p_message);
    when ero_logging.cn_debug      then ero_logging.log_debug      (p_message);
    else                                raise_application_error (-20000,'Invalid logtype provided: '||p_message);
  end case;
end erolog;
/
sho err
