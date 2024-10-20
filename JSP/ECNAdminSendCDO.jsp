<%@ page import="java.sql.* , java.io.* ,java.util.* " %> 
<jsp:useBean id="query"  class="Mimap.DADUser"  />

<html>

<head>
<meta http-equiv="Content-Language" content="fr-ca">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>DAD</title>
<style>
<!--
p
	{margin-right:0cm;
	margin-left:0cm;
	font-size:12.0pt;
	font-family:"Times New Roman";
	}
 table.MsoNormalTable
	{mso-style-parent:"";
	font-size:10.0pt;
	font-family:"Times New Roman"}
 p.MsoNormal
	{mso-style-parent:"";
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	margin-left:0cm; margin-right:0cm; margin-top:0cm}
-->



</style>
</head>

<body>
<script language="VBScript">
function vbconfirmbox(thismsg,thisstyle) 
    vbconfirmbox = MsgBox(thismsg,thisstyle)
End function
</script>
<script language="javascript">
function askme(useridvalue){
  result = vbconfirmbox('You really want to delete this user ?',32 + 4)
  if (result==6){
     window.location.href("ECNDeleteUser.jsp?userid="+useridvalue)
    
  }else{
       
  }
}
</script>
<p><font size="2" color="#0000FF"><b><span style="font-family: Tahoma">CD Requested</span></b></font></p>
<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="width: 613; border-collapse: collapse; background: #CCCCFF" height="39" cols="3">
  <tr style="height: 15.0pt">
    <td style="width: 141; height: 20; border: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal">
    <span style="font-family: Tahoma; color: #6699FF; font-weight: 700">
    <font size="1">&nbsp;</font></span><b><span style="font-family: Tahoma"><font size="1">Lastname,Firstname</font></span></b></td>
    <td style="width: 162; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF" height="20">
    <p class="MsoNormal"><b><span style="font-family: Tahoma"><font size="1">
    Address</font></span></b></td>
    <td style="width: 78; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">State   </font></b></td>
    <td style="width: 78; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Postal Code</font></b></td>
     <td style="width: 77; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">City</font></b></td>
    <td style="width: 77; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Country</font></b></td>
    <td style="width: 130; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Phone</font></b></td>
     <td style="width: 130; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Email</font></b></td>
    <td style="width: 61; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Delete</font></b></td>
  </tr>

<%
    String userid;
    String lastmod;
    String firstname;
    String lastname;
    ResultSet rs;
    rs= query.queryUser("ORDERCD","YES");

 while (rs.next())
        {
         userid= rs.getString("USERID");   
         lastmod = rs.getString("CREATIONDATE");
         firstname=rs.getString("FIRSTNAME");
         lastname=rs.getString("LASTNAME");
        %>

  <tr style="height: 15.0pt">
    <td style="width: 141; height: 20; border: 1.0pt solid windowtext; padding: 0cm; background: #DFDFFF">
    <p class="MsoNormal"><b><span style="font-size: 7.5pt; font-family: Tahoma">
    &nbsp;<%=lastname%>,<%=firstname%></span></b></td>
    
    <td style="width: 162; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFFFDD" height="20">
    <p class="MsoNormal"><b><span style="font-size: 7.5pt; font-family: Tahoma">
    &nbsp;&nbsp;<%=rs.getString("ADDRESS")%></span></b></td>
   
    
    <td style="width: 78; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("STATE")%></center></font></b></td>
    
    <td style="width: 78; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("POSTALCODE")%></center></font></b></td>
    
     <td style="width: 77; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("CITY")%></center></font></b></td>
    
     <td style="width: 77; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("COUNTRY")%></center></font></b></td>
    
    <td style="width: 130; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("PHONE")%></center></font></b></td>
    
     <td style="width: 130; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("EMAIL")%></center></font></b></td>

    
    <td style="width: 61; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFFFFF">
    <p class="MsoNormal" align="center">
   
    <input type="button" value="Delete" onClick="askme(<%=userid%>)" name="B3" style="font-size: 8pt; color: #000000; font-weight: bold; background-color: #FF0000"></td>
   
    </tr>
  <%}%>
</table>

</body>

</html>