/*
 * DADUserForm.java
 *
 * Created on August 27, 2002, 8:57 AM
 */

package Mimap;
import java.util.*;
import Mimap.DADUser;
import Mimap.DADDBConnection;
import Mimap.DADSendMail;
import java.sql.*;
/**
 *
 * @author  cfortin
 * @version
 */

public class DADUserForm {
    
    private String login = " ";
    private String password = null;
    private String password2 =null;
    private String salutation = " ";
    private String firstname = " ";
    private String lastname = " ";
    private String email = " ";
    private String institution = " ";
    private String address = " ";
    private String city = " ";
    private String state = " ";
    private String zip= " ";
    private String country= " ";
    private String phone= " ";
    private String fax=" ";
    private String comment=" ";
    private String maillist=" ";
    private String sex=" ";
    private String errormessage=" ";
   
  
    static Hashtable errors;
    
    
    public DADUserForm() {
        firstname=" ";
        lastname=" ";
        email=" ";
        login=" ";
        institution=" ";
        address=" ";
        city=" ";
        state=" ";
        zip=" ";
        country=" ";
        phone=" ";
        fax=" ";
        comment=" ";
        maillist=" ";
        sex=" ";
        
        errors = new Hashtable();
    }
    
    // On test pour que tout les champs soit OK
    
    
    public boolean validate() {
        boolean allOk=true;
        
        if (firstname.equals("")) {
            errormessage="Enter your firstname";
            firstname="";
            allOk=false;
        }
        
        if (lastname.equals("")) {
            errormessage="Enter your lastname";
            lastname="";
            allOk=false;
        }
        if (country.equals("--Select--")) {
            errormessage="Enter your country";
            lastname="";
            allOk=false;
        }
        if (email.equals("") || (email.indexOf('@') == -1) || (email.indexOf('.') == -1)) {
            errormessage="Enter a valid e-mail";
            email="";
            allOk=false;
        }

        return allOk;
    }
    
    // GET
    
    
    public boolean validateUsername() {
        
        boolean allOk=true;
        ResultSet result = null;
        
        DADDBConnection connection = new DADDBConnection();
        connection.ConnectDB();
        
        DADUser user = new DADUser();
        try {
            result = user.queryUser("USERNAME",login);
            
            if (result.next()) {
                System.out.println("Username NOT OK");
                allOk=false;
            }
            else {
                System.out.println("Username OK");
                allOk=true;
            }
        }
        catch(Exception e)
        {}
        
        
        return allOk;
    }
    
     public boolean validateUsernameinPEP() {
        
        boolean allOk=true;
        ResultSet result = null;
        
        
        DADUser user = new DADUser();
        try {
            result = user.queryUser("USERNAME",login);
            
            if (result.next()) {
                allOk=false;
            }
            else {
                allOk=true;
            }
        }
        catch(Exception e)
        {}
        
        
        return allOk;
    }
     
    
    public void associateUserToGeneralProjet(String userid) {
        
        DADUser user = new DADUser();
        try {
            user.AssociateUserToProject(userid,"1","0");
        }
        catch(Exception e)
        {}
        
    }
    
    
    
    public String getFirstName() {
        char[] tmp = new char[firstname.length()];
        tmp= firstname.toCharArray();
        tmp[0] = Character.toUpperCase(tmp[0]);
        String test = new String(tmp);
        return test;
        
    }
    
    public String getLastName() {
        char[] tmp = new char[lastname.length()];
        tmp= lastname.toCharArray();
        tmp[0] = Character.toUpperCase(tmp[0]);
        String test = new String(tmp);
        return test;
        
    }
    
    public String getEmail() {
        return email;
    }
    
     public String getErrorMessage() {
        return errormessage;
    }
     
     public String getSex() {
        return sex;
    }
    public String getLogin() {
       
        String tmp1 = null;
        String tmp2 = null;
        String tmm1 = getFirstName();
        String tmm2 =  getLastName();
        StringBuffer tm1 = new StringBuffer(tmm1.trim());
        StringBuffer tm2 = new StringBuffer(tmm2.trim());
        System.out.println("tm1 :"+tm1);
        System.out.println("tm2 :"+tm2);
              if (tm1.length() >=1) tmp1 = tm1.substring(0,1);
        else  if (tm1.length() ==0) tmp1  = "W";
        
              if (tm2.length() >=3)                      tmp2  = tm2.substring(0,3);
        else  if (tm2.length() > 0 && tm2.length() < 3 ) tmp2  = tm2.toString();
        else  if (tm2.length() == 0)                     tmp2  = "WWW";
         System.out.println("tmp1 :"+tmp1);
         System.out.println("tmp2 :"+tmp2);
        login = tmp1+tmp2;
        boolean isOK = validateUsername();
        if (isOK = false)
            login=login+2;
        return login;
    }
    
