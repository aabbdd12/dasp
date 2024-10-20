<%@ page import="java.sql.* ,java.util.*, Mimap.DADUser " %> 
<jsp:useBean id="user"  class="Mimap.DADUser" />


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>DAD</title>
</head>

<body>

   
  <table width="580">
    <tr>
      <td valign="top" width="580" height="19">
        <table border="0" style="border-collapse: collapse" bordercolor="#111111" cellpadding="0" cellspacing="0" width="632" height="19">
          <tr>
            <td width="580" colspan="3" valign="top" height="13" bgcolor="#E4E9FF"><b><font size="2" face="Tahoma">New
              User(s)</font><span style="font-family: Tahoma"><font size="2"> To 
            Validate</font></span></b><font color="#000080"><span style="font-family: Tahoma"><font size="2">&nbsp;&nbsp;</font></span></font></td>
          </tr>
</table>


 <table width="580" >
      <tr>
        <td valign="top" width="775" height="21">
          <p align="left">&nbsp;</p>
        </td>
      </tr>
      <tr>
        <td valign="top" width="775" height="21">
          <p align="left">&nbsp;<a href="ECNAdminCreateUser.jsp">Create
          New User</a></p>
        </td>
      </tr>
      <tr>
        <td valign="top" width="775" height="21">&nbsp;</td>
      </tr>
    </table>
<table width="580">
          <tr>
            <td rowspan="30" height="66" width="31"><img border="0" src="../images/cale10.gif" width="10" height="2"></td>
            <td width="597" colspan="3" valign="top" height="18" bgcolor="#FFFFFF">
              <p class="txt1" align="left"><font color="#000080"><span style="font-family: Tahoma"><font size="2">&nbsp;</font></span></font><p class="txt1" align="left">
              <font color="#FF0000"><b>
              <span style="font-family: Tahoma; font-style:italic"><font size="2">
              * To validate user, click on his username and validate the 
              corresponding information</font></span></b></font><p class="txt1" align="left">
              <font size="2" color="#FF0000"><b>
              <span style="font-family: Tahoma; font-style: italic">&nbsp;</span></b></font></td>
          </tr>
          <%
          ResultSet rs2;

                        rs2 = user.queryAllNewUsers( ); 
                        int count2 =0;
                        String creationdate;
        	 
                        while (rs2.next())
                        {
                        
                        
                        String username = rs2.getString("USERNAME");
                        String firstname = rs2.getString("FIRSTNAME");
                        String lastname = rs2.getString("LASTNAME");
                        String userid = rs2.getString("USERID");

                                               %>
          <tr>
            
            <td valign="top" height="32" width="103"><a href="ECNAdminUserInfo.jsp?userid=<%= userid %>"><%=username%></a></td>
            <td valign="top" height="32" width="272"><%=firstname%> <%=lastname%></td>
          </tr>
          <%}%>
        </table>
        
        </form>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
      </td>
    </tr>
  </table>



</body>