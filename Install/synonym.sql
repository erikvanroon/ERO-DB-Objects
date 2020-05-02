prompt ##############################
prompt Granting and Creating Synonyms
prompt ##############################
prompt

-------------------------------------------------------------------------
--                                                                     --
--       _/_/_/_/              _/_/_/      _/_/      _/_/_/    _/_/_/  --
--      _/        _/      _/  _/    _/  _/    _/  _/        _/         --
--     _/_/_/    _/      _/  _/_/_/    _/    _/  _/          _/_/      --
--    _/          _/  _/    _/    _/  _/    _/  _/              _/     --
--   _/_/_/_/      _/      _/    _/    _/_/      _/_/_/  _/_/_/        --
--                                                                     --
-------------------------------------------------------------------------


prompt ==========================
prompt Grants
prompt ==========================

-- packages
grant execute on ero_settings               to public;
grant execute on ero_callstack              to public;
grant execute on ero_const                  to public;
grant execute on ero_directory              to public;
grant execute on ero_email                  to public;
grant execute on ero_error                  to public;
grant execute on ero_file                   to public;
grant execute on ero_fill                   to public;
grant execute on ero_kalender               to public;
grant execute on ero_logging                to public;
grant execute on ero_periods                to public;
grant execute on ero_pl                     to public;
grant execute on ero_ranges                 to public;
grant execute on ero_session                to public;
grant execute on ero_stopwatch              to public;
grant execute on ero_timing                 to public;
grant execute on ero_trace                  to public;
grant execute on ero_types                  to public;
grant execute on ero_utl                    to public;

-- procedures
grant execute on erolog                    to public;
grant execute on ero_tabledata_bulkinserts to public;


-- tables
grant all     on ero_setting_values        to public;
grant all     on ero_gtt_dir_list          to public;
grant all     on ero_log                   to public;

-- types
grant all     on ot_ero_callstack          to public;
grant all     on ot_ero_distribution_chr   to public;
grant all     on ot_ero_distribution_dat   to public;
grant all     on ot_ero_distribution_num   to public;
grant all     on ot_ero_errorstack         to public;
grant all     on ot_ero_file_properties    to public;
grant all     on nt_ero_callstack          to public;
grant all     on nt_ero_dir_contents       to public;
grant all     on nt_ero_distribution_chr   to public;
grant all     on nt_ero_distribution_dat   to public;
grant all     on nt_ero_distribution_num   to public;
grant all     on nt_ero_errorstack         to public;
grant all     on nt_ero_identifier         to public;
grant all     on nt_ero_maxchar            to public;

-- sequences
grant all     on ero_log_seq               to public;

-- Java classes
grant execute on "EroDirList"              to public;


prompt ==========================
prompt Public Synonyms
prompt ==========================

-- packages
create public synonym ero_settings              for ero_settings            ;
create public synonym ero_callstack             for ero_callstack           ;
create public synonym ero_const                 for ero_const               ;
create public synonym ero_directory             for ero_directory           ;
create public synonym ero_email                 for ero_email               ;
create public synonym ero_error                 for ero_error               ;
create public synonym ero_file                  for ero_file                ;
create public synonym ero_fill                  for ero_fill                ;
create public synonym ero_kalender              for ero_kalender            ;
create public synonym ero_logging               for ero_logging             ;
create public synonym ero_periods               for ero_periods             ;
create public synonym ero_pl                    for ero_pl                  ;
create public synonym ero_ranges                for ero_ranges              ;
create public synonym ero_session               for ero_session             ;
create public synonym ero_stopwatch             for ero_stopwatch           ;
create public synonym ero_timing                for ero_timing              ;
create public synonym ero_trace                 for ero_trace               ;
create public synonym ero_types                 for ero_types               ;
create public synonym ero_utl                   for ero_utl                 ;

-- procedures
create public synonym erolog                    for erolog                  ;
create public synonym ero_tabledata_bulkinserts for ero_tabledata_bulkinserts;

-- tables
create public synonym ero_setting_values        for ero_setting_values      ;
create public synonym ero_gtt_dir_list          for ero_gtt_dir_list        ;
create public synonym ero_log                   for ero_log                 ;

-- types
create public synonym ot_ero_callstack          for ot_ero_distribution_num ;
create public synonym ot_ero_distribution_num   for ot_ero_callstack        ;
create public synonym ot_ero_distribution_chr   for ot_ero_distribution_chr ;
create public synonym ot_ero_distribution_dat   for ot_ero_distribution_dat ;
create public synonym ot_ero_errorstack         for ot_ero_errorstack       ;
create public synonym ot_ero_file_properties    for ot_ero_file_properties  ;
create public synonym nt_ero_callstack          for nt_ero_callstack        ;
create public synonym nt_ero_dir_contents       for nt_ero_dir_contents     ;
create public synonym nt_ero_distribution_chr   for nt_ero_distribution_chr ;
create public synonym nt_ero_distribution_dat   for nt_ero_distribution_dat ;
create public synonym nt_ero_distribution_num   for nt_ero_distribution_num ;
create public synonym nt_ero_errorstack         for nt_ero_errorstack       ;
create public synonym nt_ero_identifier         for nt_ero_identifier       ;
create public synonym nt_ero_maxchar            for nt_ero_maxchar          ;

-- sequences
create public synonym ero_log_seq               for ero_log_seq             ;
