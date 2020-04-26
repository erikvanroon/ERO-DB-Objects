create or replace and compile java source named "EroDirList"
as
import java.io.*;
import java.sql.*;

    public class EroDirList
    {
      // -------------------------------------------------------------------------
      // --                                                                     --
      // --       _/_/_/_/              _/_/_/      _/_/      _/_/_/    _/_/_/  --
      // --      _/        _/      _/  _/    _/  _/    _/  _/        _/         --
      // --     _/_/_/    _/      _/  _/_/_/    _/    _/  _/          _/_/      --
      // --    _/          _/  _/    _/    _/  _/    _/  _/              _/     --
      // --   _/_/_/_/      _/      _/    _/    _/_/      _/_/_/  _/_/_/        --
      // --                                                                     --
      // -------------------------------------------------------------------------
      // 
      // 
      // -- *********************************************************************************
      // -- * Name module : EroDirList
      // -- * Version     : 01.00
      // -- * Author      : Erik van Roon
      // -- * Function    : Get the contents of a filesystem directory and store it 
      // -- *               in a global temporary table
      // -- *********************************************************************************

    public static void getList(String Directory, String FileIndicator, String DirIndicator) throws SQLException
    {

       Connection conn = DriverManager.getConnection("jdbc:default:connection:");
       
       String ClearGTT  = "delete from ero_gtt_dir_list";
       String InsertGTT = "insert into ero_gtt_dir_list (pathname,filetype,filebytes,lastmodified) " +
                          "values (?, ?, ?, ?)";

       PreparedStatement pstmtClear  = conn.prepareStatement(ClearGTT );
       PreparedStatement pstmtInsert = conn.prepareStatement(InsertGTT);

       File path = new File(Directory);

       FileFilter OnlyFileFilter = new FileFilter() {
                        public boolean accept(File file) {
                                return file.isFile();
                        }
                };

       File[] FileList;

       FileList = path.listFiles();

       String    TheFile;
       Timestamp ModiDate;
       Long      FileBytes;
       String    FileType;

       // Clear the global temporary table of possible data from previous call
       // Note: Use a DELETE rather than a TRUNCATE, because TRUNCATE is DDL, hence you get an implicit commit;
       //       That could inadvertently commit other changes if not called from within an autonomous transaction.
       pstmtClear.executeUpdate();

       for(int i = 0; i < FileList.length; i++)
       {
           TheFile = FileList[i].getAbsolutePath();

           if (FileList[i].isFile()) {

             FileType  = FileIndicator;

           } else {

             FileType  = DirIndicator;
           }

           FileBytes = FileList[i].length();
           ModiDate  = new Timestamp( FileList[i].lastModified() );

           pstmtInsert.setString   (1, TheFile  );
           pstmtInsert.setString   (2, FileType );
           pstmtInsert.setLong     (3, FileBytes);
           pstmtInsert.setTimestamp(4, ModiDate );
           
           pstmtInsert.executeUpdate();
       }

       pstmtClear.close();
       pstmtInsert.close();

   }
  }
/
sho err
