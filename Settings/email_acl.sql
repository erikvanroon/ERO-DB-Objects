prompt Set ACL Permissions
prompt ===================
begin
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
  -- ACL Permissions for email from database
  --

  -- Create ACL
  dbms_network_acl_admin.create_acl
      (acl          => 'evrocs_smtp_access.xml'
      ,description  => 'Permissions to send mail through evrocs'
      ,principal    => 'PUBLIC'
      ,is_grant     => TRUE
      ,privilege    => 'connect'
      );
  commit;

  -- SMTP Server EvROCS
  dbms_network_acl_admin.assign_acl
      (acl          => 'evrocs_smtp_access.xml'
      ,host         => 'smtp.xs4all.nl'
      ,lower_port   => 465
      ,upper_port   => 465
      );
  commit;

  -- Add user PUBLIC to the ACL
  dbms_network_acl_admin.add_privilege
      (acl          => 'evrocs_smtp_access.xml'
      ,principal    => 'PUBLIC'          -- case-sensitive !!!
      ,is_grant     => true 
      ,privilege    => 'connect'
      );
  commit;

end;
/
