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

<SCRIPT LANGUAGE="JavaScript"><!--
function update(userid)
{
    winwidth = 365; // width of the new window
     winheight = 200; // height of the new window
     winleft = (screen.width / 2) - (winwidth / 2); // center the window right to left
     wintop = (screen.height / 2) - (winheight / 2); // center the window top to bottom
     w= window.open("DADInfoSendCD.jsp?userid2="+userid,"STATUS",'top=' + wintop + ',left=' + winleft + ',height=' + winheight + ',width=' + winwidth);    
}

//--> </SCRIPT>
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
<table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" style="width: 974; border-collapse: collapse; background: #CCCCFF" height="27" cols="3">
  <tr style="height: 15.0pt">
    <td style="width: 114; height: 20; border: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal">
    <span style="font-family: Tahoma; color: #6699FF; font-weight: 700">
    <font size="1">&nbsp;</font></span><b><span style="font-family: Tahoma"><font size="1">Lastname,Firstname</font></span></b></td>
    <td style="width: 76; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF" height="20">
    <p class="MsoNormal"><b><span style="font-family: Tahoma"><font size="1">
    Address</font></span></b></td>
     <td style="width: 78; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">City</font></b></td>
    <td style="width: 48; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">State   </font></b></td>
    <td style="width: 62; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Postal Code</font></b></td>
    <td style="width: 47; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <p class="MsoNormal"><b><font size="1" face="Tahoma">Country</font></b></td>
    <td style="width: 119; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Phone</font></b></td>
     <td style="width: 136; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Email</font></b></td>
    <td style="width: 107; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Sending date</font></b></td>
    <td style="width: 109; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Confirmation Number</font></b></td>
    <td style="width: 66; height: 20; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm" align="center" bgcolor="#66FFFF">
    <b><font face="Tahoma" size="1">Update Info</font></b></td>


  </tr>

<%
    String userid;
    String lastmod;
    String firstname;
    String lastname;
    ResultSet rs;
    rs= query.queryUserO("ORDERCD","YES","ORDERCD");

 while (rs.next())
        {
         userid= rs.getString("USERID");   
         lastmod = rs.getString("SDATE");
         firstname=rs.getString("FIRSTNAME");
         lastname=rs.getString("LASTNAME");
        %>

  <tr style="height: 15.0pt">
    <td style="width: 114; height: 8; border: 1.0pt solid windowtext; padding: 0cm; background: #DFDFFF">
    <p class="MsoNormal"><b><span style="font-size: 7.5pt; font-family: Tahoma">
    &nbsp;<%=lastname%>,<%=firstname%></span></b></td>
    
    <td style="width: 76; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #FFFFDD" height="8">
    <p class="MsoNormal"><b><span style="font-size: 7.5pt; font-family: Tahoma">
    &nbsp;&nbsp;<%=rs.getString("ADDRESS")%></span></b></td>
    
     <td style="width: 78; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("CITY")%></center></font></b></td>
    
    <td style="width: 48; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("STATE")%></center></font></b></td>
    
    <td style="width: 62; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("POSTALCODE")%></center></font></b></td>
    
    
     <td style="width: 47; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("COUNTRY")%></center></font></b></td>
    
    <td style="width: 119; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("PHONE")%></center></font></b></td>
    
     <td style="width: 136; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("EMAIL")%></center></font></b></td>
    <td style="width: 120; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=lastmod.substring(6,8)+"-"+lastmod.substring(4,6)+"-"+lastmod.substring(0,4)%></center></font></b></td>
    <td style="width: 109; height: 8; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding: 0cm; background: #CCFFCC">
    <p class="MsoNormal"><b><font size="1" face="Tahoma"><center>&nbsp;<%=rs.getString("SCONF")%></center></font></b></td>
     <td bordercolor="#F2FFF2" bgcolor="#CCFFCC" width="67">
               <p align="center">
               <span style="font-family: Times New Roman">
               <input type="button" onclick="update(<%=userid%>)"  value="Update" name="B1" style="font-size: 8pt; font-weight: bold; background-color: #9999FF; float:right"></td>
    
    </tr>
  <%}%>
</table>

</body>

</html>