    public String getPassword() {
        if(password==null)
            password = randomString(8);
        return password;
    }
    
    
    public String getPassword2() 
    {
       
        return password2;
    }
    
    public String randomString(int nLength) {
    Random r = new Random();
    char[] aChars = new char[52];
              
    for (int i = 0; i < 52; i ++) {
         int nOffset = i < 26 ? 65 : 71;
         aChars[i] = (char)(i + nOffset);
    }
              
    StringBuffer strBuff = new StringBuffer(nLength);
              
    for (int i = 0; i < nLength; i++) {
         strBuff.append(aChars[r.nextInt(52)]);
    }
              
    return strBuff.toString();
    }

    
    public String getZip() {
        return zip;
    }
    
    public String getSalutation() {
     
        return salutation;
    }
    
    public String getInstitution(){
       
        return institution;
    }
   
    
   
    public String getAddress(){

        
        return address;
    }
    
    public String getCity(){
       
        return city;
    }
    
    public String getState(){
        
        return state;
    }
    
    public String getCountry(){
         if (country==null)
            country=" ";
        return country;
    }
    
    public String getPhone(){
         if (phone==null)
            phone=" ";
        return phone;
    }
    
  
    
    public String getComment(){
       
        return comment;
    }
     public String getMailingList(){
       
        return maillist;
    }

   
      
    // SET
    
    public void setMailingList(String tmp)
    {
        maillist =tmp;
    }
    public void setFirstName(String fname) {
        firstname =fname;
    }
    
    public void setLastName(String lname) {
        lastname =lname;
    }
    
    public void setEmail(String eml) {
        email=eml;
    }
    
    public void setLogin(String u) {
        login=u;
    }
    
    public void setSex(String u) {
        sex=u;
    }
     
    
    public void  setPassword(String p1) {
        password=p1;
    }
    
    public void  setPassword2(String p1) {
        password2=p1;
    }
    
    public void setSalutation(String tmp) {
        salutation=tmp;
    }
    
    public void setZip(String tmp) {
        zip=tmp;
    }
    
    public void setInstitution(String tmp){
        institution=tmp;
    }
    
  
    
    public void setAddress(String tmp){
        address=tmp;
    }
    
    public void setCity(String tmp){
        city=tmp;
    }
    
    public void setState(String tmp){
        state=tmp;
    }
    
    public void setCountry(String tmp){
        country=tmp;
    }
    
    public void setPhone(String tmp){
        phone=tmp;
    }
    
    public void setComment(String tmp){
        comment=tmp;
    }
    
  
    // Messages d'erreur
    
    static public String getErrorMsg(String s) {
        String errorMsg =(String)errors.get(s.trim());
        System.out.println(errorMsg);
        return (errorMsg == null) ? "":errorMsg;
    }
    
    
    public void setErrors(String key, String msg) {
        errors.put(key,msg);
    }
    
    
    // Ecriture dans la base si tout est OK
    
    
    public int writeIntoDB() {
        
        int userid=0;
        try {
            
            
            DADDBConnection connection = new DADDBConnection();
            connection.ConnectDB();
            
            DADUser user = new DADUser();
            userid = user.createUserOfficial(this);
            
            
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
        return userid;
    }
    
     public int writeIntoDB2() {
        
        int userid=0;
        try {
            
            
            DADDBConnection connection = new DADDBConnection();
            DADDBConnection connection2 = new DADDBConnection();
            connection.ConnectDB();
            connection2.ConnectDBPEP();
            
            DADUser user = new DADUser();
            userid = user.createUserNoneOfficial(this);
            
            ResultSet rs= user.queryUserInPEP(firstname,lastname,email);
            int isexist=0;
            while(rs.next())
            {
            isexist=1;
            System.out.println("ON NE CREE PAS DANS PEP");
            }
            if (isexist==0){
            String useridpep = user.createPEPUser(this);
           
            }
            
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
        return userid;
    }
     
    public void updateIntoDB(String userid) {
        try {
            
            int error=0;
            //DADDBConnection connection = new DADDBConnection();
            //connection.ConnectDB();
            
            DADUser user = new DADUser();
            error = user.updateUser(userid,this);
            
            
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
     public void updatePasswordIntoDB(String userid) {
        try {
            
            int error=0;
            //DADDBConnection connection = new DADDBConnection();
            //connection.ConnectDB();
            
            DADUser user = new DADUser();
            error = user.updateUserPassword(userid,this);
            
            
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
