--
-------------------------------------------------------------------------
--                                                                     --
--       _/_/_/_/              _/_/_/      _/_/      _/_/_/    _/_/_/  --
--      _/        _/      _/  _/    _/  _/    _/  _/        _/         --
--     _/_/_/    _/      _/  _/_/_/    _/    _/  _/          _/_/      --
--    _/          _/  _/    _/    _/  _/    _/  _/              _/     --
--   _/_/_/_/      _/      _/    _/    _/_/      _/_/_/  _/_/_/        --
--                                                                     --
-------------------------------------------------------------------------
--
spool cre_all
-- Show current schema
prompt Own schema
prompt ==========
@ schema

prompt
prompt

prompt ###############################
prompt Drop objects that already exist
prompt ###############################
prompt
@@ .\drop_all.sql

prompt
prompt

prompt ##################
prompt Create ERO objects
prompt ##################
prompt
prompt Constants and Types Packages
prompt ============================
@@ ..\Package\ero_types.pcs
@@ ..\Package\ero_const.pcs


prompt Sequences
prompt =========
@@ ..\Sequence\ero_log_seq.seq


prompt Object Types
prompt ============
@@ ..\Type\ot_ero_distribution_chr.typ
@@ ..\Type\ot_ero_distribution_dat.typ
@@ ..\Type\ot_ero_distribution_num.typ
@@ ..\Type\ot_ero_errorstack.typ
@@ ..\Type\ot_ero_file_properties.typ 

@@ ..\Type\nt_ero_dir_contents.typ 
@@ ..\Type\nt_ero_distribution_chr.typ
@@ ..\Type\nt_ero_distribution_dat.typ
@@ ..\Type\nt_ero_distribution_num.typ
@@ ..\Type\nt_ero_errorstack.typ
@@ ..\Type\nt_ero_identifier.typ
@@ ..\Type\nt_ero_maxchar.typ

@@ ..\Type\ot_ero_callstack.typ   -- MOET NA DE nt_ero_identifier !!!!
@@ ..\Type\nt_ero_callstack.typ


prompt Tables
prompt ======
@@ ..\Table\ero_basedata_definitions.tab
@@ ..\Table\ero_gtt_dir_list.tab 
@@ ..\Table\ero_log.tab


Prompt JavaCode
Prompt ============================================== 
@@ ..\Java\EroDirList.jav


prompt PK and UK Constraints
prompt =====================
@@ ..\Constraint\ero_basedata_definitions.puk
@@ ..\Constraint\ero_log.puk


prompt Check Constraints
prompt ===========
@@ ..\Constraint\ero_basedata_definitions.chk
@@ ..\Constraint\ero_log.chk


prompt Package specs
prompt =============
@@ ..\Package\ero_logging.pcs
@@ ..\Package\ero_basedata.pcs
@@ ..\Package\ero_callstack.pcs
@@ ..\Package\ero_directory.pcs 
@@ ..\Package\ero_email.pcs
@@ ..\Package\ero_error.pcs 
@@ ..\Package\ero_file.pcs
@@ ..\Package\ero_fill.pcs
@@ ..\Package\ero_kalender.pcs
@@ ..\Package\ero_periods.pcs
@@ ..\Package\ero_pl.pcs
@@ ..\Package\ero_ranges.pcs
@@ ..\Package\ero_session.pcs
@@ ..\Package\ero_stopwatch.pcs
@@ ..\Package\ero_timing.pcs
@@ ..\Package\ero_trace.pcs
@@ ..\Package\ero_utl.pcs


prompt Package bodies
prompt ==============
@@ ..\Package\ero_basedata.pcb
@@ ..\Package\ero_callstack.pcb
@@ ..\Package\ero_const.pcb
@@ ..\Package\ero_directory.pcb 
@@ ..\Package\ero_email.pcb
@@ ..\Package\ero_error.pcb 
@@ ..\Package\ero_file.pcb
@@ ..\Package\ero_fill.pcb
@@ ..\Package\ero_kalender.pcb
@@ ..\Package\ero_logging.pcb
@@ ..\Package\ero_periods.pcb
@@ ..\Package\ero_pl.pcb
@@ ..\Package\ero_ranges.pcb
@@ ..\Package\ero_session.pcb
@@ ..\Package\ero_stopwatch.pcb
@@ ..\Package\ero_timing.pcb
@@ ..\Package\ero_trace.pcb
@@ ..\Package\ero_utl.pcb


prompt Procedures
prompt ==========
@@ ..\Procedure\erolog.prc
@@ ..\Procedure\ero_tabledata_bulkinserts.prc


--prompt Functions
--prompt =========
--@@ ..\Function\tabledata_insert_stmnts.fnc

prompt Triggers
prompt ========
@@ ..\Trigger\ero_basedata_definitions.trg
@@ ..\Trigger\ero_log.trg


prompt SQL Scripts
prompt ===========
@@ ..\DML\ero_basedata_definitions.sql

--@@ .\synonym.sql          -- Only create Public synonyms on private db's


prompt ACL for email package
prompt =====================
@@ ..\Settings\email_acl.sql


prompt ###########################
prompt Recompiling invalid objects
prompt ###########################
@comp

spool off

