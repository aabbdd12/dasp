/*
 * DADUser.java
 *
 * Created on August 27, 2002, 8:54 AM
 */

package Mimap;

import java.io.*;
import java.text.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import javax.rmi.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import Mimap.DADUserForm;
import Mimap.DADSendMail;
import javax.mail.*;
import javax.mail.internet.*;
/**
 *
 * @author  cfortin
 * @version
 */
public class DADUser  {
    
    private ResultSet rs = null;
    static ResultSet resultset;
    private String userName = "";
    private String result = null;
    private String[][] input;
    
    public void DADUser() {
       resultset=null;
    }
    
    
    
    // ********************************************************
    //                    Create user 
    // ********************************************************
    
    
    
    public int createUser(DADUserForm creationFormInput) {
        int error = 0;
        
        String userid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        
        try {
            
           // Create and Execute a query
            System.out.println("Methode évoquée 1");
            String queryString = ("INSERT INTO ");
            queryString += (" USERS ( ");
            queryString += ("USERID,USERNAME,PASSWORD,SALUTATION,FIRSTNAME,LASTNAME,EMAIL,");
            queryString += ("INSTITUTION,ADDRESS,CITY,STATE,POSTALCODE,COUNTRY,PHONE,MAILLIST,SEX,COMMENT,ISOFFICIALMEMBER");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "'");
            queryString += (",'" + creationFormInput.getLogin() + "'");
            queryString += (",'" + creationFormInput.getPassword() + "'");
            queryString += (",'" + creationFormInput.getSalutation() + "'");
            queryString += (",'" + creationFormInput.getFirstName() + "'");
            queryString += (",'" + creationFormInput.getLastName() + "'");
            queryString += (",'" + creationFormInput.getEmail() + "'");
            queryString += (",'" + creationFormInput.getInstitution() + "'");
            queryString += (",'" + creationFormInput.getAddress() + "'");
            queryString += (",'" + creationFormInput.getCity() + "'");
            queryString += (",'" + creationFormInput.getState() + "'");
            queryString += (",'" + creationFormInput.getZip() + "'");
            queryString += (",'" + creationFormInput.getCountry() + "'");
            queryString += (",'" + creationFormInput.getPhone() + "'");
            queryString += (",'" + creationFormInput.getMailingList() + "'");
            queryString += (",'" + creationFormInput.getSex() + "'");
            queryString += (",'" + creationFormInput.getComment() + "'");
            queryString += (",'1'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            System.out.println("Methode évoquée 1");
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery
    
      public String createPEPUser(DADUserForm creationFormInput) {
        int error = 0;
        System.out.println("Methode évoquée 2");
        String userid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" USERS ( ");
            queryString += ("USERID,USERNAME,PASSWORD,SALUTATION,FIRSTNAME,LASTNAME,EMAIL,");
            queryString += ("INSTITUTION,ADDRESS,CITY,STATE,POSTALCODE,COUNTRY,PHONE,ISMAILINGLIST,ISDADUSER,SEX,ISOFFICIALMEMBER,WORKINGGROUP,JOBFUNCTION,ORGANISATION");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "'");
            queryString += (",'" + creationFormInput.getLogin() + "'");
            queryString += (",'" + creationFormInput.getPassword() + "'");
            queryString += (",'" + creationFormInput.getSalutation() + "'");
            queryString += (",'" + creationFormInput.getFirstName() + "'");
            queryString += (",'" + creationFormInput.getLastName() + "'");
            queryString += (",'" + creationFormInput.getEmail() + "'");
           queryString += (",'" + creationFormInput.getInstitution() + "'");
            queryString += (",'" + creationFormInput.getAddress() + "'");
            queryString += (",'" + creationFormInput.getCity() + "'");
            queryString += (",'" + creationFormInput.getState() + "'");
            queryString += (",'" + creationFormInput.getZip() + "'");
            queryString += (",'" + creationFormInput.getCountry() + "'");
            queryString += (",'" + creationFormInput.getPhone() + "'");
            queryString += (",'YES'");
            queryString += (",'YES'");
            queryString += (",'" + creationFormInput.getSex() + "'");
            queryString += (",'1'");
            queryString += (",'DAD'");
            queryString += (",''");
            queryString += (",''");
            queryString += (");");
            
           
            Statement stmt = DADDBConnection.conPEP.createStatement();
            stmt.executeQuery(queryString);
            updateTimestampCreateUser(userid);
            updateTimestampLastMod(userid);
            
            String email = creationFormInput.getEmail();
            String phone = creationFormInput.getPhone();
           
              if (email.compareTo("")!=0 && email.compareTo(" ")!=0 && email!= null)
            createEmailAddress(userid,email,"YES","YES","YES");
             if (phone !=null && phone.compareTo("")!=0 && phone.compareTo(" ")!=0 && phone!= null)
            createPhoneAddress(userid,phone,"Work","1");
            
            
            
            
            DADSendMail sendmail= new DADSendMail();
            sendmail.sendMessageDirectlyNewMemberInPEP(userid);
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
      
        return (userid);
    } // end of executeQuery
    
    
        public int createEmailAddress(String userid,String email,String isworking,String ismain,String formailing) {
        int error = 0;
        
        String mailid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        
        
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" EMAIL ( ");
            queryString += ("EMAILID,USERID,EMAILADDRESS,ISWORKING,ISMAIN,FORMAILING");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + mailid + "'");
            queryString += (",'" + userid + "'");
            queryString += (",'" + email + "'");
            queryString += (",'" + isworking + "'");
            queryString += (",'" + ismain + "'");
            queryString += (",'" + formailing + "'");
            queryString += (");");
            //System.out.println(queryString);
            Statement stmt = DADDBConnection.conPEP.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery

           
           
              public int createPhoneAddress(String userid,String phone,String type,String ismain) {
        int error = 0;
        
        String mailid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        
        
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" PHONE ( ");
            queryString += ("PHONEID,USERID,PHONENUMBER,PHONETYPE,ISMAIN");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + mailid + "'");
            queryString += (",'" + userid + "'");
            queryString += (",'" + phone + "'");
            queryString += (",'" + type + "'");
            queryString += (",'" + ismain + "'");
            
            queryString += (");");
            //System.out.println(queryString);
            Statement stmt = DADDBConnection.conPEP.createStatement();
             stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery
              
           
              
     // ********************************************************
    //                    Create user 
    // ********************************************************
    
    
    
    public int createUserNoneOfficial(DADUserForm creationFormInput) {
        int error = 0;
        
        String userid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" USERS ( ");
            queryString += ("USERID,USERNAME,PASSWORD,SALUTATION,FIRSTNAME,LASTNAME,EMAIL,");
            queryString += ("INSTITUTION,ADDRESS,CITY,STATE,POSTALCODE,COUNTRY,PHONE,MAILLIST,SEX,COMMENT,ISOFFICIALMEMBER");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "'");
            queryString += (",'" + creationFormInput.getLogin() + "'");
            queryString += (",'" + creationFormInput.getPassword() + "'");
            queryString += (",'" + creationFormInput.getSalutation() + "'");
            queryString += (",'" + creationFormInput.getFirstName() + "'");
            queryString += (",'" + creationFormInput.getLastName() + "'");
            queryString += (",'" + creationFormInput.getEmail() + "'");
            queryString += (",'" + creationFormInput.getInstitution() + "'");
            queryString += (",'" + creationFormInput.getAddress() + "'");
            queryString += (",'" + creationFormInput.getCity() + "'");
            queryString += (",'" + creationFormInput.getState() + "'");
            queryString += (",'" + creationFormInput.getZip() + "'");
            queryString += (",'" + creationFormInput.getCountry() + "'");
            queryString += (",'" + creationFormInput.getPhone() + "'");
            queryString += (",'" + creationFormInput.getMailingList() + "'");
            queryString += (",'" + creationFormInput.getSex() + "'");
            queryString += (",'" + creationFormInput.getComment() + "'");
            queryString += (",'0'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery
    
    
    
    // ********************************************************
    //                    Create user 
    // ********************************************************
    
    
    
    public int createUserOfficial (DADUserForm creationFormInput){
        int error = 0;
        
        String userid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
           // String occupation = creationFormInput.getOccupation();
           // String workinggroup = "";
            
            System.out.println("Method Evoquée ??????");
             
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" USERS ( ");
            queryString += ("USERID,USERNAME,PASSWORD,FIRSTNAME,LASTNAME,EMAIL,INSTITUTION,SALUTATION,ISOFFICIALMEMBER");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "'");
            queryString += (",'" + creationFormInput.getLogin() + "'");
            queryString += (",'" + creationFormInput.getPassword() + "'");
            queryString += (",'" + creationFormInput.getFirstName() + "'");
            queryString += (",'" + creationFormInput.getLastName() + "'");
            queryString += (",'" + creationFormInput.getEmail() + "'");
            queryString += (",'" + creationFormInput.getInstitution() + "'");
            queryString += (",'" + creationFormInput.getSalutation() + "'");
            
            queryString += (",'1'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery
    
    
    
     // ********************************************************
    //                    Create password + login
    // ********************************************************
    
    
    
    public int createUserLoginPassword(DADUserForm creationFormInput,String prenom,String nom) {
        int error = 0;
        
        String userid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        
        creationFormInput.setLastName(nom);
        creationFormInput.setFirstName(nom);
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" USERS ( ");
            queryString += ("USERNAME,PASSWORD,");
            queryString += ("ISOFFICIALMEMBER");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + creationFormInput.getLogin() + "'");
            queryString += (",'" + creationFormInput.getPassword() + "'");
            queryString += (",'1'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery

    
    
    // ********************************************************
    //                    Create password + login
    // ********************************************************
    
    
    
       public int createUserLoginPassword(DADUserForm creationFormInput,String prenom,String nom,String email,String userid, HttpServletResponse res) {
        int error = 0;
        
        creationFormInput.setPassword(null);
        creationFormInput.setLastName(nom);
        creationFormInput.setFirstName(prenom);
        creationFormInput.setEmail(email);
        try {
            String username = creationFormInput.getLogin();
            String password = creationFormInput.getPassword();
            
            // Create and Execute a query
            String queryString = ("UPDATE");
            queryString += (" USERS SET ");
            queryString += ("USERNAME = '"+ username + "',");
            queryString += ("PASSWORD = '"+ password + "'");
            queryString += (" where USERID='");
            queryString += userid;
            queryString += ("';");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
            
            DADSendMail mail = new DADSendMail();
            String usermail=  creationFormInput.getEmail();
            String from = "aabd@ecn.ulaval.ca";
            String subject = "DAD 4.3 : New Version / Nouvelle version";
            String message = ("Bonjour, \n\n");
            message += ("Une nouvelle version du logiciel DAD est maintenant disponible. Vous pouvez maintenant vous connecter en utilisant les informations suivantes:\n");
            message += ("Nom de l'utilisateur= ");
            message += username.toLowerCase();
            message += ("\nMot de passe= ");
            message += password.toLowerCase();
            message += ("\n\n");
            message += ("Merci.\n\n");
            
            message += ("Hello, \n\n");
            message += ("A new version of DAD software is now available on our web site. You can now access the intranet facilities using the following information:\n");
            message += ("Username= ");
            message += username.toLowerCase();
            message += ("\nPassword= ");
            message += password.toLowerCase();
            message += ("\n\n");
            message += ("Thanks.");
            
            
            try {
                
                mail.sendMessage(message, subject, usermail, from );
                //out.println("Thank ! Your PEP Informations has been send to your E-Mail Account\n");
                
            }
            catch(Exception e) {
               // out.println(e.toString());
                //    System.out.println(e.toString());
            }// end catch
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery

    
      // ********************************************************
    //                    Create password + login
    // ********************************************************
    
    
    
    public int createUserLoginPassword(DADUserForm creationFormInput,String prenom,String nom,String userid) {
        int error = 0;
        
        
        creationFormInput.setLastName(nom);
        creationFormInput.setFirstName(prenom);
        try {
            creationFormInput.setPassword(null);
            // Create and Execute a query
            String queryString = ("UPDATE");
            queryString += (" USERS SET ");
            queryString += ("USERNAME = '"+ creationFormInput.getLogin() + "',");
            queryString += ("PASSWORD = '"+ creationFormInput.getPassword() + "'");
            queryString += (" where USERID='");
            queryString += userid;
            queryString += ("';");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
            error = 1;
            
            e.printStackTrace();
            
        }
        
        Integer integertmp = new Integer(userid);
        
        return (integertmp.intValue());
    } // end of executeQuery
    
    // ********************************************************
    //            Get users based on attribute
    // ********************************************************
    
    
    
    public  ResultSet queryUser(String attribut,String value) {
        try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where ");
            queryString += (attribut);
            queryString += (" like '%");
            queryString += (value);
            queryString += ("%' order by LASTNAME;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            //this.setResultSet(rs);
            
        }
        
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
     public  ResultSet queryUserO(String attribut,String value, String order) {
      try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where ");
            queryString += (attribut);
            queryString += (" like '%");
            queryString += (value);
            queryString += ("%' order by SDATE;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            //this.setResultSet(rs);
            
        }
        
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
    
    
      // ********************************************************
    //            Get users based on attribute
    // ********************************************************
    
    
    
    public  ResultSet queryUser(String [] statuscirpee,String bool, String [] institution) {
        try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where ( ");
            if (statuscirpee != null)
            {
                for (int i=0; i< statuscirpee.length ; i++)
                    queryString += ("STATUSCIRPEE = '"+statuscirpee[i]+"' OR ");
                queryString += ("STATUSCIRPEE = ' ') ");
            }
             
            if (institution != null)
            {
                if (statuscirpee != null)
                    {
                    queryString += (bool);
                    queryString += (" (");
                    }
                for (int i=0; i< institution.length ; i++)
                    queryString += ("INSTITUTION = '"+institution[i]+"' OR ");
                queryString += ("INSTITUTION = ' ')  ");
            }
             
            queryString += (" order by LASTNAME;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            this.setResultSet(rs);
            
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
    
     // ********************************************************
    //            Get users based on attribute
    // ********************************************************
    
    
   
     
    public  ResultSet queryUser(String firstname,String lastname,String email) {
        try {
            DADDBConnection connection = new DADDBConnection();
            connection.ConnectDB();
            
            String queryString = ("SELECT * ");
            queryString += ("FROM USERS where ");
            queryString += ("FIRSTNAME = '");
            queryString += (firstname);
            queryString += ("' AND LASTNAME = '");
            queryString += (lastname);
            queryString += ("' AND EMAIL = '");
            queryString += (email);
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
           
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
    
      public  ResultSet queryUserFromMail(String email) {
        try {
            DADDBConnection connection = new DADDBConnection();
            connection.ConnectDB();
            
            String queryString = ("SELECT * ");
            queryString += ("FROM USERS where ");
            queryString += ("EMAIL = '");
            queryString += (email);
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
           
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
      
      
     public  ResultSet queryUserInPEP(String firstname,String lastname,String email) {
        try {
            DADDBConnection connection = new DADDBConnection();
            connection.ConnectDB();
            
            String queryString = ("SELECT * ");
            queryString += ("FROM USERS where ");
            queryString += ("FIRSTNAME = '");
            queryString += (firstname);
            queryString += ("' AND LASTNAME = '");
            queryString += (lastname);
            queryString += ("' AND (EMAIL = '");
            queryString += (email);
            queryString += ("' OR EMAIL2='");
            queryString += (email);
            queryString += ("');");
            Statement stmt = DADDBConnection.conPEP.createStatement();
            rs = stmt.executeQuery(queryString);
           
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
     
    
     public  ResultSet queryUser2(String attribut,String value) {
        try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where ");
            queryString += (attribut);
            queryString += (" = '");
            queryString += (value);
            queryString += ("'  order by LASTNAME;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
          //  this.setResultSet(rs);
            
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
     
          public  ResultSet queryUserInPEP2(String attribut,String value) {
        try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where ");
            queryString += (attribut);
            queryString += (" = '");
            queryString += (value);
            queryString += ("'  order by LASTNAME;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.conPEP.createStatement();
            rs = stmt.executeQuery(queryString);
          //  this.setResultSet(rs);
            
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
          
    
       public  ResultSet queryUser3(String attribut,String value) {
        try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where ");
            queryString += (attribut);
            queryString += (" = '");
            queryString += (value);
            queryString += ("' order by LASTNAME;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            this.setResultSet(rs);
            
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
     
     public  ResultSet queryAllNewUsers() {
        try {
            
            String queryString = ("SELECT * ");
            queryString += ("FROM USERS where ISOFFICIALMEMBER='0' order by LASTNAME;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
           // this.setResultSet(rs);
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
      public  ResultSet queryNom(String prenom,String nom) {
        try {
            
            String queryString = ("SELECT DISTINCT * ");
            queryString += (" FROM USERS where firstname='");
            queryString += (prenom);
            queryString += ("' and lastname= '"); 
            queryString += (nom);
            queryString += ("';");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        //    this.setResultSet(rs);
            
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
     

    // ********************************************************
    //                 Get All Users 
    // ********************************************************
    
    
    public  ResultSet queryAllUser() {
        try {
            
            String queryString = ("SELECT * ");
            queryString += ("FROM USERS order by CREATIONDATE;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            this.setResultSet(rs);
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
    
     // ********************************************************
    //                 Get All Users 
    // ********************************************************
    
    
    public  ResultSet queryAllUser2() {
        try {
            
            String queryString = ("SELECT * ");
            queryString += ("FROM USERS;");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
             this.setResultSet(rs);
        }
        
        catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return (rs);
    } // end of executeQuery
    
     public int updateTimestamp(String userid) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS SET ");
            queryString += ("CREATIONDATE = now() where userid='");
            queryString += userid;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int updateUser(String userid,DADUserForm creationFormInput) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS SET ");
            queryString += ("SALUTATION = '" + creationFormInput.getSalutation() + "',");
            queryString += ("FIRSTNAME = '" + creationFormInput.getFirstName() + "',");
            queryString += ("LASTNAME = '" + creationFormInput.getLastName() + "',");
            queryString += ("EMAIL = '" + creationFormInput.getEmail() + "',");          
            queryString += ("INSTITUTION = '" + creationFormInput.getInstitution() + "',");
            queryString += ("ADDRESS = '" + creationFormInput.getAddress() + "',");
            queryString += ("CITY = '" + creationFormInput.getCity() + "',");
            queryString += ("STATE = '" + creationFormInput.getState() + "',");
            queryString += ("POSTALCODE = '" + creationFormInput.getZip() + "',");
            queryString += ("COUNTRY = '" + creationFormInput.getCountry() + "',");
            queryString += ("ORDERCD = 'YES',");
            queryString += ("PHONE = '" + creationFormInput.getPhone() + "' ");
            queryString += ("WHERE (( ");
            queryString += ("USERID = '" + userid + "' ");
            queryString += (")) ;");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
    
     // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int updateUserPassword(String userid,DADUserForm creationFormInput) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS ");
            queryString += (" SET ");
            if (creationFormInput.getPassword2() != null)
            queryString += ("PASSWORD = '" + creationFormInput.getPassword2() + "' ");
            queryString += ("WHERE (( ");
            queryString += ("USERID = '" + userid + "' ");
            queryString += (")) ;");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
    
     public int DeleteUser(String userid) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("DELETE FROM USERS WHERE ");
            queryString += ("USERID = '" + userid + "' ");
            queryString += (";");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
     // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int updateUser(String userid, String attname,String attvalue) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS ");
            queryString += (" SET ");
            queryString += attname;
            queryString += ("='");
            queryString += attvalue;
            queryString += ("' where USERID ='");
            queryString += userid;
            queryString += ("';");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
     
     // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int confirmSendCD(String date, String confnumber,String userid) {
        
        int error=0;
        try {
            System.out.println("USERID="+userid);
            // Create and Execute a query
            String queryString = ("UPDATE USERS ");
            queryString += (" SET SDATE='");
            queryString += date;
            queryString += ("', SCONF='");
            queryString += confnumber;
            queryString += ("' where USERID='");
            queryString += userid;
            queryString += ("';");
             System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
    
     // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int changeUserRoleFromProject(String userid, String projid,String isadmin) {
         ResultSet rs1=null;
        int error=0;
        try {
        // Create and Execute a query
            String queryString1 = ("SELECT * FROM PROJECTMEMBERS ");
            queryString1 += (" where PROJID ='");
            queryString1 += projid;
            queryString1 += ("' and ISADMIN='");
            queryString1 += isadmin;
            queryString1 += ("';");
            System.out.println(queryString1);
            
            Statement stmt1 = DADDBConnection.con.createStatement();
            rs1 = stmt1.executeQuery(queryString1);
           }
        catch (Exception e) {
        }
        try{
        if (rs1.next())
        {
            
            try {
            // Create and Execute a query
            String queryString = ("UPDATE PROJECTMEMBERS ");
            queryString += (" SET USERID='");
            queryString += userid;
            queryString += ("' where PROJID ='");
            queryString += projid;
            queryString += ("' and ISADMIN='");
            queryString += isadmin;
            queryString += ("';");
            System.out.println(queryString);
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            }
            catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
            }
        
        }
            
        else
        {
         try {
            
            // Create and Execute a query
            String queryString2 = ("INSERT INTO PROJECTMEMBERS (USERID,PROJID,ISADMIN) VALUES ('");
            queryString2 += userid;
            queryString2 += ("','");
            queryString2 += projid;
            queryString2 += ("','");
            queryString2 += isadmin;
            queryString2 += ("');");
            System.out.println(queryString2);
            
            Statement stmt2 = DADDBConnection.con.createStatement();
            rs = stmt2.executeQuery(queryString2);
            }
            catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
            }
        }
        }
        catch(Exception e){}
            
            
        return error;
    }
    
    
    
      // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int approveUser(String userid) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS ");
            queryString += (" SET ISOFFICIALMEMBER");
            queryString += ("='1' " );
            queryString += ("where USERID ='");
            queryString += userid;
            queryString += ("';");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
    
      // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int approveUser(String userid,String cirpeestatus) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS ");
            queryString += (" SET ISOFFICIALMEMBER");
            queryString += ("='1', STATUSCIRPEE=' ");
            queryString += cirpeestatus;
            queryString += ("' where USERID ='");
            queryString += userid;
            queryString += ("';");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            
            
            
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
        // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int approveUser(String userid,String cirpeestatus,String departement) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS ");
            queryString += (" SET ISOFFICIALMEMBER");
            queryString += ("='1', STATUSCIRPEE='");
            queryString += cirpeestatus;
            queryString += ("', DEPARTEMENT='");
            queryString += departement;
            queryString += ("' where USERID ='");
            queryString += userid;
            queryString += ("';");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            
            
            
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
      // ********************************************************
    //                 Update Specific User  
    // ********************************************************
    
    
    
    public int deleteUser(String userid) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("DELETE FROM USERS ");
            queryString += ("where USERID ='");
            queryString += userid;
            queryString += ("';");
            
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
    
    // ********************************************************
    //           Get Project Associate to the user  
    // ********************************************************
    
    
    public ResultSet getUserProject(String userid,String projecttype) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT DISTINCT PROJECTS.PROJID, ");
            queryString += (" PROJECTS.NAME, PROJECTS.TITLE,");
            queryString += (" PROJECTS.DESCRIPTION, PROJECTS.STARTINGDATE,");
            queryString += (" PROJECTS.PERIOD");
            queryString += (" FROM PROJECTS,PROJECTMEMBERS where ");
            queryString += ("PROJECTMEMBERS.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("PROJECTS.PROJECTTYPE" + " = '");
            queryString += projecttype;
            queryString += ("' AND ");
            queryString += ("PROJECTMEMBERS.PROJID = PROJECTS.PROJID");
            queryString += (";");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    
     // ********************************************************
    //           Get Project Associate to the user  
    // ********************************************************
    
    
    public ResultSet isUserMemberOfThisAxe(String axe,String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM USERS WHERE ");
            queryString += ("AXE LIKE '%");
            queryString += axe;
            queryString += ("%' and USERID = '");
            queryString += userid;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
            
            System.out.println(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    
      // ********************************************************
    //           Get Proposal
    // ********************************************************
    
    
    
     public ResultSet getUserProposal(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT DISTINCT PROPOSALS.PROPID,PROPOSALS.CODE,PROPOSALUSER.ROLE, ");
            queryString += (" PROPOSALS.NAME,");
            queryString += (" PROPOSALS.DESCRIPTION ");
            queryString += (" FROM PROPOSALS,PROPOSALUSER where ");
            queryString += ("PROPOSALUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("PROPOSALUSER.PROPID = PROPOSALS.PROPID");
            queryString += (" order by code;");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
      
      // ********************************************************
    //           Get Publication
    // ********************************************************
    
    
    
     public ResultSet getUserPublication(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM PUBLICATION,PUBLICATIONUSER where ");
            queryString += ("PUBLICATIONUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("PUBLICATIONUSER.PUBID = PUBLICATION.PUBID");
            queryString += (";");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
        // ********************************************************
    //           Get Publication
    // ********************************************************
    
    
    
     public ResultSet getUserPublication(String userid,String type) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM PUBLICATION,PUBLICATIONUSER where ");
            queryString += ("PUBLICATIONUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("PUBLICATIONUSER.PUBID = PUBLICATION.PUBID AND PUBLICATION.TYPE='");
            queryString += type;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    // ********************************************************
    //           Get Publication
    // ********************************************************
    
    
    
     public ResultSet getUserPublication(String userid,String type,String status) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM PUBLICATION,PUBLICATIONUSER where ");
            queryString += ("PUBLICATIONUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("PUBLICATIONUSER.PUBID = PUBLICATION.PUBID AND PUBLICATION.TYPE='");
            queryString += type;
            queryString += ("' AND PUBLICATION.STATUS='");
            queryString += status;
             queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
     
   // ********************************************************
    //           Get Publication
    // ********************************************************
    
    
    
     public ResultSet getUserDirectionStudent(String userid,String niveau) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM DIRECTIONETUDIANT where ");
            queryString += ("SUPERVISORID = '");
            queryString += userid;           
            queryString += ("' AND NIVEAU='");
            queryString += niveau;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
     public ResultSet queryDirection(String dirid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM DIRECTIONETUDIANT where ");
            queryString += ("DIRID = '");
            queryString += dirid;           
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
     
      public ResultSet queryEtude(String etuid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM ETUDE where ");
            queryString += ("ETUID = '");
            queryString += etuid;           
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
      
      
       public ResultSet queryCommunication(String comid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM COMMUNICATION where ");
            queryString += ("COMID = '");
            queryString += comid;           
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
      
       
       public ResultSet queryRayonnement(String rayid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM RAYONNEMENT where ");
            queryString += ("RAYID = '");
            queryString += rayid;           
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
      
      public void updateEtude(String etuid,String programme,String titre,String description,String directeur,String codirecteur1,String codirecteur2,String organisme,String date)
     {
    int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE ETUDE SET ");
            queryString += ("PROGRAMME= '" + programme + "',");
            queryString += ("TITRE = '" + titre + "',");
            queryString += ("DESCRIPTION = '" + description + "',");
            queryString += ("DIRECTEUR = '" + directeur + "',");
            queryString += ("CODIRECTEUR1 = '" + codirecteur1 + "',");
            queryString += ("CODIRECTEUR2 = '" + codirecteur2 + "',");
            queryString += ("ORGANISME = '" + organisme + "' ,");
            queryString += ("DATE = '" + date + "' ");
            queryString += ("WHERE (( ");
            queryString += ("ETUID = '" + etuid + "' ");
            queryString += (")) ;");
             System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        
    }  
    
     public void updateDirection(String dirid,String nom,String direction,String niveau,String etat,String titre,String description,String annee)
     {
    int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE DIRECTIONETUDIANT SET ");
            queryString += ("NOM = '" + nom + "',");
            queryString += ("DIRECTION = '" + direction + "',");
            queryString += ("NIVEAU = '" + niveau + "',");
            queryString += ("ETAT = '" + etat + "',");
            queryString += ("TITRE = '" + titre + "',");
            queryString += ("DESCRIPTION = '" + description + "',");
            queryString += ("ANNEE = '" + annee + "' ");
            queryString += ("WHERE (( ");
            queryString += ("DIRID = '" + dirid + "' ");
            queryString += (")) ;");
             System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        
    }
     
     
     
     
     
     public ResultSet getUserSubvention(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM SUBVENTION,SUBVENTIONUSER where ");
            queryString += ("SUBVENTIONUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("SUBVENTIONUSER.SUBID = SUBVENTION.SUBID ");
             queryString += (";");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
     
     public ResultSet getUserEtude(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM ETUDE,ETUDEUSER where ");
            queryString += ("ETUDEUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("ETUDEUSER.ETUID = ETUDE.ETUID ");
             queryString += (";");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
     
     
      public ResultSet getUserCommunication(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM COMMUNICATION where ");
            queryString += ("SUPERVISORID" + " = '");
            queryString += userid;
             queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
     
      public ResultSet getUserRayonnement(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT * ");
            queryString += (" FROM RAYONNEMENT where ");
            queryString += ("SUPERVISORID" + " = '");
            queryString += userid;
             queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
      
      
      
       public void createDirectionEtudiant(String name,String direction,String niveau,String etat ,String titre,String description,String annee,String supervisorid)
       {
   
        
     String dirid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" DIRECTIONETUDIANT ( ");
            queryString += ("DIRID,NOM,DIRECTION,NIVEAU,ETAT,TITRE,DESCRIPTION,ANNEE,SUPERVISORID");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" +dirid+ "'"); 
            queryString += (",'" + name + "'");
            queryString += (",'" + direction + "'");
            queryString += (",'" + niveau + "'");
            queryString += (",'" + etat + "'");
            queryString += (",'" + titre + "'");
            queryString += (",'" + description + "'");
            queryString += (",'" + annee + "'");
            queryString += (",'" + supervisorid + "'");
            queryString += (");");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        

    } // end of executeQuery
    
    
       public void createCommunication(String classification,String titre,String auteur,String description,String endroit,String date,String supervisorid)
       {
   
        
       String comid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" COMMUNICATION ( ");
            queryString += ("COMID,CLASSIFICATION,TITRE,AUTEUR,DESCRIPTION,ENDROIT,DATE,SUPERVISORID");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" +comid+ "'"); 
            queryString += (",'" + classification + "'");
            queryString += (",'" + titre + "'");
            queryString += (",'" + auteur + "'");
            queryString += (",'" + description + "'");
            queryString += (",'" + endroit + "'");
            queryString += (",'" + date + "'");
            queryString += (",'" + supervisorid + "'");
            queryString += (");");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        

    } // end of executeQuery
       
        public void createRayonnement(String description,String date,String supervisorid)
       {
   
        
       String rayid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" RAYONNEMENT ( ");
            queryString += ("RAYID,DESCRIPTION,DATE,SUPERVISORID");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" +rayid+ "'"); 
            queryString += (",'" + description + "'");
            queryString += (",'" + date + "'");
            queryString += (",'" + supervisorid + "'");
            queryString += (");");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        

    } // end of executeQuery
        
      public void updateRayonnement(String rayid,String description)
     {
    int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE RAYONNEMENT SET ");
            queryString += ("DESCRIPTION = '" + description + "' ");
            queryString += ("WHERE (( ");
            queryString += ("RAYID = '" + rayid + "' ");
            queryString += (")) ;");
             System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        
    }
      public void updateCommunication(String comid,String titre,String auteur,String description,String endroit,String date)
     {
    int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE COMMUNICATION SET ");
            queryString += ("TITRE = '" + titre + "', ");
            queryString += ("AUTEUR = '" + auteur + "', ");
            queryString += ("DESCRIPTION = '" + description + "', ");
            queryString += ("ENDROIT = '" + endroit + "', ");
            queryString += ("DATE = '" + date + "' ");
            queryString += ("WHERE (( ");
            queryString += ("COMID = '" + comid + "' ");
            queryString += (")) ;");
             System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        
    }
     
     
         public void deleteDirectionEtudiant(String dirid)
       {
   
        
        try {
            
            // Create and Execute a query
            String queryString = ("DELETE FROM ");
            queryString += ("DIRECTIONETUDIANT  ");
            queryString += ("WHERE DIRID='");
            queryString += dirid;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
         }
        
    public void deleteEtude(String etuid)
       {

        try {
            
            // Create and Execute a query
            String queryString = ("DELETE FROM ");
            queryString += ("ETUDE  ");
            queryString += ("WHERE ETUID='");
            queryString += etuid;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        
    } // end of executeQuery
    
    
     public void deleteRayonnement(String rayid)
       {

        try {
            
            // Create and Execute a query
            String queryString = ("DELETE FROM ");
            queryString += ("RAYONNEMENT  ");
            queryString += ("WHERE RAYID='");
            queryString += rayid;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        
    } // end of executeQuery
     
      public void deleteCommunication(String comid)
       {

        try {
            
            // Create and Execute a query
            String queryString = ("DELETE FROM ");
            queryString += ("COMMUNICATION  ");
            queryString += ("WHERE COMID='");
            queryString += comid;
            queryString += ("';");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        
    } // end of executeQuery
    
      public int createEtude(String programme,String titre,String description,String directeur ,String codirecteur1,String codirecteur2,String organisme,String date)
       {
   
        
     String etuid = Math.abs(Math.round(Math.random() * 1000000000)) + "";
        try {
            
            // Create and Execute a query
            String queryString = ("INSERT INTO ");
            queryString += (" ETUDE ( ");
            queryString += ("ETUID,PROGRAMME,TITRE,DESCRIPTION,DIRECTEUR,CODIRECTEUR1,CODIRECTEUR2,ORGANISME,DATE");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" +etuid+ "'"); 
            queryString += (",'" + programme + "'");
            queryString += (",'" + titre + "'");
            queryString += (",'" + description + "'");
            queryString += (",'" + directeur + "'");
            queryString += (",'" + codirecteur1 + "'");
            queryString += (",'" + codirecteur2 + "'");
            queryString += (",'" + organisme + "'");
            queryString += (",'" + date + "'");
            queryString += (");");
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
            
        }
        catch(Exception e) {
    
            
            e.printStackTrace();
            
        }
        
       Integer integertmp = new Integer(etuid);
        
        return (integertmp.intValue());
    } // end of executeQuery
       
     
      
       public ResultSet AssociateEtudeToUser(String userid,int etuid) {
        try {
           
            String queryString = ("INSERT INTO ");
            queryString += (" ETUDEUSER ( ");
            queryString += ("USERID,ETUID");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "',");
            queryString += ("'" + etuid + "'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    
       
       public ResultSet getUserMemo(String userid) {
        try {
            
            // Create and Execute a query
            String queryString = ("SELECT DISTINCT MEMOS.MEMOID,MEMOS.SUBJECT,MEMOS.TEXT,MEMOS.ATTACHID,");
            queryString += ("MEMOS.CREATORID,");
            queryString += ("MEMOS.CREATIONDATE ");
            queryString += (" FROM MEMOS,MEMOUSER where ");
            queryString += ("MEMOUSER.USERID" + " = '");
            queryString += userid;
            queryString += ("' AND ");
            queryString += ("MEMOUSER.MEMOID = MEMOS.MEMOID");
            queryString += (";");
            Statement stmt = DADDBConnection.con.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
       
    // ********************************************************
    //           Get Project Associate to the user  
    // ********************************************************
    
    
    public ResultSet AssociateUserToProject(String userid,String projid,String isadmin) {
        try {
            String sort ="0";
            if (isadmin.compareTo("ADMIN")==0)
                sort = "1";
            else if(isadmin.compareTo("SUPERVISOR")==0)
                sort = "4";
            else if(isadmin.compareTo("LEADER")==0)
                sort = "2";
            else if(isadmin.compareTo("RESEARCHER")==0)
                sort = "3";
            else if(isadmin.compareTo("RESSOURCE")==0)
                sort = "5";
            else if(isadmin.compareTo("OTHER")==0)
                sort = "6";
            String queryString = ("INSERT INTO ");
            queryString += (" PROJECTMEMBERS ( ");
            queryString += ("USERID,PROJID,ISADMIN,SORT");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "',");
            queryString += ("'" + projid + "',");
            queryString += ("'" + isadmin + "',");
            queryString += ("'" + sort + "'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
     // ********************************************************
    //           Get Project Associate to the user  
    // ********************************************************
    
    
    public ResultSet AssociateUserToProject(String userid,String projid,String isadmin,String droit) {
        try {
            String sort ="0";
            if (isadmin.compareTo("ADMIN")==0)
                sort = "1";
            else if(isadmin.compareTo("MEMBRE")==0)
                sort = "4";
            else if(isadmin.compareTo("COLLABORATEUR")==0)
                sort = "2";
            else if(isadmin.compareTo("OTHER")==0)
                sort = "6";
            String queryString = ("INSERT INTO ");
            queryString += (" PROJECTMEMBERS ( ");
            queryString += ("USERID,PROJID,ISADMIN,SORT,DROIT");
            queryString += (")");
            queryString += (" VALUES (");
            queryString += ("'" + userid + "',");
            queryString += ("'" + projid + "',");
            queryString += ("'" + isadmin + "',");
            queryString += ("'" + sort + "',");
            queryString += ("'" + droit + "'");
            queryString += (");");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    
    
     // ********************************************************
    //           Get Project Associate to the user  
    // ********************************************************
    
    
    public ResultSet ChangeUserStatusInProject(String userid,String projid,String isadmin,String droit) {
        try {
          
            String queryString = ("UPDATE ");
            queryString += (" PROJECTMEMBERS SET ");
            queryString += ("DROIT=");

          
            queryString += ("'" + droit + "'");
            queryString += (" where USERID= '" + userid + "' and ");
            queryString += ("PROJID= '" + projid + "' ");
            queryString += (";");
            System.out.println(queryString);
            Statement stmt = DADDBConnection.con.createStatement();
            stmt.executeQuery(queryString);
            
        }
        catch(SQLException sqle) {
            System.err.println(sqle.getMessage());
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
        
        return rs; // the ResultSet is sent back to the JSP page context.
    } // end of executeQuery
    
    
    
    
    
    public String getUserName() {
        return userName;
    }
    
    
    public void setUserName(String sz) {
        userName = sz;
    }
    
    
    
    public String getResult() {
        return result;
    }
    
    
    public void setResult(String sz) {
        result = sz;
    }
    
    
    public String getString(String str) {
        return (str);
    }
    
    
    public void setResultSet(ResultSet result) {
        resultset = result;
    }
    
    
    public ResultSet getResultSet() {
        return (resultset);
    }
    
     public int updateTimestampLastMod(String userid) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS SET ");
            queryString += ("MODIFICATIONDATE = now() where userid='");
            queryString += userid;
            queryString += ("';");
            Statement stmt = DADDBConnection.conPEP.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
     

      public int updateTimestampCreateUser(String userid) {
        
        int error=0;
        try {
            
            // Create and Execute a query
            String queryString = ("UPDATE USERS SET ");
            queryString += ("CREATIONDATE = now() where userid='");
            queryString += userid;
            queryString += ("';");
            Statement stmt = DADDBConnection.conPEP.createStatement();
            rs = stmt.executeQuery(queryString);
        }
        catch (Exception e) {
            error=1;
            e.printStackTrace();
            System.err.println(e.getMessage());
        }
        return error;
    }
     

      
}
