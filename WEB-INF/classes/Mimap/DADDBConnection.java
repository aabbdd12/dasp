/*
 * ECNDBConnection.java
 *
 * Created on August 27, 2002, 8:53 AM
 */

package Mimap;

import java.sql.*;

/**
 *
 * @author  cfortin
 * @version
 */
public class DADDBConnection  {
    
    static Connection con = null;
    static Connection conPEP = null;
   private ResultSet rs = null;
     
    public DADDBConnection()
    {
    }
    
    
    
    public void ConnectDB() {
        
        // Chargement du driver
        
        try {
            System.out.println("Triing to connect database ... DAD ");
            Class.forName("org.gjt.mm.mysql.Driver");
        }
        
        catch (Exception e) {
            System.err.println("Unable to load driver.");
            e.printStackTrace();
            return ;
        }
        
        
        // Etablissement de la connection avec la base de donnee.
        
        
        try {
            
            con = DriverManager.getConnection("jdbc:mysql://132.203.59.36/DASP?user=dasp&password=dasp$?*");
            
            
            
            System.out.println("Connection OK ...");
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
            
            sqle.printStackTrace();
        }
        
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
     
    }
    
    
      public Connection ConnectDBPEP() {
        
        // Chargement du driver
        
        try {
            System.out.println("Triing to connect  ... PEP ");
            Class.forName("org.gjt.mm.mysql.Driver");
        }
        
        catch (Exception e) {
            System.err.println("Unable to load driver.");
            e.printStackTrace();
            return conPEP;
        }
        
        
        // Etablissement de la connection avec la base de donnee.
        
        
        try {
            
            conPEP = DriverManager.getConnection("jdbc:mysql://132.203.59.36/DASP?user=dasp&password=dasp$?*");
            return conPEP;
            
           // System.out.println("Connection OK ...");
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
            
            sqle.printStackTrace();
        }
        
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        return conPEP;
     
    }
      
    
     public Connection ConnectDB2() {
        
        // Chargement du driver
        
        try {
            System.out.println("Triing to connect database ... Mimap ");
            Class.forName("org.gjt.mm.mysql.Driver");
        }
        
        catch (Exception e) {
            System.err.println("Unable to load driver.");
            e.printStackTrace();
            return null;
        }
        
        
        // Etablissement de la connection avec la base de donnee.
        
        
        try {
            
            con = DriverManager.getConnection("jdbc:mysql://localhost/DAD?user=admins&password=cirpep");
            
            
            System.out.println("Connection OK ...");
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
            
            sqle.printStackTrace();
        }
        
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return con;
    }
     
    
    public void DisconnectDB() 
    {
        try{
        con.commit();
        con.close();
        }
        catch (Exception e)
        {}
        
    }
    
 
    
    public ResultSet checkLogin(String [][] input) {
        
        // connect to database
        try {
            
            // Create and Execute a query
            
            String queryString = ("SELECT * ");
            queryString += (" FROM users where ");
            queryString += (input[0][0] + " = '" + input[0][1] + "' ");
            queryString += (" AND " + input[1][0] + " = '" + input[1][1] + "' ;");
            System.out.println("Query to execute ... : "+ queryString);
            Statement stmt = con.createStatement();
            rs = stmt.executeQuery(queryString);
            
        }
        
        catch(SQLException ex) {
            System.err.print("SQLException: ");
            System.err.println(ex.getMessage());
        }
        
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    
}
