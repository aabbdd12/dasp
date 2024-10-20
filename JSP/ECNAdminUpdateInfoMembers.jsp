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
<p><font size="2" color="#0000FF"><b><span style="font-family: Tahoma">Members Registred</span></b></font></p>
<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="width: 850; border-collapse: collapse; background: #CCCCFF" height="1" cols="3">
  <tr style="height: 15.0pt">
    <td style="width: 47; height: 21; border: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#FFFFDD">
    <p class="MsoNormal" align="left">
    <span style="font-family: Verdana; color: #6699FF; font-weight: 850">
    <font style="font-size: 8pt">&nbsp;</font></span><b><span style="font-family: Verdana"><font style="font-size: 8pt"> # </font></span></b></td>
     <td style="width: 134; height: 21; border: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal">
    <span style="font-family: Verdana; color: #6699FF; font-weight: 8500">
    <font style="font-size: 8pt">&nbsp;</font></span><b><span style="font-family: Verdana"><font style="font-size: 8pt">Lastname,Firstname</font></span></b></td>
    <td style="width: 100; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF" height="21">
    <p class="MsoNormal"><b><span style="font-family: Verdana">
    <font style="font-size: 8pt">
    Email</font></span></b></td>
    <td style="width: 80; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF" height="21">
    <font style="font-size: 8pt"><b><span style="font-family: Verdana">Username</span></b></font></td>
    <td style="width: 50; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF" height="21">
    <font style="font-size: 8pt"><b><span style="font-family: Verdana">password</span></b></font></td>
     <td style="width: 167; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="left" bgcolor="#66FFFF" height="21">
    <p align="center">
    <font style="font-size: 8pt">
    <span style="font-family: Verdana; font-weight:700">Country</span></font></td>
    <td style="width: 166; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font face="Verdana" style="font-size: 8pt">Creation Date</font></b></td>
    <td style="width: 46; height: 21; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Info   </font></b></td>
    <td style="width: 67; height: 21; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Delete</font></b></td>
  </tr>
<%
    String userid;
    String lastmod;
    String firstname;
    String lastname;
    String username;
    String password;
    String country;
    int i=0;
    ResultSet rs;
    rs= query.queryAllUser();

 while (rs.next())
        {
         userid= rs.getString("USERID");   
         lastmod = rs.getString("CREATIONDATE");
         firstname=rs.getString("FIRSTNAME");
         lastname=rs.getString("LASTNAME");
         username=rs.getString("USERNAME");
         password=rs.getString("PASSWORD");
         country=rs.getString("COUNTRY");
         i++;

        %>

  <tr style="height: 15.0pt">
   <td style="width: 1; height: 1; border: 1.0pt solid windowtext; padding: 0cm; background: #FFFFDD; ">
    <p class="MsoNormal"><b><span style="font-size: 8pt; font-family: Verdana">
    &nbsp;<%=i%></span></b></td>
    <td style="width: 235; height: 1; border: 1.0pt solid windowtext; padding: 0cm; background: #DFDFFF">
    <p class="MsoNormal"><b><span style="font-size: 8pt; font-family: Verdana">
    &nbsp;<%=lastname%>,<%=firstname%></span></b></td>
    <td style="width: 100; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFFFDD" height="1">
    <p class="MsoNormal" align="left"><font face="Verdana">
    <span style="font-size: 8pt; font-weight:700"><%=rs.getString("EMAIL")%></span></font></td>
    <td style="width: 80; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFD3B7; " height="1" align="center">
    <%=username%><font face="Verdana" style="font-size: 8pt; font-weight:700"> </font> </td>
    <td style="width: 50; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFD3B7; " height="1" align="center">
    <%=password%></td>
     <td style="width: 167; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFEDE1" height="1" align="left"><center><b>
    <%=country%></b></center></td>
    <td style="width: 166; height: 1; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC" align="center">
    <p class="MsoNormal"><b><font face="Verdana" style="font-size: 8pt"><center>&nbsp;<%=lastmod.substring(6,8)+"-"+lastmod.substring(4,6)+"-"+lastmod.substring(0,4)%></center></font></b></td>
    <td style="width: 46; height: 1; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFFFFF">
    <p class="MsoNormal" align="center">
    <form method="POST" action="ECNUserInfo.jsp?userid=<%=userid%>">  
    <p align="center">
    <input type="submit" value="Info" name="B3" style="font-size: 8pt; font-weight: bold; background-color: #00CCFF"></p>
    </td>
    </form>

    <td style="width: 67; height: 1; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFFFFF">
    <p class="MsoNormal" align="center"><b><font size="1" face="Tahoma">&nbsp;</font></b>
   
    <input type="button" value="Delete" onClick="askme(<%=userid%>)" name="B3" style="font-size: 8pt; color: #000000; font-weight: bold; background-color: #FF0000"></td>
   
    </tr>
  <%}%>
</table>

</body>

</html>